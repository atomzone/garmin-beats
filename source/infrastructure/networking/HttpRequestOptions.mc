using Toybox.Communications as Comm;
using Toybox.Media as Media;
import Toybox.Lang;

class HttpRequestOptions {
    public var options as { :headers as Dictionary } = {};

    function initialize() {
        self.options[:headers] = {
            "x-atom" => "Garmin-Beats/1.0"
        };
    }

    function get() as HttpRequestOptions {
        self.options[:method] = Comm.HTTP_REQUEST_METHOD_GET;
        return self;
    }

    function post() as HttpRequestOptions {
        self.options[:method] = Comm.HTTP_REQUEST_METHOD_POST;
        return self;
    }

    // Configures the format of the outgoing request data.
    function sendJson() as HttpRequestOptions {
        self.setHeader("Content-Type", Comm.REQUEST_CONTENT_TYPE_JSON);
        return self;
    }

    // Configures how the response is parsed.
    function expectJson() as HttpRequestOptions {
        self.options[:responseType] = Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON;
        return self;
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

    private function setHeader(key as String, value as Number) as Void {
        var headers = self.options[:headers] as Dictionary;
        headers[key] = value;
    }
}
