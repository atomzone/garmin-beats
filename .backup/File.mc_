import Toybox.Lang;
import Toybox.Cryptography;

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

        // buildId();
    }

    function buildId() as String {
        var hash = new Hash({ :algorithm => Cryptography.HASH_MD5 });
        // hash.update("message");
        
        System.println("1");
        System.println(hash.digest());
        System.println("2");
        System.println(hash.digest().hashCode());
        System.println("3");
        System.println(hash.digest().toString());

        // var ba = new ByteArray().add('t');
        // hash.update(ba);
        // System.println("4");
        // System.println(hash.digest().toString());

        System.println("5");
        System.println(Cryptography.randomBytes(10).hashCode());
        System.println(Cryptography.randomBytes(10).hashCode());
        System.println(Cryptography.randomBytes(10).hashCode());
        System.println(Cryptography.randomBytes(10).hashCode());
        System.println(Cryptography.randomBytes(10).hashCode());

        return "tom";
    }

    function getId() as String {
        return self.id;
    }

    function toStorage() {
        return {
            "href" => self.href,
            "id" => getId(),
            "name" => self.name
        };
    }
}
