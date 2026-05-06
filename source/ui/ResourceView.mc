using Toybox.WatchUi as Ui;
import Toybox.Lang;

class ResourceView extends Ui.CheckboxMenu {

    function initialize(resources as Array<AudioResource>) {
        Ui.CheckboxMenu.initialize({:title => "ResourceView"});

        for (var index = 0, limit = resources.size(); index < limit; index++) {
            var resource = resources[index];

            addItem(new Ui.CheckboxMenuItem(
                resource.getId(),
                resource.getSourceUrl(),
                index,
                false,
                {}
            ));
        }
    }
}
