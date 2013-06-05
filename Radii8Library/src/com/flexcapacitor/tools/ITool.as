
package com.flexcapacitor.tools {
	
	public interface ITool {
		
		/**
		 * Enables the selected tool. 
		 * */
		function enable():void 
		
		/**
		 * Disables the selected tool. 
		 * */
		function disable():void 
			
		/**
		 * Embedded icon
		 * */
		function get icon():Class
	}
	
}