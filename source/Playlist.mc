import Toybox.Lang;
import Toybox.Media;

class Playlist {
    private var tracks as Array<AudioAsset> = [];
    private var trackCount as Number = 0;
    private var playIndex as Number = 0;

    function initialize(tracks as Array<AudioAsset>) {
        self.tracks = tracks;
        self.trackCount = tracks.size();
    }

    function getActiveIndex() as Number {
        return self.playIndex;
    }

    function getFileByIndex(index as Number) as AudioAsset {
        return self.tracks[index];
    }

    // TODO: Remove?
    // is this needed, or just have the `getFileByIndex` -> getContent()
    function getContentByIndex(index as Number) as Media.Content? {
        // Media.ActiveContent(
        //     contentRef as Media.ContentRef, 
        //     metadata as Media.ContentMetadata, 
        //     playbackStartPos as Lang.Number or Media.PlaybackPosition
        // )
        return self.getFileByIndex(index).getContent();
    }

    function isValidIndex(index as Number) as Boolean {
        return !(index < 0 or index > self.trackCount - 1);
    }

    function setActiveIndex(index as Number) as Void {
        self.playIndex = index;
    }
}

// Convert array of Media.ContentRef.Id to Playlist of AudioAsset
function buildPlaylist(mediaRefs as Array<Object>) as Playlist {
    var tracks = [];

    for (var index = 0; index < mediaRefs.size(); index++) {
        tracks.add(new AudioAsset(mediaRefs[index]));
    }

    return new Playlist(tracks);
}
