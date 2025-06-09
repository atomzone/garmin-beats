import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.Media;
// import Toybox.PersistedContent;

class pumpSyncDelegate extends Communications.SyncDelegate {
    var progressIndicator as ProgressBarController;
    var queue as CommunicationsQueue;

    // this is called EVERYTIME startSync IS FIRED!
    // what does this mean for memory?
    function initialize(
        queue as CommunicationsQueue,
        progressIndicator as ProgressBarController
    ) {
        SyncDelegate.initialize();
        self.queue = queue;
        self.progressIndicator = progressIndicator;
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
        System.println(self.queue);

        // leave to the task??
        // self.progressIndicator.show();

        self.queue.start();
    }
    
    function onProgress(totalBytesTransferred as Number, fileSize as Number or Null) as Void { }

    function onReceive(responseCode as Number, media as Dictionary?, context as Dictionary) as Void { }

    // Called by the system to determine if the app needs to be synced.
    function isSyncNeeded() as Boolean {
        return self.queue.isEmpty() == false;
    }

    // Called when the user chooses to cancel an active sync.
    // TODO: STOP THE `taskQueue` PROCESSING...
    function onStopSync() as Void {
        System.println("[+]\tonStopSync");
        self.queue.stop();

        // self.progressIndicator.hide();
        // Communications.cancelAllRequests();
        // Communications.notifySyncComplete(null);
    }
}
