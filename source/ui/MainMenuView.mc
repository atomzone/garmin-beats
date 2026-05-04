using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Media as Media;
using Toybox.Communications as Comm;
using Toybox.System as Sys;

import Toybox.Lang;

class MainMenuView extends $.Rez.Menus.MainMenu {

    // lets dynamically set the visibility
    // lets extend the store to have an index for number of tracks
    // also refactor to to create a delete all (for storage cleanup)
    function initialize() {
        $.Rez.Menus.MainMenu.initialize();

        deleteMenuItem(:NowPlaying);
        deleteMenuItem(:ContinueListening);
    }

    private function deleteMenuItem(id as Symbol) as Void {
        var index = findItemById(id);
        if (index > -1) {
            deleteItem(index);
        }
    }
}
