import Toybox.Lang;
import Toybox.WatchUi;

class JellyfinBrowser {
    var jelly as Jellyfin;

    function initialize(jelly as Jellyfin) {
        self.jelly = jelly;
    }

    function getView() as WatchUi.View {
        return new JellyfinDefaultBrowserView();
    }

    function getPaginatedView() as WatchUi.ViewLoop {
        // move progress indicator from Jellyfin and into view factory
        var factory = new JellyfinBrowserPaginationViewFactory(self.jelly);

        // return new WatchUi.ViewLoop(factory, { :page => 1 });
        return new JellyfinBrowserPaginationView(factory, { :page => 1 });
    }
}

// the factory of views - dreams
class JellyfinBrowserPaginationViewFactory extends WatchUi.ViewLoopFactory {
    function initialize(jelly as Jellyfin) {
        ViewLoopFactory.initialize();
    }

    // Return how many pages or views you want to support
    function getSize() as Number {
        System.println("[+]\tJellyfinBrowserPaginationViewFactory.getCount: " + self);
        return 5; // Number of pages
    }

    function getView(page as Number) as [WatchUi.View] or [WatchUi.View, WatchUi.BehaviorDelegate] {
        System.println("[+]\tJellyfinBrowserPaginationViewFactory.getView: " + self);

        // this is a depenancy inject
        var view = new JellyfinDefaultBrowserView();

        return [view];
    }
}

class JellyfinBrowserPaginationView extends WatchUi.ViewLoop {
    function initialize(
        factory as WatchUi.ViewLoopFactory, 
        options as { :page as Lang.Number } or Null
    ) {
        System.println("[+]\tJellyfinBrowserPaginationView: " + self);
        ViewLoop.initialize(factory, options);
    }

    function changeView(direction as ViewLoop.Direction) as Lang.Boolean {
        System.println("[+]\tJellyfinBrowserPaginationView.changeView: " + direction);
        return true;
    }
}

// general "api browser" view
class JellyfinDefaultBrowserView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    // Resources are loaded here
    function onLayout(dc) {
    }

    // onShow() is called when this View is brought to the foreground
    function onShow() {
    }

    // onUpdate() is called periodically to update the View
    function onUpdate(dc) {
        View.onUpdate(dc);
    }

    // onHide() is called when this View is removed from the screen
    function onHide() {
    }
}

