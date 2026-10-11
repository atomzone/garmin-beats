import Toybox.Lang;

typedef LogWriter as interface {
    function getMinimumLevel() as LogEntry.LogLevel;
    function write(entry as LogEntry) as Void;
};

class ConsoleLogWriter {
    var _formatter as StringLogFormatter;

    function initialize() {
        _formatter = new StringLogFormatter();
    }

    function getMinimumLevel() as LogEntry.LogLevel {
        return LogEntry.DEBUG;
    }

    function write(entry as LogEntry) as Void {
        System.println(_formatter.format(entry));
    }
}

class StorageLogWriter {
    private var _logStore as LimitedStore;
    private var _formatter as StringLogFormatter;

    function initialize(logStore as LimitedStore) {
        _logStore = logStore;
        _formatter = new StringLogFormatter();
    }

    function getMinimumLevel() as LogEntry.LogLevel {
        return LogEntry.INFO;
    }

    function write(entry as LogEntry) as Void {
        _logStore.append(_formatter.format(entry));
    }
}
