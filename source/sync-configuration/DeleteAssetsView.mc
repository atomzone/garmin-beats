import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class DeleteAssetsView extends WatchUi.View {
    private var assets as Array<AudioAsset> = [];

    function initialize(assets as Array<AudioAsset>) {
        View.initialize();
        self.assets = assets;
    }

    function onShow() as Void {
        System.println("DeleteAssetsView::onShow()");

        var menu = new WatchUi.CheckboxMenu({:title => "Rez.Strings.syncMenuTitle"});
        
        for (var index = 0, limit = self.assets.size(); index < limit; index++) {
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
}
