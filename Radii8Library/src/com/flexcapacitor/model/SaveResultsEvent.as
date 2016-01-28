
package com.flexcapacitor.model {
	import com.flexcapacitor.services.IWPServiceEvent;
	import com.flexcapacitor.services.ServiceEvent;
	
	import flash.events.Event;
	
	/**
	 * Indicates if save of document was successful
	 * */
	public class SaveResultsEvent extends ServiceEvent implements IWPServiceEvent {
		
		/**
		 * Event dispatched when the save results are returned
		 * */
		public static const SAVE_RESULTS:String = "saveResults";
		

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

		private var _text:String;

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

		
		public function SaveResultsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, successful:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.successful = successful;
		}
		
		override public function clone():Event {
			return new SaveResultsEvent(type, bubbles, cancelable, successful);
		}
	}
}