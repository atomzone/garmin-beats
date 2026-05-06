using Toybox.Application as App;
using Toybox.Media as Media;
using Toybox.Communications as Comm;

import Toybox.Lang;

var am as ApplicationManager = new ApplicationManager();

class AppEntry extends App.AudioContentProviderApp {

    function initialize() {
        App.AudioContentProviderApp.initialize();
    }

    function getContentDelegate(audioRefs as App.PersistableType) as Media.ContentDelegate {
        var store = new PlaylistStore("active");
        var playlist;

        // 1. load current playlist from storage
        if (audioRefs == null) {
            playlist = store.getPlaylist();

            if (playlist == null) {
                playlist = new Playlist([], 0);
            }
            return new PlaybackProvider(playlist, store);
        }

        // 2. otherwise, build playlist from payload and cache it
        playlist = playlistFromPayload(audioRefs as PlaylistType);
        store.setPlaylist(playlist);

        return new PlaybackProvider(playlist, store);
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
}






