using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Media as Media;
using Toybox.Communications as Comm;
using Toybox.System as Sys;

import Toybox.Lang;

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
