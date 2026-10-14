import Toybox.Lang;

class MantleDb {
    private var _namespace as String;

    function initialize(namespace as String) {
        _namespace = namespace;
    }

    public function write(output as Dictionary) as Void {
        var request = new HttpRequest({
            :href => "https://mantledb.sh/v2/" + _namespace,
            :parameters => {}
        }, null, null);

        request.postJson(output);
    }

    public function read(callback as ResultCallbackType) as Void {
        var request = new HttpRequest({
                :href => "https://mantledb.sh/v2/" + _namespace,
                :parameters => {}
            }, 
            { :callback => callback }, 
            method(:onResponseGetJson)
        );

        request.getJson();
    }

    function onResponseGetJson(
        response as ResponseType,
        context as { :callback as ResultCallbackType }
    ) as Void {
        (context[:callback] as ResultCallbackType).invoke(response, null);
    }
}
