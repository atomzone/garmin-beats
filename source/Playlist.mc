import Toybox.Lang;

class Playlist {
    private var tracks as Array<AudioFile> = [];
    private var trackCount as Number = 0;
    private var playIndex as Number = 0;

    function initialize(tracks as Array<Object>) {
        self.addTracks(tracks);
        self.trackCount = tracks.size();
    }

    function addTrack(trackRef as Object) as Void {
        self.tracks.add(new AudioFile(trackRef));
    }

    function addTracks(trackRefs as Array<Object>) as Void {
        for (var index = 0; index < trackRefs.size(); ++index) {
            self.addTrack(trackRefs[index]);
        }
    }

    function getActiveIndex() as Number {
        return self.playIndex;
    }

    function getTrackByIndex(index as Number) as AudioFile {
        return self.tracks[index];
    }

    function isValidIndex(index as Number) as Boolean {
        return !(index < 0 or index > self.trackCount - 1);
    }

    function setActiveIndex(index as Number) as Void {
        self.playIndex = index;
    }
}
