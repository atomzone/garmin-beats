using Toybox.WatchUi as Ui;
import Toybox.Lang;

class PlaylistBrowserView extends Ui.Menu2 {

    private var _lifecycle as MenuLifecycleBehavior = new MenuLifecycleBehavior();

    function initialize(assets as Array<PlaylistResource>) {
        Ui.Menu2.initialize({ :title => "Select Tracks" });

        for (var index = 0, limit = assets.size(); index < limit; index++) {
            var asset = assets[index];

            addItem(new Ui.MenuItem(
                asset.getTitle(),
                asset.getDesc(),
                index,
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