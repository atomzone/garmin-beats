using Toybox.WatchUi as Ui;
using Toybox.Graphics;
import Toybox.Lang;

class PlaylistSyncView extends Ui.CheckboxMenu {

    private var _lifecycle as MenuLifecycleBehavior = new MenuLifecycleBehavior();

    function initialize(playlists as Array<PlaylistResource>) {
        Ui.CheckboxMenu.initialize({:title => "Playlist Sync"});

        for (var index = 0, limit = playlists.size(); index < limit; index++) {
            var playlist = playlists[index];

            addItem(new Ui.CheckboxMenuItem(
                playlist.getTitle() as String,
                playlist.getDesc(),
                index,
                false,
                {}
            ));
        }
    }

    function onShow() as Void {
        _lifecycle.handleAutoCloseOnShow();
    }

    function onHide() as Void {
        _lifecycle.markClosedOnHide();
    }
}
