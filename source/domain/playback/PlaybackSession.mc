using Toybox.Media as Media;
import Toybox.Lang;

// Owns what happened during playback
class PlaybackSession {

    private var _playlist as PlayerPlaylist;

    function initialize(playlist as PlayerPlaylist) {
        _playlist = playlist;
        savePlaybackState();
    }

    function nextInternal() as Boolean {
        return seekChapter(1);
    }

    function previousInternal() as Boolean {
        return seekChapter(-1);
    }

    function peekNextChapter() as Number? {
        return peekChapter(1);
    }

    function peekPreviousChapter() as Number? {
        return peekChapter(-1);
    }

    function onResumeCheckpoint(position as Number) as Void {
        $.am().logger().debug("[onPlaybackPosition]", {
            "index" => _playlist.getCurrentTrackIndex(),
            "current" => _playlist.getCurrentTrackPosition(),
            "position" => position
        });

        _playlist.setCurrentTrackPosition(position);
        savePlaybackState();
    }

    function onTrackChanged() as Void {
        $.am().logger().debug("[onTrackChanged]", {
            "index" => _playlist.getCurrentTrackIndex()
        });

        _playlist.setCurrentTrackPosition(0);
        savePlaybackState();
    }

    // Handles playback events that affect the persisted session state.
    function handleSongEvent(
        contentRefId as Object,
        songEvent as Media.SongEvent,
        playbackPosition as Number
    ) as Void {

        // The active track has changed.
        if (
            songEvent == Media.SONG_EVENT_START ||
            songEvent == Media.SONG_EVENT_SKIP_NEXT ||
            songEvent == Media.SONG_EVENT_SKIP_PREVIOUS
        ) {
            onTrackChanged();
            return;
        }

        // The playback position needs checkpointing
        if (
            songEvent == Media.SONG_EVENT_SKIP_FORWARD ||
            songEvent == Media.SONG_EVENT_SKIP_BACKWARD ||
            songEvent == Media.SONG_EVENT_PAUSE ||
            songEvent == Media.SONG_EVENT_STOP
        ) {
            onResumeCheckpoint(playbackPosition);
        }
    }

    // Where would we go?
    private function peekChapter(step as Integer) as Number? {
        var chapters = _playlist.getCurrentAsset().getChapters();
        var current = _playlist.getCurrentTrackPosition();

        var i = step > 0 ? 0 : chapters.size() - 1;

        while (i >= 0 && i < chapters.size()) {
            var time = chapters[i].getTimeInSeconds();

            if ((step > 0 && time > current) || (step < 0 && time < current)) {
                return time;
            }

            i += step;
        }

        return null;
    }

    // Can i move here?
    private function seekChapter(step as Integer) as Boolean {
        var position = peekChapter(step);

        if (position == null) {
            return false;
        }

        _playlist.setCurrentTrackPosition(position);
        savePlaybackState();

        return true;
    }
    
    private function savePlaybackState() as Void {
        var currentState = buildStateFromPlaylist();
        // TODO: use a checksum-based guard here if write frequency becomes a concern.
        PlaybackStateStore.save(currentState);
    }

    private function buildStateFromPlaylist() as PlaybackStateType {
        return {
            "playlistId" => _playlist.getPlaylistId(),
            "trackId" => _playlist.getCurrentTrackId(),
            "trackPosition" => _playlist.getCurrentTrackPosition()
        };
    }
}

