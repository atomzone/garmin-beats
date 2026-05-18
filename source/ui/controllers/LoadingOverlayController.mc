using Toybox.WatchUi as Ui;
import Toybox.Lang;

class LoadingOverlayController {

    private var _progressBar as Ui.ProgressBar;
    private var _operations as Dictionary = {};

    function initialize(progressBar as Ui.ProgressBar) {
        _progressBar = progressBar;
    }

    function begin(id as Symbol, label as String) as Void {
        $.am.debug("[LoadingOverlayController.begin] " + id.toString() + " (" + label + ")");

        _operations[id] = label;
        refresh();

        if (_operations.size() == 1) {
            WatchUi.pushView(_progressBar, null, WatchUi.SLIDE_IMMEDIATE);
        }
    }

    function end(id as Symbol) as Void {
        $.am.debug("[LoadingOverlayController.end] " + id.toString() + " (" + _operations.get(id) + ")");

        if (_operations.hasKey(id)) {
            _operations.remove(id);
        }

        if (_operations.size() == 0) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return;
        }
        
        refresh();
    }

    private function refresh() as Void {
        var keys = _operations.keys();
        if (keys.size() == 0) {
            return;
        }

        var label = _operations[keys[0]] as String;
        var count = _operations.size();

        if (count > 1) {
            label += " (1 of " + count + ")";
        }

        _progressBar.setDisplayString(label);
    }
}