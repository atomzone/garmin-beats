import Toybox.Lang;
using Toybox.WatchUi;

class TapDelegate extends WatchUi.BehaviorDelegate {
	
	private var d_callback;
	
	function initialize(callback) {
		BehaviorDelegate.initialize();
		
		d_callback = callback;
	}
	
	function onSelect() as Boolean {
		if (d_callback) {
			d_callback.invoke();
			return true;
		}

		return false;
	}
}

class DonateDelegate extends TapDelegate {

	function initialize() {
		TapDelegate.initialize(method(:openLink));
		openLink();
	}

	function openLink() {
		var url = "https://www.paypal.com/donate";
		var params = { "hosted_button_id" => "HBUU64LT3QWA4", };
		Communications.openWebPage(url, params, null);
	}
}