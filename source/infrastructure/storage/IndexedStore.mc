using Toybox.Application.Storage as Storage;
import Toybox.Lang;

// "{ASSET}:<INDEX_PARITION_ID>" = [id1, id2]
// "{ASSET}:id1" = model1
// "{ASSET}:id2" = model2
class IndexedStore {

    enum PartitionEnum {
        PLAYLIST,
        TRACK,
        MEDIA
    }

    private const INDEX_PARITION_ID = "I";
    
    private var _partitionId as PartitionEnum;
    private var _indexIdCache as Array<String>?;

    function initialize(partitionId as PartitionEnum) {
        _partitionId = partitionId;
    }

    private function buildPartitionKey(id as String) as String {
        return _partitionId + ":" + id;
    }

    function load(id as String) as Storage.ValueType? {
        if (!isIndexValid(id)) {
            return null;
        }

        return StorageManager.load(buildPartitionKey(id));
    }

    function loadAll() as Array<Storage.ValueType> {
        var records = [];
        var indexIds = loadIndexIds();

        for (var i = 0, limit = indexIds.size(); i < limit; i++) {
            var value = StorageManager.load(buildPartitionKey(indexIds[i]));

            if (value != null) {
                records.add(value);
            }
        }

        return records;
    }

    function loadIndexIds() as Array<String> {
        if (_indexIdCache != null) {
            return _indexIdCache;
        }

        var partitionKey = buildPartitionKey(INDEX_PARITION_ID);
        _indexIdCache = StorageManager.loadOrDefault(partitionKey, []) as Array<String>;

        return _indexIdCache;
    }
    
    function save(id as String, value as Dictionary?) as Void {
        StorageManager.save(buildPartitionKey(id), value as Storage.ValueType?);
        addIndexId(id);

        $.am.debug("[IndexedStore][Save][" + _partitionId + "] :: id='" + id + "', value='" + value + "'");
    }

    function remove(id as String) as Void {
        StorageManager.remove(buildPartitionKey(id));
        removeIndexId(id);
    }

    function isIndexValid(id as String) as Boolean {
        return loadIndexIds().indexOf(id) != -1;
    }

    function count() as Number {
        return loadIndexIds().size();
    }

    function clear() as Void {
        var indexIds = loadIndexIds();

        for (var i = 0, limit = indexIds.size(); i < limit; i++) {
            StorageManager.remove(buildPartitionKey(indexIds[i]));
        }

        StorageManager.remove(buildPartitionKey(INDEX_PARITION_ID));
        _indexIdCache = [];
    }

    private function addIndexId(id as String) as Void {
        var indexes = loadIndexIds();

        if (indexes.indexOf(id) > -1) {
            return;
        }

        _indexIdCache = indexes.add(id);
        storeIndexes(indexes);
    }

    private function removeIndexId(id as String) as Void {
        var indexes = loadIndexIds();

        if (indexes.remove(id)) {
            _indexIdCache = indexes;
            storeIndexes(indexes);
        }
    }

    private function storeIndexes(indexes as Array<String>) as Void {
        StorageManager.save(
            buildPartitionKey(INDEX_PARITION_ID), 
            indexes as Array<Storage.ValueType>
        );
    }
}