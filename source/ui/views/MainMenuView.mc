import Toybox.Lang;

class MainMenuView extends $.Rez.Menus.MainMenu {

    // lets dynamically set the visibility
    // lets extend the store to have an index for number of tracks
    // also refactor to to create a delete all (for storage cleanup)
    function initialize() {
        $.Rez.Menus.MainMenu.initialize();

        // Clarify the use of...
        deleteMenuItem(:NowPlaying);
        deleteMenuItem(:ContinueListening);

        // Hide library if no cached assets
        // Can we use application state to trigger these updates?

        // TODO: NEW SCHOOL COOL
        var storage = new KeyValueStorage("TRACK");
        var hasAssets = (storage.getIndexIds().size() > 0);

        if (!hasAssets) {
            deleteMenuItem(:PlayAll);
            deleteMenuItem(:Library);
        }
    }

    private function deleteMenuItem(id as Symbol) as Void {
        var index = findItemById(id);
        if (index > -1) {
            deleteItem(index);
        }
    }
}
