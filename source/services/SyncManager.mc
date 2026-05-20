using Toybox.Media as Media;
using Toybox.Communications as Comm;
import Toybox.Lang;

// ─────────────────────────────────────────────────────────────────────────────
// SyncManager  (Phase 1 + Slim executor)
//
// The SDK constructs this class at least twice per sync cycle (probe + exec).
// All planning work now lives in SyncPlanner. This class is a thin executor:
//
//   initialize()    ← copy current op list out of the planner (O(1))
//   isSyncNeeded()  ← length check
//   onStartSync()   ← drain ops one at a time, resolving resources lazily
//
// Lookup-at-exec means we never carry source URLs/metadata in the op itself;
// we re-resolve the live AudioResource via SyncPlanner.findTrack() right
// before issuing the HTTP request. Orphan refs return null and are skipped,
// so stale ops degrade gracefully.
// ─────────────────────────────────────────────────────────────────────────────
class SyncManager extends Comm.SyncDelegate {

    // Snapshot of the planner's op list at construction time. Holding our own
    // copy means the planner can be invalidated mid-sync without yanking the
    // queue out from under us.
    private var _ops as Array<SyncOperationType>;

    function initialize() {
        Comm.SyncDelegate.initialize();

        // Defensive copy — never alias the planner's internal array.
        _ops = [] as Array<SyncOperationType>;
        var current = SyncPlanner.getOps();
        for (var i = 0; i < current.size(); i++) {
            _ops.add(current[i]);
        }
    }

    function isSyncNeeded() as Boolean {
        return _ops.size() > 0;
    }

    function onStartSync() {
        // $.am.debug("[!] SYNC START");
        Comm.checkWifiConnection(method(:onWifiCheckComplete));
    }

    function onWifiCheckComplete(result as {
        :wifiAvailable as Boolean,
        :errorCode as Comm.WifiConnectionStatus
    }) as Void {
        if (result[:wifiAvailable] != true) {
            // Non-fatal: leave the queue intact. Next sync attempt will retry.
            stopSync("WiFi unavailable: " + result[:errorCode]);
            return;
        }
        runNext();
    }

    // SDK can call this if the user/system cancels mid-sync. Same teardown as
    // a clean finish; the queue persists in the planner for the next attempt.
    function onStopSync() as Void {
        stopSync(null);
    }

    // ── op dispatcher ───────────────────────────────────────────────────────

    private function runNext() as Void {
        if (_ops.size() == 0) {
            stopSync(null);
            return;
        }

        var op   = _ops[0];
        var type = op["type"] as String;

        if (type.equals("DOWNLOAD_TRACK") || type.equals("UPDATE_TRACK")) {
            // Resolve via lookup-at-exec. Null = track vanished from "SYNC"
            // since the manifest ran (e.g. user re-fetched playlists).
            var track = SyncPlanner.findTrack(
                op["playlistKey"] as String,
                op["logicalId"]   as String
            );
            if (track == null) {
                $.am.debug("[sync.skip] orphan op " + op);
                completeAndContinue(op);
                return;
            }
            downloadTrack(op, track);
            return;
        }

        if (type.equals("SAVE_PLAYLIST") || type.equals("UPDATE_PLAYLIST")) {
            var playlist = SyncPlanner.findPlaylist(op["playlistKey"] as String);
            if (playlist == null) {
                completeAndContinue(op);
                return;
            }
            // TODO: write the playlist to a local PlaylistStore here. For now
            // we just mirror its checksum so the manifest stops re-queuing it.
            SyncStateStore.setPlaylist(playlist.getKey(), playlist.getChecksum());
            completeAndContinue(op);
            return;
        }

        if (type.equals("REMOVE_PLAYLIST")) {
            // TODO: tear down the locally stored playlist + its tracks before
            // dropping the mirror entry.
            SyncStateStore.removePlaylist(op["playlistKey"] as String);
            completeAndContinue(op);
            return;
        }

        // Unknown op type: drop and continue rather than crash.
        $.am.debug("[sync.unknown] " + op);
        completeAndContinue(op);
    }

    // ── download path ───────────────────────────────────────────────────────

