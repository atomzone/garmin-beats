using Toybox.WatchUi as Ui;
import Toybox.Lang;

class MainMenuView extends $.Rez.Menus.MainMenu {

    private var _state as AppState;
    private var _revision as Number;
    private var _menuItems as Array<Ui.MenuItem> = [];

    function initialize(state as AppState) {
        $.Rez.Menus.MainMenu.initialize();

        _state = state;
        _revision = _state.getRevision(); // TBC
        
        // Clarify the use of...
        MenuUtils.deleteMenuItem(self, :NowPlaying);
        MenuUtils.deleteMenuItem(self, :ContinueListening);

        // cache menu items (for restore)
        _menuItems = MenuUtils.getMenuItems(self);
    }

    public function onShow() as Void {
        
        // MAYBE THIS IS NOT NEEDED
        // TODO: We only want to do-work, IF! the state has changed!
        if (_state.hasRevisionChanged(_revision)) {
            $.am.debug("** STATE CHANGED ** " + _revision + " != " + _state.getRevision());
        }

        if (_state.hasMedia()) {

            // Could avoid this if we know its the first render!
            MenuUtils.setMenuItems(self, _menuItems);

            return;
        }

        MenuUtils.deleteMenuItem(self, :PlayAll);
        MenuUtils.deleteMenuItem(self, :Library);
    }
}
