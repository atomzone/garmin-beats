using Toybox.WatchUi as Ui;
import Toybox.Lang;

class DeleteAssetConfirmation extends Ui.ConfirmationDelegate {
    private var _assetManager as AssetManager;

    function initialize(assetManager as AssetManager) {
        ConfirmationDelegate.initialize();

        _assetManager = assetManager;
    }

    function onResponse(response as Ui.Confirm) as Boolean {
        if (response == WatchUi.CONFIRM_YES) {
            _assetManager.delete();
            $.am.debug("[SettingsMenuController] Cleared " + _assetManager.size() + " cached audio + assets");
            return true;
        }

        return false;
    }
}