    private function downloadTrack(op as SyncOperationType, track as AudioResource) as Void {
        var request = new HttpRequest({
            :href => track.getSourceUrl(),
            :parameters => {}
        }, method(:onResponse));

        // Carry both the slim op (for bookkeeping) and the live track (for
        // metadata + checksum write-back) into the response callback context.
        request.downloadMp3({ :op => op, :track => track }, method(:onProgress));
    }

    function onProgress(totalBytesTransferred as Number, filesize as Number?) as Void {
        var pct = 0;
        if (filesize != null && filesize > 0) {
            pct = ((totalBytesTransferred.toDouble() / filesize.toDouble()) * 100).toNumber();
        }
        notifySyncProgress(pct);
    }

    function onResponse(
        response as ResponseType,
        context as { :op as SyncOperationType, :track as AudioResource }
    ) as Void {
        // The optional-symbol typing on the context dict means each lookup
        // is inferred as nullable; assert non-null since we always populate
        // both keys when issuing the request.
        var op    = context[:op]    as SyncOperationType;
        var track = context[:track] as AudioResource;
        var data  = response[:data];

        if (response[:ok] != true || !(data instanceof Media.ContentRef)) {
            $.am.debug("[sync.onResponse.fail]\tcode=" + response[:code]
                + " url=" + track.getSourceUrl());
            // Non-fatal: drop this op from the current cycle and invalidate
            // the planner so the next probe re-queues it.
            SyncPlanner.invalidate();
            completeAndContinue(op);
            return;
        }

        var refId = data.getId() as Number;
        $.am.debug("[sync.onResponse] stored refId=" + refId + " url=" + track.getSourceUrl());
        var asset = new AudioAsset(refId);
        var content = asset.getContent();
        var metadata = buildAssetMetadata(track, content);
        asset.saveAndApplyMetadata(content, metadata);

        // Mirror the freshly stored track in LOCAL_TR_CK so the next manifest
        // sees it as up-to-date. setTrack() also invalidates the planner.
        SyncStateStore.setTrack(track.getLogicalId(), track.getChecksum());

        completeAndContinue(op);
    }

    // ── shared teardown ─────────────────────────────────────────────────────

    // Single funnel for both success and skip-on-error: remove from the local
    // queue + the planner cache, then drive the next op.
    private function completeAndContinue(op as SyncOperationType) as Void {
        _ops.remove(op);
        SyncPlanner.complete(op);
        runNext();
    }

    // errorMessage == null  -> clean completion
    // errorMessage != null  -> non-fatal abort (WiFi missing, etc.)
    //
    // We deliberately do NOT delete any storage here. Leftover ops live in
    // the planner cache (and the LOCAL_*_CK mirrors), so the next sync
    // attempt resumes from where we stopped.
    private function stopSync(errorMessage as String?) as Void {
        Comm.notifySyncComplete(errorMessage);
        // $.am.debug("[!] SYNC DONE");
    }

    // Merge the remote-side metadata (AudioResource) with tags the device
    // parsed out of the MP3 (Media.Content). Tags win when present and
    // non-empty; remote values are the fallback.
    private function buildAssetMetadata(track as AudioResource, content as Media.Content?) as AssetMeta {
        var title = track.getTitle();
        var artist = track.getArtist();
        var album = track.getAlbum();

        if (content != null) {
            var mediaMetadata = content.getMetadata();

            if (mediaMetadata != null) {
                title = StringUtils.hasText(mediaMetadata.title) ? mediaMetadata.title : title;
                artist = StringUtils.hasText(mediaMetadata.artist) ? mediaMetadata.artist : artist;
                album = StringUtils.hasText(mediaMetadata.album) ? mediaMetadata.album : album;
            }
        }

        return {
            "title" => StringUtils.stringOrDefault(title, "Unknown"),
            "artist" => StringUtils.stringOrDefault(artist, "Unknown"),
            "album" => StringUtils.stringOrDefault(album, "Unknown"),
            "sourceUrl" => track.getSourceUrl(),
            "logicalId" => AudioAsset.logicalIdFromUrl(track.getSourceUrl()),
            "syncedAt" => null,
            "thumbsUp" => false
        } as AssetMeta;
    }
}
