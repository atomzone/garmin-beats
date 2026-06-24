using Toybox.Media as Media;
using Toybox.Graphics as Graphics;
using Toybox.WatchUi as Ui;
using Toybox.Communications as Comms;
import Toybox.Lang;

// we cannot transport the meta data with the makeImageRequest
// need someother way of know the context so we can assiotte the image with an playlist asset
class ImageSyncHandler extends TransactionAsyncHandler {

    function initialize(transaction as QueueTransactionType, onComplete as Method(Boolean) as Void) {
        TransactionAsyncHandler.initialize(transaction, onComplete);
    }

    function execute() as SyncTransactionHandler.TransactionResult {
        
        var payload = getTransaction()["payload"] as Dictionary;
        $.am.debug("PAYLOAD " + payload);

        var source = "https://fastly.picsum.photos/id/533/100/100.jpg";
        $.am.debug("FAKE SOURCE " + source);
        
        var params = { 
            "hmac" => "OUcoPZYUPb7rDoU4STh-uw-899VtngRJqnP1drjWRgc"
        };

        var options = { 
            // :palette as Lang.Array<Lang.Number>, 
            :maxWidth => 50, 
            :maxHeight => 50, 
            // :dithering as Communications.Dithering, 
            // :packingFormat as Communications.PackingFormat 
        };

        Comms.makeImageRequest(
            source,
            params, 
            options,
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

            $.am.debug("[IMAGE.SAVE.ID]" + id);
            AppStores.media.save(id, data);

        } catch (e) {

            $.am.debug("[BADTIMES]" + e);
            fail();
        }

        success();
    }
}

