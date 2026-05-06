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
    private var _resource as AudioResourceType;

    function initialize(resource as AudioResourceType) {
        self._resource = resource;
    }

    public function getId() as String {
        return hashCode().toString();
    }

    public function getSourceUrl() as String {
        return (self._resource["source"] as AudioResourceSourceType)["url"] as String;
    }

    public function getTitle() as String? {
        return DictionaryUtils.getString(self._resource["meta"] as Dictionary?, "title");
    }

    public function getArtist() as String? {
        return DictionaryUtils.getString(self._resource["meta"] as Dictionary?, "artist");
    }

    public function getAlbum() as String? {
        return DictionaryUtils.getString(self._resource["meta"] as Dictionary?, "album");
    }

    public function serialize() as AudioResourceType {
        return {
            "source" => {
                "url" => getSourceUrl()
            },
            "meta" => {
                "title" => getTitle(),
                "artist" => getArtist(),
                "album" => getAlbum()
            }
        };
    }
}

function buildResources(resources as Array<AudioResourceType>) as Array<AudioResource> {
    var audio = [];

    if (resources instanceof Array) {
        for (var index = 0, limit = resources.size(); index < limit; index++) {
            audio.add(new AudioResource(resources[index]));
        }
    }

    return audio;
}

function serializeResources(resources as Array<AudioResource>) as Array<Application.Storage.ValueType> {
    var audio = [];

    if (resources instanceof Array) {
        for (var index = 0, limit = resources.size(); index < limit; index++) {
            audio.add(resources[index].serialize());
        }
    }

    return audio;
}
