using Toybox.Application as App;
using Toybox.Media as Media;
using Toybox.WatchUi as Ui;
import Toybox.Lang;

class MainMenuController extends Ui.Menu2InputDelegate {
    private var _transition as Ui.SlideType = Ui.SLIDE_IMMEDIATE;
    private var _overlay as LoadingOverlayController;

    function initialize() {
        Ui.Menu2InputDelegate.initialize();

        _overlay = new LoadingOverlayController(
            new Ui.ProgressBar("Fetching...", null)
        );
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
            var playlist = new Playlist(assets, 0);

            Media.startPlayback(playlist.serialize() as App.PersistableType);

        // push library view
        } else if (id == :Library) {

            Ui.pushView(
                new $.Rez.Menus.LibraryMenu(), 
                new LibraryController(), 
                self._transition
            );

        } 
        // fetch playlist.json and build navigation
        else if (id == :GetPlaylists) {

            var loader = new AudioResourceLoader("https://atomzone.github.io/static/playlists.json");

            _overlay.begin(:GetPlaylists, "Fetching playlists");
            loader.fetchPlaylists(method(:demo));

        // async fetch then push reources view
        } else if (id == :GetTracks) {
            
            var loader = new AudioResourceLoader("https://atomzone.github.io/static/tracks.json");

            _overlay.begin(:GetTracks, "Fetching tracks");
            loader.fetchResources(method(:displayResources));

        // push settings view
        } else if (id == :Settings) {

            Ui.pushView(
                new $.Rez.Menus.SettingsMenu(), 
                new $.SettingsMenuController(), 
                self._transition
            );
        }
    }
    
    function displayResources(resources as Array<AudioResource>) as Void {
        _overlay.end(:GetTracks);
        Ui.pushView(
            new ResourceView(resources),
            new ResourceInputController(resources),
            self._transition
        );
    }

    function demo(playlists as Array<PlaylistResource>) as Void {

        _overlay.end(:GetPlaylists);
        
        // for (var index = 0, limit = playlists.size(); index < limit; index++) {
        //     var playlist = playlists[index];

        //     // $.am.debug("[playlist]canonicalize " + playlist.canonicalize());
        //     $.am.debug("[playlist]getChecksum " + playlist.getKey() + " -  " + playlist.getChecksum());

        //     var tracks = playlist.getTracks();
        //     for (var index2 = 0, limit2 = tracks.size(); index2 < limit2; index2++) {
        //         var track = tracks[index2];

        //         // $.am.debug("[track]canonicalize " + track.canonicalize());
        //         $.am.debug("[track]getChecksum " + track.getChecksum());
        //     }
        // }

        Ui.pushView(
            new PlaylistSyncView(playlists),
            new PlaylistSyncController(playlists),
            self._transition
        );
    }
}