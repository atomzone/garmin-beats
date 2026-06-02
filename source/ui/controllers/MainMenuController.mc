using Toybox.Application as App;
using Toybox.Media as Media;
using Toybox.WatchUi as Ui;
import Toybox.Lang;

class MainMenuController extends Ui.Menu2InputDelegate {

    private var _playlistStore as IndexedStore;
    private var _trackStore as IndexedStore;
    private var _transition as Ui.SlideType = Ui.SLIDE_IMMEDIATE;
    private var _overlay as LoadingOverlayController;

    function initialize() {
        Ui.Menu2InputDelegate.initialize();

        _playlistStore = new IndexedStore("PLAYLIST");
        _trackStore = new IndexedStore("TRACK");
        
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
            Media.startPlayback(null);


        // launch playback of all tracks
        } else if (id == :PlayAll) {
            
            var trackIds = _trackStore.loadIndexIds();

            var playlist = new PlaylistAsset({
                "id" => "pl:nowplaying",
                "metadata" => {
                    "title" => "Now playing",
                    "description" => "- All Tracks -"
                },
                "trackIds" => trackIds
            } as PlaylistAssetType);

            _playlistStore.save(playlist.getId(), playlist.serialize());

            $.am.debug("[NOW PLAYING] id='" + playlist.getId() + "', '" + playlist.serialize() + "'");

            Media.startPlayback(playlist.getId());

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

            var loader = new AudioResourceLoader(getPlaylistUrl());

            _overlay.begin(:GetPlaylists, "Fetching playlists");
            loader.fetchPlaylists(method(:displayPlaylists));

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

    function displayPlaylists(playlists as Array<PlaylistResource>) as Void {
        _overlay.end(:GetPlaylists);
        
        Ui.pushView(
            new PlaylistSyncView(playlists, _playlistStore.loadIndexIds()),
            new PlaylistSyncController(playlists),
            self._transition
        );
    }

    private function getPlaylistUrl() as String {
        try {
            return App.Properties.getValue("playlistSourceUrl") as String;
        } catch (e) {
            return "https://atomzone.github.io/static/playlists.json";
        }
    }
}