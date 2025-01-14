import Toybox.Lang;
import Toybox.WatchUi;

class DeleteAssetsDelegate extends WatchUi.Menu2InputDelegate {
    private var assetIds as Array<String> = [];

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onDone() as Void {
        if (self.assetIds.size() == 0) {
            Menu2InputDelegate.onDone();
            return;
        }

        var message = Lang.format("Delete Assets? ($1$)", [self.assetIds.size()]);

        WatchUi.switchToView(
            new WatchUi.Confirmation(message),
            new DeleteAssetConfirmation(self.assetIds),
            WatchUi.SLIDE_IMMEDIATE
        );
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as String;

        if ((item as WatchUi.CheckboxMenuItem).isChecked()) {
            self.assetIds.add(id);
        } else {
            self.assetIds.remove(id);
        }
    }
}