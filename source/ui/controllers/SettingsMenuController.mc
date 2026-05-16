using Toybox.WatchUi as Ui;

class SettingsMenuController extends Ui.Menu2InputDelegate {

    private var _assetRepo as AssetRepository;

    function initialize() {
        Ui.Menu2InputDelegate.initialize();

        _assetRepo = new AssetRepository();
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var id = item.getId();

        if (id == :Playback) {
            // (speed, quality, autoplay)
        } else if (id == :Storage) {
            Ui.pushView(
                new StorageMenuView(_assetRepo),
                new StorageMenuController(_assetRepo),
                Ui.SLIDE_IMMEDIATE
            );
        } else if (id == :Donate) {
            // triggers browser to open to donation page
        }
    }
}