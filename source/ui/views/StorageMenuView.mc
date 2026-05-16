using Toybox.WatchUi as Ui;
import Toybox.Lang;

class StorageMenuView extends $.Rez.Menus.StorageMenu {

    private var _assetManager as AssetManager;

    function initialize(assetManager as AssetManager) {
        $.Rez.Menus.StorageMenu.initialize();

        _assetManager = assetManager;
    }

    function onShow() as Void {
        if (_assetManager.size() == 0) {
            MenuUtils.deleteMenuItem(self, :Delete);
            return;
        }
        
        MenuUtils.setMenuItemLabel(
            self, :Delete, format($.Rez.Strings.DeleteLabel.toString(), [_assetManager.size()])
        );
    }
}
