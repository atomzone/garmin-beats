using Toybox.Application.Storage as Storage;
import Toybox.Lang;

// "{ASSET}:COUNTER" = 0
class CounterStore {
    
    static function get(partitionId as String) as Number {
        var partitionKey = buildPartitionKey(partitionId);
    
        return StorageManager.getOrDefault(partitionKey, 0) as Number;
    }

    static function increment(partitionId as String) as Number {
        var newValue = get(partitionId) + 1;

        StorageManager.set(buildPartitionKey(partitionId), newValue);

        return newValue;
    }

    static function delete(id as String) as Void {
        StorageManager.delete(buildPartitionKey(id));
    }
     
    static private function buildPartitionKey(id as String) as String {
        return id + ":COUNTER";
    }
}