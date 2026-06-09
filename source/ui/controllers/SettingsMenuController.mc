using Toybox.WatchUi as Ui;
import Toybox.Lang;

class SettingsMenuController extends Ui.Menu2InputDelegate {

    private var _state as AppState;
    
    function initialize(state as AppState) {
        Ui.Menu2InputDelegate.initialize();

        _state = state;
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var id = item.getId();

        if (id == :Playback) {
            // (speed, quality, autoplay)
        } else if (id == :Storage) {
            Ui.pushView(
                new StorageMenuView(_state),
                new StorageMenuController(_state.getTrackCount()),
                Ui.SLIDE_IMMEDIATE
            );
        } else if (id == :Donate) {
            // triggers browser to open to donation page
        }
    }
}