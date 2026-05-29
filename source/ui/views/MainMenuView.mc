import Toybox.Lang;

class MainMenuView extends $.Rez.Menus.MainMenu {

    // lets dynamically set the visibility
    // lets extend the store to have an index for number of tracks
    // also refactor to to create a delete all (for storage cleanup)
    function initialize() {
        $.Rez.Menus.MainMenu.initialize();

        // Clarify the use of...
        MenuUtils.deleteMenuItem(self, :NowPlaying);
        MenuUtils.deleteMenuItem(self, :ContinueListening);
    }

    // rebuild menu items is not a suitable approach
    // best have multple menu types OR build dynamically
    public function onShow() as Void {
        // Hide library if no cached assets
        // Can we use application state to trigger these updates?

        // $.Rez.Menus.MainMenu.initialize();

        // TODO: NEW SCHOOL COOL
        // var storage = new IndexedStore("TRACK");
        // var hasAssets = storage.count() > 0;

        // if (!hasAssets) {
            // MenuUtils.deleteMenuItem(self, :PlayAll);
            // MenuUtils.deleteMenuItem(self, :Library);
        // }
    }
}
