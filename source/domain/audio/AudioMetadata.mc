import Toybox.Application;
import Toybox.Lang;

typedef AudioMetadataType as {
    "title" as String?,
    "artist" as String?,
    "album" as String?
};

class AudioMetadata {
    public var _title as String?;
    public var _artist as String?;
    public var _album as String?;

    function initialize(metadata as AudioMetadataType?) {
        if (metadata == null) {
            return;
        }

        _title = metadata["title"];
        _artist = metadata["artist"];
        _album = metadata["album"];
    }

    public function canonicalize() as String {
        return
            StringUtils.stringOrDefault(_title, "") + "|" +
            StringUtils.stringOrDefault(_artist, "") + "|" +
            StringUtils.stringOrDefault(_album, "");
    }

    public function serialize() as AudioMetadataType {
        return {
            "title" => _title,
            "artist" => _artist,
            "album" => _album
        };
    }
}
