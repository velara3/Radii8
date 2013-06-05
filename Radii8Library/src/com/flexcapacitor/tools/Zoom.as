
package com.flexcapacitor.tools {
	import com.flexcapacitor.controller.Radiate;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * Zooms in on the stage.  
	 * 
	 * */
	public class Zoom implements ITool {
		
		
		public function Zoom()
		{
			
		}
		
		[Embed(source="assets/icons/tools/Zoom.png")]
		private var _icon:Class;
		
		public function get icon():Class {
			return _icon;
		}
		
		/**
		 * Enable this tool. 
		 * */
		public function enable():void
		{
			radiate = Radiate.getInstance();
			
			radiate.document.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
		}
		
		/**
		 * Disable this tool.
		 * */
		public function disable():void
		{
			radiate.document.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
		}
		
		/**
		 * The radiate instance.
		 * */
		public var radiate:Radiate;

		/**
		 * The document / application
		 * */
		public var targetApplication:Object;
		
		/**
		 * The background
		 * */
		public var canvasBackground:Object;
		
		/**
		 * The background parent
		 * */
		public var canvasBackgroundParent:Object;
		
		/**
		 * 
		 * */
		protected function mouseDownHandler(event:MouseEvent):void {
			Radiate.log.info("ZOOM MOUSE DOWN");
			var point:Point = new Point(event.stageX, event.stageY);
			/*var targetsUnderPoint:Array = FlexGlobals.topLevelApplication.getObjectsUnderPoint(point);
			var componentTree:ComponentDescription;
			var description:ComponentDescription;
			var target:Object = event.target;
			var items:Array = [];
			var length:int;
			
			// test url for remote image: 
			// http://www.google.com/intl/en_com/images/srpr/logo3w.png
			// file:///Users/monkeypunch/Documents/Adobe%20Flash%20Builder%2045/Radii8/src/assets/images/eye.png
			
			// clicked outside of this container. is there a way to prevent hearing
			// events from everywhere? stage sandboxroot?
			if (!targetApplication || !Object(targetApplication).contains(target)) {
				//trace("does not contain");
				return;
			}
			
			// clicked on background area
			if (target==canvasBackground || target==canvasBackgroundParent) {
				radiate.setTarget(targetApplication, true);
				return;
			}
			
			
			// check if target is loader
			if (target is Loader) {
				//Error: Request for resource at http://www.google.com/intl/en_com/images/srpr/logo3w.png by requestor from http://www.radii8.com/debug-build/RadiateExample.swf is denied due to lack of policy file permissions.
				
				//*** Security Sandbox Violation ***
				//	Connection to http://www.google.com/intl/en_com/images/srpr/logo3w.png halted - not permitted from http://www.radii8.com/debug-build/RadiateExample.swf
				targetsUnderPoint.push(target);
			}
			
			length = targetsUnderPoint.length;
			targetsUnderPoint = targetsUnderPoint.reverse();
			
			// loop through items under point until we find one on the *component* tree
			componentTree = Radiate.getComponentDisplayList();
			
			componentTreeLoop:
			for (var i:int;i<length;i++) {
				target = targetsUnderPoint[i];
				
				if (!targetApplication.contains(DisplayObject(target))) {
					continue;
				}
				
				description = DisplayObjectUtils.getComponentFromDisplayObject(DisplayObject(target), componentTree);
				
				if (description) {
					target = description.instance;
					break;
				}
			}
			
			
			if (target) {
				// select target on mouse up or drag drop whichever comes first
				target.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
				
				if (target!=targetApplication) {
					
				}
			}
			*/
		}
		
		
		protected function mouseUpHandler(event:MouseEvent):void {
			trace("ZOOM MOUSE UP");
			/*var target:Object = event.currentTarget;
			
			if (target is List) {
				target.dragEnabled = true; // restore drag and drop if it was enabled
			}
			
			target.visible = true;
			
			// clean up
			if (target.hasEventListener(MouseEvent.MOUSE_UP)) {
				trace("1 has event listener");
			}
			target.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			if (target.hasEventListener(MouseEvent.MOUSE_UP)) {
				trace("2 has event listener");
			}
			else {
				trace("listener removed");
			}
			
			// select target
			if (radiate.target!=target) {
				radiate.setTarget(target, true);
			}*/
			
		}
		
	}
}