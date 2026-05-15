using Toybox.WatchUi as Ui;
using Toybox.Graphics;
import Toybox.Lang;

class ResourceView extends Ui.CheckboxMenu {

    private var _isClosed as Boolean? = null;

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
        $.am.debug("[ResourceView.onShow] isClosed=" + _isClosed);
        
        if (_isClosed == true) {
            Ui.popView(Ui.SLIDE_IMMEDIATE);
            return;
        }

        _isClosed = false;
    }

    function onHide() as Void {
        $.am.debug("[ResourceView.onHide] isClosed=" + _isClosed);
        _isClosed = true;
    }
}
