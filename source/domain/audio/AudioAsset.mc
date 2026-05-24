import Toybox.Lang;

typedef AudioAssetType as {
    "id" as String,
    "refId" as Object,
    "source" as AudioSourceType,
    "meta" as AudioMetadataType?
};

class AudioAsset {

    private var _id as String;
    private var _refId as Object;
    private var _source as AudioSource;
    private var _metadata as AudioMetadata;

    function initialize(raw as AudioAssetType) {
        _id = raw["id"] as String;
        _refId = raw["refId"] as Object;
        _source = new AudioSource(raw["source"] as AudioSourceType);
        _metadata = new AudioMetadata(raw["metadata"] as AudioMetadataType?);
    }

    public function getId() as String {
        return _id;
    }

    public function getRefId() as Object {
        return _refId;
    }

    public function serialize() as AudioAssetType {
        return {
            "id" => _id,
            "refId" => _refId,
            "source" => _source.serialize(),
            "metadata" => _metadata.serialize(),
        };
    }
}
