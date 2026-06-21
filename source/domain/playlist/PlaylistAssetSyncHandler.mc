import Toybox.Lang;

class PlaylistAssetSyncHandler extends SyncTransactionHandler {

    function initialize(transaction as QueueTransactionType) {
        SyncTransactionHandler.initialize(transaction);
    }

    function execute() as SyncTransactionHandler.TransactionResult {
        var id = getTransaction()["tid"];
        var operation = getTransaction()["op"];

        if (id == null || operation == null) {
            return SyncTransactionHandler.FAILED;
        }

        // build asset and persist against targetId
        if (operation.equals("CREATE") || operation.equals("UPDATE")) {
            var payload = getTransaction()["payload"] as Dictionary;

            var asset = new PlaylistAsset({
                "id" => id,
                "metadata" => payload["metadata"] as PlaylistMetadata,
                "trackIds" => payload["trackIds"] as Array<String>,
            } as PlaylistAssetType);

            $.am.debug("[PlaylistAssetSyncHandler.execute][" + operation 
                + "][PlaylistAsset] :: targetId='" + id + "', data='" + asset.serialize() + "'");

            AppStores.playlists.save(id, asset.serialize());
        }

        if (operation.equals("DELETE")) {
            AppStores.playlists.remove(id);
        }

        return SyncTransactionHandler.COMPLETE;
    }
}
