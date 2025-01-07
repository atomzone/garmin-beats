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
        return Media.getCachedContentObj(self.getContentRef());
    }

    function getContentRef() as Media.ContentRef {
        return new Media.ContentRef(self.refId, Media.CONTENT_TYPE_AUDIO);
    }

    function getId() as String {
        return self.refId.toString();
    }
}
