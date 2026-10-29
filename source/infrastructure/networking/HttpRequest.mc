using Toybox.Communications as Comm;
using Toybox.Graphics;
using Toybox.Media as Media;
using Toybox.PersistedContent as PersistedContent;
using Toybox.Timer;
using Toybox.WatchUi;
import Toybox.Lang;

typedef ResponseType as {
    :ok as Boolean,
    :code as Number,
    :data as Object?,
    :error as String?
};

typedef ResultCallbackType as Method(result as Object?, error as String?) as Void;

typedef AudioDownloadContextType as {
    :mediaId as String,
    :entity as String,
    :source as MediaSourceType
};

typedef HandlerType as Method(response as ResponseType, context as Object?) as Void;

class HttpRequest {
    static const TIMEOUT_CODE as Number = -1009;
    static const REJECTED_CODE as Number = -1010;

    private var _handler as HandlerType?;
    private var _href as String;
    private var _context as Object?;

    private var _timer as Timer.Timer?;
    private var _executionTime as Number?;
    private var _inactivityTimeout as Number?;

    private var _settled as Boolean = false;
    private var _onProgress as Method?;

    function initialize(href as String, context as Object?, handler as HandlerType?) {
        _href = href;
        _context = context;
        _handler = handler;
    }

    // Fails the request when no response or progress arrives within the window
    function setInactivityTimeout(milliseconds as Number) as HttpRequest {
        _inactivityTimeout = milliseconds;
        return self;
    }

    // Stop listening; late native callbacks are ignored
    function abandon() as Void {
        _settled = true;
        stopTimeout();
    }

    function getJson(queryParameters as Dictionary<Object, Object>?) as Void {
        makeGetRequest(
            queryParameters,
            new HttpRequestOptions().get().expectJson()
        );
    }

    function postJson(body as Dictionary<Object, Object>) as Void {
        makePostRequest(
            body,
            new HttpRequestOptions().post().sendJson().expectJson()
        );
    }

    function getAudio(
        queryParameters as Dictionary<Object, Object>?,
        onProgressCallback as Method(totalBytesTransferred as Number, filesize as Number?) as Void
    ) as Void {
        var context = _context as AudioDownloadContextType;
        var settings = new HttpRequestOptions().get();
        var source = new MediaSource(context[:source] as MediaSourceType);

        if (source.getFormat().equals("m4a")) {
            settings.m4a();
        } else {
            settings.mp3();
        }

        settings.options[:fileDownloadProgressCallback] = method(:onDownloadProgress);
        _onProgress = onProgressCallback;

        makeGetRequest(queryParameters, settings);
    }

    function getImage(maxWidth as Number, maxHeight as Number) as Void {
        if (!hasTransport()) {
            settle(-1008, null);
            return;
        }

        $.am().logger().info("[http.request]", { "url" => _href, "method" => "IMAGE" });

        try {
            _executionTime = System.getTimer();
            Comm.makeImageRequest(_href, null, {
                :maxWidth => maxWidth,
                :maxHeight => maxHeight,
                :dithering => Comm.IMAGE_DITHERING_NONE,
                :packingFormat => Comm.PACKING_FORMAT_DEFAULT
            }, method(:onImageResponse));
        } catch (ex) {
            reject(ex);
            return;
        }

        if (!_settled) {
            startTimeout();
        }
    }

    function onDownloadProgress(totalBytesTransferred as Number, filesize as Number?) as Void {
        if (_settled) {
            return;
        }

        startTimeout();

        if (_onProgress != null) {
            _onProgress.invoke(totalBytesTransferred, filesize);
        }
    }

    function onResponse(
        responseCode as Number, 
        data as Dictionary or String or PersistedContent.Iterator or Null
    ) as Void {
        settle(responseCode, data);
    }

    function onImageResponse(
        responseCode as Number,
        data as WatchUi.BitmapResource or Graphics.BitmapReference or Null
    ) as Void {
        settle(responseCode, data);
    }

    function onTimeout() as Void {
        _timer = null;

        if (_settled) {
            return;
        }

        _settled = true;

        $.am().logger().warn("[http.timeout]", {
            "url" => _href, "timeout" => _inactivityTimeout
        });

        // global cancel is only safe because callers using timeouts run one request at a time;
        // cancel before deliver so a request started by the handler isn't killed
        Comm.cancelAllRequests();
        deliver(TIMEOUT_CODE, null);
    }

    private function settle(responseCode as Number, data as Object?) as Void {
        if (_settled) {
            return;
        }

        _settled = true;
        stopTimeout();
        deliver(responseCode, data);
    }

    private function deliver(responseCode as Number, data as Object?) as Void {
        var isOk = isSuccessResponse(responseCode);
        var payload = data as Object?;
        var errorMessage = isOk ? null : getErrorMessage(responseCode);
        var duration = _executionTime == null ? null : System.getTimer() - _executionTime;

        var response = {
            :ok => isOk,
            :code => responseCode,
            :data => payload,
            :error => errorMessage
        } as ResponseType;

        if (isOk) {
            $.am().logger().info("[http.response]", {
                "code" => responseCode,
                "duration_ms" => duration
            });
        }
        else {
            $.am().logger().error("[http.response]", { 
                "code" => responseCode,
                "payload" => payload,
                "error" => errorMessage,
                "duration_ms" => duration
            });
        }

        if (_handler != null) {
            _handler.invoke(response, _context);
        }
    }

    private function isSuccessResponse(responseCode as Number) as Boolean {
        return responseCode >= 200 && responseCode < 300;
    }

    private function makeGetRequest(
        queryParameters as Dictionary<Object, Object>?,
        httpRequest as HttpRequestOptions
    ) as Void {
        executeRequest(queryParameters, httpRequest);
    }

