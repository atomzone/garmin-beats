using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Media as Media;
using Toybox.Communications as Comm;
using Toybox.System as Sys;

import Toybox.Lang;

// =====================================================
// APP
// =====================================================

var am as ApplicationManager = new ApplicationManager();

class AppEntry extends App.AudioContentProviderApp {

    function initialize() {
        App.AudioContentProviderApp.initialize();
    }

    function getContentDelegate(audioRefs as App.PersistableType) as Media.ContentDelegate {
        $.am.debug("App.getContentDelegate() " + audioRefs);

        // playlist
        // return new TestContentDelegate(
        //     buildPlaylist(audioRefs as Array<App.PropertyValueType>?)
        // );

        var tracks = [];

        if (audioRefs != null) {
            for (var index = 0; index < audioRefs.size(); index++) {
                tracks.add(new AudioFile(audioRefs[index]));
            }
        }

        return new TestContentDelegate(tracks);
    }

    function getSyncDelegate() as Comm.SyncDelegate? {
        return new TestSyncDelegate();
    }

    function getPlaybackConfigurationView() {
        return [ new MainMenuView(), new MainMenuDelegate() ];
    }

    function getSyncConfigurationView() {
        return getPlaybackConfigurationView();
    }
}

// =====================================================
// UI
// =====================================================

class MainMenuView extends Ui.Menu2 {

    function initialize() {
        Ui.Menu2.initialize({:title => "Test ACP"});

        addItem(new Ui.MenuItem("Download Track", null, :download, {}));
        addItem(new Ui.MenuItem("Play", null, :play, {}));
    }
}

class MainMenuDelegate extends Ui.Menu2InputDelegate {

    function initialize() {
        Ui.Menu2InputDelegate.initialize();
    }

    function onSelect(item as Ui.MenuItem) {

        var id = item.getId();

        if (id == :download) {

            Sys.println("QUEUE");

            var queue = [
                {
                    "id" => "1",
                    "name" => "Track",
                    "url" => "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
                }
            ];

            Application.Storage.setValue("SYNC_SELECTION", queue);

            Communications.startSync();

        } else if (id == :play) {

            Sys.println("PLAY");

            // launch it in playback mode
            var storedTracks = Application.Storage.getValue("TRACKS") as App.PersistableType?;
            if (storedTracks == null) { return; }

            // A serializable object to pass to AudioContentProviderApp.getContentDelegate() when the app starts in playback mode
            Media.startPlayback(storedTracks);
        }
    }
}

// =====================================================
// CONTENT
// =====================================================

class TestContentDelegate extends Media.ContentDelegate {

    private var mIterator as Media.ContentIterator;

    function initialize(playlist as Array<AudioFile>) {
        Media.ContentDelegate.initialize();

        // mIterator = new pumpContentIterator(playlist);
        mIterator = new TestIterator(playlist);
    }

    function getContentIterator() as Media.ContentIterator? {
        return mIterator;
    }

    // Respond to a user ad click
    function onAdAction(adContext as Object) as Void {
        $.am.debugWithArgs("[onAdAction]", adContext);
    }

    function onCustomButton(button as Media.CustomButton) as Void {
        $.am.debugWithArgs("[onCustomButton]", button);
    }

    function onRepeat() as Void {
        $.am.debug("[onRepeat]");
    }
    
    // Respond to a command to turn shuffle on or off
    function onShuffle() as Void {
        $.am.debug("[onShuffle]");
    }

    // Handles a notification from the system that an event has
    // been triggered for the given song
    function onSong(contentRefId as Object, songEvent as Media.SongEvent, playbackPosition as Number or Media.PlaybackPosition) as Void {
        // self.songEventHandler.notify(contentRefId, songEvent, playbackPosition);
        $.am.debug("[onSong] contentRefId " + contentRefId);
        $.am.debug("[onSong] songEvent " + songEvent);
        $.am.debug("[onSong] playbackPosition " + playbackPosition);
    }

    // Respond to a thumbs-down action
    function onThumbsDown(contentRefId as Object) as Void {
        $.am.debugWithArgs("[onThumbsDown]", contentRefId);
    }

    // Respond to a thumbs-up action
    function onThumbsUp(contentRefId as Object) as Void {
        $.am.debugWithArgs("[onThumbsUp]", contentRefId);
    }

    // function resetContentIterator() as ContentIterator or Null {
    //     return new pumpContentIterator(self.playlist);
    // }
}

class TestIterator extends Media.ContentIterator {

