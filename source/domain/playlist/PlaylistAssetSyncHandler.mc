import Toybox.Lang;

class PlaylistAssetSyncHandler extends SyncTransactionHandler {

    private var _storage as IndexedStore;

    function initialize() {
        SyncTransactionHandler.initialize();
        _storage = new IndexedStore(IndexedStore.PLAYLIST);
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

            _storage.save(id, asset.serialize());
        }

        if (operation.equals("DELETE")) {
            _storage.remove(id);
        }

        return "COMPLETE";
    }
}
