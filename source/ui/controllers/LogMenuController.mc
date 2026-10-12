using Toybox.WatchUi as Ui;
import Toybox.Lang;

class LogMenuController extends Ui.Menu2InputDelegate {
    private var _entries as Array<StructuredLogType>;

    function initialize(entries as Array<StructuredLogType>) {
        Ui.Menu2InputDelegate.initialize();
        _entries = entries;
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var index = item.getId() as Number;
        var message = _entries[index];

        System.println("[LogMenuController] Selected log entry: " + message);

        var request = new HttpRequest({
            :href => "https://mantledb.sh/v2/my-playlists/test",
            :parameters => {}
        }, null, null);

        request.postJson({ "logs" => _entries });

        // Ui.pushView(
        //     new LogDetailView(message),
        //     new LogDetailDelegate(),
        //     Ui.SLIDE_UP
        // );
    }
}
