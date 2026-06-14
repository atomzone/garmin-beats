using Toybox.WatchUi as Ui;
import Toybox.Lang;

class MainMenuView extends $.Rez.Menus.MainMenu {

    private var _state as AppState;
    private var _revision as String;
    private var _menuItems as Array<Ui.MenuItem> = [];

    function initialize(state as AppState) {
        $.Rez.Menus.MainMenu.initialize();

        _state = state;
        _revision = _state.getRevision();
        
        // Clarify the use of...
        MenuUtils.deleteMenuItem(self, :NowPlaying);
        MenuUtils.deleteMenuItem(self, :ContinueListening);

        // cache menu items (for restore)
        _menuItems = MenuUtils.getMenuItems(self);
    }

    public function onShow() as Void {

        if (_state.hasMedia()) {

            // Did the state change after initialization?
            if (!_revision.equals(_state.getRevision())) {
                MenuUtils.setMenuItems(self, _menuItems);
            }

            return;
        }

        MenuUtils.deleteMenuItem(self, :PlayAll);
        MenuUtils.deleteMenuItem(self, :Library);
    }
}
