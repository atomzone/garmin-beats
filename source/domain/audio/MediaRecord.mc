import Toybox.Lang;

typedef MediaRecordType as {
    "refId" as Object,
    "source" as AudioSourceType
};

// Physical stored media
class MediaRecord {

    private var _refId as Object;
    private var _source as AudioSource;

    function initialize(raw as MediaRecordType) {
        _refId = raw["refId"] as Object;
        _source = new AudioSource(raw["source"] as AudioSourceType);
    }

    function getRefId() as Object {
        return _refId;
    }

    public function getSource() as AudioSource {
        return _source;
    }

    public function serialize() as MediaRecordType {
        return {
            "refId" => _refId,
            "source" => _source.serialize(),
        };
    }
}
