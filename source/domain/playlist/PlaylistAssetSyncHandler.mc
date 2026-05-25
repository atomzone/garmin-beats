import Toybox.Lang;

class PlaylistAssetSyncHandler extends SyncTransactionHandler {

    function initialize() {
        SyncTransactionHandler.initialize();
    }

    // LOOSE SKETCH
    function execute(transaction as QueueTransactionType) as String {
        var tid = transaction["tid"] as String;
        var operation = transaction["op"];

        if (operation == null) {
            return "FAILED";
        }

        if (operation.equals("CREATE")) {
            var payload = transaction["payload"] as Dictionary;

            var asset = new PlaylistAsset({
                "id" => tid,
                "metadata" => payload["metadata"] as PlaylistMetadata,
                "trackIds" => payload["trackIds"] as Array<String>,
            } as PlaylistAssetType);

            $.am.debug("[TRANS][BUILT][PlaylistAsset] " + asset.serialize());

            var storage = new IndexedStore(transaction["entity"] as String);
            storage.set(tid, asset.serialize());
        }

        if (operation.equals("UPDATE")) {
            var payload = transaction["payload"] as PlaylistAssetType;
            var metadata = new PlaylistMetadata(payload["metadata"] as PlaylistMetadataType);
            var playlistId = payload["trackIds"] as Array<String>;

            $.am.debug("[TRANS][" + operation 
                + "][PlaylistAsset] :: targetId=" + tid + ", metadata=" 
                + metadata.serialize() + ", trackIds=" + playlistId);
        }

        if (operation.equals("DELETE")) {
            
            // delete model + remove checksum
            PlaylistManager.delete(tid);
        }

        return "COMPLETE";
    }
}
