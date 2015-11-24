
package com.flexcapacitor.events {
	import com.flexcapacitor.utils.ArrayUtils;
	
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
		
		private var _styleAndProperties:Array;

		/**
		 * Properties and styles from the history event items
		 * */
		public function get styleAndProperties():Array {
			var numOfItems:int = historyEventItems ? historyEventItems.length : 0;
			var historyEventItem:HistoryEventItem;
			var array:Array = [];
			
			for (var i:int = 0; i < numOfItems; i++)  {
				historyEventItem = historyEventItems[i];
				array = ArrayUtils.add(array, historyEventItem.properties, historyEventItem.styles);
				
			}
			
			return array;
		}

		/**
		 * @private
		 */
		public function set styleAndProperties(value:Array):void {
			_styleAndProperties = value;
		}

		
		override public function purge():void {
			super.purge();
		}
	}
}