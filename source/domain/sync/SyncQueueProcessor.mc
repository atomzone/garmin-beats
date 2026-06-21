import Toybox.Lang;

class SyncQueueProcessor {

    private var _queue as Array<QueueTransactionType>;

    private var _onProgress as Method(percentComplete as Number) as Void;
    private var _onComplete as Method(errorMessage as String?) as Void;

    private var _cancelled as Boolean = false;
    private var _processed as Number = 0;
    private var _total as Number = 0;

    function initialize(
        queue as Array<QueueTransactionType>,
        onProgress as Method(percentComplete as Number) as Void,
        onComplete as Method(errorMessage as String?) as Void
    ) {
        _queue = queue;
        _onProgress = onProgress;
        _onComplete = onComplete;

        _total = queue.size();
    }

    function start() as Void {

        while (_queue.size() > 0) {

            // inturpted
            if (_cancelled) {
                return;
            }

            var transaction = _queue[0];
            var handler = getTransactionHandler(transaction);

            if (handler == null) {
                fail("No handler");
                return;
            }

            var result = handler.execute();

            // sync complete
            // continue loop
            if (result == SyncTransactionHandler.COMPLETE) {
                completeCurrent();
                continue; // next please
            }

            // async "pending"
            // stop loop & wait for callback
            if (result == SyncTransactionHandler.PENDING) {
                return;
            }

            // result = "FAILED"
            fail("Transaction execution failed");
            return;
        }

        // done
        _onComplete.invoke(null);
    }

    function stop() as Void {
        _cancelled = true;
    }

    function onTransactionComplete(success as Boolean) as Void {

        if (!success) {
            fail("Transaction failed");
            return;
        }

        // update queue
        completeCurrent();

        // resume loop
        start();
    }

    function completeCurrent() as Void {

        // remove task from queue
        _queue.remove(_queue[0]);

        // persist new queue
        SyncQueueStore.save(_queue);

        _processed++;

        // notify progress
        notifyProgressChange(null);
    }

    function notifyProgressChange(downloadPercent as Number?) as Void {
        if (downloadPercent == null) {
            downloadPercent = 0;
        }

        var overallProgress = (_processed * 100 + downloadPercent + _total / 2) / _total;

        _onProgress.invoke(overallProgress);
    }

    function fail(error as String) as Void {
        _onComplete.invoke(error);
    }

    private function getTransactionHandler(transaction as QueueTransactionType) as SyncTransactionHandler? {
        var entity = transaction["entity"] as String;

        // Playlist
        if (entity.equals("PLAYLIST")) {

            // all CRUD actions are sync
            return new PlaylistAssetSyncHandler(transaction);
        }

        // Tracks
        if (entity.equals("TRACK")) {

            // create/delete 
            return new AudioAssetSyncHandler(transaction);
        }

        if (entity.equals("MEDIA")) {

            // Download
            return new MediaRecordSyncHandler(
                transaction,
                method(:onTransactionComplete), 
                method(:notifyProgressChange)
            );
        }

        return null;
    }
}