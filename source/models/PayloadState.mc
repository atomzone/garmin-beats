import Toybox.Lang;

typedef PayloadQueueItemType as {
    "refId" as Number
};

typedef PayloadStateType as {
    "version" as Number,
    "queue" as Array<PayloadQueueItemType>,
    "playFromIndex" as Number,
    "shuffle" as Boolean,
    "repeatMode" as String,
    "source" as String
};

function buildPayloadStateFromAssets(
    assets as Array<AudioAsset>,
    source as String,
    playFromIndex as Number
) as PayloadStateType {
    var queue = [] as Array<PayloadQueueItemType>;

    for (var i = 0; i < assets.size(); i++) {
        var asset = assets[i];

        queue.add({
            "refId" => asset.getRefId() as Number
        } as PayloadQueueItemType);
    }

    return {
        "version" => 1,
        "queue" => queue,
        "playFromIndex" => playFromIndex,
        "shuffle" => false,
        "repeatMode" => "off",
        "source" => source
    } as PayloadStateType;
}

function payloadStateRefIds(payload as PayloadStateType) as Array<Number> {
    var refs = [] as Array<Number>;
    var queue = payload["queue"] as Array<PayloadQueueItemType>;

    for (var i = 0; i < queue.size(); i++) {
        refs.add(queue[i]["refId"] as Number);
    }

    return refs;
}

function payloadStateOrderedRefIds(payload as PayloadStateType?) as Array<Number>? {
    if (payload == null) {
        return null;
    }
    var refs = payloadStateRefIds(payload);
    var startIndex = payload["playFromIndex"] as Number;

    if (refs.size() == 0 || startIndex <= 0 || startIndex >= refs.size()) {
        return refs;
    }

    var ordered = [] as Array<Number>;

    for (var i = startIndex; i < refs.size(); i++) {
        ordered.add(refs[i]);
    }

    for (var j = 0; j < startIndex; j++) {
        ordered.add(refs[j]);
    }

    return ordered;
}