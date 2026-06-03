using Toybox.WatchUi as Ui;
import Toybox.Lang;

class SettingsMenuController extends Ui.Menu2InputDelegate {

    private var _totalTracks as Number;

    function initialize() {
        Ui.Menu2InputDelegate.initialize();

        var store = new IndexedStore(IndexedStore.TRACK);
        _totalTracks = store.count();
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var id = item.getId();

        if (id == :Playback) {
            // (speed, quality, autoplay)
        } else if (id == :Storage) {
            Ui.pushView(
                new StorageMenuView(_totalTracks),
                new StorageMenuController(_totalTracks),
                Ui.SLIDE_IMMEDIATE
            );
        } else if (id == :Donate) {
            // triggers browser to open to donation page
        }
    }
}