import Toybox.Lang;

class AudioResourceLoader {
    private var _href as String;

    function initialize(href as String) {
        self._href = href;
    }

    function fetchPlaylists(callback as ResultCallbackType) as Void {
        var request = new HttpRequest({
            :href => self._href,
            :parameters => {}
        }, { :callback => callback }, method(:onResponseBuildPlaylists));

        request.getJson();
    }

    function onResponseBuildPlaylists(
        response as ResponseType,
        context as { :callback as ResultCallbackType }
    ) as Void {
        if (response[:ok] != true || !(response[:data] instanceof Dictionary)) {
            var error = response[:error] == null ? "Unable to load playlists" : response[:error];
            $.am.debug("[loader.onResponseBuildPlaylists.fail] code=" + response[:code] + ", error=" + error);
            (context[:callback] as ResultCallbackType).invoke([], error);
            return;
        }

        var json = response[:data] as Dictionary;
        var playlists = [] as Array<PlaylistResourceType>;
        if (json.hasKey("playlists") && json["playlists"] instanceof Array) {
            playlists = json["playlists"] as Array<PlaylistResourceType>;
        }

        var model = PlaylistResource.fromArray(playlists);
        (context[:callback] as ResultCallbackType).invoke(model, null);
    }

    function fetchResources(callback as ResultCallbackType) as Void {
        var request = new HttpRequest({
            :href => self._href,
            :parameters => {}
        }, { :callback => callback }, method(:onResponseBuildResources));

        request.getJson();
    }

    function onResponseBuildResources(
        response as ResponseType,
        context as { :callback as ResultCallbackType }
    ) as Void {
        if (response[:ok] != true || !(response[:data] instanceof Dictionary)) {
            var error = response[:error] == null ? "Unable to load tracks" : response[:error];
            $.am.debug("[loader.onResponseBuildResources.fail] code=" + response[:code] + ", error=" + error);
            (context[:callback] as ResultCallbackType).invoke([], error);
            return;
        }

        var json = response[:data] as Dictionary;
        var resources = [] as Array<AudioResourceType>;
        if (json.hasKey("resources") && json["resources"] instanceof Array) {
            resources = json["resources"] as Array<AudioResourceType>;
        }

        var models = AudioResource.fromArray(resources);
        (context[:callback] as ResultCallbackType).invoke(models, null);
    }
}
