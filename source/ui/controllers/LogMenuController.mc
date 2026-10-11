using Toybox.WatchUi as Ui;
import Toybox.Lang;

class LogMenuController extends Ui.Menu2InputDelegate {
    private var _entries as Array<String>;

    function initialize(entries as Array<String>) {
        Ui.Menu2InputDelegate.initialize();
        _entries = entries;
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var index = item.getId() as Number;
        var message = _entries[index];

        System.println("[LogMenuController] Selected log entry: " + message);

        // Ui.pushView(
        //     new LogDetailView(message),
        //     new LogDetailDelegate(),
        //     Ui.SLIDE_UP
        // );
    }
}
