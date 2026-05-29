import Toybox.Lang;

typedef AudioAssetType as {
    "mediaId" as String,
    "meta" as AudioMetadataType?
};

// Persisted immutable object
class AudioAsset {

    private var _checksum as String?;
    private var _mediaId as String;
    private var _metadata as AudioMetadata;

    function initialize(raw as AudioAssetType) {
        _mediaId = raw["mediaId"] as String;
        _metadata = new AudioMetadata(raw["metadata"] as AudioMetadataType?);
    }

    // asset identity derives from content
    public function getId() as String {
        return getChecksum();
    }

    // join to MediaRecord
    public function getMediaId() as String {
        return _mediaId;
    }

    public function getMetadata() as AudioMetadata {
        return _metadata;
    }

    public function getChecksum() as String {
        if (_checksum != null) {
            return _checksum;
        }

        _checksum = StringUtils.checksum(canonicalize());
        return _checksum;
    }

    public function canonicalize() as String {
        return _mediaId + "|" + _metadata.canonicalize();
    }

    public function serialize() as AudioAssetType {
        return {
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
