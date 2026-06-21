import Toybox.Lang;

class AudioAssetSyncHandler extends SyncTransactionHandler {

    function initialize(transaction as QueueTransactionType) {
        SyncTransactionHandler.initialize(transaction);
    }

    function execute() as SyncTransactionHandler.TransactionResult {
        var id = getTransaction()["tid"];
        var operation = getTransaction()["op"];

        if (id == null || operation == null) {
            return SyncTransactionHandler.FAILED;
        }

        if (operation.equals("CREATE")) {
            var payload = getTransaction()["payload"] as Dictionary;

            var asset = new AudioAsset({
                "id" => id,
                "mediaId" => payload["mediaId"] as String,
                "metadata" => payload["metadata"] as AudioMetadataType
            } as AudioAssetType);

            $.am.debug("[AudioAssetSyncHandler.execute][" + operation 
                + "][AudioAsset] :: targetId='" + id + "', data='" + asset.serialize() + "'");

            AppStores.tracks.save(id, asset.serialize());
        }

        if (operation.equals("DELETE")) {
            AppStores.tracks.remove(id);
        }

        return SyncTransactionHandler.COMPLETE;
    }
}
