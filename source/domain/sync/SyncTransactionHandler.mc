import Toybox.Lang;

typedef QueueTransactionType as {
    "tid" as String, // target id
    "op" as String,
    "entity" as String,
    "payload" as Dictionary
};

typedef TransactionCompleteCallbackType as Method(success as Boolean, error as String?) as Void;

class SyncTransactionHandler {

    enum TransactionResult {
        COMPLETE,
        PENDING,
        FAILED
    }

    private var _transaction as QueueTransactionType;

    function initialize(transaction as QueueTransactionType) {
        _transaction = transaction;
    }

    public function getTransaction() as QueueTransactionType {
        return _transaction;
    }

    // COMPLETE -> sync completion
    // PENDING  -> async completion later
    // FAILED   -> immediate failure
    function execute() as TransactionResult {
        var tid = getTransaction()["tid"];
        var op = getTransaction()["op"];
        var entity = getTransaction()["entity"];
        var payload = getTransaction()["payload"];

        $.am().logger().debug("[SyncTransactionHandler.execute]", {
            "tid" => tid,
            "operation" => op,
            "entity" => entity,
            "payload" => payload
        });

        return COMPLETE;
    }
}

class TransactionAsyncHandler extends SyncTransactionHandler {

    private var _onComplete as TransactionCompleteCallbackType;

    function initialize(
        transaction as QueueTransactionType,
        onComplete as TransactionCompleteCallbackType
    ) {
        SyncTransactionHandler.initialize(transaction);
        _onComplete = onComplete;
    }

    // BASE CLASS; IS THIS EVER CALLED?
    function execute() as SyncTransactionHandler.TransactionResult {
        var tid = getTransaction()["tid"];
        var op = getTransaction()["op"];
        var entity = getTransaction()["entity"];
        var payload = getTransaction()["payload"];

        $.am().logger().debug("[TransactionAsyncHandler.execute]", {
            "tid" => tid,
            "operation" => op,
            "entity" => entity,
            "payload" => payload
        });

        // dummy async
        var cbTimer = new Timer.Timer();
        cbTimer.start(method(:success), 100, false);

        return PENDING;
    }

    function success() as Void {
        _onComplete.invoke(true, null);
    }

    function fail(errorMessage as String?) as Void {
        _onComplete.invoke(false, errorMessage != null ? errorMessage : "Transaction failed");
    }
}
