using Toybox.WatchUi as Ui;
using Toybox.Media as Media;
import Toybox.Lang;

class PlaylistMenuController extends Ui.Menu2InputDelegate {

    private var _assets as Array<PlaylistAsset>;

    function initialize(assets as Array<PlaylistAsset>) {
        Ui.Menu2InputDelegate.initialize();
        _assets = assets;
    }

    function onDone() as Void {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        return;
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var index = item.getId() as Number;
        var playlist = _assets[index];
        
        $.am.debug("[NOW PLAYING] id='" + playlist.getId() + "', '" + playlist.serialize() + "'");
        Media.startPlayback(playlist.getId());
    }
}
