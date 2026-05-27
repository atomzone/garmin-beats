import Toybox.Lang;

class PlaylistAssetSyncHandler extends SyncTransactionHandler {

    private var _storage as IndexedStore;

    function initialize() {
        SyncTransactionHandler.initialize();
        _storage = new IndexedStore("PLAYLIST");
    }

    function execute(transaction as QueueTransactionType) as String {
        var tid = transaction["tid"];
        var operation = transaction["op"];

        if (tid == null || operation == null) {
            return "FAILED";
        }

        // build asset and persist against tid
        if (operation.equals("CREATE") || operation.equals("UPDATE")) {
            var payload = transaction["payload"] as Dictionary;

            var asset = new PlaylistAsset({
                "id" => tid,
                "metadata" => payload["metadata"] as PlaylistMetadata,
                "trackIds" => payload["trackIds"] as Array<String>,
            } as PlaylistAssetType);

            $.am.debug("[PlaylistAssetSyncHandler.execute][" + operation 
                + "][PlaylistAsset] :: targetId='" + tid + "', data='" + asset.serialize() + "'");

            _storage.set(asset.getId(), asset.serialize());
        }

        if (operation.equals("DELETE")) {
            _storage.delete(tid);
        }

        return "COMPLETE";
    }
}
