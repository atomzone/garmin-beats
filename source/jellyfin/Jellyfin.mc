import Toybox.Lang;

class Jellyfin {
    var host as String;
    var progressIndicator as ProgressBarController;

    function initialize(host as String) {
        self.host = host;
        self.progressIndicator = new ProgressBarController(
            new WatchUi.ProgressBar("Moulding Jelly", null)
        );
    }

    function getArtists(callback as Method) as Void {
        var request = new HttpRequest({ 
            :href => "https://" + self.host + "/Artists", 
            :parameters => { "limit" => "5" }
        }, method(:onResponse));

        self.progressIndicator.show();
        request.getJson({ :callback => callback });
    }

    function getAlbums(callback as Method) as Void {
        var request = new HttpRequest({ 
            :href => "https://" + self.host + "/Items", 
            :parameters => { 
                "limit" => "5", 
                "includeItemTypes" => "Audio",
                "recursive" => "true"
            }
        }, method(:onResponse));

        self.progressIndicator.show();
        request.getJson({ :callback => callback });
    }

    function onResponse(
        data as Dictionary or String or Null, 
        context as { :callback as Method }
    ) as Void {
        self.progressIndicator.hide();
        context[:callback].invoke(data);
    }
}

///-------------------------------------------------------------------------

/*
using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;

class App extends Application.AppBase {
    function onStart(state) {
        var pager = new AudioPager();
        var factory = new AudioTrackViewFactory(pager);
        var loop = new ViewLoop(factory);

        WatchUi.pushView(loop, WatchUi.SLIDE_IMMEDIATE);
    }
}

class AudioPager {
    function fetchPage(pageIndex as Number, callback as Function) {
        // Simulated API response (replace with jelly.getAlbums in real usage)
        var items = [] as Array<Dictionary>;
        for (var i = 0; i < 5; i++) {
            var track = {
                "Id" => "track-" + (pageIndex * 5 + i).toString(),
                "Name" => "Track " + (pageIndex * 5 + i + 1).toString(),
                "AlbumArtist" => "Artist " + ((pageIndex % 3) + 1).toString()
            };
            items.add(track);
        }

        var fakeData = { "Items" => items };
        $.am.debug("Fetched page " + pageIndex);
        handleApiData(callback, fakeData);
    }

    function handleApiData(callback as Function, rawData as Dictionary) {
        var models = [] as Array<AudioTrackModel>;
        var items = rawData["Items"];
        for (var i = 0; i < items.size(); i++) {
            models.add(new AudioTrackModel(items[i]));
        }
        callback(models);
    }

    function getTotalPages() {
        return 10; // Simulated number of pages
    }
}

class AudioTrackView extends WatchUi.View {
    var tracks = [];

    function setTracks(t as Array<AudioTrackModel>) {
        tracks = t;
    }

    function onUpdate(dc as Dc) {
        dc.clear();
        for (var i = 0; i < tracks.size(); i++) {
            var track = tracks[i];
            var y = 20 + i * 25;
            dc.drawText(10, y, Graphics.FONT_SMALL, track.title + " - " + track.artist);
        }
    }
}

class AudioTrackViewDelegate extends WatchUi.ViewLoopDelegate {
    function onKey(key as Number, action as Number) {
        if (action == KEY_PRESS) {
            if (key == KEY_DOWN) {
                return changeView(ViewLoop.DIRECTION_NEXT);
            }
            if (key == KEY_UP) {
                return changeView(ViewLoop.DIRECTION_PREVIOUS);
            }
        }
        return false;
    }
}

class AudioTrackViewFactory extends WatchUi.ViewLoopFactory {
    var pager;

    function initialize(p as AudioPager) {
        pager = p;
    }

    function getView(index as Number) {
        var view = new AudioTrackView();
        var delegate = new AudioTrackViewDelegate();

        pager.fetchPage(index, method(:onPageLoaded, view));
        return [view, delegate];
    }

    function onPageLoaded(view as AudioTrackView, tracks as Array<AudioTrackModel>) {
        view.setTracks(tracks);
        WatchUi.requestUpdate();
    }

    function getCount() {
        return pager.getTotalPages();
    }
}

*/

