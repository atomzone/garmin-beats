import Toybox.Lang;

class Jellyfin {
    var host as String;
    var progressIndicator as ProgressBarController;

    function initialize(host as String) {
        self.host = host;
        self.progressIndicator = new ProgressBarController(
            new WatchUi.ProgressBar("Moulding Jelly", null)
        );
    }

    function getArtists(callback as Method) as Void {
        var request = new HttpRequest({ 
            :href => "https://" + self.host + "/Artists", 
            :parameters => { "limit" => "5" }
        }, method(:onResponse));

        self.progressIndicator.show();
        request.getJson({ :callback => callback });
    }

    function getAlbums(callback as Method) as Void {
        var request = new HttpRequest({ 
            :href => "https://" + self.host + "/Items", 
            :parameters => { 
                "limit" => "5", 
                "includeItemTypes" => "Audio",
                "recursive" => "true"
            }
        }, method(:onResponse));

        self.progressIndicator.show();
        request.getJson({ :callback => callback });
    }

    function onResponse(
        data as Dictionary or String or Null, 
        context as { :callback as Method }
    ) as Void {
        self.progressIndicator.hide();
        context[:callback].invoke(data);
    }
}
