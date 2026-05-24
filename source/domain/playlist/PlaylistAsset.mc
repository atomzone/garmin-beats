import Toybox.Lang;

typedef PlaylistAssetType as {
    "id" as String,
    "metadata" as PlaylistMetadataType,
    "trackIds" as Array<String>
};

class PlaylistAsset {

    private var _id as String;
    private var _checksum as String?;
    private var _trackIds as Array<String> = [];
    private var _metadata as PlaylistMetadata;

    // ID?! IT WONT SERIALISE!
    function initialize(raw as PlaylistAssetType) {
        _id = raw["id"] as String;
        _metadata = new PlaylistMetadata(raw["metadata"] as PlaylistMetadataType?);
        _trackIds = raw["trackIds"] as Array<String>;
    }

    public function getId() as String {
        return _id;
    }

    public function getTrackIds() as Array<String> {
        return _trackIds;
    }

    public function getMetadata() as PlaylistMetadata {
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
        var canonical = getMetadata().canonicalize();

        for (var i = 0, limit = _trackIds.size(); i < limit; i++) {
            canonical += "|" + _trackIds[i];
        }
        
        return canonical;
    }

    public function serialize() as PlaylistAssetType {
        return {
            "id" => _id,
            "metadata" => _metadata.serialize(),
            "tracksIds" => _trackIds
        };
    }

    static function fromArray(raw as Array<PlaylistAssetType>) as Array<PlaylistAsset> {
        var playlists = [];

        for (var index = 0, limit = raw.size(); index < limit; index++) {
            playlists.add(new PlaylistAsset(raw[index]));
        }

        return playlists;
    }
}
