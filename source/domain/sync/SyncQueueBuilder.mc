import Toybox.Lang;

class SyncQueueBuilder {

    private var _playlistStore as IndexedStore;
    private var _trackStore as IndexedStore;

    function initialize() {
        _playlistStore = new IndexedStore("PLAYLIST");
        _trackStore = new IndexedStore("TRACK");
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
    
    private function buildTrackTransactions(resource as AudioResource) as QueueTransactionType? {
        $.am.debug("Resouce: id='" + resource.getId() + "', checksum='" + resource.getChecksum() + "'");
        
        var rawAsset = _trackStore.get(resource.getId()) as AudioAssetType?;

        // local asset exist
        // this check works based on assumption that 
        // resource id and asset id are the same
        // which is currrently a convention knowing if assets exists
        // not ideal
        if (rawAsset == null) {
            return enqueueTrackDownload(resource.getId(), resource);
        }

        var asset = new AudioAsset(rawAsset);

        $.am.debug("Asset: id='" + asset.getId() + "', checksum='" + asset.getChecksum() + "'");

        // metadata / source changed
        if (resource.getChecksum().equals(asset.getChecksum()) == false) {

            // source changed, download needed
            if (resource.getSource().getChecksum().equals(asset.getSource().getChecksum()) == false) {
                return enqueueTrackDownload(asset.getId(), resource);
            }
            else {
                // in this instance, the linked media is the same (source) but the metadata has changed
                // if we upate the meta we change ALL instances of this asset
                // we need to create a new asset LINKED to the same media
                
                // THIS IS NOT! DOING THIS CORRECTLY
                // AS THE ASSET ID IS THE SAME, IT WILL UPDATE THE SAME ASSET IN THE STORE
                return enqueueTrackUpdate(asset.getId(), asset.getRefId(), resource);
            }
        }

        return null;
    }

    private function buildTrackTransactionFromArray(resources as Array<AudioResource>) as Array<QueueTransactionType> {
        var queue = [];

        for (var index = 0, limit = resources.size(); index < limit; index++) {
            var transaction = buildTrackTransactions(resources[index]);
            if (transaction != null) {
                queue.add(transaction);
            }
            else {
                $.am.debug("::[SKIP > TRACK]:: id='" + resources[index].getId() + "' - no changes detected!");
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

    private function enqueueTrackDownload(id as String, resource as AudioResource) as QueueTransactionType {
        var payload = {
            "source" => resource.getSource().serialize(),
            "metadata" => resource.getMetadata().serialize()
        };

        return buildTransaction(id, "DOWNLOAD", "TRACK", payload);
    }
    
    private function enqueueTrackUpdate(
        id as String, 
        refId as Object, 
        resource as AudioResource
    ) as QueueTransactionType {
        var payload = {
            "refId" => refId,
            "source" => resource.getSource().serialize(),
            "metadata" => resource.getMetadata().serialize()
        };

        return buildTransaction(id, "UPDATE", "TRACK", payload);
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