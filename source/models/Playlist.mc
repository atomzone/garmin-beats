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

    private var _refIds as Array<Object> = [];
    private var _assets as Array<AudioAsset>;
    private var _playFromIndex as Number;
    private var _lastTrackPositionSeconds as Number;

    function initialize(assets as Array<AudioAsset>, playFromIndex as Number) {
        _assets = assets;
        for (var a = 0, limit = assets.size(); a < limit; a++) {
            _refIds.add(assets[a].getRefId());
        }

        _playFromIndex = clampIndex(playFromIndex);
        _lastTrackPositionSeconds = 0;
    }

    function getAssets() as Array<AudioAsset> {
        return _assets;
    }

    function getRefIds() as Array<Object>   {
        return _refIds;
    }

    function getCurrentTrackIndex() as Number {
        return _playFromIndex;
    }

    function setTrackIndex(index as Number) as Void {
        _playFromIndex = index;
    }

    function getResumePositionSeconds() as Number {
        return _lastTrackPositionSeconds;
    }

    // Track start defines the active cursor and invalidates any old resume offset.
    function updateOnTrackStart(playFromIndex as Number) as Boolean {
        var normalizedIndex = clampIndex(playFromIndex);
        var changed = (_playFromIndex != normalizedIndex) || (_lastTrackPositionSeconds != 0);

        _playFromIndex = normalizedIndex;
        _lastTrackPositionSeconds = 0;

        return changed;
    }

    function updateResumePosition(seconds as Number) as Boolean {
        var normalizedSeconds = clampSeconds(seconds);
        if (normalizedSeconds <= 0) {
            return false;
        }

        _lastTrackPositionSeconds = normalizedSeconds;
        return true;
    }

    function restoreResumePosition(seconds as Number) as Void {
        _lastTrackPositionSeconds = clampSeconds(seconds);
    }

    private function clampIndex(playFromIndex as Number) as Number {
        if (playFromIndex < 0) {
            return 0;
        }

        var maxIndex = _assets.size() - 1;
        if (maxIndex >= 0 && playFromIndex > maxIndex) {
            return maxIndex;
        }

        return playFromIndex;
    }

    private function clampSeconds(seconds as Number) as Number {
        return seconds < 0 ? 0 : seconds;
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
        playlist.restoreResumePosition(lastTrackPos);
    }

    return playlist;
}
