using Toybox.Media;
import Toybox.Application;
import Toybox.Lang;

typedef TrackRecord as {
    "id" as String,        // Media.ContentRef id
    "contentRefId" as Object, // Media.ContentRef id
    "url" as String,       // source URL
    "title" as String?     // optional metadata
};

class Track {

    private var _contentRefId as Object;
    private var _id as String;
    private var _url as String;
    private var _title as String?;

    function initialize(contentRefId as Object, id as String, url as String, title as String?) {
        _contentRefId = contentRefId;
        _id = id;
        _url = url;
        _title = title;
    }

    // ------------------------
    // Accessors
    // ------------------------

    function getId() as String {
        return _id;
    }

    function getContentRefId() as Object {
        return _contentRefId;
    }

    function getUrl() as String {
        return _url;
    }

    function getTitle() as String? {
        return _title;
    }

    // ------------------------
    // Media bridge
    // ------------------------

    // function getContentRef() as Media.ContentRef {
    //     return new Media.ContentRef(_id, Media.CONTENT_TYPE_AUDIO);
    // }

    // function getContent() as Media.Content? {
    //     var ref = getContentRef();

    //     var metadata = {
    //         :title => (_title != null) ? _title : "Unknown"
    //     };

    //     return new Media.ActiveContent(ref, metadata, 0);
    // }

    // ------------------------
    // Serialization
    // ------------------------

    function serialize() as TrackRecord {
        return {
            "id" => _id,
            "contentRefId" => _contentRefId,
            "url" => _url,
            "title" => _title
        };
    }

    static function deserialize(data as TrackRecord) as Track? {
        if (!(data instanceof Dictionary) || !data.hasKey("id") || !data.hasKey("url")) {
            return null;
        }

        return new Track(
            data["contentRefId"] as Object,
            data["id"] as String,
            data["url"] as String,
            data["title"] as String?
        );
    }
}

// function buildTracks(resources as Array<AudioResourceType>) as Array<AudioResource> {
//     var audio = [];

//     if (resources instanceof Array) {
//         for (var index = 0, limit = resources.size(); index < limit; index++) {
//             audio.add(new AudioResource(resources[index]));
//         }
//     }

//     return audio;
// }

// function serializeTracks(resources as Array<AudioResource>) as Array<Application.Storage.ValueType> {
//     var audio = [];

//     if (resources instanceof Array) {
//         for (var index = 0, limit = resources.size(); index < limit; index++) {
//             audio.add(resources[index].serialize());
//         }
//     }

//     return audio;
// }
