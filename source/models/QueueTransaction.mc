import Toybox.Lang;

class QueueTransaction {

    private var _op as String;
    private var _entity as String;
    private var _payload as Dictionary;

    function initialize(raw as QueueTransactionType) {
        _op = raw["op"];
        _entity = raw["entity"];
        _payload = raw["payload"];
    }

    function getOperation() as String {
        return _op;
    }

    function getEntity() as String {
        return _entity;
    }

    function getPayload() as Dictionary {
        return _payload;
    }

    function serialize() as QueueTransactionType {
        return {
            "op" => _op,
            "entity" => _entity,
            "payload" => _payload
        };
    }
}