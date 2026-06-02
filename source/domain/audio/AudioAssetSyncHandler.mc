import Toybox.Lang;

class AudioAssetSyncHandler extends SyncTransactionHandler {

    private var _storage as IndexedStore;

    function initialize() {
        SyncTransactionHandler.initialize();
        _storage = new IndexedStore("TRACK");
    }

    function execute(transaction as QueueTransactionType) as String {
        var id = transaction["tid"];
        var operation = transaction["op"];

        if (id == null || operation == null) {
            return "FAILED";
        }

        if (operation.equals("CREATE")) {
            var payload = transaction["payload"] as Dictionary;

            var asset = new AudioAsset({
                "id" => id,
                "mediaId" => payload["mediaId"] as String,
                "metadata" => payload["metadata"] as AudioMetadataType
            } as AudioAssetType);

            $.am.debug("[AudioAssetSyncHandler.execute][" + operation 
                + "][AudioAsset] :: targetId='" + id + "', data='" + asset.serialize() + "'");

            _storage.set(id, asset.serialize());
        }

        if (operation.equals("DELETE")) {
            _storage.delete(id);
        }

        return "COMPLETE";
    }
}

// using Toybox.Media as Media;
// import Toybox.Lang;

// class AudioResourceSyncHandler extends TransactionAsyncHandler {

//     private var _onProgress as Method(Number) as Void;

//     function initialize(
//         onComplete as Method(Boolean) as Void, 
//         onProgress as Method(Number) as Void
//     ) {
//         TransactionAsyncHandler.initialize(onComplete);
//         _onProgress = onProgress;
//     }

//     function execute(transaction as QueueTransactionType) as String {
//         var payload = transaction["payload"] as AudioResourceType;
//         var audioResource = new AudioResource(payload);

//         var context = { :track => audioResource };
//         var request = new HttpRequest({
//             :href => audioResource.getSourceUrl(),
//             :parameters => {}
//         }, method(:onResponse));

//         request.downloadMp3(context, method(:onProgress));

//         return "PENDING";
//     }

//     // TODO: relocate to a more general async ui layer....
//     //
//     // function onWifiCheckComplete(result as {
//     //     :wifiAvailable as Boolean,
//     //     :errorCode as Comm.WifiConnectionStatus
//     // }) as Void {
//     //     if (result[:wifiAvailable] != true) {
//     //         stopSync("WiFi unavailable: " + result[:errorCode]);
//     //         return;
//     //     }
//     // }

//     function onProgress(totalBytesTransferred as Number, filesize as Number?) as Void {
//         var percentageComplete = 0;

//         if (filesize != null && filesize > 0) {
//             percentageComplete = ((totalBytesTransferred.toDouble() / filesize.toDouble()) * 100).toNumber();
//         }

//         // TODO: consider reducing notifications involkes
//         _onProgress.invoke(percentageComplete);
//     }

//     function onResponse(
//         response as ResponseType,
//         context as { :track as AudioResource }
//     ) as Void {
//         var data = response[:data];
//         var track = context[:track] as AudioResource;

//         // TODO: can we remove instanceOd check?
//         if (response[:ok] != true || !(data instanceof Media.ContentRef)) {
//             fail();
//             return;
//         }

//         var refId = data.getId() as Number;
//         $.am.debug("[sync.onResponse] stored refId=" + refId + " url=" + track.getSourceUrl());
//         var asset = new AudioAsset(refId);
//         var content = asset.getContent();
//         var metadata = buildAssetMetadata(track, content);
//         asset.saveAndApplyMetadata(content, metadata);

//         // persist track checksum 
//         // for compare on future syncs
//         // TODO: migrate from getLogicalId -> getId or getUniqueId
//         SyncStateStore.setTrack(track.getLogicalId(), track.getChecksum());

//         success();
//     }

//     private function buildAssetMetadata(track as AudioResource, content as Media.Content?) as AssetMeta {
//         var title = track.getTitle();
//         var artist = track.getArtist();
//         var album = track.getAlbum();

//         if (content != null) {
//             var mediaMetadata = content.getMetadata();

//             if (mediaMetadata != null) {
//                 title = StringUtils.hasText(mediaMetadata.title) ? mediaMetadata.title : title;
//                 artist = StringUtils.hasText(mediaMetadata.artist) ? mediaMetadata.artist : artist;
//                 album = StringUtils.hasText(mediaMetadata.album) ? mediaMetadata.album : album;
//             }
//         }

//         return {
//             "title" => StringUtils.stringOrDefault(title, "Unknown"),
//             "artist" => StringUtils.stringOrDefault(artist, "Unknown"),
//             "album" => StringUtils.stringOrDefault(album, "Unknown"),
//             "sourceUrl" => track.getSourceUrl(),
//             "logicalId" => AudioAsset.logicalIdFromUrl(track.getSourceUrl()),
//             "syncedAt" => null,
//             "thumbsUp" => false
//         } as AssetMeta;
//     }
// }
