import Toybox.Lang;
import Toybox.WatchUi;

class pumpConfigureSyncMenuDelegate extends WatchUi.Menu2InputDelegate {
    var changeList as Dictionary<String, File> = {};
    var handler as FileHandler;

    function initialize(handler as FileHandler) {
        Menu2InputDelegate.initialize();
        self.handler = handler;
    }

    // Stores the songs to delete and download in the object store
    function onDone() {
        System.println("Processess changes with file selection");
    }

    function onSelect(item as WatchUi.MenuItem) {
        // HERER WE NEED TO STORE ALL THOSE THAT HAVE CHANGED
        // EITHER FILES TO DOWNLOAD FROM REMOTE
        // OR - FILES TO REMOVE FROM DEVICE

        // 1. GET THE 'SELECTED' ITEM
        // 2. IF THE SELECTED ITEM CHECKED STATUS != THE FILELIST
        //    ADD THIS ITEM TO A CHANGE LIST
        // 3. THEN 

        System.println(
            self.handler[:filelist]
        );

        System.println("ETMPY" + self.handler.getById(""));
        System.println("HARDCODE" + self.handler.getById("id-1"));
        System.println("INPUT" + self.handler.getById(item.getId() as String));

        var file = self.handler.getById(item.getId() as String);
        var isItemChecked = (item as WatchUi.CheckboxMenuItem).isChecked();

        System.println(file[:is_on_device] + "!=" + isItemChecked);

        // if (isItemChecked) {
        //     System.println("THE ITEM HAS BEED SLECTED TO BE SYNCED (OR IT ALREADY BEEN SYNECD)");
        // }
        // else {
        //     System.println("THIS ITEM SHOULD BE DELETED (OR IT WAS NEVER SYNCED - LAST SYNC TIMESTAMP?)");
        // }

        // file[:is_on_device] = !isItemChecked;

        if (file[:is_on_device] != isItemChecked) {
            System.println("ITEM CHANGED: " + file[:id]);
            System.println("IT SHOULD BE ADDED OR REMOVED FROM THE SYNC LIST");
            
            self.changeList[file[:id]] = file;
        } else {
            self.changeList.remove(file[:id]);
        }

        System.println("CHANGELLIST" + self.changeList);
    }
}
