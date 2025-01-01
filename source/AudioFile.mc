import Toybox.Lang;
import Toybox.Media;

class AudioFile {
    var refId as Object;

    // store the index to allow serialisation to storage
    function initialize(refId as Object) {
        self.refId = refId;
    }
}
