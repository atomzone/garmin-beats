import Toybox.Lang;

class HttpRequestOptions {
    var options as Lang.Object = {};

    function initialize(context as Lang.Object?) {
        self.options[:context] = context;
        self.options[:headers] = {};
        self.setAuthorization("MediaBrowser Client=\"client\", Device=\"device\", DeviceId=\"device-id\", Version=\"version\", Token=\"17f2a2b1f5eb4deea49c993a87b23a0a\"");
    }

    function audioM4a() as HttpRequestOptions {
        self.options[:mediaEncoding] = Media.ENCODING_M4A;
        self.options[:responseType] = Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO;
        return self;
    }

    function get() as HttpRequestOptions {
        self.options[:method] = Communications.HTTP_REQUEST_METHOD_GET;
        return self;
    }

    function json() as HttpRequestOptions {
        self.options[:responseType] = Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON;
        return self;
    }

    function setAuthorization(authorization as Lang.String) as Void {
        self.options[:headers]["Authorization"] = authorization;
    }
}

typedef ResourceType as { 
    :href as String, 
    :parameters as Lang.Dictionary<Lang.Object, Lang.Object>?
};

typedef HandlerType as Method(args as Dictionary or String or Null, Context as Object) as Void;

class HttpRequest {
    private var handler as HandlerType;
    private var href as String;
    private var parameters as Lang.Dictionary<Lang.Object, Lang.Object>?;

    function initialize(
        resource as ResourceType,
        handler as HandlerType
    ) {
        self.href = resource[:href];
        self.parameters = resource[:parameters];
        self.handler = handler;
    }

    function getJson(context as Lang.Object?) as Void {
        self.makeRequest(
            new HttpRequestOptions(context).get().json()
        );
    }

    function download(
        context as Lang.Object?, 
        onProgressCallback as Method(totalBytesTransferred as Number, filesize as Number?) as Void
    ) as Void {
        var settings = new HttpRequestOptions(context).get().audioM4a();
        settings.options[:fileDownloadProgressCallback] = onProgressCallback;

        self.makeRequest(settings);
    }

    function onResponse(responseCode as Number, data as Dictionary?, context as Object) as Void {
        System.println("[+]\tResponse Code " + responseCode);

        // return response class
        self.handler.invoke(data, context);
    }

    function makeRequest(httpRequest as HttpRequestOptions) as Void {
        System.println("[+]\tHREF " + self.href);
        System.println("[+]\tHTTP params " + self.parameters);
        System.println("[+]\tHTTP options " + httpRequest.options);

        Communications.makeWebRequest(
            self.href, 
            self.parameters, 
            httpRequest.options, 
            method(:onResponse)
        ); 
    }
}
