import Toybox.Lang;

class AudioTrackFields {
    var _dict as Dictionary;

    function initialize(dict as Dictionary) {
        _dict = dict;
    }

    function getStringOrDefault(key as String, defaultVal as String) as String {
        if (_dict.hasKey(key)) {
            return _dict[key] as String;
        }
        return defaultVal;
    }

    function getString(key as String) as String {
        return getStringOrDefault(key, "");
    }

    function getNumberOrDefault(key as String, defaultVal as Number) as Number {
        if (_dict.hasKey(key)) {
            return _dict[key] as Number;
        }
        return defaultVal;
    }

    function getNumber(key as String) as Number {
        return getNumberOrDefault(key, 0);
    }
}
