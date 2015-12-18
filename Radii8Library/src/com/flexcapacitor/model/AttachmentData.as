
package com.flexcapacitor.model {
	import flash.events.IEventDispatcher;
	
	/**
	 * Used for image attachments in WordPress
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
		
		/**
		 * Base 64 encoding for data uri
		 * */
		public var base64Encoding:String;
	}
}