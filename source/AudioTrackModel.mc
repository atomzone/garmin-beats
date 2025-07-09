import Toybox.Lang;

class AudioTrackModel {
    var id as String;
    var title as String;
    var artist as String;
    var durationSeconds as Number;
    var album as String;
    var genre as String;

    function initialize(fields as AudioTrackFields) {
        id = fields.getString("id");
        title = fields.getString("title");
        artist = fields.getString("artist");
        durationSeconds = fields.getNumber("duration");
        album = fields.getString("album");
        genre = fields.getString("genre");
    }
}
