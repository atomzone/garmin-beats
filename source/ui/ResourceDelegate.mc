using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Media as Media;
using Toybox.Communications as Comm;
using Toybox.System as Sys;

import Toybox.Lang;

class ResourceDelegate extends Ui.Menu2InputDelegate {
    private var enabled as Array<AudioResource> = [];
    private var resources as Array<AudioResource>;

    function initialize(resources as Array<AudioResource>) {
        Menu2InputDelegate.initialize();
        self.resources = resources;
    }

    function onDone() as Void {
        $.am.debug("Sync selection made" + self.enabled);
        
        Ui.popView(Ui.SLIDE_IMMEDIATE); // pop the active view

        if (self.enabled.size() == 0) {
            return;
        }

        Application.Storage.setValue("SYNC_SELECTION", serializeResources(self.enabled));
        Communications.startSync();
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var id = item.getId() as Number;

        if ((item as Ui.CheckboxMenuItem).isChecked()) {
            self.enabled.add(self.resources[id]);
        } else {
            self.enabled.remove(self.resources[id]);
        }
    }
}
