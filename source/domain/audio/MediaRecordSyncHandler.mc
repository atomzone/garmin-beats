using Toybox.Media as Media;
import Toybox.Lang;

class MediaRecordSyncHandler extends TransactionAsyncHandler {

    private var _onProgress as Method(Number) as Void;

    function initialize(
        transaction as QueueTransactionType,
        onComplete as Method(Boolean) as Void, 
        onProgress as Method(Number) as Void
    ) {
        TransactionAsyncHandler.initialize(transaction, onComplete);

        _onProgress = onProgress;
    }

    function execute() as SyncTransactionHandler.TransactionResult {
        var payload = getTransaction()["payload"] as Dictionary;
        var source = new MediaSource(payload["source"] as MediaSourceType);
        
        var request = new HttpRequest({
            :href => source.getUrl(),
            :parameters => {}
        }, method(:onResponse));

        var context = { 
            :mediaId => getTransaction()["tid"], 
            :entity => getTransaction()["entity"] as String,
            :source => payload["source"] as MediaSourceType
        };
        
        request.downloadMp3(context, method(:onProgress));

        return SyncTransactionHandler.PENDING;
    }

    function onProgress(totalBytesTransferred as Number, filesize as Number?) as Void {
        var percentageComplete = 0;

        if (filesize != null && filesize > 0) {
            percentageComplete = ((totalBytesTransferred.toDouble() / filesize.toDouble()) * 100).toNumber();
        }

        // TODO: consider reducing notifications involkes
        _onProgress.invoke(percentageComplete);
    }

    function onResponse(
        response as ResponseType,
        context as { 
            :mediaId as String, 
            :entity as String,
            :source as MediaSourceType
        }
    ) as Void {
        var data = response[:data];

        // TODO: can we remove instanceOf check?
        if (response[:ok] != true || !(data instanceof Media.ContentRef)) {
            fail();
            return;
        }

        var mediaId = context[:mediaId] as String;
        var source = context[:source] as MediaSourceType;

        var mediaRecord = new MediaRecord({ 
            "source" => source,
            "refId" => data.getId()
        });

        AppStores.media.save(mediaId, mediaRecord.serialize());

        success();
    }
}

