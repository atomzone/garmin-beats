import Toybox.Lang;

class StringUtils {

    static function hasText(value as String?) as Boolean {
        return value != null && !value.equals("");
    }

    static function stringOrDefault(value as String?, defaultValue as String) as String {
        if (value == null || value.equals("")) {
            return defaultValue;
        }

        return value as String;
    }
}