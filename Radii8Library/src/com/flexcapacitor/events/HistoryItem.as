
package com.flexcapacitor.events {
	
	/**
	 * Container for history event items
	 * */
	public class HistoryItem extends HistoryEventItem {
		
		public function HistoryItem() {
			
		}
		
		/**
		 * Array of history event items
		 * */
		public var historyEvents:Array;
		
		override public function purge():void {
			super.purge();
		}
	}
}