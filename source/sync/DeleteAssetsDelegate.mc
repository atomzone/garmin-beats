import Toybox.Lang;
import Toybox.WatchUi;

class DeleteAssetsDelegate extends WatchUi.Menu2InputDelegate {
    private var assets as Array<String> = [];

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    // TODO: Confirmation (Delete YES/NO)
    function onDone() as Void {
        System.println("DeleteAssetsDelegate::onDone()");

        for (var index = 0; index < self.assets.size(); index++) {
            var id = self.assets[index];
            var asset = new AudioAsset(id);
            
            // need to also remove from any playlist referencing this track...
            asset.delete();
            // maybe not needed (as the view is popped & mem-cleaned?)
            self.assets.remove(id);
        }

        // pop the active view
        Menu2InputDelegate.onDone();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as String;

        if ((item as WatchUi.CheckboxMenuItem).isChecked()) {
            self.assets.add(id);
        } else {
            self.assets.remove(id);
        }
    }
}