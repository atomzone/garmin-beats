using Toybox.Communications as Comm;
import Toybox.Lang;

class SyncManager extends Comm.SyncDelegate {

    private var _processor as SyncQueueProcessor?;

    function initialize() {
        Comm.SyncDelegate.initialize();
    }

    function isSyncNeeded() as Boolean {
        return SyncQueueStore.getSize() > 0;
    }

    function onStartSync() as Void {
        var queue = SyncQueueStore.load();

        _processor = new SyncQueueProcessor(
            queue,
            method(:onProgress),
            method(:onComplete)
        );

        _processor.start();
    }

    function onStopSync() as Void {
        Comm.cancelAllRequests(); // this triggers :onComplete

        if (_processor != null) {
            _processor.stop();
        }
    }

    function onProgress(progress as Number) as Void {
        Comm.notifySyncProgress(progress);
    }

    // can we redirect to the playlist menu?
    function onComplete(error as String?) as Void {

        // [TODO] Should we run on Error?
        // if (error == null) {
            $.am().logger().info("[SyncManager] Sync completed successfully, running reconciliation", { "error" => error });
            new SyncReconciler().reconcile();
        // }

        Comm.notifySyncComplete(error);
    }
}