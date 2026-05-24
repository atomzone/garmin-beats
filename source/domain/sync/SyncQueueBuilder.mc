import Toybox.Lang;

class SyncQueueBuilder {

    private var _entityChecksums as Dictionary<Symbol, Dictionary<String, String>>;

    function initialize(entityChecksums as {
        :PLAYLIST as Dictionary<String, String>,
        :TRACK as Dictionary<String, String>
    }) {
        _entityChecksums = entityChecksums;
    }

    // make queue tasks
    // future - this builder will
    // - check the playlist/track against local stored assets
    // - by comparing checksums
    // - todo/descide if tracks are unique or shared across pl
    function buildQueue(playlists as Array<PlaylistResource>) as Array<QueueTransactionType> {
        var playlistChecksums = _entityChecksums[:PLAYLIST] as Dictionary<String, String>;
        var trackChecksums = _entityChecksums[:TRACK] as Dictionary<String, String>;

        var queue = [];

        for (var index = 0, limit = playlists.size(); index < limit; index++) {
            var playlist = playlists[index];
            var localChecksum = playlistChecksums[playlist.getId()];

            // $.am.debug("[playlist]canonicalize " + playlist.canonicalize());
            $.am.debug("[playlist]getChecksum '" 
                + playlist.getId() + "' => '" + playlist.getChecksum() 
                + "' Vs '" + localChecksum + "'");

            // New playlist
            if (localChecksum == null) {
                queue.add({
                    "tid" => playlist.getId(),
                    "op" => "CREATE",
                    "entity" => "PLAYLIST",
                    "payload" => { 
                        "metadata" => playlist.getMetadata().serialize(),
                        "trackIds" => playlist.getTrackIds()
                    }
                });
                // optimisation: load all track without checking...
            }
            // Updated playlist
            else if (!localChecksum.equals(playlist.getChecksum())) {
                queue.add({
                    "tid" => playlist.getId(),
                    "op" => "UPDATE",
                    "entity" => "PLAYLIST",
                    "payload" => { 
                        "metadata" => playlist.getMetadata().serialize(),
                        "trackIds" => playlist.getTrackIds()
                    }
                });
            }
            // Unchanged playlist
            else {
                continue;
            }

            var tracks = playlist.getTracks();
            for (var index2 = 0, limit2 = tracks.size(); index2 < limit2; index2++) {
                var track = tracks[index2];
                var trackCheck = trackChecksums[track.getLogicalId()];

                // $.am.debug("[track]canonicalize " + track.canonicalize());
                $.am.debug("[TRACK]getChecksum '" 
                    + track.getLogicalId() + "' => '" + track.getChecksum() 
                    + "' VS '" + trackCheck + "'");

                // New track
                if (trackCheck == null) {
                    queue.add({
                        "tid" => track.getId(),
                        "op" => "CREATE",
                        "entity" => "TRACK", // MediaAsset!
                        "payload" => {
                            "source" => track.getSource().serialize(),
                            "metadata" => track.getMetadata().serialize(),
                        }
                    });
                }
                // Updated track
                else if (!trackCheck.equals(track.getChecksum())) {
                    queue.add({
                        "tid" => track.getId(),
                        "op" => "UPDATE",
                        "entity" => "TRACK",
                        "payload" => track.serialize()
                    });
                }
                // Unchanged track 
            }

            // consider delete, no payload
            // queue.add({
            //     "tid" => track.getLogicalId(),
            //     "op" => "DELETE",
            //     "entity" => "TRACK",
            //     "payload" => null
            // });
        }

        return queue;
    }
}