using Toybox.Media as Media;
import Toybox.Lang;

// Owns where playback goes next
class PlaybackQueue extends Media.ContentIterator {

    private var _playerPlaylist as PlayerPlaylist;
    private var _mediaStore as IndexedStore;
    private var _shuffle as Boolean = false;

    function initialize(playerPlaylist as PlayerPlaylist) {
        Media.ContentIterator.initialize();

        _playerPlaylist = playerPlaylist;
        _mediaStore = new IndexedStore(IndexedStore.MEDIA);
    }

    function get() as Media.Content? {
        return getMediaContent(_playerPlaylist.getCurrentTrackIndex());
    }

    function next() as Media.Content? {
        var nextIndex = _playerPlaylist.getCurrentTrackIndex() + 1;
        var content = getMediaContent(nextIndex);

        if (content != null) {
            $.am.debug("[Queue.next] index " + _playerPlaylist.getCurrentTrackIndex() + " > " + nextIndex);
            _playerPlaylist.setTrackIndex(nextIndex);
            _playerPlaylist.setCurrentTrackPosition(0);
        }

        return content;
    }

    function previous() as Media.Content? {
        var previousIndex = _playerPlaylist.getCurrentTrackIndex() - 1;
        var content = getMediaContent(previousIndex);

        if (content != null) {
            $.am.debug("[Queue.previous] index " + _playerPlaylist.getCurrentTrackIndex() + " > " + previousIndex);
            _playerPlaylist.setTrackIndex(previousIndex);
            _playerPlaylist.setCurrentTrackPosition(0);
        }

        return content;
    }

    function peekNext() as Media.Content? {
        return getMediaContent(_playerPlaylist.getCurrentTrackIndex() + 1);
    }

    function peekPrevious() as Media.Content? {
        return getMediaContent(_playerPlaylist.getCurrentTrackIndex() - 1);
    }

    // Determine if the current track can be skipped forward.
    // Returning false on a physical device prevents both user-skip AND auto-advance after completion.
    function canSkip() as Boolean {
        var isValid = _playerPlaylist.isValidIndex(_playerPlaylist.getCurrentTrackIndex() + 1);
        $.am.debug("[Queue.canSkip] " + isValid + " (index=" + _playerPlaylist.getCurrentTrackIndex() + " size=" + _playerPlaylist.getAssetCount() + ")");

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
        profile.requirePlaybackNotification = false;
        profile.skipPreviousThreshold = 1;
        
        return profile;
    }

    // Determine if playback is currently set to shuffle.
    function shuffling() as Boolean {
        return self._shuffle;
    }

    private function getMediaContent(index as Number) as Media.Content? {
        if (!_playerPlaylist.isValidIndex(index)) {
            $.am.debug("[Queue.getMediaContent] null - index=" + index + "/" + (_playerPlaylist.getAssetCount() - 1));
            return null;
        }

        var asset = _playerPlaylist.getAssetByIndex(index);
        var refId = getRefId(asset);

        if (refId == null) {
            return null;
        }

        var metadata = mergeMetadata(
            MediaUtils.getContent(refId).getMetadata(),
            asset.getMetadata()
        );

        var position = _playerPlaylist.getCurrentTrackPosition();

        if (position > 0) {
            $.am.debug("[Queue.getMediaContent] index=" + index + "/" + (_playerPlaylist.getAssetCount() - 1) + " position=" + position);
            return MediaUtils.getActiveContentWithMetadata(refId, metadata, position);
        }

        $.am.debug("[Queue.getMediaContent] index=" + index + "/" + (_playerPlaylist.getAssetCount() - 1));
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

        var mediaAssetType = _mediaStore.load(asset.getMediaId()) as MediaRecordType?;

        if (mediaAssetType == null) {
            return null;
        }
        
        return mediaAssetType["refId"] as Object;
    }
}
