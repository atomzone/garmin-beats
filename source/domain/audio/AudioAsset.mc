import Toybox.Lang;

typedef AudioAssetType as {
    "id" as String,
    "mediaId" as String,
    "metadata" as AudioMetadataType?,
    "chapters" as Array<AudioChapterType>?
};

// Persisted immutable object
class AudioAsset {

    private var _id as String;
    private var _mediaId as String;
    private var _metadata as AudioMetadata;
    private var _chapters as Array<AudioChapter> = [];

    function initialize(raw as AudioAssetType) {
        _id = raw["id"] as String;
        _mediaId = raw["mediaId"] as String;
        _metadata = new AudioMetadata(raw["metadata"] as AudioMetadataType?);

        if (raw["chapters"] != null) {
            _chapters = AudioChapter.fromArray(raw["chapters"] as Array<AudioChapterType>);
        }
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

    public function getChapters() as Array<AudioChapter> {
        return _chapters;
    }

    public function serialize() as AudioAssetType {
        return {
            "id" => _id,
            "mediaId" => _mediaId,
            "metadata" => _metadata.serialize(),
            "chapters" => AudioChapter.serializeArray(_chapters)
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
