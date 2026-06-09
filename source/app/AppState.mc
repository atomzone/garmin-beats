
import Toybox.Lang;

class AppState {
    
    private var _revision as Number = 0;

    public function getRevision() as Number {
        return _revision;
    }

    public function getTrackCount() as Number {
        return AppStores.tracks.count();
    }

    public function hasRevisionChanged(revision as Number) as Boolean {
        return revision != _revision;
    }

    public function hasMedia() as Boolean {
        return AppStores.playlists.count() > 0;
    } 

    public function notifyChanged() as Void {
        _revision += 1;
    }
}
