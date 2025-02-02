import Toybox.Communications;
import Toybox.Lang;
import Toybox.Media;

// typedef Error as { :code as Number, :message as String };

class DownloadAudioTask extends Task {
    private var resource as AudioResource;
    // var onError as Method(error as Error) as Void;
    // var onProgressCallback as Method(percentageComplete as Number) as Void?;
    // var timeout as Number = 100;

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
        
        System.println(
            Lang.format("[+]\tTask $1$", [self.hashCode()])
        );

        // start a timer 
        // this may allow us to cancel long running tasks
        // var task = new DelayedTask(self.timeout);
        // task.onComplete = new Method(self, :onTimeOut) as Method(task as Task) as Void;

        Communications.makeWebRequest(self.resource.href, null, options, method(:onReceive));
        // task.execute();
    }

    // function onTimeOut(task as Task) as Void {
    //     // here i think we should ERROR
    //     // and that ERROR stops the queue from processing!
    //     System.println("TIMEOUT " + task.hashCode()) ;
    //     self.onError.invoke({ :code => 100, :message => "HI" });
    //     // Communications.cancelAllRequests();

    // }

    function onProgress(totalBytesTransferred as Number, filesize as Number?) as Void {
        // if (self.onProgressCallback == null) {
        //     return;
        // }
        
        var percentageComplete = 50; // optimism

        if (filesize != null && totalBytesTransferred > 0) {
            percentageComplete = (100 * filesize) / totalBytesTransferred;
        }

        System.println("[+]\tBytes transferred " + totalBytesTransferred + " of " + filesize);
        System.println("[+]\tpercentageComplete " + percentageComplete);

        // self.onProgressCallback.invoke(percentageComplete);
    }

    function onReceive(responseCode as Number, media as Dictionary?, context as Dictionary) as Void {
        System.println("[+]\tResponse Code " + responseCode);
        // System.println(media);
        System.println("[+]\t" + context);

        if (responseCode != 200) {
            System.println("ONRECEIVE FAILED " + responseCode);
            // TODO REPORT FAILURE
            Task.execute();
            return;
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

// class DownloadAudioTaskQueue extends TaskQueue {

// }
