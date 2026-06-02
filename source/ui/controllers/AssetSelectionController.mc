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

        var trackIds = [];
        for (var i = 0, limit = _selected.size(); i < limit; i++) {
            trackIds.add(_selected[i].getId());
        }

        // Build and Save playlist
        // Code duplication, maintenance burden
        // Fix: Extract to PlaylistManager.createNowPlayingPlaylist(trackIds, description)
        var playlist = new PlaylistAsset({
            "id" => "pl:nowplaying",
            "metadata" => {
                "title" => "Now playing",
                "description" => "- Custom collection -"
            },
            "trackIds" => trackIds
        } as PlaylistAssetType);

        var playlistAssetStore = new IndexedStore("PLAYLIST");
        playlistAssetStore.save(playlist.getId(), playlist.serialize());

        // Start playback
        $.am.debug("[NOW PLAYING] id='" + playlist.getId() + "', '" + playlist.serialize() + "'");
        Media.startPlayback(playlist.getId());
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
