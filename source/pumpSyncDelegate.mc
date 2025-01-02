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
        System.println("[START] ONRECEIVE!");
        System.println(responseCode);
        System.println(media);
        System.println(context);

        if (responseCode != 200) {
            System.println("ONRECEIVE FAILED " + responseCode);
            return;
        }

        var contentType = (media as Media.ContentRef).getContentType();
        var refId = (media as Media.ContentRef).getId();

        System.println("**** MEDIA CONTENT REF ****!");
        System.println(contentType);
        System.println(refId);

        // persist to storage
        self.songStore.put(refId, context);

        // ALL SONGS
        System.println(self.songStore.getAll());

        // here we should let Audio file have some additional context
        var file = new AudioFile(refId);
        file.setMetadata();

        // READ METADATA (HOW TO SET??)
        var metaData = file.getContent().getMetadata();
        System.println(metaData.album);
        System.println(metaData.artist);
        System.println(metaData.genre);
        System.println(metaData.title);
        System.println(metaData.trackNumber);

        // REMOVE/UPDATE FROM SYNC STORAGE
        // USES CONTEXT-ID (CONFUSING RIGHT!)
        self.syncStore.delete(context["ID"]);

        Communications.notifySyncComplete(null);

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
