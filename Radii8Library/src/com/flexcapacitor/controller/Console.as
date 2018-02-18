package com.flexcapacitor.controller
{
	
	/**
	 * Base class to make it easier to show message
	 **/
	public class Console {
		
		public function Console() {
			
		}
		
		/**
		 * Traces an error message.
		 * 
		 * Getting three error messages. 
		 * One from Radii8Desktop, one from here Radiate.as, and one from DocumentContainer
		 * */
		public static function error(message:String, event:Object = null, sender:String = null, ...Arguments):void {
			Radiate.error(message, event, sender, Arguments);
		}
		
		/**
		 * Traces an warning message
		 * */
		public static function warn(message:String, sender:Object = null, ...Arguments):void {
			Radiate.warn(message, sender, Arguments);
		}
		
		/**
		 * Traces an info message
		 * */
		public static function info(message:String, sender:Object = null, ...Arguments):void {
			Radiate.info(message, sender, sender, Arguments);
		}
		
		/**
		 * Traces an debug message. We use log since we use debug as a flag
		 * */
		public static function log(message:String, sender:Object = null, ...Arguments):void {
			Radiate.debug(message, sender, Arguments);
		}
	}
}