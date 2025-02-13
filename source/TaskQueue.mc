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

    function add(task as Task) as Void {
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
    // function add(task as Task) as Void {
    //     // task.onError = new Method(self, :onError) as Method(error as Error) as Void;
    //     TaskQueue.add(task);
    // }

    // function onError(error as Error) as Void {
    //     System.print(error);
    //     self.stop();
    // }

    // function onTaskComplete(task as Task) as Void {
    //     var percentageComplete = (100 / self.taskCount) / self.activeTask;
    //     System.println(percentageComplete + "%");

    //     Communications.notifySyncProgress(percentageComplete);

    //     TaskQueue.onTaskComplete(task);
    // }

    function stop() as Void {
        Communications.notifySyncComplete(null);
        TaskQueue.stop();
    }
}