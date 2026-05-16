import Toybox.Lang;

class AssetRepository {

    private var _refIds as Array<Number>;
    private var _cache as Dictionary<Number, AudioAsset>;

    function initialize() {
        _refIds = MediaAsset.getCachedMediaRefIds(Media.CONTENT_TYPE_AUDIO);
        _cache = {};
    }

    function size() as Number {
        return _refIds.size();
    }

    // function getRefId(index as Number) as Number {
    //     return _refIds[index];
    // }

    function getAsset(index as Number) as AudioAsset {
        var refId = _refIds[index];

        if (_cache.hasKey(refId)) {
            return _cache[refId] as AudioAsset;
        }

        var asset = new AudioAsset(refId);

        _cache[refId] = asset;

        return asset;
    }

    function deleteAll() as Void {
        for(var index = 0, limit = size(); index < limit; index++) {
            getAsset(index).delete();
        }

        _refIds = [];
        _cache = {};
    }
}
