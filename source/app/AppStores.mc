import Toybox.Lang;

class AppStores {

    public static var playlists as IndexedStore
        = new IndexedStore(IndexedStore.PLAYLIST);

    public static var tracks as IndexedStore
        = new IndexedStore(IndexedStore.TRACK);

    public static var media as IndexedStore
        = new IndexedStore(IndexedStore.MEDIA);

}