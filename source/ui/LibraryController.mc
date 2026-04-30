using Toybox.WatchUi as Ui;

import Toybox.Lang;

class LibraryController extends Ui.Menu2InputDelegate {
    private var transition as Ui.SlideType = Ui.SLIDE_IMMEDIATE;

    function initialize() {
        Ui.Menu2InputDelegate.initialize();
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var id = item.getId();

        if (id == :AllTracks) {
            var refIds = AudioAsset.getCachedAssetRefIds();
            var assets = AudioAsset.fromRefIds(refIds);
            
            Ui.pushView(
                new AssetSelectionView(assets),
                new AssetSelectionController(assets),
                self.transition
            );
        } else if (id == :Artists) {
            //
        } else if (id == :Liked) {
            //
        }
    }
}

