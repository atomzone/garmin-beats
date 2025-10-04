import Toybox.Communications;
import Toybox.Lang;
import Toybox.Media;

// typedef Error as { :code as Number, :message as String };

class DownloadAudioTask extends Task {
    private var resource as AudioResource;
    // var onError as Method(error as Error) as Void;
    var onProgressCallback as Method(percentageComplete as Number) as Void?;
    // var timeout as Number = 100;

    function initialize(resource as AudioResource) {
        Task.initialize();
        self.resource = resource;
    }

    function execute() as Void {
        // with params this request is jellyfin specific
        var request = new HttpRequest({ 
            :href => self.resource.href,
            :parameters => {
                // "Container" => "mp3,m4a,wav",
                "Container" => "m4a",
                "TranscodingContainer" => "m4a",
                "TranscodingProtocol" => "http",
                "AudioCodec" => "aac",
                "api_key" => "8f63a081dc484594b0cc7c1cb48ebd4f"
            }
        }, method(:onResponse));

        var context = {
            "ID" => self.resource.getId(),
            "URL" => self.resource.href
        };
        
        $.am.debug("[!] Begin (async) request.download()");
        request.download(context, method(:onProgress));
        $.am.debug("[!] End (call) request.download()");
    
        $.am.debug(
            Lang.format("[+]\tTask $1$", [self.hashCode()])
        );

        // start a timer 
        // this may allow us to cancel long running tasks
        // var task = new DelayedTask(self.timeout);
        // task.onComplete = new Method(self, :onTimeOut) as Method(task as Task) as Void;
    }

    // function onTimeOut(task as Task) as Void {
    //     // here i think we should ERROR
    //     // and that ERROR stops the queue from processing!
    //     $.am.debug("TIMEOUT " + task.hashCode()) ;
    //     self.onError.invoke({ :code => 100, :message => "HI" });
    //     // Communications.cancelAllRequests();
    // }

    // Righ then!
    // this function should calculate and/or suggest how complete the download is completed
    // and inform the Queue, so it an update the UI as appropriate 
    function onProgress(totalBytesTransferred as Number, filesize as Number?) as Void {
        var percentageComplete = 0;

        // If filesize is not known, estimate based on heuristics
        if (filesize == null || filesize <= 0) {
            filesize = estimateFileSize((1024 * 1024) * 3);
        }

        if (filesize > 0) {
            percentageComplete = self.calculatePercentage(totalBytesTransferred, filesize);
        }

        $.am.debug("[+]\tTransferred: " + totalBytesTransferred + " / " + filesize + " (" + percentageComplete + "%)");

        if (self.onProgressCallback != null) {
            self.onProgressCallback.invoke(percentageComplete);
        }
    }

    function onResponse(
        data as Dictionary or String or Null, 
        context as { :callback as Method }
    ) as Void {
        $.am.debug("[D]\t" + data);
        $.am.debug("[C]\t" + context);

        var refId = (data as Media.ContentRef).getId();

        $.am.debug("[R]\t" + refId);

        // here we should let Audio file have some additional context
        var file = new AudioAsset(refId);
        file.setResourceId(context["ID"] as String);
        file.setMetadata(); // example of using content to set meta data

        Task.execute();
    }

    // Helper function to estimate unknown filesize
    function estimateFileSize(currentMax as Number) as Number {
        // Grow the estimate gently — 50% more than current best guess
        return (currentMax.toDouble() * 1.5).toNumber();
    }

    // Calculate and clamp progress percentage
    function calculatePercentage(transferred as Number, total as Number) as Number {
        if (total <= 0 || transferred <= 0) {
            return 0;
        }

        var percent = ((transferred.toDouble() / total.toDouble()) * 100).toNumber();
        return (percent >= 100) ? 99 : percent;
    }
}

// class DownloadAudioTaskQueue extends TaskQueue {

// }
