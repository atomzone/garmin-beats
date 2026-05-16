using Toybox.WatchUi as Ui;
import Toybox.Lang;

class MenuLifecycleController {

    // null  -> never shown
    // false -> currently active
    // true  -> hidden/closed
    private var _isClosed as Boolean? = null;

    function handleAutoCloseOnShow() as Void {
        $.am.debug("[MenuLifecycleController.onShow] isClosed=" + _isClosed);
        
        if (_isClosed == true) {
            Ui.popView(Ui.SLIDE_IMMEDIATE);
            return;
        }

        _isClosed = false;
    }

    function markClosedOnHide() as Void {
        $.am.debug("[MenuLifecycleController.onHide] isClosed=" + _isClosed);
        _isClosed = true;
    }
}