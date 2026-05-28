import Toybox.Lang;

typedef MediaAssetType as {
    "refId" as Object
};

class MediaRecord {

    private var _refId as Object;

    function initialize(raw as MediaAssetType) {
        _refId = raw["refId"] as Object;
    }

    function getRefId() as Object {
        return _refId;
    }

    public function serialize() as MediaAssetType {
        return {
            "refId" => _refId
        };
    }
}
