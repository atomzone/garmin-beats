import Toybox.Lang;

typedef PlaylistResourceType as {
    "title" as String,
    "desc" as String?,
    "tracks" as Array<AudioResourceType>
};

class PlaylistResource extends Object {   
    private var _title as String;
    private var _desc as String?;
    private var _tracks as Array<AudioResource>;

    function initialize(raw as PlaylistResourceType) {
        _title = raw["title"] as String;
        _desc = raw["desc"];
        _tracks = [];
        
        var tracks = raw["tracks"] as Array<AudioResourceType>;
        for (var i = 0; i < tracks.size(); i++) {
            _tracks.add(new AudioResource(tracks[i]));
        }
    }

    public function getId() as String {
        return hashCode().toString();
    }

    public function getTitle() as String {
        return _title;
    }

    public function getDesc() as String? {
        return _desc;
    }

    public function getTracks() as Array<AudioResource> {
        return _tracks;
    }

    public function serialize() as PlaylistResourceType {
        var tracks = [];

        for (var i = 0; i < _tracks.size(); i++) {
            tracks.add(_tracks[i].serialize());
        }

        return {
            "title" => _title,
            "desc" => _desc,
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
