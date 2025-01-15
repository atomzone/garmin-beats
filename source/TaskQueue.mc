import Toybox.Lang;

// class DeleteTask extends Task {
//     function execute() as Boolean {
//         System.println("DELETE RECORD");

//         return true;
//     }
// }

// class SyncTask extends Task {
//     function execute() as Boolean {
//         System.println("SYNC TRACK");

//         return true;
//     }
// }

class Task { 
    var onComplete as Method(task as Task) as Void?;

    function execute() as Void {
        System.println("Executing task");

        if (self.onComplete != null) {
            self.onComplete.invoke(self);
        }
    }
}

class DelayedTask extends Task { 
    var timeout as Number;

    function initialize(timeout as Number) {
        Task.initialize();
        self.timeout = timeout;
    }

    function execute() as Void {
        var myTimer = new Timer.Timer();
        var callback = new Method(self, :onTimerCallback) as Method() as Void;
        
        myTimer.start(callback, self.timeout, false);
    }

    function onTimerCallback() as Void {
        Task.execute();
    }
}

// class DownloadAudioTask extends Task {

// }

// FIFO: first-in-first-out
class TaskQueue {
    private var queue as Array<Task> = [] as Array<Task>;

    function add(task as Task) as Void {
        task.onComplete = new Method(self, :onTaskComplete) as Method(task as Task) as Void;
        self.queue.add(task);
    }

    function onTaskComplete(task as Task) as Void {
        System.println("TASK COMPLETED: " + task);

        self.remove(task);
        self.process();
    }

    function process() as Void {
        if (self.queue.size() > 0) {
            self.queue[0].execute();
        }
    }

    function remove(task as Task) as Void {
        self.queue.remove(task);
    }
}

