using Toybox.Media as Media;
import Toybox.Lang;

class MediaRecordSyncHandler extends TransactionAsyncHandler {

    private var _mediaStore as IndexedStore;
    private var _onProgress as Method(Number) as Void;

    function initialize(
        onComplete as Method(Boolean) as Void, 
        onProgress as Method(Number) as Void
    ) {
        TransactionAsyncHandler.initialize(onComplete);

        _mediaStore = new IndexedStore(IndexedStore.MEDIA);
        _onProgress = onProgress;
    }

    function execute(transaction as QueueTransactionType) as String {
        var payload = transaction["payload"] as Dictionary;
        var source = new AudioSource(payload["source"] as AudioSourceType);
        
        var request = new HttpRequest({
            :href => source.getUrl(),
            :parameters => {}
        }, method(:onResponse));

        var context = { 
            :mediaId => transaction["tid"], 
            :entity => transaction["entity"] as String,
            :source => payload["source"] as AudioSourceType
        };
        
        request.downloadMp3(context, method(:onProgress));

        return "PENDING";
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
            :source as AudioSourceType
        }
    ) as Void {
        var data = response[:data];

        // TODO: can we remove instanceOf check?
        if (response[:ok] != true || !(data instanceof Media.ContentRef)) {
            fail();
            return;
        }

        var mediaId = context[:mediaId] as String;
        var source = context[:source] as AudioSourceType;

        var mediaRecord = new MediaRecord({ 
            "source" => source,
            "refId" => data.getId()
        });

        _mediaStore.save(mediaId, mediaRecord.serialize());

        success();
    }
}

