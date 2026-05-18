import Toybox.Application;
import Toybox.Lang;

typedef AudioResourceType as {
    "source" as AudioSourceType,
    "meta" as AudioMetadataType?
};

class AudioResource {   

    private var _checksum as String?;
    private var _source as AudioSource;
    private var _metadata as AudioMetadata;

    function initialize(raw as AudioResourceType) {
        var source = raw["source"] as AudioSourceType;
        var metadata = raw["meta"] as AudioMetadataType?;

        _source = new AudioSource(source);
        _metadata = new AudioMetadata(metadata);
    }

    public function getLogicalId() as String {
        return StringUtils.checksum(getSourceUrl());
    }

    public function getSourceUrl() as String {
        return _source.getUrl();
    }

    public function getTitle() as String? {
        return _metadata._title;
    }

    public function getArtist() as String? {
        return _metadata._artist;
    }

    public function getAlbum() as String? {
        return _metadata._album;
    }

    public function getChecksum() as String {
        if (_checksum != null) {
            return _checksum;
        }

        var canonical = _source.canonicalize() + "|" + _metadata.canonicalize();
        _checksum = StringUtils.checksum(canonical);

        return _checksum;
    }

    public function serialize() as AudioResourceType {
        return {
            "source" => _source.serialize(),
            "meta" => _metadata.serialize()
        };
    }

    static function fromArray(resources as Array<AudioResourceType>) as Array<AudioResource> {
        var audio = [];

        for (var index = 0, limit = resources.size(); index < limit; index++) {
            audio.add(new AudioResource(resources[index]));
        }
    
        return audio;
    }
}
