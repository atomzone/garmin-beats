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

    // need to cleanup on error or cancellation
    // can we redirect to the playlist menu?
    function onStopSync() as Void {
        if (_processor != null) {
            _processor.stop();
        }

        Comm.notifySyncComplete(null);
        Comm.cancelAllRequests();
    }

    function onProgress(progress as Number) as Void {
        Comm.notifySyncProgress(progress);
    }

    // can we redirect to the playlist menu?
    function onComplete(error as String?) as Void {
        Comm.notifySyncComplete(error);
    }
}