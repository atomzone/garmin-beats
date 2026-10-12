using Toybox.Application.Storage as Storage;
import Toybox.Lang;

typedef LogWriter as interface {
    function getMinimumLevel() as LogEntry.LogLevel;
    function write(entry as LogEntry) as Void;
};

class ConsoleLogWriter {
    function getMinimumLevel() as LogEntry.LogLevel {
        return LogEntry.DEBUG;
    }

    function write(entry as LogEntry) as Void {
        System.println(StringLogFormatter.format(entry));
    }
}

class StorageLogWriter {
    private var _logStore as LimitedStore;

    function initialize(logStore as LimitedStore) {
        _logStore = logStore;
    }

    function getMinimumLevel() as LogEntry.LogLevel {
        return LogEntry.DEBUG; // WARN;
    }

    function write(entry as LogEntry) as Void {
        _logStore.append(StructuredLogFormatter.format(entry));
    }
}
