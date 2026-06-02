using Toybox.Application.Storage as Storage;
import Toybox.Lang;

// "{ASSET}:COUNTER" = 0
class CounterStore {
    
    static function load(partitionId as String) as Number {
        var partitionKey = buildPartitionKey(partitionId);
    
        return StorageManager.loadOrDefault(partitionKey, 0) as Number;
    }

    static function increment(partitionId as String) as Number {
        var newValue = load(partitionId) + 1;

        StorageManager.save(buildPartitionKey(partitionId), newValue);

        return newValue;
    }

    static function remove(id as String) as Void {
        StorageManager.remove(buildPartitionKey(id));
    }
     
    static private function buildPartitionKey(id as String) as String {
        return id + ":COUNTER";
    }
}