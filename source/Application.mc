using Toybox.Application as App;
using Toybox.Media as Media;
using Toybox.Communications as Comm;

import Toybox.Lang;

var am as ApplicationManager = new ApplicationManager();

class AppEntry extends App.AudioContentProviderApp {

    function initialize() {
        App.AudioContentProviderApp.initialize();

        // Do we need to track drift between system storage and the app?
        var reconciler = new SyncReconciler();
        $.am.debug("Reconciliation result: " + reconciler.audit());
    }

    function getContentDelegate(playlistId as App.PersistableType) as Media.ContentDelegate {

        var playerPlaylist = PlayerPlaylist.load(playlistId as String?);

        if (playerPlaylist == null) {
            // Can we relaunch the app in another mode o.O
            // https://developer.garmin.com/connect-iq/api-docs/Toybox/System/Intent.html
            return new EmptyContentDelegate();
        }

        $.am.debug("[AppEntry.getContentDelegate]"
            + " assets=" + playerPlaylist.getAssetCount()
            + " playlist=" + playerPlaylist.getPlaylistId()
            + " index=" + playerPlaylist.getCurrentTrackIndex() 
            + " position=" + playerPlaylist.getCurrentTrackPosition());

        var session = new PlaybackSession(playerPlaylist);

        return new PlaybackProvider(playerPlaylist, session);
    }

    function getSyncDelegate() as Comm.SyncDelegate? {
        return new SyncManager();
    }

    function getPlaybackConfigurationView() {
        return [ new MainMenuView(), new MainMenuController() ];
    }

    function getSyncConfigurationView() {
        return getPlaybackConfigurationView();
    }

    function getProviderIconInfo() as Media.ProviderIconInfo? {
        return new Media.ProviderIconInfo(
            $.Rez.Drawables.ProviderIcon, Toybox.Graphics.COLOR_ORANGE
        );
    }

    // https://developer.garmin.com/connect-iq/api-docs/Toybox/Application/AppBase.html#onSettingsChanged-instance_function
    function onSettingChanged(key as String, value as String) as Void {
        $.am.debug("Setting changed: " + key + " = " + value);
    }
}