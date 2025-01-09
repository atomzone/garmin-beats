import Toybox.Application;
import Toybox.Lang;

// namespaced key=>value system storage
// Keys and values are limited to 8 KB each, and a total of 128 KB of storage is available.
class Storage {
    var partition as String;

    function initialize(partition as String) {
        self.partition = partition;
        // empty();
    }

    function delete(key as PropertyKeyType) as Void {
        var store = getAll();
        store.remove(key);
        persist(store);
    }

    function empty() as Void {
        persist(null);
    }

    // GETALL SHOULD BE CACHED?
    // REDUCE LOOKUPS
    // currentlt the storage is like 
    //  {"TRACK" => {"id-1" => "my track", "id-2" => "my track"}}
    // but it could be
    //  {"TRACK"+"id-1" => "my track", "TRACK"+"id-2" => "my track"}
    // then individual lookups are possible
    // but is this quicker?
    // and how could we delete ALL entries?
    function get(key as PropertyKeyType) as PersistableType {
        var store = getAll();
        return store.get(key);
    }

    function getAll() as PersistableType {
        var value = Application.Storage.getValue(self.partition);
        return (value != null) ? value : {};
    }

    function isEmpty() as Boolean {
        var store = getAll();
        return store.isEmpty();
    }

    function persist(value as PersistableType) as Void {
        Application.Storage.setValue(self.partition, value);
    }

    function put(key as PropertyKeyType, value as PersistableType) as Void {
        var store = getAll();
        store.put(key, value);
        persist(store);
    }
}
