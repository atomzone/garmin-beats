using Toybox.Communications as Comm;
using Toybox.WatchUi as Ui;
import Toybox.Lang;

class LoadingOverlayDelegate extends Ui.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Cancel all pending JSON and Image requests
    function onBack() as Boolean {
        Comm.cancelAllRequests();

        return true;
    }
}

class LoadingOverlayController {
    private var _progressBar as Ui.ProgressBar;
    private var _operations as Dictionary = {};

    function initialize(progressBar as Ui.ProgressBar) {
        _progressBar = progressBar;
    }

    function begin(id as Symbol, label as String) as Void {
        $.am().logger().debug(
            "[LoadingOverlayController.begin]", { "id" => id.toString(), "label" => label }
        );

        _operations[id] = label;
        refresh();

        if (_operations.size() == 1) {
            WatchUi.pushView(_progressBar, new LoadingOverlayDelegate(), WatchUi.SLIDE_IMMEDIATE);
        }
    }

    function end(id as Symbol) as Void {
        $.am().logger().debug(
            "[LoadingOverlayController.end]", { "id" => id.toString(),  "label" => _operations.get(id) }
        );

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