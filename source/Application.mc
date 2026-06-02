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

    function getContentDelegate(playlistAssetId as App.PersistableType) as Media.ContentDelegate {
        // Read requested playlist id from runtime input.
        var requestedPlaylistId = playlistAssetId as String?;

        // Load last persisted playback session state.
        var storedState = PlaybackStateStore.load();

        // Resolve playlist id: explicit request first, then stored session.
        var resolvedPlaylistId = requestedPlaylistId;
        if (resolvedPlaylistId == null && storedState != null) {
            resolvedPlaylistId = storedState["playlistId"] as String?;
        }

        // Fall back to default now-playing playlist id.
        if (resolvedPlaylistId == null) {
            resolvedPlaylistId = "pl:nowplaying";
        }

        // Open playlist store and load the selected playlist asset.
        var playlistAssetStore = new IndexedStore("PLAYLIST");
        var raw = playlistAssetStore.load(resolvedPlaylistId);

        // Use an empty placeholder payload when the playlist is missing.
        if (raw == null) {
            raw = {};
        }

        // Build playlist domain object from persisted payload.
        var playlistAsset = new PlaylistAsset(raw as PlaylistAssetType);

        // Resolve runtime cursor (resume or reset) from request + stored state.
        var playbackCursor = PlaybackStateStore.resolvePlaylistState(
            requestedPlaylistId,
            playlistAsset.getId(),
            storedState
        );
        
        // Construct runtime playback playlist with resolved cursor.
        var playerPlaylist = new PlayerPlaylist(playbackCursor, playlistAsset);

        // Emit playback bootstrap diagnostics.
        $.am.debug("[AppEntry.getContentDelegate]"
            + " assets=" + playerPlaylist.getAssetCount()
            + " playlist=" + playerPlaylist.getPlaylistId()
            + " index=" + playerPlaylist.getCurrentTrackIndex() 
            + " position=" + playerPlaylist.getCurrentTrackPosition());

        // Build playback session/persistence manager for this playlist instance.
        var session = new PlaybackSession(playerPlaylist);
        
        // Return playback delegate consumed by the platform.
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