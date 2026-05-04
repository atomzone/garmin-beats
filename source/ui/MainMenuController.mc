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

        if (id == :NowPlaying) {
            // launch now playing view
            // hide if no track is playing
        } else if (id == :ContinueListening) {
            // resume unfinished tracks
            // hide if no unfinished tracks
        } else if (id == :PlayAll) {

            // launch playback of all tracks
            var assets = AudioAsset.getCachedAssets();
            var payload = buildPayloadStateFromAssets(assets, "library", 0);
            Media.startPlayback(payload as App.PersistableType);

        } else if (id == :Library) {
            // fetch the cached media ids
            // and detirmine which menu items need removeing
            // then pass this into the view & controller

            var view = new $.Rez.Menus.LibraryMenu();
            Ui.pushView(view, new LibraryController(), self.transition);
        } else if (id == :GetTracks) {
            // fetch from API and present options to download

            var loader = new AudioResourceLoader("https://atomzone.github.io/static/tracks.json");
            loader.fetchResources(method(:displayResources));
        } else if (id == :Settings) {
            Ui.pushView(new $.Rez.Menus.SettingsMenu(), new $.SettingsMenuController(), self.transition);
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