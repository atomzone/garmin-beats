using Toybox.Media as Media;
import Toybox.Lang;

class PlaybackSession {

    private var _playlist as Playlist;
    private var _store as PlaylistStore;

    function initialize(playlist as Playlist, store as PlaylistStore) {
        _playlist = playlist;
        _store = store;
    }

    function onPlaybackPosition(contentRefId as Object, position as Number) as Void {
        var index = _playlist.getRefIds().indexOf(contentRefId);

        $.am.debug("[onPlaybackPosition] index=" + index + " Position=" + position);

        if (index < 0) {
            return;
        }

        _playlist.restoreResumePosition(position);
        save();
    }

    function onTrackStarted(contentRefId as Object) as Void {
        var index = _playlist.getRefIds().indexOf(contentRefId);

        $.am.debug("[onTrackStarted] index=" + index);

        if (index < 0) {
            return;
        }

        _playlist.setTrackIndex(index);
        save();
    }

    private function save() as Void {
        _store.setPlaylist(_playlist);
    }
}