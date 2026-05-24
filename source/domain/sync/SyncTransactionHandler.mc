import Toybox.Lang;

// enum TransactionResult {
//     COMPLETE,
//     PENDING,
//     FAILED
// }

typedef QueueTransactionType as {
    "tid" as String, // target id
    "op" as String,
    "entity" as String,
    "payload" as Dictionary
};

class SyncTransactionHandler {

    // COMPLETE -> sync completion
    // PENDING  -> async completion later
    // FAILED   -> immediate failure
    function execute(transaction as QueueTransactionType) as String {
        var tid = transaction["tid"];
        var op = transaction["op"];
        var entity = transaction["entity"];
        var payload = transaction["payload"];

        $.am.debug("[SYNC] op " + op + " ID " + tid);
        $.am.debug("entity " + entity);
        $.am.debug("payload " + payload);

        return "COMPLETE";
    }
}

class TransactionAsyncHandler extends SyncTransactionHandler {

    private var _onComplete as Method(Boolean) as Void;

    function initialize(onComplete as Method(Boolean) as Void) {
        SyncTransactionHandler.initialize();
        _onComplete = onComplete;
    }

    function execute(transaction as QueueTransactionType) as String {
        var op = transaction["op"];
        var entity = transaction["entity"];
        var payload = transaction["payload"];

        $.am.debug("[ASYNC] op " + op);
        $.am.debug("entity " + entity);
        $.am.debug("payload " + payload);

        // dummy async
        var cbTimer = new Timer.Timer();
        cbTimer.start(method(:success), 100, false);

        return "PENDING";
    }

    function success() as Void {
        _onComplete.invoke(true);
    }

    function fail() as Void {
        _onComplete.invoke(false);
    }
}
