using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Media as Media;
using Toybox.Communications as Comm;
using Toybox.System as Sys;

class MainMenuView extends Ui.Menu2 {

    function initialize() {
        Ui.Menu2.initialize({:title => "Test ACP"});

        addItem(new Ui.MenuItem("Download Track", null, :download, {}));
        addItem(new Ui.MenuItem("Play", null, :play, {}));
    }
}

class MainMenuDelegate extends Ui.Menu2InputDelegate {

    function initialize() {
        Ui.Menu2InputDelegate.initialize();
    }

    function onSelect(item as Ui.MenuItem) {

        var id = item.getId();

        if (id == :download) {

            Sys.println("QUEUE");

            var queue = [
                {
                    "id" => "1",
                    "name" => "Track",
                    "url" => "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
                }
            ];

            Application.Storage.setValue("SYNC_SELECTION", queue);

            Communications.startSync();

        } else if (id == :play) {

            Sys.println("PLAY");

            // launch it in playback mode
            var storedTracks = Application.Storage.getValue("TRACKS") as App.PersistableType?;
            if (storedTracks == null) { return; }

            // A serializable object to pass to AudioContentProviderApp.getContentDelegate() when the app starts in playback mode
            Media.startPlayback(storedTracks);
        }
    }
}
