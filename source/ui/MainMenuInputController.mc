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
            
            StorageManager.set("SYNC", serializeResources([resource]));
            Communications.startSync();

        } else if (id == :play) {

            Sys.println("PLAY");

            // launch it in playback mode
            var refs = AudioAsset.getCachedAssetRefIds();
            Media.startPlayback(refs as App.PersistableType);
        
        } else if (id == :resources) {
            var loader = new AudioResourceLoader("https://atomzone.github.io/static/tracks.json");
            loader.fetchResources(method(:displayResources));
        } else if (id == :selectTracks) {
            var refIds = AudioAsset.getCachedAssetRefIds();
            var assets = AudioAsset.fromRefIds(refIds);
            
            var view = new AssetSelectionView(assets);
            var controller = new AssetSelectionController(assets);

            Ui.pushView(view, controller, Ui.SLIDE_IMMEDIATE);
        } else if (id == :navigation) {
            var menu = new $.Rez.Menus.MainMenu();

            // example of modifying a menu after it's been created but before it's been pushed
            deleteMenuItem(menu, :NowPlaying);
            deleteMenuItem(menu, :ContinueListening);

            Ui.pushView(menu, new $.MainMenuController(), Ui.SLIDE_IMMEDIATE);
        }
    }

    function displayResources(resources as Array<AudioResource>) as Void {
        $.am.debug("dd" + resources);

        var view = new ResourceView(resources);
        var delegate = new ResourceInputController(resources);

        Ui.pushView(view, delegate, Ui.SLIDE_BLINK);
    }

    private function deleteMenuItem(menu as Ui.Menu2, id as Symbol) as Void {
        var index = menu.findItemById(id);
        if (index > -1) {
            menu.deleteItem(index);
        }
    }
}
