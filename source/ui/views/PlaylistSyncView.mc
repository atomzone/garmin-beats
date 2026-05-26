using Toybox.WatchUi as Ui;
using Toybox.Graphics;
import Toybox.Lang;

class PlaylistSyncView extends Ui.CheckboxMenu {

    private var _lifecycle as MenuLifecycleBehavior = new MenuLifecycleBehavior();

    function initialize(playlists as Array<PlaylistResource>, activePlaylistIds as Array<String>) {
        Ui.CheckboxMenu.initialize({:title => "Playlist Sync"});

        for (var index = 0, limit = playlists.size(); index < limit; index++) {
            var playlist = playlists[index];

            addItem(new Ui.CheckboxMenuItem(
                playlist.getTitle() as String,
                playlist.getDescription(),
                index,
                activePlaylistIds.indexOf(playlist.getId()) > -1, // this is good, but, unticking will not delete the assets
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
