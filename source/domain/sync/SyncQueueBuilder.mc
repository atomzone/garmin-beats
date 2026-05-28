import Toybox.Lang;

class SyncQueueBuilder {

    private var _playlistStore as IndexedStore;
    private var _trackStore as IndexedStore;
    private var _mediaStore as IndexedStore;

    function initialize() {
        _playlistStore = new IndexedStore("PLAYLIST");
        _trackStore = new IndexedStore("TRACK");
        _mediaStore = new IndexedStore("MEDIA");
    }

    function buildQueue(playlists as Array<PlaylistResource>) as Array<QueueTransactionType> {
        var queue = [] as Array<QueueTransactionType>;

        for (var index = 0, limit = playlists.size(); index < limit; index++) {
            queue.addAll(buildPlaylistTransactions(playlists[index]));
        }

        for (var index = 0, limit = queue.size(); index < limit; index++) {
            $.am.debug("::[" + queue[index]["entity"] + " > " + queue[index]["op"] + "]:: " + queue[index]);
        }

        return queue;
    }

    private function buildPlaylistTransactions(resource as PlaylistResource) as Array<QueueTransactionType> {
        var queue = [] as Array<QueueTransactionType>;
        var rawAsset = _playlistStore.get(resource.getId()) as PlaylistAssetType?;

        // local asset exist
        if (rawAsset == null) {
            queue.add(enqueuePlaylistCreate(resource.getId(), resource));
            queue.addAll(buildTrackTransactionFromArray(resource.getTracks()));

            return queue;
        }

        var asset = new PlaylistAsset(rawAsset);

        // metadata / tracks changed
        if(resource.getChecksum().equals(asset.getChecksum()) == false) {
            queue.add(enqueuePlaylistUpdate(asset.getId(), resource));
            queue.addAll(buildTrackTransactionFromArray(resource.getTracks()));
        }
        else {
            $.am.debug("::[SKIP playlist]:: id='" + resource.getId() + "' - no changes detected");
        }

        return queue;
    }
    
    private function buildTrackTransaction(resource as AudioResource) as QueueTransactionType? {
        var assetId = resource.getChecksum();
        var rawAsset = _trackStore.get(assetId) as AudioAssetType?;

        if (rawAsset != null) {
            return null;
        }

        var existingMediaAsset = _mediaStore.get(resource.getSource().getChecksum()) as MediaAssetType?;

        if (existingMediaAsset != null) {

            return enqueueSaveTrack(
                assetId,
                existingMediaAsset["refId"] as Object,
                resource
            );
        }

        return enqueueDownloadAndSaveTrack(assetId, resource);
    }

    private function buildTrackTransactionFromArray(resources as Array<AudioResource>) as Array<QueueTransactionType> {
        var queue = [];

        for (var index = 0, limit = resources.size(); index < limit; index++) {
            var transaction = buildTrackTransaction(resources[index]);
            if (transaction != null) {
                queue.add(transaction);
            }
            else {
                $.am.debug("::[SKIP > TRACK]:: id='" + resources[index].getChecksum() + "' - no changes detected!");
            }
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

    private function enqueueDownloadAndSaveTrack(id as String, resource as AudioResource) as QueueTransactionType {
        var payload = {
            "source" => resource.getSource().serialize(),
            "metadata" => resource.getMetadata().serialize()
        };

        return buildTransaction(id, "DOWNLOAD", "TRACK", payload);
    }
    
    private function enqueueSaveTrack(
        id as String, 
        refId as Object, 
        resource as AudioResource
    ) as QueueTransactionType {
        var payload = {
            "refId" => refId,
            "source" => resource.getSource().serialize(),
            "metadata" => resource.getMetadata().serialize()
        };

        return buildTransaction(id, "CREATE", "TRACK", payload);
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