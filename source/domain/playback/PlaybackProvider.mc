using Toybox.Media as Media;
using Toybox.Graphics as Graphics;
import Toybox.Lang;

class PlaybackProvider extends Media.ContentDelegate {

    private var _playlist as PlayerPlaylist;
    private var _session as PlaybackSession;
    private var _iterator as Media.ContentIterator;
    private var _songEventDispatcher as SongEventDispatcher;

    function initialize(playlist as PlayerPlaylist, session as PlaybackSession) {
        Media.ContentDelegate.initialize();

        _playlist = playlist;
        _session = session;
        _iterator = new PlaybackQueue(playlist, session);

        _songEventDispatcher = new SongEventDispatcher([
            _session.method(:handleSongEvent),
            (new LogSongEventHandler()).method(:logSongEvent)
        ]);
    }

    function getContentIterator() as Media.ContentIterator? {
        $.am().logger().debug("[PlaybackProvider.getContentIterator]", null);
        
        return self._iterator;
    }

    // Called by the system when the queue needs to restart (e.g. repeat-all, re-entry).
    // Reset the ContentIterator to the beginning of the current playlist
    function resetContentIterator() as Media.ContentIterator? {
        $.am().logger().debug("[PlaybackProvider.resetContentIterator]", null);

        // reset iterator to the beginning of the playlist
        self._iterator = new PlaybackQueue(_playlist, _session);

        return self._iterator;
    }

    function onAdAction(adContext as Object) as Void {
        $.am().logger().debug("[onAdAction]", { "context" => adContext });
    }

    function onCustomButton(button as Media.CustomButton) as Void {
        $.am().logger().debug("[onCustomButton]", { "button" => button });
    }

    // repeatMode() is always null... 
    // do we need to make our own verion of intertor.repeatMode()?
    function onRepeat() as Void {
        var repeatModes = {
            REPEAT_MODE_OFF => "Repeat is off",
            REPEAT_MODE_ONE => "Repeat the current track",
            REPEAT_MODE_ALL => "Repeat all tracks"
        };
        var mode = _iterator.repeatMode();
        var message = (mode == null) ? "(missing repeat mode)" : repeatModes[mode] as String;

        $.am().logger().debug("[onRepeat]", { "message" => message });
    }
    
    // Respond to a command to turn shuffle on or off
    // this /seems/ to force a queue.get
    function onShuffle() as Void {
        $.am().logger().debug("[onShuffle]", null);
    }

    // Handles a notification from the system that an event has been triggered for the given song
    function onSong(
        contentRefId as Object, 
        songEvent as Media.SongEvent, 
        playbackPosition as Number or Media.PlaybackPosition
    ) as Void {
        _songEventDispatcher.dispatch(
            contentRefId,
            songEvent,
            playbackPosition
        );
        
        // move to session
        // if (songEvent == Media.SONG_EVENT_START) {
            var images = AppStores.images.loadAll();
            // System.println(images);

            if (images.size() > 0) {
                Media.setAlbumArt(images[0] as Graphics.BitmapType);
            }
        // }
    }

    // Respond to a thumbs-down action
    function onThumbsDown(contentRefId as Object) as Void {
        $.am().logger().debug("[onThumbsDown]", { "contentRefId" => contentRefId });

        // _session.setThumbsUp(true);
    }

    // Respond to a thumbs-up action
    function onThumbsUp(contentRefId as Object) as Void {
        $.am().logger().debug("[onThumbsUp]", { "contentRefId" => contentRefId });

        // _session.setThumbsUp(false);
    }
}
