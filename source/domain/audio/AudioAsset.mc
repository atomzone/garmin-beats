import Toybox.Lang;

typedef AudioAssetType as {
    "id" as String,
    "mediaId" as String,
    "metadata" as AudioMetadataType?
};

// Persisted immutable object
class AudioAsset {

    private var _id as String;
    private var _mediaId as String;
    private var _metadata as AudioMetadata;

    function initialize(raw as AudioAssetType) {
        _id = raw["id"] as String;
        _mediaId = raw["mediaId"] as String;
        _metadata = new AudioMetadata(raw["metadata"] as AudioMetadataType?);
    }

    // asset identity derives from content
    public function getId() as String {
        return _id;
    }

    // join to MediaRecord
    public function getMediaId() as String {
        return _mediaId;
    }

    public function getMetadata() as AudioMetadata {
        return _metadata;
    }

    public function serialize() as AudioAssetType {
        return {
            "id" => _id,
            "mediaId" => _mediaId,
            "metadata" => _metadata.serialize(),
        };
    }

    static function fromArray(raw as Array<AudioAssetType>) as Array<AudioAsset> {
        var assets = [];

        for (var index = 0, limit = raw.size(); index < limit; index++) {
            assets.add(new AudioAsset(raw[index]));
        }

        return assets;
    }
}
