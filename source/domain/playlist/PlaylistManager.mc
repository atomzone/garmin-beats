import Toybox.Lang;

class PlaylistManager {

    static function save(playlist as PlaylistResource) as Void {
  
        // persist model
        StorageManager.set(playlist.getKey(), playlist.serialize());

        // persist checksum
        SyncStateStore.setPlaylist(playlist.getKey(), playlist.getChecksum());
    }

    static function delete(key as String) as Void {
        
        // delete model
        StorageManager.delete(key);

        // remove checksum
        SyncStateStore.deletePlaylist(key);
    }

    static function load(key as String) as PlaylistResource? {
        var playlistResource = StorageManager.get(key) as PlaylistResourceType?;
        
        if (playlistResource == null) {
            return null;
        }

        return new PlaylistResource(playlistResource);
    }

    static function fromArray(ids as Array<String>) as Array<PlaylistResource> {
        var playlists = [];

        for (var index = 0, limit = ids.size(); index < limit; index++) {
            var playlistResource = load(ids[index]);

            if (playlistResource != null) {
                playlists.add(playlistResource);
            }
        }

        return playlists;
    }

    static function getActiveIds() as Array<String> {
        return SyncStateStore.getPlaylistChecksums().keys();
    }

    // function getEnabled()
    //     as Array<PlaylistResource>

    //
    // ACTIVE PLAYLIST
    //

    // function setActive(
    //     playlistId as String
    // ) as Void

    // function getActiveId()
    //     as String?

    // function getActive()
    //     as PlaylistResource?

    //
    // CHECKSUM CACHE
    //

    // function getPlaylistChecksums()
    //     as Dictionary
}