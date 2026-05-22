import Toybox.Lang;

// enum TransactionResult {
//     COMPLETE,
//     PENDING,
//     FAILED
// }

class TransactionHandler {

    //
    // RETURN:
    //
    // COMPLETE -> sync completion
    // PENDING  -> async completion later
    // FAILED   -> immediate failure
    //
    function execute(transaction as QueueTransactionType) as String {
        var op = transaction["op"];
        var entity = transaction["entity"];
        var payload = transaction["payload"];

        $.am.debug("[SYNC] op " + op);
        $.am.debug("entity " + entity);
        $.am.debug("payload " + payload);

        return "COMPLETE";
    }
}

class TransactionAsyncHandler extends TransactionHandler {

    protected var _onComplete as Method(Boolean) as Void;

    function initialize(onComplete as Method(Boolean) as Void) {
        TransactionHandler.initialize();
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
        cbTimer.start(method(:success), 1000, false);

        return "PENDING";
    }

    function success() as Void {
        _onComplete.invoke(true);
    }

    function fail() as Void {
        _onComplete.invoke(false);
    }
}
