import Toybox.Application;
import Toybox.Lang;

/*
SOME PERF NOTES
EVEN THOUGH (TO ME) THIS IS AN EXCEPTIBLE PATTERN
STACKING UP FUNCTIONS IS COSTLY TO THE PERFORMANCE
AND SHOULD BE CONSIDERED "BAD" DESIGN FOR THE TARGET DEVICE
*/

typedef ApplicationStore as Dictionary<PropertyKeyType, PersistableType>;

// ** dangerous! trading memory for storage **
// Simple in-memory store
class Store {
    private var store as Dictionary<String, ApplicationStore> = {} as Dictionary<String, ApplicationStore>;

    function empty(key as String) as Void {
        self.store.remove(key);
        Application.Storage.deleteValue(key);
    }

    function get(key as String) as ApplicationStore? {
        var value = self.store.get(key);

        if (value == null) {
            value = Application.Storage.getValue(key) as ApplicationStore;
            self.store.put(key, value);
        }

        return value;
    }

    function set(key as String, value as ApplicationStore) as Void {
        self.store.put(key, value);
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
class StorageManager {
    private var store as Store = new Store();
    private var partition as String;

    function initialize(partition as String) {
        self.partition = partition;
    }

    function delete(key as PropertyKeyType) as Void {
        var storage = self.getAll();
        storage.remove(key);
        persist(storage);
    }

    function empty() as Void {
        self.store.empty(self.partition);
    }

    function get(key as PropertyKeyType) as PersistableType {
        return self.getAll().get(key);
    }

    private function getAll() as ApplicationStore {
        var storage = self.store.get(self.partition);
        return (storage != null) ? storage : {} as ApplicationStore;
    }

    function isEmpty() as Boolean {
        return self.getAll().isEmpty();
    }

    private function persist(value as ApplicationStore) as Void {
        self.store.set(self.partition, value);
    }

    // should rename set, like Store
    function put(key as PropertyKeyType, value as PersistableType) as Void {
        var storage = self.getAll();
        storage.put(key, value);
        persist(storage);
    }
}
