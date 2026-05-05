using Toybox.Media as Media;
import Toybox.Lang;

class TrackEventHandler {

    private var _playlist as Playlist;
    private var _queue as PlaybackQueue;
    private var _store as PlaylistStore;
    private var _eventNames as Dictionary;

    function initialize(playlist as Playlist, queue as PlaybackQueue, store as PlaylistStore) {
        _playlist = playlist;
        _queue = queue;
        _store = store;
        _eventNames = {
            Media.SONG_EVENT_START => "Start",
            Media.SONG_EVENT_SKIP_NEXT => "Skip Next",
            Media.SONG_EVENT_SKIP_PREVIOUS => "Skip Previous",
            Media.SONG_EVENT_PLAYBACK_NOTIFY => "Playback Notify",
            Media.SONG_EVENT_COMPLETE => "Complete",
            Media.SONG_EVENT_STOP => "Stop",
            Media.SONG_EVENT_PAUSE => "Pause",
            Media.SONG_EVENT_RESUME => "Resume",
            Media.SONG_EVENT_SKIP_FORWARD => "Skip Forward",
            Media.SONG_EVENT_SKIP_BACKWARD => "Skip Backward"
        } as Dictionary;
    }

    function notify(contentRefId as Object, songEvent as Media.SongEvent, playbackPosition as Number or Media.PlaybackPosition) as Void {
        $.am.debug("[TrackEventHandler] event=" + eventName(songEvent) + " contentRefId=" + contentRefId + " playbackPosition=" + playbackPosition);

        if (!shouldStoreIndex(songEvent)) {
            return;
        }

        var playFromIndex = _queue.getPlayIndex();
        if (playFromIndex == _playlist.getPlayFromIndex()) {
            return;
        }

        _playlist.setPlayFromIndex(playFromIndex);
        _store.setPlaylist(_playlist);

        $.am.debug("[TrackEventHandler] stored startIndex=" + playFromIndex + " event=" + eventName(songEvent));
    }

    private function shouldStoreIndex(songEvent as Media.SongEvent) as Boolean {
        return songEvent == Media.SONG_EVENT_START;
    }

    private function eventName(songEvent as Media.SongEvent) as String {
        var value = _eventNames[songEvent];
        if (value instanceof String) {
            return value as String;
        }

        return "Unknown(" + songEvent + ")";
    }
}