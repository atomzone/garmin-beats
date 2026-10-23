using Toybox.Media;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Graphics;
import Toybox.Lang;

class MediaUtils {

    static function getContentRef(refId as Object) as Media.ContentRef {
        return new Media.ContentRef(refId, Media.CONTENT_TYPE_AUDIO);
    }

    static function getContent(refId as Object) as Media.Content {
        return Media.getCachedContentObj(getContentRef(refId));
    }

    static function getContentWithMetadata(
        refId as Object, 
        metadata as Media.ContentMetadata
    ) as Media.Content {
        return new Media.Content(getContentRef(refId), metadata);
    }
    
    // Currently unused: no active call sites in source.
    static function getActiveContent(refId as Object, startPositionSeconds as Number) as Media.Content {
        var content = MediaUtils.getContent(refId);

        return new Media.ActiveContent(
            content.getContentRef(), content.getMetadata(), startPositionSeconds
        );
    }

    static function getActiveContentWithMetadata(
        refId as Object, 
        metadata as Media.ContentMetadata,
        startPositionSeconds as Number
    ) as Media.Content {
        return new Media.ActiveContent(
            getContentRef(refId), metadata, startPositionSeconds
        );
    }

    static function getCachedMediaRefIds(contentType as Media.ContentType) as Array<Object> {
        var iterator = Media.getContentRefIter({ :contentType => contentType });
        var ids = [];

        if (iterator as Media.ContentRefIterator? == null) {
            return ids;
        }

        var ref = iterator.next();
        while (ref != null) {
            ids.add(ref.getId());
            ref = iterator.next();
        }

        return ids;
    }

    static function delete(refId as Object) as Void {
        Media.deleteCachedItem(getContentRef(refId));
    }

    public static function createBitmapFromSource(source as MediaSource?) as Ui.Bitmap? {
        if (source == null) {
            return null;
        }

        try {
            var image = AppStores.images.load(source.getId());
            if (image == null) {
                return null;
            }

            return new Ui.Bitmap({
                :bitmap => image as Graphics.BitmapReference
            });
        }
        catch (e) {
            $.am().logger().warn("[createBitmapFromSource]", {
                "source" => source.serialize(),
                "error" => e.getErrorMessage()
            });
        }

        return null;
    }

    public static function createArtwork(checksum as String, size as Number) as Graphics.BufferedBitmapReference {
        var bitmapRef = Graphics.createBufferedBitmap({
            :width => size,
            :height => size
        });

        var bitmap = bitmapRef.get() as Graphics.BufferedBitmap;
        var dc = bitmap.getDc();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Experiment settings.
        var safeSize = size < 48 ? size : 48;
        var verticalOffset = 3;
        var accentColor = Graphics.COLOR_RED;

        if (safeSize <= verticalOffset) {
            return bitmapRef;
        }

        var maxHeight = safeSize - verticalOffset;

        // Stable seed derived from the checksum.
        var seed = 0;

        for (var i = 0; i < checksum.length(); i += 1) {
            var digit = (checksum.substring(i, i + 1) as String).toNumberWithBase(16);

            if (digit != null) {
                seed = (seed * 31 + (digit as Number) + 1) % 65536;
            }
        }

        if (seed == 0) {
            seed = 1;
        }

        // One-pixel bars separated by one-pixel gaps.
        var barStride = 2;
        var barCount = (safeSize + barStride - 1) / barStride;
        var amplitudes = [];

        for (var i = 0; i < barCount; i += 1) {
            seed = (seed * 25173 + 13849) % 65536;

            // Preserve a broad range of peak heights.
            var amplitude = 1 + (seed * maxHeight / 65536);
            amplitudes.add(amplitude);
        }

        // Smooth neighbouring bars into clusters.
        for (var i = 0; i < barCount; i += 1) {
            var previous = amplitudes[i > 0 ? i - 1 : i] as Number;
            var current = amplitudes[i] as Number;
            var next = amplitudes[
                i < barCount - 1 ? i + 1 : i
            ] as Number;

            var height = (previous + current * 2 + next) / 4;

            if (height < 1) {
                height = 1;
            }
            if (height > maxHeight) {
                height = maxHeight;
            }

            var x = i * barStride;
            var y = verticalOffset;
            var endY = y + height - 1;

            if (x < safeSize && endY < safeSize) {
                // Main bar.
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
                dc.fillRectangle(x, y, 1, height);

                // Single coloured pixel at the bar's lower edge.
                dc.setColor(accentColor, Graphics.COLOR_BLACK);
                dc.drawLine(x, endY, x, endY);
            }
        }

        return bitmapRef;
    }

}
