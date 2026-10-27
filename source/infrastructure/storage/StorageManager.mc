using Toybox.Application.Storage as Storage;
using Toybox.System;
import Toybox.Lang;

class StorageManager {

    static function load(key as Storage.KeyType) as Storage.ValueType? {
        return Storage.getValue(key);
    }

    static function loadOrDefault(key as Storage.KeyType, defaultValue as Storage.ValueType) as Storage.ValueType {
        var value = load(key);
        return (value != null) ? value : defaultValue;
    }
    
    static function save(key as Storage.KeyType, value as Storage.ValueType) as Boolean {
        try {
            Storage.setValue(key, value);
            return true;
        } catch (ex) {
            // println only: the logger persists via this method and would recurse
            System.println("[StorageManager.save] failed: " + key + " " + ex.getErrorMessage());
            return false;
        }
    }

    static function remove(key as Storage.KeyType) as Void {
        Storage.deleteValue(key);
    }
}