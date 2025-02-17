// import Toybox.Application;
// import Toybox.Communications;
import Toybox.Lang;
import Toybox.Media;
import Toybox.WatchUi;

class ProgressBarController {
    var progressBar as WatchUi.ProgressBar;

    function initialize(progressBar as WatchUi.ProgressBar) {
        self.progressBar = progressBar;
    }
    
    function setDisplayString(displayString as Lang.String) as Void {
        self.progressBar.setDisplayString(displayString);
    }

    function setProgress(progressValue as Lang.Float or Null) as Void {
        self.progressBar.setProgress(progressValue);
    }

    function show() as Void {
        WatchUi.pushView(self.progressBar, null, WatchUi.SLIDE_IMMEDIATE);
    }

    function hide() as Void {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
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

