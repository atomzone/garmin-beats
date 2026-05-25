using Toybox.WatchUi as Ui;
import Toybox.Lang;

class StorageMenuView extends $.Rez.Menus.StorageMenu {

    private var _totalTracks as Number;
    private var _deleteLabel as String;

    function initialize(totalTracks as Number) {
        $.Rez.Menus.StorageMenu.initialize();

        _totalTracks = totalTracks;
        _deleteLabel = Ui.loadResource($.Rez.Strings.DeleteLabel) as String;
    }

    function onShow() as Void {
        if (_totalTracks == 0) {
            MenuUtils.deleteMenuItem(self, :Delete);
            return;
        } 

        MenuUtils.setMenuItemLabel(
            self, :Delete, format(_deleteLabel, [_totalTracks])
        );
    }
}
