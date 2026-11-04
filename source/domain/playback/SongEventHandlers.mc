using Toybox.Media as Media;
using Toybox.Graphics as Graphics;
import Toybox.Lang;

class LogSongEventHandler {

    // Logs playback events through the application logger
    public static function logSongEvent(
        contentRefId as Object,
        songEvent as Media.SongEvent,
        playbackPosition as Number or Media.PlaybackPosition
    ) as Void {
        $.am().logger().debug("[2 - PlaybackProvider.onSong]", { 
            "event" => eventName(songEvent),
            "playbackPosition" => playbackPosition
        });
    }

    private static function eventName(songEvent as Media.SongEvent) as String {
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
}
