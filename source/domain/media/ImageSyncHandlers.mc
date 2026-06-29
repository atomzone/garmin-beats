using Toybox.Media as Media;
using Toybox.Graphics as Graphics;
using Toybox.WatchUi as Ui;
using Toybox.Communications as Comms;
import Toybox.Lang;

class ImageSyncHandler extends TransactionAsyncHandler {

    function initialize(transaction as QueueTransactionType, onComplete as Method(Boolean) as Void) {
        TransactionAsyncHandler.initialize(transaction, onComplete);
    }

    function execute() as SyncTransactionHandler.TransactionResult {
        var payload = getTransaction()["payload"] as Dictionary;
        var source = new MediaSource(payload["source"] as MediaSourceType);

        Comms.makeImageRequest(
            source.getUrl(),
            null,
            { 
                // :palette as Lang.Array<Lang.Number>, 
                :maxWidth => 48, 
                :maxHeight => 48, 
                :dithering => Comms.IMAGE_DITHERING_NONE, 
                :packingFormat => Comms.PACKING_FORMAT_DEFAULT 
            },
            method(:onResponse)
        );

        return SyncTransactionHandler.PENDING;
    }

    function onResponse(
        responseCode as Number,
        data as Ui.BitmapResource or Graphics.BitmapReference or Null
    ) as Void {

        if (data == null || responseCode != 200) {
            fail();
            return;
        }

        var id = getTransaction()["tid"] as String;
    
        try {
            AppStores.images.save(id, data);
        } catch (e) {
            $.am.debug("[ImageSyncHandler.onResponse]" + e.getErrorMessage());
            fail();
        }

        success();
    }
}

