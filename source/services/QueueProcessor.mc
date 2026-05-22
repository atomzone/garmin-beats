import Toybox.Lang;

typedef QueueTransactionType as {
    "op" as String,
    "entity" as String,
    "payload" as Dictionary
};

class QueueProcessor {

    private var _queue as Array<QueueTransactionType>;

    private var _onProgress as Method(Number) as Void;
    private var _onComplete as Method(String) as Void;

    private var _cancelled as Boolean = false;
    private var _processed as Number = 0;
    private var _total as Number = 0;

    function initialize(
        queue as Array<QueueTransactionType>,
        onProgress as Method(Number) as Void,
        onComplete as Method(String) as Void
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
            var handler = transactionRouter(
                transaction,
                method(:onTransactionComplete)
            );

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
        QueueStore.save(_queue);

        _processed++;

        // notify progress
        var percentageComplete = (_processed * 100 + _total / 2) / _total;
        _onProgress.invoke(percentageComplete);
    }

    function fail(error as String) as Void {
        _onComplete.invoke(error);
    }

    static function transactionRouter(
        transaction as QueueTransactionType,
        onTransactionComplete as Method(Boolean) as Void
    ) as TransactionHandler? {

        var op = transaction["op"] as String;
        var entity = transaction["entity"] as String;

        // TRACK DOWNLOAD
        if (entity.equals("TRACK") && op.equals("DOWNLOAD")) {
            return new TransactionAsyncHandler(onTransactionComplete);
        }

        // PLAYLIST SAVE
        if (entity.equals("PLAYLIST") && op.equals("SAVE")) {
            return new TransactionHandler();
        }

        return null;
    }
}