import Toybox.Lang;

/*
Remote Playlists
        ↓
   SyncManifest
        ↓
  SyncOperations
        ↓
   SyncManager
        ↓
 Device State
*/

typedef SyncOperationType as {
    "type" as String,
    "playlistKey" as String?,
    "logicalId" as String?,
    "playlist" as PlaylistResource?,
    "track" as AudioResource?
};

class SyncManifest {

    private var _playlists as Array<PlaylistResource>;
    private var _localPlaylistChecksums as Dictionary<String, String>;
    private var _localTrackChecksums as Dictionary<String, String>;
    private var _operations as Array<SyncOperationType> = [];

    function initialize(
        playlists as Array<PlaylistResource>,
        localPlaylistChecksums as Dictionary<String, String>,
        localTrackChecksums as Dictionary<String, String>
    ) {
        _playlists = playlists;
        _localPlaylistChecksums = localPlaylistChecksums;
        _localTrackChecksums = localTrackChecksums;
    }

    public function build() as Void {
        _operations = [];

        reconcilePlaylists();
        cleanupPlaylists();
    }

    public function getOperations() as Array<SyncOperationType> {
        return _operations;
    }

    public function hasChanges() as Boolean {
        return _operations.size() > 0;
    }

    private function reconcilePlaylists() as Void {
        for (var i = 0; i < _playlists.size(); i++) {
            var playlist = _playlists[i];
            var localChecksum = _localPlaylistChecksums[playlist.getKey()];

            $.am.debug("_localPlaylistChecksums = " + _localPlaylistChecksums);
            $.am.debug("localChecksum = " + localChecksum);
            $.am.debug("playlist key = " + playlist.getKey());
            $.am.debug("playlist checksum = " + playlist.getChecksum());

            // New playlist
            if (localChecksum == null) {
                addPlaylistOperation("SAVE_PLAYLIST", playlist);
            }
            // Updated playlist
            else if (!localChecksum.equals(playlist.getChecksum())) {
                addPlaylistOperation("UPDATE_PLAYLIST", playlist);
            }
            // Unchanged playlist
            else {
                continue;
            }

            reconcileTracks(playlist);
        }
    }

    private function cleanupPlaylists() as Void {
        var remotePlaylistKeys = {} as Dictionary<String, Boolean>;
        var localKeys = _localPlaylistChecksums.keys();

        for (var i = 0; i < _playlists.size(); i++) {
            remotePlaylistKeys[_playlists[i].getKey()] = true;
        }

        for (var i = 0; i < localKeys.size(); i++) {
            var playlistKey = localKeys[i];

            if (!remotePlaylistKeys.hasKey(playlistKey)) {
                _operations.add({
                    "type" => "REMOVE_PLAYLIST",
                    "playlistKey" => playlistKey
                } as SyncOperationType);
            }
        }
    }

    private function reconcileTracks(playlist as PlaylistResource) as Void {
        var tracks = playlist.getTracks();

        for (var i = 0; i < tracks.size(); i++) {
            var track = tracks[i];
            var localChecksum = _localTrackChecksums[track.getLogicalId()];

            // New track
            if (localChecksum == null) {
                addTrackOperation("DOWNLOAD_TRACK", playlist, track);
            }
            // Updated track
            else if (!localChecksum.equals(track.getChecksum())) {
                addTrackOperation("UPDATE_TRACK", playlist, track);
            }
            // Unchanged track
        }
    }

    private function addPlaylistOperation(type as String, playlist as PlaylistResource) as Void {
        _operations.add({
            "type" => type,
            "playlistKey" => playlist.getKey(),
            "playlist" => playlist
        } as SyncOperationType);
    }

    private function addTrackOperation(type as String, playlist as PlaylistResource, track as AudioResource) as Void {
        _operations.add({
            "type" => type,
            "playlistKey" => playlist.getKey(),
            "logicalId" => track.getLogicalId(),
            "track" => track
        } as SyncOperationType);
    }
}