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

    function onTaskComplete(task as Task) as Void {
        System.println(
            Lang.format("[+]\tTask($3$) $1$ of $2$", [self.activeTask, self.taskCount, self.hashCode()])
        );
        self.queue.remove(task);
        self.process();
    }

    private function process() as Void {
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
        self.queue = [];
    }
}

class CommunicationsQueue extends TaskQueue {
    function add(task as Task) as Void {
        // task.onError = new Method(self, :onError) as Method(error as Error) as Void;
        (task as DownloadAudioTask).onProgressCallback = new Method(self, :onProgress) as Method(percentageComplete as Number) as Void;
        TaskQueue.add(task);
    }

    // function onError(error as Error) as Void {
    //     System.print(error);
    //     self.stop();
    // }

    // function onTaskComplete(task as DownloadAudioTask) as Void {


    //     var percentageComplete = (100 * self.activeTask) / self.taskCount;
    //     System.println(percentageComplete + "%");

    //     Communications.notifySyncProgress(percentageComplete);

    //     TaskQueue.onTaskComplete(task);
    // }

    function onProgress(taskPercentageComplete as Number) as Void {
        System.println("[+]\tTASK IS percentageComplete " + taskPercentageComplete);

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

    function stop() as Void {
        // Communications.notifySyncProgress(100);
        Communications.notifySyncComplete(null);
        TaskQueue.stop();
    }
}