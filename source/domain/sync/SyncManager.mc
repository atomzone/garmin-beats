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
        if (_processor != null) {
            _processor.stop();
        }

        _notified = false;

        var queue = SyncQueueStore.load();
        $.am().logger().info("[SyncManager] onStartSync", { "queueSize" => queue.size() });

        var processor = new SyncQueueProcessor(
            queue,
            method(:onProgress),
            method(:onComplete)
        );

        _processor = processor;
        processor.start();
    }

    // User cancel abandons the remaining work; landed tracks stay and the playlist can be re-synced
    function onStopSync() as Void {
        $.am().logger().info("[SyncManager] onStopSync", { "hasProcessor" => _processor != null });

        if (_processor != null) {
            _processor.stop();
            _processor = null;
        }

        SyncQueueStore.clear();
        AppStores.playlistManifests.clear();

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