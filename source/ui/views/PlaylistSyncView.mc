using Toybox.WatchUi as Ui;
using Toybox.Graphics;
import Toybox.Lang;

class PlaylistSyncView extends Ui.CheckboxMenu {

    private var _lifecycle as MenuLifecycleBehavior = new MenuLifecycleBehavior();

    function initialize(playlists as Array<PlaylistResource>, activePlaylistIds as Array<String>) {
        Ui.CheckboxMenu.initialize({:title => "Playlist Sync"});

        for (var index = 0, limit = playlists.size(); index < limit; index++) {
            var playlist = playlists[index];
            var state = playlist.getResourceState();

            // skip playlists that are already up to date
            if (state == PlaylistResource.CURRENT) {
                continue;
            }

            addItem(new Ui.CheckboxMenuItem(
                playlist.getTitle() as String,
                getSyncStateLabel(state) + playlist.getDescription(),
                index,
                false,
                {}
            ));
        }
    }

    private function getSyncStateLabel(state as PlaylistResource.ResourceState) as String {
        if (state == PlaylistResource.UPDATE_AVAILABLE) {
            return "[Update] ";
        }

        return "";
    }

    function onShow() as Void {
        _lifecycle.handleAutoCloseOnShow();
    }

    function onHide() as Void {
        _lifecycle.markClosedOnHide();
    }
}
