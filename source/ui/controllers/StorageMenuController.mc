using Toybox.WatchUi as Ui;
import Toybox.Lang;

class StorageMenuController extends Ui.Menu2InputDelegate {

    private var _trackCount as Number;

    function initialize(trackCount as Number) {
        Ui.Menu2InputDelegate.initialize();

        _trackCount = trackCount;
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var id = item.getId();

        if (id == :Delete) {
            var message = Lang.format("Delete Assets? ($1$)", [_trackCount]);

            Ui.pushView(
                new Ui.Confirmation(message),
                new DeleteAssetConfirmation(),
                Ui.SLIDE_IMMEDIATE
            );

        } else if (id == :Capacity) {
            // show memory
            // show cached sizes
        } 
    }
}