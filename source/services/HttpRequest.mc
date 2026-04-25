import Toybox.Lang;

class HttpRequest {
    private var handler as HandlerType;
    private var href as String;
    private var parameters as Lang.Dictionary<Lang.Object, Lang.Object>?;

    function initialize(
        resource as ResourceType,
        handler as HandlerType
    ) {
        self.href = resource[:href] as String;
        self.parameters = resource[:parameters];
        self.handler = handler;
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
        self.handler.invoke(data, context);
    }

    function makeRequest(httpRequest as HttpRequestOptions) as Void {
        $.am.debug("[+]\tHREF " + self.href);
        $.am.debug("[+]\tHTTP params " + self.parameters);
        $.am.debug("[+]\tHTTP options " + httpRequest.options);

        Communications.makeWebRequest(
            self.href, 
            self.parameters, 
            httpRequest.options,
            method(:onResponse)
        ); 
    }
}
