using Toybox.Media as Media;
import Toybox.Lang;

// Owns what happened during playback
class PlaybackSession {

    private var _playlist as PlayerPlaylist;

    function initialize(playlist as PlayerPlaylist) {
        _playlist = playlist;
        savePlaybackState();
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