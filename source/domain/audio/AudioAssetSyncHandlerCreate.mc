using Toybox.Media as Media;
import Toybox.Lang;

class AudioAssetSyncHandlerCreate extends TransactionAsyncHandler {

    private var _onProgress as Method(Number) as Void;

    function initialize(
        onComplete as Method(Boolean) as Void, 
        onProgress as Method(Number) as Void
    ) {
        TransactionAsyncHandler.initialize(onComplete);
        _onProgress = onProgress;
    }

    function execute(transaction as QueueTransactionType) as String {
        var id = transaction["tid"];
        var payload = transaction["payload"] as Dictionary;

        var source = new AudioSource(payload["source"] as AudioSourceType);
        
        var request = new HttpRequest({
            :href => source.getUrl(),
            :parameters => {}
        }, method(:onResponse));

        var context = { 
            :id => id, 
            :entity => transaction["entity"] as String,
            :metadata => payload["metadata"] as AudioMetadataType,
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
            :id as String, 
            :entity as String,
            :metadata as AudioMetadataType, 
            :source as AudioSourceType 
        }
    ) as Void {
        var data = response[:data];
        var id = context[:id] as String;

        // TODO: can we remove instanceOf check?
        if (response[:ok] != true || !(data instanceof Media.ContentRef)) {
            fail();
            return;
        }

        var asset = new AudioAsset({
            "id" => id,
            "refId" => data.getId(),
            "metadata" => context[:metadata],
            "source" => context[:source]
        } as AudioAssetType);

        $.am.debug("[TRANS][BUILT][MediaAsset2] " + asset.serialize());

        var storage = new IndexedStore(context[:entity] as String);
        storage.set(id, asset.serialize());

        success();
    }
}

