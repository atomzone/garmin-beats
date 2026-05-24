using Toybox.WatchUi as Ui;
using Toybox.Communications as Comm;
import Toybox.Lang;

class PlaylistSyncController extends Ui.Menu2InputDelegate {
    private var _enabled as Array<PlaylistResource> = [];
    private var _playlists as Array<PlaylistResource>;

    function initialize(playlists as Array<PlaylistResource>) {
        Ui.Menu2InputDelegate.initialize();
        _playlists = playlists;
    }

    function onDone() as Void {
        if (self._enabled.size() == 0) {
            Ui.popView(Ui.SLIDE_IMMEDIATE);
            return;
        }

        // make queue tasks
        var builder = new SyncQueueBuilder({
            :PLAYLIST => {}, // SyncStateStore.getPlaylistChecksums(),
            :TRACK => {}, // SyncStateStore.getTrackChecksums()
        });
        var queue = builder.buildQueue(_enabled);

        // and store
        SyncQueueStore.save(queue);
        
        // now fans
        Comm.startSync2({
            :message => "Start the fans, please!",
        });
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var id = item.getId() as Number;

        if ((item as Ui.CheckboxMenuItem).isChecked()) {
            _enabled.add(_playlists[id]);
        } else {
            _enabled.remove(_playlists[id]);
        }
    }
}
