using Toybox.Media as Media;
import Toybox.Lang;

class MediaResourceSyncHandler extends TransactionAsyncHandler {

    private var _onProgress as Method(Number) as Void;

    function initialize(
        onComplete as Method(Boolean) as Void, 
        onProgress as Method(Number) as Void
    ) {
        TransactionAsyncHandler.initialize(onComplete);
        _onProgress = onProgress;
    }

    function execute(transaction as QueueTransactionType) as String {
        var tid = transaction["tid"];
        var payload = transaction["payload"] as AudioSourceType;
        
        var audioSource = new AudioSource(payload);
        var context = { :id => tid, };
        var request = new HttpRequest({
            :href => audioSource.getUrl(),
            :parameters => {}
        }, method(:onResponse));

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
        context as { :id as String } 
    ) as Void {
        var data = response[:data];

        // TODO: can we remove instanceOf check?
        if (response[:ok] != true || !(data instanceof Media.ContentRef)) {
            fail();
            return;
        }

        var asset = new MediaAssetNew({
            "id" => context[:id] as String,
            "refId" => data.getId()
        });

        $.am.debug("[TRANS][BUILT][MediaAssetNew] " + asset.serialize());

        success();
    }
}

