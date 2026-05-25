using Toybox.Application as App;
using Toybox.Media as Media;
using Toybox.Communications as Comm;

import Toybox.Lang;

var am as ApplicationManager = new ApplicationManager();

class AppEntry extends App.AudioContentProviderApp {

    function initialize() {
        App.AudioContentProviderApp.initialize();

        var media = MediaUtils.getCachedMediaRefIds(Media.CONTENT_TYPE_AUDIO);
        var plStore = new IndexedStore("PLAYLIST");
        var trStore = new IndexedStore("TRACK");
        $.am.debug("TrackCount='" + trStore.count()
            + "', PlaylistCount='" + plStore.count()
            + "', MediaCount='" + media.size() + "'");
    }

    function getContentDelegate(playlistAssetId as App.PersistableType) as Media.ContentDelegate {
        // DEFAULT FOR NOW...
        if (playlistAssetId == null) {
            playlistAssetId = "pl:nowplaying";
        }

        // FETCH THE PLAYLIST ASSET
        var playlistAssetStore = new IndexedStore("PLAYLIST");
        var raw = playlistAssetStore.get(playlistAssetId as String);

        // can we avoid doing all this if the playlist does not exist!
        if (raw == null) {
            raw = {};
        }

        // Player Playlist + PlaylistAsset
        var playlistAsset = new PlaylistAsset(raw as PlaylistAssetType);
        var playerPlaylist = new PlayerPlaylist({ "trackIndex" => 2, "trackPosition" => 30 }, playlistAsset);

        $.am.debug("[AppEntry.getContentDelegate]"
            + " assets=" + playerPlaylist.getAssetCount()
            + " index=" + playerPlaylist.getCurrentTrackIndex() 
            + " position=" + playerPlaylist.getCurrentTrackPosition());

        // Playback Provider
        var session = new PlaybackSession(playerPlaylist, playlistAssetStore);
        
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
}