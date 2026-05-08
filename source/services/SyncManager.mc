using Toybox.Media as Media;
using Toybox.Communications as Comm;
import Toybox.Lang;

class SyncManager extends Comm.SyncDelegate {

    private var _queue as Array<AudioResource>;

    function initialize() {
        Comm.SyncDelegate.initialize();

        var resources = StorageManager.getOrDefault("SYNC", []) as Array<AudioResourceType>;
        _queue = buildResources(resources);
    }

    function isSyncNeeded() as Boolean {
        return _queue.size() > 0;
    }

    function onStartSync() {
        $.am.debug("[!] SYNC START");
        Comm.checkWifiConnection(method(:onWifiCheckComplete));
    }

    function onWifiCheckComplete(result as {
        :wifiAvailable as Boolean,
        :errorCode as Comm.WifiConnectionStatus
    }) as Void {
        if (result[:wifiAvailable] != true) {
            stopSync("WiFi unavailable: " + result[:errorCode]);
            return;
        }

        downloadNext();
    }

    function onStopSync() as Void {
        stopSync(null);
    }

    function downloadNext() as Void {

        if (_queue.size() == 0) {
            stopSync(null);
            return;
        }

        var track = _queue[0];
        var context = { :track => track };
        var request = new HttpRequest({
            :href => track.getSourceUrl(),
            :parameters => {}
        }, method(:onResponse));
      
        $.am.debug("[!] Begin (async) request.download()");
        request.downloadMp3(context, method(:onProgress));
        $.am.debug("[!] End (call) request.download()");
    }

    function onProgress(totalBytesTransferred as Number, filesize as Number?) as Void {
        var percentageComplete = 0;

        if (filesize != null && filesize > 0) {
            percentageComplete = ((totalBytesTransferred.toDouble() / filesize.toDouble()) * 100).toNumber();
        }

        $.am.debug("[+]\tTransferred: " + totalBytesTransferred + " / " + filesize + " (" + percentageComplete + "%)");

        notifySyncProgress(percentageComplete);
    }

    function onResponse(
        response as ResponseType,
        context as { :track as AudioResource }
    ) as Void {
        var data = response[:data];
        var track = context[:track] as AudioResource;

        if (response[:ok] != true || !(data instanceof Media.ContentRef)) {
            $.am.debug("[sync.onResponse.fail]\tcode=" + response[:code] + " Expected Media.ContentRef");
            _queue.remove(track);
            downloadNext();
            return;
        }

        var refId = data.getId() as Number;
        var asset = new AudioAsset(refId);
        var content = asset.getContent();
        var metadata = buildAssetMetadata(track, content);
        asset.saveAndApplyMetadata(content, metadata);

        _queue.remove(track);
        downloadNext();
    }

    private function stopSync(errorMessage as String?) as Void {
        $.am.debug("[!] SYNC STOP");
        StorageManager.delete("SYNC");
        Comm.notifySyncComplete(errorMessage);
        $.am.debug("[!] SYNC DONE");
    }

    private function buildAssetMetadata(track as AudioResource, content as Media.Content?) as AssetMeta {
        var title = track.getTitle();
        var artist = track.getArtist();
        var album = track.getAlbum();

        if (content != null) {
            var mediaMetadata = content.getMetadata();

            if (mediaMetadata != null) {
                title = StringUtils.hasText(mediaMetadata.title) ? mediaMetadata.title : title;
                artist = StringUtils.hasText(mediaMetadata.artist) ? mediaMetadata.artist : artist;
                album = StringUtils.hasText(mediaMetadata.album) ? mediaMetadata.album : album;
            }
        }

        return {
            "title" => StringUtils.stringOrDefault(title, "Unknown"),
            "artist" => StringUtils.stringOrDefault(artist, "Unknown"),
            "album" => StringUtils.stringOrDefault(album, "Unknown"),
            "sourceUrl" => track.getSourceUrl(),
            "logicalId" => AudioAsset.logicalIdFromUrl(track.getSourceUrl()),
            "syncedAt" => null,
            "thumbsUp" => false
        } as AssetMeta;
    }
}
