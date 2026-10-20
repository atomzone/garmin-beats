import Toybox.Lang;

class MantleDb {
    private var _namespace as String;

    function initialize(namespace as String) {
        _namespace = namespace;
    }

    public function write(output as Dictionary<Object, Object>) as Void {
        var request = new HttpRequest("https://mantledb.sh/v2/" + _namespace, null, null);

        request.postJson(output);
    }

    public function read(callback as ResultCallbackType) as Void {
        var request = new HttpRequest(
            "https://mantledb.sh/v2/" + _namespace,
            { :callback => callback }, 
            method(:onResponseGetJson)
        );

        request.getJson(null);
    }

    function onResponseGetJson(
        response as ResponseType,
        context as { :callback as ResultCallbackType }
    ) as Void {
        (context[:callback] as ResultCallbackType).invoke(response, null);
    }
}
