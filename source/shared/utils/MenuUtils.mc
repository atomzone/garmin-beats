using Toybox.WatchUi as Ui;
import Toybox.Lang;

class MenuUtils {

    static function deleteMenuItem(menu as Ui.Menu2, id as Symbol) as Void {
        var index = menu.findItemById(id);

        if (index > -1) {
            menu.deleteItem(index);
        }
    }

    static function setMenuItemLabel(menu as Ui.Menu2, id as Symbol, label as String) as Void {
        var index = menu.findItemById(id);

        if (index < 0) {
            return;
        }

        var item = menu.getItem(index) as Ui.MenuItem;

        item.setLabel(label);
        menu.updateItem(item, index);
    }
}

