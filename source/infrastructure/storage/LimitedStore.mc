
using Toybox.Application.Storage as Storage;
import Toybox.Lang;

class LimitedStore {
    private var _key as String;
    private var _maxEntries as Number;

    function initialize(key as String, maxEntries as Number) {
        _key = key;
        _maxEntries = maxEntries;
    }

    function append(entry as String) as Void {
        var entries = StorageManager.loadOrDefault(_key, []) as Array<String>;

        if (entries.size() >= _maxEntries) {
            entries.remove(entries[0]);
        }

        entries.add(entry);
        StorageManager.save(_key, entries as Array<Storage.ValueType>);
    }

    function read() as Array<String> {
        return StorageManager.loadOrDefault(_key, []) as Array<String>;
    }

    function clear() as Void {
        StorageManager.remove(_key);
    }
}
