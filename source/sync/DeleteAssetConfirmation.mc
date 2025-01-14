import Toybox.Lang;
import Toybox.WatchUi;

class DeleteAssetConfirmation extends WatchUi.ConfirmationDelegate {
    private var assetIds as Array<String> = [];

    function initialize(assetIds as Array<String>) {
        ConfirmationDelegate.initialize();
        self.assetIds = assetIds;
    }

    function onResponse(response as WatchUi.Confirm) as Boolean {
        if (response == WatchUi.CONFIRM_YES) {
            for (var index = 0; index < self.assetIds.size(); index++) {
                var asset = new AudioAsset(self.assetIds[index]);
                asset.delete();
            }
            return true;
        }

        return false;
    }
}
