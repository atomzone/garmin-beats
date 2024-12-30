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
        System.println("canSkip");
        return false;
    }

    // Get the current media content object.
    function get() as Content? {
        System.println("get");
        
        return getMediaContent(self.trackpointer);
    }

    function getMediaContent(index as Number) as Content? {
        if (index < 0 or index > self.playlist.size() - 1) {
            return null;
        }

        var refId = self.playlist[index];
        var ref = new Media.ContentRef(refId, Media.CONTENT_TYPE_AUDIO);

        System.println("MEDIA" + refId + " INDEX " + index);

        return Media.getCachedContentObj(ref);
    }

    // Get the current media content playback profile
    function getPlaybackProfile() as PlaybackProfile? {
        var profile = new Media.PlaybackProfile();
        profile.attemptSkipAfterThumbsDown = false;
        profile.playbackControls = [
            PLAYBACK_CONTROL_SKIP_BACKWARD,
            PLAYBACK_CONTROL_NEXT,
            PLAYBACK_CONTROL_PLAYBACK,
            PLAYBACK_CONTROL_PREVIOUS,
            PLAYBACK_CONTROL_SKIP_FORWARD
        ];
        profile.playbackNotificationThreshold = 1;
        profile.requirePlaybackNotification = false;
        profile.skipPreviousThreshold = null;
        return profile;
    }

    // Get the next media content object.
    function next() as Content? {
        System.println("next");
        
        return getMediaContent(self.trackpointer + 1);
    }

    // Get the next media content object without incrementing the iterator.
    function peekNext() as Content? {
        System.println("peekNext");
        
        return getMediaContent(self.trackpointer + 1);
    }

    // Get the previous media content object without decrementing the iterator.
    function peekPrevious() as Content? {
        System.println("peekPrevious");
        
        return getMediaContent(self.trackpointer - 1);
    }

    // Get the previous media content object.
    function previous() as Content? {
        System.println("previous");
        
        return getMediaContent(self.trackpointer - 1);
    }

    // Determine if playback is currently set to shuffle.
    function shuffling() as Boolean {
        System.println("shuffling");
        return false;
    }

}
