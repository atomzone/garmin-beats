import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class SyncResourcesView extends WatchUi.View {
    private var resources as Array<AudioResource> = [];

    function initialize(resources as Array<AudioResource>) {
        View.initialize();
        self.resources = resources;
    }

    function onShow() as Void {
        System.println("SyncResourcesView::onShow()");

        var menu = new WatchUi.CheckboxMenu({:title => "Rez.Strings.syncMenuTitle"});

        for (var index = 0, limit = self.resources.size(); index < limit; index++) {
            var resource = self.resources[index];
            var item = new WatchUi.CheckboxMenuItem(
                resource.getTitle(),
                resource.getId(),
                resource[:id],
                false,
                null
            );
            menu.addItem(item);
        }

        WatchUi.switchToView(
            menu, new SyncResourcesDelegate(self.resources), WatchUi.SLIDE_IMMEDIATE
        );
    }
}
