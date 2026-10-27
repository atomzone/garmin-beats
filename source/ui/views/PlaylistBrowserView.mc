using Toybox.WatchUi as Ui;
using Toybox.Graphics as Graphics;
import Toybox.Lang;

class PlaylistBrowserView extends Ui.Menu2 {

    private var _lifecycle as MenuLifecycleBehavior = new MenuLifecycleBehavior();

    function initialize(assets as Array<PlaylistAsset>) {
        Ui.Menu2.initialize({ :title => "Select Playlist" });

        for (var index = 0, limit = assets.size(); index < limit; index++) {
            var asset = assets[index];
            var meta = asset.getMetadata();
            // var bitmap = null;

            var bitmap = MediaUtils.createBitmapFromSource(meta.getArtwork());

            if (bitmap == null) {
                var bitmapRef = MediaUtils.createArtwork(asset.getChecksum(), 64);
                bitmap = new Ui.Bitmap({ :bitmap => bitmapRef });
            }

            addItem(new Ui.IconMenuItem(
                meta.getTitle(),
                meta.getDescription(),
                index,
                bitmap,
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