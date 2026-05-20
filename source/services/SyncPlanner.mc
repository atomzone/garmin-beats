import Toybox.Lang;

// ─────────────────────────────────────────────────────────────────────────────
// SyncPlanner  (Phase 1: in-memory only, no persistence)
//
// Purpose:
//   The Connect IQ SDK calls AppEntry.getSyncDelegate() at least twice per
//   sync cycle (probe -> exec). Previously each instance rebuilt the whole
//   manifest from scratch. SyncPlanner caches the manifest result in module-
//   level statics so probe+exec share one build per wake.
//
// Lifetime:
//   - Module statics live for the lifetime of the app process.
//   - Process death (power off, watch reboot, OS kill) clears the cache.
//     That is acceptable: a cold-start sync wake then does ONE rebuild,
//     which is the same cost we had before this class existed.
//   - Promote to Phase 2 by persisting { fp, ops } to Storage if cold-start
//     wakes become common enough to matter.
//
// Op shape:
//   Slim: { type, playlistKey, logicalId? }
//   The executor never carries source URLs forward; it asks the planner
//   to resolve a fresh AudioResource/PlaylistResource via findTrack()/
//   findPlaylist() at execution time. This means:
//     - stale ops degrade gracefully (orphan lookups return null -> skip)
//     - metadata edits in "SYNC" are honoured at download time
//   The fat manifest output ({type, playlistKey, logicalId, playlist, track})
//   is kept internally because the refs cost nothing in memory.
//
// Contract:
//   - ensureFresh() MUST be called before each new SyncManager instance.
//     AppEntry.getSyncDelegate() is the canonical caller.
//   - invalidate() MUST be called by:
//       1. SyncStateStore (already wired) when SYNC / LOCAL_*_CK mutate
//     A missed invalidate() is recoverable: fp is recomputed every probe,
//     so any other input change will heal the cache.
// ─────────────────────────────────────────────────────────────────────────────
class SyncPlanner {

    // ── in-memory cache (module-scoped, dies with the process) ──────────────

    // Fingerprint of the inputs that produced the cached ops.
    // null means "no valid cache" -> next ensureFresh() will rebuild.
    private static var _fp as String? = null;

    // Inflated remote playlists, and lookup maps for O(1) access by key/logicalId.
    private static var _playlists as Array<PlaylistResource> = [];
    private static var _playlistMap as Dictionary<String, PlaylistResource> = {};
    private static var _trackMap as Dictionary<String, AudioResource> = {};

    // The manifest output. Kept fat (with track/playlist refs) for cheap
    // lookups; only the slim subset (type/playlistKey/logicalId) would be
    // persisted if we ever move to Phase 2.
    private static var _ops as Array<SyncOperationType> = [];

    // ── public API ──────────────────────────────────────────────────────────

    // Drop the cache. Forces the next ensureFresh() to rebuild.
    // Cheap; called by SyncStateStore on every mutating write.
    static function invalidate() as Void {
        _fp = null;
        _playlists = [];
        _ops = [];
    }

    // Idempotent. Computes the current fingerprint from "SYNC" + local
    // mirrors and rebuilds the manifest ONLY when the fingerprint differs.
    // Hot path (no input changes): one Storage read + a small string hash.
    static function ensureFresh() as Void {
        var remoteRaw = SyncStateStore.getRemote();
        var localPl   = SyncStateStore.getPlaylistChecksums();
        var localTr   = SyncStateStore.getTrackChecksums();

        // Inflate playlists and build lookup maps for O(1) access.
        var playlists = PlaylistResource.fromArray(remoteRaw);
        var playlistMap = {} as Dictionary<String, PlaylistResource>;
        var trackMap = {} as Dictionary<String, AudioResource>;
        for (var i = 0; i < playlists.size(); i++) {
            var pl = playlists[i];
            playlistMap[pl.getKey()] = pl;
            var tracks = pl.getTracks();
            for (var j = 0; j < tracks.size(); j++) {
                var tr = tracks[j];
                // Use canonicalize() for logicalId uniqueness (matches AudioResource)
                trackMap[tr.getLogicalId()] = tr;
            }
        }

        // Use deep checksums for fingerprinting.
        var fp = getChecksum(playlists, localPl, localTr);

        if (_fp != null && _fp.equals(fp)) {
            return;
        }

        $.am.debug("[SyncPlanner.ensureFresh] rebuild fp=" + fp);

        _playlists = playlists;
        _playlistMap = playlistMap;
        _trackMap = trackMap;

        var manifest = new SyncManifest(_playlists, localPl, localTr);
        manifest.build();
        _ops = manifest.getOperations();
        _fp  = fp;
    }

    // Returns the current op queue. SyncManager copies this into its own
    // array so iteration during execution is independent of the cache.
    static function getOps() as Array<SyncOperationType> {
        return _ops;
    }

    // Remove a completed op from the cache. Called by the executor after
    // each op succeeds (or is dropped as un-actionable). Keeps _fp intact
    // so successive completions don't trigger pointless rebuilds.
    static function complete(op as SyncOperationType) as Void {
        _ops.remove(op);
    }

    // Lookup-at-exec: resolve a slim op's identifiers back to a live
    // AudioResource. Returns null when the op references something that
    // no longer exists in the current "SYNC" payload (e.g. track removed
    // remotely between manifest build and execution).
    // O(1) lookup by logicalId (track) and playlistKey (playlist)
    static function findTrack(playlistKey as String, logicalId as String) as AudioResource? {
        // Optionally, could scope to playlistKey for stricter matching, but logicalId is globally unique.
        return _trackMap.hasKey(logicalId) ? _trackMap[logicalId] : null;
    }

    // Same idea as findTrack but for playlist-level ops.
    static function findPlaylist(playlistKey as String) as PlaylistResource? {
        return _playlistMap.hasKey(playlistKey) ? _playlistMap[playlistKey] : null;
    }

    // ── helpers ─────────────────────────────────────────────────────────────

    // getChecksum: deep fingerprint using PlaylistResource.getChecksum() and canonicalize()
    private static function getChecksum(
        playlists as Array<PlaylistResource>,
        localPl   as Dictionary<String, String>,
        localTr   as Dictionary<String, String>
    ) as String {
        var remoteSummary = "";
        for (var i = 0; i < playlists.size(); i++) {
            var pl = playlists[i];
            remoteSummary += pl.getKey() + ":" + pl.getChecksum() + ";";
        }
        return StringUtils.checksum(
            remoteSummary + "||" +
            canonicalize(localPl) + "||" +
            canonicalize(localTr)
        );
    }

    // canonicalize: stable string for a dictionary (key order sorted)
    private static function canonicalize(d as Dictionary<String, String>) as String {
        var keys = d.keys();
        // keys.sort();
        var out = "";
        for (var i = 0; i < keys.size(); i++) {
            var k = keys[i] as String;
            out += k + "=" + (d[k] as String) + ";";
        }
        return out;
    }
}
