using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Media as Media;
import Toybox.Lang;

class PlaylistMenuController extends Ui.Menu2InputDelegate {

    private var _assets as Array<PlaylistAsset>;

    function initialize(assets as Array<PlaylistAsset>) {
        Ui.Menu2InputDelegate.initialize();
        _assets = assets;
    }

    function onDone() as Void {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        return;
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var index = item.getId() as Number;
        var playlist = _assets[index];
        var trackIds = playlist.getTrackIds();
        
        $.am.debug("** NEW ASSET **" + playlist.serialize());

        // // convert new -> old

        var trackStorage = new KeyValueStorage("TRACK");

        var refIds = [] as Array<Number>;
        for (var i = 0; i < trackIds.size(); i++) {
            var raw = trackStorage.get(trackIds[i]) as AudioAssetType?;
            
            if (raw == null) {
                continue;
            }

            var track = new AudioAsset(raw);
            refIds.add(track.getRefId() as Number);
        }

        // OLD SCHOOL PLAYER+PLAYLIST
        var assets = XAudioAsset.fromRefIds(refIds); 
        var xplaylist = new Playlist(assets, 0);

        Media.startPlayback(xplaylist.serialize() as App.PersistableType);
    }
}
