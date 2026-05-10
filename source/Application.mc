using Toybox.Application as App;
using Toybox.Media as Media;
using Toybox.Communications as Comm;

import Toybox.Lang;

var am as ApplicationManager = new ApplicationManager();

class AppEntry extends App.AudioContentProviderApp {
    // App-level singleton: StorageManager provides access to persisted state
    // This is accessed by ContentIterator to load fresh data on each playback session
    private static var _storageManager as StorageManager?;

    function initialize() {
        App.AudioContentProviderApp.initialize();
        // Initialize storage singleton on app startup
        _storageManager = new StorageManager();
    }

    function getContentDelegate(audioRefs as App.PersistableType) as Media.ContentDelegate {
        // STATELESS DELEGATE PATTERN (per OpenPlayer)
        // This method is called by the Garmin system and may be called multiple times.
        // We always return a fresh ContentDelegate wrapper with no retained state.
        // The iterator will load data fresh from storage on each instantiation.
        
        // If payload provided, persist it to storage for later loading
        if (audioRefs != null) {
            var store = new PlaylistStore("active");
            var playlist = playlistFromPayload(audioRefs as PlaylistType);
            $.am.debug("[AppEntry.getContentDelegate] persisting payload assets=" + playlist.getAssets().size());
            store.setPlaylist(playlist);
        }
        
        // Always return fresh, stateless delegate
        // The delegate will create fresh iterators that load from storage
        return new PlaybackProvider();
    }
    
    // Accessor for ContentIterator to reach StorageManager
    // This allows the iterator to load tracks fresh from persistent storage
    static function getStorageManager() as StorageManager {
        if (_storageManager == null) {
            _storageManager = new StorageManager();
        }
        return _storageManager;
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






