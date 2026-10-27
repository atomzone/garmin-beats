using Toybox.Media as Media;
import Toybox.Lang;

// Mark-and-sweep from playlists. Only run once the sync queue is drained: it clears in-flight playlist manifests.
class SyncGarbageCollector {

    function collect() as Void {
        var usedTracks = {} as Dictionary<String, Boolean>;
        var usedImages = {} as Dictionary<String, Boolean>;

        var playlistIds = AppStores.playlists.getIds();
        for (var i = 0, limit = playlistIds.size(); i < limit; i++) {
            var raw = AppStores.playlists.load(playlistIds[i]) as PlaylistAssetType?;
            if (raw == null) {
                continue;
            }

            var playlist = new PlaylistAsset(raw);
            var trackIds = playlist.getTrackIds();
            for (var j = 0, trLimit = trackIds.size(); j < trLimit; j++) {
                usedTracks[trackIds[j]] = true;
            }

            var artwork = playlist.getMetadata().getArtwork();
            if (artwork != null) {
                usedImages[artwork.getId()] = true;
            }
        }

        var removedTracks = removeUnused(AppStores.tracks, usedTracks);

        var usedMedia = {} as Dictionary<String, Boolean>;
        var trackIds = AppStores.tracks.getIds();
        for (var i = 0, limit = trackIds.size(); i < limit; i++) {
            var raw = AppStores.tracks.load(trackIds[i]) as AudioAssetType?;
            if (raw != null) {
                usedMedia[raw["mediaId"] as String] = true;
            }
        }

        var removedMedia = removeUnusedMedia(usedMedia);
        var removedContent = removeUntrackedContent();
        var removedImages = removeUnused(AppStores.images, usedImages);

        AppStores.playlistManifests.clear();

        $.am().logger().info("[SyncGarbageCollector]", {
            "tracks" => removedTracks,
            "media" => removedMedia,
            "content" => removedContent,
            "images" => removedImages
        });
    }

    private function removeUnused(store as IndexedStore, used as Dictionary<String, Boolean>) as Number {
        // copy: removal mutates the cached index
        var ids = store.getIds().slice(0, null);
        var removed = 0;

        for (var i = 0, limit = ids.size(); i < limit; i++) {
            if (!used.hasKey(ids[i])) {
                store.remove(ids[i]);
                removed++;
            }
        }

        return removed;
    }

    private function removeUnusedMedia(used as Dictionary<String, Boolean>) as Number {
        var ids = AppStores.media.getIds().slice(0, null);
        var removed = 0;

        for (var i = 0, limit = ids.size(); i < limit; i++) {
            if (used.hasKey(ids[i])) {
                continue;
            }

            var record = AppStores.media.load(ids[i]) as MediaRecordType?;
            if (record != null && record["refId"] != null) {
                deleteContent(record["refId"] as Object);
            }

            AppStores.media.remove(ids[i]);
            removed++;
        }

        return removed;
    }

    // Downloads that finished but whose MediaRecord was never written (crash, storage full)
    private function removeUntrackedContent() as Number {
        var known = {};
        var mediaIds = AppStores.media.getIds();

        for (var i = 0, limit = mediaIds.size(); i < limit; i++) {
            var record = AppStores.media.load(mediaIds[i]) as MediaRecordType?;
            if (record != null && record["refId"] != null) {
                known[record["refId"]] = true;
            }
        }

        var cached = MediaUtils.getCachedMediaRefIds(Media.CONTENT_TYPE_AUDIO);
        var removed = 0;

        for (var i = 0, limit = cached.size(); i < limit; i++) {
            if (!known.hasKey(cached[i])) {
                deleteContent(cached[i]);
                removed++;
            }
        }

        return removed;
    }

    private function deleteContent(refId as Object) as Void {
        try {
            MediaUtils.delete(refId);
        } catch (ex) {
            $.am().logger().warn("[SyncGarbageCollector] Content delete failed", {
                "refId" => refId, "error" => ex.getErrorMessage()
            });
        }
    }
}
