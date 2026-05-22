import Toybox.Lang;

class QueueProcessor {

    private var _queue as Array<QueueTransactionType>;

    private var _onProgress as Method(Number) as Void;
    private var _onComplete as Method(String) as Void;

    private var _cancelled as Boolean = false;
    private var _processed as Number = 0;
    private var _total as Number = 0;

    function initialize(
        queue as Array<QueueTransactionType>,
        onProgress as Method(Number) as Void,
        onComplete as Method(String) as Void
    ) {
        _queue = queue;
        _onProgress = onProgress;
        _onComplete = onComplete;

        _total = queue.size();
    }

    function start() as Void {
        _processNext();
    }

    function stop() as Void {
        _cancelled = true;
    }

    function _processNext() as Void {
        if (_cancelled) {
            return;
        }

        if (_queue.size() == 0) {
            _onComplete.invoke(null);
            return;
        }

        var task = _queue[0];
        var op = task["op"];
        var entity = task["entity"];
        var payload = task["payload"];

        $.am.debug("task " + task);
        $.am.debug("op " + op);
        $.am.debug("entity " + entity);
        $.am.debug("payload " + payload);

        completeCurrent();

/*
        //
        // TRACK DOWNLOAD
        //

        if (
            entity == "TRACK"
            && op == "DOWNLOAD"
        ) {

            var track =
                new AudioResource(payload);

            _downloadTrack(track);

            return;
        }

        //
        // PLAYLIST SAVE
        //

        if (
            entity == "PLAYLIST"
            && op == "SAVE"
        ) {

            var playlist =
                new PlaylistResource(payload);

            PlaylistStore.save(playlist);

            _completeCurrent();
            return;
        }

        //
        // UNKNOWN
        //

        _fail("Unknown operation");

        */
    }

/*
    //
    // ASYNC DOWNLOAD
    //

    function _downloadTrack(
        track as AudioResource
    ) {

        TrackDownloader.download(
            track,
            method(:_onTrackDownloaded)
        );
    }

    //
    // DOWNLOAD CALLBACK
    //

    function _onTrackDownloaded(result) {

        if (_cancelled) {
            return;
        }

        if (result == null) {
            _fail("Download failed");
            return;
        }

        var tx = _queue[0];
        var payload = tx["payload"];

        var track =
            new AudioResource(payload);

        AssetIndex.markDownloaded(
            track.getLogicalId()
        );

        _completeCurrent();
    }
*/

    function completeCurrent() as Void {

        // remove task from queue
        _queue.remove(_queue[0]);

        // persist change
        QueueStore.save(_queue);

        _processed++;

        // notify progress
        var percentageComplete = (_processed * 100 + _total / 2) / _total;
        _onProgress.invoke(percentageComplete);

        // next please
        _processNext();
    }

    function fail(error as String) as Void {
        _onComplete.invoke(error);
    }
}
