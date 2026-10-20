using Toybox.Communications as Comm;
using Toybox.Media as Media;
using Toybox.PersistedContent as PersistedContent;
using Toybox.Timer;
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
    private var _handler as HandlerType?;
    private var _href as String;
    private var _context as Object?;
    private var _timer as Timer.Timer?;
    private var _timeout as Number = 5000; // 5s

    function initialize(href as String, context as Object?, handler as HandlerType?) {
        _href = href;
        _context = context;
        _handler = handler;
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

        settings.options[:fileDownloadProgressCallback] = onProgressCallback;

        makeGetRequest(queryParameters, settings);
    }

    function onResponse(
        responseCode as Number, 
        data as Dictionary or String or PersistedContent.Iterator or Null
    ) as Void {
        // stopTimeout();

        var isOk = isSuccessResponse(responseCode);
        var payload = data as Object?;
        var errorMessage = isOk ? null : getErrorMessage(responseCode);

        var response = {
            :ok => isOk,
            :code => responseCode,
            :data => payload,
            :error => errorMessage
        } as ResponseType;

        if (isOk) {
            $.am().logger().info("[http.response]", { "code" => responseCode }); //, "payload" => payload });
        }
        else {
            $.am().logger().error("[http.response]", { 
                "code" => responseCode, "payload" => payload, "error" => errorMessage 
            });
        }

        if (_handler != null) {
            _handler.invoke(response, _context);
        }
    }

    // this timeout is canceling ligit long downloads...
    function onTimeout() as Void {
        _timer = null;

        $.am().logger().warn("[http.timeout] Cancel all requests", {
            "timeout" => _timeout
        });

        Comm.cancelAllRequests();
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

        // startTimeout();

        var methodName = httpRequest.options[:method] as String;

        $.am().logger().info(
            "[http.request]", { "url" => _href, "method" => methodName }
        );

        Comm.makeWebRequest(
            _href,
            parameters,
            httpRequest.options,
            method(:onResponse)
        );
    }

    private function startTimeout() as Void {
        stopTimeout();

        _timer = new Timer.Timer();
        _timer.start(method(:onTimeout), _timeout, false);
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

        $.am().logger().info("[hasTransport]", { 
            "bluetoothConnected" => bluetoothConnected, 
            "wifiConnected" => wifiConnected
        });
        
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

            default:
                return "HTTP request failed (" + responseCode + ")";
        }
    }
}
