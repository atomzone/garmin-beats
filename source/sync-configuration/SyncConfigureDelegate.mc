import Toybox.Application;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Media;
import Toybox.System;
import Toybox.WatchUi;

class SyncConfigureDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();

        $.am.debug("label " + item.getLabel());

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
        } else if (id == :add_jellyfin) {
            var jelly = new Jellyfin("jellyfin.hoveoffice.com");
            // jelly.getArtists(method(:renderArtists));
            // jelly.getArtists(method(:renderItems));
            jelly.getAlbums(method(:renderItems));
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
        } else if (id == :open_webpage) {
            WatchUi.pushView(
                new DonateView(),
                new DonateDelegate(),
                WatchUi.SLIDE_LEFT
            );
        } else if (id == :system_information) {
            // build menu
            // add both items, push view
            var view = new Menu2({:title => "Storage"});
            view.addItem(new MenuItem("Memory", sublabel_Memory(), null, null));
            view.addItem(new MenuItem("Cache", sublabel_Cache(), null, null));

            WatchUi.pushView(
                view, null, WatchUi.SLIDE_LEFT
            );
            
        } else if (id == :x) {
            // experiement
            var jelly = new Jellyfin("jellyfin.hoveoffice.com");
            var browser = new JellyfinBrowser(jelly);

            WatchUi.pushView(
                browser.getView(), 
                browser.getDelegate(), 
                WatchUi.SLIDE_LEFT
            );
        }
    }

    static function sublabel_Memory() as Lang.String {
        var stats = System.getSystemStats();
        return formatBytes(stats.usedMemory) + " / " + formatBytes(stats.totalMemory);
    }

    static function sublabel_Cache() as Lang.String {
        var stats = Media.getCacheStatistics();
        return formatBytes(stats.size) + " / " + formatBytes(stats.capacity);
    }

    static function formatBytes(bytes as Lang.Integer) as Lang.String {
        if (bytes == 0) {
            return "0 Bytes";
        }
        var k = 1024;
        var sizes = ["Bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
        var in = Math.floor(Math.log(bytes, 10) / Math.log(k, 10));
        var flt = (bytes / Math.pow(k, in));
        return flt.format("%.1f") + " " + sizes[in.toNumber()];
    }
    
    function renderItems(data as Dictionary or String or Null) as Void {
        $.am.debug("Rendering items");
        $.am.debug(data);

        var audioResources = [] as Array<AudioTrackModel>;
        var translator = new JellyfinAudioTranslator();

        for (var index = 0, limit = data["Items"].size(); index < limit; index++) {
            var jellyfinItem = data["Items"][index] as Dictionary;
            var model = translator.translate(jellyfinItem);

            $.am.debug("Id " + model.id);
            $.am.debug("Image " + model.image);
            $.am.debug("Title " + model.title);
            $.am.debug("Description " + model.artist + ", " + model.album);

            audioResources.add(model);
        }

        if (audioResources.size() == 0) { return; }

        // var factory = new MyLoopFactory();
        // var opts = { :page => 0, :wrap => true }; 
        // var view = new AudioTrackViewLoopFactory(audioResource);

        var view = new AudioTrackMenuView(audioResources);
        // var view = new AudioTrackPaginationMenuView(audioResources);

        WatchUi.pushView(
            view, null, WatchUi.SLIDE_LEFT
        );
    }

    function renderArtists(data as Dictionary or String or Null) as Void {
        $.am.debug("Rendering artists");
        $.am.debug(data);

        var translator = new JellyfinAudioTranslator();

        for (var index = 0, limit = data["Items"].size(); index < limit; index++) {
            // $.am.debug(data["Items"][index]["Name"]);

            var jellyfinItem = data["Items"][index] as Dictionary;
            var model = translator.translate(jellyfinItem);

            $.am.debug("(" + model.id + ")" + model.title + " by " + model.artist + " (" + model.durationSeconds + "s)");
        }
    }
}
