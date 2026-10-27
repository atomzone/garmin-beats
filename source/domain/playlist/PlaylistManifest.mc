import Toybox.Lang;

// What the source says a playlist should be (tracks in source order), kept while it syncs.
// The stored playlist is always derived from it: manifest tracks that exist on the watch.
class PlaylistManifest {

    static function save(resource as PlaylistResource) as Boolean {
        return AppStores.playlistManifests.save(resource.getId(), {
            "id" => resource.getId(),
            "metadata" => resource.getMetadata().serialize(),
            "trackIds" => resource.getTrackIds()
        } as PlaylistAssetType);
    }

    static function remove(playlistId as String) as Void {
        AppStores.playlistManifests.remove(playlistId);
    }

    // Returns false only when storage refused the write
    static function rebuild(playlistId as String) as Boolean {
        var manifest = AppStores.playlistManifests.load(playlistId) as PlaylistAssetType?;

        if (manifest == null) {
            return true;
        }

        var desired = manifest["trackIds"] as Array<String>;
        var present = [] as Array<String>;

        for (var i = 0, limit = desired.size(); i < limit; i++) {
            if (AppStores.tracks.contains(desired[i])) {
                present.add(desired[i]);
            }
        }

        // a playlist only exists once it has at least one track
        if (present.size() == 0) {
            AppStores.playlists.remove(playlistId);
            return true;
        }

        var asset = new PlaylistAsset({
            "id" => playlistId,
            "metadata" => manifest["metadata"],
            "trackIds" => present
        } as PlaylistAssetType);

        return AppStores.playlists.save(playlistId, asset.serialize());
    }
}
