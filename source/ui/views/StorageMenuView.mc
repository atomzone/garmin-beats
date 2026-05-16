using Toybox.WatchUi as Ui;
import Toybox.Lang;

class StorageMenuView extends $.Rez.Menus.StorageMenu {

    private var _assetRepo as AssetRepository;

    function initialize(assetRepo as AssetRepository) {
        $.Rez.Menus.StorageMenu.initialize();

        _assetRepo = assetRepo;
    }

    function onShow() as Void {
        if (_assetRepo.size() == 0) {
            MenuUtils.deleteMenuItem(self, :Delete);
            return;
        }
        
        MenuUtils.setMenuItemLabel(
            self, :Delete, format($.Rez.Strings.DeleteLabel.toString(), [_assetRepo.size()])
        );
    }
}
