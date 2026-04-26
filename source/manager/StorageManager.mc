import Toybox.Application;
import Toybox.Lang;

typedef StorageKey as String;
typedef StorageValue as Storage.ValueType;
typedef PartitionStore as Dictionary<StorageKey, StorageValue>;

class StorageManager {
    private var _partition as String;
    
    function initialize(partition as String) {
        _partition = partition;
    }
    
    function get(key as StorageKey) as StorageValue? {
        var store = getStore();
        return store.get(key);
    }
    
    function set(key as StorageKey, value as StorageValue) as Void {
        var store = getStore();
        store.put(key, value);
        persist(store);
    }
    
    function delete(key as StorageKey) as Void {
        var store = getStore();
        store.remove(key);
        persist(store);
    }
    
    function hasKey(key as StorageKey) as Boolean {
        var store = getStore();
        return store.hasKey(key);
    }
    
    function getOrDefault(key as StorageKey, defaultValue as StorageValue) as StorageValue {
        var value = get(key);
        return (value != null) ? value : defaultValue;
    }
    
    private function getStore() as PartitionStore {
        var stored = Storage.getValue(_partition as Storage.KeyType);
        if (stored instanceof Dictionary) {
            return stored as PartitionStore;
        }
        return {} as PartitionStore;
    }
    
    private function persist(store as PartitionStore) as Void {
        Storage.setValue(_partition as Storage.KeyType, store as StorageValue);
    }
}