import Toybox.Lang;
import Toybox.Media;

class AudioFile {
    var refId as Object;

    function initialize(refId as Object) {
        self.refId = refId;
    }

    function delete() as Void {
        Media.deleteCachedItem(self.getContentRef());
    }

    function getContent() as Media.Content? {
        // instead of writing metadat to the saved audio
        // we could return active content with specific metadata
        // and play position
        //
        // var content = Media.getCachedContentObj(self.getContentRef());
		// var metadata = content.getMetadata();
        // var playbackStartPos = 0; // think podcast and resuming long mixes
        // return new Media.ActiveContent(self.getContentRef(), metadata, playbackStartPos);
        //
        return Media.getCachedContentObj(self.getContentRef());
    }

    function getContentRef() as Media.ContentRef {
        return new Media.ContentRef(self.refId, Media.CONTENT_TYPE_AUDIO);
    }

    function getId() as String {
        return self.refId.toString();
    }
}
