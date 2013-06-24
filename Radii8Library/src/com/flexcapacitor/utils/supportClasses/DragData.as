
package com.flexcapacitor.utils.supportClasses {
	import flash.geom.Point;
	
	import spark.components.supportClasses.GroupBase;
	import spark.layouts.supportClasses.DropLocation;
	import spark.layouts.supportClasses.LayoutBase;
	
	/**
	 * 
	 * */
	public class DragData {
		
		
		public function DragData()
		{
			
		}
		
		public var offscreen:Boolean;
		public var isApplication:Boolean;
		public var isGroup:Boolean;
		public var isSkinnableContainer:Boolean;
		public var isVisualElementContainer:Boolean;
		public var isBasicLayout:Boolean;
		public var isTile:Boolean;
		public var isVertical:Boolean;
		public var isHorizontal:Boolean;
		public var targetGroupLayout:LayoutBase;
		public var targetGroup:GroupBase;
		public var target:Object;
		public var targetsUnderPoint:Array;
		public var topLeftEdgePoint:Point;
		public var description:ComponentDescription;
		public var dropLocation:DropLocation;
		public var dropIndex:int;
		public var layout:LayoutBase;
	}
}