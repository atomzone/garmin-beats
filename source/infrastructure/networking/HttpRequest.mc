using Toybox.Communications as Comm;
using Toybox.Media as Media;
using Toybox.PersistedContent as PersistedContent;
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

typedef HandlerType as Method(response as ResponseType, context as Object) as Void;

class HttpRequest {
    private var _handler as HandlerType;
    private var _href as String;
    private var _parameters as Dictionary<Object, Object>?;

    function initialize(resource as ResourceType, handler as HandlerType) {
        self._href = resource[:href] as String;
        self._parameters = resource[:parameters];
        self._handler = handler;
    }

    function getJson(context as Object) as Void {
        self.makeRequest(
            new HttpRequestOptions(context).get().json()
        );
    }

    function getAudio(
        context as AudioDownloadContextType,
        onProgressCallback as Method(totalBytesTransferred as Number, filesize as Number?) as Void
    ) as Void {
        var settings = new HttpRequestOptions(context).get();
        var source = new MediaSource(context[:source] as MediaSourceType);

        if (source.getFormat().equals("m4a")) {
            settings.m4a();
        } else {
            settings.mp3();
        }

        settings.options[:fileDownloadProgressCallback] = onProgressCallback;

        self.makeRequest(settings);
    }

    function onResponse(
        responseCode as Number, 
        data as Dictionary or String or PersistedContent.Iterator or Null, 
        context as Object
    ) as Void {
        var isOk = isSuccessResponse(responseCode);
        var payload = data as Object?;
        var errorMessage = isOk ? null : getErrorMessage(responseCode);
        $.am.debug("[http.response] " + (isOk ? "ok" : "fail") + " code=" + responseCode + " error=" + (errorMessage == null ? "none" : errorMessage));

        var response = {
            :ok => isOk,
            :code => responseCode,
            :data => payload,
            :error => errorMessage
        } as ResponseType;

        self._handler.invoke(response, context);
    }

    private function isSuccessResponse(responseCode as Number) as Boolean {
        return responseCode >= 200 && responseCode < 300;
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
            default:
                return "HTTP request failed (" + responseCode + ")";
        }
    }

    private function makeRequest(httpRequest as HttpRequestOptions) as Void {
        $.am.debug("[http.request] url=" + self._href);
        Comm.makeWebRequest(
            self._href, 
            self._parameters, 
            httpRequest.options,
            method(:onResponse)
        ); 
    }
}
