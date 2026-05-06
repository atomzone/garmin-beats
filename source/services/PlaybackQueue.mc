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
        if (self._playIndex > self._tracks.size() - 1) {
            return null;
        }

        var file = self._tracks[self._playIndex];

        if (self._playIndex == self._initialPlayIndex && self._resumePositionSeconds > 0) {
            return file.getActiveContent(self._resumePositionSeconds);
        }

        return file.getContent();
    }

    function next() as Media.Content? {
        self._playIndex += 1;
        return get();
    }

    function previous() as Media.Content? {
        if (self._playIndex > 0) {
            self._playIndex -= 1;
        }
        return get();
    }

    // Determine if the current track can be skipped.
    function canSkip() as Boolean {
        $.am.debug("canSkip");
        return false;
    }

    // Get the current media content playback profile
    // this is function is needed
    function getPlaybackProfile() as Media.PlaybackProfile? {
        var profile = new PlaybackProfile();
        profile.attemptSkipAfterThumbsDown = false;
        profile.playbackControls = [
            PLAYBACK_CONTROL_SKIP_BACKWARD,
            PLAYBACK_CONTROL_NEXT,
            PLAYBACK_CONTROL_PLAYBACK,
            PLAYBACK_CONTROL_PREVIOUS,
            PLAYBACK_CONTROL_SKIP_FORWARD,
            PLAYBACK_CONTROL_RATING,
            PLAYBACK_CONTROL_VOLUME,
            PLAYBACK_CONTROL_SOURCE,
            PLAYBACK_CONTROL_LIBRARY
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

}
