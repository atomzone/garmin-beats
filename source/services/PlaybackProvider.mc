using Toybox.Media as Media;
import Toybox.Lang;

class PlaybackProvider extends Media.ContentDelegate {

    private var _playlist as Playlist;
    private var _session as PlaybackSession;
    private var _iterator as Media.ContentIterator;

    function initialize(playlist as Playlist, session as PlaybackSession) {
        Media.ContentDelegate.initialize();

        _playlist = playlist;
        _session = session;

        _iterator = new PlaybackQueue(
            playlist.getAssets(),
            playlist.getCurrentTrackIndex(),
            playlist.getResumePositionSeconds()
        );
    }

    function getContentIterator() as Media.ContentIterator? {
        $.am.debug("[PlaybackProvider.getContentIterator]");
        
        return self._iterator;
    }

    // Called by the system when the queue needs to restart (e.g. repeat-all, re-entry).
    // Reset the ContentIterator to the beginning of the current playlist
    function resetContentIterator() as Media.ContentIterator? {
        $.am.debug("[PlaybackProvider.resetContentIterator]");

        // reset iterator to the beginning of the playlist
        self._iterator = new PlaybackQueue(
            _playlist.getAssets(), 0, 0
        );

        return self._iterator;
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

    // Handles a notification from the system that an event has been triggered for the given song
    function onSong(
        contentRefId as Object, 
        songEvent as Media.SongEvent, 
        playbackPosition as Number or Media.PlaybackPosition
    ) as Void {
        $.am.debug("[PlaybackProvider.onSong] event=" + eventName(songEvent) + " contentRefId=" + contentRefId + " playbackPosition=" + playbackPosition);

        // onTrackStarted
        if (songEvent == Media.SONG_EVENT_START || songEvent == Media.SONG_EVENT_SKIP_NEXT || songEvent == Media.SONG_EVENT_SKIP_PREVIOUS) {
            _session.onTrackStarted(contentRefId);
        }

        // onPlaybackPosition
        if (
            songEvent == Media.SONG_EVENT_START ||
            songEvent == Media.SONG_EVENT_SKIP_FORWARD ||
            songEvent == Media.SONG_EVENT_SKIP_BACKWARD ||
            songEvent == Media.SONG_EVENT_PAUSE ||
            songEvent == Media.SONG_EVENT_STOP
        ) {
            _session.onPlaybackPosition(contentRefId, playbackPosition);
        }
    }

    private function eventName(songEvent as Media.SongEvent) as String {
        var eventNames = {
            Media.SONG_EVENT_START => "Start",
            Media.SONG_EVENT_SKIP_NEXT => "Skip Next",
            Media.SONG_EVENT_SKIP_PREVIOUS => "Skip Previous",
            Media.SONG_EVENT_PLAYBACK_NOTIFY => "Playback Notify",
            Media.SONG_EVENT_COMPLETE => "Complete",
            Media.SONG_EVENT_STOP => "Stop",
            Media.SONG_EVENT_PAUSE => "Pause",
            Media.SONG_EVENT_RESUME => "Resume",
            Media.SONG_EVENT_SKIP_FORWARD => "Skip Forward",
            Media.SONG_EVENT_SKIP_BACKWARD => "Skip Backward"
        } as Dictionary;
        var value = eventNames[songEvent];
        if (value instanceof String) {
            return value as String;
        }

        return "Unknown(" + songEvent + ")";
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
