using Toybox.WatchUi as Ui;

class SettingsMenuController extends Ui.Menu2InputDelegate {

    function initialize() {
        Ui.Menu2InputDelegate.initialize();
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var id = item.getId();

        if (id == :Playback) {
            
        } else if (id == :Storage) {
            Ui.pushView(new $.Rez.Menus.StorageMenu(), new Menu2InputDelegate(), Ui.SLIDE_IMMEDIATE);            
        } else if (id == :Donate) {

        }
    }
}