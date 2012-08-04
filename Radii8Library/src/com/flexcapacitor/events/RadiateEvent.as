
package com.flexcapacitor.events {
	import flash.events.Event;
	
	import mx.states.AddItems;
	
	public class RadiateEvent extends Event {
		
		public function RadiateEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, 
									 target:Object=null, changes:Array=null, properties:Array=null, value:*=null, multipleSelection:Boolean = false) {
			super(type, bubbles, cancelable);
			
			this.selectedItem = target;
			this.properties = properties;
			this.changes = changes;
			this.value = value;
			this.multipleSelection = multipleSelection;
		}
		
		/**
		 * Dispatched when the document is changed
		 * */
		public static const DOCUMENT_CHANGE:String = "documentChange";
		
		/**
		 * Dispatched when the target is changed
		 * */
		public static const TARGET_CHANGE:String = "targetChange";
		
		/**
		 * Dispatched when an item (usually a display object) is added
		 * */
		public static const ADD_ITEM:String = "addItem";
		
		/**
		 * Dispatched when an item (usually a display object) is moved
		 * */
		public static const MOVE_ITEM:String = "moveItem";
		
		/**
		 * Dispatched when an item (usually a display object) is removed
		 * */
		public static const REMOVE_ITEM:String = "removeItem";
		
		/**
		 * Dispatched when a property on the target is changed
		 * */
		public static const PROPERTY_CHANGE:String = "propertyChange";
		
		/**
		 * Dispatched when a property edit is requested
		 * */
		public static const PROPERTY_EDIT:String = "propertyEdit";
		
		/**
		 * Dispatched when at the beginning of the undo history stack
		 * */
		public static const BEGINNING_OF_UNDO_HISTORY:String = "beginningOfUndoHistory";
		
		/**
		 * Dispatched when at the end of the undo history stack
		 * */
		public static const END_OF_UNDO_HISTORY:String = "endOfUndoHistory";
		
		/**
		 * Dispatched when history is changed.
		 * */
		public static var HISTORY_CHANGE:String = "historyChange";
		
		public var selectedItem:Object;
		public var properties:Array;
		public var changes:Array;
		public var value:*;
		public var multipleSelection:Boolean;
		public var addItemsInstance:AddItems;
		public var moveItemsInstance:AddItems;
		public var newIndex:int;
		public var oldIndex:int;
		public var historyEvent:HistoryEvent;
		public var targets:Array;
		
		override public function clone():Event {
			throw new Error("do this");
			return new RadiateEvent(type, bubbles, cancelable, selectedItem, changes, properties, value, multipleSelection);
		}
		
		
		
	}
}