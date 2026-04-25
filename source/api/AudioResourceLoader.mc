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
        data as Dictionary or String or Null, 
        context as { :callback as Method }
    ) as Void {
        var json = (data as { "resources" as Array<AudioResourceType> });
        var models = buildResources(json["resources"] as Array<AudioResourceType>);

        (context[:callback] as Method).invoke(models);
    }
}
