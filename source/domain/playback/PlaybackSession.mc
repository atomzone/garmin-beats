using Toybox.Media as Media;
import Toybox.Lang;

// Owns what happened during playback
class PlaybackSession {

    private var _playlist as PlayerPlaylist;
    private var _store as KeyValueStorage?; // this id more like playback State

    function initialize(playlist as PlayerPlaylist, store as KeyValueStorage?) {
        _playlist = playlist;
        _store = store;
    }

    function onResumeCheckpoint(position as Number) as Void {
        $.am.debug("[onPlaybackPosition] index=" + _playlist.getCurrentTrackIndex() + " Current=" + _playlist.getCurrentTrackPosition() + ", New=" + position);

        _playlist.setCurrentTrackPosition(position);
        // _store.setPlaylist(_playlist);
    }

    function onTrackChanged() as Void {
        $.am.debug("[onTrackChanged] index=" + _playlist.getCurrentTrackIndex());

        _playlist.setCurrentTrackPosition(0);
        // _store.setPlaylist(_playlist);
    }
}