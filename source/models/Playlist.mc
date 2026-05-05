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
    private var _playFromIndex as Number;
    private var _lastTrackPositionSeconds as Number;

    function initialize(assets as Array<AudioAsset>, playFromIndex as Number) {
        _assets = assets;
        _playFromIndex = playFromIndex < 0 ? 0 : playFromIndex;
        _lastTrackPositionSeconds = 0;
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

    function getLastTrackPositionSeconds() as Number {
        return _lastTrackPositionSeconds;
    }

    function setLastTrackPositionSeconds(seconds as Number) as Void {
        _lastTrackPositionSeconds = seconds < 0 ? 0 : seconds;
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
        playlist.setLastTrackPositionSeconds(lastTrackPos);
    }

    return playlist;
}
