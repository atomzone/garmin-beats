using Toybox.WatchUi as Ui;
import Toybox.Lang;

class MessageUtils {
    static function show(message as String) as Void {
        if (message == null || message.length() == 0) {
            return;
        }

        Ui.showToast(message, null);
    }
}
