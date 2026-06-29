import Toybox.Lang;

typedef AudioChapterType as {
    "timestamp" as String,
    "title" as String,
};

class AudioChapter {

    private var _timestamp as String;
    private var _title as String;

    function initialize(raw as AudioChapterType) {
        _timestamp = raw["timestamp"] as String;
        _title = raw["title"] as String;
    }

    public function getTitle() as String {
        return _title;
    }

    public function getTimeInSeconds() as Number {
        return 1;
    }

    public function serialize() as AudioChapterType {
        return {
            "timestamp" => _timestamp,
            "title" => _title,
        };
    }

    // https://developer.garmin.com/connect-iq/api-docs/Toybox/Time/Duration.html
    private function timestampToSeconds(timestamp as String) as Number {
        var hours = (_timestamp.substring(0, 2) as String).toNumber() as Number;
        var minutes = (_timestamp.substring(3, 5) as String).toNumber() as Number;
        var seconds = (_timestamp.substring(6, 8) as String).toNumber() as Number;

        return hours * 3600 + minutes * 60 + seconds;
    }

    static function fromArray(raw as Array<AudioChapterType>) as Array<AudioChapter> {
        var assets = [];

        for (var index = 0, limit = raw.size(); index < limit; index++) {
            assets.add(new AudioChapter(raw[index]));
        }

        return assets;
    }

    static function serializeArray(chapters as Array<AudioChapter>) as Array<AudioChapterType> {
        var serialized = [] as Array<AudioChapterType>;

        for (var index = 0, limit = chapters.size(); index < limit; index++) {
            serialized.add(chapters[index].serialize());
        }

        return serialized;
    }
}
