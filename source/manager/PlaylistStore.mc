import Toybox.Lang;

class PlaylistStore {

    private var _key as String;

    function initialize(storeId as String) {
        _key = storeId;
    }

    function setPlaylist(playlist as Playlist) as Void {
        var serialized = playlist.serialize();
        StorageManager.set(_key, serialized);
    }

    function getPlaylist() as Playlist? {
        var value = StorageManager.get(_key);
        if (!(value instanceof Dictionary)) {
            return null;
        }

        return playlistFromPayload(value as PlaylistType);
    }
}
