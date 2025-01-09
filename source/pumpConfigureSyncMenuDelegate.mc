import Toybox.Lang;
import Toybox.WatchUi;

class pumpConfigureSyncMenuDelegate extends WatchUi.Menu2InputDelegate {
    var syncStore = new Storage("SYNC");
    // DO I EVEN NEED THIS EXTRA LIST?
    // COULD KEEP TRACK OF THE "CHANGED FILES" within "HANDLE"
    var changeList as FileHandler;
    var handler as FileHandler;

    // Class OR Dictionary?
    var files as Array = [];

    function initialize(handler as FileHandler) {
        Menu2InputDelegate.initialize();
        self.changeList = new FileHandler([]);
        self.handler = handler;
    }

    // Stores the songs to delete and download in the object store
    function onDone() {
        System.println("Processess changes with file selection");

        // GET FROM THE CHANGELIST
        // 1. THE TRACKS TO SYNC
        // STORE TRACKS THAT REQUIRE SYNCING
        self.changeList.toStorage(self.syncStore);

        // 2. THE TRACKS TO DELETE
        System.println(self.files);
        for (var index = 0; index < self.files.size(); ++index) {
            var file = new AudioAsset(self.files[index]);
            file.delete();
            // REFRESH THE VIEW (TO REFLECT THE CHANGES)
            // THOUGH. MAYBE A SYNC HAPPENS HERE?
        }
    }

    // handle menu item selects
    // maintain a list of file changes
    function onSelect(item as WatchUi.MenuItem) as Void {
        System.println(item.getId());
        System.println((item as WatchUi.CheckboxMenuItem).isChecked());
        System.println(item.getLabel());

        var id = item.getId() as String;
        var file = self.handler.getById(id);

        // CLUNKY!
        // TODO: REWRITE ONCE WE CAN DEFINE WHAT A TRACK ATTRIBUTES WE NEED?
        // FILE NOT ON FILESYSTEM
        if (file == null) {
            if (self.files.indexOf(id) == -1) {
                self.files.add(id);
            } else {
                self.files.remove(id);
            }
            return;
        }

        // FILES TO SYNC...
        var isItemChecked = (item as WatchUi.CheckboxMenuItem).isChecked();
        if (isItemChecked) {
            self.changeList.add(file);
        } else {
            self.changeList.delete(file);
        }
    }
}
