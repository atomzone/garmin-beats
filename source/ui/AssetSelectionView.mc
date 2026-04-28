using Toybox.WatchUi as Ui;

import Toybox.Lang;

class AssetSelectionView extends Ui.CheckboxMenu {

    function initialize(assets as Array<AudioAsset>) {
        Ui.CheckboxMenu.initialize({ :title => "Select Tracks" });

        for (var index = 0, limit = assets.size(); index < limit; index++) {
            var asset = assets[index];
            var meta = asset.load();
            var title = meta["title"] != null ? meta["title"] : "Unknown";

            addItem(new Ui.CheckboxMenuItem(
                title as String,
                null,
                index,
                false,
                {}
            ));
        }
    }
}