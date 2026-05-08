using Toybox.Media as Media;
import Toybox.Lang;

class TrackEventHandler {

    private var _playlist as Playlist;
    private var _queue as PlaybackQueue;
    private var _store as PlaylistStore;
    private var _eventNames as Dictionary;
    private var _lastRefId as Object?;

    function initialize(playlist as Playlist, queue as PlaybackQueue, store as PlaylistStore) {
        _playlist = playlist;
        _queue = queue;
        _store = store;
        _lastRefId = null;
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

        // On new track start: only update index if track has genuinely changed (different refId)
        if (songEvent == Media.SONG_EVENT_START) {
            if (_lastRefId != contentRefId) {
                // Genuine track change: update cursor position
                var playFromIndex = _queue.getPlayIndex();
                if (_playlist.updateOnTrackStart(playFromIndex)) {
                    _store.setPlaylist(_playlist);
                    $.am.debug("[TrackEventHandler] stored trackStartIndex=" + playFromIndex + " lastTrackPosition=0");
                }
                _lastRefId = contentRefId;
            } else {
                // Same track restarted (e.g., skip at boundary): don't update cursor
                $.am.debug("[TrackEventHandler] same track restarted, not updating cursor");
            }
            return;
        }

        // On pause or stop: capture position in seconds for mid-track resume
        if (songEvent == Media.SONG_EVENT_PAUSE || songEvent == Media.SONG_EVENT_STOP) {
            var seconds = playbackPosition as Number;
            if (_playlist.updateResumePosition(seconds)) {
                _store.setPlaylist(_playlist);
                $.am.debug("[TrackEventHandler] stored lastTrackPosition=" + seconds);
            }
        }
    }

    private function eventName(songEvent as Media.SongEvent) as String {
        var value = _eventNames[songEvent];
        if (value instanceof String) {
            return value as String;
        }

        return "Unknown(" + songEvent + ")";
    }
}