import Toybox.Lang;

class JellyfinAudioTranslator extends AudioTrackTranslator {
    function translate(source as Dictionary) as AudioTrackModel {
        var durationTicks = source.hasKey("RunTimeTicks") ? source["RunTimeTicks"] : 0;
        var durationSec = durationTicks / 10000000.0; // 10,000,000 ticks per second

        var genre = "";
        if (source.hasKey("Genres")) {
            var genres = source["Genres"];
            if (genres != null and genres.size() > 0) {
                genre = genres[0];
            }
        }

        var fields = new AudioTrackFields({
            "id" => source["Id"],
            "title" => source["Name"],
            "artist" => source["AlbumArtist"],
            "duration" => durationSec,
            "album" => source["Album"],
            "genre" => genre
        });

        return new AudioTrackModel(fields);
    }
}

