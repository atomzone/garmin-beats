import Toybox.Lang;
import Toybox.WatchUi;

class SyncConfigureDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();

        System.println("label " + item.getLabel());

        // var view as WatchUi.Views;
        // var model as WatchUi.InputDelegates;

        if (id == :library) {
            WatchUi.pushView(
                new DeleteAssetsView(getAudioAssets()),
                null,
                WatchUi.SLIDE_LEFT
            );
        } else if (id == :add) {
            WatchUi.pushView(
                new SyncResourcesView(getAudioResources()),
                null,
                WatchUi.SLIDE_LEFT
            );
        } else if (id == :settings) {
            // WatchUi.pushView(
            //     new pumpConfigureSyncView(), 
            //     new pumpConfigureSyncDelegate(),
            //     WatchUi.SLIDE_LEFT
            // );
        } else if (id == :fractal) {
            // WatchUi.pushView(
            //     new pumpConfigureSyncView(), 
            //     new pumpConfigureSyncDelegate(),
            //     WatchUi.SLIDE_LEFT
            // );
        }

        // WatchUi.pushView(view, model, WatchUi.SLIDE_LEFT);
    }
}
