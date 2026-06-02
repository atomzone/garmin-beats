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

    static function resolvePlaylistState(
        requestedPlaylistId as String?,
        playlistId as String,
        storedState as PlaybackStateType?
    ) as PlaybackCursorType {
        var playlistState = {
            "trackIndex" => 0,
            "trackPosition" => 0
        } as PlaybackCursorType;

        if (requestedPlaylistId != null || storedState == null) {
            return playlistState;
        }

        if (!(storedState["playlistId"] as String).equals(playlistId)) {
            return playlistState;
        }

        return {
            "trackIndex" => storedState["trackIndex"],
            "trackPosition" => storedState["trackPosition"]
        } as PlaybackCursorType;
    }
}