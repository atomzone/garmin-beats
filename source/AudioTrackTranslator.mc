import Toybox.Lang;

class AudioTrackTranslator {
    /*
     * Abstract method to convert a source object (Dictionary or other)
     * into an AudioTrackModel.
     *
     * Subclasses must override this.
     */
    function translate(source as Dictionary) as AudioTrackModel {
        throw new Exception();
    }
}