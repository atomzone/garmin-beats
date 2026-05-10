using Toybox.Media as Media;
import Toybox.Lang;

// THIN WRAPPER: ContentDelegate with no retained state (OpenPlayer pattern)
// Responsibility: Factory for creating fresh ContentIterator instances
// The Garmin system may call methods on this delegate multiple times during a session.
// We must not retain state here; all state is managed by the iterator.
class PlaybackProvider extends Media.ContentDelegate {

    function initialize() {
        // STATELESS INITIALIZATION
        // No parameters, no state fields.
        // This delegate is just a factory; the real work happens in the iterator.
        Media.ContentDelegate.initialize();
    }

    function getContentIterator() as Media.ContentIterator? {
        // FRESH ITERATOR ON DEMAND
        // Each call creates a new PlaybackQueue instance.
        // The iterator loads tracks fresh from storage, not from stale in-memory state.
        return new PlaybackQueue();
    }

    function resetContentIterator() as Media.ContentIterator? {
        // RESET CREATES NEW INSTANCE
        // Don't try to reset a cached iterator; create a fresh one.
        // This ensures playback position and playlist are reloaded from storage.
        return new PlaybackQueue();
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
    
    function onShuffle() as Void {
        $.am.debug("[onShuffle]");
    }

    function onSong(contentRefId as Object, songEvent as Media.SongEvent, playbackPosition as Number or Media.PlaybackPosition) as Void {
        // Delegate to track event handler if needed
        // Could be enhanced to persist playback position
    }

    function onThumbsDown(contentRefId as Object) as Void {
        $.am.debugWithArgs("[onThumbsDown]", contentRefId);
        var asset = new AudioAsset(contentRefId as Number);
        asset.setThumbsUp(false);
    }

    function onThumbsUp(contentRefId as Object) as Void {
        $.am.debugWithArgs("[onThumbsUp]", contentRefId);
        var asset = new AudioAsset(contentRefId as Number);
        asset.setThumbsUp(true);
    }
}
