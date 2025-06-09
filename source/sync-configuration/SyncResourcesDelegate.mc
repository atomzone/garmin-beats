import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.WatchUi;

class SyncResourcesDelegate extends WatchUi.Menu2InputDelegate {
    private var enabled as Array<String> = [];
    private var resources as Array<AudioResource> = [];
    private var syncStore as StorageManager = new StorageManager("SYNC"); // inject/global

    function initialize(resources as Array<AudioResource>) {
        Menu2InputDelegate.initialize();
        self.resources = resources;
    }

    // Lookup the resource 
    // TODO: refactor to key/vals map?
    function getResourceById(id as String) as AudioResource? {
        for (var index = 0, limit = self.resources.size(); index < limit; index++) {
            var resource = self.resources[index];

            if (id.equals(resource.getId())) {
                return resource;
            }
        }

        return null;
    }

    // deal with the selected items
    function onDone() as Void {
        Menu2InputDelegate.onDone(); // pop the active view

        if (self.enabled.size() == 0) {
            return;
        }

        // persist selected audio resources 
        self.storeAudioSyncResources();
        
        // Exit the AppBase and launch it in sync mode with the provided message.
        Communications.startSync2({
            :message => "Downloading beats"
        });
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as String;

        if ((item as WatchUi.CheckboxMenuItem).isChecked()) {
            self.enabled.add(id);
        } else {
            self.enabled.remove(id);
        }
    }

    function storeAudioSyncResources() as Void {
        var storage = [] as Array<PersistableType>;

        for (var index = 0, limit = self.enabled.size(); index < limit; index++) {
            var resource = self.getResourceById(self.enabled[index]);

            if (resource != null) {
                storage.add(resource.toStorage());
            }
        }

        self.syncStore.put("audio", storage as PersistableType);
    }
}
