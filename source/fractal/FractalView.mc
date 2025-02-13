import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// onLayout() → onShow() → onUpdate() → onHide()
class FractalView extends WatchUi.View {
    private var step as Number = 0;
    private var y as Number = 0;
    private var x as Number = 0;
    private var height as Number = 0;
    private var width as Number = 0;
    private var radius as Number = 0;
    private var centerX as Number = 0;
    private var centerY as Number = 0;
    
    function initialize() {
        View.initialize();
    }

    function inCircle(x as Number, y as Number) as Boolean {
        var squareDistance = (self.centerX - x) * (self.centerX - x) + (self.centerY - y) * (self.centerY - y);
        return squareDistance <= self.radius * self.radius;
    }

    function onHide() as Void {
        System.println("onHide");
    }

    function onLayout(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
        // dc.fillCircle(50, 100, 75);

        self.height = dc.getHeight();
        self.width = dc.getWidth();
        self.radius = self.width / 2;
        self.centerX = self.width / 2;
        self.centerY = self.height / 2;

        System.println("onLayout");
        System.println(self.width + "," + self.height);

        // System.println("Drawing");
        // self.gridRunner(width, height);
        // System.println("Done");
        // View.onLayout(dc);
    }

    function gridRunner(width as Number, height as Number) as Void {
        for (var x = 0; x < width; x++) {
            for (var y = 0; y < height; y++) {
                System.println(x + "," + y);
            }
        }
    }

    function onShow() as Void {
        System.println("onShow");
    }

// this is called SOOOO offtern, it shoudl ONLY render
    function onUpdate(dc as Graphics.Dc) as Void {
        System.println("onUpdate");

        // dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLUE);
        // dc.fillCircle(50, 100, 75);

        // can we optimise 1000 for each device?
        for (var limit = 0; limit < 1000; limit++) {
            var coords = self.stepToCoordinates(self.step);
            self.step++;

            var x = coords[0];
            var y = coords[1];
            // var x = self.x;
            // var y = self.y;

            if (self.inCircle(x, y)) {
                System.println(x + ", " + y);
                dc.drawPoint(x, y);
            }

            // if (x <= self.width) {
            //     self.x += 1;
            // } else if (x > self.width) {
            //     self.x = 0;
            //     if (y < self.height) {
            //         self.y += 1;
            //     }
            // }
        }

        // View.onUpdate(dc);
    }

    function stepToCoordinates(step as Number) as [Number, Number] {
        return [
            (step - 1) % self.width,
            (step - 1) / self.height,
        ];
    }
}
