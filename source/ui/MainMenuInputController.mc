using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Media as Media;
using Toybox.Communications as Comm;
using Toybox.System as Sys;
import Toybox.Lang;

class MainMenuInputController extends Ui.Menu2InputDelegate {

    function initialize() {
        Ui.Menu2InputDelegate.initialize();
    }

    function onSelect(item as Ui.MenuItem) {
        var id = item.getId();

        if (id == :download) {
            Sys.println("QUEUE");

            var resource = new AudioResource({
                "source" => {
                    "url" => "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
                }
            });

            Application.Storage.setValue("SYNC_SELECTION", serializeResources([resource]));

            Communications.startSync();

        } else if (id == :play) {

            Sys.println("PLAY");

            // launch it in playback mode
            var storedTracks = Application.Storage.getValue("TRACKS") as App.PersistableType?;
            if (storedTracks == null) { return; }

            // A serializable object to pass to AudioContentProviderApp.getContentDelegate() when the app starts in playback mode
            Media.startPlayback(storedTracks);
        
        } else if (id == :resources) {
            var loader = new AudioResourceLoader("https://atomzone.github.io/static/tracks.json");
            loader.fetchResources(method(:displayResources));
        }
    }

    function displayResources(resources as Array<AudioResource>) as Void {
        $.am.debug("dd" + resources);

        var view = new ResourceView(resources);
        var delegate = new ResourceInputController(resources);

        Ui.pushView(view, delegate, Ui.SLIDE_BLINK);
    }
}
