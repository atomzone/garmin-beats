import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class File {
    var href as String;
    var id as String;
    var is_on_device as Boolean;
    var name as String;

    function initialize(href as String, options as Dictionary) {
        self.href = href;
        self.id = options[:id];
        self.is_on_device = options[:is_on_device];
        self.name = options[:name];
    }
}

class FileHandler {
    var filelist as Array<File>;

    function initialize(filelist as Array<File>) {
        self.filelist = filelist;
    }

    function getById(id as String) as File? {
        for (var index = 0; index < self.filelist.size(); ++index) {
            var file = self.filelist[index];

            if (id.equals(file[:id])) {
                return file;
            }
        }
        return null;
    }
}

// WE SHOULD HAVE TWO SOURCES OF FILES
// 1. TRACKS FROM THE FILESYSTEM (AS EXPOSED BY AN API)
// 2. TRACKS ON THE DEVICE (AS TRACKED BY AN APPLICATION VARIABLE)
function getFiles() as FileHandler {
    // GET FILESYSTEM
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
        var filelist = self.handler[:filelist];
        var menu = new WatchUi.CheckboxMenu({:title => "Rez.Strings.syncMenuTitle"});

        for (var index = 0; index < filelist.size(); ++index) {
            var file = filelist[index];
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
