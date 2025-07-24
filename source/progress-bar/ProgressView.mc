import Toybox.Lang;
import Toybox.Media;
import Toybox.WatchUi;

class ProgressBarController {
    var progressBar as WatchUi.ProgressBar;
    var isViewActive as Boolean;

    function initialize(progressBar as WatchUi.ProgressBar) {
        self.progressBar = progressBar;
        self.isViewActive = false;
    }
    
    function setDisplayString(displayString as Lang.String) as Void {
        self.progressBar.setDisplayString(displayString);
    }

    function setProgress(progressValue as Lang.Float or Null) as Void {
        self.progressBar.setProgress(progressValue);
    }

    function show() as Void {
        if (self.isViewActive) {
            return;
        }

        WatchUi.pushView(self.progressBar, null, WatchUi.SLIDE_IMMEDIATE);
        self.isViewActive = true;
    }

    function hide() as Void {
        if (!self.isViewActive) {
            return;
        }

        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        self.isViewActive = false;
    }
}

// class ProgressBar extends WatchUi.ProgressBar {
//     function initialize(displayString as Lang.String, startValue as Lang.Float or Null) {
//         WatchUi.ProgressBar.initialize(displayString, startValue);
//     }
    
//     function setDisplayString(displayString as Lang.String) as Void {
//         WatchUi.ProgressBar(displayString);
//     }

//     function setProgress(progressValue as Lang.Float or Null) as Void {
//         WatchUi.ProgressBar(progressValue);
//     }
// }

