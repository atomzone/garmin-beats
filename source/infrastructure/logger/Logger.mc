import Toybox.Lang;

class Logger {
    var _writers as Array<LogWriter>;

    function initialize(writers as Array<LogWriter>) {
        _writers = writers;
    }

    function debug(message as String, args as Dictionary<String, Object?>?) as Void {
        log(LogEntry.DEBUG, message, args);
    }

    function info(message as String, args as Dictionary<String, Object?>?) as Void {
        log(LogEntry.INFO, message, args);
    }

    function warn(message as String, args as Dictionary<String, Object?>?) as Void {
        log(LogEntry.WARN, message, args);
    }

    function error(message as String, args as Dictionary<String, Object?>?) as Void {
        log(LogEntry.ERROR, message, args);
    }

    private function log(
        level as LogEntry.LogLevel,
        message as String,
        args as Dictionary<String, Object?>?
    ) as Void {
        for (var i = 0, max = _writers.size(); i < max; i++) {
            if (LogEntry.isAtLeast(level, _writers[i].getMinimumLevel())) {
                _writers[i].write(
                    new LogEntry(level, message, args)
                );
            }
        }
    }
}
