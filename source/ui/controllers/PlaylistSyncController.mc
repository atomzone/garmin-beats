using Toybox.Application as App;
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

        var serialized = [];
        for (var i = 0, limit = _enabled.size(); i < limit; i++) {
            var tracks = _enabled[i].getTracks();
            
            for (var ii = 0, max = tracks.size(); ii < max; ii++) {
                serialized.add(tracks[ii].serialize());
            }
        }

        StorageManager.set("SYNC", serialized);
        Communications.startSync2({
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
