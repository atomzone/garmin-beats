import Toybox.Lang;

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

// function tom(task as Task) as Void {
//     System.println(task);
// }

// var task = new DelayedTask(2000);
// task.onComplete = tom();