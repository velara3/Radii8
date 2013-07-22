
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
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import mx.core.EventPriority;
	import mx.core.FlexGlobals;
	import mx.managers.SystemManager;
	
	/**
	 * Zooms in on the stage.  
	 * 
	 * */
	public class Zoom extends EventDispatcher implements ITool {
		
		
		public function Zoom()
		{
			//radiate = Radiate.getInstance();
		}
		
		[Embed(source="assets/icons/tools/Zoom.png")]
		private var _icon:Class;
		
		public function get icon():Class {
			return _icon;
		}
		
		[Embed(source="assets/icons/tools/ZoomIn.png")]
		public static const ZoomInCursor:Class;
		
		[Embed(source="assets/icons/tools/ZoomOut.png")]
		public static const ZoomOutCursor:Class;
		
		public var cursors:Array;
		
		

		/**
		 * The radiate instance.
		 * */
		public function get radiate():Radiate {
			return Radiate.getInstance();
		}


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
			
			if (radiate.document) {
				updateDocument(radiate.document);
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
				targetApplication.removeEventListener(MouseEvent.CLICK, handleClick, true);
				targetApplication.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
				targetApplication.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
				targetApplication.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
				targetApplication.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
				
				//targetApplication.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true);
				//stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true);
				
				// keyboard handling
				//targetApplication.removeEventListener(Event.ENTER_FRAME, enterFrameHandler, false);
				sandboxRoot.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandlerSandboxRoot, false);
				//sandboxRoot.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandlerSandboxRoot, false);
				//sandboxRoot.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandlerSandboxRoot, true);
			}
			
			targetApplication = document ? document.instance : null;
			
			// add listeners
			if (targetApplication) {
				targetApplication.addEventListener(MouseEvent.CLICK, handleClick, true, EventPriority.CURSOR_MANAGEMENT, true);
				targetApplication.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, false, EventPriority.CURSOR_MANAGEMENT, true);
				targetApplication.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, EventPriority.CURSOR_MANAGEMENT, true);
				targetApplication.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler, false, EventPriority.CURSOR_MANAGEMENT, true);
				targetApplication.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler, false, EventPriority.CURSOR_MANAGEMENT, true);
				
				// keyboard handling
				//targetApplication.addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, EventPriority.DEFAULT, true);
				sandboxRoot.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandlerSandboxRoot, false, EventPriority.DEFAULT, true);
				sandboxRoot.addEventListener(KeyboardEvent.KEY_UP, keyUpHandlerSandboxRoot, false, EventPriority.DEFAULT, true);
				//sandboxRoot.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandlerSandboxRoot, false, 1001, true);
				//sandboxRoot.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandlerSandboxRoot, true, 1001, true);
				
				//targetApplication.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, false, EventPriority.CURSOR_MANAGEMENT, true);
				//targetApplication.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true, EventPriority.CURSOR_MANAGEMENT, true);
				
				//stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, false, EventPriority.CURSOR_MANAGEMENT, true);
				//stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true, EventPriority.CURSOR_MANAGEMENT, true);
			}
			
		}
		
		/**
		 * Click mouse move
		 * */
		protected function handleMouseMove(event:MouseEvent):void {
			
			if (isOverDocument) {
				event.stopImmediatePropagation();
				
				// redispatch mouse move event
				dispatchEvent(event);
				
				updateMouseCursor(event.altKey || event.shiftKey);
				
			}
		}
		
		/**
		 * Click mouse down
		 * */
		protected function handleMouseDown(event:MouseEvent):void {
			
			if (isOverDocument) {
				event.stopImmediatePropagation();
				
				// redispatch mouse move event
				dispatchEvent(event);
				
				updateMouseCursor(event.altKey || event.shiftKey);
				
			}
		}
		
		
		/**
		 * Click handler added 
		 * */
		protected function handleClick(event:MouseEvent):void {
			// we are intercepting this event so we can inspect the target
			// stop the event propagation
			
			// we don't stop the propagation on touch devices so you can navigate the application
			event.stopImmediatePropagation();
			
			updateMouseCursor(event.altKey || event.shiftKey);
			
			if (targetApplication is DisplayObject) {
				
				if (event.altKey || event.shiftKey) {
					radiate.decreaseScale();
				}
				else {
					radiate.increaseScale();
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
			isOverDocument = false;
			event.stopImmediatePropagation();
			
			// redispatch rollout event
			dispatchEvent(event); 
			
			Mouse.cursor = MouseCursor.AUTO;
		}
		
		/**
		 * Key down handler 
		 * */
		protected function keyDownHandler(event:KeyboardEvent):void {
			//Radiate.log.info("Dispatcher is: " + event.currentTarget + " in phase " + (event.eventPhase==1 ? "capture" : "bubble"));
			updateMouseCursor(event.altKey || event.shiftKey);
		}
		
		/**
		 * Key down handler 
		 * */
		protected function keyDownHandlerSandboxRoot(event:KeyboardEvent):void {
			// Radiate.log.info("1. Dispatcher is: " + event.currentTarget + " in phase " + (event.eventPhase==1 ? "capture" : "bubble"));
			updateMouseCursor(event.altKey || event.shiftKey);
		}
		
		/**
		 * Key up handler 
		 * */
		protected function keyUpHandlerSandboxRoot(event:KeyboardEvent):void {
			// Radiate.log.info("1. Dispatcher is: " + event.currentTarget + " in phase " + (event.eventPhase==1 ? "capture" : "bubble"));
			updateMouseCursor(event.altKey || event.shiftKey);
		}
		
		/**
		 * Enter frame handler to try and capture ALT key. Doesn't work. 
		 * */
		protected function enterFrameHandler(event:Event):void {
			//Radiate.log.info("1. Dispatcher is: " + event.currentTarget + " in phase " + (event.eventPhase==1 ? "capture" : "bubble"));
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
					//Radiate.log.info("Setting zoom out");
					Mouse.cursor = zoomOutCursorID;
				}
				else {
					//Radiate.log.info("Setting zoom IN");
					Mouse.cursor = zoomInCursorID;
				}
			}
		}
		
	}
}