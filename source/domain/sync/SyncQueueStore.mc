using Toybox.Application.Storage as Storage;
import Toybox.Lang;

class SyncQueueStore {

    private static const QUEUE_KEY as String = "QUEUE";

    static function load() as Array<QueueTransactionType> {
        return StorageManager.loadOrDefault(QUEUE_KEY, []) as Array<QueueTransactionType>;
    }

    static function save(queue as Array<QueueTransactionType>) as Boolean {
        return StorageManager.save(QUEUE_KEY, queue as Storage.ValueType);
    }

    static function getSize() as Number {
        return load().size(); // could cache in mem
    }

    static function clear() as Void {
        StorageManager.remove(QUEUE_KEY);
    }
}