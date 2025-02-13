import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.WatchUi;

class SyncResourcesDelegate extends WatchUi.Menu2InputDelegate {
    private var enabled as Array<String> = [];
    private var resources as Array<AudioResource> = [];

    function initialize(resources as Array<AudioResource>) {
        Menu2InputDelegate.initialize();
        self.resources = resources;
    }

    // DOES INDEXOF MATCH ON OBJECT
    function getResourceById(id as String) as AudioResource? {
        for (var index = 0, limit = self.resources.size(); index < limit; index++) {
            var resource = self.resources[index];

            if (id.equals(resource.getId())) {
                return resource;
            }
        }

        return null;
    }

    function onDone() as Void {
        // TODO: Global storage handler? (systemwide)
        // SHOULD USE STORE NOT STORAGEMANAGER
        var store = new StorageManager("SYNC");
        var storage = [] as Array<PersistableType>;

        for (var index = 0, limit = self.enabled.size(); index < limit; index++) {
            var id = self.enabled[index];
            var resource = self.getResourceById(id);

            if (resource != null) {
                storage.add(resource.toStorage());
            }
        }

        // SHOULD USE STORE NOT STORAGEMANAGER
        store.put("audio", storage as PersistableType);

        // pop the active view
        // THIS SEEM TO FUCKS TUFF UP!
        // but we need to pop the view right?!
        // Menu2InputDelegate.onDone();

        // TODO: Should we use `startSync2` ?
        // TODO: Can we know a sync is needed (shared func)
        // Exit the AppBase and launch it in sync mode with the provided message.
        Communications.startSync();
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
