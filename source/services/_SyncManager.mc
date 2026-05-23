using Toybox.Media as Media;
using Toybox.Communications as Comm;
import Toybox.Lang;

// move to manager folder?
class OLDSyncManager extends Comm.SyncDelegate {

    private var _playlist as Array<PlaylistResource>;
    // queue = required mutations
    private var _queue as Array<AudioResource>;

    function initialize(playlist as Array<PlaylistResource>) {
        Comm.SyncDelegate.initialize();

        _playlist = playlist;

        _queue = [];
        // for (var i = 0, limit = _playlist.size(); i < limit; i++) {
        //     _queue.addAll(_playlist[i].getTracks());
        // }

        var playlistLocal = {"thetechmonkey" => "0C217DEA", "Default Playlist" => "FFCDF976"};
        var tracklistLocal = {};
        var manifest = new SyncManifest(_playlist, playlistLocal, tracklistLocal);
        manifest.build();

        var ops = manifest.getOperations();
        for (var i = 0, limit = ops.size(); i < limit; i++) {
            var operation = ops[i];

            $.am.debug("[manifest.getOperations] " + operation);
            $.am.debug("[manifest.getOperations.type] " + operation["type"]);    
            $.am.debug("[manifest.getOperations.track] " + operation["track"]);

            if (operation["type"] != null && (operation["type"] as String).equals("DOWNLOAD_TRACK")) {
                if (operation["track"] != null) {
                    _queue.add(operation["track"] as AudioResource);
                }
            }
        }

        // var syncOperation as Array<SyncOperation>
    }

    function isSyncNeeded() as Boolean {
        return _queue.size() > 0;
    }

    function onStartSync() {
        // $.am.debug("[!] SYNC START");
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
      
        // $.am.debug("[!] Begin (async) request.download()");
        request.downloadMp3(context, method(:onProgress));
        // $.am.debug("[!] End (call) request.download()");
    }

    function onProgress(totalBytesTransferred as Number, filesize as Number?) as Void {
        var percentageComplete = 0;

        if (filesize != null && filesize > 0) {
            percentageComplete = ((totalBytesTransferred.toDouble() / filesize.toDouble()) * 100).toNumber();
        }

        // $.am.debug("[+]\tTransferred: " + totalBytesTransferred + " / " + filesize + " (" + percentageComplete + "%)");

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
        $.am.debug("[sync.onResponse] stored refId=" + refId + " url=" + track.getSourceUrl());
        var asset = new AudioAsset(refId);
        var content = asset.getContent();
        var metadata = buildAssetMetadata(track, content);
        asset.saveAndApplyMetadata(content, metadata);

        _queue.remove(track);
        downloadNext();
    }

    private function stopSync(errorMessage as String?) as Void {
        // $.am.debug("[!] SYNC STOP");
        StorageManager.delete("SYNC");
        Comm.notifySyncComplete(errorMessage);
        // $.am.debug("[!] SYNC DONE");
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
