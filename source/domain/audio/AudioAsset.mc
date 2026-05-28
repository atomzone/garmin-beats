import Toybox.Lang;

typedef AudioAssetType as {
    "refId" as Object,
    "source" as AudioSourceType,
    "meta" as AudioMetadataType?
};

// Persisted immutable object
class AudioAsset {

    private var _checksum as String?;
    private var _refId as Object;
    private var _source as AudioSource;
    private var _metadata as AudioMetadata;

    function initialize(raw as AudioAssetType) {
        _refId = raw["refId"] as Object;
        _source = new AudioSource(raw["source"] as AudioSourceType);
        _metadata = new AudioMetadata(raw["metadata"] as AudioMetadataType?);
    }

    // asset identity derives from content
    public function getId() as String {
        return getChecksum();
    }

    // media identity derives from source
    public function getMediaId() as String {
        return _source.getChecksum();
    }

    // convenience prevents lookup of media record
    public function getRefId() as Object {
        return _refId;
    }

    public function getMetadata() as AudioMetadata {
        return _metadata;
    }

    public function getSource() as AudioSource {
        return _source;
    }

    public function getChecksum() as String {
        if (_checksum != null) {
            return _checksum;
        }

        _checksum = StringUtils.checksum(canonicalize());
        return _checksum;
    }

    public function canonicalize() as String {
        return _source.canonicalize() + "|" + _metadata.canonicalize();
    }

    public function serialize() as AudioAssetType {
        return {
            "refId" => _refId,
            "source" => _source.serialize(),
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
