import Toybox.Application;
import Toybox.Lang;

typedef AudioMetadataType as {
    "title" as String?,
    "artist" as String?,
    "album" as String?
};

class AudioMetadata {
    private var _title as String?;
    private var _artist as String?;
    private var _album as String?;

    function initialize(metadata as AudioMetadataType?) {
        if (metadata == null) {
            return;
        }

        _title = metadata["title"];
        _artist = metadata["artist"];
        _album = metadata["album"];
    }

    public function getTitle() as String? {
        return _title;
    }

    public function getArtist() as String? {
        return _artist;
    }

    public function getAlbum() as String? {
        return _album;
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
