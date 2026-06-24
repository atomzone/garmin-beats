import Toybox.Lang;

typedef MediaSourceType as { 
    "url" as String 
};

// Track exists remotely
// class AudioSource extends MediaSource {} 

// Image exists remotely
// how does this convert to loading from strage or n/a
// class AudioSource extends MediaSource {} 

class MediaSource {

    private var _url as String;
    private var _checksum as String?;

    function initialize(source as MediaSourceType) {
        _url = source["url"] as String;
    }

    public function getId() as String {
        return getChecksum();
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

    public function serialize() as MediaSourceType {
        return {
            "url" => _url
        };
    }
}