import Toybox.Lang;
import Toybox.WatchUi;

class SyncConfigureDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();

        System.println("label " + item.getLabel());

        // var view as WatchUi.Views;
        // var model as WatchUi.InputDelegates;

        if (id == :library) {
            WatchUi.pushView(
                new DeleteAssetsView(getAudioAssets()),
                null,
                WatchUi.SLIDE_LEFT
            );
        } else if (id == :add) {
            WatchUi.pushView(
                new SyncResourcesView(getAudioResources()),
                null,
                WatchUi.SLIDE_LEFT
            );
        } else if (id == :settings) {
            WatchUi.pushView(
                new pumpConfigureSyncView(), 
                new pumpConfigureSyncDelegate(),
                WatchUi.SLIDE_LEFT
            );
        }

        // WatchUi.pushView(view, model, WatchUi.SLIDE_LEFT);
    }
}

// import Toybox.Lang;
// import Toybox.WatchUi;

// class SyncConfigureDelegate extends WatchUi.Menu2InputDelegate {
//     function initialize() {
//         Menu2InputDelegate.initialize();
//     }

//     function onSelect(item as WatchUi.MenuItem) as Void {
//         var id = item.getId();
//         // var view as WatchUi.Views;
//         // var model as WatchUi.InputDelegates;

//         if (id == :library) {
//             WatchUi.pushView(
//                 new DeleteAssetsView(), 
//                 new DeleteAssetsDelegate(), 
//                 WatchUi.SLIDE_LEFT
//             );
//         } else if (id == :add) {
//             WatchUi.pushView(
//                 new SyncResourcesView(), 
//                 new SyncResourcesDelegate(), 
//                 WatchUi.SLIDE_LEFT
//             );
//         } else if (id == :settings) {
//             System.println("label " + item.getLabel());
//         }
//     }
// }

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
