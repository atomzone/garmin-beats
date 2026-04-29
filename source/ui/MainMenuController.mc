using Toybox.WatchUi as Ui;

class MainMenuController extends Ui.Menu2InputDelegate {

    function initialize() {
        Ui.Menu2InputDelegate.initialize();
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var id = item.getId();

        if (id == :NowPlaying) {
            
        } else if (id == :ContinueListening) {
            
        } else if (id == :Library) {
            Ui.pushView(new $.Rez.Menus.LibraryMenu(), new Menu2InputDelegate(), Ui.SLIDE_IMMEDIATE);
        } else if (id == :GetTracks) {
            
        } else if (id == :Settings) {
            Ui.pushView(new $.Rez.Menus.SettingsMenu(), new $.SettingsMenuController(), Ui.SLIDE_IMMEDIATE);
        }
    }
}