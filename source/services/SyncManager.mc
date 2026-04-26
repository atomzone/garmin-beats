using Toybox.Application as App;
using Toybox.Media as Media;
using Toybox.Communications as Comm;
using Toybox.System as Sys;
import Toybox.Lang;

class SyncManager extends Comm.SyncDelegate {

    private var _mQueue as Array<AudioResource>;

    function initialize() {
        Comm.SyncDelegate.initialize();

        var resources = StorageManager.getArray("SYNC") as Array<AudioResourceType>;
        _mQueue = buildResources(resources);
    }

    function isSyncNeeded() as Boolean {
        return _mQueue.size() > 0;
    }

    function onStartSync() {
        $.am.debug("[!] SYNC START");
        downloadNext();
    }

    function onStopSync() as Void {
        $.am.debug("[!] SYNC STOP");
        StorageManager.delete("SYNC");
        Comm.notifySyncComplete(null);
        $.am.debug("[!] SYNC DONE");
    }

    function downloadNext() as Void {

        if (_mQueue.size() == 0) {
            onStopSync();
            return;
        }

        var track = _mQueue[0];
        var context = { :track => track };
        var request = new HttpRequest({ 
            :href => track.getSourceUrl(),
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
        context as { :track as AudioResource }
    ) as Void {
        $.am.debug("[D]\t" + data);
        $.am.debug("[C]\t" + context);

        var refId = (data as Media.ContentRef).getId();
        $.am.debug("[R]\t" + refId);

        // build and store track
        var track = new Track(
            refId,
            refId.toString(),
            (context[:track] as AudioResource).getSourceUrl(),
            "Unknown Title"
        );

        var stored = StorageManager.getOrDefault("TRACKS", []) as Array<TrackRecord>;
        stored.add(track.serialize());
        StorageManager.set("TRACKS", stored as App.Storage.ValueType);
        
        // remove track from from queue; (on sucess, we need also on fail....)
        _mQueue.remove(context[:track]);
        downloadNext();
    }

}
