
package com.flexcapacitor.logging {
	import mx.core.mx_internal;
	import mx.logging.targets.LineFormattedTarget;
	
	use namespace mx_internal;
	
	/**
	 * Logging target
	 * */
	public class RadiateLogTarget extends LineFormattedTarget {
		
		
		public function RadiateLogTarget(console:Object = null) {
			super();
			
			this.console = console;
		}
		
		private var _console:Object;
		
		public var messages:String = "";
		
		public var storedMessages:String = "";
		
		public var fallBackToTraceConsole:Boolean = true;
	
		/**
		 * Store messages 
		 * */
		public var storeMessages:Boolean = false;
		
		/**
		 * Shows messages deferred until console is created
		 * */
		public var showDeferredMessages:Boolean = true;
		
		[Bindable]
		public function get console():Object {
			return _console;
		}

		public function set console(value:Object):void {
			if (_console == value) return;
			
			_console = value;
			
			if (value && showDeferredMessages && storedMessages) {
				internalLog (storedMessages);
			}
		}

		override mx_internal function internalLog(message : String) : void {
			var shortMessage:String = message + "\n";
			
			if (console) {
				console.text += shortMessage;
			}
			else {
				storedMessages += shortMessage;
				
				if (fallBackToTraceConsole) {
					trace(message);
				}
			}
			
			if (storedMessages) {
				messages += shortMessage;
			}
		}
	}
}
