using Toybox.Communications as Comm;
import Toybox.Lang;

class SyncManager extends Comm.SyncDelegate {

    private var _processor as QueueProcessor?;

    function initialize() {
        Comm.SyncDelegate.initialize();
    }

    function isSyncNeeded() as Boolean {
        return QueueStore.getSize() > 0;
    }

    function onStartSync() as Void {
        var queue = QueueStore.load();

        _processor = new QueueProcessor(
            queue,
            method(:onProgress),
            method(:onComplete)
        );

        _processor.start();
    }

    function onStopSync() as Void {
        if (_processor != null) {
            _processor.stop();
        }

        Communications.cancelAllRequests();
        notifySyncComplete(null);
    }

    function onProgress(progress as Number) as Void {
        notifySyncProgress(progress);
    }

    function onComplete(error as String?) as Void {
        notifySyncComplete(error);
    }
}