using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Communications as Comm;
import Toybox.Lang;

class ResourceInputController extends Ui.Menu2InputDelegate {
    private var _enabled as Array<AudioResource> = [];
    private var _resources as Array<AudioResource>;

    function initialize(resources as Array<AudioResource>) {
        Ui.Menu2InputDelegate.initialize();
        self._resources = resources;
    }

    function onDone() as Void {
        if (self._enabled.size() == 0) {
            Ui.popView(Ui.SLIDE_IMMEDIATE);
            return;
        }

        var serialized = [];
        for (var i = 0, limit = _enabled.size(); i < limit; i++) {
            serialized.add(_enabled[i].serialize());
        }

        var playlist = new PlaylistResource({
            "title" => "Dynamic playlist from resources",
            "tracks" => serialized
        });

        // Single chokepoint: SyncStateStore owns the SYNC key and
        // invalidates the planner cache for us.
        SyncStateStore.setRemote([playlist.serialize()]);
        Communications.startSync2({
            :message => "Start the fans, please!",
        });
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var id = item.getId() as Number;

        if ((item as Ui.CheckboxMenuItem).isChecked()) {
            self._enabled.add(self._resources[id]);
        } else {
            self._enabled.remove(self._resources[id]);
        }
    }
}
