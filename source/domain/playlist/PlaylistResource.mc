import Toybox.Lang;

typedef PlaylistResourceType as {
    "title" as String,
    "desc" as String?,
    "tracks" as Array<AudioResourceType>
};

class PlaylistResource {

    private var _checksum as String?;
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

    public function getKey() as String {
        return _title; //StringUtils.checksum(_title);
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

    public function getChecksum() as String {
        if (_checksum != null) {
            return _checksum;
        }

        _checksum = StringUtils.checksum(canonicalize());
        return _checksum;
    }

    public function canonicalize() as String {
        var canonical = _title + "|" + StringUtils.stringOrDefault(_desc, "");

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
