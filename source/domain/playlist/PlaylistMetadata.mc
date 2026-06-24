import Toybox.Application;
import Toybox.Lang;

typedef PlaylistMetadataType as {
    "title" as String,
    "description" as String?,
    "artwork" as MediaSourceType?
};

class PlaylistMetadata {
    private var _title as String = "";
    private var _description as String?;
    private var _artwork as MediaSource?;

    function initialize(metadata as PlaylistMetadataType?) {
        if (metadata == null) {
            return;
        }

        _title = metadata["title"] as String;
        _description = metadata["description"];
        
        if (metadata["artwork"] != null) {
            _artwork = new MediaSource(metadata["artwork"] as MediaSourceType);
        }
    }

    public function getTitle() as String {
        return _title;
    }

    public function getDescription() as String? {
        return _description;
    }

    public function getArtwork() as MediaSource? {
        return _artwork;
    }

    public function canonicalize() as String {
        var artwork = (_artwork == null) ? "" : _artwork.canonicalize();

        return
            StringUtils.stringOrDefault(_title, "") + "|" +
            StringUtils.stringOrDefault(_description, "") + "|" +
            artwork;
    }

    public function serialize() as PlaylistMetadataType {
        var artwork = (_artwork == null) ? null : _artwork.serialize();

        return {
            "title" => _title,
            "description" => _description,
            "artwork" => artwork
        };
    }
}
