import Toybox.Lang;

// interface for static?
typedef LogFormatter as interface {
    function format(entry as LogEntry) as String;
};

// unstructured
class StringLogFormatter {
    public static function format(entry as LogEntry) as String {
        var result = "[" + entry.level + "] " + entry.message;

        if (entry.args == null) {
            return result;
        }

        var argString = "\n\t";
        var keys = (entry.args as Dictionary<String, Object?>).keys();
        var values = (entry.args as Dictionary<String, Object?>).values();

        for(var i = 0, max = keys.size(); i < max; i++) {
            argString += keys[i] + " = '" + values[i] + "'\n\t";
        }

        return result + argString.substring(0, argString.length() - 2);
    }
}

// structured

typedef StructuredLogType as {
    "timestamp" as Number,
    "level" as LogEntry.LogLevel,
    "message" as String,
    "args" as Dictionary<String, String>
};

class StructuredLogFormatter {
    public static function format(entry as LogEntry) as StructuredLogType {
        return {
            "timestamp" => entry.timestamp,
            "level" => entry.level,
            "message" => entry.message,
            "args" => StructuredLogFormatter.formatArgs(entry.args)
        };
    }

    private static function formatArgs(args as Dictionary?) as Dictionary<String, String> {
        var argList = {} as Dictionary<String, String>;

        if (args == null) {
            return argList;
        }

        var keys = args.keys() as Array<String>;
        var values = args.values() as Array<Object?>;

        for(var i = 0, max = keys.size(); i < max; i++) {
            var value = values[i] == null ? "null" : (values[i] as Object).toString();
            argList.put(keys[i], value);
        }

        return argList;
    }
}
