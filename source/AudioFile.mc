import Toybox.Lang;
import Toybox.Media;

class AudioFile {
    var refId as Object;

    // store the index to allow serialisation to storage
    function initialize(refId as Object) {
        self.refId = refId;
    }

    function delete() as Void {
        Media.deleteCachedItem(self.getContentRef());
    }

    function getContent() as Media.Content? {
        return Media.getCachedContentObj(self.getContentRef());
    }

    function getContentRef() as Media.ContentRef {
        return new Media.ContentRef(self.refId, Media.CONTENT_TYPE_AUDIO);
    }

    // Faster to convert meta to object properties?
    // OR will that cost more in mem than lookups?
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
