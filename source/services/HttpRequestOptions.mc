import Toybox.Lang;

class HttpRequestOptions {
    var options as { :context as Lang.Object, :headers as Dictionary } = {};

    function initialize(context as Lang.Object) {
        self.options[:context] = context;
        self.options[:headers] = {};
        // self.setAuthorization("MediaBrowser Client=\"client\", Device=\"device\", DeviceId=\"device-id\", Version=\"version\", Token=\"17f2a2b1f5eb4deea49c993a87b23a0a\"");
    }

    function audio() as HttpRequestOptions {
        self.options[:responseType] = Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO;
        return self;
    }

    function m4a() as HttpRequestOptions {
        self.options[:mediaEncoding] = Media.ENCODING_M4A;
        return self.audio();
    }

    function mp3() as HttpRequestOptions {
        self.options[:mediaEncoding] = Media.ENCODING_MP3;
        return self.audio();
    }

    function get() as HttpRequestOptions {
        self.options[:method] = Communications.HTTP_REQUEST_METHOD_GET;
        return self;
    }

    function json() as HttpRequestOptions {
        self.options[:responseType] = Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON;
        return self;
    }

    // function setAuthorization(authorization as Lang.String) as Void {
    //     self.options[:headers]["Authorization"] = authorization;
    // }
}

typedef ResourceType as { 
    :href as String, 
    :parameters as Lang.Dictionary<Lang.Object, Lang.Object>?
};

typedef HandlerType as Method(args as Dictionary or String or Null, Context as Object) as Void;
