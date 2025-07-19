import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class AudioTrackMenuView extends WatchUi.View {
    private var resources as Array<AudioTrackModel> = [];

    function initialize(resources as Array<AudioTrackModel>) {
        View.initialize();
        self.resources = resources;
    }

    function onShow() as Void {
        System.println("SyncResourcesView::onShow()");

        var menu = new WatchUi.CheckboxMenu({:title => "Rez.Strings.syncMenuTitle"});

        var audioResources = [];

        for (var index = 0, limit = self.resources.size(); index < limit; index++) {
            var resource = self.resources[index] as AudioTrackModel;
            var item = new WatchUi.CheckboxMenuItem(
                resource[:title],
                resource.getDescription(),
                resource[:id],
                false,
                null
            );
            menu.addItem(item);

            // lets temp convert to AudioResource
            audioResources.add(
                new AudioResource(
                    "https://jellyfin.hoveoffice.com/Audio/" + resource[:id] + "/universal", 
                    { :id => resource[:id], :title => resource[:title] }
                )
            );
        }

        WatchUi.switchToView(
            menu, new SyncResourcesDelegate(audioResources), WatchUi.SLIDE_IMMEDIATE
        );
    }
}
