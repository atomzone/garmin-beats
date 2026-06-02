using Toybox.Media;
import Toybox.Lang;

class MediaUtils {

    static function getContentRef(refId as Object) as Media.ContentRef {
        return new Media.ContentRef(refId, Media.CONTENT_TYPE_AUDIO);
    }

    static function getContent(refId as Object) as Media.Content {
        return Media.getCachedContentObj(getContentRef(refId));
    }

    static function getContentWithMetadata(
        refId as Object, 
        metadata as Media.ContentMetadata
    ) as Media.Content {
        return new Media.Content(getContentRef(refId), metadata);
    }
    
    // Currently unused: no active call sites in source.
    static function getActiveContent(refId as Object, startPositionSeconds as Number) as Media.Content {
        var content = MediaUtils.getContent(refId);

        return new Media.ActiveContent(
            content.getContentRef(), content.getMetadata(), startPositionSeconds
        );
    }

    static function getActiveContentWithMetadata(
        refId as Object, 
        metadata as Media.ContentMetadata,
        startPositionSeconds as Number
    ) as Media.Content {
        return new Media.ActiveContent(
            getContentRef(refId), metadata, startPositionSeconds
        );
    }

    static function getCachedMediaRefIds(contentType as Media.ContentType) as Array<Object> {
        var iterator = Media.getContentRefIter({ :contentType => contentType });
        var ids = [];

        if (iterator as Media.ContentRefIterator? == null) {
            return ids;
        }

        var ref = iterator.next();
        while (ref != null) {
            ids.add(ref.getId());
            ref = iterator.next();
        }

        return ids;
    }

    static function delete(refId as Object) as Void {
        Media.deleteCachedItem(getContentRef(refId));
    }
}
