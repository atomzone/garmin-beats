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
            self.deleteAssets();
            return true;
        }

        return false;
    }

    private function deleteAssets() as Void {
        // var progressBar = new ProgressBarController(
        //     new WatchUi.ProgressBar("Deleting Assets", null)
        // );

        // progressBar.show();

        for (var index = 0, limit = self.assetIds.size(); index < limit; index++) {
            var asset = new AudioAsset(self.assetIds[index]);
            asset.delete();
        }

        // progressBar.hide();
    }
}
