using Toybox.Media;

import Toybox.Lang;

class MediaAsset {
    private var _refId as Object;
    private var _contentType as Media.ContentType;

    function initialize(refId as Object, contentType as Media.ContentType) {
        self._refId = refId;
        self._contentType = contentType;
    }

    function delete() as Void {
        Media.deleteCachedItem(self.getContentRef());
    }

    function getContent() as Media.Content {
        return Media.getCachedContentObj(self.getContentRef());
    }

    function getContentRef() as Media.ContentRef {
        return new Media.ContentRef(self._refId, self._contentType);
    }

    function getRefId() as Object {
        return self._refId;
    }

    static function getCachedMediaRefIds(contentType as Media.ContentType) as Array<Number> {
        var iterator = Media.getContentRefIter({ :contentType => contentType });
        var ids = [];

        if (iterator == null) {
            return ids;
        }

        var ref = iterator.next();
        while (ref != null) {
            ids.add(ref.getId() as Number);
            ref = iterator.next();
        }

        return ids;
    }
}
