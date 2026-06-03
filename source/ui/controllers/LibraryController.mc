using Toybox.WatchUi as Ui;
import Toybox.Lang;

class LibraryController extends Ui.Menu2InputDelegate {
    private var _transition as Ui.SlideType = Ui.SLIDE_IMMEDIATE;

    function initialize() {
        Ui.Menu2InputDelegate.initialize();
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var id = item.getId();

        if (id == :Playlists) {
            var playlistStorage = new IndexedStore(IndexedStore.PLAYLIST);
            var playlists = playlistStorage.loadAll() as Array<PlaylistAssetType>;

            var assets = PlaylistAsset.fromArray(playlists);

            Ui.pushView(
                new PlaylistBrowserView(assets),
                new PlaylistMenuController(assets),
                _transition
            );

        } else if (id == :AllTracks) {
            var trackStorage = new IndexedStore(IndexedStore.TRACK);
            var tracks = trackStorage.loadAll() as Array<AudioAssetType>;

            var assets = AudioAsset.fromArray(tracks);
           
            Ui.pushView(
                new AssetSelectionView(assets),
                new AssetSelectionController(assets),
                _transition
            );
        } else if (id == :Artists) {
            //
        } else if (id == :Liked) {
            // hide this and/or update title to reflect number of liked tracks Liked(101)
        }
    }
}