    private function makePostRequest(
        body as Dictionary<Object, Object>,
        httpRequest as HttpRequestOptions
    ) as Void {
        executeRequest(body, httpRequest);
    }

    private function executeRequest(
        parameters as Dictionary<Object, Object>?,
        httpRequest as HttpRequestOptions
    ) as Void {
        if (!hasTransport()) {
            onResponse(-1008, null);
            return;
        }

        var methodName = httpRequest.options[:method] as String;

        $.am().logger().info(
            "[http.request]", { "url" => _href, "method" => methodName }
        );

        try {
            _executionTime = System.getTimer();
            Comm.makeWebRequest(
                _href,
                parameters,
                httpRequest.options,
                method(:onResponse)
            );
        } catch (ex) {
            reject(ex);
            return;
        }

        // is this check for _settled needed?
        // why does this mean you need to start a timer??
        // infact how can you settle without an unique id?
        if (!_settled) {
            startTimeout();
        }
    }

    // native request calls throw on invalid options/unsupported response types
    private function reject(ex as Exception) as Void {
        $.am().logger().error("[http.rejected]", {
            "url" => _href, "error" => ex.getErrorMessage()
        });

        settle(REJECTED_CODE, null);
    }

    private function startTimeout() as Void {
        var timeout = _inactivityTimeout;
        if (timeout == null) {
            return;
        }

        stopTimeout();

        var timer = new Timer.Timer();
        timer.start(method(:onTimeout), timeout, false);
        _timer = timer;
    }

    private function stopTimeout() as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }
    
    private function hasTransport() as Boolean {
        var connectionInfo = System.getDeviceSettings().connectionInfo;
        var bluetooth = connectionInfo[:bluetooth];
        var wifi = connectionInfo[:wifi];

        var bluetoothConnected =
            bluetooth != null &&
            bluetooth.state == System.CONNECTION_STATE_CONNECTED;

        var wifiConnected =
            wifi != null &&
            wifi.state == System.CONNECTION_STATE_CONNECTED;

        // $.am().logger().info("[hasTransport]", { 
        //     "bluetoothConnected" => bluetoothConnected, 
        //     "wifiConnected" => wifiConnected
        // });
        
        return bluetoothConnected || wifiConnected;
    }

    private function getErrorMessage(responseCode as Number) as String? {
        if (responseCode >= 200 && responseCode < 300) {
            return null;
        }

        switch (responseCode) {
          case 0:
                return "UNKNOWN_ERROR: An unknown error has occurred.";

            // BLE errors
            case -1:
                return "BLE_ERROR: A generic BLE error has occurred.";
            case -2:
                return "BLE_HOST_TIMEOUT: Timed out waiting for a response from the host.";
            case -3:
                return "BLE_SERVER_TIMEOUT: Timed out waiting for a response from a server.";
            case -4:
                return "BLE_NO_DATA: Response contained no data.";
            case -5:
                return "BLE_REQUEST_CANCELLED: Request was cancelled at the request of the system.";
            case -101:
                return "BLE_QUEUE_FULL: Too many requests have been made.";
            case -102:
                return "BLE_REQUEST_TOO_LARGE: Serialized input data for the request was too large.";
            case -103:
                return "BLE_UNKNOWN_SEND_ERROR: Send failed for an unknown reason.";
            case -104:
                return "BLE_CONNECTION_UNAVAILABLE: No BLE connection is available.";

            // HTTP request errors
            case -200:
                return "INVALID_HTTP_HEADER_FIELDS_IN_REQUEST: Request contained invalid HTTP header fields.";
            case -201:
                return "INVALID_HTTP_BODY_IN_REQUEST: Request contained an invalid HTTP body.";
            case -202:
                return "INVALID_HTTP_METHOD_IN_REQUEST: Request used an invalid HTTP method.";
            case -300:
                return "NETWORK_REQUEST_TIMED_OUT: Request timed out before a response was received.";
            case -400:
                return "INVALID_HTTP_BODY_IN_NETWORK_RESPONSE: Response body data is invalid for the request type.";
            case -401:
                return "INVALID_HTTP_HEADER_FIELDS_IN_NETWORK_RESPONSE: Response contained invalid HTTP header fields.";
            case -402:
                return "NETWORK_RESPONSE_TOO_LARGE: Serialized response was too large.";
            case -403:
                return "NETWORK_RESPONSE_OUT_OF_MEMORY: Ran out of memory processing network response.";
            case -1000:
                return "STORAGE_FULL: Filesystem too full to store response data.";
            case -1001:
                return "SECURE_CONNECTION_REQUIRED: An HTTPS connection is required.";
            case -1002:
                return "UNSUPPORTED_CONTENT_TYPE_IN_RESPONSE: Response content type is unsupported or does not match what is expected.";
            case -1003:
                return "REQUEST_CANCELLED: HTTP request was cancelled by the system.";
            case -1004:
                return "REQUEST_CONNECTION_DROPPED: Connection was lost before a response could be obtained.";
            case -1005:
                return "UNABLE_TO_PROCESS_MEDIA: Downloaded media file was unable to be read.";
            case -1006:
                return "UNABLE_TO_PROCESS_IMAGE: Downloaded image file was unable to be processed.";
            case -1007:
                return "UNABLE_TO_PROCESS_HLS: HLS content could not be downloaded.";

            // Custom application error
            case -1008:
                return "NO_TRANSPORT: Network transport is not available.";
            case -1009:
                return "TIMEOUT: No response or progress within the inactivity timeout.";
            case -1010:
                return "REJECTED: The request could not be made.";

            default:
                return "HTTP request failed (" + responseCode + ")";
        }
    }
}
