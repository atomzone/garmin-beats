import Toybox.Application;
import Toybox.Lang;

typedef AudioResourceType as {
    "source" as AudioResourceSourceType,
    "meta" as AudioResourceMetaType?
};
typedef AudioResourceSourceType as { "url" as String };
typedef AudioResourceMetaType as {
    "title" as String?,
    "artist" as String?,
    "album" as String?
};

class AudioResource extends Object {   

    private var _url as String;
    private var _title as String?;
    private var _artist as String?;
    private var _album as String?;

    function initialize(raw as AudioResourceType) {
        var source = raw["source"] as AudioResourceSourceType;
        var meta = raw["meta"] as AudioResourceMetaType?;

        _url = source["url"] as String;
        
        if (meta != null) {
            _title = meta["title"];
            _artist = meta["artist"];
            _album = meta["album"];
        }
    }

    public function getId() as String {
        return hashCode().toString();
    }

    public function getSourceUrl() as String {
        return _url;
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

    public function serialize() as AudioResourceType {
        return {
            "source" => {
                "url" => _url
            },
            "meta" => {
                "title" => _title,
                "artist" => _artist,
                "album" => _album
            }
        };
    }

    static function fromArray(resources as Array<AudioResourceType>) as Array<AudioResource> {
        var audio = [];

        for (var index = 0, limit = resources.size(); index < limit; index++) {
            audio.add(new AudioResource(resources[index]));
        }
    
        return audio;
    }
}
