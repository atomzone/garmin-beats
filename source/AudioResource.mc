import Toybox.Lang;
import Toybox.StringUtil;

// Source used to create an asset
// Each `AudioResource` should represent a single provider - e.g. Soundcloud, Plex, Youtube
class AudioResource {
    var href as String;
    var id as String;

    function initialize(href as String, options as { :id as String }) {
        self.href = href;
        self.id = options[:id];
    }

    function getId() as String {
        return self.id;
    }

    function getTitle() as String {
        // parse href for filename - not really an options no regexp/slow devices
        // should be done in initialize()
        var title = self.href.toCharArray().reverse();
        var split = StringUtil.charArrayToString(title).find("/");

        if (split != null) {
            title = title.slice(0, split).reverse();
        }
        title = StringUtil.charArrayToString(title);

        // return "TITLE " + self.id;
        return title;
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
            :id => "id-1"
        }),
        new AudioResource("https://getsamplefiles.com/download/m4a/sample-3.m4a", {
            :id => "id-2"
        }),
        new AudioResource("https://getsamplefiles.com/download/m4a/sample-3.m4a", {
            :id => "id-3"
        }),
        new AudioResource("https://github.com/supermihi/pytaglib/raw/refs/heads/main/tests/data/issue46.m4a", {
            :id => "id-99"
        })
    ];
}
