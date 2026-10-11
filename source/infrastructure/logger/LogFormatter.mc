import Toybox.Lang;

typedef LogFormatter as interface {
    function format(entry as LogEntry) as String;
};

class StringLogFormatter {
    function format(entry as LogEntry) as String {
        var result = "[" + entry.level + "] " + entry.message;

        if (entry.args == null) {
            return result;
        }

        var argString = "";
        var keys = (entry.args as Dictionary<String, Object?>).keys();
        var values = (entry.args as Dictionary<String, Object?>).values();

        for(var i = 0, max = keys.size(); i < max; i++) {
            argString += keys[i] + "=" + values[i] + ", ";
        }

        return result + " { " + argString.substring(0, argString.length() - 2) + " }";
    }
}
