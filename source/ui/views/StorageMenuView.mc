using Toybox.WatchUi as Ui;
import Toybox.Lang;

class StorageMenuView extends $.Rez.Menus.StorageMenu {

    private var _assetRepo as AudioAssetRepositoryOld;
    private var _deleteLabel as String;

    function initialize(assetRepo as AudioAssetRepositoryOld) {
        $.Rez.Menus.StorageMenu.initialize();

        _assetRepo = assetRepo;
        _deleteLabel = Ui.loadResource($.Rez.Strings.DeleteLabel) as String;
    }

    function onShow() as Void {
        if (_assetRepo.size() == 0) {
            MenuUtils.deleteMenuItem(self, :Delete);
            return;
        } 

        MenuUtils.setMenuItemLabel(
            self, :Delete, format(_deleteLabel, [_assetRepo.size()])
        );
    }
}
