import Toybox.Lang;

// Currently unused: no call sites in source.
class DictionaryUtils {

    private static function getValue(record as Dictionary?, key as String) as Object? {
        if (record == null || !record.hasKey(key) || record[key] == null) {
            return null;
        }

        return record[key] as Object;
    }

    static function getString(record as Dictionary?, key as String) as String? {
        var value = getValue(record, key);
        if (value == null) {
            return null;
        }

        var stringValue = value as String;
        return stringValue.equals("") ? null : stringValue;
    }

    static function getStringOrDefault(record as Dictionary?, key as String, defaultValue as String) as String {
        return StringUtils.stringOrDefault(getString(record, key), defaultValue);
    }

    static function getNumber(record as Dictionary?, key as String) as Number? {
        var value = getValue(record, key);
        return (value == null) ? null : (value as Number);
    }

    static function getBoolean(record as Dictionary?, key as String) as Boolean? {
        var value = getValue(record, key);
        return (value == null) ? null : (value as Boolean);
    }

    static function getBooleanOrDefault(record as Dictionary?, key as String, defaultValue as Boolean) as Boolean {
        var value = getBoolean(record, key);
        return (value == null) ? defaultValue : (value as Boolean);
    }
}