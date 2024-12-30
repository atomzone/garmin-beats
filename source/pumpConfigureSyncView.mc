import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Media;
import Toybox.WatchUi;

// WE SHOULD HAVE TWO SOURCES OF FILES
// 1. TRACKS FROM THE FILESYSTEM (AS EXPOSED BY AN API)
// 2. TRACKS ON THE DEVICE (AS TRACKED BY AN APPLICATION VARIABLE)
function getFiles() as FileHandler {
    // GET FILESYSTEM - Application.Storage
    // GET SYNC
    // COMBINE AND RETURN
    return new FileHandler([
        new File("http://192.168.1.222:8000/BBC/Mary_Anne_Hobbs_-_Adam_F_with_the_ICONS_Mix_m0024dwt_original.m4a", {
            :id => "id-1",
            :is_on_device => false,
            :name => "Mary_Anne_Hobbs_-_Adam_F_with_the_ICONS_Mix_m0024dwt_original"
        }),
        new File("http://192.168.1.222:8000/BBC/Radio_1_Dance_Presents_-_Anjunabeats_Above_Beyond_m001ydv7_original.m4a", {
            :id => "id-2",
            :is_on_device => true,
            :name => "Radio_1_Dance_Presents_-_Anjunabeats_Above_Beyond_m001ydv7_original"
        }),
        new File("https://getsamplefiles.com/download/m4a/sample-3.m4a", {
            :id => "id-3",
            :is_on_device => false,
            :name => "Remote Sample"
        })
    ]);
}

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

    function initialize() {
        View.initialize();

        // GET ALL CACHED CONTENT
        var iterator = Media.getContentRefIter({ :contentType => Media.CONTENT_TYPE_AUDIO });

        if (iterator != null) {
            var contentRef = iterator.next();
            while (contentRef != null) {
                // content ref_id
                System.println(contentRef.getId());
                // content
                System.println(Media.getCachedContentObj(contentRef));
                // content metadata
                System.println(Media.getCachedContentObj(contentRef).getMetadata());
                contentRef = iterator.next();
            }
        }

        // var metaData = Media.getCachedContentObj(ref).getMetadata();

        // all songs reported by the internal storage
        var storage = new Storage("SONGS");
        System.println(storage.getAll());

        self.handler = getFiles();
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
        
        for (var index = 0; index < keys.size(); ++index) {
            var file = handler.getById(keys[index]);
            var item = new WatchUi.CheckboxMenuItem(
                file[:name],
                file[:href],
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
