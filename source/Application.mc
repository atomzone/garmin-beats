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

        // Load playlist from storage
        if (audioRefs == null) {
            var stored = store.getPlaylist();
            $.am.debug("[AppEntry.getContentDelegate] source=store assets=" + stored.getAssets().size() + " index=" + stored.getCurrentTrackIndex() + " resume=" + stored.getResumePositionSeconds());
            return new PlaybackProvider(stored, store);
        }

        // Build playlist from payload and persist to storage
        var playlist = playlistFromPayload(audioRefs as PlaylistType);
        $.am.debug("[AppEntry.getContentDelegate] source=payload assets=" + playlist.getAssets().size() + " index=" + playlist.getCurrentTrackIndex() + " resume=" + playlist.getResumePositionSeconds());
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






