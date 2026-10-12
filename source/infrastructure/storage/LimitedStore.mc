
using Toybox.Application.Storage as Storage;
import Toybox.Lang;

class LimitedStore {
    private var _key as String;
    private var _maxEntries as Number;

    function initialize(key as String, maxEntries as Number) {
        _key = key;
        _maxEntries = maxEntries;
    }

    function append(entry as Storage.ValueType) as Void {
        var entries = StorageManager.loadOrDefault(_key, []) as Array<Storage.ValueType>;

        if (entries.size() >= _maxEntries) {
            entries.remove(entries[0]);
        }

        entries.add(entry);
        StorageManager.save(_key, entries);
    }

    function read() as Array<Storage.ValueType> {
        return StorageManager.loadOrDefault(_key, []) as Array<Storage.ValueType>;
    }

    function clear() as Void {
        StorageManager.remove(_key);
    }
}
