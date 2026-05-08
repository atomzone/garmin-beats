using Toybox.Media as Media;
import Toybox.Lang;

class PlaybackQueue extends Media.ContentIterator {

    private var _tracks as Array<AudioAsset>;
    private var _playIndex as Number;
    private var _initialPlayIndex as Number;
    private var _resumePositionSeconds as Number;
    private var _shuffle as Boolean;

    function initialize(tracks as Array<AudioAsset>, playIndex as Number, resumePositionSeconds as Number) {
        Media.ContentIterator.initialize();

        self._tracks = tracks;
        self._playIndex = playIndex;
        self._initialPlayIndex = self._playIndex;
        self._resumePositionSeconds = resumePositionSeconds;
        self._shuffle = false;
    }

    function getPlayIndex() as Number {
        return self._playIndex;
    }

    function get() as Media.Content? {
        return getAt(self._playIndex, true);
    }

    function next() as Media.Content? {
        var nextIndex = self._playIndex + 1;
        var content = getAt(nextIndex, false);

        if (content == null) {
            $.am.debug("[Queue.next] null - index=" + nextIndex + " size=" + self._tracks.size());
            return null;
        }

        self._playIndex = nextIndex;
        $.am.debug("[Queue.next] advancing to index=" + self._playIndex);
        return content;
    }

    function previous() as Media.Content? {
        var previousIndex = self._playIndex - 1;
        var content = getAt(previousIndex, false);

        if (content == null) {
            $.am.debug("[Queue.previous] null - index=" + previousIndex + " size=" + self._tracks.size());
            return null;
        }

        self._playIndex = previousIndex;
        $.am.debug("[Queue.previous] back to index=" + self._playIndex);
        return content;
    }

    function peekNext() as Media.Content? {
        return getAt(self._playIndex + 1, false);
    }

    function peekPrevious() as Media.Content? {
        return getAt(self._playIndex - 1, false);
    }

    // Determine if the current track can be skipped forward.
    // Returning false on a physical device prevents both user-skip AND auto-advance after completion.
    function canSkip() as Boolean {
        var canAdvance = self._playIndex < self._tracks.size() - 1;
        $.am.debug("[Queue.canSkip] " + canAdvance + " (index=" + self._playIndex + " size=" + self._tracks.size() + ")");
        return canAdvance;
    }

    // Get the current media content playback profile
    // this is function is needed
    function getPlaybackProfile() as Media.PlaybackProfile? {
        var profile = new PlaybackProfile();
        profile.attemptSkipAfterThumbsDown = false;
        profile.playbackControls = [
            // first linked to hotkey (if supported)
            Media.PLAYBACK_CONTROL_PLAYBACK,      // Allow Play/Pause control
            // Media.PLAYBACK_CONTROL_SHUFFLE,       // Allow Shuffle control
            Media.PLAYBACK_CONTROL_PREVIOUS,      // Allow Previous control
            Media.PLAYBACK_CONTROL_NEXT,          // Allow Next control
            // Media.PLAYBACK_CONTROL_SKIP_FORWARD,  // Allow Skip-Forward control
            // Media.PLAYBACK_CONTROL_SKIP_BACKWARD, // Allow Skip-Backward control
            // Media.PLAYBACK_CONTROL_REPEAT,        // Allow Repeat control
            // Media.PLAYBACK_CONTROL_RATING         // Allow Ratings control
            // PLAYBACK_CONTROL_VOLUME, CustomButton, and SystemButton??
            // PLAYBACK_CONTROL_SOURCE, ||
            // PLAYBACK_CONTROL_LIBRARY ||
        ];
        profile.playbackNotificationThreshold = 1;
        profile.requirePlaybackNotification = false;
        profile.skipPreviousThreshold = null;
        
        return profile;
    }

    // Determine if playback is currently set to shuffle.
    function shuffling() as Boolean {
        return self._shuffle;
    }

    private function getAt(index as Number, useResumePosition as Boolean) as Media.Content? {
        var size = self._tracks.size();
        if (size == 0 || index < 0 || index > size - 1) {
            $.am.debug("[Queue.get] null - index=" + index + " size=" + size);
            return null;
        }

        var file = self._tracks[index];
        $.am.debug("[Queue.get] index=" + index + "/" + (size - 1) + " refId=" + file.getRefId());

        if (useResumePosition && index == self._initialPlayIndex && self._resumePositionSeconds > 0) {
            $.am.debug("[Queue.get] resuming at " + self._resumePositionSeconds + "s");
            return file.getActiveContent(self._resumePositionSeconds);
        }

        return file.getContent();
    }

}
