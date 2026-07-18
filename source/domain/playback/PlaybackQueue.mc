using Toybox.Media as Media;
import Toybox.Lang;

// Owns where playback goes next
class PlaybackQueue extends Media.ContentIterator {

    private var _shuffle as Boolean = false;
    private var _playlist as PlayerPlaylist;
    private var _session as PlaybackSession;

    function initialize(
        playlist as PlayerPlaylist,
        session as PlaybackSession
    ) {
        _playlist = playlist;
        _session = session;
    }

    function get() as Media.Content? {
        return getMediaContent(_playlist.getCurrentTrackIndex());
    }

    function next() as Media.Content? {
        if (_session.nextInternal() != null) {
            return get();
        }
        
        return nextTrack();
    }

    function previous() as Media.Content? {
        if (_session.previousInternal() != null) {
            return get();
        }

        return previousTrack();
    }

    function peekNext() as Media.Content? {
        if (_session.nextInternal() != null) {
            return get();
        }

        return getMediaContent(_playlist.getCurrentTrackIndex() + 1);
    }

    function peekPrevious() as Media.Content? {
        if (_session.previousInternal() != null) {
            return get();
        }

        return getMediaContent(_playlist.getCurrentTrackIndex() - 1);
    }

    // Determine if the current track can be skipped forward.
    // Returning false on a physical device prevents both user-skip AND auto-advance after completion.
    function canSkip() as Boolean {
        var isValid = _playlist.isValidIndex(_playlist.getCurrentTrackIndex() + 1);
        $.am.debug("[Queue.canSkip] " + isValid + " (index=" + _playlist.getCurrentTrackIndex() + " size=" + _playlist.getAssetCount() + ")");

        return isValid;
    }

    // Get the current media content playback profile
    // this is function is needed
    function getPlaybackProfile() as Media.PlaybackProfile? {
        var profile = new PlaybackProfile();
        // profile.attemptSkipAfterThumbsDown = false;
        // profile.playbackControls = [
        //     // first linked to hotkey (if supported)
        //     Media.PLAYBACK_CONTROL_PLAYBACK,      // Allow Play/Pause control
        //     // Media.PLAYBACK_CONTROL_SHUFFLE,       // Allow Shuffle control
        //     Media.PLAYBACK_CONTROL_PREVIOUS,      // Allow Previous control
        //     Media.PLAYBACK_CONTROL_NEXT,          // Allow Next control
        //     // Media.PLAYBACK_CONTROL_SKIP_FORWARD,  // Allow Skip-Forward control
        //     // Media.PLAYBACK_CONTROL_SKIP_BACKWARD, // Allow Skip-Backward control
        //     // Media.PLAYBACK_CONTROL_REPEAT,        // Allow Repeat control
        //     // Media.PLAYBACK_CONTROL_RATING         // Allow Ratings control
        //     // PLAYBACK_CONTROL_VOLUME, CustomButton, and SystemButton??
        //     // PLAYBACK_CONTROL_SOURCE, ||
        //     // PLAYBACK_CONTROL_LIBRARY ||
        // ];

        profile.playbackControls = [
            PLAYBACK_CONTROL_SKIP_FORWARD,
            PLAYBACK_CONTROL_SKIP_BACKWARD,
            PLAYBACK_CONTROL_PREVIOUS,
            PLAYBACK_CONTROL_NEXT,
            PLAYBACK_CONTROL_VOLUME,
            PLAYBACK_CONTROL_REPEAT
        ];
        if (profile has :playbackCapabilities) {
            profile.playbackCapabilities = 1;
        }
        // The number of seconds a song must play to trigger a "played" notification.
        profile.playbackNotificationThreshold = 10;
        profile.requirePlaybackNotification = true;
        profile.skipPreviousThreshold = 1;
        profile.skipBackwardTimeDelta = 23;
        profile.skipForwardTimeDelta = 23;
        
        return profile;
    }

    // Determine if playback is currently set to shuffle.
    function shuffling() as Boolean {
        return self._shuffle;
    }

    private function nextTrack() as Media.Content? {
        var nextIndex = _playlist.getCurrentTrackIndex() + 1;

        if (!_playlist.isValidIndex(nextIndex)) {
            return null;
        }

        _playlist.setTrackIndex(nextIndex);
        _playlist.setCurrentTrackPosition(0);
        _session.onTrackChanged();

        return get();
    }

    private function previousTrack() as Media.Content? {
        var previousIndex = _playlist.getCurrentTrackIndex() - 1;

        if (!_playlist.isValidIndex(previousIndex)) {
            return null;
        }

        _playlist.setTrackIndex(previousIndex);
        _playlist.setCurrentTrackPosition(0);
        _session.onTrackChanged();

        return get();
    }

    private function getMediaContent(index as Number) as Media.Content? {
        if (!_playlist.isValidIndex(index)) {
            $.am.debug("[Queue.getMediaContent] null - index=" + index + "/" + (_playlist.getAssetCount() - 1));
            return null;
        }

        var asset = _playlist.getAssetByIndex(index);
        var refId = getRefId(asset);

        if (refId == null) {
            return null;
        }

        var metadata = mergeMetadata(
            MediaUtils.getContent(refId).getMetadata(),
            asset.getMetadata()
        );

        var position = _playlist.getCurrentTrackPosition();

        if (position > 0) {
            $.am.debug("[Queue.getMediaContent] index=" + index + "/" + (_playlist.getAssetCount() - 1) + " position=" + position);
            return MediaUtils.getActiveContentWithMetadata(refId, metadata, position);
        }

        $.am.debug("[Queue.getMediaContent] index=" + index + "/" + (_playlist.getAssetCount() - 1));
        return MediaUtils.getContentWithMetadata(refId, metadata);
    }

    private function mergeMetadata(
        source as Media.ContentMetadata, 
        audio as AudioMetadata
    ) as Media.ContentMetadata {

        source.title = StringUtils.stringOrDefault(audio.getTitle(), "[Title Not Found]");
        source.artist = StringUtils.stringOrDefault(audio.getArtist(), "[Artist Not Found]");
        source.album = StringUtils.stringOrDefault(audio.getAlbum(), "[Album Not Found]");

        return source;
    }

    // think avbout cached
    // think avout changing to a stragih lookup
    // get(asset.mediaId) -> refId -> getContent(refId)
    private function getRefId(asset as AudioAsset) as Object? {
        $.am.debug("[PlaybackQueue.getRefId] sourceChecksum='" + asset.getMediaId() + "'");

        var mediaAssetType = AppStores.media.load(asset.getMediaId()) as MediaRecordType?;

        if (mediaAssetType == null) {
            return null;
        }
        
        return mediaAssetType["refId"] as Object;
    }
}
