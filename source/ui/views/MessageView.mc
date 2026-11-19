using Toybox.Graphics as Graphics;
using Toybox.WatchUi as Ui;
import Toybox.Lang;

class MessageView extends Ui.View {
    private var _title as String?;
    private var _message as String;

    function initialize(title as String?, message as String?) {
        Ui.View.initialize();
        _title = title;
        _message = message == null ? "" : message;
    }

    function onLayout(dc as Graphics.Dc) as Void {
        if (_title != null && _title.length() > 0) {
            setLayout($.Rez.Layouts.TextAreaWithTitleLayout(dc));

            (findDrawableById("MessageTitle") as Ui.TextArea).setText(_title as String);
            (findDrawableById("MessageBody") as Ui.TextArea).setText(_message);
            return;
        }

        setLayout($.Rez.Layouts.TextAreaLayout(dc));
        (findDrawableById("MessageBody") as Ui.TextArea).setText(_message);
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        Ui.View.onUpdate(dc);
    }

}
