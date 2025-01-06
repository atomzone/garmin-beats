import Toybox.Lang;
import Toybox.Media;

// Audio asset owned by the service
// Extending `AudioFile` which is responsible for storage methods
class AudioAsset extends AudioFile {
    function initialize(refId as Object) {
        AudioFile.initialize(refId);
    }

    function getTitle() as String {
        return self.getMetadata()[:title];
    }

    function getMetadata() as Media.ContentMetadata {
        return self.getContent().getMetadata();
    }

    function setMetadata() as Void {
        var metaData = self.getMetadata();
        metaData.album = "ALBUM";
        metaData.artist = "ARTIST";
        metaData.title = "J:" + self.refId;

        self.getContent().setMetadata(metaData);
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
