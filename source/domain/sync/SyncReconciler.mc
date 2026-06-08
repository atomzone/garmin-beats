import Toybox.Lang;

// string vs symbol, only for the debug qualities
typedef MissingTrackReferenceType as {
    "playlistId" as String,
    "trackIds" as Array<String>
};

typedef AuditResultType as {
    "orphanedMedia" as Array<String>,
    "orphanedTracks" as Array<String>,
    "missingTrackReferences" as Array<MissingTrackReferenceType>
};

// Can we be smarter about when reconcilation needs to execute?
// this looks like a static
class SyncReconciler {

    public function audit() as AuditResultType {
        return runAudit();
    }

    public function reconcile() as Void {
        var audit = runAudit();

        cleanupMedia(audit["orphanedMedia"] as Array<String>);
        cleanupTracks(audit["orphanedTracks"] as Array<String>);
        cleanupPlaylists(audit["missingTrackReferences"] as Array<MissingTrackReferenceType>);
    }

    private function runAudit() as AuditResultType {
        return {
            "orphanedMedia" => findOrphanedMedia(),
            "orphanedTracks" => findOrphanedTracks(),
            "missingTrackReferences" => findMissingTrackReferences()
        };
    }

    private function findOrphanedMedia() as Array<String> {

        var orphanMedia = createLookup(AppStores.media.loadIndexIds());
        var tracks = AudioAsset.fromArray(AppStores.tracks.loadAll() as Array<AudioAssetType>);

        for (var i = 0, limit = tracks.size(); i < limit; i++) {
            orphanMedia.remove(tracks[i].getMediaId());
        }

        return orphanMedia.keys();
    }

    private function findOrphanedTracks() as Array<String> {

        var orphanTracks = createLookup(AppStores.tracks.loadIndexIds());
        var playlists = PlaylistAsset.fromArray(AppStores.playlists.loadAll() as Array<PlaylistAssetType>);

        for (var i = 0, plLimit = playlists.size(); i < plLimit; i++) {
            var trackIds = playlists[i].getTrackIds();

            for (var j = 0, trLimit = trackIds.size(); j < trLimit; j++) {
                orphanTracks.remove(trackIds[j]);
            }
        }

        return orphanTracks.keys();
    }

    private function findMissingTrackReferences() as Array<MissingTrackReferenceType> {

        var results = [] as Array<MissingTrackReferenceType>;
        var trackExists = createLookup(AppStores.tracks.loadIndexIds());
        var playlists = PlaylistAsset.fromArray(AppStores.playlists.loadAll() as Array<PlaylistAssetType>);

        for (var i = 0, plLimit = playlists.size(); i < plLimit; i++) {
            var missingTrackIds = [] as Array<String>;
            var trackIds = playlists[i].getTrackIds();

            for (var j = 0, trLimit = trackIds.size(); j < trLimit; j++) {
                if (!trackExists.hasKey(trackIds[j])) {
                    missingTrackIds.add(trackIds[j]);
                }
            }

            if (missingTrackIds.size() > 0) {
                results.add({
                    "playlistId" => playlists[i].getId(),
                    "trackIds" => missingTrackIds
                } as MissingTrackReferenceType);
            }
        }

        return results;
    }

    private function cleanupMedia(mediaIds as Array<String>) as Void {
        for (var i = 0, limit = mediaIds.size(); i < limit; i++) {
            AppStores.media.remove(mediaIds[i]);
        }
    }

    private function cleanupTracks(trackIds as Array<String>) as Void {
        for (var i = 0, limit = trackIds.size(); i < limit; i++) {
            AppStores.tracks.remove(trackIds[i]);
        }
    }

    private function cleanupPlaylists(missingReferences as Array<MissingTrackReferenceType>) as Void {

        for (var i = 0, refLimit = missingReferences.size(); i < refLimit; i++) {
            var playlistId = missingReferences[i]["playlistId"] as String;
            var missingTrackIds = missingReferences[i]["trackIds"] as Array<String>;

            var playlist = new PlaylistAsset(AppStores.playlists.load(playlistId) as PlaylistAssetType);
            var trackIds = playlist.getTrackIds();

            for (var j = 0, limit = missingTrackIds.size(); j < limit; j++) {
                trackIds.remove(missingTrackIds[j]);
            }

            playlist.setTrackIds(trackIds);
            AppStores.playlists.save(playlist.getId(), playlist.serialize());
        }
    }

    private function createLookup(ids as Array<String>) as Dictionary<String, Boolean> {
        var lookup = {};

        for (var i = 0, limit = ids.size(); i < limit; i++) {
            lookup[ids[i]] = true;
        }

        return lookup;
    }
}
