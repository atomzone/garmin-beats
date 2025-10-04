import Toybox.Lang;
import Toybox.WatchUi;

// THIS IS KINDA SPEIFIC TO VIEW LOOPS
class JellyfinBrowser {
    private var view as WatchUi.ViewLoop;
    private var controller as WatchUi.ViewLoopDelegate;

    function initialize(jelly as Jellyfin) {
        var factory = new JellyfinBrowserPaginationViewFactory(jelly);

        self.view = new WatchUi.ViewLoop(factory, { :page => 0 });
        self.controller = new WatchUi.ViewLoopDelegate(self.view);
    }

    function getView() as WatchUi.ViewLoop {
        return self.view;
    }

    function getDelegate() as WatchUi.ViewLoopDelegate {
        return self.controller;
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

    // function getView(page as Number) as [WatchUi.View] or [WatchUi.View, WatchUi.BehaviorDelegate] {
    //     System.println("[+]\tJellyfinBrowserPaginationViewFactory.getView: " + self);

    //     // this is a depenancy inject
    //     // var view = new JellyfinDefaultBrowserView();
    //     var view = new PlaybackConfigureMenuView();
    //     return [view, new WatchUi.BehaviorDelegate()];
    // }
}

// general "api browser" view
class JellyfinDefaultBrowserView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }
}

