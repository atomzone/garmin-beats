import Toybox.Lang;

// Final step per playlist: align stored playlist with its manifest, then drop the manifest
class PlaylistAssetSyncHandler extends SyncTransactionHandler {

    function initialize(transaction as QueueTransactionType) {
        SyncTransactionHandler.initialize(transaction);
    }

    function execute() as Void {
        var id = getTransaction()["tid"] as String?;

        if (id == null) {
            complete(SyncTransactionHandler.ITEM_FAILED, "Invalid playlist transaction");
            return;
        }

        if (!PlaylistManifest.rebuild(id)) {
            complete(SyncTransactionHandler.ENV_FAILED, "Storage full");
            return;
        }

        PlaylistManifest.remove(id);
        complete(SyncTransactionHandler.OK, null);
    }
}
