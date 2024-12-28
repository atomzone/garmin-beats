import Toybox.Communications;
import Toybox.Lang;

class pumpSyncDelegate extends Communications.SyncDelegate {

    function initialize() {
        SyncDelegate.initialize();
    }

    // Called when the system starts a sync of the app.
    // The app should begin to download songs chosen in the configure
    // sync view .
    function onStartSync() as Void {
        // GET SESSION/SERVER GLOBAL VARS....
        System.println(Application.Storage.getValue("ACTION"));
        System.println(Application.Storage.getValue("KEYS"));
        System.println(Application.Storage.getValue("VALUES"));

        Communications.notifySyncComplete(null);
    }

    // Called by the system to determine if the app needs to be synced.
    function isSyncNeeded() as Boolean {
        System.println("SYNC CHECK");

        // GET SESSION/SERVER GLOBAL VARS....
        System.println(Application.Storage.getValue("ACTION"));
        System.println(Application.Storage.getValue("KEYS"));
        System.println(Application.Storage.getValue("VALUES"));

        // return Application.Storage.getValue("VALUES").size() > 0 ? true : false;
        return false;
    }

    // Called when the user chooses to cancel an active sync.
    function onStopSync() as Void {
        Communications.cancelAllRequests();
        Communications.notifySyncComplete(null);
    }
}
