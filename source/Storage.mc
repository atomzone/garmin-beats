import Toybox.Application;
import Toybox.Lang;

/*
SOME PERF NOTES
EVEN THOUGH (TO ME) THIS IS AN EXCEPTIBLE PATTERN
STACKING UP FUNCTIONS IS COSTLY TO THE PERFORMANCE
AND SHOULD BE CONSIDERED "BAD" DESIGN FOR THE TARGET DEVICE
*/

// ** dangerous! trading memory for storage **
// simple inmemory cache
// should limit by KB (shards)
class Cache {
    private var cache as Dictionary<String, PersistableType> = {} as Dictionary<String, PersistableType>;

    function get(key as String) as PersistableType {
        var value = self.cache.get(key);

        if (value == null) {
            value = Application.Storage.getValue(key);
            self.cache.put(key, value);
        }

        return value;
    }

    function set(key as String, value as PersistableType) as Void {
        self.cache.put(key, value);
        Application.Storage.setValue(key, value);
    }
}

// currentlt the storage is like 
//  {"TRACK" => {"id-1" => "my track", "id-2" => "my track"}}
// but it could be
//  {"TRACK"+"id-1" => "my track", "TRACK"+"id-2" => "my track"}
// then individual lookups are possible
// but is this quicker?
// and how could we delete ALL entries?

// namespaced key=>value system storage
// Keys and values are limited to 8 KB each, and a total of 128 KB of storage is available.
class Storage {
    private var cache as Cache = new Cache();
    private var partition as String;

    function initialize(partition as String) {
        self.partition = partition;
    }

    function delete(key as PropertyKeyType) as Void {
        var store = self.getAll();
        store.remove(key);
        persist(store);
    }

    function empty() as Void {
        persist(null);
    }

    function get(key as PropertyKeyType) as PersistableType {
        return self.getAll().get(key);
    }

    function getAll() as PersistableType {
        var value = self.cache.get(self.partition);
        return (value != null) ? value : {} as Dictionary<String, PersistableType>;
    }

    function isEmpty() as Boolean {
        return self.getAll().isEmpty();
    }

    function persist(value as PersistableType) as Void {
        self.cache.set(self.partition, value);
    }

    function put(key as PropertyKeyType, value as PersistableType) as Void {
        var store = self.getAll();
        store.put(key, value);
        persist(store);
    }
}
