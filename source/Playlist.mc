using Toybox.Application as App;
import Toybox.Lang;
import Toybox.Media;

class Playlist {
    private var tracks as Array<AudioAsset> = [];
    private var playIndex as Number = 0;

    function initialize(tracks as Array<AudioAsset>) {
        self.tracks = tracks;
    }

    function getActiveIndex() as Number {
        return self.playIndex;
    }

    function getFileByIndex(index as Number) as AudioAsset {
        return self.tracks[index];
    }

    function getTrackCount() as Number {
        return self.tracks.size();
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
        return !(index < 0 || index > getTrackCount() - 1);
    }

    function setActiveIndex(index as Number) as Void {
        self.playIndex = index;
    }
}

// Convert array of Media.ContentRef.Id to Playlist of AudioAsset
function buildPlaylist(mediaRefs as Array<App.PropertyValueType>?) as Playlist {
    var tracks = [];

    if (mediaRefs != null) {
        for (var index = 0; index < mediaRefs.size(); index++) {
            tracks.add(new AudioAsset((mediaRefs[index] as Object)));
        }
    }

    return new Playlist(tracks);
}
