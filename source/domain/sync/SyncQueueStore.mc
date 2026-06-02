using Toybox.Application.Storage as Storage;
import Toybox.Lang;

class SyncQueueStore {

    static function load() as Array<QueueTransactionType> {
        return StorageManager.loadOrDefault("QUEUE", []) as Array<QueueTransactionType>;
    }

    static function save(queue as Array<QueueTransactionType>) as Void {
        StorageManager.save("QUEUE", queue as Storage.ValueType);
    }

    static function getSize() as Number {
        $.am.debug("[QueueStore.getSize] CHECK");
        return load().size(); // could cache in mem
    }
}