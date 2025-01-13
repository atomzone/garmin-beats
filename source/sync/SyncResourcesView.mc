import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class SyncResourcesView extends WatchUi.View {
    private var resources as Array<AudioResource> = [];

    function initialize(resources as Array<AudioResource>) {
        View.initialize();
        self.resources = resources;
    }

    // function onBack() as Void {
    //     WatchUi.popView(WatchUi.SLIDE_RIGHT);
    // }

    // // Load your resources here
    // function onLayout(dc as Dc) as Void {
    //     setLayout(Rez.Layouts.ConfigureSyncLayout(dc));
    // }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        var menu = new WatchUi.CheckboxMenu({:title => "Rez.Strings.syncMenuTitle"});

        for (var index = 0; index < self.resources.size(); index++) {
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

    // // Update the view
    // function onUpdate(dc as Dc) as Void {
    //     // Call the parent onUpdate function to redraw the layout
    //     View.onUpdate(dc);
    // }

    // // Called when this View is removed from the screen. Save the
    // // state of this View here. This includes freeing resources from
    // // memory.
    // function onHide() as Void {
    // }
}
