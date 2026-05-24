import Toybox.Lang;

typedef PlaylistResourceType as {
    "id" as String,
    "title" as String,
    "desc" as String?,
    "tracks" as Array<AudioResourceType>
};

class PlaylistResource {

    private var _id as String;
    private var _checksum as String?;
    private var _tracks as Array<AudioResource> = [];
    private var _trackIds as Array<String> = [];
    private var _metadata as PlaylistMetadata;

    function initialize(raw as PlaylistResourceType) {
        _id = raw["id"] as String;

        // var metadata = raw["meta"] as PlaylistMetadataType?;
        _metadata = new PlaylistMetadata({
            "title" => raw["title"] as String,
            "description" => raw["desc"]
        });
        
        var tracks = raw["tracks"] as Array<AudioResourceType>;
        for (var i = 0; i < tracks.size(); i++) {
            _tracks.add(new AudioResource(tracks[i]));
            _trackIds.add(_tracks[i].getId());
        }
    }

    public function getId() as String {
        return _id;
    }

    public function getTitle() as String {
        return _metadata._title;
    }

    public function getDesc() as String? {
        return _metadata._description;
    }

    public function getTracks() as Array<AudioResource> {
        return _tracks;
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

        // we could simplify this unique method
        for (var i = 0, limit = _tracks.size(); i < limit; i++) {
            canonical += "|" + _tracks[i].canonicalize();
        }
        
        return canonical;
    }

    public function serialize() as PlaylistResourceType {
        var tracks = [];

        for (var i = 0; i < _tracks.size(); i++) {
            tracks.add(_tracks[i].serialize());
        }

        return {
            "id" => _id,
            "title" => getTitle(),
            "desc" => getDesc(),
            "tracks" => tracks
        };
    }

    static function fromArray(raw as Array<PlaylistResourceType>) as Array<PlaylistResource> {
        var playlists = [];

        for (var index = 0, limit = raw.size(); index < limit; index++) {
            playlists.add(new PlaylistResource(raw[index]));
        }

        return playlists;
    }
}
