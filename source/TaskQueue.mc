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

// FIFO: first-in-first-out
class TaskQueue {
    private var queue as Array<Task> = [] as Array<Task>;
    protected var taskCount as Number = 0;
    protected var activeTask as Number = 0;

    protected function add(task as Task) as Void {
        task.onComplete = new Method(self, :onTaskComplete) as Method(task as Task) as Void;
        self.queue.add(task);
        self.taskCount++;
    }

    function isEmpty() as Boolean {
        return self.queue.size() == 0;
    }

    function onTaskComplete(task as Task) as Void {
        System.println(
            Lang.format("[+]\tTask($3$) $1$ of $2$", [self.activeTask, self.taskCount, self.hashCode()])
        );
        self.queue.remove(task);
        self.process();
    }

    protected function process() as Void {
        if (self.activeTask == self.taskCount) {
            self.stop();
            return;
        }
        
        self.activeTask++;
        self.queue[0].execute();
    }

    function start() as Void {
        self.process();
    }

    function stop() as Void {
        // is this enough, what happens calling start()
        self.queue = [];
    }
}

class CommunicationsQueue extends TaskQueue {
    var progressIndicator as ProgressBarController;

    function initialize(progressIndicator as ProgressBarController) {
        TaskQueue.initialize();
        self.progressIndicator = progressIndicator;
    }

    function add(task as Task) as Void {
        TaskQueue.add(task);
        // task.onError = new Method(self, :onError) as Method(error as Error) as Void;
        (task as DownloadAudioTask).onProgressCallback = new Method(self, :onProgress) as Method(percentageComplete as Number) as Void;
    }

    // function onError(error as Error) as Void {
    //     System.print(error);
    //     self.stop();
    // }

    function onTaskComplete(task as Task) as Void {
        TaskQueue.onTaskComplete(task);
        self.progressIndicator.setProgress(100.0);
    }

    function onProgress(taskPercentageComplete as Number) as Void {
        System.println("[+]\tTASK IS percentageComplete " + taskPercentageComplete);

        self.progressIndicator.setProgress(taskPercentageComplete.toFloat());

        // queue lenth 1
        // task 1 is 25% complete
        // queue is 25% complete

        // queue lenth 2
        // task 1 is 25% complete
        // queue is 12.5% complete

        // queue lenth 2
        // task 1 is 100% complete
        // task 2 is 25% complete
        // queue is 50% + 12.5% = 62.5% complete
        // queue is 50% + ((50% / 100) * 25%) = 62.5% complete

        // queue lenth 3
        // task 1 is 100% complete
        // task 2 is 100% complete
        // task 3 is 25% complete
        // queue is 33% + 33% + ((33% / 100) * 25%) = 74.25% complete

        var taskMaxPercent = 100 / self.taskCount.toDouble();
        var queueProgressPercent = taskMaxPercent * (self.activeTask.toDouble() - 1);
        var currentTaskCompletePercent = (taskMaxPercent / 100) * taskPercentageComplete;
        var total = queueProgressPercent + currentTaskCompletePercent;

        System.println("taskPercentageComplete " + taskPercentageComplete);
        System.println("taskMaxPercent " + taskMaxPercent);
        System.println("queueProgressPercent " + queueProgressPercent);
        System.println("currentTaskCompletePercent " + currentTaskCompletePercent);
        System.println("total " + total);

        Communications.notifySyncProgress(total.toNumber());

        // self.progressIndicator.setProgress(total.toFloat());

        // queue is queueProgressPercent% + ((taskMaxPercent% / 100) * 25%) = 74.25% complete

        // var queuePercentageComplete = (100 * self.activeTask) / self.taskCount;
        // var taskPercent = (100 / self.taskCount);
        // var combinedPercent = taskPercentageComplete.toDouble() * (taskPercent.toDouble() / 100);

        // System.println(taskPercentageComplete.toDouble());
        // System.println((taskPercent / 100).toDouble());
        // System.println((taskPercent.toDouble() / 100));
        // System.println((taskPercent.toDouble() / 100) * 100);

        // System.println(queuePercentageComplete + "!");
        // System.println(taskPercent + "!");
        // System.println(combinedPercent + "!");

        // Communications.notifySyncProgress(combinedPercent.toNumber());
    }

    protected function process() as Void {
        TaskQueue.process();
        var message = Lang.format("Downloading\n$1$ of $2$", [self.activeTask, self.taskCount]);
        self.progressIndicator.setDisplayString(message);
        self.progressIndicator.setProgress(null);
    }

    function start() as Void {
        TaskQueue.start();
        self.progressIndicator.show();
    }

    function stop() as Void {
        TaskQueue.stop();
        self.progressIndicator.hide();
        Communications.notifySyncComplete(null);
    }
}