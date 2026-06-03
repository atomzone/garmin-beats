import Toybox.Lang;

class PlaybackStartPosition {
    enum ResumeMode {
        RESUME,
        NEVER
    }

    private static function defaultCursor() as PlaybackCursorType {
        return {
            "trackIndex" => 0,
            "trackPosition" => 0
        } as PlaybackCursorType;
    }

    static function getCursor(
        playlist as PlaylistAsset,
        storedState as PlaybackStateType?
    ) as PlaybackCursorType {

        var cursorMode = RESUME; // playlist.getResumeMode();

        if (cursorMode == RESUME) {
            return getResumeCursor(playlist, storedState);
        }

        return defaultCursor();
    }

    static private function getResumeCursor(
        playlist as PlaylistAsset,
        storedState as PlaybackStateType?
    ) as PlaybackCursorType {

        if (storedState == null) {
            return defaultCursor();
        }

        if (!(storedState["playlistId"] as String).equals(playlist.getId())) {
            return defaultCursor();
        }

        return {
            "trackIndex" => storedState["trackIndex"],
            "trackPosition" => storedState["trackPosition"]
        } as PlaybackCursorType;
    }
}
