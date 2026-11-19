using Toybox.WatchUi as Ui;
import Toybox.Lang;

class MessageUtils {
    static function show(title as String?, message as String?) as Void {
        var hasTitle = title != null && title.length() > 0;
        var hasMessage = message != null && message.length() > 0;
        if (!hasTitle && !hasMessage) {
            return;
        }

        Ui.pushView(
            new MessageView(title, message),
            new MessageViewController(),
            Ui.SLIDE_UP
        );
    }
}
