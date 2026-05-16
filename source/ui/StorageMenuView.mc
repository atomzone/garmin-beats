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
            deleteMenuItem(:Delete);
            return;
        }
        
        formatMenuItemLabel(:Delete, method(:DeleteLabelFormatter));
    }

    function DeleteLabelFormatter(label as String) as String {
        return format(label, [_assetManager.size()]);
    }

    private function deleteMenuItem(id as Symbol) as Void {
        var index = findItemById(id);

        if (index > -1) {
            deleteItem(index);
        }
    }

    private function formatMenuItemLabel(id as Symbol, formatter as Method(label) as String) as Void {
        var index = findItemById(id);

        if (index < 0) {
            return;
        }

        var item = getItem(index) as Ui.MenuItem;
        var message = formatter.invoke(item.getLabel());

        item.setLabel(message);
        updateItem(item, index);
    }
}
