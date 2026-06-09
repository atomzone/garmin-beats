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

    static function getMenuItems(menu as Ui.Menu2) as Array<Ui.MenuItem> {
        var index = 0;
        var menuItems = [] as Array<Ui.MenuItem>;

        // while true :')
        while (true) {
            var item = menu.getItem(index);
            if (item == null) {
                break;
            } 
            
            var id = item.getId();
            if (id != null) {
                menuItems.add(item);
            }

            ++index;
        }

        return menuItems;
    }

    static function setMenuItems(menu as Ui.Menu2, items as Array<Ui.MenuItem>) as Ui.Menu2 {
        for (var i = 0, limit = items.size(); i < limit; i++) {
            menu.updateItem(items[i], i);
        }

        return menu;
    }
}

