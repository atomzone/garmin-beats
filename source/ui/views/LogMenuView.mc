using Toybox.WatchUi as Ui;
import Toybox.Lang;

class LogMenuView extends Ui.Menu2 {
    function initialize(entries as Array<StructuredLogType>) {
        Ui.Menu2.initialize({ :title => "Logs" });

        for (var i = entries.size() - 1; i >= 0; i--) {
            var level = entries[i]["level"];
            var label = level + "| " + entries[i]["message"];
            var subtitle = getSubtitle(entries[i]["args"] as Dictionary<String, String>);

            addItem(new Ui.MenuItem(label, subtitle, i, {}));
        }
    }

    private function getSubtitle(args as Dictionary<String, String>) as String? {
        var argString = "";
        var keys = (args as Dictionary<String, String>).keys();
        var values = (args as Dictionary<String, String>).values();

        for(var i = 0, max = args.size(); i < max; i++) {
            argString += keys[i] + "=" + values[i] + ", ";
        }

        return argString.substring(0, argString.length() - 2);
    }
}
