import Toybox.Lang;

// Source used to create an asset
// Each `AudioResource` should represent a single provider - e.g. Soundcloud, Plex, Youtube
class AudioResource {
    var href as String;
    var id as String;

    function initialize(href as String, options as Dictionary) {
        self.href = href;
        self.id = options[:id];
    }

    function getId() as String {
        return self.id;
    }

    function getTitle() as String {
        return "TITLE " + self.id;
    }

    function toStorage() {
        return {
            "href" => self.href,
            "id" => getId()
        };
    }
}

function getAudioResources() as Array<AudioResource> {
    return [
        new AudioResource("https://getsamplefiles.com/download/m4a/sample-3.m4a", {
            :id => "id-3"
        })
    ];
}
