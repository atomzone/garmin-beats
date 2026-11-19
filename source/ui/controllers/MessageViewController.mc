using Toybox.WatchUi as Ui;
import Toybox.Lang;

class MessageViewController extends Ui.BehaviorDelegate {
    function initialize() {
        Ui.BehaviorDelegate.initialize();
    }

    function onBack() as Boolean {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        return true;
    }
}
