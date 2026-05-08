using Toybox.Media as Media;
import Toybox.Lang;

class PlaybackProvider extends Media.ContentDelegate {

    private var _trackEventHandler as TrackEventHandler;
    private var _mIterator as Media.ContentIterator;

    function initialize(playlist as Playlist, store as PlaylistStore) {
        Media.ContentDelegate.initialize();

        var queue = new PlaybackQueue(
            playlist.getAssets(),
            playlist.getCurrentTrackIndex(),
            playlist.getResumePositionSeconds()
        );

        self._trackEventHandler = new TrackEventHandler(playlist, queue, store);
        self._mIterator = queue;
    }

    function getContentIterator() as Media.ContentIterator? {
        return self._mIterator;
    }

    // Called by the system when the queue needs to restart (e.g. repeat-all, re-entry).
    // Must return a valid iterator; returning null is undefined behavior on physical devices.
    function resetContentIterator() as Media.ContentIterator? {
        $.am.debug("[PlaybackProvider] resetContentIterator");
        (self._mIterator as PlaybackQueue).reset();
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
        self._trackEventHandler.notify(contentRefId, songEvent, playbackPosition);
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
}
