using Toybox.Graphics as Graphics;
import Toybox.Lang;

// Artwork is non-critical: every failure is a SKIP
class ImageSyncHandler extends SyncTransactionHandler {

    private static const INACTIVITY_TIMEOUT_MS as Number = 2000;

    private var _request as HttpRequest?;

    function initialize(transaction as QueueTransactionType) {
        SyncTransactionHandler.initialize(transaction);
    }

    function execute() as Void {
        if (AppStores.images.contains(getTransaction()["tid"] as String)) {
            complete(SyncTransactionHandler.OK, null);
            return;
        }

        var payload = getTransaction()["payload"] as Dictionary;
        if (!AppStores.playlists.contains(payload["playlistId"] as String)) {
            complete(SyncTransactionHandler.SKIP, "No tracks synced, artwork not needed");
            return;
        }

        var source = new MediaSource(payload["source"] as MediaSourceType);
        var request = new HttpRequest(source.getUrl(), null, method(:onResponse));
        _request = request;
        request.setInactivityTimeout(INACTIVITY_TIMEOUT_MS);
        request.getImage(48, 48);
    }

    function cancel() as Void {
        SyncTransactionHandler.cancel();

        if (_request != null) {
            _request.abandon();
        }
    }

    function onResponse(response as ResponseType, context as Object?) as Void {
        _request = null;
        var data = response[:data];

        if (response[:ok] != true || data == null) {
            complete(SyncTransactionHandler.SKIP, response[:error] != null ? response[:error] : "Image download failed");
            return;
        }

        var id = getTransaction()["tid"] as String;

        if (!AppStores.images.save(id, data as Graphics.BitmapReference)) {
            complete(SyncTransactionHandler.SKIP, "Image could not be saved");
            return;
        }

        complete(SyncTransactionHandler.OK, null);
    }
}

