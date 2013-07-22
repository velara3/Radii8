
package com.flexcapacitor.events {
	
	/**
	 * Container for history event items
	 * */
	public class HistoryEvent extends HistoryEventItem {
		
		public function HistoryEvent() {
			
		}
		
		/**
		 * Array of history event items
		 * */
		public var historyEventItems:Array;
		
		override public function purge():void {
			super.purge();
		}
	}
}