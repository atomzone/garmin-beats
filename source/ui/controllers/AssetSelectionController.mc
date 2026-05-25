using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Media as Media;

import Toybox.Lang;

class AssetSelectionController extends Ui.Menu2InputDelegate {

    private var _assets as Array<AudioAsset>;
    private var _selected as Array<AudioAsset> = [];

    function initialize(assets as Array<AudioAsset>) {
        Ui.Menu2InputDelegate.initialize();
        _assets = assets;
    }

    function onDone() as Void {
        if (_selected.size() == 0) {
            Ui.popView(Ui.SLIDE_IMMEDIATE);
            return;
        }

        // OLD SCHOOL FROM HERE
        // TODO: REPALCE OLD SCHOOL

        // convert new -> old
        var refIds = [] as Array<Number>;
        for (var i = 0; i < _selected.size(); i++) {
            refIds.add(_selected[i].getRefId() as Number);
        }

        var assets = XAudioAsset.fromRefIds(refIds);            
        var playlist = new Playlist(assets, 0);
        
        Media.startPlayback(playlist.serialize() as App.PersistableType);
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var index = item.getId() as Number;
        var asset = _assets[index];

        if ((item as Ui.CheckboxMenuItem).isChecked()) {
            _selected.add(asset);
        } else {
            _selected.remove(asset);
        }
    }
}
