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
        // Cheap on cache hit (probe + exec within same wake share one build).
        // Cache-miss only on cold start or after a real input change.
        SyncPlanner.ensureFresh();
        return new SyncManager();
    }

    function getPlaybackConfigurationView() {
        return [ new MainMenuView(), new MainMenuController() ];
    }

    function getSyncConfigurationView() {
        return getPlaybackConfigurationView();
    }
}