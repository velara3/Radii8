


package com.flexcapacitor.views {
	
	public interface Inspector {
	
		/**
		 * Called when the Element Inspector is closed
		 * Used to clean up any references
		 * */
		function close():void;
		
		/**
		 * This property is set when the target is changed
		 * */
		function set target(value:*):void;
	}
}