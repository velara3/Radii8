
package com.flexcapacitor.tools {
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.model.IDocument;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import mx.core.EventPriority;
	import mx.core.FlexGlobals;
	import mx.core.IVisualElement;
	import mx.events.SandboxMouseEvent;
	import mx.managers.SystemManager;
	
	import spark.components.Scroller;
	import spark.core.IViewport;
	
	/**
	 * Zooms in on the stage.  
	 * 
	 * */
	public class Zoom extends EventDispatcher implements ITool {
		
		
		public function Zoom()
		{
			//radiate = Radiate.getInstance();
		}
		
		private var _icon:Class = Radii8LibraryToolAssets.Zoom;
		
		public function get icon():Class {
			return _icon;
		}
		
		public static const ZoomInCursor:Class = Radii8LibraryToolAssets.ZoomIn;
		
		public static const ZoomOutCursor:Class = Radii8LibraryToolAssets.ZoomOut;
		
		public var cursors:Array;
		
		
		/**
		 * The radiate instance.
		 * */
		public function get radiate():Radiate {
			if (_radiate==null) {
				_radiate = Radiate.getInstance();
			}
			return _radiate;
		}
		private var _radiate:Radiate;


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
		public var defaultCursorID:String;
		
		/**
		 * 
		 * */
		public var zoomInCursorID:String;
		
		/**
		 * 
		 * */
		public var zoomOutCursorID:String;
		
		/**
		 * 
		 * */
		public var isOverDocument:Boolean;
		
		/**
		 * Enable this tool. 
		 * */
		public function enable():void
		{
			
			//radiate.document.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
			
			if (radiate.selectedDocument) {
				updateDocument(radiate.selectedDocument);
			}
			
			zoomInCursorID = radiate.getMouseCursorID(this, "ZoomInCursor");
			zoomOutCursorID = radiate.getMouseCursorID(this, "ZoomOutCursor");
		}
		
		/**
		 * Disable this tool.
		 * */
		public function disable():void {
			
			radiate.removeEventListener(RadiateEvent.DOCUMENT_CHANGE, documentChangeHandler);
			
			updateDocument(null);
		}
		
		/**
		 * 
		 * */
		public function updateDocument(document:IDocument):void {
			var stage:Stage = FlexGlobals.topLevelApplication.stage;
			var sandboxRoot:DisplayObject = SystemManager(FlexGlobals.topLevelApplication.systemManager).getSandboxRoot();
			
			// remove listeners
			if (targetApplication) {
				targetApplication.removeEventListener(MouseEvent.CLICK, clickHandler, true);
				targetApplication.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
				targetApplication.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
				targetApplication.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				targetApplication.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
				targetApplication.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
				
				//targetApplication.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true);
				//stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true);
				
				// keyboard handling
				//targetApplication.removeEventListener(Event.ENTER_FRAME, enterFrameHandler, false);
				sandboxRoot.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
				sandboxRoot.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandlerSandboxRoot, false);
				sandboxRoot.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandlerSandboxRoot, false);
				sandboxRoot.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpHandler, false);
				sandboxRoot.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false);
				//sandboxRoot.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandlerSandboxRoot, false);
				//sandboxRoot.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandlerSandboxRoot, true);
			}
			
			targetApplication = document ? document.instance : null;
			
			// add listeners
			if (targetApplication) {
				targetApplication.addEventListener(MouseEvent.CLICK, clickHandler, true, EventPriority.CURSOR_MANAGEMENT, true);
				targetApplication.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, EventPriority.CURSOR_MANAGEMENT, true);
				targetApplication.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, EventPriority.CURSOR_MANAGEMENT, true);
				targetApplication.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, EventPriority.CURSOR_MANAGEMENT, true);
				targetApplication.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler, false, EventPriority.CURSOR_MANAGEMENT, true);
				targetApplication.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler, false, EventPriority.CURSOR_MANAGEMENT, true);
				
				sandboxRoot.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, EventPriority.CURSOR_MANAGEMENT, true);
				// keyboard handling
				//targetApplication.addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, EventPriority.DEFAULT, true);
				sandboxRoot.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandlerSandboxRoot, false, EventPriority.DEFAULT, true);
				sandboxRoot.addEventListener(KeyboardEvent.KEY_UP, keyUpHandlerSandboxRoot, false, EventPriority.DEFAULT, true);
				sandboxRoot.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpHandler, false, EventPriority.DEFAULT, true);
				sandboxRoot.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, EventPriority.DEFAULT, true);
				//sandboxRoot.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandlerSandboxRoot, false, 1001, true);
				//sandboxRoot.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandlerSandboxRoot, true, 1001, true);
				
				//targetApplication.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, false, EventPriority.CURSOR_MANAGEMENT, true);
				//targetApplication.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true, EventPriority.CURSOR_MANAGEMENT, true);
				
				//stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, false, EventPriority.CURSOR_MANAGEMENT, true);
				//stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true, EventPriority.CURSOR_MANAGEMENT, true);
			}
			
		}
		
		public var previousStageX:int;
		public var startingPoint:Point;
		public var localStartingPoint:Point;
		public var startingScale:Number;
		
		/**
		 * How many pixels the mouse has to move before a drag operation is started
		 * */
		public var dragStartTolerance:int = 5;
		
		/**
		 * Mouse down handler
		 * */
		protected function mouseDownHandler(event:MouseEvent):void {
			
			if (isOverDocument) {
				event.stopImmediatePropagation();
				
				// redispatch mouse down event
				dispatchEvent(event);
				
				updateMouseCursor(event.altKey || event.shiftKey);
				
				startingPoint = new Point(event.stageX, event.stageY);
				startingScale = radiate.getScale();
				localStartingPoint = DisplayObject(targetApplication).globalToLocal(startingPoint);
				localStartingPoint = DisplayObject(targetApplication).globalToLocal(startingPoint);
				//radiate.centerApplication(false);
				//radiate.centerOnPoint(localStartingPoint);
			}
		}
		
		/**
		 * Mouse up handler
		 * */
		protected function mouseUpHandler(event:Event):void {
			var altOrShift:Boolean = "altKey" in event ? Object(event).altKey || Object(event).shiftKey : false;
			
			if (isOverDocument) {
				event.stopImmediatePropagation();
				
				// redispatch mouse up event
				dispatchEvent(event);
				
				updateMouseCursor(altOrShift);
				
				if (isDragging) {
					temporaryPreventClickEvent = true;
				}
			}
			
			if (isDragging) {
				event.stopImmediatePropagation();
				event.stopPropagation(); // stop mouse click event - doesn't work
			}
			startingPoint = null;
			isDragging = false;
			//trace("mouse up: " + event.currentTarget);
			
			if (!isOverDocument) {
				resetMouse();
			}
		}
		
		protected function resetMouse():void
		{
			Mouse.cursor = MouseCursor.AUTO;
		}
		
		/**
		 * Mouse move handler
		 * */
		protected function mouseMoveHandler(event:MouseEvent):void {
			var dragToleranceMet:Boolean;
			var newScale:Number;
			var pixelDifference:int;
			var zoomOut:Boolean;
			
			
			//trace("mouse move. is app: " +event.currentTarget==targetApplication);
			if (isDragging && event.currentTarget!=targetApplication) {
				pixelDifference = event.stageX - startingPoint.x;
				
				// figure out what cursor we should show
				// if less than previous position then 
				// we are moving left. if more we are moving right
				if (event.stageX<previousStageX) {
					zoomOut = true;
				}
				
				// update last move location
				previousStageX = event.stageX;
				
				//if (pixelDifference<0) {
				//}
				
				updateMouseCursor(zoomOut);
				
				if (Math.abs(pixelDifference)<10) {
					updateZoom(startingScale);
					return;
				}
				
				newScale = startingScale + pixelDifference/scrubAmount;
				//trace("new scale: "+ newScale);
				updateZoom(newScale);
				return;
			}
			
			//var sandboxRoot:DisplayObject = SystemManager(FlexGlobals.topLevelApplication.systemManager).getSandboxRoot();
			
			if (!isDragging && isOverDocument && event.currentTarget==targetApplication) {
				event.stopImmediatePropagation();
				
				// redispatch mouse move event
				dispatchEvent(event);
				
				updateMouseCursor(event.altKey || event.shiftKey);
				
				if (startingPoint) {
					dragToleranceMet = Math.abs(startingPoint.x - event.stageX) >= dragStartTolerance;
					dragToleranceMet = !dragToleranceMet ? Math.abs(startingPoint.y - event.stageY)  >= dragStartTolerance: true;
				}
				
				if (dragToleranceMet) {
					isDragging = true;
					//radiate.centerOnPoint(startingPoint);
				}
				
			}
			
			// update last move location
			previousStageX = event.stageX;
		}
		
		public var isDragging:Boolean;
		public var temporaryPreventClickEvent:Boolean;

		/**
		 * Percent to scale on each mouse move during scrub
		 * */
		public var scrubAmount:int = 200;
		
		public function updateZoom(newScale:Number):void {
			var currentScale:Number = radiate.getScale();
			var offsetX:int;
			var offsetY:int;
			//var point:Point;
			var vPosition:int = radiate.canvasScroller.verticalScrollBar.value;
			var hPosition:int = radiate.canvasScroller.horizontalScrollBar.value;
			var scaleChange:Number;
			
			if (newScale) {
				//point = DisplayObject(targetApplication).globalToLocal(new Point(stageX, stageY));
				scaleChange = newScale - currentScale;
				offsetX = (startingPoint.x * scaleChange);
				offsetY = (startingPoint.y * scaleChange);
				
				radiate.setScale(newScale);
				radiate.setScrollPosition(offsetX+hPosition, offsetY+vPosition);
				//radiate.decreaseScale();
			}
			else {
				//point = DisplayObject(targetApplication).globalToLocal(new Point(stageX, stageY));
				scaleChange = (newScale) - currentScale;
				offsetX = (startingPoint.x * scaleChange);
				offsetY = (startingPoint.y * scaleChange);
				
				radiate.setScale(newScale);
				radiate.setScrollPosition(offsetX+hPosition, offsetY+vPosition);
				//radiate.increaseScale();
			}
		}
		
		
		/**
		 * Click handler added 
		 * */
		protected function clickHandler(event:MouseEvent):void {
			// we are intercepting this event so we can inspect the target
			// stop the event propagation
			//trace("mouse click");
			// we don't stop the propagation on touch devices so you can navigate the application
			if (temporaryPreventClickEvent) {
				temporaryPreventClickEvent = false;
				return;
			}
			
			event.stopImmediatePropagation();
				
			updateMouseCursor(event.altKey || event.shiftKey);
			
			if (targetApplication is DisplayObject) {
				var currentScale:Number = radiate.getScale();
				var offsetX:int;
				var offsetY:int;
				var point:Point;
				var canvasScroller:Scroller = radiate.canvasScroller;
				var vPosition:int = canvasScroller.verticalScrollBar.value;
				var hPosition:int = canvasScroller.horizontalScrollBar.value;
				var viewportComponent:IViewport = canvasScroller.viewport;
				var availableWidth:int = canvasScroller.width;// - vsbWidth;
				var availableHeight:int = canvasScroller.height;// - hsbHeight;
				var vsbWidth:int = canvasScroller.verticalScrollBar ? canvasScroller.verticalScrollBar.width : 11;
				var hsbHeight:int = canvasScroller.horizontalScrollBar ? canvasScroller.horizontalScrollBar.height : 11;
				//var documentVisualElement:IVisualElement = IVisualElement(selectedDocument.instance);
				var scaleChange:Number;
				var scaleAmount:Number = .2;
				
				var viewPortWidth:int = canvasScroller.width;
				var viewPortHeight:int = canvasScroller.height;
				
				point = DisplayObject(canvasScroller).globalToLocal(new Point(event.stageX, event.stageY));
				// (990/2=445) - (975/2=487)
				//            -42*-1
				//            42-11
				//            31
				var scrollerXPosition2:int = ((canvasScroller.width/2)-(viewportComponent.width/2)) * -1;
				var scrollerYPosition:int = ((canvasScroller.height/2)-(viewportComponent.height/2)) * -1;
				var scrollerXPosition3:int = ((canvasScroller.width/2)-((targetApplication.width*currentScale)/2)) * -1;
				var scrollerXPosition4:int = ((canvasScroller.width - viewportComponent.width*currentScale)/2) * -1;
				var scrollerXPosition5:int = ((canvasScroller.width - targetApplication.width*currentScale)/2) * -1;
				
				var scrollerXPosition:int = ((canvasScroller.width/2-point.y)) * -1;
				var scrollerXPosition7:int = (((canvasScroller.width/2)-point.y*currentScale)) * -1;
				var scrollerXPosition8:int = ((canvasScroller.width-point.y*currentScale)/2) * -1;
				trace(scrollerXPosition);
				// formula for scroll position should be
				//  (viewbox width / 2) --> center of viewbox
				// - (object width / 2) --> center of object
				// -------------------- 
				//   horizontal location to position object
				// 
				
				/* 
				viewport                  100
				                           /2
				                         ----
				viewCenter                 50
				
				object                    200
				                           /2
				                         ----
				objectCenter              100
				
				viewCenter                 50
				objectCenter             -100
				                         ----
				x position of object      -50
				
				x position of object      -50
				                          *-1
				                         ----
				x position of scrollbar    50
				*/
				
				
				if (event.altKey || event.shiftKey) {
					point = DisplayObject(canvasScroller).globalToLocal(new Point(event.stageX, event.stageY));
					scaleChange = (currentScale-scaleAmount) - currentScale;
					offsetX = (point.x * scaleChange);
					offsetY = (point.y * scaleChange);
					
					radiate.setScrollPosition(offsetX+hPosition, offsetY+vPosition);
					radiate.setScale(currentScale-scaleAmount);
					//radiate.decreaseScale();
				}
				else {
					point = DisplayObject(canvasScroller).globalToLocal(new Point(event.stageX, event.stageY));
					var zPoint:Point = DisplayObject(canvasScroller).globalToLocal(new Point());
					//scaleChange = (currentScale+scaleAmount) - currentScale;//same value
					offsetX = (point.x * scaleAmount);
					offsetY = (point.y * scaleAmount);
					// at scale 2.6
					// horizScrollbar - vertScrollBar
					// x 620 y 418 
					
					radiate.setScrollPosition(offsetX+hPosition, offsetY+vPosition);
					radiate.setScale(currentScale+scaleAmount);
					//radiate.setScrollPosition(scrollerXPosition, scrollerYPosition);
					//radiate.increaseScale();
				}
				
			}
		}
		
		
		/**
		 * Roll over handler 
		 * */
		protected function rollOverHandler(event:MouseEvent):void {
			isOverDocument = true;
			
			event.stopImmediatePropagation();
			
			// redispatch rollover event
			dispatchEvent(event);
			
			
			
			updateMouseCursor(event.altKey || event.shiftKey);
		}
		
		/**
		 * Roll out handler 
		 * */
		protected function rollOutHandler(event:MouseEvent):void {
			
			if (isDragging) return;
			isOverDocument = false;
			event.stopImmediatePropagation();
			
			// redispatch rollout event
			dispatchEvent(event);
			
			resetMouse();
		}
		
		/**
		 * Key down handler 
		 * */
		protected function keyDownHandler(event:KeyboardEvent):void {
			//Radiate.info("Dispatcher is: " + event.currentTarget + " in phase " + (event.eventPhase==1 ? "capture" : "bubble"));
			updateMouseCursor(event.altKey || event.shiftKey);
		}
		
		/**
		 * Key down handler 
		 * */
		protected function keyDownHandlerSandboxRoot(event:KeyboardEvent):void {
			// Radiate.info("1. Dispatcher is: " + event.currentTarget + " in phase " + (event.eventPhase==1 ? "capture" : "bubble"));
			updateMouseCursor(event.altKey || event.shiftKey);
		}
		
		/**
		 * Key up handler 
		 * */
		protected function keyUpHandlerSandboxRoot(event:KeyboardEvent):void {
			// Radiate.info("1. Dispatcher is: " + event.currentTarget + " in phase " + (event.eventPhase==1 ? "capture" : "bubble"));
			updateMouseCursor(event.altKey || event.shiftKey);
		}
		
		/**
		 * Enter frame handler to try and capture ALT key. Doesn't work. 
		 * */
		protected function enterFrameHandler(event:Event):void {
			//Radiate.info("1. Dispatcher is: " + event.currentTarget + " in phase " + (event.eventPhase==1 ? "capture" : "bubble"));
			var newEvent:MouseEvent = new MouseEvent(MouseEvent.MOUSE_MOVE, false, false);
			
			if (newEvent.altKey) {
				updateMouseCursor(newEvent.altKey);
			}
			if (newEvent.shiftKey) {
				updateMouseCursor(newEvent.altKey);
			}
		}
		
		/**
		 * Document changed update. 
		 * */
		protected function documentChangeHandler(event:RadiateEvent):void {
			updateDocument(event.selectedItem as IDocument);
			
		}
		
		/**
		 * Restores the zoom of the target application to 100%. 
		 * */
		public function setScale(value:Number):void {
			radiate.setScale(value);
		}
		
		/**
		 * Restores the zoom of the target application to 100%. 
		 * */
		public function getScale():Number {
			
			return radiate.getScale();
		}
		
		/**
		 * Restores the zoom of the target application to 100%. 
		 * */
		public function restoreDefaultScale():void {
			radiate.restoreDefaultScale();
		}
		
		/**
		 * Update mouse cursor
		 * */
		public function updateMouseCursor(zoomOut:Boolean = false):void {
			
			if (isOverDocument) {
				if (zoomOut) {
					//Radiate.info("Setting zoom out");
					Mouse.cursor = zoomOutCursorID;
				}
				else {
					//Radiate.info("Setting zoom IN");
					Mouse.cursor = zoomInCursorID;
				}
			}
		}
		
	}
}