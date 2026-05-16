using Toybox.WatchUi as Ui;
using Toybox.Graphics;
import Toybox.Lang;

class ResourceView extends Ui.CheckboxMenu {

    private var _lifecycle as MenuLifecycleController = new MenuLifecycleController();

    function initialize(resources as Array<AudioResource>) {
        Ui.CheckboxMenu.initialize({:title => "ResourceView"});

        for (var index = 0, limit = resources.size(); index < limit; index++) {
            var resource = resources[index];

            addItem(new Ui.CheckboxMenuItem(
                resource.getTitle() as String,
                resource.getArtist(),
                index,
                false,
                {}
            ));
        }
    }

    function onShow() as Void {
        _lifecycle.handleAutoCloseOnShow();
    }

    function onHide() as Void {
        _lifecycle.markClosedOnHide();
    }
}
