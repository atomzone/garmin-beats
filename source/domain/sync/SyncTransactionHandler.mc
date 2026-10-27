import Toybox.Lang;

typedef QueueTransactionType as {
    "tid" as String, // target id
    "op" as String,
    "entity" as String,
    "payload" as Dictionary
};

typedef TransactionDoneCallbackType as Method(outcome as Number, error as String?) as Void;

// Every handler is async: execute() must eventually call complete() exactly once.
// Synchronous work simply calls complete() before execute() returns.
class SyncTransactionHandler {

    enum Outcome {
        OK,          // done, remove from queue
        SKIP,        // non-critical failure, remove from queue
        ITEM_FAILED, // item at fault, remove from queue and continue
        ENV_FAILED   // device/network at fault, keep item and stop
    }

    private var _transaction as QueueTransactionType;
    private var _done as TransactionDoneCallbackType?;

    function initialize(transaction as QueueTransactionType) {
        _transaction = transaction;
    }

    public function getTransaction() as QueueTransactionType {
        return _transaction;
    }

    public function start(done as TransactionDoneCallbackType) as Void {
        _done = done;
        execute();
    }

    // Detach so late native callbacks are ignored
    public function cancel() as Void {
        _done = null;
    }

    function execute() as Void {
        complete(OK, null);
    }

    function complete(outcome as Outcome, error as String?) as Void {
        var done = _done;
        if (done == null) {
            return;
        }

        _done = null;
        done.invoke(outcome, error);
    }

    static function outcomeForResponseCode(code as Number) as Outcome {
        switch (code) {
            case -2:    // BLE_HOST_TIMEOUT
            case -104:  // BLE_CONNECTION_UNAVAILABLE
            case -1000: // STORAGE_FULL
            case -1008: // NO_TRANSPORT
                return ENV_FAILED;
        }

        return ITEM_FAILED;
    }
}
