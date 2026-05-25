import Toybox.Lang;

class PlayerPlaylist {

    private var _playlist as PlaylistAsset;
    private var _assetCount as Number = 0;
    private var _playFromIndex as Number;
    private var _lastTrackPositionSeconds as Number = 0;

    private var _storage as KeyValueStorage;

    function initialize(
        playlist as PlaylistAsset,
        playFromIndex as Number
    ) {
        _playlist = playlist;
        _assetCount = playlist.getTrackIds().size();

        _playFromIndex = isValidIndex(playFromIndex)
            ? playFromIndex
            : 0;

        _storage = new KeyValueStorage("TRACK");
    }

    function getAssetCount() as Number {
        return _assetCount;
    }

    function getAssetByIndex(index as Number) as AudioAsset {
        var trackId = _playlist.getTrackIds()[index];
        var track = _storage.get(trackId);

        return new AudioAsset(track as AudioAssetType);
    }

    function getCurrentTrackIndex() as Number {
        return _playFromIndex;
    }

    function setTrackIndex(index as Number) as Void {
        _playFromIndex = index;
    }

    function getCurrentTrackPosition() as Number {
        return _lastTrackPositionSeconds;
    }

    function setCurrentTrackPosition(position as Number) as Void {
        _lastTrackPositionSeconds = position;
    }

    function isValidIndex(index as Number) as Boolean {
        return !(index < 0 or index > _assetCount - 1);
    }
}