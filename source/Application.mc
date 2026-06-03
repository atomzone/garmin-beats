using Toybox.Application as App;
using Toybox.Media as Media;
using Toybox.Communications as Comm;

import Toybox.Lang;

var am as ApplicationManager = new ApplicationManager();

class AppEntry extends App.AudioContentProviderApp {

    function initialize() {
        App.AudioContentProviderApp.initialize();

        // $.am.clearAll();

        var media = MediaUtils.getCachedMediaRefIds(Media.CONTENT_TYPE_AUDIO);
        var plStore = new IndexedStore(IndexedStore.PLAYLIST);
        var trStore = new IndexedStore(IndexedStore.TRACK);

        $.am.debug("TrackCount='" + trStore.count()
            + "', PlaylistCount='" + plStore.count()
            + "', MediaCount='" + media.size() + "'");

        // TODO: Identify a good time/place for this checks (after aa sync)
        // 1(media) : Many(tracks)
        if (media.size() <= trStore.count()) {
            return;
        }

        $.am.debug("Media count does not match track store count!");
        $.am.debug("Fixing this consistency");

        // TODO: fix/builkd this clean up
        // var trackIds = trStore.loadIndexIds();
        // for (var i = 0, limit = trStore.count(); i < limit; i++) {

        //     var raw = trStore.load(trackIds[i]);
        //     var track = new AudioAsset(raw as AudioAssetType);

        //     if (media.remove(track.getRefId())) {
        //         $.am.debug("Removed id='" + track.getId() + "'");
        //     }
        // }

        // for (var i = 0, limit = media.size(); i < limit; i++) {
        //     MediaUtils.delete(media[i]);
        // }
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