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
            var handler = transactionRouter(transaction);

            if (handler == null) {
                fail("No handler");
                return;
            }

            var result = handler.execute(transaction);

            // sync complete
            // continue loop
            if (result.equals("COMPLETE")) {
                completeCurrent();
                continue; // next please
            }

            // async "pending"
            // stop loop & wait for callback
            if (result.equals("PENDING")) {
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

    private function transactionRouter(transaction as QueueTransactionType) as SyncTransactionHandler? {

        var op = transaction["op"] as String;
        var entity = transaction["entity"] as String;

        // TRACK DOWNLOAD
        if (op.equals("DOWNLOAD")) {

            // Save MediaResource
            return new MediaResourceSyncHandler(
                method(:onTransactionComplete), method(:notifyProgressChange)
            );
        }

        if (entity.equals("PLAYLIST")) {

            // SAVE/UPDATE PlaylistResource -> PlaylistAsset
            return new PlaylistResourceSyncHandler();
        }
        if (entity.equals("TRACK")) {

            // SAVE/UPDATE AudioResource -> AudioAsset
            return new AudioResourceSyncHandler();
        }

        return null;
    }
}