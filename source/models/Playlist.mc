import Toybox.Lang;

typedef PlaylistItemType as {
    "refId" as Number
};

typedef PlaylistType as {
    "version" as Number,
    "queue" as Array<PlaylistItemType>,
    "playFromIndex" as Number
};

class Playlist {

    private var _assets as Array<AudioAsset>;
    private var _playFromIndex as Number;

    function initialize(assets as Array<AudioAsset>, playFromIndex as Number) {
        _assets = assets;
        _playFromIndex = playFromIndex < 0 ? 0 : playFromIndex;
    }

    function getAssets() as Array<AudioAsset> {
        return _assets;
    }

    function getPlayFromIndex() as Number {
        return _playFromIndex;
    }

    function setPlayFromIndex(playFromIndex as Number) as Void {
        _playFromIndex = playFromIndex < 0 ? 0 : playFromIndex;
    }

    function serialize() as PlaylistType {
        var queue = [] as Array<PlaylistItemType>;

        for (var i = 0; i < _assets.size(); i++) {
            queue.add({ "refId" => _assets[i].getRefId() as Number } as PlaylistItemType);
        }

        return {
            "version" => 1,
            "queue" => queue,
            "playFromIndex" => _playFromIndex
        } as PlaylistType;
    }
}

// Deserializes the payload dict passed via Media.startPlayback into a Playlist.
function playlistFromPayload(payload as PlaylistType) as Playlist {
    var queue = payload["queue"] as Array<PlaylistItemType>;
    var refIds = [] as Array<Number>;

    for (var i = 0; i < queue.size(); i++) {
        refIds.add(queue[i]["refId"] as Number);
    }

    return new Playlist(
        AudioAsset.fromRefIds(refIds),
        payload["playFromIndex"] as Number
    );
}
