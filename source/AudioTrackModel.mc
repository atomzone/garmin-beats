import Toybox.Lang;

class AudioTrackModel {
    var id as String;
    var image as String;
    var title as String;
    var artist as String;
    var durationSeconds as Number;
    var album as String;
    var genre as String;

    function initialize(fields as AudioTrackFields) {
        id = fields.getString("id");
        image = fields.getString("image");
        title = fields.getString("title");
        artist = fields.getString("artist");
        durationSeconds = fields.getNumber("duration");
        album = fields.getString("album");
        genre = fields.getString("genre");
    }

    function getReadableDuration() as String {
        var minutes = durationSeconds / 60.0;
        var seconds = durationSeconds % 60;
        return minutes + ":" + (seconds < 10 ? "0" + seconds : seconds);
    }

    function getDescription() as String {
        return artist + " - " + album + " (" + durationSeconds + ")";
    }
}
