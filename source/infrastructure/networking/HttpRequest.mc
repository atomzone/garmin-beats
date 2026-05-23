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

    function downloadMp3(
        context as Object,
        onProgressCallback as Method(totalBytesTransferred as Number, filesize as Number?) as Void
    ) as Void {
        var settings = new HttpRequestOptions(context).get().mp3();
        settings.options[:fileDownloadProgressCallback] = onProgressCallback;

        self.makeRequest(settings);
    }

    function onResponse(
        responseCode as Number, 
        data as Dictionary or String or PersistedContent.Iterator or Null, 
        context as Object
    ) as Void {
        var ok = isSuccessResponse(responseCode);
        var payload = data as Object?;
        var errorMessage = ok ? null : "HTTP request failed";
        $.am.debug("[http.response] " + (ok ? "ok" : "fail") + " code=" + responseCode);

        var response = {
            :ok => ok,
            :code => responseCode,
            :data => payload,
            :error => errorMessage
        } as ResponseType;

        self._handler.invoke(response, context);
    }

    private function isSuccessResponse(responseCode as Number) as Boolean {
        return responseCode >= 200 && responseCode < 300;
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
