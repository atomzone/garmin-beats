using Toybox.Application.Storage as Storage;
import Toybox.Lang;

// ─────────────────────────────────────────────────────────────────────────────
// SyncStateStore
//
// Single owner of every persisted input that the SyncManifest depends on:
//
// Why this class exists:
//   - These three keys are the only inputs to SyncPlanner. If anything
//     mutates them without invalidating the planner, the in-memory
//     manifest cache can drift from reality.
//   - Therefore every setter here ALSO calls SyncPlanner.invalidate().
//   - Rule: do NOT call StorageManager.{get,set,delete}("SYNC"|"LOCAL_PL_CK"|
//     "LOCAL_TR_CK") anywhere else. A grep for those strings should only
//     ever find this file.
//
// Example persisted shapes:
//
//   SYNC:
//     [ { "title" => "Test Playlist", "desc" => null,
//         "tracks" => [
//             { "source" => { "url" => "https://.../song1.mp3" },
//               "meta"   => { "title" => "Song 1", ... } }
//         ] },
//       { "title" => "thetechmonkey", "desc" => null, "tracks" => [ ... ] } ]
//
//   LOCAL_PL_CK:
//     { "Default Playlist" => "FFCDF976",
//       "thetechmonkey"    => "0C217DEA" }
//
//   LOCAL_TR_CK:
//     { "47CD4FF2" => "74D98B8F",
//       "A1B2C3D4" => "32A03605" }
// ─────────────────────────────────────────────────────────────────────────────
class SyncStateStore {

    private static const REMOTE_KEY as String = "SYNC";
    private static const PL_KEY as String = "LOCAL_PL_CK";
    private static const TR_KEY as String = "LOCAL_TR_CK";

    static function getRemote() as Array<PlaylistResourceType> {
        return StorageManager.getOrDefault(REMOTE_KEY, []) as Array<PlaylistResourceType>;
    }

    static function getPlaylistChecksums() as Dictionary<String, String> {
        return StorageManager.getOrDefault(PL_KEY, {}) as Dictionary<String, String>;
    }

    static function getTrackChecksums() as Dictionary<String, String> {
        return StorageManager.getOrDefault(TR_KEY, {}) as Dictionary<String, String>;
    }

    static function setRemote(playlists as Array<PlaylistResourceType>) as Void {
        setAndInvalidate(REMOTE_KEY, playlists as Storage.ValueType);
    }

    static function setPlaylist(key as String, checksum as String) as Void {
        var map = getPlaylistChecksums();
        map[key] = checksum;
        setAndInvalidate(PL_KEY, map as Storage.ValueType);
    }

    static function setTrack(key as String, checksum as String) as Void {
        var map = getTrackChecksums();
        map[key] = checksum;
        setAndInvalidate(TR_KEY, map as Storage.ValueType);
    }

    static function deleteRemote() as Void {
        StorageManager.delete(REMOTE_KEY);
        SyncPlanner.invalidate();
    }

    static function deletePlaylist(key as String) as Void {
        var map = getPlaylistChecksums();
        map.remove(key);
        setAndInvalidate(PL_KEY, map as Storage.ValueType);
    }

    static function deleteTrack(key as String) as Void {
        var map = getTrackChecksums();
        map.remove(key);
        setAndInvalidate(TR_KEY, map as Storage.ValueType);
    }

    static private function setAndInvalidate(key as String, value as Storage.ValueType) as Void {
        StorageManager.set(key, value);
        SyncPlanner.invalidate();
    }
}
