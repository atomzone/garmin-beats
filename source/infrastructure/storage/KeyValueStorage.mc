using Toybox.Application.Storage as Storage;
import Toybox.Lang;

// "{ASSET}:INDEXES" = [id1, id2]
// "{ASSET}:id1" = model1
// "{ASSET}:id2" = model2
class KeyValueStorage {

    private var _partitionId as String;
    private var _indexIdCache as Array<String> = [];

    function initialize(partitionId as String) {
        _partitionId = partitionId;
    }

    private function buildPartitionKey(id as String) as String {
        return _partitionId + ":" + id;
    }

    function get(id as String) as Storage.ValueType? {
        if (!isValid(id)) {
            return null;
        }

        var partitionKey = buildPartitionKey(id);

        return StorageManager.get(partitionKey);
    }

    function getIndexIds() as Array<String> {
        if (_indexIdCache.size() > 0) {
            $.am.debug("getIndexIds[" + _partitionId + "][CACHE][HIT]");
            return _indexIdCache;
        }
        
        $.am.debug("getIndexIds[" + _partitionId + "][CACHE][MISS]");

        var partitionKey = buildPartitionKey("INDEXES");
        _indexIdCache = StorageManager.getOrDefault(partitionKey, []) as Array<String>;

        return _indexIdCache;
    }
    
    function set(id as String, value as Dictionary?) as Void {
        var partitionKey = buildPartitionKey(id);

        StorageManager.set(partitionKey, value as Storage.ValueType?);
        addIndexId(id);
    }

    function delete(id as String) as Void {
        var partitionKey = buildPartitionKey(id);

        StorageManager.delete(partitionKey);
        deleteIndexId(id);
    }

    function isValid(id as String) as Boolean {
        var indexes = getIndexIds();

        return indexes.indexOf(id) != -1;
    }

    private function addIndexId(id as String) as Void {
        var indexes = getIndexIds();

        if (indexes.indexOf(id) > -1) {
            return;
        }

        _indexIdCache = indexes.add(id);
        storeIndexes(indexes);
    }

    private function deleteIndexId(id as String) as Void {
        var indexes = getIndexIds();

        if (indexes.remove(id)) {
            _indexIdCache = indexes;
            storeIndexes(indexes);
        }
    }

    private function storeIndexes(indexes as Array<String>) as Void {
        StorageManager.set(buildPartitionKey("INDEXES"), indexes as Array<Storage.ValueType>);
    }
}