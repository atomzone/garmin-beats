import Toybox.Lang;

class FileHandler {
    hidden var filelist as Dictionary<String, File> = {};

    function initialize(filelist as Array<File>) {
        addAll(filelist);
    }

    function add(file as File) {
        self.filelist.put(file[:id], file);
    }

    function addAll(files as Array<File>) {
        for (var index = 0; index < files.size(); ++index) {
            add(files[index]);
        }
    }

    function delete(file as File) {
        self.filelist.remove(file.getId());
    }

    function getById(id as String) as File? {
        return self.filelist[id];
    }

    function getKeys() as Array<String> {
        return self.filelist.keys();
    }

    // Flattern dictonary to array<string>
    function toStorage() as Array {    
        var storage = [];
        var keys = getKeys();

        for (var index = 0; index < keys.size(); ++index) {
            var file = getById(keys[index]);

            storage.add(file.toStorage());
        }

        return storage;
    }
}