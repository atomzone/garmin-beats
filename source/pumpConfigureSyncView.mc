import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Media;
import Toybox.WatchUi;

// This is the View that is used to configure the songs
// to sync. New pages may be pushed as needed to complete
// the configuration.
// ****
// MAYBE THIS VIEW NEEDS TWO MODES (?)
// - BROWSE TRACKS ON DEVICE
// - SYNC TRACKS FROM EXTERNAL SOURCE
// ****
class pumpConfigureSyncView extends WatchUi.View {
    var handler as FileHandler;
    var assets as Array<AudioAsset> = [];
    var resources as Array<File> = [];

    function initialize() {
        View.initialize();

        // stuff from disk
        self.assets = getAudioAssets();
        // stuff from resource provider (e.g. Plex)
        self.resources = getAudioResources();

        // **
        // if the asset contains ref to the original source
        // then we could consider these related
        // **

        // combine these are resouces could have been converted to assets
        self.handler = new FileHandler(getAudioResources());
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.ConfigureSyncLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        var menu = new WatchUi.CheckboxMenu({:title => "Rez.Strings.syncMenuTitle"});
        var keys = self.handler.getKeys();
        
        for (var index = 0; index < self.assets.size(); ++index) {
            var asset = self.assets[index];
            var item = new WatchUi.CheckboxMenuItem(
                asset.getTitle(),
                asset.getResourceId(),
                asset[:refId],
                true,
                null
            );
            menu.addItem(item);
        }

        // for (var index = 0; index < self.resources.size(); ++index) {
        //     var file = self.resources[index];
        //     var item = new WatchUi.CheckboxMenuItem(
        //         file[:name],
        //         null,
        //         file[:id],
        //         true,
        //         null
        //     );
        //     menu.addItem(item);
        // }

        for (var index = 0; index < keys.size(); ++index) {
            var file = handler.getById(keys[index]);
            var item = new WatchUi.CheckboxMenuItem(
                file[:name],
                file[:id], // file[:href],
                file[:id],
                file[:is_on_device],
                null
            );
            menu.addItem(item);
        }

        WatchUi.pushView(menu, new pumpConfigureSyncMenuDelegate(self.handler), WatchUi.SLIDE_IMMEDIATE);
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }
}
