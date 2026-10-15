using Toybox.Time;
using Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.System;

class ApplicationManager {
    private var _version as String;
    private var _logger as Logger;
    private var _logStore as LimitedStore;

    public function initialize() {
        _version = getTimestamp();
        _logStore = new LimitedStore("APP_LOGS", 50);
        _logger = new Logger([
            new ConsoleLogWriter(),
            new StorageLogWriter(_logStore)
        ]);

        _logger.debug("ApplicationManager initialized", { "version" => _version });

        // Storage review
        var cacheStats = Media.getCacheStatistics();
        _logger.debug("Stores media cache size in bytes", {
            "capacity" => cacheStats.capacity,
            "size" => cacheStats.size
        });

        var sysStats = System.getSystemStats();
        _logger.debug("Device memory statistics in bytes", {
            "freeMemory" => sysStats.freeMemory, // bytes
            "totalMemory" => sysStats.totalMemory,
            "usedMemory" => sysStats.usedMemory
        });
    }

    public function logger() as Logger {
        return _logger;
    }

    public function getLogs() as Array<StructuredLogType> {
        _logger.debug("Reading logs from Store", null);
        return _logStore.read() as Array<StructuredLogType>;
    }

    public function clearLogs() as Void {        
        _logStore.clear();
        _logger.debug("Clearing logs from Store", null);
    }

    public function clearAll() as Void {

        // CLEAR LOGS
        _logStore.clear();

        // REMOVE PLAYLISTS
        AppStores.playlists.clear();

        // REMOVE TRACKS
        AppStores.tracks.clear();

        // REMOVE MEDIA RECORDS
        AppStores.media.clear();

        // REMOVE IMAGES RAW
        AppStores.images.clear();

        // REMOVE PLAYBACK STATE
        PlaybackStateStore.clear();

        // REMOVE CACHCED CONTENT
        // Media.resetContentCache(); ????
        
        var cachedMedia = MediaUtils.getCachedMediaRefIds(Media.CONTENT_TYPE_AUDIO);
        for (var index = 0, limit = cachedMedia.size(); index < limit; index++) {
            MediaUtils.delete(cachedMedia[index]);
        }
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
