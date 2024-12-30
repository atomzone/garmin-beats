import Toybox.Lang;
import Toybox.Media;

class pumpContentIterator extends Media.ContentIterator {
    var playlist as Playlist;

    function initialize(playlist as Playlist) {
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
        
        return getMediaContent(self.playlist.getActiveIndex());
    }

    function getMediaContent(index as Number) as Content? {
        if (!self.playlist.isValidIndex(index)) {
            return null;
        }

        var refId = self.playlist.getTrack(index);
        var ref = new Media.ContentRef(refId, Media.CONTENT_TYPE_AUDIO);
        
        var tom = new ContentMetadata();
        tom.title = index + ": TOM";
        Media.getCachedContentObj(ref).setMetadata(tom);

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

        var index = self.playlist.getActiveIndex() + 1;
        var content = getMediaContent(index);
        
        if (content != null) {
            self.playlist.setActiveIndex(index);
        }
        
        return content;
    }

    // Get the next media content object without incrementing the iterator.
    function peekNext() as Content? {
        System.println("peekNext");
        
        return getMediaContent(self.playlist.getActiveIndex() + 1);
    }

    // Get the previous media content object without decrementing the iterator.
    function peekPrevious() as Content? {
        System.println("peekPrevious");
        
        return getMediaContent(self.playlist.getActiveIndex() - 1);
    }

    // Get the previous media content object.
    function previous() as Content? {
        System.println("previous");
        
        var index = self.playlist.getActiveIndex() - 1;
        var content = getMediaContent(index);
        
        if (content != null) {
            self.playlist.setActiveIndex(index);
        }
        
        return content;
    }

    // Determine if playback is currently set to shuffle.
    function shuffling() as Boolean {
        System.println("shuffling");
        return false;
    }

}
