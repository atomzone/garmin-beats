import Toybox.Application;
import Toybox.Lang;
import Toybox.Media;

// This class handles events from the system's media
// player. getContentIterator() returns an iterator
// that iterates over the songs configured to play.
class pumpContentDelegate extends Media.ContentDelegate {
    var contentIterator as ContentIterator;
    var playlist as Playlist = new Playlist([]);
    var songEventHandler as SongEventHandler;

    function initialize(args as PersistableType?) {
        ContentDelegate.initialize();

        if (args != null) {
            self.playlist = buildPlaylist((args as Dictionary)["playlist"] as Array<Object>);
        }
        self.songEventHandler = new SongEventHandler(self.playlist);

        self.contentIterator = resetContentIterator();
    }

    // Returns an iterator that is used by the system to play songs.
    // A custom iterator can be created that extends Media.ContentIterator
    // to return only songs chosen in the sync configuration mode.
    function getContentIterator() as ContentIterator? {
        $.am.debug("getContentIterator");
        // if (self.playlist == null || self.playlist.getTrackCount() == 0) {
        //     return null;
        // }

        return self.contentIterator;
    }

    // Respond to a user ad click
    function onAdAction(adContext as Object) as Void {
        $.am.debugWithArgs("onAdAction", adContext);
    }

    function onCustomButton(button as CustomButton) as Void {
        $.am.debugWithArgs("onCustomButton", button);
    }

    function onRepeat() as Void {
        $.am.debug("onRepeat");
    }
    
    // Respond to a command to turn shuffle on or off
    function onShuffle() as Void {
        $.am.debug("onShuffle");
    }

    // Handles a notification from the system that an event has
    // been triggered for the given song
    function onSong(contentRefId as Object, songEvent as SongEvent, playbackPosition as Number or PlaybackPosition) as Void {
        self.songEventHandler.notify(contentRefId, songEvent, playbackPosition);
    }

    // Respond to a thumbs-down action
    function onThumbsDown(contentRefId as Object) as Void {
        $.am.debugWithArgs("onThumbsDown", contentRefId);
    }

    // Respond to a thumbs-up action
    function onThumbsUp(contentRefId as Object) as Void {
        $.am.debugWithArgs("onThumbsUp", contentRefId);
    }

    function resetContentIterator() as ContentIterator or Null {
        return new pumpContentIterator(self.playlist);
    }
}
