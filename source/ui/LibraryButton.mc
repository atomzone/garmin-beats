using Toybox.Media as Media;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Graphics;

import Toybox.Lang;

class LibraryButton extends Media.CustomButton {

    private var _image as Ui.BitmapResource;
    private var _text as String;

    function initialize() {
        CustomButton.initialize();

        _image = Ui.loadResource($.Rez.Drawables.LibraryIcon) as Ui.BitmapResource;
        _text = Ui.loadResource($.Rez.Strings.LibraryButton) as String;
    }

    // this is called in a loop. maybe exploit for an animate!
    function getImage(
        image as Media.ButtonImage,
        highlighted as Boolean
    ) as Ui.BitmapResource or Graphics.BitmapReference or Null {
        $.am().logger().debug("getImage for library", {
            "image" => image,
            "highlighted" => highlighted
        });

        return _image;
    }

    function getText(state as Media.ButtonState) as String? {
        return _text;
    }

    function getState() as Media.ButtonState {
        return Media.BUTTON_STATE_DEFAULT;
    }
}