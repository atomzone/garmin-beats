import Toybox.Lang;

class PlaylistAssetSyncHandler extends SyncTransactionHandler {

    function initialize() {
        SyncTransactionHandler.initialize();
    }

    function execute(transaction as QueueTransactionType) as String {
        var id = transaction["tid"];
        var operation = transaction["op"];

        if (id == null || operation == null) {
            return "FAILED";
        }

        // build asset and persist against targetId
        if (operation.equals("CREATE") || operation.equals("UPDATE")) {
            var payload = transaction["payload"] as Dictionary;

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

        return "COMPLETE";
    }
}
