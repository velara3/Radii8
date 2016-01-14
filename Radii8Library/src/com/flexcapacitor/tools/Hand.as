

package com.flexcapacitor.tools {
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.skins.MinimalScrollerSkin;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import mx.core.EventPriority;
	import mx.core.FlexGlobals;
	import mx.core.InteractionMode;
	import mx.events.SandboxMouseEvent;
	import mx.managers.SystemManager;
	
	import spark.components.Scroller;
	import spark.skins.spark.ScrollerSkin;
	
	/**
	 * Moves the stage around when it is larger than the available space.  
	 * 
	 * */
	public class Hand extends EventDispatcher implements ITool {
		
		
		public function Hand()
		{
			//radiate = Radiate.getInstance();
		}
		
		private var _icon:Class = Radii8LibraryToolAssets.Hand;
		
		public function get icon():Class {
			return _icon;
		}
		
		public static const HandOverCursor:Class = Radii8LibraryToolAssets.Hand;
		
		public static const HandGrabCursor:Class = Radii8LibraryToolAssets.HandGrab;
		
		
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
		 * The scroller
		 * */
		public var canvasScroller:Scroller;
		
		
		/**
		 * Cursor when over the document
		 * */
		public var handOverCursorID:String;
		
		/**
		 * Cursor when over the document and mouse is down
		 * */
		public var handGrabCursorID:String;
		
		/**
		 * Indicates if over the document
		 * */
		public var isOverDocument:Boolean;
		
		/**
		 * Indicates the mouse is still down
		 * */
		public var isDown:Boolean;
		
		/**
		 * Previous interaction mode. Usually mouse. 
		 * */
		public var previousInteractionMode:String;
		
		/**
		 * Enable this tool. 
		 * */
		public function enable():void {
			
			//radiate.document.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
			
			if (radiate.selectedDocument) {
				updateDocument(radiate.selectedDocument);
			}
			
			// we made cursors when we imported the tool - these were defined in our tool.xml node we get their reference here. these are the paths to the classes which are embedded icons. we could add these on import at startup??  
			handOverCursorID = radiate.getMouseCursorID(this, "HandOverCursor");
			handGrabCursorID = radiate.getMouseCursorID(this, "HandGrabCursor");
			
			
			if (canvasScroller) {
				canvasScroller.setStyle("interactionMode", InteractionMode.TOUCH);
			}
			
			updateMouseCursor();
		}
		
		/**
		 * Disable this tool.
		 * */
		public function disable():void {
			
			radiate.removeEventListener(RadiateEvent.DOCUMENT_CHANGE, documentChangeHandler);
			
			if (canvasScroller) {
				canvasScroller.setStyle("interactionMode", previousInteractionMode);
				
				// reset the scroller
				var previousSkin:Class = canvasScroller.getStyle("skinClass");
				canvasScroller.setStyle("skinClass", spark.skins.spark.ScrollerSkin);
				canvasScroller.validateNow();
				canvasScroller.setStyle("skinClass", com.flexcapacitor.skins.MinimalScrollerSkin);
				canvasScroller.validateNow();
				canvasScroller.setStyle("skinClass", previousSkin);
			}
			
			updateDocument(null);
			
			previousInteractionMode = null;
			
			Mouse.cursor = MouseCursor.AUTO;
		}
		
		/**
		 * 
		 * */
		public function updateDocument(document:IDocument):void {
			var stage:Stage = FlexGlobals.topLevelApplication.stage;
			var sandboxRoot:DisplayObject = SystemManager(FlexGlobals.topLevelApplication.systemManager).getSandboxRoot();
			
			// remove listeners
			if (targetApplication) {
				targetApplication.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
				targetApplication.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
				targetApplication.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
				targetApplication.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, handleMouseUp);
				
				targetApplication.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
				targetApplication.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
				
				//targetApplication.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true);
				//stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true);
				
			}
			
			targetApplication = document ? document.instance : null;
			
			// add listeners
			if (targetApplication) {
				targetApplication.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, false, EventPriority.CURSOR_MANAGEMENT, true);
				targetApplication.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, EventPriority.CURSOR_MANAGEMENT, true);
				targetApplication.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp, false, EventPriority.CURSOR_MANAGEMENT, true);
				targetApplication.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, handleMouseUp, false, EventPriority.CURSOR_MANAGEMENT, true);
				
				targetApplication.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler, false, EventPriority.CURSOR_MANAGEMENT, true);
				targetApplication.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler, false, EventPriority.CURSOR_MANAGEMENT, true);
				
				if (radiate && radiate.canvasScroller) {
					canvasScroller = radiate.canvasScroller;
				}
			}
			
			
			if (targetApplication==null) {
				canvasScroller = null;
				previousInteractionMode = null;
				return;
			}
			
		}
		
		/**
		 * Click mouse move
		 * */
		protected function handleMouseMove(event:MouseEvent):void {
			isDown = event.buttonDown;
			
			if (isOverDocument) {
				//event.stopImmediatePropagation();
				
				// redispatch mouse move event
				dispatchEvent(event);
				
				updateMouseCursor();
				
			}
		}
		
		/**
		 * Mouse down
		 * */
		protected function handleMouseDown(event:MouseEvent):void {
			isDown = true;
			
			if (isOverDocument) {
				//event.stopImmediatePropagation();
				
				// redispatch mouse move event
				dispatchEvent(event);
				
				updateMouseCursor();
				
			}
			
		}
		
		/**
		 * Mouse up
		 * */
		protected function handleMouseUp(event:MouseEvent):void {
			isDown = false;
			
			if (isOverDocument) {
				//event.stopImmediatePropagation();
				
				// redispatch mouse move event
				dispatchEvent(event);
				
				updateMouseCursor();
				
			}
			
		}
		
		
		/**
		 * Click handler added 
		 * */
		protected function handleClick(event:MouseEvent):void {
			// we are intercepting this event so we can inspect the target
			// stop the event propagation
			
			// we don't stop the propagation on touch devices so you can navigate the application
			//event.stopImmediatePropagation();
			
			updateMouseCursor();
			/*
			if (targetApplication is DisplayObject) {
				
				if (event.altKey || event.shiftKey) {
					radiate.decreaseScale();
				}
				else {
					radiate.increaseScale();
				}
				
			}*/
		}
		
		
		/**
		 * Roll over handler 
		 * */
		protected function rollOverHandler(event:MouseEvent):void {
			isOverDocument = true;
			
			//event.stopImmediatePropagation();
			
			// redispatch rollover event
			dispatchEvent(event);
			
			
			updateMouseCursor();
		}
		
		/**
		 * Roll out handler 
		 * */
		protected function rollOutHandler(event:MouseEvent):void {
			isOverDocument = false;
			
			//event.stopImmediatePropagation();
			
			// redispatch rollout event
			dispatchEvent(event); 
			
			Mouse.cursor = MouseCursor.AUTO;
		}
		
		
		/**
		 * Document changed update. 
		 * */
		protected function documentChangeHandler(event:RadiateEvent):void {
			updateDocument(event.selectedItem as IDocument);
		}
		
		
		/**
		 * Update mouse cursor. Enforce mouse cursor for when already over document. 
		 * */
		public function updateMouseCursor(showCursor:Boolean = false):void {
			
			if (showCursor) {
				isOverDocument = true;
				Mouse.cursor = handOverCursorID;
			}
			
			if (isOverDocument) {
				if (isDown) {
					//Radiate.info("Setting hand grab cursor");
					Mouse.cursor = handGrabCursorID;
				}
				else {
					//Radiate.info("Setting hand over cursor");
					Mouse.cursor = handOverCursorID;
				}
			}
		}
		
	}
}