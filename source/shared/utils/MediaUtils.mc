using Toybox.Media;

import Toybox.Lang;

class MediaUtils {

    static function getContent(refId as Object) as Media.Content {
        return Media.getCachedContentObj(
            new Media.ContentRef(refId, Media.CONTENT_TYPE_AUDIO)
        );
    }
    
    static function getActiveContent(refId as Object, startPositionSeconds as Number) as Media.Content {
        var content = MediaUtils.getContent(refId);

        return new Media.ActiveContent(
            content.getContentRef(), content.getMetadata(), startPositionSeconds
        );
    }

    static function getCachedMediaRefIds(contentType as Media.ContentType) as Array<Number> {
        var iterator = Media.getContentRefIter({ :contentType => contentType });
        var ids = [];

        if (iterator as Media.ContentRefIterator? == null) {
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
