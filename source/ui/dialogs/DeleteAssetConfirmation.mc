using Toybox.WatchUi as Ui;
import Toybox.Lang;

class DeleteAssetConfirmation extends Ui.ConfirmationDelegate {

    private var _assetRepo as AudioAssetRepositoryOld;

    function initialize(assetRepo as AudioAssetRepositoryOld) {
        ConfirmationDelegate.initialize();

        _assetRepo = assetRepo;
    }

    function onResponse(response as Ui.Confirm) as Boolean {
        if (response == WatchUi.CONFIRM_YES) {
            _assetRepo.deleteAll();
            $.am.debug("[SettingsMenuController] Cleared " + _assetRepo.size() + " cached audio + assets");
            return true;
        }

        return false;
    }
}