import Toybox.Lang;

class PlaylistStore {

    private var _key as String;

    function initialize(storeId as String) {
        _key = storeId;
    }

    function setPlaylist(playlist as Playlist) as Void {
        StorageManager.set(_key, playlist.serialize());
    }

    function getPlaylist() as Playlist {
        var value = StorageManager.get(_key);
        if (value instanceof Dictionary) {
            return playlistFromPayload(value as PlaylistType);
        }

        return new Playlist([], 0);
    }
}
