using Toybox.Communications as Comm;
using Toybox.Media as Media;
using Toybox.PersistedContent as PersistedContent;
using Toybox.Timer;
import Toybox.Lang;

typedef ResourceType as { 
    :href as String, 
    :parameters as Dictionary<Object, Object>?
};

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
    private var _parameters as Dictionary<Object, Object>?;
    private var _context as Object?;
    private var _timer as Timer.Timer?;
    private var _timeout as Number = 5000; // 5s

    function initialize(resource as ResourceType, context as Object?, handler as HandlerType?) {
        _href = resource[:href] as String;
        var parameters = resource[:parameters];
        _parameters = parameters == null ? {} : parameters;
        _context = context;
        _handler = handler;
    }

    function getJson() as Void {
        makeRequest(new HttpRequestOptions().get().json());
    }

    function postJson(body as Dictionary?) as Void {
        var requestBody = body == null ? _parameters : body;
        makeRequestWithBody(new HttpRequestOptions().post().json(), requestBody);
    }

    function getAudio(
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

        makeRequestWithBody(settings, _parameters);
    }

    function onResponse(
        responseCode as Number, 
        data as Dictionary or String or PersistedContent.Iterator or Null
    ) as Void {
        stopTimeout();

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
            $.am().logger().info("[http.response]", { "code" => responseCode, "payload" => payload });
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

    private function makeRequest(httpRequest as HttpRequestOptions) as Void {
        makeRequestWithBody(httpRequest, _parameters);
    }

    private function makeRequestWithBody(httpRequest as HttpRequestOptions, body as Dictionary?) as Void {
        if (!hasTransport()) {
            onResponse(-1008, null);
            return;
        }

        startTimeout();

        var requestBody = body == null ? {} : body as Dictionary;
        var methodName = httpRequest.options[:method] as String;

        $.am().logger().info(
            "[http.request]", { "url" => _href, "method" => methodName }
        );

        Comm.makeWebRequest(
            _href, 
            requestBody,
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
        
        return bluetoothConnected || wifiConnected;
    }

    private function getErrorMessage(responseCode as Number) as String? {
        if (responseCode >= 200 && responseCode < 300) {
            return null;
        }

        switch (responseCode) {
            case 0:
                return "UNKNOWN_ERROR: An unknown error has occurred.";
            case -200:
                return "INVALID_HTTP_HEADER_FIELDS_IN_REQUEST: Request contained invalid http header fields.";
            case -201:
                return "INVALID_HTTP_BODY_IN_REQUEST: Request contained an invalid http body.";
            case -202:
                return "INVALID_HTTP_METHOD_IN_REQUEST: Request used an invalid http method.";
            case -300:
                return "NETWORK_REQUEST_TIMED_OUT: Request timed out before a response was received.";
            case -400:
                return "INVALID_HTTP_BODY_IN_NETWORK_RESPONSE: Response body data is invalid for the request type.";
            case -401:
                return "INVALID_HTTP_HEADER_FIELDS_IN_NETWORK_RESPONSE: Response contained invalid http header fields.";
            case -402:
                return "NETWORK_RESPONSE_TOO_LARGE: Serialized response was too large.";
            case -403:
                return "NETWORK_RESPONSE_OUT_OF_MEMORY: Ran out of memory processing network response.";
            case -1000:
                return "STORAGE_FULL: Filesystem too full to store response data.";
            case -1001:
                return "SECURE_CONNECTION_REQUIRED: Indicates an https connection is required for the request.";
            case -1002:
                return "UNSUPPORTED_CONTENT_TYPE_IN_RESPONSE: Content type given in response is not supported or does not match what is expected.";
            case -1003:
                return "REQUEST_CANCELLED: Http request was cancelled by the system.";
            case -1004:
                return "REQUEST_CONNECTION_DROPPED: Connection was lost before a response could be obtained.";
            case -1005:
                return "UNABLE_TO_PROCESS_MEDIA: Downloaded media file was unable to be read.";
            case -1006:
                return "UNABLE_TO_PROCESS_IMAGE: Downloaded image file was unable to be processed.";
            case -1007:
                return "UNABLE_TO_PROCESS_HLS: HLS content could not be downloaded. Most often occurs when requested and provided bit rates do not match.";

            // custom
            case -1008:
                return "NO_TRANSPORT: Network transport is not available.";

            default:
                return "HTTP request failed (" + responseCode + ")";
        }
    }
}
