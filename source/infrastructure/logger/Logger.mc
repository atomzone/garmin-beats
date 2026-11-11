import Toybox.Lang;

// The build-specific threshold lets the optimizer 
// fold disabled log branches away and remove the 
// resulting empty methods and calls
// https://youtu.be/bxjmiD-Qfv4
class Logger {

    (:debug)
    static const MIN_SEVERITY = LogEntry.DEBUG;

    (:release)
    static const MIN_SEVERITY = LogEntry.INFO;

    var _writers as Array<LogWriter>;

    function initialize(writers as Array<LogWriter>) {
        _writers = writers;
    }

    function debug(message as String, args as LogEntryArgsType?) as Void {
        if (MIN_SEVERITY <= LogEntry.DEBUG) {
            log(LogEntry.DEBUG, message, args);
        }
    }

    function info(message as String, args as LogEntryArgsType?) as Void {
        if (MIN_SEVERITY <= LogEntry.INFO) {
            log(LogEntry.INFO, message, args);
        }
    }

    function warn(message as String, args as LogEntryArgsType?) as Void {
        if (MIN_SEVERITY <= LogEntry.WARN) {
            log(LogEntry.WARN, message, args);
        }
    }

    function error(message as String, args as LogEntryArgsType?) as Void {
        if (MIN_SEVERITY <= LogEntry.ERROR) {
            log(LogEntry.ERROR, message, args);
        }
    }

    private function log(
        level as LogEntry.LogLevel,
        message as String,
        args as LogEntryArgsType?
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
