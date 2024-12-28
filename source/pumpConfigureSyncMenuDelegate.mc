import Toybox.Lang;
import Toybox.WatchUi;

class pumpConfigureSyncMenuDelegate extends WatchUi.Menu2InputDelegate {
    // DO I EVEN NEED THIS EXTRA LIST?
    // COULD KEEP TRACK OF THE "CHANGED FILES" within "HANDLE"
    var changeList as FileHandler;
    var handler as FileHandler;

    function initialize(handler as FileHandler) {
        Menu2InputDelegate.initialize();
        self.changeList = new FileHandler([]);
        self.handler = handler;
    }

    // Stores the songs to delete and download in the object store
    function onDone() {
        System.println("Processess changes with file selection");
        System.println("CHANGELLIST => " + self.changeList);

        // GET FROM THE CHANGELIST
        // 1. THE TRACKS TO SYNC
        // 2. THE TRACKS TO DELETE

        var storage = self.changeList.toStorage();
        System.println("----------------------------");
        System.println(storage);
        System.println("----------------------------");

        Application.Storage.setValue("ACTION", "self.changeList");
        Application.Storage.setValue("KEYS", self.changeList.getKeys());
        Application.Storage.setValue("VALUES", storage);
    }

    // handle menu item selects
    // maintain a list of file changes
    function onSelect(item as WatchUi.MenuItem) {
        var file = self.handler.getById(item.getId() as String);
        var isItemChecked = (item as WatchUi.CheckboxMenuItem).isChecked();

        if (file[:is_on_device] != isItemChecked) {
            self.changeList.add(file);
        } else {
            self.changeList.delete(file);
        }
    }
}
