import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.Media;
// import Toybox.PersistedContent;

class pumpSyncDelegate extends Communications.SyncDelegate {
    var syncStore = new Storage("SYNC");
    var songStore = new Storage("SONGS");

    function initialize() {
        SyncDelegate.initialize();
    }

    // Called when the system starts a sync of the app.
    // The app should begin to download songs chosen in the configure
    // sync view .
    function onStartSync() as Void {
        System.println("onStartSync");

        System.println(syncStore.getAll());
        
        var list = syncStore.getAll() as Array<File>;

        System.println(list);
        System.println(list.size());

        var records = syncStore.getAll() as Dictionary;
        var keys = records.keys();

        for (var index = 0; index < keys.size(); ++index) {
            var key = keys[index];
            var url = records[key]["href"];
            var id = records[key]["id"];

            var context = {
                "ID" => id,
                "URL" => url
            };
            var options = {
                :context => context,
                :fileDownloadProgressCallback => method(:onProgress),
                :mediaEncoding => Media.ENCODING_M4A,
                :method => Communications.HTTP_REQUEST_METHOD_GET,
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO
            };

            // var delegate = new RequestDelegate(method(:onSongDownloaded), context);  
            // delegate.makeWebRequest(mSyncList[ids[0]][SongInfo.URL], null, options);
            // Communications.makeWebRequest(url, {}, {}, self.method(:onReceive));

            Communications.makeWebRequest(url, {}, options, method(:onReceive));
            Communications.notifySyncProgress(25);
        }
    }

    function onProgress(totalBytesTransferred as Number, fileSize as Number or Null) as Void {
        System.println("[+] BYTES RECEIVED");
        System.println(totalBytesTransferred);
        System.println(fileSize);

        Communications.notifySyncProgress(75);
    }

    function onReceive(responseCode as Number, media as Dictionary, context as Dictionary) as Void {
        if (responseCode != 200) {
            System.println("ONRECEIVE FAILED " + responseCode);
            return;
        }

        var contentType = (media as Media.ContentRef).getContentType();
        var refId = (media as Media.ContentRef).getId();

        System.println("[START] ONRECEIVE!");
        System.println(responseCode);
        System.println(media);
        System.println("**** MEDIA CONTENT REF ****!");
        System.println(contentType);
        System.println(refId);
        System.println("**** CONTEXT ****!");
        System.println(context);

        self.songStore.put(refId, context);
        System.println(self.songStore.getAll());

        // RETRIEVE MEDIA FROM ITS REFID
        var ref = new Media.ContentRef(refId, contentType);

        // MEDIA METADATA (SHOULD BE USED AS INTERNAL AUDIO FORMAT)
        var tom = new ContentMetadata();
        tom.album = "ALBUM";
        tom.artist = "ARTIST";
        tom.title = "TOM";
        Media.getCachedContentObj(ref).setMetadata(tom);

        var metaData = Media.getCachedContentObj(ref).getMetadata();

        // READ METADATA (HOW TO SET??)
        System.println(metaData.album);
        System.println(metaData.artist);
        System.println(metaData.genre);
        System.println(metaData.title);
        System.println(metaData.trackNumber);

        Communications.notifySyncComplete(null);

        // REMOVE/UPDATE FROM SYNC STORAGE
        // USES CONTEXT-ID (CONFUSING RIGHT!)
        self.syncStore.delete(context["ID"]);

        System.println("[END] ONRECEIVE!");        
    }

    // Called by the system to determine if the app needs to be synced.
    function isSyncNeeded() as Boolean {
        return !self.syncStore.isEmpty();
    }

    // Called when the user chooses to cancel an active sync.
    function onStopSync() as Void {
        Communications.cancelAllRequests();
        Communications.notifySyncComplete(null);
    }
}
