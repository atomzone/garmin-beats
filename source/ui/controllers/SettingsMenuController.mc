using Toybox.WatchUi as Ui;

class SettingsMenuController extends Ui.Menu2InputDelegate {

    private var _assetManager as AssetManager;

    function initialize() {
        Ui.Menu2InputDelegate.initialize();

        _assetManager = new AssetManager();
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var id = item.getId();

        if (id == :Playback) {
            // (speed, quality, autoplay)
        } else if (id == :Storage) {
            Ui.pushView(
                new StorageMenuView(_assetManager), 
                new StorageMenuController(_assetManager), 
                Ui.SLIDE_IMMEDIATE
            );
        } else if (id == :Donate) {
            // triggers browser to open to donation page
        }
    }
}