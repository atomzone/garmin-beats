import Toybox.Lang;
import Toybox.Media;

// Audio asset owned by the service
// Extending `AudioFile` which is responsible for storage methods
class AudioAsset extends AudioFile {
    var store as Storage = new Storage("AUDIOASSET");

    function initialize(refId as Object) {
        AudioFile.initialize(refId);
    }

    function delete() as Void {
        store.delete(self.getId());
        AudioFile.delete();
    }

    function getResourceId() as String? {
        return store.get(self.getId());
    }

    function getTitle() as String {
        return self.getMetadata()[:title];
    }

    function getMetadata() as Media.ContentMetadata {
        // PROFILER HINTS THAT READIND METADATA IS COSTLY
        // AND IT /SEEMS/ TO CALL 'setMetadata()' \o/

        // var tom = new ContentMetadata();

        // System.println(tom);
        // System.println(tom[:title]);

        // var fred = self.getContent().getMetadata();

        // System.println(fred);
        // System.println(fred[:title]);

        // return tom;

        return self.getContent().getMetadata();
    }

    function setMetadata() as Void {
        var metaData = self.getMetadata();

        System.println("======================");
        System.println(metaData.album);
        System.println(metaData.artist);
        System.println(metaData.genre);
        System.println(metaData.title);
        System.println(metaData.trackNumber);
        System.println("======================");

        metaData.album = "ALBUM";
        metaData.artist = "ARTIST";
        metaData.title = "J:" + self.refId;

        self.getContent().setMetadata(metaData);
    }

    function setResourceId(id as String) as Void {
        store.put(self.getId(), id);
    }
}

function getAudioAssets() as Array<AudioAsset> {
    var assets = [];
    var mediaRefs = getCachedAudioRefIds();
    
    for (var index = 0; index < mediaRefs.size(); ++index) {
        assets.add(new AudioAsset(mediaRefs[index]));
    }

    return assets;
}
