using Toybox.Time;
using Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.System;

class ApplicationManager {
    public function debug(message as String) as Void {
        // var timestamp = getTimestamp();
        // System.println("[" + timestamp + "] " + message);
        System.println(message);
    }

    public function debugWithArgs(message as String, args as Object) as Void {
        self.debug(message + "(" + self.parseArgs(args) + ")");
    }

    private function parseArgs(args as Object?) as String {
        return (args == null) ? "null" : args.toString();
    }

    private function getTimestamp() as String {
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        
        return Lang.format(
            "$1$:$2$:$3$ $4$ $5$ $6$ $7$",
            [
                today.hour,
                today.min,
                today.sec,
                today.day_of_week,
                today.day,
                today.month,
                today.year
            ]
        );
    }
}
