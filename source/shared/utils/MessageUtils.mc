using Toybox.WatchUi as Ui;
import Toybox.Lang;

// TITLE IDEAS
// Error	Trail blocked	A path ending at a barrier, or a route line with a clear X
// Warn	Rough terrain	A caution triangle; a rockfall or uneven-ground pictogram if it stays legible small
// Info	Trail update	A waypoint/map marker or a simple information marker
// Debug	Tiny details	A compass or contour lines—a subtle “map detail” cue

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
