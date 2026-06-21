import Toybox.Lang;

typedef QueueTransactionType as {
    "tid" as String, // target id
    "op" as String,
    "entity" as String,
    "payload" as Dictionary
};

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

        $.am.debug("[SYNC] op " + op + " ID " + tid);
        $.am.debug("entity " + entity);
        $.am.debug("payload " + payload);

        return COMPLETE;
    }
}

class TransactionAsyncHandler extends SyncTransactionHandler {

    private var _onComplete as Method(Boolean) as Void;

    function initialize(
        transaction as QueueTransactionType,
        onComplete as Method(Boolean) as Void
    ) {
        SyncTransactionHandler.initialize(transaction);
        _onComplete = onComplete;
    }

    function execute() as SyncTransactionHandler.TransactionResult {
        var op = getTransaction()["op"];
        var entity = getTransaction()["entity"];
        var payload = getTransaction()["payload"];

        $.am.debug("[ASYNC] op " + op);
        $.am.debug("entity " + entity);
        $.am.debug("payload " + payload);

        // dummy async
        var cbTimer = new Timer.Timer();
        cbTimer.start(method(:success), 100, false);

        return PENDING;
    }

    function success() as Void {
        _onComplete.invoke(true);
    }

    function fail() as Void {
        _onComplete.invoke(false);
    }
}
