import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Media;
import Toybox.WatchUi;

class PlaybackConfigureMenuView extends WatchUi.View {
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
        var cachedAudio = getCachedAudioRefIds();

        if (cachedAudio.size == 0) {
            System.println("pumpConfigurePlaybackView.onShow - No cached audio found");
            return;
        }

        var menu = new WatchUi.CheckboxMenu({:title => "Rez.Strings.playbackMenuTitle"});
        
        for (var index = 0; index < cachedAudio.size(); index++) {
            var item = new WatchUi.CheckboxMenuItem(
                cachedAudio[index].toString(),
                null,
                index,
                false,
                null
            );
            menu.addItem(item);
        }

        WatchUi.pushView(menu, new PlaybackConfigureDelegate(cachedAudio), WatchUi.SLIDE_IMMEDIATE);
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
