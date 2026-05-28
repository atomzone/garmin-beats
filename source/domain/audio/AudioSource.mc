import Toybox.Lang;

typedef AudioSourceType as { 
    "url" as String 
};

// Track exists remotely
class AudioSource {

    private var _url as String;
    private var _checksum as String?;

    function initialize(source as AudioSourceType) {
        _url = source["url"] as String;
    }

    public function getUrl() as String {
        return _url;
    }

    public function getChecksum() as String {
        if (_checksum != null) {
            return _checksum;
        }

        _checksum = StringUtils.checksum(canonicalize());
        return _checksum;
    }

    public function canonicalize() as String {
        return _url;
    }

    public function serialize() as AudioSourceType {
        return {
            "url" => _url
        };
    }
}