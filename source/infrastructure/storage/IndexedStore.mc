using Toybox.Application.Storage as Storage;
import Toybox.Lang;

// "{ASSET}:INDEXES" = [id1, id2]
// "{ASSET}:id1" = model1
// "{ASSET}:id2" = model2
class IndexedStore {
    
    private var _partitionId as String;
    private var _indexIdCache as Array<String> = [];

    function initialize(partitionId as String) {
        _partitionId = partitionId;
    }

    private function buildPartitionKey(id as String) as String {
        return _partitionId + ":" + id;
    }

    function get(id as String) as Storage.ValueType? {
        if (!isIndexValid(id)) {
            return null;
        }

        return StorageManager.get(buildPartitionKey(id));
    }

    function getAll() as Array<Storage.ValueType> {
        var records = [];
        var indexIds = getIndexIds();

        for (var i = 0, limit = indexIds.size(); i < limit; i++) {
            var value = get(indexIds[i]);

            if (value != null) {
                records.add(value);
            }
        }

        return records;
    }

    function getIndexIds() as Array<String> {
        if (_indexIdCache.size() > 0) {
            return _indexIdCache;
        }
        
        var partitionKey = buildPartitionKey("INDEXES");
        _indexIdCache = StorageManager.getOrDefault(partitionKey, []) as Array<String>;

        return _indexIdCache;
    }
    
    function set(id as String, value as Dictionary?) as Void {
        StorageManager.set(buildPartitionKey(id), value as Storage.ValueType?);
        addIndexId(id);
    }

    function delete(id as String) as Void {
        StorageManager.delete(buildPartitionKey(id));
        deleteIndexId(id);
    }

    function isIndexValid(id as String) as Boolean {
        return getIndexIds().indexOf(id) != -1;
    }

    function count() as Number {
        return getIndexIds().size();
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