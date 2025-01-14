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

class Task { // extends Lang.Object { 
    function execute(onComplete as Method) as Void {
        System.println("SYNC TRACK");
        
        onComplete.invoke(self);
    }
}

class TaskQueue {
    // why a Dictionary?
    var queue as Dictionary<Number, Task> = {} as Dictionary<Number, Task>;

    function add(task as Task) as Void {
        self.queue.put(task.hashCode(), task);
    }

    function get(task as Task) as Task? {
        return self.queue.get(task.hashCode());
    }

    function process() as Void {
        var tasks = self.queue.values();

        for (var index = 0; index < tasks.size(); index++) {
            var task = self.get(tasks[index]);

            if (task != null) {
                var callback = new Method(self, :remove);
                task.execute(callback);
            }
        }
    }

    function remove(task as Task) as Void {
        System.println("REMOVE " + task);
        self.queue.remove(task.hashCode());
    }
}

