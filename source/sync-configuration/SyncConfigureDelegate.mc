import Toybox.Application;
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

        if (id == :play) {
            // lets check each time (i see another pattern)
            var audioRefIds = getCachedAudioRefIds();
            if (audioRefIds.size() == 0) { return; }

            Media.startPlayback({ 
                "playlist" => audioRefIds,
                "title" => "Playlist Name"
            });
        } else if (id == :library) {
            // lets check each time (i see another pattern)
            var audioAssets = getAudioAssets();
            if (audioAssets.size() == 0) { return; }

            WatchUi.pushView(
                new DeleteAssetsView(audioAssets),
                null,
                WatchUi.SLIDE_LEFT
            );
        } else if (id == :add_local) {
            // lets check each time (i see another pattern)
            var audioResources = getAudioResources();
            if (audioResources.size() == 0) { return; }

            WatchUi.pushView(
                new SyncResourcesView(audioResources),
                null,
                WatchUi.SLIDE_LEFT
            );
        } else if (id == :settings) {
            // WatchUi.pushView(
            //     new pumpConfigureSyncView(), 
            //     new pumpConfigureSyncDelegate(),
            //     WatchUi.SLIDE_LEFT
            // );
            WatchUi.pushView(
                new WatchUi.ProgressBar("Processing...", null),
                null,
                WatchUi.SLIDE_DOWN
            );
        } else if (id == :fractal) {
            WatchUi.pushView(
                new FractalView(), 
                new FractalDelegate(),
                WatchUi.SLIDE_LEFT
            );
        } else if (id == :app_config) {
            // POC. convert config to AudioResource
            // and download that config driven resource!!
            // basically here is the download contract handed to the 
            // resource retriever...
            var audioResource = new AudioResource(
                Properties.getValue("audioSource").toString(),
                { :id => "source-from-app-property" }
            ); 
            
            // view this time
            // could download and play automagically
            WatchUi.pushView(
                new SyncResourcesView([audioResource]),
                null,
                WatchUi.SLIDE_LEFT
            );
        }
    }
}
