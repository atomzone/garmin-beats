import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class DeleteAssetsView extends WatchUi.View {
    private var assets as Array<AudioAsset> = [];

    function initialize(assets as Array<AudioAsset>) {
        View.initialize();
        self.assets = assets;
    }

    // // Load your resources here
    // function onLayout(dc as Dc) as Void {
    //     setLayout(Rez.Layouts.ConfigureSyncLayout(dc));
    // }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        var menu = new WatchUi.CheckboxMenu({:title => "Rez.Strings.syncMenuTitle"});
        
        for (var index = 0; index < self.assets.size(); index++) {
            var asset = self.assets[index];
            var item = new WatchUi.CheckboxMenuItem(
                asset.getTitle(),
                asset.getResourceId(),
                asset[:refId],
                false,
                null
            );
            menu.addItem(item);
        }

        // TODO: understand why popView dose not work here
        WatchUi.switchToView(menu, new DeleteAssetsDelegate(), WatchUi.SLIDE_IMMEDIATE);
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
    //     System.println("onHide");
    // }

    // // Update the view
    // function onUpdate(dc as Dc) as Void {
    //     System.println("onUpdate");
    //     // Call the parent onUpdate function to redraw the layout
    //     View.onUpdate(dc);
    // }
}
