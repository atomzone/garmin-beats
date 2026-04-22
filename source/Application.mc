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
        $.am.debug("App.getContentDelegate() " + audioRefs);

        var tracks = [];

        if (audioRefs instanceof Array) {
            for (var index = 0; index < audioRefs.size(); index++) {
                tracks.add(new AudioFile(audioRefs[index]));
            }
        }

        return new TestContentDelegate(tracks);
    }

    function getSyncDelegate() as Comm.SyncDelegate? {
        return new TestSyncDelegate();
    }

    function getPlaybackConfigurationView() {
        return [ new MainMenuView(), new MainMenuDelegate() ];
    }

    function getSyncConfigurationView() {
        return getPlaybackConfigurationView();
    }
}






