using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Media as Media;
using Toybox.Communications as Comm;
using Toybox.System as Sys;

import Toybox.Lang;


// =====================================================
// APP
// =====================================================

var am as ApplicationManager = new ApplicationManager();

class AppEntry extends App.AudioContentProviderApp {

    function initialize() {
        App.AudioContentProviderApp.initialize();
    }

    function getContentDelegate(audioRefs as App.PersistableType) as Media.ContentDelegate {
        var tracks = [];

        if (audioRefs instanceof Array) {
            for (var index = 0, limit = audioRefs.size(); index < limit; index++) {
                tracks.add(new AudioFile(audioRefs[index] as Object));
            }
        }

        return new PlaybackProvider(tracks);
    }

    function getSyncDelegate() as Comm.SyncDelegate? {
        return new SyncManager();
    }

    function getPlaybackConfigurationView() {
        return [ new MainMenuView(), new MainMenuInputController() ];
    }

    function getSyncConfigurationView() {
        return getPlaybackConfigurationView();
    }
}






