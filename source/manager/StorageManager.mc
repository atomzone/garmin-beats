import Toybox.Application;
import Toybox.Lang;

typedef StorageDict as Dictionary<String, StorageDict>;

class StorageManager {

    static function get(key as Storage.KeyType) as Storage.ValueType? {
        return Application.Storage.getValue(key);
    }

    static function getOrDefault(key as Storage.KeyType, defaultValue as Storage.ValueType) as Storage.ValueType {
        var value = get(key);
        return (value != null) ? value : defaultValue;
    }

    static function getArray(key as Storage.KeyType) as Array {
        var value = get(key);
        return (value instanceof Array) ? value as Array: [];
    }
    
    static function set(key as Storage.KeyType, value as Storage.ValueType) as Void {
        Application.Storage.setValue(key, value);
    }

    static function delete(key as Storage.KeyType) as Void {
        Application.Storage.deleteValue(key);
    }
}