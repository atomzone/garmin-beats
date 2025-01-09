import Toybox.Lang;

typedef ResourceType as AudioResource or File;

class FileHandler {
    hidden var filelist as Dictionary<String, ResourceType> = {};

    function initialize(filelist as Array<ResourceType>) {
        addAll(filelist);
    }

    function add(file as ResourceType) {
        self.filelist.put(file.getId(), file);
    }

    function addAll(files as Array<ResourceType>) {
        for (var index = 0; index < files.size(); ++index) {
            add(files[index]);
        }
    }

    function delete(file as ResourceType) {
        self.filelist.remove(file.getId());
    }

    function getById(id as String) as ResourceType? {
        return self.filelist[id];
    }

    function getKeys() as Array<String> {
        return self.filelist.keys();
    }

    // could this be serialsie/deserialise?
    function toStorage(store as Storage) as Storage {    
        var keys = getKeys();

        for (var index = 0; index < keys.size(); ++index) {
            var key = keys[index];
            var file = getById(key);

            store.put(key, file.toStorage());
        }

        return store;
    }
}