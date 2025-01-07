# Pump it Up!
## You got to pump it up

### What?
Application for Audio ready garmin based watches.
To allow the syncing of Audio based media from local (provide examples) assets

### Audio Sources
To be defined

### Next
- define the file model (attributes)
- define the application workflow
    - track Browsing 
    - playlist creation
    - Application settings
- define application name
- demonstration
- howto add meta data for files read from a filesystem
- what other meta data (e.g. CUE points)
- logger that is visiable in the App
- create a cUrl type interface for templating HTTP requests for audio files?
- link to an external API (Watch has many size limits and any API's prob needs a middleman)
- what application feature do DJ's/Mixers/playlist builders
- can playlist be linked to GPS env?
- can playlist be linked to BPM?
- remote template creation (cUrl + mapping recipes)
- code and compiler optimisations (+prettier-extension-monkeyc)
- Log barrel [https://github.com/garmin/connectiq-apps/tree/master/barrels/LogMonkey]


## Scratch

currently we have 
- Entity `File` - Represents the SYNC model      (the structure that creates an audiotype download)
- `FileHandler` - Manage and utilities for a collection of `File`
- Entity `AudioFile` - Represent the Audio file on the filesystem
- `Playlist` - A collection of `AudioFile` and playlist attributes. Used within `Media.ContentDelegate`
- `Storage` - Namespaced key=>value CRUD using system storage
    - [SYNC] list of `File.toStorage()`
    - [PLAYLIST] The last `Playlist` played by the media player (not implemented)
    - [TRACKS] Collection of tracks (not implemented)
        - Currently this is read from file system, future view is a combination OR 
        - *** LETS NOT DUPLICATE ANYTHING - use metadata and extend with filesystem


FILESYSTEM + API = SYNCLIST

SYNC MENU 
[x] menu item checked will be queued for download to device
[x] menu item UNchecked will be (queued?) for removal from storage
[done] Store sync information to filesystem

`onStartSync` - Called when the system starts a sync of the app.
Here we load the SYNC list from storage
READ SYNC
if Delete -> remove from filesystem
if SYNC -> Convert to `<UNKNOWN>` 
REMOVE from queue SYNC

-

class SyncTask {

}

class Sync {
    var tasks as SyncTask;
}

class File {
    var href as String;
    var id as String;
    var is_on_device as Boolean;
    var name as String;

    function initialize(href as String, options as Dictionary) {
        self.href = href;
        self.id = options[:id];
        self.is_on_device = options[:is_on_device];
        self.name = options[:name];
