import Toybox.Lang;

/*
    var taskQueue = new TaskQueue();

    taskQueue.add(new DelayedTask(1000));
    taskQueue.add(new Task());
    taskQueue.add(new DownloadAudioTask(getAudioResources()[0]));
    taskQueue.add(new DelayedTask(2000));
    taskQueue.add(new Task());
    taskQueue.add(new DownloadAudioTask(getAudioResources()[1]));

    taskQueue.process();
*/

class Task { 
    var onComplete as Method(task as Task) as Void?;

    function execute() as Void {
        System.println("[+]\tExecuting task: " + self);

        if (self.onComplete != null) {
            self.onComplete.invoke(self);
        }
    }
}

class DelayedTask extends Task { 
    private var timeout as Number;

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

// FIFO: first-in-first-out
class TaskQueue {
    private var queue as Array<Task> = [] as Array<Task>;
    private var taskCount as Number = 0;
    private var activeTask as Number = 0;

    function add(task as Task) as Void {
        task.onComplete = new Method(self, :onTaskComplete) as Method(task as Task) as Void;
        self.queue.add(task);
        self.taskCount++;
    }

    function onComplete() as Void {
        // Make noise with Toybox.Attention
        Communications.notifySyncComplete(null);
    }

    function onTaskComplete(task as Task) as Void {
        System.println(
            Lang.format("[+]\tTask($3$) $1$ of $2$", [self.activeTask, self.taskCount, self.hashCode()])
        );

        var percentageComplete = (100 * self.activeTask) / self.taskCount;
        System.println(percentageComplete + "%");
        Communications.notifySyncProgress(percentageComplete);

        self.queue.remove(task);
        self.process();
    }

    function process() as Void {
        if (self.activeTask == self.taskCount) {
            self.onComplete();
            return;
        }
        
        self.activeTask++;
        self.queue[0].execute();
    }
}
