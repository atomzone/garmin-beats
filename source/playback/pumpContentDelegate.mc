import Toybox.Application;
import Toybox.Lang;
import Toybox.Media;

// This class handles events from the system's media
// player. getContentIterator() returns an iterator
// that iterates over the songs configured to play.
class pumpContentDelegate extends Media.ContentDelegate {
    var playlist as Playlist = new Playlist([]);
    var songEventHandler as SongEventHandler;

    function initialize(args as PersistableType?) {
        ContentDelegate.initialize();

        if (args != null) {
            self.playlist = buildPlaylist((args as Dictionary)["playlist"] as Array<Object>);
        }
        self.songEventHandler = new SongEventHandler(self.playlist);
    }

    // Returns an iterator that is used by the system to play songs.
    // A custom iterator can be created that extends Media.ContentIterator
    // to return only songs chosen in the sync configuration mode.
    function getContentIterator() as ContentIterator? {
        return new pumpContentIterator(self.playlist);
    }

    // Respond to a user ad click
    function onAdAction(adContext as Object) as Void {
    }

    // Respond to a thumbs-up action
    function onThumbsUp(contentRefId as Object) as Void {
    }

    // Respond to a thumbs-down action
    function onThumbsDown(contentRefId as Object) as Void {
    }

    // Respond to a command to turn shuffle on or off
    function onShuffle() as Void {
    }

    // Handles a notification from the system that an event has
    // been triggered for the given song
    function onSong(contentRefId as Object, songEvent as SongEvent, playbackPosition as Number or PlaybackPosition) as Void {
        self.songEventHandler.notify(contentRefId, songEvent, playbackPosition);
    }
}
