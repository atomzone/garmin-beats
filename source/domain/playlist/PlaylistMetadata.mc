import Toybox.Application;
import Toybox.Lang;

typedef PlaylistMetadataType as {
    "title" as String,
    "description" as String?,
    "artwork" as String?
};

class PlaylistMetadata {
    public var _title as String = "";
    public var _description as String?;
    public var _artwork as String?;

    function initialize(metadata as PlaylistMetadataType?) {
        if (metadata == null) {
            return;
        }

        _title = metadata["title"] as String;
        _description = metadata["description"];
        _artwork = metadata["artwork"];
    }

    public function canonicalize() as String {
        return
            StringUtils.stringOrDefault(_title, "") + "|" +
            StringUtils.stringOrDefault(_description, "") + "|" +
            StringUtils.stringOrDefault(_artwork, "");
    }

    public function serialize() as PlaylistMetadataType {
        return {
            "title" => _title,
            "description" => _description,
            "artwork" => _artwork
        };
    }
}
