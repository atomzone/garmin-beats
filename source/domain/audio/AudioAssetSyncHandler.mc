import Toybox.Lang;

class AudioAssetSyncHandler extends SyncTransactionHandler {

    function initialize() {
        SyncTransactionHandler.initialize();
    }

    function execute(transaction as QueueTransactionType) as String {
        var id = transaction["tid"];
        var operation = transaction["op"];

        if (id == null || operation == null) {
            return "FAILED";
        }

        if (operation.equals("CREATE")) {
            var payload = transaction["payload"] as Dictionary;

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

        return "COMPLETE";
    }
}
