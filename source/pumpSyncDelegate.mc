import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.Media;
// import Toybox.PersistedContent;

class pumpSyncDelegate extends Communications.SyncDelegate {
    var syncStore as StorageManager = new StorageManager("SYNC");

    // this is called EVERYTIME startSync IS FIRED!
    // what does this mean for memory?
    function initialize() {
        System.println("WHY IS THIS CALLED TWICE?");
        SyncDelegate.initialize();
    }

    function onWifiCheck(result as { :wifiAvailable as Boolean, :errorCode as Communications.WifiConnectionStatus }) as Void {
        System.println(result[:wifiAvailable]);
        System.println(result[:errorCode]);
    }

    // Called when the system starts a sync of the app.
    // The app should begin to download songs chosen in the configure
    // sync view .
    function onStartSync() as Void {
        System.println("onStartSync");

        Communications.checkWifiConnection(method(:onWifiCheck));

        var resourceData = self.syncStore.get("audio") as Array?;

        if (resourceData == null) {
            return;
        }

        System.println(resourceData);

        var taskQueue = new CommunicationsQueue();
        for (var index = 0; index < resourceData.size(); index++) {
            // TODO: better serialse/deserialise please
            var data = resourceData[index];
            var audioResource = new AudioResource(
                data["href"] as String, 
                { :id => data["id"] as String }
            );

            taskQueue.add(new DownloadAudioTask(audioResource));
        }

        taskQueue.start();
    }

    
    function onProgress(totalBytesTransferred as Number, fileSize as Number or Null) as Void { }

    function onReceive(responseCode as Number, media as Dictionary?, context as Dictionary) as Void { }

    // Called by the system to determine if the app needs to be synced.
    function isSyncNeeded() as Boolean {
        // TODO: CHECK FOR A MORE ACCURATE PENDING SYNC
        System.println("IS SYNC NEEDED? " + !self.syncStore.isEmpty());

        return !self.syncStore.isEmpty();
    }

    // Called when the user chooses to cancel an active sync.
    // TODO: STOP THE `taskQueue` PROCESSING...
    function onStopSync() as Void {
        System.println("[+]\tonStopSync");
        Communications.cancelAllRequests();
        Communications.notifySyncComplete(null);
    }
}
