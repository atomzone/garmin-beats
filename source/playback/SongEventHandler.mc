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
        playbackTime as Number or PlaybackPosition
    ) as Void {
        var songEvents = ["Start", "Skip Next", "Skip Previous", "Playback Notify", "Complete", "Stop", "Pause", "Resume"];
        var eventTitle = songEvents[songEvent] != null ? songEvents[songEvent] : "Unknown";

        $.am.debug("SongEventHandler.notify(" + songEvent + ", '" + eventTitle + "', playback-time => " + playbackTime + ")");
    }
}
