import Toybox.Application.Storage;
import Toybox.Lang;

typedef StorageDict as Dictionary<String, StorageDict>;

class StorageManager {

    static function get(key as Storage.KeyType) as Storage.ValueType? {
        return Storage.getValue(key);
    }

    static function getOrDefault(key as Storage.KeyType, defaultValue as Storage.ValueType) as Storage.ValueType {
        var value = get(key);
        return (value != null) ? value : defaultValue;
    }
    
    static function set(key as Storage.KeyType, value as Storage.ValueType) as Void {
        Storage.setValue(key, value);
    }

    static function delete(key as Storage.KeyType) as Void {
        Storage.deleteValue(key);
    }
}