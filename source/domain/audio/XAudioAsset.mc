using Toybox.Application.Storage;
using Toybox.Media;

import Toybox.Lang;

class MediaAssetOld {
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

// AudioAsset - "Track exists locally"
// AudioAssetState - "User/device state for local track"
class XAudioAsset extends MediaAssetOld {

    function initialize(id as Number) {
        MediaAssetOld.initialize(id, Media.CONTENT_TYPE_AUDIO);
    }

    function getActiveContent(startPositionSeconds as Number) as Media.Content {
        var ref = getContentRef();
        var content = Media.getCachedContentObj(ref);
        return new Media.ActiveContent(ref, content.getMetadata(), startPositionSeconds);
    }

    // TODO: shoudl we passs content?
    function saveAndApplyMetadata(content as Media.Content?, meta as XAudioAsset) as Void {
        save(meta);
        $.am.debug("[AudioAsset] saveAndApplyMetadata refId=" + getRefId() + " title=" + meta["title"]);
        
        if (content != null) {
            var metadata = content.getMetadata();
            if (metadata != null) {
                metadata.title = meta["title"] as String;
                metadata.artist = meta["artist"] as String;
                metadata.album = meta["album"] as String;
                content.setMetadata(metadata);
            }
        }
    }

    function getStorageKey() as String {
        return "track:" + getRefId().toString();
    }

    function setThumbsUp(value as Boolean) as Void {
        var record = load();
        record["thumbsUp"] = value;

        save(record);
    }

    function save(meta as XAudioAsset) as Void {
        StorageManager.set(getStorageKey(), normalize(meta) as Storage.ValueType);
    }

    function load() as XAudioAsset {
        var defaultValue = {
            "title" => "Unknown",
            "artist" => "Unknown",
            "album" => "Unknown",
            "sourceUrl" => null,
            "logicalId" => null,
            "syncedAt" => null,
            "thumbsUp" => false
        };

        var value = StorageManager.getOrDefault(getStorageKey(), defaultValue);
        return normalize(value);
    }

    public function delete() as Void {
        StorageManager.delete(getStorageKey());
        MediaAssetOld.delete();
    }

    private function normalize(meta as Object?) as XAudioAsset {
        var record = {} as Dictionary;

        if (meta instanceof Dictionary) {
            record = meta as Dictionary;
        }

        var sourceUrl = DictionaryUtils.getString(record, "sourceUrl");

        var logicalId = DictionaryUtils.getString(record, "logicalId");
        if (logicalId == null && sourceUrl != null) {
            logicalId = XAudioAsset.logicalIdFromUrl(sourceUrl);
        }

        var normalized = {
            "title" => DictionaryUtils.getStringOrDefault(record, "title", "Unknown"),
            "artist" => DictionaryUtils.getStringOrDefault(record, "artist", "Unknown"),
            "album" => DictionaryUtils.getStringOrDefault(record, "album", "Unknown"),
            "sourceUrl" => sourceUrl,
            "logicalId" => logicalId,
            "syncedAt" => DictionaryUtils.getNumber(record, "syncedAt"),
            "thumbsUp" => DictionaryUtils.getBooleanOrDefault(record, "thumbsUp", false)
        };

        return normalized as XAudioAsset;
    }

    static function fromRefIds(ids as Array<Number>?) as Array<XAudioAsset> {
        if (ids == null) {
            return [];
        }

        var assets = [];
        for (var i = 0, limit = ids.size(); i < limit; i++) {
            assets.add(new XAudioAsset(ids[i]));
        }

        return assets;
    }

    static function getCachedAssetRefIds() as Array<Number> {
        return MediaAssetOld.getCachedMediaRefIds(Media.CONTENT_TYPE_AUDIO);
    }

    static function getCachedAssets() as Array<XAudioAsset> {
        return XAudioAsset.fromRefIds(
            XAudioAsset.getCachedAssetRefIds()
        );
    }

    // Canonical derivation of a logicalId from a source URL.
    // Use this wherever a stable identity is needed for a URL-keyed resource.
    static function logicalIdFromUrl(sourceUrl as String) as String {
        return "u:" + sourceUrl.hashCode().toString();
    }
}
