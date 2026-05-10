using Toybox.WatchUi as Ui;

class SettingsMenuController extends Ui.Menu2InputDelegate {

    function initialize() {
        Ui.Menu2InputDelegate.initialize();
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var id = item.getId();

        if (id == :Playback) {
            // (speed, quality, autoplay)
        } else if (id == :Storage) {
            Ui.pushView(new $.Rez.Menus.StorageMenu(), new Ui.Menu2InputDelegate(), Ui.SLIDE_IMMEDIATE);
        } else if (id == :Donate) {
            // triggers browser to open to donation page

            var assets = AudioAsset.getCachedAssets();
            for (var i = 0, limit = assets.size(); i < limit; i++) {
                assets[i].delete();
            }
            $.am.debug("[SettingsMenuController] Cleared " + assets.size() + " cached audio + assets");
        }
    }
}