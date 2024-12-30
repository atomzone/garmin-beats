import Toybox.Lang;
import Toybox.Media;

class pumpContentIterator extends Media.ContentIterator {
    var playlist as TPlaylist = [];
    var trackpointer as Number = 0;

    function initialize(playlist as TPlaylist) {
        ContentIterator.initialize();

        self.playlist = playlist;
    }

    // Determine if the the current track can be skipped.
    function canSkip() as Boolean {
        return false;
    }

    // Get the current media content object.
    function get() as Content? {
        // GRAB THE CONTENT FROM ITS REF-ID
        var refId = self.playlist[self.trackpointer];
        var ref = new Media.ContentRef(refId, Media.CONTENT_TYPE_AUDIO);

        return Media.getCachedContentObj(ref);
    }

    // Get the current media content playback profile
    function getPlaybackProfile() as PlaybackProfile? {
        var profile = new Media.PlaybackProfile();
        profile.attemptSkipAfterThumbsDown = false;
        profile.playbackControls = [
            PLAYBACK_CONTROL_SKIP_BACKWARD,
            PLAYBACK_CONTROL_PLAYBACK,
            PLAYBACK_CONTROL_SKIP_FORWARD
        ];
        profile.playbackNotificationThreshold = 1;
        profile.requirePlaybackNotification = false;
        profile.skipPreviousThreshold = null;
        return profile;
    }

    // Get the next media content object.
    function next() as Content? {
        return null;
    }

    // Get the next media content object without incrementing the iterator.
    function peekNext() as Content? {
        return null;
    }

    // Get the previous media content object without decrementing the iterator.
    function peekPrevious() as Content? {
        return null;
    }

    // Get the previous media content object.
    function previous() as Content? {
        return null;
    }

    // Determine if playback is currently set to shuffle.
    function shuffling() as Boolean {
        return false;
    }

}
