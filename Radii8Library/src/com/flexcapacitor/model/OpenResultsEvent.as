
package com.flexcapacitor.model {
	import com.flexcapacitor.services.IWPServiceEvent;
	import com.flexcapacitor.services.ServiceEvent;
	
	import flash.events.Event;
	
	/**
	 * Indicates if open of document was successful
	 * */
	public class OpenResultsEvent extends ServiceEvent implements IWPServiceEvent {

		private var _call:String;

		/**
		 * 
		 * */
		public function get call():String {
			return _call;
		}

		public function set call(value:String):void {
			_call = value;
		}

		private var _message:String;

		/**
		 * 
		 * */
		public function get message():String {
			return _message;
		}

		public function set message(value:String):void {
			_message = value;
		}

		
		public function OpenResultsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, successful:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.successful = successful;
		}
		
		/**
		 * Indicates if open was successful
		 * */
		public var successful:Boolean;
		
		override public function clone():Event {
			return new OpenResultsEvent(type, bubbles, cancelable, successful);
		}
	}
}