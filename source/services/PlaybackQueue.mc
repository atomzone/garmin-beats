using Toybox.Media as Media;
import Toybox.Lang;

class PlaybackQueue extends Media.ContentIterator {

    private var _tracks as Array<AudioAsset>;
    private var _playIndex as Number;
    private var _initialPlayIndex as Number;
    private var _resumePositionSeconds as Number;
    private var _shuffle as Boolean;

    function initialize() {
        // LOAD FROM STORAGE ON INIT
        // No parameters. All data comes from persistent storage via PlaylistStore.
        // This ensures fresh data on each playback session and prevents state leakage.
        Media.ContentIterator.initialize();

        self._tracks = [];
        self._playIndex = 0;
        self._initialPlayIndex = 0;
        self._resumePositionSeconds = 0;
        self._shuffle = false;

        // Load playlist from persistent storage
        loadPlaylistFromStorage();
    }

    private function loadPlaylistFromStorage() as Void {
        // FETCH FRESH STATE FROM PERSISTENT STORAGE
        // This is called once per iterator instance.
        // Ensures we have current playlist and playback position.
        var store = new PlaylistStore("active");
        var playlist = store.getPlaylist();

        self._tracks = playlist.getAssets();
        self._playIndex = playlist.getCurrentTrackIndex();
        self._initialPlayIndex = self._playIndex;
        self._resumePositionSeconds = playlist.getResumePositionSeconds();

        $.am.debug("[Queue.init] loaded from storage: assets=" + self._tracks.size() + " index=" + self._playIndex + " resume=" + self._resumePositionSeconds);
    }

    function setPlayIndex(index as Number) as Void {
        if (index < 0 || index > self._tracks.size() - 1) {
            $.am.debug("[Queue.setPlayIndex] invalid index=" + index + " size=" + self._tracks.size());
            return;
        }

        self._playIndex = index;
        $.am.debug("[Queue.setPlayIndex] index set to " + self._playIndex);
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
            $.am.debug("[Queue.next] null - boundary reached (index=" + self._playIndex + " size=" + self._tracks.size() + ")");
            return null;  // Don't advance index; keep iterator valid at boundary
        }

        self._playIndex = nextIndex;
        $.am.debug("[Queue.next] advancing to index=" + self._playIndex);
        return content;
    }

    function previous() as Media.Content? {
        var previousIndex = self._playIndex - 1;
        var content = getAt(previousIndex, false);

        if (content == null) {
            $.am.debug("[Queue.previous] null - boundary reached (index=" + self._playIndex + " size=" + self._tracks.size() + ")");
            return null;  // Don't advance index; keep iterator valid at boundary
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
    // Defines available controls and notification thresholds
    function getPlaybackProfile() as Media.PlaybackProfile? {
        var profile = new PlaybackProfile();
        profile.attemptSkipAfterThumbsDown = false;
        profile.playbackControls = [
            Media.PLAYBACK_CONTROL_PLAYBACK,      // Allow Play/Pause control
            Media.PLAYBACK_CONTROL_PREVIOUS,      // Allow Previous control
            Media.PLAYBACK_CONTROL_NEXT,          // Allow Next control
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

        // Resume playback from saved position on first track of session
        if (useResumePosition && index == self._initialPlayIndex && self._resumePositionSeconds > 0) {
            $.am.debug("[Queue.get] resuming at " + self._resumePositionSeconds + "s");
            return file.getActiveContent(self._resumePositionSeconds);
        }

        return file.getContent();
    }

}
