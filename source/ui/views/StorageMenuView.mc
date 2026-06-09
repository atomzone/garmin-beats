using Toybox.WatchUi as Ui;
import Toybox.Lang;

class StorageMenuView extends $.Rez.Menus.StorageMenu {

    private var _state as AppState;
    private var _deleteLabel as String;

    function initialize(state as AppState) {
        $.Rez.Menus.StorageMenu.initialize();

        _state = state;
        _deleteLabel = Ui.loadResource($.Rez.Strings.DeleteLabel) as String;
    }

    function onShow() as Void {
        var trackCount = _state.getTrackCount();

        if (trackCount == 0) {
            MenuUtils.deleteMenuItem(self, :Delete);
            return;
        } 

        MenuUtils.setMenuItemLabel(
            self, :Delete, format(_deleteLabel, [trackCount])
        );
    }
}
