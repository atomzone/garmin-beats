using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Media as Media;
using Toybox.Communications as Comm;
using Toybox.System as Sys;

import Toybox.Lang;

class MainMenuView extends Ui.Menu2 {

    function initialize() {
        Ui.Menu2.initialize({:title => "Test ACP"});

        addItem(new Ui.MenuItem("Navigation", null, :navigation, {}));

        addItem(new Ui.MenuItem("Download Track", "description", :download, {}));
        addItem(new Ui.MenuItem("Play", null, :play, {}));
        addItem(new Ui.MenuItem("Select Tracks", null, :selectTracks, {}));
        addItem(new Ui.MenuItem("Resources", null, :resources, {}));
    }
}
