import Toybox.Lang;

class File {
    var href as String;
    var id as String;
    var is_on_device as Boolean;
    var name as String;

    function initialize(href as String, options as Dictionary) {
        self.href = href;
        self.id = options[:id];
        self.is_on_device = options[:is_on_device];
        self.name = options[:name];
    }

    function getId() as String {
        return self.id;
    }

    function toStorage() {
        return {
            "href" => self.href
        };
    }
}
