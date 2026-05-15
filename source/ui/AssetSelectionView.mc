using Toybox.WatchUi as Ui;
import Toybox.Lang;

class AssetSelectionView extends Ui.CheckboxMenu {

    private var _isClosed as Boolean? = null;

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

    function onShow() as Void {
        $.am.debug("[AssetSelectionView.onShow] isClosed=" + _isClosed);
        
        if (_isClosed == true) {
            Ui.popView(Ui.SLIDE_IMMEDIATE);
            return;
        }

        _isClosed = false;
    }

    function onHide() as Void {
        $.am.debug("[AssetSelectionView.onHide] isClosed=" + _isClosed);
        _isClosed = true;
    }
}