    private var tracks as Array<AudioFile>;
    private var playIndex as Number;

    function initialize(tracks as Array<AudioFile>) {
        Media.ContentIterator.initialize();

        self.tracks = tracks;
        self.playIndex = 0;
    }

    function get() as Media.Content? {
        if (self.playIndex > self.tracks.size() - 1) {
            return null;
        }

        var file = self.tracks[self.playIndex];
        return file.getContent();
    }

    function next() as Media.Content? {
        self.playIndex += 1;
        return get();
    }

    function previous() as Media.Content? {
        if (self.playIndex > 0) {
            self.playIndex -= 1;
        }
        return get();
    }

    // Determine if the th[]e current track can be skipped.
    function canSkip() as Boolean {
        $.am.debug("canSkip");
        return false;
    }

    // Get the current media content playback profile
    // this is function is needed
    function getPlaybackProfile() as Media.PlaybackProfile? {
        var profile = new PlaybackProfile();
        profile.attemptSkipAfterThumbsDown = false;
        profile.playbackControls = [
            PLAYBACK_CONTROL_SKIP_BACKWARD,
            PLAYBACK_CONTROL_NEXT,
            PLAYBACK_CONTROL_PLAYBACK,
            PLAYBACK_CONTROL_PREVIOUS,
            PLAYBACK_CONTROL_SKIP_FORWARD,
            PLAYBACK_CONTROL_RATING,
            PLAYBACK_CONTROL_VOLUME,
            PLAYBACK_CONTROL_SOURCE,
            PLAYBACK_CONTROL_LIBRARY
        ];
        profile.playbackNotificationThreshold = 1;
        profile.requirePlaybackNotification = false;
        profile.skipPreviousThreshold = null;
        
        return profile;
    }

    // Determine if playback is currently set to shuffle.
    function shuffling() as Boolean {
        $.am.debug("shuffling");
        return false;
    }

}

// =====================================================
// SYNC
// =====================================================

class TestSyncDelegate extends Comm.SyncDelegate {

    private var mQueue as Array;

    function initialize() {
        Comm.SyncDelegate.initialize();

        var q = Application.Storage.getValue("SYNC_SELECTION") as Array?;
        mQueue = (q != null) ? q : [];
    }

    function isSyncNeeded() as Boolean {
        return mQueue.size() > 0;
    }

    function onStartSync() {
        $.am.debug("[!] SYNC START");
        downloadNext();
    }

    function downloadNext() {

        if (mQueue.size() == 0) {
            Application.Storage.deleteValue("SYNC_SELECTION");
            Comm.notifySyncComplete(null);
            $.am.debug("[!] SYNC DONE");
            return;
        }

        var track = mQueue[0];
        var context = { :track => track };
        var request = new HttpRequest({ 
            :href => track["url"],
            :parameters => {}
        }, method(:onResponse));
      
        $.am.debug("[!] Begin (async) request.download()");
        request.downloadMp3(context, method(:onProgress));
        $.am.debug("[!] End (call) request.download()");
    
        $.am.debug(
            Lang.format("[+]\tTask $1$", [self.hashCode()])
        );
    }

    function onProgress(totalBytesTransferred as Number, filesize as Number?) as Void {
        var percentageComplete = 0;

        if (filesize > 0) {
            percentageComplete = ((totalBytesTransferred.toDouble() / filesize.toDouble()) * 100).toNumber();
        }

        $.am.debug("[+]\tTransferred: " + totalBytesTransferred + " / " + filesize + " (" + percentageComplete + "%)");

        notifySyncProgress(percentageComplete);
    }

    function onResponse(
        data as Dictionary or String or Null, 
        context as { :callback as Method }
    ) as Void {
        $.am.debug("[D]\t" + data);
        $.am.debug("[C]\t" + context);

        var refId = (data as Media.ContentRef).getId();
        $.am.debug("[R]\t" + refId);

        // // here we should let Audio file have some additional context
        // var file = new AudioAsset(refId);

        // // what is this doing?
        // file.setResourceId(context["ID"] as String); 
        // file.setMetadata(); // example of using content to set meta data

        var trackRefs = Application.Storage.getValue("TRACKS") as Array?;
        trackRefs = (trackRefs == null) ? [] : trackRefs;
        trackRefs.add(refId);
        Application.Storage.setValue("TRACKS", trackRefs);
        
        // remove track from from queue; (on sucess, we need also on fail....)
        mQueue.remove(context[:track]);
        downloadNext();
    }

}
