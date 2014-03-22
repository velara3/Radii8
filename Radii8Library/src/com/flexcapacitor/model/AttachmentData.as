
package com.flexcapacitor.model {
	import flash.events.IEventDispatcher;
	
	/**
	 * 
	 * */
	public class AttachmentData extends DocumentData {
		
		/**
		 * Constructor
		 * */
		public function AttachmentData(target:IEventDispatcher=null) {
			super(target);
		}
		
		/**
		 * Mime type
		 * */
		public var mimeType:String;
	}
}