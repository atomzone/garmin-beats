import Toybox.Application;
import Toybox.Lang;

typedef AudioResourceType as {
    "source" as MediaSourceType,
    "meta" as AudioMetadataType?,
    "chapters" as Array<AudioChapterType>?
};

// Transient track snapshot
// Identity derived from getChecksum()
class AudioResource {   

    private var _checksum as String?;
    private var _source as MediaSource;
    private var _metadata as AudioMetadata;
    private var _chapters as Array<AudioChapter> = [];

    function initialize(raw as AudioResourceType) {
        var source = raw["source"] as MediaSourceType;
        var metadata = raw["meta"] as AudioMetadataType?;

        _source = new MediaSource(source);
        _metadata = new AudioMetadata(metadata);

        if (raw["chapters"] != null) {
            _chapters = AudioChapter.fromArray(raw["chapters"] as Array<AudioChapterType>);
        }
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

    public function getSource() as MediaSource {
        return _source;
    }

    public function getMetadata() as AudioMetadata {
        return _metadata;
    }

    public function getChapters() as Array<AudioChapter>? {
        return _chapters;
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
            "meta" => _metadata.serialize(),
            "chapters" => AudioChapter.serializeArray(_chapters)
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
