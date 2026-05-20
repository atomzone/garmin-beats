import Toybox.Lang;
import Toybox.Application.Storage;

// ─────────────────────────────────────────────────────────────────────────────
// SyncStateStore
//
// Single owner of every persisted input that the SyncManifest depends on:
//
//   SYNC        : Array<PlaylistResourceType>   // remote playlist payload
//   LOCAL_PL_CK : Dictionary<String, String>    // playlist key  -> checksum
//   LOCAL_TR_CK : Dictionary<String, String>    // track logicalId -> checksum
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

    // Storage keys. Kept private so callers can't bypass invalidation.
    private static const REMOTE_KEY as String = "SYNC";
    private static const PL_KEY     as String = "LOCAL_PL_CK";
    private static const TR_KEY     as String = "LOCAL_TR_CK";

    // ── remote (server-pushed playlists) ────────────────────────────────────

    // Returns the remote playlist payload, or [] when nothing has been pushed.
    static function getRemote() as Array<PlaylistResourceType> {
        return StorageManager.getOrDefault(REMOTE_KEY, []) as Array<PlaylistResourceType>;
    }

    // Replaces the remote payload. Use this from any UI / fetch path that
    // currently calls StorageManager.set("SYNC", ...). Invalidation is wired
    // here so callers cannot forget it.
    static function setRemote(playlists as Array<PlaylistResourceType>) as Void {
        StorageManager.set(REMOTE_KEY, playlists as Storage.ValueType);
        SyncPlanner.invalidate();
    }

    static function clearRemote() as Void {
        StorageManager.delete(REMOTE_KEY);
        SyncPlanner.invalidate();
    }

    // ── local mirrors (what we've actually stored on the device) ────────────

    static function getPlaylistChecksums() as Dictionary<String, String> {
        return StorageManager.getOrDefault(PL_KEY, {}) as Dictionary<String, String>;
    }

    static function getTrackChecksums() as Dictionary<String, String> {
        return StorageManager.getOrDefault(TR_KEY, {}) as Dictionary<String, String>;
    }

    static function setPlaylist(key as String, checksum as String) as Void {
        var d = getPlaylistChecksums();
        d[key] = checksum;
        StorageManager.set(PL_KEY, d as Storage.ValueType);
        SyncPlanner.invalidate();
    }

    static function removePlaylist(key as String) as Void {
        var d = getPlaylistChecksums();
        d.remove(key);
        StorageManager.set(PL_KEY, d as Storage.ValueType);
        SyncPlanner.invalidate();
    }

    static function setTrack(logicalId as String, checksum as String) as Void {
        var d = getTrackChecksums();
        d[logicalId] = checksum;
        StorageManager.set(TR_KEY, d as Storage.ValueType);
        SyncPlanner.invalidate();
    }

    static function removeTrack(logicalId as String) as Void {
        var d = getTrackChecksums();
        d.remove(logicalId);
        StorageManager.set(TR_KEY, d as Storage.ValueType);
        SyncPlanner.invalidate();
    }

    // Nuclear option used by "clear local cache" UI paths. Wipes both
    // local mirrors so the next sync will re-queue every remote track.
    // The remote payload itself is left intact.
    static function clearLocal() as Void {
        StorageManager.delete(PL_KEY);
        StorageManager.delete(TR_KEY);
        SyncPlanner.invalidate();
    }
}
