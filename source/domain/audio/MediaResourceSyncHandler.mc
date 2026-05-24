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

        var context = { :tid => tid, :class => audioSource };
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
        context as { :tid as String, :class as AudioSource }
    ) as Void {
        var data = response[:data];

        // TODO: can we remove instanceOf check?
        if (response[:ok] != true || !(data instanceof Media.ContentRef)) {
            fail();
            return;
        }

        var tid = context[:tid];
        var audioSource = context[:class] as AudioSource;
        var refId = data.getId() as Number;

        // LETS MAKE THIS A RECORD OF ID => mediaResource()
        $.am.debug("[TRANS] CREATE MediaAsset :: targetId=" + tid + ", refId=" + refId + ", audioSource=" + audioSource.serialize());

        success();
    }
}

