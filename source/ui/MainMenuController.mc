using Toybox.Application as App;
using Toybox.WatchUi as Ui;

import Toybox.Lang;

class MainMenuController extends Ui.Menu2InputDelegate {
    private var transition as Ui.SlideType = Ui.SLIDE_IMMEDIATE;

    function initialize() {
        Ui.Menu2InputDelegate.initialize();
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var id = item.getId();

        // launch now playing view
        if (id == :NowPlaying) {


        // resume unfinished tracks
        } else if (id == :ContinueListening) {


        // launch playback of all tracks
        } else if (id == :PlayAll) {

            var assets = AudioAsset.getCachedAssets();
            var payload = buildPayloadStateFromAssets(assets, "library", 0);

            Media.startPlayback(payload as App.PersistableType);

        // push library view
        } else if (id == :Library) {

            Ui.pushView(
                new $.Rez.Menus.LibraryMenu(), 
                new LibraryController(), 
                self.transition
            );

        // async fetch then push reources view
        } else if (id == :GetTracks) {
            
            var loader = new AudioResourceLoader("https://atomzone.github.io/static/tracks.json");

            loader.fetchResources(method(:displayResources));

        // push settings view
        } else if (id == :Settings) {

            Ui.pushView(
                new $.Rez.Menus.SettingsMenu(), 
                new $.SettingsMenuController(), 
                self.transition
            );
        }
    }
    
    function displayResources(resources as Array<AudioResource>) as Void {
        Ui.pushView(
            new ResourceView(resources),
            new ResourceInputController(resources),
            self.transition
        );
    }
}