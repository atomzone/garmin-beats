using Toybox.Application.Storage as Storage;
import Toybox.Lang;

class SyncQueueStore {

    private static const QUEUE_KEY as String = "QUEUE";
    private static const HEAD_KEY as String = "QUEUE_HEAD";

    static function load() as Array<QueueTransactionType> {
        return StorageManager.loadOrDefault(QUEUE_KEY, []) as Array<QueueTransactionType>;
    }

    static function save(queue as Array<QueueTransactionType>) as Boolean {
        return StorageManager.save(QUEUE_KEY, queue as Storage.ValueType);
    }

    static function getSize() as Number {
        return load().size(); // could cache in mem
    }

    // Persisted before execution so interruptions (cancel, crash, power loss) are counted
    static function incrementHeadAttempts(tid as String) as Number {
        var head = StorageManager.load(HEAD_KEY) as Dictionary<String, String or Number>?;
        var attempts = 1;

        if (head != null && tid.equals(head["tid"] as String?)) {
            attempts = (head["attempts"] as Number) + 1;
        }

        var record = { "tid" => tid, "attempts" => attempts } as Dictionary<Storage.KeyType, Storage.ValueType>;
        StorageManager.save(HEAD_KEY, record);
        return attempts;
    }

    static function clearHead() as Void {
        StorageManager.remove(HEAD_KEY);
    }

    static function clear() as Void {
        StorageManager.remove(QUEUE_KEY);
        clearHead();
    }
}