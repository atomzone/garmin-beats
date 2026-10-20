using Toybox.Application as App;
using Toybox.Media as Media;
using Toybox.WatchUi as Ui;
using Toybox.Communications as Comm;

import Toybox.Lang;

var _am as ApplicationManager?;

class AppEntry extends App.AudioContentProviderApp {

    private var _state as AppState;

    function initialize() {
        App.AudioContentProviderApp.initialize();

        _am = new ApplicationManager();
        _state = new AppState();

        // Do we need to track drift between system storage and the app?
        var reconciler = new SyncReconciler();
        $.am().logger().info("Reconciliation", reconciler.audit());
    }

    function getContentDelegate(playlistId as App.PersistableType) as Media.ContentDelegate {

        var playerPlaylist = PlayerPlaylist.load(playlistId as String?);

        if (playerPlaylist == null) {
            // Can we relaunch the app in another mode o.O
            // https://developer.garmin.com/connect-iq/api-docs/Toybox/System/Intent.html
            return new EmptyContentDelegate();
        }

        $.am().logger().info("[AppEntry.getContentDelegate]", {
            "assets" => playerPlaylist.getAssetCount(),
            "playlist" => playerPlaylist.getPlaylistId(),
            "index" => playerPlaylist.getCurrentTrackIndex(),
            "position" => playerPlaylist.getCurrentTrackPosition()
        });

        var session = new PlaybackSession(playerPlaylist);

        return new PlaybackProvider(playerPlaylist, session);
    }

    function getSyncDelegate() as Comm.SyncDelegate? {
        return new SyncManager();
    }

    function getPlaybackConfigurationView() as [Ui.Views] or [Ui.Views, Ui.InputDelegates] {
        return getSyncConfigurationView();
    }

    function getSyncConfigurationView() as [Ui.Views] or [Ui.Views, Ui.InputDelegates] {
        return [ new MainMenuView(_state), new MainMenuController(_state) ];
    }

    function getProviderIconInfo() as Media.ProviderIconInfo? {
        return new Media.ProviderIconInfo(
            $.Rez.Drawables.ProviderIcon, Toybox.Graphics.COLOR_ORANGE
        );
    }

    // https://developer.garmin.com/connect-iq/api-docs/Toybox/Application/AppBase.html#onSettingsChanged-instance_function
    function onSettingChanged(key as String, value as String) as Void {
        $.am().logger().info("Setting changed", { "key" => key, "value" => value });
    }
}

function am() as ApplicationManager {
    if (_am == null) {
        _am = new ApplicationManager();
    }
    return _am;
}
