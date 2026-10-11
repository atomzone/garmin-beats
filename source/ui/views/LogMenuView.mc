using Toybox.WatchUi as Ui;
import Toybox.Lang;

class LogMenuView extends Ui.Menu2 {
    function initialize(entries as Array<String>) {
        Ui.Menu2.initialize({ :title => "Logs" });

        for (var i = entries.size() - 1; i >= 0; i--) {
            var value = entries[i];
            var label = truncate(value, 20);
            var subtitle = getSubtitle(value, 20);
            addItem(new Ui.MenuItem(label, subtitle, i, {}));
        }
    }

    private function truncate(value as String, maxLen as Number) as String {
        if (value.length() <= maxLen) {
            return value;
        }
        return value.substring(0, maxLen - 3) + "...";
    }

    private function getSubtitle(value as String, maxLen as Number) as String? {
        if (value.length() <= maxLen) {
            return null;
        }

        var remaining = value.substring(maxLen, value.length()) as String;
        if (remaining.length() > 26) {
            remaining = remaining.substring(0, 23) + "...";
        }

        return remaining;
    }
}
