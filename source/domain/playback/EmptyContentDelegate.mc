using Toybox.Media as Media;
import Toybox.Lang;

class EmptyContentDelegate extends Media.ContentDelegate {

    function initialize() {
        Media.ContentDelegate.initialize();
    }

    function getContentIterator() as Media.ContentIterator? {
        // Returning null seems to crash the simulator, so return an empty iterator instead
        return new EmptyContentIterator();
    }
}

class EmptyContentIterator extends Media.ContentIterator {

    function initialize() {
        Media.ContentIterator.initialize();
    }

    function getPlaybackProfile() as Media.PlaybackProfile? {
        // Returning null seems to crash the simulator, so return an empty profile instead
        return new PlaybackProfile();
    }
}