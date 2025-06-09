import Toybox.Lang;
import Toybox.WatchUi;

class PlaybackConfigureDelegate extends WatchUi.Menu2InputDelegate {
    private var audioRefs as Array<Object>;
    private var enabled as Array<Object> = [];

    function initialize(audioRefs as Array<Object>) {
        Menu2InputDelegate.initialize();
        self.audioRefs = audioRefs;
    }

    function onDone() as Void {
        if (self.enabled.size() == 0) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE); // view manipulation :|
            return;
        }

        Media.startPlayback({ 
            "playlist" => self.enabled,
            "title" => "Playlist Name"
        });
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as Number;
        var ref = self.audioRefs[id];

        if ((item as WatchUi.CheckboxMenuItem).isChecked()) {
            self.enabled.add(ref);
        } else {
            self.enabled.remove(ref);
        }
    }
}
