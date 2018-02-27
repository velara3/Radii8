
package com.flexcapacitor.tools {
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.managers.ToolManager;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.views.Tools;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import mx.core.EventPriority;
	
	[Event(name="rollOver", type="flash.events.MouseEvent")]
	[Event(name="rollOut", type="flash.events.MouseEvent")]
	[Event(name="mouseMove", type="flash.events.MouseEvent")]
	
	/**
	 * Gets the color under the pointer. 
	 * 
	 * */
	public class EyeDropper extends EventDispatcher implements ITool {
		
		
		public function EyeDropper() {
			
		}
		
		private var _icon:Class = Radii8LibraryToolAssets.EyeDropper;
		
		public function get icon():Class {
			return _icon;
		}
		
		public static const Cursor:Class = Radii8LibraryToolAssets.EyeDropperCursor;
		
		public var cursors:Array;
		public var radiate:Radiate;
		public var targetApplication:Object;

		private var defaultCursorID:String;
		public var isOverDocument:Boolean;
		
		/**
		 * Enable
		 * */
		public function enable():void {
			radiate = Radiate.instance;
			
			radiate.addEventListener(RadiateEvent.DOCUMENT_CHANGE, documentChangeHandler, false, 0, true);
			
			if (Radiate.selectedDocument) {
				updateDocument(Radiate.selectedDocument);
			}
			
			defaultCursorID = ToolManager.getMouseCursorID(this);
			
			Mouse.cursor = defaultCursorID;
		}
	
		/**
		 * Disable 
		 * */
		public function disable():void {
			
			radiate.removeEventListener(RadiateEvent.DOCUMENT_CHANGE, documentChangeHandler);
			
			updateDocument(null);
			
			Mouse.cursor = MouseCursor.AUTO;
		}
		
		/**
		 * Document changed update. 
		 * */
		protected function documentChangeHandler(event:RadiateEvent):void {
			updateDocument(event.selectedItem as IDocument);
			
		}
		
		public function updateDocument(document:IDocument):void {
			
			// remove listeners
			if (targetApplication) {
				targetApplication.removeEventListener(MouseEvent.CLICK, handleClick, true);
				targetApplication.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
				targetApplication.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
				targetApplication.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			}
			
			targetApplication = document ? document.instance : null;
			
			// add listeners
			if (targetApplication) {
				targetApplication.addEventListener(MouseEvent.CLICK, handleClick, true, EventPriority.CURSOR_MANAGEMENT, true);
				targetApplication.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, false, EventPriority.CURSOR_MANAGEMENT, true);
				targetApplication.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler, false, EventPriority.CURSOR_MANAGEMENT, true);
				targetApplication.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler, false, EventPriority.CURSOR_MANAGEMENT, true);
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
			getColorUnderMouse(event.target, event, false);
		}
		
		/**
		 * Click mouse move
		 * */
		protected function handleMouseMove(event:MouseEvent):void {
			
			if (isOverDocument) {
				event.stopImmediatePropagation();
				getColorUnderMouse(event.target, event, true);
				
				// redispatch mouse move event
				dispatchEvent(event);
			}
		}
		
		
		/**
		 * Roll over handler 
		 * */
		protected function rollOverHandler(event:MouseEvent):void {
			isOverDocument = true;
			
			event.stopImmediatePropagation();
			//getColorUnderMouse(event.target, event, true);
			
			// redispatch rollover event
			dispatchEvent(event);
			
			Mouse.cursor = defaultCursorID;
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
		 * Get color under mouse.
		 * */
		protected function getColorUnderMouse(target:Object, event:MouseEvent, isPreview:Boolean = true):void {
			var color:Object = DisplayObjectUtils.getColorUnderMouse(event);
			var couldNotGetColor:Boolean;
			
			// if color is null we may be outside our security sandbox
			if (color==null) {
				couldNotGetColor = true;
				
				if (isPreview) {
					Radiate.dispatchColorPreviewEvent(0, couldNotGetColor);
				}
				else {
					Radiate.dispatchColorSelectedEvent(0, couldNotGetColor);
				}
			}
			else {
				if (isPreview) {
					Radiate.dispatchColorPreviewEvent(uint(color));
				}
				else {
					Radiate.dispatchColorSelectedEvent(uint(color));
					
				}
			}
		}
	}
}

