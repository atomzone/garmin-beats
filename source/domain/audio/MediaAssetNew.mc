import Toybox.Application;
import Toybox.Lang;

typedef MediaAssetNewType as {
    "id" as String,
    "refId" as Object
};

class MediaAssetNew {
    private var _id as String;
    private var _refId as Object;

    function initialize(raw as MediaAssetNewType) {
        _id = raw["id"] as String;
        _refId = raw["refId"] as Object;
    }

    public function getId() as String {
        return _id;
    }

    public function getRefId() as Object {
        return _refId;
    }

    public function serialize() as MediaAssetNewType {
        return {
            "id" => _id,
            "refId" => _refId
        };
    }
}
