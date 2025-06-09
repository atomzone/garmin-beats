import Toybox.Lang;
import Toybox.Media;

// Audio asset owned by the service
// Extending `AudioFile` which is responsible for storage methods
class AudioAsset extends AudioFile {
    private var store as StorageManager = new StorageManager("AUDIOASSET");

    function initialize(refId as Object) {
        AudioFile.initialize(refId);
    }

    function delete() as Void {
        store.delete(self.getId());
        AudioFile.delete();
    }

    function getResourceId() as String? {
        return store.get(self.getId()) as String?;
    }

    function getTitle() as String {
        return self.getMetadata()[:title];
    }

    // PROFILER HINTS THAT READIND METADATA IS COSTLY
    // AND IT /SEEMS/ TO CALL 'setMetadata()' \o/
    function getMetadata() as Media.ContentMetadata {
        return self.getContent().getMetadata();
    }

    // Creates defaults for missing metadata
    (:typecheck(false))
    function setMetadata() as Void {
        var metaData = self.getMetadata();
        var properties = {
            :album => "[Album]",
            :artist => "[Artist]",
            :genre => "[Genre]",
            :title => "[Title]",
            :trackNumber => 0
        };
        var methods = properties.keys();

        // use metadata or define some defaults
        for (var index = 0; index < methods.size(); index++) {
            var method = methods[index] as Symbol;

            // System.println("'" + metaData[method] + "'");
            // System.println("'" + (metaData[method] == "") + "'");
            // System.println("'" + (metaData[method].equals("")) + "'");

            // needs a instanceof Lang.String check here :|
            // not type safe here... :trackNumber is NUmber and number.equals() != exist
            // if (metaData[method] == "") {
            if (metaData[method].equals("")) {
                metaData[method] = properties.get(method);
            }
        }

        // System.println("======================");
        // System.println(metaData.album);
        // System.println(metaData.artist);
        // System.println(metaData.genre);
        // System.println(metaData.title);
        // System.println(metaData.trackNumber);
        // System.println("======================");

        self.getContent().setMetadata(metaData);
    }

    function setResourceId(id as String) as Void {
        store.put(self.getId(), id);
    }
}

function getAudioAssets() as Array<AudioAsset> {
    var assets = [];
    var mediaRefs = getCachedAudioRefIds();
    
    for (var index = 0; index < mediaRefs.size(); index++) {
        assets.add(new AudioAsset(mediaRefs[index]));
    }

    return assets;
}
