import Toybox.Lang;

typedef MediaRecordType as {
    "refId" as Object,
    "source" as MediaSourceType
};

// Physical stored media
class MediaRecord {

    private var _refId as Object;
    private var _source as MediaSource;

    function initialize(raw as MediaRecordType) {
        _refId = raw["refId"] as Object;
        _source = new MediaSource(raw["source"] as MediaSourceType);
    }

    function getRefId() as Object {
        return _refId;
    }

    public function getSource() as MediaSource {
        return _source;
    }

    public function serialize() as MediaRecordType {
        return {
            "refId" => _refId,
            "source" => _source.serialize(),
        };
    }
}
