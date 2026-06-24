
import Toybox.Lang;

class AppState {
    
    public function getRevision() as String {
        return Lang.format(
            "$1$:$2$:$3$:$4$", [
                AppStores.playlists.getRevision(),
                AppStores.tracks.getRevision(),
                AppStores.media.getRevision(),
                AppStores.images.getRevision()
            ]
        );
    }

    public function getTrackCount() as Number {
        return AppStores.tracks.count();
    }

    public function hasMedia() as Boolean {
        return AppStores.playlists.count() > 0;
    }
}
