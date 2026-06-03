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
            $.am.clearAll();
            
            return true;
        }

        return false;
    }
}