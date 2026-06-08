using Toybox.Time;
using Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.System;

class ApplicationManager {
    private var _version as String;

    public function initialize() {
        self._version = getTimestamp();
        debug("Initializing ApplicationManager (Build | " + self._version + ")");
    }

    public function debug(message as String) as Void {
        // var timestamp = getTimestamp();
        // System.println("[" + timestamp + "] " + message);
        System.println(message);
    }

    public function debugWithArgs(message as String, args as Object) as Void {
        self.debug(message + "(" + self.parseArgs(args) + ")");
    }

    public function clearAll() as Void {

        // REMOVE PLAYLISTS
        AppStores.playlists.clear();

        // REMOVE TRACKS
        AppStores.tracks.clear();

        // REMOVE MEDIA RECORDS
        AppStores.media.clear();

        // REMOVE PLAYBACK STATE
        PlaybackStateStore.clear();

        // REMOVE CACHCED CONTENT
        var cachedMedia = MediaUtils.getCachedMediaRefIds(Media.CONTENT_TYPE_AUDIO);
        for (var index = 0, limit = cachedMedia.size(); index < limit; index++) {
            MediaUtils.delete(cachedMedia[index]);
        }
    }

    private function parseArgs(args as Object?) as String {
        return (args == null) ? "null" : args.toString();
    }

    private function getTimestamp() as String {
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        
        return Lang.format(
            "$1$:$2$:$3$ $4$ $5$ $6$ $7$",
            [
                today.hour,
                today.min,
                today.sec,
                today.day_of_week,
                today.day,
                today.month,
                today.year
            ]
        );
    }
}
