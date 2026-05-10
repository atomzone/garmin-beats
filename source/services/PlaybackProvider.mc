using Toybox.Media as Media;
import Toybox.Lang;

class PlaybackProvider extends Media.ContentDelegate {

    private var _playlist as Playlist;
    // private var _store as PlaylistStore;
    private var _trackEventHandler as TrackEventHandler?;
    private var _mIterator as Media.ContentIterator?;

    function initialize(playlist as Playlist, store as PlaylistStore) {
        Media.ContentDelegate.initialize();

        self._playlist = playlist;
        // self._store = store;

        rebuildIterator(self._playlist, "init");
    }

    function getContentIterator() as Media.ContentIterator? {
        $.am.debug("[PlaybackProvider.getContentIterator] assets=" + self._playlist.getAssets().size() + " index=" + self._playlist.getCurrentTrackIndex() + " resume=" + self._playlist.getResumePositionSeconds());
        return self._mIterator;
    }

    // Called by the system when the queue needs to restart (e.g. repeat-all, re-entry).
    // Must return a valid iterator; returning null is undefined behavior on physical devices.
    function resetContentIterator() as Media.ContentIterator? {
        // Rebuild from in-memory state to avoid rehydrating stale storage snapshots mid-session.
        rebuildIterator(self._playlist, "reset");
        return self._mIterator;
    }
    function onAdAction(adContext as Object) as Void {
        $.am.debugWithArgs("[onAdAction]", adContext);
    }

    function onCustomButton(button as Media.CustomButton) as Void {
        $.am.debugWithArgs("[onCustomButton]", button);
    }

    function onRepeat() as Void {
        $.am.debug("[onRepeat]");
    }
    
    // Respond to a command to turn shuffle on or off
    function onShuffle() as Void {
        $.am.debug("[onShuffle]");
    }

    // Handles a notification from the system that an event has
    // been triggered for the given song
    function onSong(contentRefId as Object, songEvent as Media.SongEvent, playbackPosition as Number or Media.PlaybackPosition) as Void {
        if (self._trackEventHandler != null) {
            (self._trackEventHandler as TrackEventHandler).notify(contentRefId, songEvent, playbackPosition);
        }
    }

    // Respond to a thumbs-down action
    function onThumbsDown(contentRefId as Object) as Void {
        $.am.debugWithArgs("[onThumbsDown]", contentRefId);

        var asset = new AudioAsset(contentRefId as Number);
        asset.setThumbsUp(false);
    }

    // Respond to a thumbs-up action
    function onThumbsUp(contentRefId as Object) as Void {
        $.am.debugWithArgs("[onThumbsUp]", contentRefId);

        var asset = new AudioAsset(contentRefId as Number);
        asset.setThumbsUp(true);
    }

    private function rebuildIterator(playlist as Playlist, reason as String) as Void {
        var queue = new PlaybackQueue(
            playlist.getAssets(),
            playlist.getCurrentTrackIndex(),
            playlist.getResumePositionSeconds()
        );

        $.am.debug("[PlaybackProvider." + reason + "] assets=" + playlist.getAssets().size() + " startIndex=" + playlist.getCurrentTrackIndex() + " resume=" + playlist.getResumePositionSeconds());

        // self._trackEventHandler = new TrackEventHandler(playlist, queue, self._store);
        self._mIterator = queue;
    }
}
