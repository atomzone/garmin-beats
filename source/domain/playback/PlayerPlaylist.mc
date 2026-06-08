import Toybox.Lang;

typedef PlaybackCursorType as {
    "trackIndex" as Number,
    "trackPosition" as Number?,
};

class PlayerPlaylist {

    private var _playlist as PlaylistAsset;
    private var _assetCount as Number = 0;
    private var _playFromIndex as Number;
    private var _lastTrackPositionSeconds as Number;

    function initialize(
        cursor as PlaybackCursorType,
        playlist as PlaylistAsset
    ) {
        _playlist = playlist;
        _assetCount = playlist.getTrackIds().size();

        _playFromIndex = !isValidIndex(cursor["trackIndex"]) ? 0 : cursor["trackIndex"] as Number;
        _lastTrackPositionSeconds = cursor["trackPosition"] == null ? 0 : cursor["trackPosition"] as Number;
    }

    function getAssetCount() as Number {
        return _assetCount;
    }

    function getPlaylistId() as String {
        return _playlist.getId();
    }

    function getAssetByIndex(index as Number) as AudioAsset {
        var trackId = _playlist.getTrackIds()[index];
        var track = AppStores.tracks.load(trackId);

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

    function isValidIndex(index as Number?) as Boolean {
        return index != null && index >= 0 && index < _assetCount;
    }

    // Combine playlist and persisted playback state to determine the appropriate starting cursor for playback
    static function load(requestedPlaylistId as String?) as PlayerPlaylist? {

        var storedState = PlaybackStateStore.load();
        var playlistId = requestedPlaylistId;

        if (playlistId == null && storedState != null) {
            playlistId = storedState["playlistId"] as String;
        }

        if (playlistId == null) {
            return null;
        }

        var raw = AppStores.playlists.load(playlistId) as PlaylistAssetType;
        var playlistAsset = new PlaylistAsset(raw);
        var cursor = PlaybackStartPosition.getCursor(playlistAsset, storedState);

        return new PlayerPlaylist(cursor, playlistAsset);
    }

}