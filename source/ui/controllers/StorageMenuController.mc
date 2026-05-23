using Toybox.WatchUi as Ui;

class StorageMenuController extends Ui.Menu2InputDelegate {

    private var _assetRepo as AudioAssetRepository;

    function initialize(assetRepo as AudioAssetRepository) {
        Ui.Menu2InputDelegate.initialize();

        _assetRepo = assetRepo;
    }

    function onSelect(item as Ui.MenuItem) as Void {
        var id = item.getId();

        if (id == :Delete) {
            var message = Lang.format("Delete Assets? ($1$)", [_assetRepo.size()]);

            Ui.pushView(
                new Ui.Confirmation(message),
                new DeleteAssetConfirmation(_assetRepo),
                Ui.SLIDE_IMMEDIATE
            );

        } else if (id == :Capacity) {
            // show memory
            // show cached sizes
        } 
    }
}