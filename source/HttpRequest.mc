import Toybox.Lang;

class HttpRequestOptions {
    var options as Lang.Object = {};

    function initialize(context as Lang.Object?) {
        self.options[:context] = context;
        self.setAuthorization("MediaBrowser Client=\"client\", Device=\"device\", DeviceId=\"device-id\", Version=\"version\", Token=\"8f63a081dc484594b0cc7c1cb48ebd4f\"");
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
        // refine with a merge
        self.options[:headers] = {
            "Authorization" => authorization
        };
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

    // function download(context as Lang.Object?) {
    //     var options = {
    //         :context => context,
    //         // :fileDownloadProgressCallback => method(:onProgress),
    //         :mediaEncoding => Media.ENCODING_M4A,
    //         :method => Communications.HTTP_REQUEST_METHOD_GET,
    //         :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO
    //     };
        
    //     Communications.makeWebRequest(self.href, null, options, method(:onResponse));       
    // }

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
