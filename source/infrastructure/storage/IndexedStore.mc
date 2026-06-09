using Toybox.Application.Storage as Storage;
import Toybox.Lang;

// "{PARTITION_KEY}:I" = [<ID1>, <ID2>]
// "{PARTITION_KEY}:<ID1>" = model1
// "{PARTITION_KEY}:<ID2>" = model2
class IndexedStore {

    enum PartitionEnum {
        PLAYLIST,
        TRACK,
        MEDIA
    }
    
    private var _partitionId as PartitionEnum;
    private var _index as PartitionIndex;

    function initialize(partitionId as PartitionEnum) {
        _partitionId = partitionId;
        _index = new PartitionIndex(buildPartitionKey("I"));
    }

    public function load(id as String) as Storage.ValueType? {
        if (!_index.contains(id)) {
            return null;
        }

        return StorageManager.load(buildPartitionKey(id));
    }

    public function loadAll() as Array<Storage.ValueType> {
        var records = [];
        var indexIds = _index.getIds();

        for (var i = 0, limit = indexIds.size(); i < limit; i++) {
            var value = StorageManager.load(buildPartitionKey(indexIds[i]));

            if (value != null) {
                records.add(value);
            }
        }

        return records;
    }
    
    public function save(id as String, value as Dictionary?) as Void {
        StorageManager.save(buildPartitionKey(id), value as Storage.ValueType?);
        _index.add(id);

        $.am.debug("[IndexedStore][Save][" + _partitionId + "] :: id='" + id + "', value='" + value + "'");
    }

    public function remove(id as String) as Void {
        StorageManager.remove(buildPartitionKey(id));
        _index.remove(id);
    }

    public function getIds() as Array<String> {
        return _index.getIds();
    } 

    public function count() as Number {
        return _index.getIds().size();
    }

    public function clear() as Void {
        var indexIds = _index.getIds();

        for (var i = 0, limit = indexIds.size(); i < limit; i++) {
            StorageManager.remove(buildPartitionKey(indexIds[i]));
        }

        _index.clear();
    }

    private function buildPartitionKey(id as String) as String {
        return _partitionId + ":" + id;
    }
}
