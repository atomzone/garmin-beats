using Toybox.WatchUi as Ui;
import Toybox.Lang;

class DeleteAssetConfirmation extends Ui.ConfirmationDelegate {

    // private var _assetRepo as XAudioAssetRepository;

    function initialize() { //assetRepo as XAudioAssetRepository) {
        ConfirmationDelegate.initialize();

        // _assetRepo = assetRepo;
    }

    function onResponse(response as Ui.Confirm) as Boolean {
        if (response == WatchUi.CONFIRM_YES) {

            // REMOVE PLAYLISTS
            var playlistStore = new IndexedStore("PLAYLIST");
            playlistStore.clear();

            // REMOVE TRACKS
            var trackStore = new IndexedStore("TRACK");
            trackStore.clear();

            // REMOVE MEDIA RECORDS
            var mediaStore = new IndexedStore("MEDIA");
            mediaStore.clear();

            // REMOVE CACHCED CONTENT
            var cachedMedia = MediaUtils.getCachedMediaRefIds(Media.CONTENT_TYPE_AUDIO);
            for (var index = 0, limit = cachedMedia.size(); index < limit; index++) {
                MediaUtils.delete(cachedMedia[index]);
            }

            return true;
        }

        return false;
    }
}