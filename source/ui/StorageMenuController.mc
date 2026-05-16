using Toybox.WatchUi as Ui;

class StorageMenuController extends Ui.Menu2InputDelegate {

    private var _assetManager as AssetManager;

    function initialize(assetManager as AssetManager) {
        Ui.Menu2InputDelegate.initialize();

        _assetManager = assetManager;
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var id = item.getId();

        if (id == :Delete) {
            var message = Lang.format("Delete Assets? ($1$)", [_assetManager.size()]);

            Ui.pushView(
                new Ui.Confirmation(message),
                new DeleteAssetConfirmation(_assetManager),
                Ui.SLIDE_IMMEDIATE
            );

        } else if (id == :Capacity) {
            // show memory
            // show cached sizes
        } 
    }
}