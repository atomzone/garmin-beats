import Toybox.Lang;

// lets make this light weight with just the refIds
// and load the asset when demanded...
class AssetManager {
    private var _assets as Array<AudioAsset>;

    function initialize() {
        _assets = AudioAsset.getCachedAssets(); // move this fnc to manager
    }

    function delete() as Void {
        for (var i = 0, limit = _assets.size(); i < limit; i++) {
            _assets[i].delete();
        }

        _assets = [];
    }

    function size() as Number {
        return _assets.size();
    }
}
