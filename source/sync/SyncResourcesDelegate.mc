import Toybox.Lang;
import Toybox.WatchUi;

class SyncResourcesDelegate extends WatchUi.Menu2InputDelegate {
    private var enabled as Array<String> = [];
    private var resources as Array<AudioResource> = [];

    function initialize(resources as Array<AudioResource>) {
        Menu2InputDelegate.initialize();
        self.resources = resources;
    }

    function getResourceById(id as String) as AudioResource? {
        for (var index = 0; index < self.resources.size(); index++) {
            var resource = self.resources[index];

            if (id.equals(resource.getId())) {
                return resource;
            }
        }

        return null;
    }

    function onDone() as Void {
        // TODO: Global storage handler? (systemwide)
        var store = new Storage("SYNC");

        for (var index = 0; index < self.enabled.size(); index++) {
            var id = self.enabled[index];
            var resource = self.getResourceById(id);

            if (resource != null) {
                store.put(id, resource.toStorage());
            }
        }

        // pop the active view
        Menu2InputDelegate.onDone();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as String;

        if ((item as WatchUi.CheckboxMenuItem).isChecked()) {
            self.enabled.add(id);
        } else {
            self.enabled.remove(id);
        }
    }
}

// import Toybox.Lang;
// import Toybox.WatchUi;

// class pumpConfigureSyncMenuDelegate extends WatchUi.Menu2InputDelegate {
//     var syncStore = new Storage("SYNC");
//     // DO I EVEN NEED THIS EXTRA LIST?
//     // COULD KEEP TRACK OF THE "CHANGED FILES" within "HANDLE"
//     var changeList as FileHandler;
//     var handler as FileHandler;

//     // Class OR Dictionary?
//     var files as Array = [];

//     private var assets as Array<AudioAsset>;
//     private var resources as Array<AudioResource>;

//     function initialize(
//         handler as FileHandler, 
//         assets as Array<AudioAsset>,
//         resources as Array<AudioResource>
//     ) {
//         Menu2InputDelegate.initialize();
//         self.assets = assets;
//         self.resources = resources;

//         self.changeList = new FileHandler([]);
//         self.handler = handler;
//     }

//     // Stores the songs to delete and download in the object store
//     function onDone() {
//         System.println("Processess changes with file selection");

//         // GET FROM THE CHANGELIST
//         // 1. THE TRACKS TO SYNC
//         // STORE TRACKS THAT REQUIRE SYNCING
//         self.changeList.toStorage(self.syncStore);

//         // 2. THE TRACKS TO DELETE
//         System.println(self.files);
//         for (var index = 0; index < self.files.size(); index++) {
//             // Its sad that craeting new classes are costly
//             // Here i should just perform the delete. without creating a new object... :(
//             var file = new AudioAsset(self.files[index]);
//             file.delete();
//             // REFRESH THE VIEW (TO REFLECT THE CHANGES)
//             // THOUGH. MAYBE A SYNC HAPPENS HERE?
//         }
//     }

//     // handle menu item selects
//     // maintain a list of file changes
//     function onSelect(item as WatchUi.MenuItem) as Void {
//         System.println(item.getId());
//         System.println((item as WatchUi.CheckboxMenuItem).isChecked());
//         System.println(item.getLabel());

//         var id = item.getId() as String;

//         // NEEDS TO REMOVE HANDLER  
//         var file = self.handler.getById(id);

//         // CLUNKY!
//         // TODO: REWRITE ONCE WE CAN DEFINE WHAT A TRACK ATTRIBUTES WE NEED?
//         // FILE NOT ON FILESYSTEM
//         if (file == null) {
//             if (self.files.indexOf(id) == -1) {
//                 self.files.add(id);
//             } else {
//                 self.files.remove(id);
//             }
//             return;
//         }

//         // FILES TO SYNC...
//         // REPLACE WITH ARRAY AS ABOVE....
//         var isItemChecked = (item as WatchUi.CheckboxMenuItem).isChecked();
//         if (isItemChecked) {
//             self.changeList.add(file);
//         } else {
//             self.changeList.delete(file);
//         }
//     }
// }
