import Toybox.Lang;

// Source used to create an asset
// Each `AudioResource` should represent a single provider - e.g. Soundcloud, Plex, Youtube
class AudioResource {
    // RESOURCE LOADING/SYNCING
}

function getAudioResources() as Array<File> {
    return [
        new File("http://192.168.1.222:8000/BBC/Mary_Anne_Hobbs_-_Adam_F_with_the_ICONS_Mix_m0024dwt_original.m4a", {
            :id => "id-1",
            :is_on_device => false,
            :name => "Mary_Anne_Hobbs_-_Adam_F_with_the_ICONS_Mix_m0024dwt_original"
        }),
        new File("http://192.168.1.222:8000/BBC/Radio_1_Dance_Presents_-_Anjunabeats_Above_Beyond_m001ydv7_original.m4a", {
            :id => "id-2",
            :is_on_device => true,
            :name => "Radio_1_Dance_Presents_-_Anjunabeats_Above_Beyond_m001ydv7_original"
        }),
        new File("https://getsamplefiles.com/download/m4a/sample-3.m4a", {
            :id => "id-3",
            :is_on_device => false,
            :name => "Remote Sample"
        })
    ];
}
