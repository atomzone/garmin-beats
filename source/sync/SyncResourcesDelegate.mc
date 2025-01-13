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
