using Toybox.WatchUi as Ui;

class StorageMenuController extends Ui.Menu2InputDelegate {

    function initialize() {
        Ui.Menu2InputDelegate.initialize();
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var id = item.getId();

        if (id == :Delete) {
            var assets = AudioAsset.getCachedAssets();
            var message = Lang.format("Delete Assets? ($1$)", [assets.size()]);

            Ui.pushView(
                new Ui.Confirmation(message),
                new DeleteAssetConfirmation(assets),
                WatchUi.SLIDE_IMMEDIATE
            );

        } else if (id == :Capacity) {

        } 
    }
}