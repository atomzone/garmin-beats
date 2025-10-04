import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class AudioTrackViewLoop extends ViewLoop {
    // function initialize(
    //     factory as WatchUi.ViewLoopFactory, 
    //     options as { :page as Lang.Number, :wrap as Lang.Boolean, :color as Graphics.ColorType } or Null
    // ) {
    //     ViewLoop.initialize(factory, options);
    // }
    
    function changeView(direction as ViewLoop.Direction) as Lang.Boolean {
        return true;
    }
}

/*
class AudioTrackViewLoopFactory extends ViewLoopFactory {
    function initialize(resources as Array<AudioTrackModel>) {
        ViewLoopFactory.initialize();

        self.resources = resources;
    }
    
    function getSize() as Lang.Number {
        return self.resources.size();
    }

    // could be called on each chnageView
    function getView(page as Lang.Number) as [ ViewLoopFactory.Views ] or [ ViewLoopFactory.Views, ViewLoopFactory.Delegates ]
        // var view = new WatchUi.View();
        // view.initialize();
        // var delegate = new MyLoopDelegate(page);
        // return [view, delegate];
        // return [ null ];
    }
}

import Toybox.WatchUi as WatchUi;
import Toybox.Graphics as Gfx;

class MyLoopDelegate extends WatchUi.ViewLoopDelegate {
    var pageIndex as Number;

    function initialize(viewLoop as WatchUi.ViewLoop, page as Number) {
        ViewLoopDelegate.initialize(viewLoop);
        pageIndex = page;
    }

    function onShow() {
        // optional per-page init
    }

    function onUpdate(dc as Gfx.Dc) {
        dc.clear();
        dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Gfx.FONT_MEDIUM, "Page " + (pageIndex+1), Gfx.TEXT_JUSTIFY_CENTER);
    }

    function onNextView() as Boolean {
        return viewLoop.changeView(WatchUi.ViewLoop.DIRECTION_NEXT);
    }

    function onPreviousView() as Boolean {
        return viewLoop.changeView(WatchUi.ViewLoop.DIRECTION_PREVIOUS);
    }
}
*/

class AudioTrackMenuView extends WatchUi.View {
    private var resources as Array<AudioTrackModel> = [];

    function initialize(resources as Array<AudioTrackModel>) {
        View.initialize();
        self.resources = resources;
    }

    function onShow() as Void {
        $.am.debug("AudioTrackMenuView::onShow()");

        var menu = new WatchUi.CheckboxMenu({:title => "Rez.Strings.syncMenuTitle"});
        var audioResources = [];

        for (var index = 0, limit = self.resources.size(); index < limit; index++) {
            var resource = self.resources[index] as AudioTrackModel;
            var item = new WatchUi.CheckboxMenuItem(
                resource[:title],
                resource.getDescription(),
                resource[:id],
                false,
                null
            );
            menu.addItem(item);

            // recreating an audiotrack into and audioresource :?
            var url = "https://jellyfin.hoveoffice.com/Audio/" + resource[:id] + "/universal";
            var tom = new AudioResource(url, { 
                :id => resource[:id],
                :title => resource[:title]
            });
            audioResources.add(tom);
        }

        WatchUi.switchToView(
            menu, new SyncResourcesDelegate(audioResources), WatchUi.SLIDE_IMMEDIATE
        );
    }
}

class AudioTrackPaginationMenuView extends WatchUi.View {
    private var resources as Array<AudioTrackModel> = [];

    function initialize(resources as Array<AudioTrackModel>) {
        View.initialize();
        self.resources = resources;
    }

    function onShow() as Void {
        var menu = new WatchUi.CheckboxMenu({
            :title => "Imagine Pagination",
            :footer => "1 of 101"
        });

        var audioResources = [];

        for (var index = 0, limit = self.resources.size(); index < limit; index++) {
            var resource = self.resources[index] as AudioTrackModel;
            var item = new WatchUi.CheckboxMenuItem(
                resource[:title],
                resource.getDescription(),
                resource[:id],
                false,
                null
            );
            menu.addItem(item);
        }

        // var item = new WatchUi.MenuItem(
        //     "Next >",
        //     null,
        //     :next,
        //     { :alignment => MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT }
        // );
        // menu.addItem(item);

        WatchUi.switchToView(
            menu, new SyncResourcesDelegate(audioResources), WatchUi.SLIDE_IMMEDIATE
        );
    }
}