import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.Media;
import Toybox.WatchUi;

class pumpApp extends Application.AudioContentProviderApp {

    function initialize() {
        AudioContentProviderApp.initialize();

        System.println("<properties.xml>");
        System.println("appVersion: " + Properties.getValue("appVersion"));
        System.println("audioSource: " + Properties.getValue("audioSource"));
        System.println("</properties.xml>");
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        System.println("AudioContentProviderApp.onStart");
        System.println(state);
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        System.println("AudioContentProviderApp.onStop");
        System.println(state);
    }

    // Get a Media.ContentDelegate for use by the system to get and iterate through media on the device
    function getContentDelegate(args as PersistableType) as ContentDelegate {
        System.println("AudioContentProviderApp.getContentDelegate");
        System.println(args);

        // attempt to load playlist from system storage
        if (args == null) {
            System.println("// attempt to load playlist from system storage");
        }
        
        return new pumpContentDelegate(args);
    }

    // Get the initial view for configuring playback
    function getPlaybackConfigurationView() as [Views] or [Views, InputDelegates] {
        System.println("AudioContentProviderApp.getPlaybackConfigurationView");

        var audioRefs = getCachedAudioRefIds();
        
        if (audioRefs.size() == 0) {
            return getSyncConfigurationView();
        }

        // return [ new pumpConfigurePlaybackView(), new pumpConfigurePlaybackDelegate() ];
        return [ new pumpConfigurePlaybackView(audioRefs) ];
    }

    // Get the initial view for configuring sync
    function getSyncConfigurationView() as [Views] or [Views, InputDelegates] {
        System.println("AudioContentProviderApp.getSyncConfigurationView");

        return [ new Rez.Menus.configureSyncMenu(), new SyncConfigureDelegate() ];
    }

    // Get a delegate that communicates sync status to the system for syncing media content to the device
    function getSyncDelegate() as Communications.SyncDelegate? {
        System.println("AudioContentProviderApp.getSyncDelegate");

        var resources = new StorageManager("SYNC").get("audio") as Array?;

        if (resources == null) {
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

            queue.add(new DownloadAudioTask(audioResource));
        }

        return new pumpSyncDelegate(queue, progressIndicator);
    }
}

function getApp() as pumpApp {
    return Application.getApp() as pumpApp;
}