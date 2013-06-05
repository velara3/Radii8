
package com.flexcapacitor.events {
	import com.flexcapacitor.tools.ITool;
	
	import flash.events.Event;
	
	import mx.states.AddItems;
	
	/**
	 * Handles Radiate events. 
	 * Need to refactor. 
	 * */
	public class RadiateEvent extends Event {
		
		/**
		 * Dispatched when the document is changed
		 * */
		public static const DOCUMENT_CHANGE:String = "documentChange";
		
		/**
		 * Dispatched when the canvas is changed
		 * */
		public static const CANVAS_CHANGE:String = "canvasChange";
		
		/**
		 * Dispatched when the target is changed
		 * */
		public static const TARGET_CHANGE:String = "targetChange";
		
		/**
		 * Dispatched when a preview is requested
		 * */
		public static const REQUEST_PREVIEW:String = "requestPreview";
		
		/**
		 * Dispatched when a color is selected
		 * */
		public static const COLOR_SELECTED:String = "colorSelected";
		
		/**
		 * Dispatched when a color is previewed before color selected event.
		 * */
		public static const COLOR_PREVIEW:String = "colorPreview";
		
		/**
		 * Dispatched when the generated code is updated
		 * */
		public static const CODE_UPDATED:String = "codeUpdated";
		
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
		public static const HISTORY_CHANGE:String = "historyChange";
		
		/**
		 * Dispatched when the tool is changed.
		 * */
		public static const TOOL_CHANGE:String = "toolChange";
		
		/**
		 * Dispatched when the tools list is updated.
		 * */
		public static const TOOLS_UPDATED:String = "toolsUpdated";
		
		
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
		public var tool:ITool;
		public var previewType:String;
		public var color:uint;
		public var invalid:Boolean;
		public var isRollOver:Boolean;
		
		/**
		 * Constructor.
		 * */
		public function RadiateEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, 
									 target:Object=null, changes:Array=null, properties:Array=null, 
									 value:*=null, multipleSelection:Boolean = false, tool:ITool = null) {
			super(type, bubbles, cancelable);
			
			this.selectedItem = target;
			this.properties = properties;
			this.changes = changes;
			this.value = value;
			this.multipleSelection = multipleSelection;
			this.tool = tool;
		}
		
		override public function clone():Event {
			throw new Error("do this");
			return new RadiateEvent(type, bubbles, cancelable, selectedItem, changes, properties, value, multipleSelection, tool);
		}
		
		
		
	}
}