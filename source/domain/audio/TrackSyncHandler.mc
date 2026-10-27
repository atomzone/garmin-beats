using Toybox.Media as Media;
import Toybox.Lang;

// Ensures media is on the watch, writes the track, then grows its playlist
class TrackSyncHandler extends SyncTransactionHandler {

    private static const INACTIVITY_TIMEOUT_MS as Number = 30000;

    private var _onProgress as Method(Number) as Void;
    private var _request as HttpRequest?;

    function initialize(
        transaction as QueueTransactionType,
        onProgress as Method(Number) as Void
    ) {
        SyncTransactionHandler.initialize(transaction);
        _onProgress = onProgress;
    }

    function execute() as Void {
        var trackId = getTransaction()["tid"] as String?;
        var payload = getTransaction()["payload"] as Dictionary?;

        if (trackId == null || payload == null || payload["mediaId"] == null || payload["source"] == null) {
            complete(SyncTransactionHandler.ITEM_FAILED, "Invalid track transaction");
            return;
        }

        // shared tracks/media may already have been synced by an earlier item
        if (AppStores.tracks.contains(trackId) || AppStores.media.contains(payload["mediaId"] as String)) {
            commitTrack();
            return;
        }

        var resource = payload["source"] as AudioResourceType;
        var source = resource["source"] as MediaSourceType;

        var context = {
            :mediaId => payload["mediaId"] as String,
            :entity => getTransaction()["entity"] as String,
            :source => source
        } as AudioDownloadContextType;

        var request = new HttpRequest(new MediaSource(source).getUrl(), context, method(:onResponse));
        _request = request;
        request.setInactivityTimeout(INACTIVITY_TIMEOUT_MS);
        request.getAudio(null, method(:onProgress));
    }

    function cancel() as Void {
        SyncTransactionHandler.cancel();

        if (_request != null) {
            _request.abandon();
        }
    }

    function onProgress(totalBytesTransferred as Number, filesize as Number?) as Void {
        var percentageComplete = 0;

        if (filesize != null && filesize > 0) {
            percentageComplete = ((totalBytesTransferred.toDouble() / filesize.toDouble()) * 100).toNumber();
        }

        _onProgress.invoke(percentageComplete);
    }

    function onResponse(response as ResponseType, context as AudioDownloadContextType) as Void {
        _request = null;
        var data = response[:data];

        if (response[:ok] != true || !(data instanceof Media.ContentRef)) {
            var error = response[:error] != null ? response[:error] : "Media download failed";
            complete(SyncTransactionHandler.outcomeForResponseCode(response[:code] as Number), error);
            return;
        }

        var mediaRecord = new MediaRecord({
            "source" => context[:source] as MediaSourceType,
            "refId" => (data as Media.ContentRef).getId()
        });

        if (!AppStores.media.save(context[:mediaId] as String, mediaRecord.serialize())) {
            complete(SyncTransactionHandler.ENV_FAILED, "Storage full");
            return;
        }

        commitTrack();
    }

    private function commitTrack() as Void {
        var trackId = getTransaction()["tid"] as String;
        var payload = getTransaction()["payload"] as Dictionary;

        if (!AppStores.tracks.contains(trackId)) {
            var resource = payload["source"] as AudioResourceType;
            var asset = new AudioAsset({
                "id" => trackId,
                "mediaId" => payload["mediaId"] as String,
                "metadata" => resource["meta"],
                "chapters" => resource["chapters"]
            } as AudioAssetType);

            if (!AppStores.tracks.save(trackId, asset.serialize())) {
                complete(SyncTransactionHandler.ENV_FAILED, "Storage full");
                return;
            }
        }

        if (!PlaylistManifest.rebuild(payload["playlistId"] as String)) {
            complete(SyncTransactionHandler.ENV_FAILED, "Storage full");
            return;
        }

        complete(SyncTransactionHandler.OK, null);
    }
}
