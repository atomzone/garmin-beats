import Toybox.Lang;

class SyncQueueBuilder {

    private var _queuedMediaChecksums as Dictionary<String, Boolean>;

    function initialize() {
        _queuedMediaChecksums = {};
    }

    function buildQueue(playlists as Array<PlaylistResource>) as Array<QueueTransactionType> {
        var queue = [] as Array<QueueTransactionType>;

        for (var index = 0, limit = playlists.size(); index < limit; index++) {
            queue.addAll(
                buildPlaylistTransactions(playlists[index])
            );
        }

        for (var index = 0, limit = queue.size(); index < limit; index++) {
            $.am.debug("::[" + queue[index]["entity"] + " > " + queue[index]["op"] + "]:: " + queue[index]["payload"]);
        }

        return queue;
    }

    private function buildPlaylistTransactions(playlist as PlaylistResource) as Array<QueueTransactionType> {
        var queue = [] as Array<QueueTransactionType>;
        var rawAsset = AppStores.playlists.load(playlist.getId()) as PlaylistAssetType?;

        if (rawAsset == null) {
            
            // new playlist - create
            queue.add(enqueuePlaylistCreate(playlist.getId(), playlist));

            // var imageSource = playlist.getMetadata().getArtwork();
        
        } else {
            
            // existing playlist - check for changes
            var asset = new PlaylistAsset(rawAsset);
            if (playlist.getChecksum().equals(asset.getChecksum()) == false) {
                queue.add(enqueuePlaylistUpdate(asset.getId(), playlist));
            }
            else {
                $.am.debug("::[SKIP playlist]:: id='" + playlist.getId() + "' - no changes detected");
            }
        }

        return queue.addAll(
            buildTrackTransactionFromArray(playlist.getTracks())
        );
    }
    
    private function buildTrackTransaction(track as AudioResource) as Array<QueueTransactionType> {
        var assetId = track.getChecksum();
        var rawAsset = AppStores.tracks.load(assetId) as AudioAssetType?;

        if (rawAsset != null) {
            return [];
        }

        var queue = [] as Array<QueueTransactionType>;
        var mediaId = track.getSource().getChecksum();
        var existingMediaAsset = AppStores.media.load(mediaId) as MediaRecordType?;

        // Queue and Media we didnt know about yet
        if (existingMediaAsset == null && _queuedMediaChecksums[mediaId] == null) {
            queue.add(enqueueMediaDownload(mediaId, track.getSource()));
            _queuedMediaChecksums[mediaId] = true;
        }   

        return queue.add(enqueueTrackCreate(assetId, track));
    }

    private function buildTrackTransactionFromArray(tracks as Array<AudioResource>) as Array<QueueTransactionType> {
        var queue = [];

        for (var index = 0, limit = tracks.size(); index < limit; index++) {
            queue.addAll(
                buildTrackTransaction(tracks[index])
            );
        }

        return queue;
    }

    private function enqueuePlaylistCreate(id as String, resource as PlaylistResource) as QueueTransactionType {
        var payload = {
            "metadata" => resource.getMetadata().serialize(),
            "trackIds" => resource.getTrackIds()
        };

        return buildTransaction(id, "CREATE", "PLAYLIST", payload);       
    }

    private function enqueuePlaylistUpdate(id as String, resource as PlaylistResource) as QueueTransactionType {
        var payload = {
            "metadata" => resource.getMetadata().serialize(),
            "trackIds" => resource.getTrackIds()
        };

        return buildTransaction(id, "UPDATE", "PLAYLIST", payload);
    }
    
    private function enqueueTrackCreate(
        trackId as String, 
        resource as AudioResource
    ) as QueueTransactionType {
        var payload = {
            "mediaId" => resource.getSource().getChecksum(),
            "metadata" => resource.getMetadata().serialize()
        };

        return buildTransaction(trackId, "CREATE", "TRACK", payload);
    }

    private function enqueueMediaDownload(
        mediaId as String,
        source as MediaSource
    ) as QueueTransactionType {
        return buildTransaction(
            mediaId, "DOWNLOAD", "MEDIA", { "source" => source.serialize() }
        );
    }

    private function enqueueImageDownload(
        imageId as String,
        source as MediaSource
    ) as QueueTransactionType {
        return buildTransaction(
            imageId, "DOWNLOAD", "IMAGE", { "source" => source.serialize() }
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