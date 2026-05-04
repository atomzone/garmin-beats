using Toybox.WatchUi as Ui;

import Toybox.Lang;

class AssetSelectionView extends Ui.CheckboxMenu {

    function initialize(assets as Array<AudioAsset>) {
        Ui.CheckboxMenu.initialize({ :title => "Select Tracks" });

        for (var index = 0, limit = assets.size(); index < limit; index++) {
            var asset = assets[index];
            var meta = asset.load();

            addItem(new Ui.CheckboxMenuItem(
                meta["title"] as String,
                meta["artist"],
                index,
                false,
                {}
            ));
        }
    }
}