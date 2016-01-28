
package com.flexcapacitor.model {
	import com.flexcapacitor.services.IWPServiceEvent;
	import com.flexcapacitor.services.ServiceEvent;
	
	import flash.events.Event;
	
	/**
	 * Indicates if retrieve of document was successful
	 * */
	public class LoadResultsEvent extends ServiceEvent implements IWPServiceEvent {
		
		/**
		 * Event dispatched when the document data has been retrieved
		 * */
		public static const LOAD_RESULTS:String = "retrievedResults";

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

		
		public function LoadResultsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, successful:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.successful = successful;
		}
		
		override public function clone():Event {
			return new LoadResultsEvent(type, bubbles, cancelable, successful);
		}
	}
}