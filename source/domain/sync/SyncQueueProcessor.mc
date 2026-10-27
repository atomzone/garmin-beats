import Toybox.Lang;

class SyncQueueProcessor {

    // runs allowed per item before an interrupted (cancelled/crashed) item is abandoned
    private static const MAX_ATTEMPTS as Number = 2;

    private var _queue as Array<QueueTransactionType>;

    private var _onProgress as Method(percentComplete as Number) as Void;
    private var _onComplete as Method(errorMessage as String?) as Void;

    private var _cancelled as Boolean = false;
    private var _finished as Boolean = false;
    private var _looping as Boolean = false;
    private var _settledInLoop as Boolean = false;

    private var _active as SyncTransactionHandler?;

    private var _processed as Number = 0;
    private var _total as Number = 0;
    private var _errors as Array<String> = [];

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

    // Iterative so synchronous completions don't grow the call stack
    function start() as Void {
        _looping = true;

        while (!_cancelled && !_finished) {
            if (_queue.size() == 0) {
                finish();
                break;
            }

            _settledInLoop = false;
            runHead();

            // async: the handler callback re-enters start()
            if (!_settledInLoop) {
                break;
            }
        }

        _looping = false;
    }

    function stop() as Void {
        _cancelled = true;

        if (_active != null) {
            _active.cancel();
            _active = null;
        }
    }

    function onHandlerDone(outcome as Number, error as String?) as Void {
        if (_cancelled || _finished) {
            return;
        }

        _active = null;
        applyOutcome(outcome, error);

        if (_looping) {
            _settledInLoop = true;
        } else {
            start();
        }
    }

    function notifyProgressChange(downloadPercent as Number?) as Void {
        if (_total == 0) {
            return;
        }

        if (downloadPercent == null) {
            downloadPercent = 0;
        }

        var overallProgress = (_processed * 100 + downloadPercent + _total / 2) / _total;

        _onProgress.invoke(overallProgress);
    }

    private function runHead() as Void {
        var transaction = _queue[0];
        var tid = transaction["tid"] as String;

        if (SyncQueueStore.incrementHeadAttempts(tid) > MAX_ATTEMPTS) {
            applyOutcome(
                SyncTransactionHandler.ITEM_FAILED,
                "Abandoned after interruption: " + describe(transaction)
            );
            _settledInLoop = true;
            return;
        }

        var handler = getTransactionHandler(transaction);

        if (handler == null) {
            applyOutcome(
                SyncTransactionHandler.ITEM_FAILED,
                "No handler: " + describe(transaction)
            );
            _settledInLoop = true;
            return;
        }

        _active = handler;
        handler.start(method(:onHandlerDone));
    }

    private function applyOutcome(outcome as Number, error as String?) as Void {
        var transaction = _queue[0];

        switch (outcome) {
            case SyncTransactionHandler.OK:
                advance();
                return;

            case SyncTransactionHandler.SKIP:
                $.am().logger().warn("[SyncQueueProcessor] Skipped", {
                    "item" => describe(transaction), "error" => error
                });
                advance();
                return;

            case SyncTransactionHandler.ENV_FAILED:
                $.am().logger().error("[SyncQueueProcessor] Stopped, will retry", {
                    "item" => describe(transaction), "error" => error
                });
                // the run completed; only interrupted runs count towards MAX_ATTEMPTS
                SyncQueueStore.clearHead();
                _errors.add(error != null ? error : "Sync interrupted");
                finish();
                return;
        }

        // ITEM_FAILED (and anything unexpected)
        var message = error != null ? error : "Transaction failed";
        $.am().logger().error("[SyncQueueProcessor] Dropped", {
            "item" => describe(transaction), "error" => message
        });
        _errors.add(message);
        advance();
    }

    private function advance() as Void {
        _queue = _queue.slice(1, null);
        SyncQueueStore.save(_queue);
        SyncQueueStore.clearHead();
        _processed++;
        notifyProgressChange(null);
    }

    private function finish() as Void {
        _finished = true;

        if (_queue.size() == 0) {
            new SyncGarbageCollector().collect();
        }

        _onComplete.invoke(buildSummary());
    }

    private function buildSummary() as String? {
        var count = _errors.size();

        if (count == 0) {
            return null;
        }

        return count.toString() + " error(s): " + _errors[count - 1];
    }

    private function describe(transaction as QueueTransactionType) as String {
        return transaction["entity"] + ":" + transaction["tid"];
    }

    private function getTransactionHandler(transaction as QueueTransactionType) as SyncTransactionHandler? {
        var entity = transaction["entity"] as String;

        switch (entity) {
            case "PLAYLIST":
                return new PlaylistAssetSyncHandler(transaction);

            case "TRACK":
                return new TrackSyncHandler(transaction, method(:notifyProgressChange));

            case "IMAGE":
                return new ImageSyncHandler(transaction);
        }

        return null;
    }
}