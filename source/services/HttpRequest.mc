using Toybox.Communications as Comm;
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
        $.am.debug("[+]\tResponse " + (responseCode > 0 ? "SUCCESS" : "FAIL"));
        $.am.debug("[+]\tResponse Code " + responseCode);

        // Media.notifySyncComplete("Fail");

        // return response class
        self._handler.invoke(data, context);
    }

    function makeRequest(httpRequest as HttpRequestOptions) as Void {
        $.am.debug("[+]\tHREF " + self._href);
        $.am.debug("[+]\tHTTP params " + self._parameters);
        $.am.debug("[+]\tHTTP options " + httpRequest.options);

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

typedef HandlerType as Method(args as Dictionary or String or Null, Context as Object) as Void;
