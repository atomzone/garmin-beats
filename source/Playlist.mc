import Toybox.Lang;

typedef TTrack as Object;
typedef TTracks as Array<TTrack>;

class Playlist {
    private var tracks as TTracks = [];
    private var trackCount as Number = 0;
    private var playIndex as Number = 0;

    function initialize(tracks as TTracks) {
        self.tracks = tracks;
        self.trackCount = tracks.size();
    }

    function getActiveIndex() as Number {
        return self.playIndex;
    }

    function getTrack(index as Number) as TTrack {
        return self.tracks[index];
    }

    function isValidIndex(index as Number) as Boolean {
        return !(index < 0 or index > self.trackCount - 1);
    }

    function setActiveIndex(index as Number) as Void {
        self.playIndex = index;
    }
}
