using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Media as Media;

import Toybox.Lang;

class PlaylistMenuController extends Ui.Menu2InputDelegate {

    private var _assets as Array<PlaylistResource>;
    private var _selected as Array<PlaylistResource> = [];

    function initialize(assets as Array<PlaylistResource>) {
        Ui.Menu2InputDelegate.initialize();
        _assets = assets;
    }

    function onDone() as Void {
        if (_selected.size() == 0) {
            Ui.popView(Ui.SLIDE_IMMEDIATE);
            return;
        }

        $.am.debug("[onDone] " + _selected);

        // var playlist = new Playlist(_selected, 0);
        // Media.startPlayback(playlist.serialize() as App.PersistableType);
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var index = item.getId() as Number;
        // var asset = _assets[index];

        var assets = XAudioAsset.getCachedAssets();
        var playlist = new Playlist(assets, 0);

        Media.startPlayback(playlist.serialize() as App.PersistableType);

    }
}
