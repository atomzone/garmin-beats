import Toybox.Lang;
import Toybox.Media;

// !! THIS SHOULD BE RENAMED TrackEventHandler!!
class SongEventHandler {
    // private var playlist as Playlist;

    function initialize(playlist as Playlist) {
        // self.playlist = playlist;
    }

    function notify(
        contentRefId as Object, 
        songEvent as SongEvent, 
        playbackPosition as Number or PlaybackPosition
    ) as Void {
        var SongEvents = ["Start", "Skip Next", "Skip Previous", "Playback Notify", "Complete", "Stop", "Pause", "Resume"];

        // $.am.debug(contentRefId);
        $.am.debug("SONG EVENT: (" + songEvent + ") " + SongEvents[songEvent] + " Track: " + playbackPosition);
    }
}
