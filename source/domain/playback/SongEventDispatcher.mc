using Toybox.Media; 
import Toybox.Lang;

typedef SongEventHandlerType as Method(
    contentRefId as Object,
    songEvent as Media.SongEvent,
    playbackPosition as Number or Media.PlaybackPosition
) as Void;

class SongEventDispatcher {

    private var _handlers as Array<SongEventHandlerType> = [];

    function initialize(handlers as Array<SongEventHandlerType>) {
        _handlers = handlers;
    }

    // Broadcast an event to all registered handlers.
    function dispatch(
        contentRefId as Object,
        songEvent as Media.SongEvent,
        playbackPosition as Number or Media.PlaybackPosition
    ) as Void {
        for (var i = 0; i < _handlers.size(); i++) {
            _handlers[i].invoke(
                contentRefId,
                songEvent,
                playbackPosition
            );
        }
    }
}