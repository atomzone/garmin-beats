import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.Media;
import Toybox.WatchUi;

class pumpApp extends Application.AudioContentProviderApp {

    function initialize() {
        AudioContentProviderApp.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Get a Media.ContentDelegate for use by the system to get and iterate through media on the device
    function getContentDelegate(arg as PersistableType) as ContentDelegate {
        return new pumpContentDelegate();
    }

    // Get a delegate that communicates sync status to the system for syncing media content to the device
    function getSyncDelegate() as Communications.SyncDelegate? {
        return new pumpSyncDelegate();
    }

    // Get the initial view for configuring playback
    function getPlaybackConfigurationView() as [Views] or [Views, InputDelegates] {
        return [ new pumpConfigurePlaybackView(), new pumpConfigurePlaybackDelegate() ];
    }

    // Get the initial view for configuring sync
    function getSyncConfigurationView() as [Views] or [Views, InputDelegates] {
        return [ new pumpConfigureSyncView(), new pumpConfigureSyncDelegate() ];
    }

}

function getApp() as pumpApp {
    return Application.getApp() as pumpApp;
}