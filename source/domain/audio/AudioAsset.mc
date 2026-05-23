using Toybox.Application.Storage;
using Toybox.Media;

import Toybox.Lang;

typedef AssetMeta as {
    "title" as String?,
    "artist" as String?,
    "album" as String?,
    "sourceUrl" as String?,
    "logicalId" as String?,
    "syncedAt" as Number?,
    "thumbsUp" as Boolean?
};

// AudioAsset - "Track exists locally"
// AudioAssetState - "User/device state for local track"
class AudioAsset extends MediaAsset {

    function initialize(id as Number) {
        MediaAsset.initialize(id, Media.CONTENT_TYPE_AUDIO);
    }

    function getActiveContent(startPositionSeconds as Number) as Media.Content {
        var ref = getContentRef();
        var content = Media.getCachedContentObj(ref);
        return new Media.ActiveContent(ref, content.getMetadata(), startPositionSeconds);
    }

    // TODO: shoudl we passs content?
    function saveAndApplyMetadata(content as Media.Content?, meta as AssetMeta) as Void {
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

    function save(meta as AssetMeta) as Void {
        StorageManager.set(getStorageKey(), normalize(meta) as Storage.ValueType);
    }

    function load() as AssetMeta {
        var defaultValue = {
            "title" => "Unknown",
            "artist" => "Unknown",
            "album" => "Unknown",
            "sourceUrl" => null,
            "logicalId" => null,
            "syncedAt" => null,
            "thumbsUp" => false
        } as AssetMeta;

        var value = StorageManager.getOrDefault(getStorageKey(), defaultValue);
        return normalize(value);
    }

    public function delete() as Void {
        StorageManager.delete(getStorageKey());
        MediaAsset.delete();
    }

    private function normalize(meta as Object?) as AssetMeta {
        var record = {} as Dictionary;

        if (meta instanceof Dictionary) {
            record = meta as Dictionary;
        }

        var sourceUrl = DictionaryUtils.getString(record, "sourceUrl");

        var logicalId = DictionaryUtils.getString(record, "logicalId");
        if (logicalId == null && sourceUrl != null) {
            logicalId = AudioAsset.logicalIdFromUrl(sourceUrl);
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

        return normalized as AssetMeta;
    }

    static function fromRefIds(ids as Array<Number>?) as Array<AudioAsset> {
        if (ids == null) {
            return [];
        }

        var assets = [];
        for (var i = 0, limit = ids.size(); i < limit; i++) {
            assets.add(new AudioAsset(ids[i]));
        }

        return assets;
    }

    static function getCachedAssetRefIds() as Array<Number> {
        return MediaAsset.getCachedMediaRefIds(Media.CONTENT_TYPE_AUDIO);
    }

    static function getCachedAssets() as Array<AudioAsset> {
        return AudioAsset.fromRefIds(
            AudioAsset.getCachedAssetRefIds()
        );
    }

    // Canonical derivation of a logicalId from a source URL.
    // Use this wherever a stable identity is needed for a URL-keyed resource.
    static function logicalIdFromUrl(sourceUrl as String) as String {
        return "u:" + sourceUrl.hashCode().toString();
    }
}
