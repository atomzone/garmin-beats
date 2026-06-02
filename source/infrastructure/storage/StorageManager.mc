using Toybox.Application.Storage as Storage;
import Toybox.Lang;

class StorageManager {

    static function load(key as Storage.KeyType) as Storage.ValueType? {
        return Storage.getValue(key);
    }

    static function loadOrDefault(key as Storage.KeyType, defaultValue as Storage.ValueType) as Storage.ValueType {
        var value = load(key);
        return (value != null) ? value : defaultValue;
    }
    
    static function save(key as Storage.KeyType, value as Storage.ValueType) as Void {
        Storage.setValue(key, value);
    }

    static function remove(key as Storage.KeyType) as Void {
        Storage.deleteValue(key);
    }
}