using Toybox.Communications as Comm;
using Toybox.Media as Media;
import Toybox.Lang;

class HttpRequest {
    private var _handler as HandlerType;
    private var _href as String;
    private var _parameters as Lang.Dictionary<Lang.Object, Lang.Object>?;

    function initialize(
        resource as ResourceType,
        handler as HandlerType
    ) {
        self._href = resource[:href] as String;
        self._parameters = resource[:parameters];
        self._handler = handler;
    }

    function getJson(context as Lang.Object) as Void {
        self.makeRequest(
            new HttpRequestOptions(context).get().json()
        );
    }

    function downloadMp3(
        context as Lang.Object, 
        onProgressCallback as Method(totalBytesTransferred as Number, filesize as Number?) as Void
    ) as Void {
        var settings = new HttpRequestOptions(context).get().mp3();
        settings.options[:fileDownloadProgressCallback] = onProgressCallback;

        self.makeRequest(settings);
    }

    function onResponse(responseCode as Number, data as Dictionary?, context as Object) as Void {
        var ok = responseCode > 0;
        $.am.debug("[http.response] " + (ok ? "ok" : "fail") + " code=" + responseCode);

        self._handler.invoke(data as Object, context); // Object widens type; handler narrows to Dictionary or Media.ContentRef
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

typedef ResourceType as { 
    :href as String, 
    :parameters as Lang.Dictionary<Lang.Object, Lang.Object>?
};

typedef HandlerType as Method(args as Object, Context as Object) as Void;
