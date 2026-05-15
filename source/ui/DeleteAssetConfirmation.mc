using Toybox.WatchUi as Ui;
import Toybox.Lang;

class DeleteAssetConfirmation extends Ui.ConfirmationDelegate {
    private var assets as Array<AudioAsset> = [];

    function initialize(assets as Array<AudioAsset>) {
        ConfirmationDelegate.initialize();

        self.assets = assets;
    }

    function onResponse(response as Ui.Confirm) as Boolean {
        if (response == WatchUi.CONFIRM_YES) {
            deleteAssets();
            $.am.debug("[SettingsMenuController] Cleared " + assets.size() + " cached audio + assets");
            return true;
        }

        return false;
    }

    private function deleteAssets() as Void {
        for (var i = 0, limit = assets.size(); i < limit; i++) {
            assets[i].delete();
        }
    }
}