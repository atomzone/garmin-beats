import Toybox.Lang;
import Toybox.Media;

class Playlist {
    private var tracks as Array<AudioFile> = [];
    private var trackCount as Number = 0;
    private var playIndex as Number = 0;

    function initialize(tracks as Array<AudioFile>) {
        self.tracks = tracks;
        self.trackCount = tracks.size();
    }

    function getActiveIndex() as Number {
        return self.playIndex;
    }

    function getFileByIndex(index as Number) as AudioFile {
        return self.tracks[index];
    }

    // TODO: Remove?
    // is this needed, or just have the `getFileByIndex` -> getContent()
    function getContentByIndex(index as Number) as Media.Content? {
        return self.getFileByIndex(index).getContent();
    }

    function isValidIndex(index as Number) as Boolean {
        return !(index < 0 or index > self.trackCount - 1);
    }

    function setActiveIndex(index as Number) as Void {
        self.playIndex = index;
    }
}

// Convert array of Media.ContentRef.Id to Playlist of Audiofiles
function buildPlaylist(mediaRefs as Array<Object>) as Playlist {
    var tracks = [];

    for (var index = 0; index < mediaRefs.size(); ++index) {
        tracks.add(new AudioFile(mediaRefs[index]));
    }

    return new Playlist(tracks);
}
