import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Media;
import Toybox.WatchUi;

// this returns all the cached content
// would we want to load only 
function getCachedAudioRefIds() as Array<Object> {
    var iterator = Media.getContentRefIter({ :contentType => Media.CONTENT_TYPE_AUDIO });
    var refIds = [];

    if (iterator == null) {
        return refIds;
    }

    var contentRef = iterator.next();
    while (contentRef != null) {
        refIds.add(contentRef.getId());
        contentRef = iterator.next();
    }

    return refIds;
}

class pumpConfigurePlaybackView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.ConfigurePlaybackLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        // 0. LOAD EACH SONG TO GET META INFO
        // 1. CHECK MENU FOREACH SONG IN STORAGE
        //     - HIGHLIGHT SONGS ALREADY IN PLAYLIST?
        // 2. START MEDIA PLAYBACK LIST
        // 3. ON PLAYBACK? PERSIST THE PLAYLIST TO STORAGE (LAST PLAYED)

        // AM SEEING A PATTERN TO BUILDING A MENU 
        // BASED ON TWO LISTS 
        // THE SONGS AND THE PLAYLIST (HOW THEY INTERSECT)

        Media.startPlayback({ 
            // "playlist" => [-2030043133, -2030043132],
            "playlist" => getCachedAudioRefIds(),
            "title" => "Playlist Name"
        });

        // var menu = new WatchUi.CheckboxMenu({:title => "Rez.Strings.playbackMenuTitle"});
        // var keys = self.handler.getKeys();
        
        // for (var index = 0; index < self.files.size(); index++) {
        //     var file = self.files[index];
        //     var item = new WatchUi.CheckboxMenuItem(
        //         file.getTitle(),
        //         null,
        //         file[:refId],
        //         true,
        //         null
        //     );
        //     menu.addItem(item);
        // }

        // WatchUi.pushView(menu, new pumpConfigureSyncMenuDelegate(self.handler), WatchUi.SLIDE_IMMEDIATE);
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
