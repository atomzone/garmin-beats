using Toybox.System as Sys;
import Toybox.Lang;

class AudioResourceLoader {
    private var _href as String;

    function initialize(href as String) {
        self._href = href;
    }

    function fetchResources(callback as Method) as Void {
        var request = new HttpRequest({ 
            :href => self._href,
            :parameters => {}
        }, method(:onResponseBuildResources));

        request.getJson({ :callback => callback });
    }

    function onResponseBuildResources(
        data as Object, // Expected JSON will be Dictionary
        context as { :callback as Method }
    ) as Void {
        if (!(data instanceof Dictionary)) {
            (context[:callback] as Method).invoke([]);
            return;
        }

        var json = data as Dictionary;
        var resources = [] as Array<AudioResourceType>;
        if (json.hasKey("resources") && json["resources"] instanceof Array) {
            resources = json["resources"] as Array<AudioResourceType>;
        }

        var models = buildResources(resources);
        (context[:callback] as Method).invoke(models);
    }
}
