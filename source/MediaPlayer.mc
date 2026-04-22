using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Media as Media;
using Toybox.Communications as Comm;
using Toybox.System as Sys;

import Toybox.Lang;

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