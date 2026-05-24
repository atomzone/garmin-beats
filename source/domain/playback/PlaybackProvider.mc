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
        _iterator = new PlaybackQueue(playlist);
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
        self._iterator = new PlaybackQueue(_playlist);

        return self._iterator;
    }

    function onAdAction(adContext as Object) as Void {
        $.am.debugWithArgs("[onAdAction]", adContext);
    }

    function onCustomButton(button as Media.CustomButton) as Void {
        $.am.debugWithArgs("[onCustomButton]", button);
    }

    // repeatMode() is always null... 
    // do we need to make our own verion of intertor.repeatMode()?
    function onRepeat() as Void {
        var repeatModes = {
            REPEAT_MODE_OFF => "Repeat is off",
            REPEAT_MODE_ONE => "Repeat the current track",
            REPEAT_MODE_ALL => "Repeat all tracks"
        };
        var mode = _iterator.repeatMode();
        var message = (mode == null) ? "(missing repeat mode)" : repeatModes[mode] as String;

        $.am.debug("[onRepeat] " +  message);
    }
    
    // Respond to a command to turn shuffle on or off
    // this /seems/ to force a queue.get
    function onShuffle() as Void {
        $.am.debug("[onShuffle]");
    }

    // Handles a notification from the system that an event has been triggered for the given song
    function onSong(
        contentRefId as Object, 
        songEvent as Media.SongEvent, 
        playbackPosition as Number or Media.PlaybackPosition
    ) as Void {
        $.am.debug("[PlaybackProvider.onSong] event=" + eventName(songEvent) + " playbackPosition=" + playbackPosition);

        // $.am.debug("[BUG] playlist index=" + _playlist.getCurrentTrackIndex());
        // $.am.debug("[BUG] playlist position=" + _playlist.getCurrentTrackPosition());

        // Active track changed
        if (
            songEvent == Media.SONG_EVENT_START || 
            songEvent == Media.SONG_EVENT_SKIP_NEXT ||  // this is handled by next/prev
            songEvent == Media.SONG_EVENT_SKIP_PREVIOUS // this is handled by next/prev
        ) {
            // can we know the change is not needed here
            // or do we test before save within the playlistOerfect
            _session.onTrackChanged();
        }

        // onPlaybackPosition
        if (
            songEvent == Media.SONG_EVENT_SKIP_FORWARD ||
            songEvent == Media.SONG_EVENT_SKIP_BACKWARD ||
            songEvent == Media.SONG_EVENT_PAUSE ||
            songEvent == Media.SONG_EVENT_STOP
        ) {
            _session.onResumeCheckpoint(playbackPosition);
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

        var asset = new AudioAssetOld(contentRefId as Number);
        asset.setThumbsUp(false);
    }

    // Respond to a thumbs-up action
    function onThumbsUp(contentRefId as Object) as Void {
        $.am.debugWithArgs("[onThumbsUp]", contentRefId);

        var asset = new AudioAssetOld(contentRefId as Number);
        asset.setThumbsUp(true);
    }
}
