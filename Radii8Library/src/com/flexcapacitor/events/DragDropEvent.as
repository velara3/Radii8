
package com.flexcapacitor.events {
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.core.DragSource;
	import mx.core.IUIComponent;
	import spark.layouts.supportClasses.DropLocation;
	import mx.events.DragEvent;
	
	
	public class DragDropEvent extends Event {
		
		public static var DRAG_START:String = "dragStart";
		public static var DRAG_END:String = "dragEnd";
		public static var DRAG_OVER:String = "dragOver";
		public static var DRAG_DROP:String = "dragDrop";
		public static var DRAG_DROP_COMPLETE:String = "dragDropComplete";
		
		public var dragInitiator:IUIComponent;
		public var dropTarget:Object;
		public var draggedItem:Object;
		public var dragSource:DragSource;
		public var dropPoint:Point;
		public var dropLocation:DropLocation;
		public var dragEvent:DragEvent;
		public var offsetPoint:Point;
		public var isSkinnableContainer:Boolean;
		public var isGroup:Boolean;
		public var isTile:Boolean;
		public var isVertical:Boolean;
		public var isHorizontal:Boolean;
		public var isBasicLayout:Boolean;
		public var isDropTargetParent:Boolean;
		public var isDropTargetOwner:Boolean;
		
		public function DragDropEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		
		override public function clone():Event {
			var event:DragDropEvent = new DragDropEvent(type, bubbles, cancelable);
			event.dragInitiator = dragInitiator;
			event.dropTarget = dropTarget;
			event.draggedItem = draggedItem;
			event.dragSource = dragSource;
			event.dropPoint = dropPoint;
			event.dropLocation = dropLocation;
			event.dragEvent = dragEvent;
			event.offsetPoint = offsetPoint;
			event.isGroup = isGroup;
			event.isTile = isTile;
			event.isVertical = isVertical;
			event.isHorizontal = isHorizontal;
			event.isBasicLayout = isBasicLayout;
			event.isSkinnableContainer = isSkinnableContainer;
			event.isDropTargetOwner = isDropTargetOwner;
			event.isDropTargetParent = isDropTargetParent;
			return event;
		}
		
	}
}