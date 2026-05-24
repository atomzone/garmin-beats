import Toybox.Lang;

typedef TrackAssetType as {
    "id" as String,
    "metadata" as AudioMetadataType
};

class TrackAsset {
    private var _id as String;
    private var _metadata as AudioMetadataType;

    function initialize(raw as TrackAssetType) {
        _id = raw["id"] as String;
        _metadata = raw["metadata"] as AudioMetadataType;
    }

    public function getId() as String {
        return _id;
    }

    public function serialize() as TrackAssetType {
        return {
            "id" => _id,
            "metadata" => _metadata
        };
    }
}
