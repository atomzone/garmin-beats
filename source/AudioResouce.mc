import Toybox.Lang;

typedef AudioResourceType as { "source" as AudioResouceSourceType };
typedef AudioResouceSourceType as { "url" as String };

class AudioResource extends Object {   
    private var resource as AudioResourceType;

    function initialize(resource as AudioResourceType) {
        self.resource = resource;
    }

    public function getId() as String {
        return hashCode().toString();
    }

    public function getSourceUrl() as String {
        return (self.resource["source"] as AudioResouceSourceType)["url"] as String;
    }

    public function serialize() as AudioResourceType {
        return {
            "source" => {
                "url" => getSourceUrl()
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

function serializeResources(resources as Array<AudioResource>) as Array<$.Toybox.Application.Storage.ValueType> {
    var audio = [];

    if (resources instanceof Array) {
        for (var index = 0, limit = resources.size(); index < limit; index++) {
            audio.add(resources[index].serialize());
        }
    }

    return audio;
}
