import Toybox.Lang;

// Per playlist: TRACK... [IMAGE] PLAYLIST(commit)
// Tracks grow the playlist as they land; the commit aligns it with the source.
class SyncQueueBuilder {

    function buildQueue(playlists as Array<PlaylistResource>) as Array<QueueTransactionType> {
        var queue = [] as Array<QueueTransactionType>;

        for (var index = 0, limit = playlists.size(); index < limit; index++) {
            queue.addAll(
                buildPlaylistTransactions(playlists[index])
            );
        }

        for (var index = 0, limit = queue.size(); index < limit; index++) {
            $.am().logger().debug("[SyncQueueBuilder.buildQueue]", queue[index]);
        }

        return queue;
    }

    private function buildPlaylistTransactions(playlist as PlaylistResource) as Array<QueueTransactionType> {
        var playlistId = playlist.getId();
        var trackTransactions = buildTrackTransactions(playlistId, playlist.getTracks());
        var artwork = playlist.getMetadata().getArtwork();
        var needsArtwork = artwork != null && !AppStores.images.contains(artwork.getId());

        var rawAsset = AppStores.playlists.load(playlistId) as PlaylistAssetType?;
        var isCurrent = rawAsset != null
            && playlist.getChecksum().equals(new PlaylistAsset(rawAsset).getChecksum());

        if (isCurrent && trackTransactions.size() == 0 && !needsArtwork) {
            $.am().logger().debug("[SyncQueueBuilder] No changes detected", { "id" => playlistId });
            return [];
        }

        PlaylistManifest.save(playlist);

        var queue = [] as Array<QueueTransactionType>;

        queue.addAll(trackTransactions);

        // after tracks: artwork is only worth fetching once the playlist exists
        if (needsArtwork) {
            queue.add(enqueueImageDownload(playlistId, artwork as MediaSource));
        }

        queue.add(buildTransaction(playlistId, "COMMIT", "PLAYLIST", {}));

        return queue;
    }

    private function buildTrackTransactions(
        playlistId as String,
        tracks as Array<AudioResource>
    ) as Array<QueueTransactionType> {
        var queue = [] as Array<QueueTransactionType>;

        for (var index = 0, limit = tracks.size(); index < limit; index++) {
            var track = tracks[index];
            var trackId = track.getChecksum();

            if (AppStores.tracks.contains(trackId)) {
                continue;
            }

            queue.add(buildTransaction(trackId, "CREATE", "TRACK", {
                "playlistId" => playlistId,
                "mediaId" => track.getSource().getChecksum(),
                "source" => track.serialize()
            }));
        }

        return queue;
    }

    private function enqueueImageDownload(playlistId as String, source as MediaSource) as QueueTransactionType {
        return buildTransaction(
            source.getId(), "DOWNLOAD", "IMAGE", { "playlistId" => playlistId, "source" => source.serialize() }
        );
    }

    private function buildTransaction(
        id as String, 
        operation as String, 
        entity as String, 
        payload as Dictionary
    ) as QueueTransactionType {
        return {
            "tid" => id,
            "op" => operation,
            "entity" => entity,
            "payload" => payload
        };
    }
}