using Toybox.Application.Storage as Storage;
import Toybox.Lang;

typedef PlaybackStateType as {
    "playlistId" as String,
    "trackIndex" as Number,
    "trackPosition" as Number
};

class PlaybackStateStore {

    private static const KEY as String = "PLAYBACK";

    static function load() as PlaybackStateType? {
        return StorageManager.load(KEY) as PlaybackStateType?;
    }

    static function save(state as PlaybackStateType) as Void {
        StorageManager.save(KEY, state as Storage.ValueType);
    }

    static function clear() as Void {
        StorageManager.remove(KEY);
    }
}