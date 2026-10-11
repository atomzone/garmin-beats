import Toybox.Lang;

class LogEntry {
    enum LogLevel {
        DEBUG,
        INFO,
        WARN,
        ERROR
    }

    var timestamp as Number;
    var level as LogLevel;
    var message as String;
    var args as Dictionary<String, Object?>?;

    function initialize(
        level as LogLevel,
        message as String,
        args as Dictionary<String, Object?>?
    ) {
        timestamp = Time.now().value();
        self.level = level;
        self.message = message;
        self.args = args;
    }

    static function severity(level as LogLevel) as Number {
        switch (level) {
            case DEBUG: return 0;
            case INFO: return 1;
            case WARN: return 2;
            case ERROR: return 3;
        }
        return 0;
    }

    static function isAtLeast(level as LogLevel, minimum as LogLevel) as Boolean {
        return severity(level) >= severity(minimum);
    }
}
