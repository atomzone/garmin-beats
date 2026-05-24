import Toybox.Lang;

class XAudioAssetRepository {

    private var _refIds as Array<Number>;
    private var _cache as Dictionary<Number, XAudioAsset>;

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

    function getAsset(index as Number) as XAudioAsset {
        var refId = _refIds[index];

        if (_cache.hasKey(refId)) {
            return _cache[refId] as XAudioAsset;
        }

        var asset = new XAudioAsset(refId);

        _cache[refId] = asset;

        return asset;
    }

    function deleteAll() as Void {
        for(var index = 0, limit = size(); index < limit; index++) {
            getAsset(index).delete();
        }

        _refIds = [];
        _cache = {};

        // TODO: move this 
        // who is the owner of assets and syncstates and coordinates the realtionship?
        SyncStateStore.removalAll();
    }
}
