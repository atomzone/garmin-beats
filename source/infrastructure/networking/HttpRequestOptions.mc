using Toybox.Communications as Comm;
using Toybox.Media as Media;
import Toybox.Lang;

class HttpRequestOptions {
    public var options as { :headers as Dictionary } = {};

    function initialize() {
        self.options[:headers] = {};
        // self.setAuthorization("MediaBrowser Client=\"client\", Device=\"device\", DeviceId=\"device-id\", Version=\"version\", Token=\"17f2a2b1f5eb4deea49c993a87b23a0a\"");
    }

    function audio() as HttpRequestOptions {
        self.options[:responseType] = Comm.HTTP_RESPONSE_CONTENT_TYPE_AUDIO;
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
        self.options[:method] = Comm.HTTP_REQUEST_METHOD_GET;
        return self;
    }

    function post() as HttpRequestOptions {
        self.options[:method] = Comm.HTTP_REQUEST_METHOD_POST;
        return self;
    }

    function json() as HttpRequestOptions {
        self.options[:responseType] = Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON;
        // self.setHeader("Content-Type", "application/json");

        return self;
    }

    private function setHeader(key as String, value as String) as Void {
        var headers = self.options[:headers] as Dictionary;
        headers[key] = value;
    }
    
    // function setAuthorization(authorization as Lang.String) as Void {
    //     self.options[:headers]["Authorization"] = authorization;
    // }
}
