using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Media as Media;
using Toybox.Communications as Comm;
using Toybox.System as Sys;

import Toybox.Lang;

// =====================================================
// SYNC
// =====================================================

class TestSyncDelegate extends Comm.SyncDelegate {

    private var mQueue as Array;

    function initialize() {
        Comm.SyncDelegate.initialize();

        var q = Application.Storage.getValue("SYNC_SELECTION") as Array?;
        mQueue = (q != null) ? q : [];
    }

    function isSyncNeeded() as Boolean {
        return mQueue.size() > 0;
    }

    function onStartSync() {
        $.am.debug("[!] SYNC START");
        downloadNext();
    }

    function onStopSync() as Void {
        $.am.debug("[!] SYNC STOP");
        Application.Storage.deleteValue("SYNC_SELECTION");
        Comm.notifySyncComplete(null);
        $.am.debug("[!] SYNC DONE");
    }

    function downloadNext() {

        if (mQueue.size() == 0) {
            onStopSync();
            return;
        }

        var track = mQueue[0];
        var context = { :track => track };
        var request = new HttpRequest({ 
            :href => track["url"],
            :parameters => {}
        }, method(:onResponse));
      
        $.am.debug("[!] Begin (async) request.download()");
        request.downloadMp3(context, method(:onProgress));
        $.am.debug("[!] End (call) request.download()");
    
        $.am.debug(
            Lang.format("[+]\tTask $1$", [self.hashCode()])
        );
    }

    function onProgress(totalBytesTransferred as Number, filesize as Number?) as Void {
        var percentageComplete = 0;

        if (filesize > 0) {
            percentageComplete = ((totalBytesTransferred.toDouble() / filesize.toDouble()) * 100).toNumber();
        }

        $.am.debug("[+]\tTransferred: " + totalBytesTransferred + " / " + filesize + " (" + percentageComplete + "%)");

        notifySyncProgress(percentageComplete);
    }

    function onResponse(
        data as Dictionary or String or Null, 
        context as { :callback as Method }
    ) as Void {
        $.am.debug("[D]\t" + data);
        $.am.debug("[C]\t" + context);

        var refId = (data as Media.ContentRef).getId();
        $.am.debug("[R]\t" + refId);

        // // here we should let Audio file have some additional context
        // var file = new AudioAsset(refId);

        // // what is this doing?
        // file.setResourceId(context["ID"] as String); 
        // file.setMetadata(); // example of using content to set meta data

        var trackRefs = Application.Storage.getValue("TRACKS") as Array?;
        trackRefs = (trackRefs == null) ? [] : trackRefs;
        trackRefs.add(refId);
        Application.Storage.setValue("TRACKS", trackRefs);
        
        // remove track from from queue; (on sucess, we need also on fail....)
        mQueue.remove(context[:track]);
        downloadNext();
    }

}
