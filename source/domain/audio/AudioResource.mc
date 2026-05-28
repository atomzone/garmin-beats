import Toybox.Application;
import Toybox.Lang;

typedef AudioResourceType as {
    "source" as AudioSourceType,
    "meta" as AudioMetadataType?
};

// Transient observation
// Identity derived from getChecksum()
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

    public function getSourceUrl() as String {
        return _source.getUrl();
    }

    public function getTitle() as String? {
        return _metadata.getTitle();
    }

    public function getArtist() as String? {
        return _metadata.getArtist();
    }

    public function getAlbum() as String? {
        return _metadata.getAlbum();
    }

    public function getSource() as AudioSource {
        return _source;
    }

    public function getMetadata() as AudioMetadata {
        return _metadata;
    }

    public function getChecksum() as String {
        if (_checksum != null) {
            return _checksum;
        }

        _checksum = StringUtils.checksum(canonicalize());
        return _checksum;
    }

    public function canonicalize() as String {
        return _source.canonicalize() + "|" + _metadata.canonicalize();
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
