import Toybox.Lang;

class AppStores {

    public static var playlists as IndexedStore
        = new IndexedStore(IndexedStore.PLAYLIST);

    public static var tracks as IndexedStore
        = new IndexedStore(IndexedStore.TRACK);

    public static var media as IndexedStore
        = new IndexedStore(IndexedStore.MEDIA);

    public static var images as IndexedStore
        = new IndexedStore(IndexedStore.IMAGE);

    // desired playlist state while a sync is in flight
    public static var playlistManifests as IndexedStore
        = new IndexedStore(IndexedStore.PLAYLIST_MANIFEST);

}