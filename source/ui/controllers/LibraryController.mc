using Toybox.WatchUi as Ui;

class LibraryController extends Ui.Menu2InputDelegate {
    private var _transition as Ui.SlideType = Ui.SLIDE_IMMEDIATE;

    function initialize() {
        Ui.Menu2InputDelegate.initialize();
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var id = item.getId();

        if (id == :Playlists) {
            // [TODO] this would not render if empty
            var playlistResourceIds = PlaylistManager.getActiveIds();
            var playlistResources = PlaylistManager.fromArray(playlistResourceIds);

            Ui.pushView(
                new PlaylistBrowserView(playlistResources),
                new PlaylistMenuController(playlistResources),
                _transition
            );

        } else if (id == :AllTracks) {
            
            // maybe we pass around refIds() small footprint
            // or maybe we just use AudioAsset.getCachedAssets()
            var refIds = AudioAsset.getCachedAssetRefIds();
            var assets = AudioAsset.fromRefIds(refIds);
            
            Ui.pushView(
                new AssetSelectionView(assets),
                new AssetSelectionController(assets),
                self._transition
            );
        } else if (id == :Artists) {
            //
        } else if (id == :Liked) {
            // hide this and/or update title to reflect number of liked tracks Liked(101)
        }
    }
}

