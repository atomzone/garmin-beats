import Toybox.Lang;

class PlaylistResourceSyncHandler extends SyncTransactionHandler {

    function initialize() {
        SyncTransactionHandler.initialize();
    }

    // LOOSE SKETCH
    function execute(transaction as QueueTransactionType) as String {
        var operation = transaction["op"];

        if (operation == null) {
            return "FAILED";
        }

        if (operation.equals("SAVE") || operation.equals("UPDATE")) {
            var playlist = new PlaylistResource(transaction["payload"] as PlaylistResourceType);

            // persist model + persist checksum
            PlaylistManager.save(playlist);
        }

        if (operation.equals("DELETE")) {
            
            // delete model + remove checksum
            PlaylistManager.delete(transaction["id"] as String);
        }

        return "COMPLETE";
    }
}
