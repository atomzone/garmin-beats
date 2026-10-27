using Toybox.Communications as Comm;
import Toybox.Lang;

class SyncManager extends Comm.SyncDelegate {

    private var _processor as SyncQueueProcessor?;
    private var _notified as Boolean = false;

    function initialize() {
        Comm.SyncDelegate.initialize();
    }

    function isSyncNeeded() as Boolean {
        return SyncQueueStore.getSize() > 0;
    }

    function onStartSync() as Void {
        _notified = false;

        var processor = new SyncQueueProcessor(
            SyncQueueStore.load(),
            method(:onProgress),
            method(:onComplete)
        );

        _processor = processor;
        processor.start();
    }

    // Queue head is kept; its persisted attempt count decides whether it is retried
    function onStopSync() as Void {
        if (_processor != null) {
            _processor.stop();
            _processor = null;
        }

        Comm.cancelAllRequests();
        notifyComplete("Sync cancelled");
    }

    function onProgress(progress as Number) as Void {
        Comm.notifySyncProgress(progress);
    }

    function onComplete(error as String?) as Void {
        _processor = null;

        $.am().logger().info("[SyncManager] Sync finished", {
            "error" => error,
            "remaining" => SyncQueueStore.getSize()
        });

        notifyComplete(error);
    }

    private function notifyComplete(error as String?) as Void {
        if (_notified) {
            return;
        }

        _notified = true;
        Comm.notifySyncComplete(error);
    }
}