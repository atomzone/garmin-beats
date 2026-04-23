using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Media as Media;
using Toybox.Communications as Comm;
using Toybox.System as Sys;

import Toybox.Lang;

class MainMenuView extends Ui.Menu2 {

    function initialize() {
        Ui.Menu2.initialize({:title => "Test ACP"});

        addItem(new Ui.MenuItem("Download Track", null, :download, {}));
        addItem(new Ui.MenuItem("Play", null, :play, {}));
        addItem(new Ui.MenuItem("Resources", null, :resources, {}));
    }
}

class MainMenuDelegate extends Ui.Menu2InputDelegate {

    function initialize() {
        Ui.Menu2InputDelegate.initialize();
    }

    function onSelect(item as Ui.MenuItem) {
        var id = item.getId();

        if (id == :download) {
            Sys.println("QUEUE");

            var resource = new AudioResource({
                "source" => {
                    "url" => "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
                }
            });

            Application.Storage.setValue("SYNC_SELECTION", serializeResources([resource]));

            Communications.startSync();

        } else if (id == :play) {

            Sys.println("PLAY");

            // launch it in playback mode
            var storedTracks = Application.Storage.getValue("TRACKS") as App.PersistableType?;
            if (storedTracks == null) { return; }

            // A serializable object to pass to AudioContentProviderApp.getContentDelegate() when the app starts in playback mode
            Media.startPlayback(storedTracks);
        
        } else if (id == :resources) {
            var loader = new AudioResourceLoader("https://atomzone.github.io/static/tracks.json");
            loader.fetchResources(method(:displayResources));
        }
    }

    function displayResources(resources as Array<AudioResource>) as Void {
        $.am.debug("dd" + resources);

        var view = new ResourceView(resources);
        var delegate = new ResourceDelegate(resources);

        Ui.pushView(view, delegate, Ui.SLIDE_BLINK);
    }
}

class ResourceView extends Ui.CheckboxMenu {

    function initialize(resources as Array<AudioResource>) {
        Ui.CheckboxMenu.initialize({:title => "ResourceView"});

        for (var index = 0, limit = resources.size(); index < limit; index++) {
            var resource = resources[index];

            addItem(new Ui.CheckboxMenuItem(
                resource.getId(),
                resource.getSourceUrl(),
                index,
                false,
                {}
            ));
        }
    }
}

class ResourceDelegate extends Ui.Menu2InputDelegate {
    private var enabled as Array<AudioResource> = [];
    private var resources as Array<AudioResource>;

    function initialize(resources as Array<AudioResource>) {
        Menu2InputDelegate.initialize();
        self.resources = resources;
    }

    function onDone() as Void {
        $.am.debug("Sync selection made" + self.enabled);
        
        Ui.popView(Ui.SLIDE_IMMEDIATE); // pop the active view

        if (self.enabled.size() == 0) {
            return;
        }

        Application.Storage.setValue("SYNC_SELECTION", serializeResources(self.enabled));
        Communications.startSync();
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var id = item.getId() as Number;

        if ((item as Ui.CheckboxMenuItem).isChecked()) {
            self.enabled.add(self.resources[id]);
        } else {
            self.enabled.remove(self.resources[id]);
        }
    }
}

class AudioResourceLoader {
    var href as String;

    function initialize(href as String) {
        self.href = href;
    }

    function fetchResources(callback as Method) as Void {
        var request = new HttpRequest({ 
            :href => self.href,
            :parameters => {}
        }, method(:onResponseBuildResources));

        request.getJson({ :callback => callback });
    }

    function onResponseBuildResources(
        data as Dictionary or String or Null, 
        context as { :callback as Method }
    ) as Void {
        var json = (data as { "resources" as Array<AudioResourceType> });
        var models = buildResources(json["resources"] as Array<AudioResourceType>);

        (context[:callback] as Method).invoke(models);
    }
}