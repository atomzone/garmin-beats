import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.Media;
import Toybox.WatchUi;

var am as ApplicationManager = new ApplicationManager();

class pumpApp extends Application.AudioContentProviderApp {

    function initialize() {
        AudioContentProviderApp.initialize();

        $.am.debug("AudioContentProviderApp:initialize");
        $.am.debugWithArgs("appVersion", Properties.getValue("appVersion") as Object);
        $.am.debugWithArgs("audioSource", Properties.getValue("audioSource") as Object);
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        $.am.debugWithArgs("AudioContentProviderApp.onStart", state as Object);

        // var resources = new StorageManager("SYNC").get("audio") as Array?;

        // $.am.debug("Audio refs " + getCachedAudioRefIds());
        // $.am.debug("Audio refs " + resources);
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        $.am.debugWithArgs("AudioContentProviderApp.onStop", state as Object);

        // var resources = new StorageManager("SYNC").get("audio") as Array?;

        // $.am.debug("Audio refs " + getCachedAudioRefIds());
        // $.am.debug("Audio refs " + resources);
    }

    function onSettingsChanged() as Void {
        $.am.debug("AudioContentProviderApp.onSettingsChanged");
    }

    // Get a Media.ContentDelegate for use by the system to get and iterate through media on the device
    function getContentDelegate(args as PersistableType) as ContentDelegate {
        $.am.debugWithArgs("AudioContentProviderApp.getContentDelegate", args as Object);

        // attempt to load playlist from system storage
        if (args == null) {
            $.am.debug("- Attempt to load playlist from system storage");
        }
        
        return new pumpContentDelegate(args);
    }

    // Get the initial view for configuring playback
    function getPlaybackConfigurationView() as [Views] or [Views, InputDelegates] {
        $.am.debug("AudioContentProviderApp.getPlaybackConfigurationView");

        var audioRefs = getCachedAudioRefIds();
        
        if (audioRefs.size() == 0) {
            return getSyncConfigurationView();
        }

        // return [ new pumpConfigurePlaybackView(), new pumpConfigurePlaybackDelegate() ];
        return [ new pumpConfigurePlaybackView(audioRefs) ];
    }

    // Get the initial view for configuring sync
    function getSyncConfigurationView() as [Views] or [Views, InputDelegates] {
        $.am.debug("AudioContentProviderApp.getSyncConfigurationView");

        return [ new Rez.Menus.configureSyncMenu(), new SyncConfigureDelegate() ];
    }

    // Get a delegate that communicates sync status to the system for syncing media content to the device
    function getSyncDelegate() as Communications.SyncDelegate? {
        $.am.debug("AudioContentProviderApp.getSyncDelegate");

        var resources = new StorageManager("SYNC").get("audio") as Array?;

        if (resources == null) {
            $.am.debug("[!] No SYNC resources found");
            return null;
        }

        var progressIndicator = new ProgressBarController(
            new WatchUi.ProgressBar("Download", null)
        );

        var queue = new CommunicationsQueue(progressIndicator);
        
        for (var index = 0; index < resources.size(); index++) {
            var data = resources[index];
            var audioResource = new AudioResource(
                data["href"] as String, 
                { :id => data["id"] as String }
            );

            $.am.debug("[!] Building Dowaload task for " + data["href"] as String);

            // this download task has hardcoded stuff...
            queue.add(new DownloadAudioTask(audioResource));
        }

        return new pumpSyncDelegate(queue, progressIndicator);
    }
}

