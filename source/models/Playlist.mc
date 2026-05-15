import Toybox.Lang;

typedef PlaylistItemType as {
    "refId" as Number
};

typedef PlaylistType as {
    "version" as Number,
    "queue" as Array<PlaylistItemType>,
    "playFromIndex" as Number,
    "lastTrackPosition" as Number?
};

class Playlist {

    private var _assets as Array<AudioAsset>;
    private var _assetCount as Number = 0;
    private var _playFromIndex as Number;
    private var _lastTrackPositionSeconds as Number = 0;

    function initialize(assets as Array<AudioAsset>, playFromIndex as Number) {
        _assets = assets;
        _assetCount = assets.size();
        _playFromIndex = isValidIndex(playFromIndex) ? playFromIndex : 0;
    }

    function getAssetCount() as Number {
        return _assetCount;
    }

    function getAssetByIndex(index as Number) as AudioAsset {
        return _assets[index];
    }

    function getCurrentTrackIndex() as Number {
        return _playFromIndex;
    }

    function setTrackIndex(index as Number) as Void {
        _playFromIndex = index;
    }

    function getCurrentTrackPosition() as Number {
        return _lastTrackPositionSeconds;
    }

    function setCurrentTrackPosition(position as Number) as Void {
        _lastTrackPositionSeconds = position;
    }

    function isValidIndex(index as Number) as Boolean {
        return !(index < 0 or index > _assetCount - 1);
    }

    function serialize() as PlaylistType {
        var queue = [] as Array<PlaylistItemType>;

        for (var i = 0; i < _assets.size(); i++) {
            queue.add({ "refId" => _assets[i].getRefId() as Number } as PlaylistItemType);
        }

        return {
            "version" => 1,
            "queue" => queue,
            "playFromIndex" => _playFromIndex,
            "lastTrackPosition" => _lastTrackPositionSeconds
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

    var playlist = new Playlist(
        AudioAsset.fromRefIds(refIds),
        payload["playFromIndex"] as Number
    );

    var lastTrackPos = DictionaryUtils.getNumber(payload as Dictionary, "lastTrackPosition");
    if (lastTrackPos != null && lastTrackPos > 0) {
        playlist.setCurrentTrackPosition(lastTrackPos);
    }

    return playlist;
}
