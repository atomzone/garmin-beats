using Toybox.Application as App;
using Toybox.Media as Media;
using Toybox.Communications as Comm;

import Toybox.Lang;

var am as ApplicationManager = new ApplicationManager();

class AppEntry extends App.AudioContentProviderApp {

    function initialize() {
        App.AudioContentProviderApp.initialize();
    }

    function getContentDelegate(playlistRaw as App.PersistableType) as Media.ContentDelegate {
        var store = new PlaylistStore("active");
        var playlist;

        if (playlistRaw == null) {
            playlist = store.getPlaylist();
        } else {
            playlist = playlistFromPayload(playlistRaw as PlaylistType);
            store.setPlaylist(playlist);
        }

        $.am.debug("[AppEntry.getContentDelegate]"
            + " assets=" + playlist.getAssetCount()
            + " index=" + playlist.getCurrentTrackIndex() 
            + " position=" + playlist.getCurrentTrackPosition());

        var session = new PlaybackSession(playlist, store);
        return new PlaybackProvider(playlist, session);
    }

    function getSyncDelegate() as Comm.SyncDelegate? {
        var raw = StorageManager.getOrDefault("SYNC", []) as Array<PlaylistResourceType>;
        var playlists = PlaylistResource.fromArray(raw);

        return new SyncManager(playlists);
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