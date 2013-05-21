
package com.flexcapacitor.tools {
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.events.DragDropEvent;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.DragManagerUtil;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	import com.flexcapacitor.utils.supportClasses.ISelectionGroup;
	import com.flexcapacitor.utils.supportClasses.TargetSelectionGroup;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import mx.core.FlexGlobals;
	import mx.core.IFlexDisplayObject;
	import mx.core.IUIComponent;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	import mx.managers.ISystemManager;
	import mx.managers.PopUpManager;
	
	import spark.components.Application;
	import spark.components.Image;
	import spark.components.List;
	import spark.components.Scroller;
	import spark.components.supportClasses.GroupBase;
	import spark.components.supportClasses.ItemRenderer;
	import spark.core.IGraphicElement;
	import spark.skins.spark.ListDropIndicator;
	
	/**
	 * Finds and selects the item or items under the pointer. 
	 * 
	 * To do:
	 * - select item
	 * - select group
	 * - draw selection area
	 * - show resize handles
	 * - show property inspector
	 * - show selection option
	 * */
	public class Selection implements ITool {
		
		
		public function Selection() {
			
		}
		
		/**
		 * Reference to the current or last target.
		 * */
		public var lastTarget:Object;
		
		private var _showSelection:Boolean = true;

		/**
		 * Show selection around target.
		 * */
		public function get showSelection():Boolean {
			return _showSelection;
		}

		/**
		 * @private
		 */
		public function set showSelection(value:Boolean):void {
			_showSelection = value;
			
			if (value) {
				if (radiate.target) {
					drawSelection(radiate.target, toolLayer);
				}
			}
			else {
				clearSelection();
			}
		}

		
		public var targetSelectionGroup:ItemRenderer;
		public var mouseLocationLines:IFlexDisplayObject = new ListDropIndicator();
		private var _showSelectionLabel:Boolean = true;

		public function get showSelectionLabel():Boolean {
			return _showSelectionLabel;
		}

		public function set showSelectionLabel(value:Boolean):void {
			if (_showSelectionLabel==value) return;
			
			_showSelectionLabel = value;
			
			updateTarget(radiate.target);
		}

		public var showSelectionLabelOnDocument:Boolean = false;
		public var showSelectionFill:Boolean = true;
		public var showSelectionFillOnDocument:Boolean = false;
		public var lastTargetCandidate:Object;
		
		public var toolLayer:IVisualElementContainer;
		
		/**
		 * Enable this tool. 
		 * */
		public function enable():void {
			radiate = Radiate.getInstance();
			
			
			if (radiate.document) {
				
				updateDocument(radiate.document);
			}
			else {
				radiate.addEventListener(RadiateEvent.DOCUMENT_CHANGE, documentChangeHandler, false, 0, true);
			}
			
			radiate.addEventListener(RadiateEvent.TARGET_CHANGE, targetChangeHandler, false, 0, true);
			radiate.addEventListener(RadiateEvent.PROPERTY_CHANGE, propertyChangeHandler, false, 0, true);
		}
		
		protected function propertyChangeHandler(event:RadiateEvent):void {
			updateTarget(event.selectedItem);
		}
		
		protected function targetChangeHandler(event:RadiateEvent):void {
			updateTarget(event.selectedItem);
			
		}
		
		protected function documentChangeHandler(event:RadiateEvent):void {
			updateDocument(event.selectedItem);
			
		}
		
		public function updateDocument(document:Object):void {
			
			// remove listeners
			if (targetApplication && targetApplication!=document) {
				Object(targetApplication).stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				Object(targetApplication).removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			}
			
			targetApplication = document;
			
			// add listeners
			if (document) {
				Object(document).stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
				Object(document).addEventListener(KeyboardEvent.KEY_UP, keyUpHandler, false, 0, true);
				Object(document).addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true, 1001, true);
				Object(document).addEventListener(FlexEvent.UPDATE_COMPLETE, updateCompleteHandler, false, 0, true);
			}
			
			
			
			if (radiate.toolLayer) {
				toolLayer = radiate.toolLayer;
			}
			
			if (radiate.canvasBackground) {
				canvasBackground = radiate.canvasBackground;
			}
			
			if (radiate.canvasBackgroundParent) {
				if (canvasBackgroundParent) {
					canvasBackgroundParent.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleScrollChanges);
				}
				canvasBackgroundParent = radiate.canvasBackgroundParent;
				canvasBackgroundParent.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleScrollChanges, false, 1000, true);
			}
			
			if (radiate.canvasScroller) {
				if (canvasScroller) {
					
				}
				canvasScroller = radiate.canvasScroller;
				canvasScroller.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, handleScrollChanges, false, 1000, true);
			}
		}
		
		/**
		 * Handle scroll position changes
		 */
		private function handleScrollChanges(event:PropertyChangeEvent):void {
			 if (event.source == event.target && event.property == "verticalScrollPosition") {
				//trace(e.property, "changed to", e.newValue);
				//drawSelection(radiate.target);
				//Radiate.log.info("Selection scroll change");
			}
			if (event.source == event.target && event.property == "horizontalScrollPosition") {
				//trace(e.property, "changed to", e.newValue);
				//drawSelection(radiate.target);
				//Radiate.log.info("Selection scroll change");
			}
		}
		
		/**
		 * Update complete event for target
		 * */
		public function updateCompleteHandler(event:FlexEvent):void {
			
			updateTarget(event.currentTarget);
		}
	
		/**
		 * Updates selection around the target
		 * */
		public function updateTarget(target:Object):void {
			
			if (lastTarget && lastTarget is Image) {
				lastTarget.removeEventListener(FlexEvent.READY, setSelectionLaterHandler);
				lastTarget.removeEventListener(Event.COMPLETE, setSelectionLaterHandler);
				lastTarget.removeEventListener(IOErrorEvent.IO_ERROR, setSelectionLaterHandler);
				lastTarget.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, setSelectionLaterHandler);
			}
			
			lastTarget = target;
			
			if (lastTarget && lastTarget is Image) {
				lastTarget.addEventListener(FlexEvent.READY, setSelectionLaterHandler, false, 0, true);
				lastTarget.addEventListener(Event.COMPLETE, setSelectionLaterHandler, false, 0, true);
				lastTarget.addEventListener(IOErrorEvent.IO_ERROR, setSelectionLaterHandler, false, 0, true);
				lastTarget.addEventListener(SecurityErrorEvent.SECURITY_ERROR, setSelectionLaterHandler, false, 0, true);
			}
			
			
			if (showSelection && 
				(target is IVisualElement || target is IGraphicElement)) {
				drawSelection(target, toolLayer);
			}
			else {
				clearSelection();
			}
		}
	
		/**
		 * Disable this tool.
		 * */
		public function disable():void {
			
			if (radiate.document) {
				Object(radiate.document).stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			}
			
			radiate.removeEventListener(RadiateEvent.DOCUMENT_CHANGE, documentChangeHandler);
				
			clearSelection();
		}
		
		/**
		 * The radiate instance.
		 * */
		public var radiate:Radiate;
		
		/**
		 * Drag helper utility.
		 * */
		private var dragManagerInstance:DragManagerUtil;

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
		 * The background parent scroller
		 * */
		public var canvasScroller:Scroller;
		
		/**
		 * Add listeners to target
		 * */
		protected function mouseDownHandler(event:MouseEvent):void {
			var point:Point = new Point(event.stageX, event.stageY);
			var targetsUnderPoint:Array = FlexGlobals.topLevelApplication.getObjectsUnderPoint(point);
			var componentTree:ComponentDescription;
			var description:ComponentDescription;
			var target:Object = event.target;
			var items:Array = [];
			var length:int;
			
			
			
			radiate = Radiate.getInstance();
			targetApplication = radiate.document;
			
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
				
				//Radiate.log.info("Selection Mouse down");
				
				// select target on mouse up or drag drop whichever comes first
				target.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
				
				if (target!=targetApplication) {
					
					// listen for drag
					if (!dragManagerInstance) {
						dragManagerInstance = new DragManagerUtil();
					}
					
					//target.visible = false;
					dragManagerInstance.listenForDragBehavior(target as IUIComponent, radiate.document as Application, event);
					dragManagerInstance.addEventListener(DragDropEvent.DRAG_DROP, handleDragDrop);
					dragManagerInstance.addEventListener(DragDropEvent.DRAG_OVER, handleDragOver);
				}
			}
			
		}
		
		/**
		 * Handles drag over
		 * */
		protected function handleDragOver(event:DragDropEvent):void {
			//Radiate.log.info("Selection Drag Drop");
			var target:Object = dragManagerInstance.draggedItem;
			// trace("Drag over")
			
			
		}
		
		/**
		 * Handles mouse up event on the target
		 * */
		protected function handleDragDrop(event:DragDropEvent):void {
			// select target
			//radiate.target = event.draggedItem;
			//Radiate.log.info("Selection Drag Drop");
			
			var target:Object = dragManagerInstance.draggedItem;
			
			
			// CHECKING FOR ROGUE EVENT LISTENERS BEING ADDED TO THE TARGET
			// SOME ARE ADDED BY CONSTRAINTS PANEL
			
			// clean up
			if (target.hasEventListener(MouseEvent.MOUSE_UP)) {
				//Radiate.log.info("3 has event listener");
			}
			
			target.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			
			if (target.hasEventListener(MouseEvent.MOUSE_UP)) {
				//Radiate.log.info("4 has event listener");
			}
			else {
				//Radiate.log.info("listener removed");
			}
			
			//Radiate.log.info("End Selection Drag Drop");
			
			// select target
			if (radiate.target!=target) {
				radiate.setTarget(target, true);
			}
			
			if (showSelection) {
				updateTarget(target);
			}
			
			
			dragManagerInstance.removeEventListener(DragDropEvent.DRAG_DROP, handleDragDrop);
			dragManagerInstance.removeEventListener(DragDropEvent.DRAG_OVER, handleDragOver);
		}
	
		/**
		 * Handle mouse up on the stage
		 * */
		protected function mouseUpHandler(event:MouseEvent):void {
			var target:Object = event.currentTarget;
			//Radiate.log.info("Selection Mouse up");
			
			if (target is List) {
				target.dragEnabled = true; // restore drag and drop if it was enabled
			}
			
			target.visible = true;
			
			// clean up
			if (target.hasEventListener(MouseEvent.MOUSE_UP)) {
				//Radiate.log.info("1 has event listener");
			}
			
			target.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			
			if (target.hasEventListener(MouseEvent.MOUSE_UP)) {
				//Radiate.log.info("2 has event listener");
			}
			else {
				//Radiate.log.info("listener removed");
			}
			
			//Radiate.log.info("End Selection Mouse Up");
			
			// select target
			if (radiate.target!=target) {
				radiate.setTarget(target, true);
			}
			
			// draw selection rectangle
			if (showSelection) {
				updateTarget(target);
			}
		}
		
		/**
		 * Prevent system manager from taking our events
		 * */
	    private function keyDownHandler(event:KeyboardEvent):void
	    {
			
            switch (event.keyCode)
            {
                case Keyboard.UP:
                case Keyboard.DOWN:
                case Keyboard.PAGE_UP:
                case Keyboard.PAGE_DOWN:
                case Keyboard.HOME:
                case Keyboard.END:
                case Keyboard.LEFT:
                case Keyboard.RIGHT:
                case Keyboard.ENTER:
                {
                    event.stopImmediatePropagation();
					//Radiate.log.info("Canceling key down");
                }
            }
	    }
		
		/**
		 * Handle keyboard position changes
		 * */
		protected function keyUpHandler(event:KeyboardEvent):void {
			var changes:Array = [];
			var constant:int = event.shiftKey ? 10 : 1;
			var index:int;
			var applicable:Boolean;
			
					//Radiate.log.info("Selection key up");
			if (radiate.targets.length>0) {
				applicable = true;
			}
			
			if (event.keyCode==Keyboard.LEFT) {
				
				for (;index<radiate.targets.length;index++) {
					changes.push(radiate.targets[index].x-constant);
				}
				
				Radiate.moveElement(radiate.targets, null, ["x"], changes);
			}
			else if (event.keyCode==Keyboard.RIGHT) {
				for (;index<radiate.targets.length;index++) {
					changes.push(radiate.targets[index].x+constant);
				}
				
				Radiate.moveElement(radiate.targets, null, ["x"], changes);
			}
			else if (event.keyCode==Keyboard.UP) {
				for (;index<radiate.targets.length;index++) {
					changes.push(radiate.targets[index].y-constant);
				}
				
				Radiate.moveElement(radiate.targets, null, ["y"], changes);
			}
			else if (event.keyCode==Keyboard.DOWN) {
				for (;index<radiate.targets.length;index++) {
					changes.push(radiate.targets[index].y+constant);
				}
				
				Radiate.moveElement(radiate.targets, null, ["y"], changes);
			}
			else if (event.keyCode==Keyboard.DELETE) {
				
				Radiate.removeElement(radiate.targets);
			}
			
			if (applicable) {
				event.stopImmediatePropagation();
				event.stopPropagation();
				event.preventDefault();
			}
		}
		
		/**
		 * Show selection box on target change
		 * */
		public var showSelectionRectangle:Boolean = true;
		
		/**
		 * Clears the outline around a target display object
		 * */
		public function clearSelection():void {
			
			if (targetSelectionGroup) {
				targetSelectionGroup.visible = false;
			}
		}
		
		/**
		 * Draws outline around target display object. 
		 * Trying to add support to add different types of selection rectangles. 
		 * */
		public function drawSelection2(target:Object, selection:Object = null):void {
			var rectangle:Rectangle;
			
			// creates an instance of the bounding box that will be shown around the drop target
			if (targetSelectionGroup) {
				targetSelectionGroup.mouseEnabled = false;
				targetSelectionGroup.mouseChildren = false;
			}
			
			// get bounds
			if (!target) {
				
				// set values to zero
				if (!rectangle) {
					rectangle = new Rectangle();
				}
				
				// hide selection group
				if (targetSelectionGroup.visible) {
					targetSelectionGroup.visible = false;
				}
			}
			else {
				
				if (selection) {
					
					
				}
				
				// draw the selection rectangle only if it's changed
				else if (lastTargetCandidate!=target) {
					var topLevelApplication:Object = FlexGlobals.topLevelApplication;
					// if selection is offset then check if using system manager sandbox root or top level root
					var systemManager:ISystemManager = ISystemManager(topLevelApplication.systemManager);
					
					// no types so no dependencies
					var marshallPlanSystemManager:Object = systemManager.getImplementation("mx.managers.IMarshallPlanSystemManager");
					var targetCoordinateSpace:DisplayObject;
					
					if (marshallPlanSystemManager && marshallPlanSystemManager.useSWFBridge()) {
						targetCoordinateSpace = Sprite(systemManager.getSandboxRoot());
					}
					else {
						targetCoordinateSpace = Sprite(topLevelApplication);
					}
					
					
					// get content width and height
					if (target is GroupBase) {
						rectangle = GroupBase(target).getBounds(target.parent);
						
						// size and position fill
						targetSelectionGroup.width = GroupBase(target).contentWidth || rectangle.size.x;
						targetSelectionGroup.height = GroupBase(target).contentHeight || rectangle.size.y;
						
						rectangle = GroupBase(target).getVisibleRect(target.parent);
						targetSelectionGroup.x = rectangle.x;
						targetSelectionGroup.y = rectangle.y;
						//trace("target is groupbase");
					}
					
					// get target bounds
					else if (target is UIComponent) {
						rectangle = UIComponent(target).getVisibleRect(target.parent);
						//rectangle = UIComponent(target).getBounds(target.parent);
						
						// size and position fill
						targetSelectionGroup.width = rectangle.width;
						targetSelectionGroup.height = rectangle.height;
						//rectangle = UIComponent(target).getVisibleRect(target.parent); // get correct x and y
						targetSelectionGroup.x = rectangle.x;
						targetSelectionGroup.y = rectangle.y;
						//trace("target is uicomponent");
					}
					else {
						rectangle = DisplayObject(target).getBounds(targetCoordinateSpace);
						
						// size and position fill
						targetSelectionGroup.width = rectangle.width;
						targetSelectionGroup.height = rectangle.height;
						targetSelectionGroup.x = rectangle.x;
						targetSelectionGroup.y = rectangle.y;
						//trace("target is not uicomponent");
					}
					
					
					targetSelectionGroup.data = target;
					
					// unhide target selection group
					if (!targetSelectionGroup.visible) {
						targetSelectionGroup.visible = true;
					}
					
					targetCoordinateSpace = Radiate.instance.document as DisplayObject;
					
					// show selection / bounding box 
					PopUpManager.addPopUp(targetSelectionGroup, targetCoordinateSpace);
					targetSelectionGroup.validateNow();
				}
				
			}
		}
		
		/**
		 * Draws outline around target display object. 
		 * Trying to add support to add different types of selection rectangles. 
		 * */
		public function drawSelection(target:Object, selection:Object = null):void {
			var rectangle:Rectangle;
			var selectionGroup:ISelectionGroup;
			
			// creates an instance of the bounding box that will be shown around the drop target
			if (!targetSelectionGroup) {
				targetSelectionGroup = new TargetSelectionGroup();
			}
			
			if (targetSelectionGroup) {
				//targetSelectionGroup.mouseEnabled = false;
				//targetSelectionGroup.mouseChildren = false;
				selectionGroup = targetSelectionGroup as ISelectionGroup;
				
				if (selectionGroup) {
					
					selectionGroup.showSelectionFill 			= showSelectionFill;
					selectionGroup.showSelectionFillOnDocument	= showSelectionFillOnDocument;
					selectionGroup.showSelectionLabel 			= showSelectionLabel;
					selectionGroup.showSelectionLabelOnDocument = showSelectionLabelOnDocument;
					
				}
			}
			
			// get bounds
			if (!target) {
				
				// set values to zero
				if (!rectangle) {
					rectangle = new Rectangle();
				}
				
				// hide selection group
				if (targetSelectionGroup.visible) {
					targetSelectionGroup.visible = false;
				}
			}
			else {
				
				// get and set selection rectangle
				setSelectionGroup(target, selection as DisplayObject);
				
				
				// add to tools layer
				if (selection && selection is IVisualElementContainer) {
					IVisualElementContainer(selection).addElement(targetSelectionGroup);
					targetSelectionGroup.validateNow();
				}
				
				// draw the selection rectangle only if it's changed
				else if (lastTargetCandidate!=target) {
					var topLevelApplication:Object = FlexGlobals.topLevelApplication;
					// if selection is offset then check if using system manager sandbox root or top level root
					var systemManager:ISystemManager = ISystemManager(topLevelApplication.systemManager);
					
					// no types so no dependencies
					var marshallPlanSystemManager:Object = systemManager.getImplementation("mx.managers.IMarshallPlanSystemManager");
					var targetCoordinateSpace:DisplayObject;
					
					if (marshallPlanSystemManager && marshallPlanSystemManager.useSWFBridge()) {
						targetCoordinateSpace = Sprite(systemManager.getSandboxRoot());
					}
					else {
						targetCoordinateSpace = Sprite(topLevelApplication);
					}
					
					/*
					var documentSpace:DisplayObject = Radiate.instance.document as DisplayObject;
					
					if (documentSpace) {
						targetCoordinateSpace = documentSpace;
					}*/
					
					// Error occurs when targetCoordinateSpace is the document (loaded application)
					// Error: removeChild() is not available in this class. 
					// Instead, use removeElement() or modify the skin, if you have one.
					//     at spark.components::Group/removeChild()[E:\dev\4.y\frameworks\projects\spark\src\spark\components\Group.as:2136]
					//
					// Solution:
					// 
					// probably use toplevelapplication
					
					// show selection / bounding box
					PopUpManager.addPopUp(targetSelectionGroup, targetCoordinateSpace);
					targetSelectionGroup.validateNow();
				}
				
			}
		}
		
		/**
		 * Sets the selection rectangle to the size of the target.
		 * */
		public function setSelectionGroup(target:Object, targetCoordinateSpace:DisplayObject = null, localTargetSpace:Boolean = true):void {
			var rectangle:Rectangle;
			var showContentSize:Boolean = false;
			var isEmbeddedCoordinateSpace:Boolean;
			var isTargetInvalid:Boolean;
			
			// get content width and height
			if (target is GroupBase) {
				if (!targetCoordinateSpace) targetCoordinateSpace = target.parent;
				//rectangle = GroupBase(target).getBounds(target.parent);
				rectangle = GroupBase(target).getBounds(targetCoordinateSpace);
				
				// size and position fill
				targetSelectionGroup.width = showContentSize ? GroupBase(target).contentWidth : rectangle.size.x;
				targetSelectionGroup.height = showContentSize ? GroupBase(target).contentHeight : rectangle.size.y;
				
				if (!localTargetSpace) {
					rectangle = GroupBase(target).getVisibleRect(target.parent);
				}
				
				targetSelectionGroup.x = rectangle.x;
				targetSelectionGroup.y = rectangle.y;
				//trace("target is groupbase");
			}
			else if (target is Image) {
				
				if (targetCoordinateSpace && "systemManager" in targetCoordinateSpace
					&& Object(targetCoordinateSpace).systemManager!=target.systemManager) {
					isEmbeddedCoordinateSpace = true;
				}
				
				if (!targetCoordinateSpace ) targetCoordinateSpace = target.parent; 
				
			
				// if target is IMAGE it can be sized to 6711034.2 width or height at times!!! 6710932.2
				// possibly because it is not ready. there is a flag _ready that is false
				// also sourceWidth and sourceHeight are NaN at first
					
				trace("targetCoordinateSpace="+Object(targetCoordinateSpace).id);
				trace("targetCoordinateSpace owner="+Object(targetCoordinateSpace).owner.id);
				trace("x=" + target.x);
				trace("y=" + target.y);
				trace("w=" + target.width);
				trace("h=" + target.height);
				//if (!localTargetSpace) {
				/*	rectangle = UIComponent(target).getVisibleRect();
					rectangle = UIComponent(target).getVisibleRect(targetCoordinateSpace);
					rectangle = UIComponent(target).getVisibleRect(target.parent);
					rectangle = UIComponent(target).getVisibleRect(targetApplication.parent);
					rectangle = UIComponent(target).getVisibleRect(Object(targetCoordinateSpace).owner);
					rectangle = UIComponent(target).getVisibleRect(targetCoordinateSpace.parent);
				*/
				target.validateNow();
				
				rectangle = UIComponent(target).getBounds(targetCoordinateSpace);
				
				if (rectangle.width==0 || rectangle.height==0
					|| rectangle.x>100000 || rectangle.y>100000) {
					
					//Radiate.log.info("Image not returning correct bounds");
					/*
					target.addEventListener(FlexEvent.READY, setSelectionLaterHandler, false, 0, true);
					target.addEventListener(Event.COMPLETE, setSelectionLaterHandler, false, 0, true);
					target.addEventListener(IOErrorEvent.IO_ERROR, setSelectionLaterHandler, false, 0, true);
					target.addEventListener(SecurityErrorEvent.SECURITY_ERROR, setSelectionLaterHandler, false, 0, true);
					*/
					//target.imageDisplay.addEventListener(FlexEvent.READY, setSelectionLaterHandler, false, 0, true);
					//target.imageDisplay.addEventListener(Event.COMPLETE, setSelectionLaterHandler, false, 0, true);
					
					// size and position fill
					//targetSelectionGroup.width = 0;//rectangle.width;//UIComponent(target).getLayoutBoundsWidth();
					//targetSelectionGroup.height = 0;//rectangle.height; // UIComponent(target).getLayoutBoundsHeight();
					//targetSelectionGroup.x = 0;//rectangle.x;
					//targetSelectionGroup.y = 0;//rectangle.y;
					isTargetInvalid = true;
				}
				else {
					
					/*rectangle = UIComponent(target).getBounds(target.parent);
					rectangle = UIComponent(target).getBounds(target.owner);
					rectangle = UIComponent(target).getBounds(targetCoordinateSpace.parent);
					rectangle = UIComponent(target).getBounds(null);*/
				//}
				//else {
					
					/*rectangle = UIComponent(target).getBounds(targetCoordinateSpace);
					rectangle = UIComponent(target).getBounds(target.parent);
					rectangle = UIComponent(target).getBounds(targetApplication as DisplayObject);
					rectangle = UIComponent(target).getBounds(targetApplication.parent);
					var s:Number = UIComponent(target).getLayoutBoundsWidth();
					s= UIComponent(target).getLayoutBoundsHeight();
					s= UIComponent(target).getLayoutBoundsX();
					s= UIComponent(target).getLayoutBoundsY();*/
				//}
					
					// size and position fill
					targetSelectionGroup.width = rectangle.width;//UIComponent(target).getLayoutBoundsWidth();
					targetSelectionGroup.height = rectangle.height; // UIComponent(target).getLayoutBoundsHeight();
					//rectangle = UIComponent(target).getVisibleRect(target.parent); // get correct x and y
					targetSelectionGroup.x = rectangle.x;
					targetSelectionGroup.y = rectangle.y;
				}
				
			}
			// get target bounds
			else if (target is UIComponent) {
				if (!targetCoordinateSpace) targetCoordinateSpace = target.parent; 
				
				if (!localTargetSpace) {
					rectangle = UIComponent(target).getVisibleRect(targetCoordinateSpace);
				}
				else {
					// if target is IMAGE it can be sized to 6711034.2 width or height at times!!! 6710932.2
					rectangle = UIComponent(target).getBounds(targetCoordinateSpace);
				}
				
				// size and position fill
				targetSelectionGroup.width = rectangle.width;
				targetSelectionGroup.height = rectangle.height;
				//rectangle = UIComponent(target).getVisibleRect(target.parent); // get correct x and y
				targetSelectionGroup.x = rectangle.x;
				targetSelectionGroup.y = rectangle.y;
				//trace("target is uicomponent");
			}
			// get target bounds
			else if (target is IGraphicElement) {
				if (!targetCoordinateSpace) targetCoordinateSpace = target.parent; 
				
				/*if (!localTargetSpace) {
					rectangle = IGraphicElement(target).getLayoutBoundsHeight();
				}
				else {
					rectangle = IGraphicElement(target).getBounds(targetCoordinateSpace);
				}*/
				
				// size and position fill
				targetSelectionGroup.width = IGraphicElement(target).getLayoutBoundsWidth();
				targetSelectionGroup.height = IGraphicElement(target).getLayoutBoundsHeight();
				//rectangle = UIComponent(target).getVisibleRect(target.parent); // get correct x and y
				targetSelectionGroup.x = IGraphicElement(target).getLayoutBoundsX();
				targetSelectionGroup.y = IGraphicElement(target).getLayoutBoundsY();
				//trace("target is uicomponent");
			}
			
			else {
				if (!localTargetSpace) {
					rectangle = DisplayObject(target).getBounds(targetCoordinateSpace);
				}
				else {
					rectangle = DisplayObject(target).getBounds(targetCoordinateSpace);
				}
				
				// size and position fill
				targetSelectionGroup.width = rectangle.width;
				targetSelectionGroup.height = rectangle.height;
				targetSelectionGroup.x = rectangle.x;
				targetSelectionGroup.y = rectangle.y;
				//trace("target is not uicomponent");
			}
			
			// we set to the target so we can display target name and size in label above selection
			targetSelectionGroup.data = target;
			
			
			// unhide target selection group
			if (isTargetInvalid) {
				targetSelectionGroup.visible = false;
			}
			
			else if (!targetSelectionGroup.visible) {
				targetSelectionGroup.visible = true;
			}
		}
		
		/**
		 * When waiting for images to the display we need to update the selection after the image loads
		 * */
		public function setSelectionLaterHandler(event:Event):void {
			
			// we are referencing the 
			if (radiate.targets.indexOf(lastTarget)!=-1) {
				radiate.target.validateNow();
				updateTarget(radiate.target);
			}
			
			
			/*if (event.type==FlexEvent.READY) {
				Radiate.log.info("Removing Ready listener for " + event.currentTarget);
				event.currentTarget.removeEventListener(FlexEvent.READY, setSelectionLaterHandler);
			}
			else if (event.type==Event.COMPLETE) {
				Radiate.log.info("Removing Complete listener for " + event.currentTarget);
				event.currentTarget.removeEventListener(Event.COMPLETE, setSelectionLaterHandler);
			}*/
		}
	}
}