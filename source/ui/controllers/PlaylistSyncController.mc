using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Communications as Comm;
import Toybox.Lang;

class PlaylistSyncController extends Ui.Menu2InputDelegate {
    private var _enabled as Array<PlaylistResource> = [];
    private var _playlists as Array<PlaylistResource>;

    function initialize(playlists as Array<PlaylistResource>) {
        Ui.Menu2InputDelegate.initialize();
        _playlists = playlists;
    }

    function onDone() as Void {
        if (self._enabled.size() == 0) {
            Ui.popView(Ui.SLIDE_IMMEDIATE);
            return;
        }

        var serialized = [];
        for (var i = 0, limit = _enabled.size(); i < limit; i++) {
            serialized.add(_enabled[i].serialize());
        }

        // SyncStateStore.setRemote(serialized);

        // make queue tasks
        // future - this builder will
        // - check the playlist/track against local stored assets
        // - by comparing checksums
        // - todo/descide if tracks are unique or shared across pl
        var queue = [];
        for (var i = 0, limit = _enabled.size(); i < limit; i++) {
            queue.add({
                "op" => "SAVE",
                "entity" => "PLAYLIST",
                "payload" => _enabled[i].serialize()
            });

            var tracks = _enabled[i].getTracks();
            for (var t = 0; t < tracks.size(); t++) {
                queue.add({
                    "op" => "DOWNLOAD",
                    "entity" => "TRACK",
                    "payload" => _enabled[i].serialize()
                });
            }
        }

        // and store
        QueueStore.save(queue);
        
        Communications.startSync2({
            :message => "Start the fans, please!",
        });
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var id = item.getId() as Number;

        if ((item as Ui.CheckboxMenuItem).isChecked()) {
            _enabled.add(_playlists[id]);
        } else {
            _enabled.remove(_playlists[id]);
        }
    }
}
