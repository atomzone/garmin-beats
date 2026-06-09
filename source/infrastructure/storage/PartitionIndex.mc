using Toybox.Application.Storage as Storage;
import Toybox.Lang;

// "{PARTITION_KEY}:I" = [<ID1>, <ID2>]
class PartitionIndex {

    private var _indexKey as String;
    private var _cache as Array<String>?;

    function initialize(indexKey as String) {
        _indexKey = indexKey;
    }

    public function add(id as String) as Void {
        var indexes = getIds();

        if (indexes.indexOf(id) > -1) {
            return;
        }

        _cache = indexes.add(id);
        save(indexes);
    }

    public function clear() as Void {
        StorageManager.remove(_indexKey);
        _cache = [];
    }

    public function contains(id as String) as Boolean {
        return getIds().indexOf(id) != -1;
    }

    public function getIds() as Array<String> {
        if (_cache != null) {
            return _cache;
        }

        _cache = StorageManager.loadOrDefault(_indexKey, []) as Array<String>;

        return _cache;
    }

    public function remove(id as String) as Void {
        var indexes = getIds();

        if (indexes.remove(id)) {
            _cache = indexes;
            save(indexes);
        }
    }

    private function save(indexes as Array<String>) as Void {
        StorageManager.save(
            _indexKey, indexes as Array<Storage.ValueType>
        );
    }
}
