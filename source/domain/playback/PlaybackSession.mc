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

    function onResumeCheckpoint(position as Number) as Void {
        $.am.debug("[onPlaybackPosition] index=" + _playlist.getCurrentTrackIndex() + " Current=" + _playlist.getCurrentTrackPosition() + ", New=" + position);

        _playlist.setCurrentTrackPosition(position);
        savePlaybackState();
    }

    function onTrackChanged() as Void {
        $.am.debug("[onTrackChanged] index=" + _playlist.getCurrentTrackIndex());

        _playlist.setCurrentTrackPosition(0);
        savePlaybackState();
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
            "trackIndex" => _playlist.getCurrentTrackIndex(),
            "trackPosition" => _playlist.getCurrentTrackPosition()
        };
    }
}

