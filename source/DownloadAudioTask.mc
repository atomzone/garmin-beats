import Toybox.Communications;
import Toybox.Lang;
import Toybox.Media;

class DownloadAudioTask extends Task {
    private var resource as AudioResource;

    function initialize(resource as AudioResource) {
        Task.initialize();
        self.resource = resource;
    }

    function execute() as Void {
        System.println(self.resource);
        
        var context = {
            "ID" => self.resource.getId(),
            "URL" => self.resource.href
        };
        var options = {
            :context => context,
            :fileDownloadProgressCallback => method(:onProgress),
            :mediaEncoding => Media.ENCODING_M4A,
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO
        };
        
        Communications.makeWebRequest(self.resource.href, null, options, method(:onReceive));
    }

    function onProgress(totalBytesTransferred as Number, fileSize as Number or Null) as Void {
        System.println("[+]\tBytes transferred " + totalBytesTransferred + " of " + fileSize);
        // Communications.notifySyncProgress(75);
    }

    function onReceive(responseCode as Number, media as Dictionary?, context as Dictionary) as Void {
        System.println("[+]\tResponse Code " + responseCode);
        // System.println(media);
        System.println("[+]\t" + context);

        if (responseCode != 200) {
            System.println("ONRECEIVE FAILED " + responseCode);
            // TODO REPORT FAILURE
            Task.execute();
        }

        // var contentType = (media as Media.ContentRef).getContentType();
        var refId = (media as Media.ContentRef).getId();

        // System.println("**** MEDIA CONTENT REF ****!");
        // System.println(contentType);
        // System.println(refId);

        // here we should let Audio file have some additional context
        var file = new AudioAsset(refId);
        file.setResourceId(context["ID"] as String);
        file.setMetadata(); // example of using content to set meta data

        System.println("[END] ONRECEIVE!");
        
        Task.execute();
    }
}

class DownloadAudioTaskQueue extends TaskQueue {

}
