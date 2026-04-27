using Toybox.Application.Storage;
using Toybox.Media;

import Toybox.Lang;

typedef AssetMeta as {
    "title" as String?,
    "url" as String?,
    "thumbsUp" as Boolean?
};

class AudioAsset extends MediaAsset {

    function initialize(id as Number) {
        MediaAsset.initialize(id, Media.CONTENT_TYPE_AUDIO);
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
        StorageManager.set(getStorageKey(), meta as Storage.ValueType);
    }

    function load() as AssetMeta {
        var defaultValue = { } as AssetMeta;
        var value = StorageManager.getOrDefault(getStorageKey(), defaultValue);
        return value as AssetMeta;
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
}
