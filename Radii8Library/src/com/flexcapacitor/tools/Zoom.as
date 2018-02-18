
package com.flexcapacitor.tools {
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.controller.RadiateUtilities;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.managers.ScaleManager;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import mx.core.EventPriority;
	import mx.core.FlexGlobals;
	import mx.core.mx_internal;
	import mx.events.SandboxMouseEvent;
	import mx.managers.SystemManager;
	
	import spark.components.Button;
	import spark.components.Scroller;
	import spark.components.supportClasses.GroupBase;
	import spark.core.IViewport;
	import spark.effects.Animate;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	
	use namespace mx_internal;
	
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
		
		/**
		 *  The name of the viewport's horizontal scroll position property
		 */
		private static const HORIZONTAL_SCROLL_POSITION:String = "horizontalScrollPosition";
		
		/**
		 *  The name of the viewport's vertical scroll position property
		 */
		private static const VERTICAL_SCROLL_POSITION:String = "verticalScrollPosition";
		
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
		 * The canvas scroller
		 * */
		public var canvasScroller:Scroller;

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
		 * Location on stage that contains the start mouse down location
		 * */
		public var startingStagePoint:Point;
		
		/**
		 * Location on document that contains the starting mouse location relative to target application
		 * */
		public var startingApplicationPoint:Point;
		
		public var previousStageX:int;
		public var localPositionPoint:Point;
		public var startingScale:Number;
		
		public var isDragging:Boolean;
		public var temporaryPreventClickEvent:Boolean;
		
		/**
		 * Percent to scale on each mouse move during scrub
		 * */
		public var scrubAmount:int = 200;
		
		/**
		 * How many pixels the mouse has to move before a drag operation is started
		 * */
		public var dragStartTolerance:int = 5;

		public var scaleByAmount:Number = .2;
		
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
			
			canvasScroller = radiate.canvasScroller;
			
			radiate.addEventListener(RadiateEvent.DOCUMENT_CHANGE, documentChangeHandler, false, 0, true);
		}
		
		/**
		 * Disable this tool.
		 * */
		public function disable():void {
			
			radiate.removeEventListener(RadiateEvent.DOCUMENT_CHANGE, documentChangeHandler);
			
			updateDocument(null);
			
			Mouse.cursor = MouseCursor.AUTO;
			
			canvasScroller = null;
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
			
			canvasScroller = radiate.canvasScroller;
		}
		
		/**
		 * Mouse down handler
		 * */
		protected function mouseDownHandler(event:MouseEvent):void {
			
			if (isOverDocument) {
				event.stopImmediatePropagation();
				
				// redispatch mouse down event
				dispatchEvent(event);
				
				updateMouseCursor(event.altKey || event.shiftKey);
				
				startingStagePoint = new Point(event.stageX, event.stageY);
				startingApplicationPoint = DisplayObjectUtils.getDisplayObjectPosition(targetApplication as DisplayObject, event, true);
				startingScale = ScaleManager.getScale();
				
				localPositionPoint = DisplayObjectUtils.getDisplayObjectPosition(targetApplication as DisplayObject, event, true);;
				//localPositionPoint.x /= startingScale;
				//localPositionPoint.y /= startingScale;
				//trace("starting1: " + startingApplicationPoint);
				//trace("starting2: " + localPositionPoint);
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
			
			startingStagePoint = null;
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
				pixelDifference = event.stageX - startingStagePoint.x;
				
				// update last move location
				previousStageX = event.stageX;
				
				newScale = startingScale + pixelDifference/scrubAmount;
				
				if (newScale<startingScale) {
					zoomOut = true;
				}
				else {
					zoomOut = false;
				}
				
				updateMouseCursor(zoomOut);
				
				if (Math.abs(pixelDifference)<10) {
					updateZoom(startingScale, event);
					return;
				}
				
				//trace("new scale: "+ newScale);
				updateZoom(newScale, event);
				return;
			}
			
			//var sandboxRoot:DisplayObject = SystemManager(FlexGlobals.topLevelApplication.systemManager).getSandboxRoot();
			
			if (!isDragging && isOverDocument && event.currentTarget==targetApplication) {
				event.stopImmediatePropagation();
				
				// redispatch mouse move event
				dispatchEvent(event);
				
				updateMouseCursor(event.altKey || event.shiftKey);
				
				if (startingStagePoint) {
					dragToleranceMet = Math.abs(startingStagePoint.x - event.stageX) >= dragStartTolerance;
					dragToleranceMet = !dragToleranceMet ? Math.abs(startingStagePoint.y - event.stageY)  >= dragStartTolerance: true;
				}
				
				if (dragToleranceMet) {
					isDragging = true;
					//radiate.centerOnPoint(startingPoint);
				}
				
			}
			
			// update last move location
			previousStageX = event.stageX;
		}
		
		public function updateZoom(newScale:Number, event:MouseEvent):void {
			var currentScale:Number = ScaleManager.getScale();
			var newPoint:Point;
			
			ScaleManager.setScale(newScale);
			
			newPoint = new Point();
			newPoint.x = localPositionPoint.x * newScale;
			newPoint.y = localPositionPoint.y * newScale;
			//trace("sc: " + newScale + " local=" + newPoint);
			
			if (newPoint!=null) {
				centerViewOnPoint(radiate.canvasScroller, newPoint);
			}
		}
		
		
		/**
		 * Click handler added 
		 * */
		protected function clickHandlerold(event:MouseEvent):void {
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
				var currentScale:Number = ScaleManager.getScale();
				var offsetX:int;
				var offsetY:int;
				var point:Point;
				var localMousePoint:Point;
				var pointRectangle:Rectangle;
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
				//trace(scrollerXPosition);
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
				
				// zoom out
				if (event.altKey || event.shiftKey) {
					point = DisplayObject(canvasScroller).globalToLocal(new Point(event.stageX, event.stageY));
					scaleChange = (currentScale-scaleAmount) - currentScale;
					offsetX = (point.x * scaleChange);
					offsetY = (point.y * scaleChange);
					
					RadiateUtilities.setScrollPosition(offsetX+hPosition, offsetY+vPosition);
					ScaleManager.setScale(currentScale-scaleAmount);
					//radiate.decreaseScale();
				}
				else {
					// zoom in
					point = DisplayObject(canvasScroller).globalToLocal(new Point(event.stageX, event.stageY));
					var zPoint:Point = DisplayObject(canvasScroller).globalToLocal(new Point());
					//scaleChange = (currentScale+scaleAmount) - currentScale;//same value
					offsetX = (point.x * scaleAmount);
					offsetY = (point.y * scaleAmount);
					// at scale 2.6
					// horizScrollbar - vertScrollBar
					// x 620 y 418 
					localMousePoint = DisplayObjectUtils.getDisplayObjectPosition(targetApplication as DisplayObject, event);
					var localDistancePoint:Point = DisplayObjectUtils.getDistanceBetweenDisplayObjects(canvasScroller, targetApplication);
					var localDistancePoint2:Point = DisplayObjectUtils.getDisplayObjectPosition(targetApplication as DisplayObject, event);
					pointRectangle = new Rectangle(localMousePoint.x, localMousePoint.y, 10, 10);
					
					ScaleManager.setScale(currentScale+scaleAmount);
					
					point = getScrollPositionDeltaToPoint(radiate.canvasScroller, localDistancePoint2);
					
					if (point!=null) {
						//radiate.setScrollPosition(offsetX+hPosition, offsetY+vPosition);
						//radiate.setScrollPosition(point.x + hPosition, point.y + vPosition);
						centerViewOnPoint(radiate.canvasScroller, point);
					}
					//radiate.setScrollPosition(scrollerXPosition, scrollerYPosition);
					//radiate.increaseScale();
				}
				
			}
		}
		
		/**
		 *  Animation to scrollbars clicked area into view
		 */
		public var scrollBarAnimation:Animate;
		public var scrollBarAnimationDuration:int = 250;
		public var scrollBarAnimationStartDelay:int = 0;
		
		public var scaleAnimation:Animate;
		public var scaleAnimationDuration:int = 250;
		public var scaleAnimationStartDelay:int = 0;
		
		/**
		 * Click handler added 
		 * */
		protected function clickHandler(event:MouseEvent):void {
			var currentScale:Number;
			var newScale:Number;
			var point:Point;
			var localApplicationPoint:Point;
			var localScrollerPoint:Point;
			var scrollerDistancePoint:Point;
			var currentScrollPoint:Point;
			var newScrollPoint:Point;
			var currentScrollRect:Rectangle;
			var newScrollRect:Rectangle;
			var newPoint:Point;
			
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
				currentScale = ScaleManager.getScale();
				currentScrollRect = getScrollRect(canvasScroller.viewport as GroupBase);
				currentScrollPoint = getScrollPoint(canvasScroller.viewport as GroupBase);
				
				// zoom out
				if (event.shiftKey) {
					if (currentScale<=1) {
						newScale = currentScale-currentScale*scaleByAmount;
					}
					else {
						newScale = currentScale-scaleByAmount;
					}
				}
				else if (event.altKey) {
					// center on point
					localScrollerPoint = DisplayObjectUtils.getDisplayObjectPosition(canvasScroller.viewport as DisplayObject, event, true);
					newPoint = centerViewOnPoint(canvasScroller, localScrollerPoint);
					animateScrollPointIntoView(newPoint, currentScrollPoint);
					return;
				}
				else {
					if (currentScale<=1) {
						newScale = currentScale+currentScale*scaleByAmount;
					}
					else {
						newScale = currentScale+scaleByAmount;
					}
				}
				
				//PerformanceMeter.mark("Setting scale", true);
				ScaleManager.setScale(newScale);
				canvasScroller.validateNow();
				//PerformanceMeter.mark("Setting scale");
				
				localScrollerPoint = DisplayObjectUtils.getDisplayObjectPosition(canvasScroller.viewport as DisplayObject, event, true);
				scrollerDistancePoint = DisplayObjectUtils.getDistanceBetweenDisplayObjects(canvasScroller.viewport, targetApplication);
				localScrollerPoint.x += scrollerDistancePoint.x/2;
				localScrollerPoint.y += scrollerDistancePoint.y/2;
				newPoint = centerViewOnPoint(canvasScroller, localScrollerPoint, false);
				
				//addButton(canvasScroller.viewport as Group, localScrollerPoint.x, localScrollerPoint.y, "3");
				
				//radiate.setScale(currentScale, false);
				var maxPoint:Point;
				
				if (getCanScroll()) {
					maxPoint = getMaxScrollPoint(canvasScroller);
					currentScrollPoint.x = Math.min(maxPoint.x, currentScrollPoint.x);
					currentScrollPoint.y = Math.min(maxPoint.y, currentScrollPoint.y);
					
					animateScrollPointIntoView(newPoint, currentScrollPoint);
					animateScalePointIntoView(new Point(newScale, newScale), new Point(currentScale, currentScale));
					
					newScrollPoint = getScrollPoint(canvasScroller.viewport as GroupBase);
					newScrollRect = getScrollRect(canvasScroller.viewport as GroupBase);
				}
				else {
					//trace("can't scroll");
				}
			}
		}
		
		public function animateScrollPointIntoView(newPoint:Point, oldPoint:Point = null):void {
			var scrollMotionPaths:Vector.<MotionPath>;
			var scrollHorizontalPath:SimpleMotionPath;
			var scrollVerticalPath:SimpleMotionPath;
			
			scrollBarAnimation = new Animate();
			//scrollBarAnimation.addEventListener(EffectEvent.EFFECT_END, hideScrollBarAnimation_effectEndHandler);
			scrollBarAnimation.duration = scrollBarAnimationDuration;
			scrollBarAnimation.startDelay = scrollBarAnimationStartDelay;
			
			if (oldPoint) {
				scrollHorizontalPath = new SimpleMotionPath(HORIZONTAL_SCROLL_POSITION, oldPoint.x, newPoint.x);
				scrollVerticalPath = new SimpleMotionPath(VERTICAL_SCROLL_POSITION, oldPoint.y, newPoint.y);
			}
			else {
				scrollHorizontalPath = new SimpleMotionPath(HORIZONTAL_SCROLL_POSITION, null, newPoint.x);
				scrollVerticalPath = new SimpleMotionPath(VERTICAL_SCROLL_POSITION, null, newPoint.y);
			}
			
			scrollMotionPaths = Vector.<MotionPath>([scrollHorizontalPath, scrollVerticalPath]);
			scrollBarAnimation.motionPaths = scrollMotionPaths;
			scrollBarAnimation.play([canvasScroller.viewport]);
		}
		
		public function animateScalePointIntoView(newScale:Point, oldScale:Point = null):void {
			var scaleMotionPaths:Vector.<MotionPath>;
			var scaleXPath:SimpleMotionPath;
			var scaleYPath:SimpleMotionPath;
			
			scaleAnimation = new Animate();
			//scrollBarAnimation.addEventListener(EffectEvent.EFFECT_END, hideScrollBarAnimation_effectEndHandler);
			scaleAnimation.duration = scrollBarAnimationDuration;
			scaleAnimation.startDelay = scrollBarAnimationStartDelay;
			
			if (newScale) {
				scaleXPath = new SimpleMotionPath("scaleX", oldScale.x, newScale.x);
				scaleYPath = new SimpleMotionPath("scaleY", oldScale.y, newScale.y);
			}
			else {
				scaleXPath = new SimpleMotionPath("scaleX", null, newScale.x);
				scaleYPath = new SimpleMotionPath("scaleY", null, newScale.y);
			}
			
			scaleMotionPaths = Vector.<MotionPath>([scaleXPath, scaleYPath]);
			scaleAnimation.motionPaths = scaleMotionPaths;
			scaleAnimation.play([targetApplication]);
		}
		
		public function getCanScrollVertically():Boolean {
			if (canvasScroller) {
				return canvasScroller.scrollerLayout.canScrollVertically;
			}
			
			return false;
		}
		
		public function getCanScrollHorizontally():Boolean {
			if (canvasScroller) {
				return canvasScroller.scrollerLayout.canScrollHorizontally;
			}
			
			return false;
		}
		
		public function getCanScroll():Boolean {
			return getCanScrollHorizontally() || getCanScrollVertically();
		}
		
		public function addButton(container:Object, x:int, y:int, label:String):void {
			
			var button:Button = new Button();
			button.width = 10;
			button.height = 10;
			button.x = x;
			button.y = y;
			button.label = label;
			container.addElement(button);
			
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
			ScaleManager.setScale(value);
		}
		
		/**
		 * Restores the zoom of the target application to 100%. 
		 * */
		public function getScale():Number {
			
			return ScaleManager.getScale();
		}
		
		/**
		 * Restores the zoom of the target application to 100%. 
		 * */
		public function restoreDefaultScale():void {
			ScaleManager.restoreDefaultScale();
		}
		
		/**
		 * Update mouse cursor
		 * */
		public function updateMouseCursor(zoomOut:Boolean = false):void {
			
			if (isOverDocument) {
				if (zoomOut) {
					Mouse.cursor = zoomOutCursorID;
				}
				else {
					Mouse.cursor = zoomInCursorID;
				}
			}
		}
		
		/**
		 * 
		 */ 
		protected function getScrollPositionDeltaToPoint(scroller:Scroller, point:Point, center:Boolean = true):Point {
			
			if (!point)
				return null;
			
			var target:GroupBase = scroller.viewport as GroupBase;
			var scrollRectangle:Rectangle = getScrollRect(target);
			
			if (!scrollRectangle || !target.clipAndEnableScrolling)
				return null;
			
			var dx:Number = 0;
			var dy:Number = 0;
			
			var dxl:Number;
			var dyt:Number;
			var deltaHorizontalCenter:Number;
			var deltaVerticalCenter:Number;
			var maxVerticalScrollPosition:int;
			var maxHorizontalScrollPosition:int;
			
			
			dxl = point.x - scrollRectangle.left;
			dyt = point.y - scrollRectangle.top;
			
			deltaHorizontalCenter = point.x - scrollRectangle.left - (scrollRectangle.width/2);
			deltaVerticalCenter = point.y - scrollRectangle.top - (scrollRectangle.height/2);
			
			maxHorizontalScrollPosition = scroller.horizontalScrollBar.maximum;
			
			maxVerticalScrollPosition = scroller.verticalScrollBar.maximum;
			
			if (center) {
				dx = deltaHorizontalCenter;
				
				if (scrollRectangle.left + deltaHorizontalCenter<0) {
					dx = -scrollRectangle.left;
				}
				else if (scrollRectangle.left + deltaHorizontalCenter>maxHorizontalScrollPosition) {
					dx = maxHorizontalScrollPosition-scrollRectangle.left;
				}
				
				dy = deltaVerticalCenter;
				
				if (scrollRectangle.top + deltaVerticalCenter<0) {
					dy = -scrollRectangle.top;
				}
				else if (scrollRectangle.top + deltaVerticalCenter>maxVerticalScrollPosition) {
					dy = maxVerticalScrollPosition - scrollRectangle.top;
				}
			}
			else {
				// minimize the scroll
				dx = dxl;
				dy = dyt;
			}
			
			dx = Math.floor(dx);
			dy = Math.floor(dy);
			
			return new Point(dx, dy);
		}

		
		public function centerViewOnPoint(scroller:Scroller, point:Point, animate:Boolean = false):Point {
			
			if (!point) {
				return null;
			}
			
			var target:GroupBase = scroller.viewport as GroupBase;
			var scrollRectangle:Rectangle = getScrollRect(target);
			
			if (!scrollRectangle || !target.clipAndEnableScrolling) {
				return null;
			}
			
			var newX:Number = 0;
			var newY:Number = 0;
			
			var left:Number;
			var top:Number;
			var horizontalCenter:Number;
			var verticalCenter:Number;
			var maxVerticalScrollPosition:int;
			var maxHorizontalScrollPosition:int;
			var currentHorizontalPosition:int;
			var currentVerticalPosition:int;
			
			left = point.x;
			top = point.y;
			
			horizontalCenter = left - (scrollRectangle.width/2);
			verticalCenter = top - (scrollRectangle.height/2);
			
			currentHorizontalPosition = scroller.viewport.horizontalScrollPosition;
			currentVerticalPosition = scroller.viewport.verticalScrollPosition;
			
			maxHorizontalScrollPosition = scroller.horizontalScrollBar.maximum;
			maxVerticalScrollPosition = scroller.verticalScrollBar.maximum;
			
			newX = horizontalCenter;
			
			if (horizontalCenter<0) {
				newX = 0;
			}
			else if (horizontalCenter > maxHorizontalScrollPosition) {
				newX = maxHorizontalScrollPosition;
			}
			
			newY = verticalCenter;
			
			if (verticalCenter<0) {
				newY = 0;
			}
			else if (verticalCenter > maxVerticalScrollPosition) {
				newY = maxVerticalScrollPosition;
			}
			
			newX = Math.floor(newX);
			newY = Math.floor(newY);
			
			if (!animate) {
				scroller.viewport.horizontalScrollPosition = newX;
				scroller.viewport.verticalScrollPosition = newY;
			}
			else {
				animateScrollPointIntoView(new Point(newX, newY), new Point(currentHorizontalPosition, currentVerticalPosition));
			}
			
			return new Point(newX, newY);
			
		}
		
		/**
		 *  @private 
		 *  This takes an element rather than an index so it can be used for
		 *  DataGrid which has rows and columns.
		 * 
		 *  For the offset properties, a value of NaN means don't offset from that edge. A value
		 *  of 0 means to put the element flush against that edge.
		 * 
		 *  @param elementR The bounds of the element to position
		 *  @param elementLocalBounds The bounds inside of the element to position
		 *  @param entireElementVisible If true, position the entire element in the viewable area
		 *  @param topOffset Number of pixels to position the element below the top edge.
		 *  @param bottomOffset Number of pixels to position the element above the bottom edge.
		 *  @param leftOffset Number of pixels to position the element to the right of the left edge.
		 *  @param rightOffset Number of pixels to position the element to the left of the right edge.
		 */ 
		protected function getScrollPositionDeltaToElementHelperHelper(target:GroupBase,
			elementRectangle:Rectangle,
			elementLocalBounds:Rectangle = null,
			entireElementVisible:Boolean = true,
			topOffset:Number = NaN, 
			bottomOffset:Number = NaN, 
			leftOffset:Number = NaN,
			rightOffset:Number = NaN):Point {
			
			if (!elementRectangle)
				return null;
			
			var scrollR:Rectangle = getScrollRect(target);
			if (!scrollR || !target.clipAndEnableScrolling)
				return null;
			
			if (isNaN(topOffset) && isNaN(bottomOffset) && isNaN(leftOffset) && isNaN(rightOffset) &&
				(scrollR.containsRect(elementRectangle) || (!elementLocalBounds && elementRectangle.containsRect(scrollR))))
				return null;
			
			var dx:Number = 0;
			var dy:Number = 0;
			
			if (entireElementVisible) {
				var dxl:Number = elementRectangle.left - scrollR.left;     // left justify element
				var dxr:Number = elementRectangle.right - scrollR.right;   // right justify element
				var dyt:Number = elementRectangle.top - scrollR.top;       // top justify element
				var dyb:Number = elementRectangle.bottom - scrollR.bottom; // bottom justify element
				
				// minimize the scroll
				dx = (Math.abs(dxl) < Math.abs(dxr)) ? dxl : dxr;
				dy = (Math.abs(dyt) < Math.abs(dyb)) ? dyt : dyb;
				
				if (!isNaN(topOffset))
					dy = dyt + topOffset;
				else if (!isNaN(bottomOffset))
					dy = dyb - bottomOffset;
				
				if (!isNaN(leftOffset))
					dx = dxl + leftOffset;
				else if (!isNaN(rightOffset))
					dx = dxr - rightOffset;
				
				// scrollR "contains"  elementR in just one dimension
				if ((elementRectangle.left >= scrollR.left) && (elementRectangle.right <= scrollR.right))
					dx = 0;
				else if ((elementRectangle.bottom <= scrollR.bottom) && (elementRectangle.top >= scrollR.top))
					dy = 0;
				
				// elementR "contains" scrollR in just one dimension
				if ((elementRectangle.left <= scrollR.left) && (elementRectangle.right >= scrollR.right))
					dx = 0;
				else if ((elementRectangle.bottom >= scrollR.bottom) && (elementRectangle.top <= scrollR.top))
					dy = 0;
			}
			
			if (elementLocalBounds)
			{
				// Only adjust for local bounds if the element is wider than the scroll width
				if (elementRectangle.width > scrollR.width || !entireElementVisible)
				{
					if (elementLocalBounds.left < scrollR.left)
						dx = elementLocalBounds.left - scrollR.left;
					else if (elementLocalBounds.right > scrollR.right)
						dx = elementLocalBounds.right - scrollR.right;
				}
				
				// Only adjust for local bounds if the element is taller than the scroll height
				if (elementRectangle.height > scrollR.height || !entireElementVisible)
				{
					if (elementLocalBounds.bottom > scrollR.bottom) 
						dy = elementLocalBounds.bottom - scrollR.bottom;
					else if (elementLocalBounds.top <= scrollR.top)
						dy = elementLocalBounds.top - scrollR.top;
				}
			}
			
			return new Point(dx, dy);
		}
		
		/**
		 *  Returns the bounds of the target's scroll rectangle in layout coordinates.
		 * 
		 *  Layout methods should not get the target's scroll rectangle directly.
		 * 
		 *  @return The bounds of the target's scrollRect in layout coordinates, null
		 *      if target or clipAndEnableScrolling is false. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		protected function getScrollRect(target:GroupBase):Rectangle
		{
			var g:GroupBase = target;
			if (!g || !g.clipAndEnableScrolling)
				return null;
			var vsp:Number = g.verticalScrollPosition;
			var hsp:Number = g.horizontalScrollPosition;
			return new Rectangle(hsp, vsp, g.width, g.height);
		}
		
		protected function getScrollPoint(target:GroupBase):Point {
			var g:GroupBase = target;
			if (!g || !g.clipAndEnableScrolling)
				return null;
			var vsp:Number = g.verticalScrollPosition;
			var hsp:Number = g.horizontalScrollPosition;
			return new Point(hsp, vsp);
		}
		
		protected function getMaxScrollPoint(scroller:Scroller):Point {
			var maxHorizontalScrollPosition:int = scroller.horizontalScrollBar.maximum;
			var maxVerticalScrollPosition:int = scroller.verticalScrollBar.maximum;
			return new Point(maxHorizontalScrollPosition, maxVerticalScrollPosition);
		}
	}
}