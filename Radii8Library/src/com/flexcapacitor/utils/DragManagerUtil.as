

package com.flexcapacitor.utils {
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.events.DragDropEvent;
	import com.flexcapacitor.managers.HistoryManager;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	import com.flexcapacitor.utils.supportClasses.DragData;
	import com.flexcapacitor.utils.supportClasses.SnapPoints;
	import com.flexcapacitor.utils.supportClasses.SnapToElementDropIndicator;
	import com.flexcapacitor.utils.supportClasses.TargetSelectionGroup;
	import com.flexcapacitor.utils.supportClasses.log;
	import com.flexcapacitor.utils.supportClasses.logTarget;
	import com.jacobschatz.bk.utils.NumberUtil;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.core.BitmapAsset;
	import mx.core.DragSource;
	import mx.core.FlexGlobals;
	import mx.core.FlexSprite;
	import mx.core.IFactory;
	import mx.core.IFlexDisplayObject;
	import mx.core.IInvalidating;
	import mx.core.IUIComponent;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.Singleton;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.DragEvent;
	import mx.events.EffectEvent;
	import mx.events.SandboxMouseEvent;
	import mx.managers.DragManager;
	import mx.managers.ISystemManager;
	import mx.managers.PopUpManager;
	import mx.managers.SystemManager;
	import mx.managers.SystemManagerGlobals;
	import mx.managers.dragClasses.DragProxy;
	import mx.skins.ProgrammaticSkin;
	import mx.utils.NameUtil;
	import mx.utils.Platform;
	
	import spark.components.Application;
	import spark.components.Image;
	import spark.components.SkinnableContainer;
	import spark.components.supportClasses.GroupBase;
	import spark.components.supportClasses.InvalidatingSprite;
	import spark.components.supportClasses.ItemRenderer;
	import spark.components.supportClasses.Skin;
	import spark.core.IGraphicElement;
	import spark.effects.Animate;
	import spark.effects.Fade;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	import spark.effects.easing.IEaser;
	import spark.effects.easing.Power;
	import spark.filters.GlowFilter;
	import spark.layouts.BasicLayout;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.TileLayout;
	import spark.layouts.VerticalLayout;
	import spark.layouts.supportClasses.DropLocation;
	import spark.layouts.supportClasses.LayoutBase;
	import spark.primitives.Line;
	import spark.primitives.supportClasses.GraphicElement;
	import spark.skins.spark.ApplicationSkin;
	import spark.skins.spark.ImageSkin;
	import spark.skins.spark.ListDropIndicator;
	import spark.utils.BitmapUtil;
	
	import org.as3commons.lang.DictionaryUtils;
	
	use namespace mx_internal;
	
	/**
	 * Drag start 
	 * */
	[Event(name="dragStart", type="com.flexcapacitor.events.DragDropEvent")]
	
	/**
	 * Drag end
	 * */
	[Event(name="dragEnd", type="com.flexcapacitor.events.DragDropEvent")]

	/**
	 * Drag over 
	 * */
	[Event(name="dragOver", type="com.flexcapacitor.events.DragDropEvent")]

	/**
	 * Drop event 
	 * */
	[Event(name="dragDrop", type="com.flexcapacitor.events.DragDropEvent")]
	
	/**
	 * Drop complete event 
	 * */
	[Event(name="dragDropComplete", type="com.flexcapacitor.events.DragDropEvent")]
	
	/**
	 * Drop incomplete event. The user dragged but did not drop to anywhere successful 
	 * */
	[Event(name="dragDropIncomplete", type="com.flexcapacitor.events.DragDropEvent")]
	
	/**
	 * Enables drag and drop of UIComponent. 
	 * I don't know if this has a drag cancel event. 
	 * That is, if you don't find a place to drop then what happens? 
	 * Could listen for stage mouse up or mouse up outside. 
	 * 
	 * 
	 * This class is ancient. We need to eventually clean it up. 
	 * We might want to use displayObject.startDrag(), or objecthandles class
	 * instead or a combination of drag methods.
	 * Or better yet, rewrite the drag manager class.
	 * Move some of this code to the Selection class except if selection tool is not 
	 * selected. 
	 * */
	public class DragManagerUtil extends EventDispatcher {
		
		
		public function DragManagerUtil():void {
			if (_instance==null) _instance = this;
			else {
				throw new Error("Use getInstance()");
			}
		}
		
		public static var debug:Boolean;
		
		/**
		 * Used during drag and drop to indicate the target destination for the dragged element
		 * */
		public var dropIndicatorFactory:IFactory;
		
		/**
		 * Used during drag and drop to indicate the target destination for the dragged element
		 * */
		public var dropIndicatorInstance:DisplayObject;
		
		/**
		 * The distance of the mouse pointer location from the edge of the dragged element
		 * */
		private var offset:Point = new Point;
		
		[Bindable] 
		public var showSelectionBox:Boolean = false;
		public var showGroupDropZone:Boolean = true;
		public var showListDropIndicator:Boolean = false;
		public var showMousePositionLines:Boolean = false;
		public var showSelectionBoxOnApplication:Boolean;
		
		public var swfRoot:DisplayObject;
		public var dragProxy:DragProxy;
		public var dragManager:DragManager;
		public var scaleX:Number;
		public var scaleY:Number;
		
		/**
		 * Reference to the document
		 * */
		public var targetApplication:Application;
		
		public var selectionGroup:ItemRenderer = new TargetSelectionGroup();
		public var mouseLocationLines:IFlexDisplayObject = new ListDropIndicator();
		public var lastTargetCandidate:Object;
		public var dropTarget:Object;
		public var groupBase:GroupBase;
		public var dropLayout:LayoutBase;
		
		[Bindable] 
		public var dropTargetName:String;
		
		/**
		 * X and Y location of dragged object
		 * */
		public var dropTargetLocation:String;
		
		/**
		 * X and Y location of dragged object
		 * */
		public var dropLocationPoint:Point;
		
		public var startingPoint:Point;
		
		public var includeSkins:Boolean;
		
		/**
		 * Keep a reference to groups that have mouse enabled where transparent 
		 * and mouse handler support added when addGroupMouseSupport is called
		 * Stored so it can be removed with removeGroupMouseSupport
		 * */
		public var applicationGroups:Dictionary;
		
		/**
		 * How many pixels the mouse has to move before a drag operation is started
		 * */
		public var dragStartTolerance:int = 4;
		
		public var dragInitiator:IVisualElement;
		public var dragInitiatorProxy:Image;
		private var dropLocation:DropLocation;
		public var dragData:DragData;
		
		
		public var showDropIndicator:Boolean = true;
		public var showDropIndicatorInBasicLayout:Boolean = true;
		public var useImageForDropIndicator:Boolean;
		private var systemManager:Object;
		private var dragListener:DisplayObjectContainer;
		
		private var targetsUnderPoint:Array;
		public var adjustMouseOffset:Boolean = true;
		public var draggedItem:Object;
		private var topLevelApplication:Application;
		public var testScaledMovement:Boolean;
		public var isDragOutAllowed:Boolean;
		public var roundToIntegers:Boolean;
		
		public var hiddenItemsDictionary:Dictionary = new Dictionary(true);
		
		public var replaceImageGlow:GlowFilter = new GlowFilter(255, 1, 8, 8, 3, 3, false, false);
		public var replaceImageGlowApplied:Boolean;
		public var replaceableImage:Object;
		public var replaceableImageFilters:Array;
		
		/**
		 * Sets up a target to listen for drag like behavior. 
		 * There is a little bit of resistance before a drag is started. 
		 * This can be set in the dragStartTolerance
		 * @param dragInitiator the component that will be dragged
		 * @param parentApplication the application of the component being dragged
		 * @param event Mouse event from the mouse down event
		 * @param draggedItem The item or data to be dragged. If null then this is the dragInitiator.
		 * */
		public function listenForDragBehavior(dragInitiatorReference:IVisualElement, document:IDocument, event:MouseEvent, itemToDrag:Object = null, dragOutAllowed:Boolean = true):void {
			var attemptToFixHiddenElements:Boolean;
			var topSystemManager:SystemManager;
			var systemManager:ISystemManager;
			var marshallPlanSystemManager:Object;
			var targetCoordinateSpace:DisplayObject;
			
			if (debug) {
				log();
			}
			
			attemptToFixHiddenElements = true;
			
			topSystemManager = SystemManagerGlobals.topLevelSystemManagers[0];
			
			dragInitiator = dragInitiatorReference;
			targetApplication = Application(document.instance);
			
			destroySnapPointsCache();
			systemManager = targetApplication.systemManager;
			topLevelApplication = Application(FlexGlobals.topLevelApplication);
			startingPoint = new Point();
			
			//componentTree = DisplayObjectUtils.getComponentDisplayList(documentApplication);
			componentTree = document.componentDescription;
			
			// either the component to add or the component to move
			if (arguments[3]) {
				draggedItem = itemToDrag;
			}
			else {
				draggedItem = dragInitiator;
			}
			
			isDragOutAllowed = dragOutAllowed;
			
			if (debug) {
				logTarget(draggedItem, "is dragged item");
			}
			
			// if selection is offset then check if using system manager sandbox root or top level root
			systemManager = ISystemManager(topLevelApplication.systemManager);
			
			// no types so no dependencies
			marshallPlanSystemManager = systemManager.getImplementation("mx.managers.IMarshallPlanSystemManager");
			
			if (marshallPlanSystemManager && marshallPlanSystemManager.useSWFBridge()) {
				targetCoordinateSpace = Sprite(systemManager.getSandboxRoot());
			}
			else {
				targetCoordinateSpace = Sprite(topLevelApplication);
			}
			
			if (attemptToFixHiddenElements) {
				swfRoot = topLevelApplication.systemManager.stage;
			}
			else {
				swfRoot = targetCoordinateSpace;
			}
			
			startingPoint.x = event.stageX;
			startingPoint.y = event.stageY;
			
			
			//updateDropTargetLocation(targetApplication, event);
			
			// we shouldn't be listening on components but instead the stage
			
			if (attemptToFixHiddenElements) {
				swfRoot.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			}
			else {
				if (dragInitiator is IUIComponent) {
					dragInitiator.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
				}
				else if (dragInitiator is IGraphicElement) {
					GraphicElement(dragInitiator).displayObject.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
					//GraphicElement(dragInitiator).addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
					swfRoot.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
					
					//topSystemManager.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpSomewhereHandler);
					//topSystemManager.stage.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpSomewhereHandler);
				}
			}
			
			swfRoot.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			//swfRoot.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
			swfRoot.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpSomewhereHandler);
			// let's add this so we can be sure to unhide all the display objects that we hid
			// but set priority low so everything else runs first
			swfRoot.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandlerUnhideObjects, false, -10, true);
			//swfRoot.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpSomewhereHandler, true);
		}
		
		protected function mouseUpHandlerUnhideObjects(event:Event):void {
			if (debug) {
				logTarget(event.currentTarget);
			}
			swfRoot.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandlerUnhideObjects);
			restoreHiddenItems();
		}
		
		protected function mouseUpSomewhereHandler(event:Event):void {
			if (debug) {
				logTarget(event.currentTarget);
			}
			
			// sometimes elements disappear because mouse coordinates are off somewhere
			// try and catch those cases and show components that were hidden
			restoreHiddenItems();
			removeDragInitiatorProxy();
		}
		
		/**
		 * Updates the drop target location property with the x and y values of the dragged item.
		 * Format is "XxY", so for example, "100x50".
		 * */
		private function updateDropLocation():void {
			var dropX:Number;
			var dropY:Number;
			var out:String;
			var dropPoint:Point;
			var scaleX:Number;
			
			scaleX = targetApplication.scaleX;
			
			if (dropLocation!=null) {
			
				dropPoint = dropLocation.dropPoint;
				
				// on desktop drag proxy is null
				if (dragProxy==null) {
					if (scaleX<1) {
						dropX = dropPoint.x-offset.x/scaleX;
						dropY = dropPoint.y-offset.y/scaleX;
					}
					else if (scaleX>1) {
						dropX = dropPoint.x-offset.x/scaleX;
						dropY = dropPoint.y-offset.y/scaleX;
					}
					else {
						dropX = dropPoint.x - offset.x;
						dropY = dropPoint.y - offset.y;
					}
				}
				else {
					if (scaleX<1) {
						dropX = dropPoint.x-dragProxy.xOffset/scaleX;
						dropY = dropPoint.y-dragProxy.yOffset/scaleX;
					}
					else if (scaleX>1) {
						dropX = dropPoint.x-dragProxy.xOffset/scaleX;
						dropY = dropPoint.y-dragProxy.yOffset/scaleX;
					}
					else {
						dropX = dropPoint.x - dragProxy.xOffset;
						dropY = dropPoint.y - dragProxy.yOffset;
					}
				}
			}
			else {
				dropX = 0;
				dropY = 0;
			}
			
			if (dropLocationPoint==null) {
				dropLocationPoint = new Point();
			}
			
			if (roundToIntegers) {
				dropLocationPoint.x = Math.round(dropX);
				dropLocationPoint.y = Math.round(dropY);
			}
			else {
				dropLocationPoint.x = NumberUtils.toDecimalPoint(dropX);
				dropLocationPoint.y = NumberUtils.toDecimalPoint(dropY);
			}
				
			out = dropLocationPoint.x + "x" + dropLocationPoint.y;
			
			if (dropTargetLocation!=out) {
				dropTargetLocation = out;
			}
		}
		
		/**
		 * Updates the drop target location property with the x and y values of the dragged item.
		 * Format is "XxY", so for example, "100x50".
		 * */
		private function updateDropTargetLocation(rootDisplayObject:DisplayObject, event:MouseEvent):void {
			var mousePoint:Point = new Point(event.stageX, event.stageY);
			//var applicationLocationPoint:Point = DisplayObjectUtils.getDisplayObjectPosition(targetApplication, mousePoint);
			var applicationLocationPoint:Point = DisplayObject(rootDisplayObject).localToGlobal(new Point());
			
			//var point2:Point = new Point(-event.stageX, -event.stageY);
			//var newPoint:Point = DisplayObject(rootDisplayObject).localToGlobal(mousePoint);
			//var newPoint1:Point = DisplayObject(rootDisplayObject).localToGlobal(point2);
			
			// this one works 
			//var newPoint3:Point = DisplayObject(rootDisplayObject).globalToLocal(mousePoint);
			//var newPoint4:Point = DisplayObject(rootDisplayObject).globalToLocal(point2);
			var applicationScaleX:Number = rootDisplayObject.scaleX;
			var applicationScaleY:Number = rootDisplayObject.scaleY;
			var newX:Number = mousePoint.x - applicationLocationPoint.x - offset.x*applicationScaleX;
			var newY:Number = mousePoint.y - applicationLocationPoint.y - offset.y*applicationScaleY;
			//var newX2:Number = targetApplication.contentMouseX - offset.x;
			//var newY2:Number = targetApplication.contentMouseY - offset.y;
			
			//newX = NumberUtils.toDecimalPoint(newX*applicationScaleX);
			//newY = NumberUtils.toDecimalPoint(newY*applicationScaleY);
			
			
			if (dropLocationPoint==null) {
				dropLocationPoint = new Point();
			}
			
			dropLocationPoint.x = NumberUtils.toDecimalPoint(newX);
			dropLocationPoint.y = NumberUtils.toDecimalPoint(newY);
			
			var out:String = dropLocationPoint.x + "x" + dropLocationPoint.y;
			// Find the registration point of the owner
			/*var sandboxRoot:DisplayObject = systemManager.getSandboxRoot();
			var regPoint:Point = owner.localToGlobal(new Point());
			regPoint = sandboxRoot.globalToLocal(regPoint);*/
			//var regPoint:Point = rootDisplayObject.localToGlobal(new Point());
			//regPoint = rootDisplayObject.globalToLocal(regPoint);
			
			if (dropTargetLocation!=out) {
				dropTargetLocation = out;
			}
		}
		
		/**
		 * Mouse move handler that listens to see if the mouse has moved past the drag tolerance amount.
		 * If the mouse has moved past the drag tolerance then dragging is started.
		 * */
		protected function mouseMoveHandler(event:MouseEvent):void {
			var dragToleranceMet:Boolean;
			if (debug) {
				logTarget(event.currentTarget);
			}
			
			// this value is sometimes much higher. this may be what's contributing to 
			// graphic element counting as a mouse move but not really a mouse move because no event up. 
			dragToleranceMet = Math.abs(startingPoint.x - event.stageX) >= dragStartTolerance;
			dragToleranceMet = !dragToleranceMet ? Math.abs(startingPoint.y - event.stageY)  >= dragStartTolerance: true;
			
			//updateDropTargetLocation(targetApplication, event);
			
			if (dragToleranceMet) {
				
				if (hideDragInitiatorOnDrag) {
					addToHiddenItemsDictionary(dragInitiator);
				}
				
				removeMouseHandlers(dragInitiator);
				
				if (dragInitiator==null && event.currentTarget) {
					removeMouseHandlers(event.currentTarget);
					restoreHiddenItems();
					return;
				}
				
				if (dragInitiator is IGraphicElement) {
					var useLocalSpaceForGraphicElement:Boolean = true;
					dragInitiatorProxy = DisplayObjectUtils.duplicateIntoImage(dragInitiator as GraphicElement, true, 0xFFFFFF, useLocalSpaceForGraphicElement);
					
					if (Platform.isAir) {
						dragInitiatorProxy.width = dragInitiatorProxy.width*targetApplication.scaleX;
						dragInitiatorProxy.height = dragInitiatorProxy.height*targetApplication.scaleY;
						dragInitiatorProxy.validateNow();
					}
					
					startDrag(dragInitiatorProxy as IUIComponent, targetApplication, event);
					dragInitiatorProxy.alpha = 0;
				}
				else {
					dragInitiatorProxy = null;
					startDrag(dragInitiator as IUIComponent, targetApplication, event);
				}
			}
			
		}
		
		public static var testSomething:Boolean;
		
		public var imageAlpha:Number = .9;
		
		/**
		 * Helps highlights items that are locked
		 * */
		public var layoutDebugHelper:LayoutDebugHelper;
		
		public var snapshot:BitmapAsset;
		
		/**
		 * Start dragging
		 * */
		public function startDrag(dragInitiator:IUIComponent, application:Application, event:MouseEvent):void {
			var dragSource:DragSource = new DragSource();
			var scaleOffsetPoint:Point;
			
			if (debug) {
				log(" current target: " + event.currentTarget);
			}
			
			destroySnapPointsCache();
			
			this.dragInitiator = dragInitiator as IVisualElement;
			this.targetApplication = application;
			this.systemManager = application.systemManager;
			
			// set the object that will listen for drag events
			dragListener = DisplayObjectContainer(application);
			distanceFromLeft = dragInitiator.localToGlobal(new Point).x;
			distanceFromTop = dragInitiator.localToGlobal(new Point).y;
			
			// Flex coordinate systems
			// http://help.adobe.com/en_US/flex/using/WS2db454920e96a9e51e63e3d11c0bf69084-7de0.html
			scaleX = application.scaleX;
			scaleY = application.scaleY;
			
			scaleOffsetPoint = new Point();
			
			// store distance of mouse point to top left of display object
			if (scaleX!=1 && !isNaN(scaleX)) {
				offset.x = event.stageX - distanceFromLeft;// * scale;
				offset.y = event.stageY - distanceFromTop;// * scale;
			}
			else {
				offset.x = event.stageX - distanceFromLeft;
				offset.y = event.stageY - distanceFromTop;
			}
			
			//updateDropTargetLocation(targetApplication, event);
			
			addGroupListeners(application);
			
			if (dragInitiatorProxy) {
				addDragListeners(dragInitiatorProxy, dragListener);
			}
			else {
				addDragListeners(dragInitiator, dragListener);
			}
			
			// creates an instance of the bounding box that will be shown around the drop target
			if (!selectionGroup) {
				selectionGroup = new TargetSelectionGroup();
				selectionGroup.mouseEnabled = false;
				selectionGroup.mouseChildren = false;
			}
			
			// hide any locked outline 
			if (layoutDebugHelper==null) {
				layoutDebugHelper = LayoutDebugHelper.getInstance();
			}
			
			layoutDebugHelper.clear();
			
			// show selection / bounding box 
			// we should be drawing this with the drop indicator not adding as a pop up
			if (showSelectionBox) {
				// RangeError: Error #2006: The supplied index is out of bounds.
				PopUpManager.addPopUp(selectionGroup, swfRoot);
				selectionGroup.visible = false;
				//selectionGroup.addEventListener(DragEvent.DRAG_OVER, dragOverHandler);
			}
			
			// show mouse location lines
			if (showListDropIndicator && mouseLocationLines) {
				PopUpManager.addPopUp(mouseLocationLines, swfRoot);
				mouseLocationLines.visible = false;
			}
			
			// SecurityError: Error #2123: Security sandbox violation: 
			//BitmapData.draw: http://www.radii8.com/debug-build/RadiateExample.swf cannot access http://www.google.com/intl/en_com/images/srpr/logo3w.png. No policy files granted access.
			if (dragInitiator is Image && !Image(dragInitiator).trustedSource) {
				snapshot = null;
			}
			else {
				// i think this is causing some resizing of images problems when zoomed out during drag and drop 
				// update: may have been caused by embedding image - that converts bitmap to base64 
				// which may update source bitmapData
				if (scaleX!=1 && false) {
					var tempScale:Number = dragInitiator.scaleX;
					dragInitiator.scaleX = scaleX;
					dragInitiator.scaleY = scaleX;
					Object(dragInitiator).validateNow();
				}
				
				if (Platform.isAir) {
					testSomething = true;
					
					//if (scaleOffsetPoint.x>dragInitiator.width && "mouseX" in dragInitiator) {
					if ("mouseX" in dragInitiator) {
						scaleOffsetPoint.x = dragInitiator.mouseX-dragInitiator.mouseX*scaleX;
						scaleOffsetPoint.y = dragInitiator.mouseY-dragInitiator.mouseY*scaleY;
					}
					else {
						scaleOffsetPoint.x = event.localX-event.localX*scaleX;
						scaleOffsetPoint.y = event.localY-event.localY*scaleY;
					}
				}
				
				if (testSomething) {
					
					if (dragInitiatorProxy) {
						
						if (draggedItem is GraphicElement && Platform.isAir) {
							// graphic element proxy is already scaled in desktop
							snapshot = DisplayObjectUtils.getBitmapAssetSnapshot2(dragInitiatorProxy as DisplayObject, true, 1, 1);
						}
						else {
							snapshot = DisplayObjectUtils.getBitmapAssetSnapshot2(dragInitiatorProxy as DisplayObject, true, scaleX, scaleX);
						}
					}
					else {
						//snapshot = DisplayObjectUtils.getBitmapAssetSnapshot2(dragInitiator as DisplayObject, true, scaleX, scaleX);
						var bitmapData:BitmapData = BitmapUtil.getSnapshotWithPadding(dragInitiator as IUIComponent, 0);
						snapshot = new BitmapAsset(bitmapData);
					}
				}
				else {
					if (dragInitiatorProxy) {
						snapshot = DisplayObjectUtils.getBitmapAssetSnapshot2(dragInitiatorProxy as DisplayObject);
					}
					else {
						snapshot = DisplayObjectUtils.getBitmapAssetSnapshot2(dragInitiator as DisplayObject);
					}
				}
				
				//removeDragInitiatorProxy();
				
				//snapshot = DisplayObjectUtils.getSpriteSnapshot(dragInitiator as DisplayObject);
				//DisplayObjectUtils.scaleDisplayObject(targetApplication as DisplayObject, snapshot, "stretch");
				/*
				if (scale!=1) {
					dragInitiator.scaleX = tempScale;
					dragInitiator.scaleY = tempScale;
				}*/
			}
			
			
			if (testScaledMovement) {
				snapshot = null;
			}
			
			addDropShadow = false;
			// check if any component has mask and don't add drop shadow
			if (addDropShadow && snapshot) {
				snapshot.filters = [dropShadowFilter];
			}
			
			dragSource.addData(draggedItem, "UIComponent");
			
			
			if (setDragManagerOffset) {
				DragManager.doDrag(dragInitiator, dragSource, event, snapshot, -offset.x, -offset.y, imageAlpha);
				
				//var icon:Sprite = getDragIcon();
				
			}
			else {
				
				if (Platform.isAir) {
					// native drag manager may use drag proxy if dragImage (snapshot) is UIComponent 
					DragManager.doDrag(dragInitiator, dragSource, event, snapshot, scaleOffsetPoint.x, scaleOffsetPoint.y, imageAlpha);
				}
				else {
					DragManager.doDrag(dragInitiator, dragSource, event, snapshot, 0, 0, imageAlpha);
				}
				
				//icon = getDragIcon();
				
				// error when snapshot is null and running on desktop: 
				// 
				// TypeError: Error #1009: Cannot access a property or method of a null object reference.
				//	at mx.managers::NativeDragManagerImpl/doDrag()[E:\dev\4.y\frameworks\projects\airframework\src\mx\managers\NativeDragManagerImpl.as:318]
				//		at mx.managers::DragManager$/doDrag
				// Lines from NativeDragManager: 
				//   var dragManagerStyleDeclaration:CSSStyleDeclaration = getStyleManager(dragInitiator).getStyleDeclaration("mx.managers.DragManager");
				//   var dragImageClass:Class = dragManagerStyleDeclaration.getStyle("defaultDragImageSkin");
				//   - dragManagerStyleDeclaration is null 
				// 
				// drag icon style (copy or move) was set to ClassReference(null);
			}
			
			if (dragManager==null) {
				//dragManager = Singleton.getInstance("mx.managers::IDragManager");
			}
			
			//dragManagerImplementation = Singleton.getClass("mx.managers::IDragManager");
			//var dragManagerImplementation:Object = mx.managers.DragManagerImpl.getInstance();
			var dragManagerImplementation:Object;
			dragManagerImplementation = Singleton.getClass("mx.managers::IDragManager").getInstance();
			dragProxy = dragManagerImplementation.dragProxy;
			//dragProxy = DragManager::mx_internal.getDragProxy(); //throws error below???
			// TypeError: Error #1034: Type Coercion failed: cannot convert mx.managers::DragManager$ to Namespace.
			//removeDragInitiatorProxy();
			
			dragging = true;
			dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_START));
		}
		
		// attempt to find the dragged image but it might be passed to the OS so we 
		// can't get it after the fact
		// on native it is passed to the OS
		// on drag manager it is DragProxy
		// this is outdated though so remove
		private function getDragIcon():Sprite
		{
			var modalWindow:FlexSprite;
			if (systemManager==null) {
				systemManager = SystemManager.getSWFRoot(FlexGlobals.topLevelApplication);
			}
			var numOfChildren:int = systemManager.rawChildren.numChildren;
			var sprite:Sprite;
			
			for (var i:int = 0; i < numOfChildren; i++) 
			{
				sprite = systemManager.rawChildren.getChildAt(i);
				sprite.scaleX = targetApplication.scaleX;
				sprite.scaleY = targetApplication.scaleY;
				//modalWindow = systemManager.rawChildren.getChildAt(index-1) as FlexSprite;
				
				if (modalWindow) {
					modalWindow.blendMode = BlendMode.NORMAL;
					//modalWindow.addEventListener(MouseEvent.CLICK, mouseUpOutsideHandler, false, 0, true);
				}
			}
			
			
			return modalWindow;
		}
		
		public function removeDragInitiatorProxy():void {
			
			if (debug) {
				logTarget(dragInitiatorProxy);
			}
			
			if (dragInitiatorProxy) {
				//CallLaterUtil.callLater(removeDragInitiator, dragInitiatorProxy);
				// called when rasterizing things like graphic elements into temporary images
				removeDragInitiator(dragInitiatorProxy);
			}
		}
		
		public function removeDragInitiator(dragInitiatorObject:Object = null):void{
			
			if (dragInitiatorObject && dragInitiatorObject.owner) {
				if (dragInitiatorObject.owner is IVisualElementContainer) {
					IVisualElementContainer(dragInitiatorObject.owner).removeElement(dragInitiatorObject as IVisualElement);
				}
				else if (dragInitiatorObject.owner is DisplayObjectContainer) {
					DisplayObjectContainer(dragInitiatorObject.owner).removeChild(dragInitiatorObject as DisplayObject);
				}
			}
		}
		
		private function dragEnterHandler(event:DragEvent):void {
			if (debug) {
				log(" current target: " + ClassUtils.getClassName(event.currentTarget));
			}
			
			DragManager.acceptDragDrop(event.target as IUIComponent);
			//trace("Drag Enter:" + event.target);
		}
		
		protected function dragExitHandler(event:DragEvent):void {
			if (debug) {
				log();
			}
			
			//destroyDropIndicator();
			//trace("Drag Exit:" + event.target);
		}
		
		/**
		 * Dispatched during a drag over event. Dispatched multiple times. 
		 * */
		protected function dragOverHandler(event:DragEvent):void {
			if (debug) {
				log(" current target: " + ClassUtils.getClassName(event.currentTarget));
			}
			
			var eventTarget:FlexSprite;
			//var description:ComponentDescription;
			var topLeftEdgePoint:Point;
			var rectangle:Rectangle;
			var isHorizontal:Boolean;
			var isApplication:Boolean;
			var isVertical:Boolean;
			var isBasic:Boolean;
			var isTile:Boolean;
			var target:Object;
			var replaceTarget:Boolean;
			
			eventTarget = FlexSprite(event.target);
			
			dragData = findDropTarget(event, true, targetApplication.scaleX);
			
			if (dragData==null) {
				if (debug) {
					logTarget(event.currentTarget, " Drop target not found");
				}
				return;
			}
			
			
			dropTarget 		= dragData.target;
			isApplication 	= dragData.isApplication;
			isTile 			= dragData.isTile;
			isVertical 		= dragData.isVertical;
			isBasic 		= dragData.isBasicLayout;
			isHorizontal 	= dragData.isHorizontal;
			dropLocation 	= dragData.dropLocation;
			dropLayout 		= dragData.layout;
			replaceTarget 	= dragData.replaceTarget;
			
			
			// adds a glow filter or selection around a replaceable drop target ie an image
			if (replaceTarget) {
				
				if (dropTarget.filters) {
					if (dropTarget.filters.indexOf(replaceImageGlow)==-1) {
						replaceableImageFilters = dropTarget.filters;
						replaceableImageFilters.push(replaceImageGlow);
						dropTarget.filters = replaceableImageFilters;
					}
				}
				else {
					dropTarget.filters = [replaceImageGlow];
				}
				
				replaceImageGlowApplied = true;
				replaceableImage = dropTarget;
			}
			else {
				if (replaceImageGlowApplied && replaceableImage && replaceableImage.filters) {
					replaceImageFilterIndex = replaceableImage.filters.indexOf(replaceImageGlow);
					if (replaceImageFilterIndex!=-1) {
						replaceableImageFilters = dropTarget.filters;
						(replaceableImage.filters as Array).splice(replaceImageFilterIndex, 1);
						replaceableImage.filters = replaceableImageFilters;
					}
					replaceImageGlowApplied = false;
					replaceableImage = null;
				}
			}
			
			////////////////////////////////////////////////////////////
			// show selection box
			////////////////////////////////////////////////////////////
			if (showSelectionBox) {
				
				// get bounds
				if (!dropTarget || 
					(isApplication && !showSelectionBoxOnApplication)) {
					
					// set values to zero
					if (!rectangle) {
						rectangle = new Rectangle();
					}
					
					// hide selection group
					if (selectionGroup.visible) {
						selectionGroup.visible = false;
						//selectionGroup.x = rectangle.x;
						//selectionGroup.y = rectangle.y;
					}
					selectionGroup.width = 0;
					selectionGroup.height = 0;
				}
				else {
					
					// draw the selection rectangle only if it's changed
					//if (lastTargetCandidate!=dropTarget) {
						
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
						
						// SHOULD be using GroupBase.LayoutBase to get bounds of elements
						// get target bounds
						rectangle = DisplayObject(dropTarget).getBounds(targetCoordinateSpace);
						
						// size and position fill
						selectionGroup.width = rectangle.width;
						selectionGroup.height = rectangle.height;
						selectionGroup.x = rectangle.x;
						selectionGroup.y = rectangle.y;
						
						// show target selection group
						if (!selectionGroup.visible) {
							selectionGroup.visible = true;
						}
						
						selectionGroup.data = dropTarget;
					//}
					
				}
				
			}
			
			
			
			////////////////////////////////////////////////////////////
			// show drop indicator
			////////////////////////////////////////////////////////////
			if (showDropIndicator) {
				
				// remove previous drop indicator
				if (lastTargetCandidate && 
					lastTargetCandidate!=dropTarget && 
					lastTargetCandidate is IVisualElementContainer) {
					
					// hide drop indicator
					lastTargetCandidate.layout.hideDropIndicator();
					
					// Hide focus
					//targetGroup.drawFocus(false);
					//targetGroup.drawFocusAnyway = false;
					
					// Destroy the dropIndicator instance
					destroyDropIndicator();
				}
				
				// if drop indicator is needed
				if (isHorizontal || isVertical || isTile || (isBasic && showDropIndicatorInBasicLayout)) {
					// get drop indicator location
					//dropLocation = targetGroupLayout.calculateDropLocation(event);
					
					if (dropLocation) {
						//DragManager.acceptDragDrop(parentApplication);
						DragManager.acceptDragDrop(targetApplication);
						
						// Show focus
						//drawFocusAnyway = true;
						//targetGroup.drawFocus(true);
						
						// Notify manager we can drop
						DragManager.showFeedback(event.ctrlKey ? DragManager.COPY : DragManager.MOVE);
						
						/*
						TypeError: Error #1007: Instantiation attempted on a non-constructor.
						at mx.managers::CursorManagerImpl/showCurrentCursor()[/Users/justinmclean/Documents/ApacheFlex4.16/frameworks/projects/framework/src/mx/managers/CursorManagerImpl.as:621]
						at mx.managers::CursorManagerImpl/setCursor()[/Users/justinmclean/Documents/ApacheFlex4.16/frameworks/projects/framework/src/mx/managers/CursorManagerImpl.as:452]
						at mx.managers.dragClasses::DragProxy/showFeedback()[/Users/justinmclean/Documents/ApacheFlex4.16/frameworks/projects/framework/src/mx/managers/dragClasses/DragProxy.as:264]
						at mx.managers.dragClasses::DragProxy/mouseMoveHandler()[/Users/justinmclean/Documents/ApacheFlex4.16/frameworks/projects/framework/src/mx/managers/dragClasses/DragProxy.as:553]
						TypeError: Error #1007: Instantiation attempted on a non-constructor.
						TypeError: Error #1007: Instantiation attempted on a non-constructor.
						TypeError: Error #1007: Instantiation attempted on a non-constructor.
						at mx.managers::CursorManagerImpl/showCurrentCursor()[/Users/justinmclean/Documents/ApacheFlex4.16/frameworks/projects/framework/src/mx/managers/CursorManagerImpl.as:621]
						at mx.managers::CursorManagerImpl/setCursor()[/Users/justinmclean/Documents/ApacheFlex4.16/frameworks/projects/framework/src/mx/managers/CursorManagerImpl.as:452]
						at mx.managers.dragClasses::DragProxy/showFeedback()[/Users/justinmclean/Documents/ApacheFlex4.16/frameworks/projects/framework/src/mx/managers/dragClasses/DragProxy.as:264]
						at mx.managers.dragClasses::DragProxy/mouseMoveHandler()[/Users/justinmclean/Documents/ApacheFlex4.16/frameworks/projects/framework/src/mx/managers/dragClasses/DragProxy.as:553]
						TypeError: Error #1007: Instantiation attempted on a non-constructor.
						TypeError: Error #1007: Instantiation attempted on a non-constructor.
						
						we had cleared the cursor in CSS using classReference(null) so it was not finding it
						*/
						
						// Show drop indicator
						// if you drag too fast with a graphic element it creates an error in VerticalLayout line 2281
						//             emptySpaceTop = (dropIndex < count) ? getElementBounds(dropIndex).top - emptySpace :
						// TypeError: Error #1009: Cannot access a property or method of a null object reference.
						try {
							
							var currentX:int;
							var currentY:int;
							var currentRight:int;
							var currentBottom:int;
							var currentHorizontalCenter:int;
							var currentVerticalCenter:int;
							var hasLeftSnapEdge:Boolean;
							var hasTopSnapEdge:Boolean;
							var hasBottomSnapEdge:Boolean;
							var hasRightSnapEdge:Boolean;
							var hasHorizontalSnapEdge:Boolean;
							var hasVerticalSnapEdge:Boolean;
							var snapPoints:SnapPoints;
							
							
							// Create the dropIndicator instance. The layout will take care of
							// parenting, sizing, positioning and validating the dropIndicator.
							currentX = dropLocation.dropPoint.x - (offset.x/scaleX);
							currentY = dropLocation.dropPoint.y - (offset.y/scaleY);
							currentRight = dropLocation.dropPoint.x + draggedItem.width - (offset.x/scaleX);
							currentBottom = dropLocation.dropPoint.y + draggedItem.height - (offset.y/scaleY);
							
							currentHorizontalCenter = dropLocation.dropPoint.x + draggedItem.width/2 - (offset.x/scaleX);
							currentVerticalCenter = dropLocation.dropPoint.y + draggedItem.height/2 - (offset.y/scaleY);
							
							// this could be more optimized. 
							// we should probably assign the drop indicator when creating groups based on basic layout
							if (isBasic) {
								var skipOwner:Boolean = true;
								
								if (snapToNearbyElements && !event.altKey) {
									snapPoints = getSnapPoints(dropLayout.target, draggedItem, skipOwner);
									
									if (useImageForDropIndicator) {
										dropLayout.dropIndicator = DisplayObjectUtils.getBitmapAssetSnapshot2(draggedItem as DisplayObject, true);
										dropLayout.dropIndicator.width = draggedItem.width;
										dropLayout.dropIndicator.height = draggedItem.height;
										dropLayout.dropIndicator.visible = true;
										dropLayout.dropIndicator.x = dropLocation.dropPoint.x - (offset.x/scaleX);
										dropLayout.dropIndicator.y = 0;// dropLocation.dropPoint.y - (offset.y/scaleY);
									}
									else {
										if (dropLayout.dropIndicator==null || dropLayout.dropIndicator!=dropIndicatorInstance) { 
											dropLayout.dropIndicator = createBasicLayoutDropIndicator(dropLayout.target);
										}
									}
									
									// if its not a number we set the threshold too large so we skip it later on
									
									// left edge
									snapX = NumberUtil.snapToInArray(currentX, snapPoints.left);
									leftDifference = isNaN(snapX) ? snapThreshold+1 : Math.abs(snapX-currentX);
									
									// horizontal center edge
									snapHorizontalCenter = NumberUtil.snapToInArray(currentHorizontalCenter, snapPoints.horizontalCenter);
									horizontalDifference = isNaN(snapHorizontalCenter) ? snapThreshold+1 : Math.abs(snapHorizontalCenter-currentHorizontalCenter);
									
									// right edge
									snapRight = NumberUtil.snapToInArray(currentRight, snapPoints.right);
									rightDifference = isNaN(snapRight) ? snapThreshold+1 : Math.abs(snapRight-currentRight);
									
									// top edge
									snapY = NumberUtil.snapToInArray(currentY, snapPoints.top);
									topDifference = isNaN(snapY) ? snapThreshold+1 : Math.abs(snapY-currentY);
									
									// vertical center 
									snapVerticalCenter = NumberUtil.snapToInArray(currentVerticalCenter, snapPoints.verticalCenter);
									verticalDifference = isNaN(snapVerticalCenter) ? snapThreshold+1 : Math.abs(snapVerticalCenter-currentVerticalCenter);
									
									// bottom edge
									snapBottom = NumberUtil.snapToInArray(currentBottom, snapPoints.bottom);
									bottomDifference = isNaN(snapBottom) ? snapThreshold+1 : Math.abs(snapBottom-currentBottom);
									
									if (leftDifference<=snapThreshold) {
										hasLeftSnapEdge = true;
										//trace("snapx found =" + snapX);
									}
									else {
										snapX = NaN;
									}
									
									if (horizontalDifference<=snapThreshold) {
										hasHorizontalSnapEdge = true;
										//trace("snapping to=" + snapX);
									}
									else {
										snapHorizontalCenter = NaN;
									}
									
									if (rightDifference<=snapThreshold) {
										hasRightSnapEdge = true;
										//trace("snapping to=" + snapX);
									}
									else {
										snapRight = NaN;
									}
									
									if (topDifference<=snapThreshold) {
										hasTopSnapEdge = true;
										//trace("snapy found =" + snapY);
									}
									else {
										snapY = NaN;
									}
									
									if (verticalDifference<=snapThreshold) {
										hasVerticalSnapEdge = true;
										//trace("snapx found =" + snapX);
									}
									else {
										snapVerticalCenter = NaN;
									}
									
									if (bottomDifference<=snapThreshold) {
										hasBottomSnapEdge = true;
										//trace("snapping to=" + snapX);
									}
									else {
										snapBottom = NaN;
									}
									
									if (hasLeftSnapEdge || hasTopSnapEdge || hasRightSnapEdge || hasBottomSnapEdge
										|| hasVerticalSnapEdge || hasHorizontalSnapEdge) {
										
										SnapToElementDropIndicator(dropLayout.dropIndicator).setLines(snapX, snapY, snapRight, snapBottom, snapHorizontalCenter, snapVerticalCenter);
										
										if (isApplication) {
											SnapToElementDropIndicator(dropLayout.dropIndicator).showFill = showSelectionBoxOnApplication && showGroupDropZone;
										}
										else {
											SnapToElementDropIndicator(dropLayout.dropIndicator).showFill = showGroupDropZone;
										}
										//dropLayout.showDropIndicator(dropLocation.dropPoint);
										dropLayout.dropIndicator.visible = true;
										
										if (dropLayout.dropIndicator is ProgrammaticSkin) {
											//SnapToElementDropIndicator(dropLayout.dropIndicator).updateSize();
											ProgrammaticSkin(dropLayout.dropIndicator).invalidateSize();
											ProgrammaticSkin(dropLayout.dropIndicator).invalidateDisplayList();
										}
									}
									else {
										
										if (showGroupDropZone && dropLayout.dropIndicator is ProgrammaticSkin) {
											SnapToElementDropIndicator(dropLayout.dropIndicator).setLines(NaN, NaN);
											
											if (isApplication) {
												SnapToElementDropIndicator(dropLayout.dropIndicator).showFill = showSelectionBoxOnApplication && showGroupDropZone;
											}
											else {
												SnapToElementDropIndicator(dropLayout.dropIndicator).showFill = showGroupDropZone;
											}
											dropLayout.dropIndicator.visible = true;
											
											ProgrammaticSkin(dropLayout.dropIndicator).invalidateDisplayList();
										}
										else {
											dropLayout.hideDropIndicator();
										}
									}
								}
								else {
									snapX = NaN;
									snapY = NaN;
									snapRight = NaN;
									snapBottom = NaN;
									snapHorizontalCenter= NaN;
									snapVerticalCenter= NaN;
									
									if (showGroupDropZone && dropLayout.dropIndicator is ProgrammaticSkin) {
										SnapToElementDropIndicator(dropLayout.dropIndicator).setLines(NaN, NaN);
										
										if (isApplication) {
											SnapToElementDropIndicator(dropLayout.dropIndicator).showFill = showSelectionBoxOnApplication && showGroupDropZone;
										}
										else {
											SnapToElementDropIndicator(dropLayout.dropIndicator).showFill = showGroupDropZone;
										}
										dropLayout.dropIndicator.visible = true;
										
										ProgrammaticSkin(dropLayout.dropIndicator).invalidateDisplayList();
									}
									else {
										dropLayout.hideDropIndicator();
									}
								}
								
								//trace("x:" + dropLocation.dropPoint.x);
								//trace("w:" + dropLayout.dropIndicator.width);
								//trace("h:" + dropLayout.dropIndicator.height);
							}
							else {
								
								// Create the dropIndicator instance. The layout will take care of
								// parenting, sizing, positioning and validating the dropIndicator.
								
								if (dropLayout.dropIndicator==null || dropLayout.dropIndicator!=dropIndicatorInstance) {
									dropLayout.dropIndicator = createDropIndicator();
								}
								
								dropLayout.showDropIndicator(dropLocation);
							}
						}
						catch (e:Error) {
							
						}
					}
					else {
						// drop location is null
						// hide drop indicator
						DragManager.showFeedback(DragManager.NONE);
						
						// hide drop indicator
						dropLayout.hideDropIndicator();
						
						// Hide focus
						//targetGroup.drawFocus(false);
						//targetGroup.drawFocusAnyway = false;
						
						// Destroy the dropIndicator instance
						destroyDropIndicator();
					}
					
				}
					// target group is basic layout
					// does not need drop indicator
				else if (dropLayout) {
					if (lastTargetCandidate && "layout" in lastTargetCandidate) {
						lastTargetCandidate.layout.hideDropIndicator();
					}
					
					// Hide if previously showing
					dropLayout.hideDropIndicator();
					
					// Hide focus
					//targetGroup.drawFocus(false);
					//targetGroup.drawFocusAnyway = false;
					
					// Destroy the dropIndicator instance
					destroyDropIndicator();
				}
				
			}
			
			// store the last target
			lastTargetCandidate = dropTarget;
			
			dropTargetName = NameUtil.getUnqualifiedClassName(dropTarget);
			
			event.updateAfterEvent();
			
			if (!hasLeftSnapEdge && !hasRightSnapEdge) {
				
				if (roundToIntegers) {
					//snapX = Math.round(snapX);
				}
				else {
					//snapX = NumberUtils.toDecimalPoint(snapX);
				}
			}
			
			if (!hasTopSnapEdge && !hasTopSnapEdge) {
				
				if (roundToIntegers) {
					//snapY = Math.round(snapY);
				}
				else {
					//snapY = NumberUtils.toDecimalPoint(snapY);
				}
			}
			
			// update location properties
			//updateDropTargetLocation(targetApplication, event);
			updateDropLocation();
			
			if (hasEventListener(DragDropEvent.DRAG_OVER)) {
				dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_OVER));
			}
			
			
			
		}
		
		/**
		 * Drag drop event
		 * */
		protected function dragDropHandler(event:DragEvent):void {
			var targetSkinnableContainer:SkinnableContainer;
			var isVisualElementContainer:Boolean;
			var isSkinnableContainer:Boolean;
			var targetsUnderPoint:Array;
			var dragEvent:DragDropEvent;
			var topLeftEdgePoint:Point;
			var isApplication:Boolean;
			var isBasicLayout:Boolean;
			var isHorizontal:Boolean;
			var isVertical:Boolean;
			var isGroup:Boolean;
			var isTile:Boolean;
			var offscreen:Boolean;
			var dropIndex:int;
			var target:Object;
			var point:Point;
			var length:int;
			var replaceTarget:Boolean;
			var eventDescription:String;
			
			
			dragData = findDropTarget(event, false);
			
			dropTarget 			= dragData.target;
			dropIndex 			= dragData.dropIndex;
			dropLocation		= dragData.dropLocation;
			dropLayout		 	= dragData.layout;
			isApplication 		= dragData.isApplication;
			isTile		 		= dragData.isTile;
			isVertical 			= dragData.isVertical;
			isBasicLayout 		= dragData.isBasicLayout;
			isHorizontal 		= dragData.isHorizontal;
			isGroup				= dragData.isGroup;
			isSkinnableContainer= dragData.isSkinnableContainer;
			isVisualElementContainer= dragData.isVisualElementContainer;
			offscreen			= dragData.offscreen;
			replaceTarget		= dragData.replaceTarget;
			
			if (debug) {
				logTarget(dropTarget);
			}
			
			/*
			removeDragListeners(dragListener);
			removeDragDisplayObjects();
			removeGroupListeners(targetApplication);*/
			
			// Hide if previously showing
			if (dropLayout && !animateSnapToEdge) {
				dropLayout.hideDropIndicator();
			}
			
			// Hide if previously showing
			if (lastTargetCandidate && "layout" in lastTargetCandidate && !animateSnapToEdge) {
				lastTargetCandidate.layout.hideDropIndicator();
			}
			
			// hide drop indicator
			DragManager.showFeedback(DragManager.NONE);
			
			updateDropLocation();
			
			// Destroy the dropIndicator instance
			if (!animateSnapToEdge) {
				destroyDropIndicator();
			}
			
			restoreHiddenItems();
			
			// store the last target
			lastTargetCandidate = dropTarget;
			
			dropTargetName = NameUtil.getUnqualifiedClassName(dropTarget);
			
			//trace("target: " + dropTargetName);
			event.updateAfterEvent();
			
			dragEvent = new DragDropEvent(DragDropEvent.DRAG_DROP, false, true);
			dragEvent.offsetPoint 			= offset;
			dragEvent.dragEvent				= event;
			dragEvent.dropTarget 			= dropTarget;
			dragEvent.dragInitiator 		= event.dragInitiator;
			dragEvent.dragSource 			= event.dragSource;
			dragEvent.draggedItem 			= draggedItem;
			dragEvent.dropLocation 			= dropLocation;
			dragEvent.dropPoint 			= dropLocation ? dropLocation.dropPoint : new Point(event.localX, event.localY);
			dragEvent.isGroup 				= isGroup;
			dragEvent.isTile 				= isTile;
			dragEvent.isVertical 			= isVertical;
			dragEvent.isHorizontal 			= isHorizontal;
			dragEvent.isBasicLayout			= isBasicLayout;
			dragEvent.isSkinnableContainer	= isSkinnableContainer;
			dragEvent.isDropTargetParent 	= (dropTarget == draggedItem.parent);
			dragEvent.isDropTargetOwner 	= (dropTarget == draggedItem.owner);
			dragEvent.replaceTarget 		= replaceTarget;
			
			dispatchEvent(dragEvent);
			
			if (replaceImageGlowApplied && replaceableImage && replaceableImage.filters) {
				replaceImageFilterIndex = replaceableImage.filters.indexOf(replaceImageGlow);
				
				if (replaceImageFilterIndex!=-1) {
					replaceableImageFilters = dropTarget.filters;
					(replaceableImage.filters as Array).splice(replaceImageFilterIndex, 1);
					replaceableImage.filters = replaceableImageFilters;
				}
				
				replaceImageGlowApplied = false;
				replaceableImage = null;
			}
			
			if (dragEvent.isDefaultPrevented()) {
				
				if (debug) {
					logTarget(lastTargetCandidate, "Drag event prevented");
				}
				
				dragging = false;
				dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_END));
				return;
			}

			
			// SHOULD BE MOVED TO SELECTION CLASS?!?!
			// no because selection class is not always the selected tool
			
			// continue drop
			var index:int = -1;
			var dropPoint:Point;
			var addResult:String;
			var move:Boolean;
			var width:int;
			var height:int;
			var moveResult:String; 
			var dragManagerImplementation:Object;
			
			//sm = SystemManagerGlobals.topLevelSystemManagers[0];
			
			// THE Following code may be causing this error:
			// TypeError: Error #1009: Cannot access a property or method of a null object reference.
			//	at mx.managers.dragClasses::DragProxy/mouseUpHandler()[E:\dev\4.y\frameworks\projects\framework\src\mx\managers\dragClasses\DragProxy.as:640]
			//  - the parent property is null for some reason
			//  solution maybe to add a try catch block if possible
			// 
			//  monkey patched DragProxy and removed animation effect (that causes error)
			
			// it seems to happen when dragging and dropping rapidly
			// stops the drop not accepted animation
			// when using our own dragmanager this no longer works:
			dragManagerImplementation = mx.managers.DragManagerImpl.getInstance();
			// so we use this
			dragManagerImplementation = Singleton.getClass("mx.managers::IDragManager");
			dragManagerImplementation = dragManagerImplementation.getInstance();
			//var dragProxy:DragProxy = dragManagerImplementation.dragProxy;
			//var startPoint:Point = new Point(dragProxy.startX, dragProxy.startY);
			Object(dragManagerImplementation).endDrag();
			//DragManager.endDrag();
			
			distanceFromLeftEdge = targetApplication.localToGlobal(new Point()).x;
			distanceFromTopEdge = targetApplication.localToGlobal(new Point()).y;
			
			if (dropLocation) {
				
				if (isHorizontal || isVertical || isTile) {
					index = dropLocation.dropIndex;
				}
				else if (isGroup || isSkinnableContainer) {
					/*
					trace("drag comp X:"+ distanceFromLeft);
					trace("drag comp Y:"+ distanceFromTop);
					trace("app X:"+ distanceFromLeftEdge);
					trace("app Y:"+ distanceFromTopEdge);
					trace("start point X:"+ startingPoint.x);
					trace("start point Y:"+ startingPoint.y);
					trace("drag proxy start X:"+ dragProxy.startX);
					trace("drag proxy start Y:"+ dragProxy.startY);
					trace("dragProxy.xOffset:"+ dragProxy.xOffset);
					trace("dragProxy.yOffset:"+ dragProxy.yOffset);
					trace("stageX:"+ event.stageX);
					trace("stageY:"+ event.stageY);
					trace("event.localX:"+ event.localX);
					trace("event.localY:"+ event.localY);
					trace("application.scaleX:" + targetApplication.scaleX);
					trace("offset.x:" + offset.x);
					trace("offset.y:" + offset.y);
					trace("dropPoint.y:"+ dropLocation.dropPoint.y);
					trace("dropPoint.x:"+ dropLocation.dropPoint.x);
					*/
					
					if (offscreen) {
						dropPoint = new Point(event.localX, event.localY);
					}
					else {
						dropPoint = dropLocation.dropPoint;
					}
				}
			}
			
			if (draggedItem.parent==null) {
				eventDescription = HistoryManager.getAddDescription(draggedItem);
			}
			else {
				eventDescription = HistoryManager.getMoveDescription(draggedItem);
			}
			
			if (replaceTarget) {
				eventDescription = HistoryManager.getReplaceDescription(draggedItem);
				
				//imageLocalPoint = new Point();
				var propertiesObject:Object = {};
				var imageSource:Image = event.dragInitiator as Image;
				var imageTarget:Image = dropTarget as Image;
				properties = ["source"];
				
				propertiesObject.source = imageSource.source;
				
				// Image has this line: 
				// 
				//     public function set source(value:Object):void {
				// 		if (source == value) return;
				// 
				// so if source is set to the string [object BitmapData]
				// then the assignment never occurs
				// doing check here
				
				if (imageTarget.source == "[object BitmapData]") {
					//var source:Object = imageTarget.source;
					//imageTarget.source = null;
				}
				
				Radiate.setProperties(imageTarget, properties, propertiesObject, eventDescription, true);
				
				if (targetApplication.contains(imageSource)) {
					Radiate.removeElement(imageSource);
					HistoryManager.mergeLastHistoryEvent(Radiate.instance.selectedDocument, eventDescription);
				}
				
				dragCompleteEvent 						= new DragDropEvent(DragDropEvent.DRAG_DROP_COMPLETE, false, true);
				dragCompleteEvent.dragEvent				= event;
				dragCompleteEvent.dropTarget 			= dropTarget;
				dragCompleteEvent.dragInitiator 		= event.dragInitiator;
				dragCompleteEvent.dragSource 			= event.dragSource;
				dragCompleteEvent.draggedItem 			= draggedItem;
				dragCompleteEvent.isDropTargetParent 	= (dropTarget == draggedItem.parent);
				dragCompleteEvent.isDropTargetOwner 	= (dropTarget == draggedItem.owner);
				dragCompleteEvent.replaceTarget 		= replaceTarget;
				
				dispatchEvent(dragCompleteEvent);
				return;
			}
			
			// try to refactor to use MoveUtils
			if (isBasicLayout) {
				var dropX:Number;
				var dropY:Number;
				var values:Object;
				var properties:Array;
				var styles:Array;
				var verticalCenter:int;
				var horizontalCenter:int;
				var setVerticalCenter:Boolean;
				var setHorizontalCenter:Boolean;
				var setBottom:Boolean;
				var setRight:Boolean;
				var setLeft:Boolean;
				var setTop:Boolean;
				var setX:Boolean;
				var setY:Boolean;
				var bottom:Number;
				var right:Number;
				var left:Number;
				var top:Number;
				var x:Number;
				var y:Number;
				var scaleX:Number;
				var scaleY:Number;
				var distanceFromLeftEdge:Number;
				var distanceFromTopEdge:Number;
				var line:Line;
				var xFrom:Number;
				var xTo:Number;
				var yFrom:Number;
				var yTo:Number;
				var xDiff:Number;
				var yDiff:Number;
				var snapStartDropPoint:Point;
				var snapEndDropPoint:Point;
				var hasSnapX:Boolean;
				var hasSnapY:Boolean;
				var hasSnapRight:Boolean;
				var hasSnapBottom:Boolean;
				var hasSnapHorizontal:Boolean;
				var hasSnapVertical:Boolean;
				var minimumSnapValue:Number;
				
				values = {};
				properties = [];
				styles = [];
				
				scaleX = targetApplication.scaleX;
				scaleY = targetApplication.scaleY;
				
				
				if (!isNaN(snapX)) {
					hasSnapX = true;
				}
				
				if (!isNaN(snapY)) {
					hasSnapY = true;
				}
				
				if (!isNaN(snapRight)) {
					hasSnapRight = true;
				}
				
				if (!isNaN(snapBottom)) {
					hasSnapBottom = true;
				}
				
				if (!isNaN(snapVerticalCenter)) {
					hasSnapVertical = true;
				}
				
				if (!isNaN(snapHorizontalCenter)) {
					hasSnapHorizontal = true;
				}
				
				if (hasSnapX || hasSnapY || hasSnapRight || hasSnapBottom || hasSnapHorizontal || hasSnapVertical) {
					snapStartDropPoint = new Point();
					snapEndDropPoint = new Point();
				}
				
				// desktop this is null - but our offset point might be the same 
				if (dragProxy==null) {
					
					if (scaleX<1) {
						dropX = dropPoint.x-offset.x/scaleX;
						dropY = dropPoint.y-offset.y/scaleY;
					}
					else if (scaleX>1) {
						dropX = dropPoint.x-offset.x/scaleX;
						dropY = dropPoint.y-offset.y/scaleY;
					}
				}
				else {
					
					if (scaleX<1) {
						dropX = dropPoint.x-dragProxy.xOffset/scaleX;
						dropY = dropPoint.y-dragProxy.yOffset/scaleY;
					}
					else if (scaleX>1) {
						dropX = dropPoint.x-dragProxy.xOffset/scaleX;
						dropY = dropPoint.y-dragProxy.yOffset/scaleY;
					}
				}
					
				// check for scaling
				if (scaleX!=1 && !isNaN(scaleX)) {
					dropX;
				}
				else {
					dropX = dropPoint.x - offset.x;
					dropY = dropPoint.y - offset.y;
				}
				
				
				if (hasSnapX || hasSnapY || hasSnapRight || hasSnapBottom || hasSnapHorizontal || hasSnapVertical) {
					snapStartDropPoint.x = dropX;
					snapStartDropPoint.y = dropY;
					
					if (hasSnapX || hasSnapRight || hasSnapHorizontal) {
						//minimumSnapValue = NumberUtil.snapToInArray(0, [snapX, snapRight, snapHorizontalCenter]);
						minimumSnapValue = NumberUtil.snapToInArray(0, [leftDifference, rightDifference, horizontalDifference]);
						
						if (minimumSnapValue==leftDifference) {
							hasSnapRight = false;
							hasSnapHorizontal = false;
							snapRight = NaN;
							snapHorizontalCenter = NaN;
						}
						else if (minimumSnapValue==rightDifference) {
							hasSnapX = false;
							hasSnapHorizontal = false;
							snapX = NaN;
							snapHorizontalCenter = NaN;
						}
						else if (minimumSnapValue==horizontalDifference) {
							hasSnapX = false;
							hasSnapRight = false;
							snapX = NaN;
							snapRight= NaN;
						}
					}
					else if (hasSnapX && hasSnapRight) {
						//minimumSnapValue = NumberUtil.snapToInArray(0, [snapX, snapRight]);
						minimumSnapValue = NumberUtil.snapToInArray(0, [leftDifference, rightDifference]);
						
						if (minimumSnapValue==snapX) {
							hasSnapRight = false;
							snapRight= NaN;
						}
						else if (minimumSnapValue==snapRight) {
							hasSnapX = false;
							snapX = NaN;
						}
					}
					
					if (hasSnapY || hasSnapBottom || hasSnapVertical) {
						//minimumSnapValue = NumberUtil.snapToInArray(0, [snapY, snapBottom, snapVerticalCenter]);
						minimumSnapValue = NumberUtil.snapToInArray(0, [topDifference, bottomDifference, verticalDifference]);
						
						if (minimumSnapValue==topDifference) {
							hasSnapBottom = false;
							hasSnapVertical = false;
							snapBottom = NaN;
							snapVerticalCenter = NaN;
						}
						else if (minimumSnapValue==bottomDifference) {
							hasSnapY = false;
							hasSnapVertical = false;
							snapY = NaN;
							snapVerticalCenter = NaN;
						}
						else if (minimumSnapValue==verticalDifference) {
							hasSnapBottom = false;
							hasSnapY = false;
							snapBottom = NaN;
							snapY = NaN;
						}
					}
					else if (hasSnapY && hasSnapBottom) {
						//minimumSnapValue = NumberUtil.snapToInArray(0, [snapY, snapBottom]);
						minimumSnapValue = NumberUtil.snapToInArray(0, [topDifference, bottomDifference]);
						
						if (minimumSnapValue==snapY) {
							hasSnapBottom = false;
							snapBottom = NaN;
						}
						else if (minimumSnapValue==snapBottom) {
							hasSnapY = false;
							snapY = NaN;
						}
					}
					
					// horizontal 
					if (hasSnapX) {
						dropX = snapX;
						//trace("snapX to:" + dropX);
					}
					
					if (hasSnapHorizontal) {
						dropX = snapHorizontalCenter - draggedItem.width/2;
						//trace("snapY to:" + dropY);
					}
					
					if (hasSnapRight) {
						dropX = snapRight - draggedItem.width;
						//trace("snapX to:" + dropX);
					}
					
					// vertical
					if (hasSnapY) {
						dropY = snapY;
						//trace("snapY to:" + dropY);
					}
					
					if (hasSnapVertical) {
						dropY = snapVerticalCenter - draggedItem.height/2;
						//trace("snapY to:" + dropY);
					}
					
					if (hasSnapBottom) {
						dropY = snapBottom - draggedItem.height;
						//trace("snapY to:" + dropY);
					}
				}
				
				
				if (!hasSnapX && !hasSnapRight && !hasSnapHorizontal) {
					
					if (roundToIntegers) {
						dropX = Math.round(dropX);
						//trace("rounding dropX to:" + dropX);
					}
					else {
						dropX = NumberUtils.toDecimalPoint(dropX);
						//trace("to dec dropX to:" + dropX);
					}
				}
				
				if (!hasSnapY && !hasSnapBottom && !hasSnapVertical) {
					
					if (roundToIntegers) {
						dropY = Math.round(dropY);
						//trace("rounding dropY to:" + dropY);
					}
					else {
						dropY = NumberUtils.toDecimalPoint(dropY);
						//trace("to dec dropY to:" + dropY);
					}
				}
				
				if (draggedItem is Line) {
					line = draggedItem as Line;
					
					xDiff = dropX - line.xFrom;
					xDiff = line.xTo<line.xFrom ? xDiff + line.xFrom-line.xTo : xDiff;
					xFrom = line.xFrom + xDiff + line.stroke.weight/2;
					values["xFrom"] = xFrom;
					
					if (isNaN(line.percentWidth)) {
						xTo = line.xTo + xDiff + line.stroke.weight/2;
						values["xTo"] = xTo;
					}
					
					yDiff = dropY - line.yFrom;
					yDiff = line.yTo<line.yFrom ? yDiff + line.yFrom-line.yTo : yDiff;
					yFrom = line.yFrom + yDiff + line.stroke.weight/2;
					values["yFrom"] = yFrom;
					
					if (isNaN(line.percentHeight)) {
						yTo = line.yTo + yDiff + line.stroke.weight/2;
						values["yTo"] = yTo;
					}
					
					dropX = Math.min(xFrom, xTo); 
					dropY = Math.min(yFrom, yTo); 
				}
				else {
					
					////////////////////////////////////////
					// X and Y
					////////////////////////////////////////
					setX = true;
					x = dropX;
					values["x"] = x;
					
					setY = true;
					y = dropY;
					values["y"] = y;
					
					
					////////////////////////////////////////
					// Top and bottom
					////////////////////////////////////////
					if (draggedItem.top!=undefined) {
						setTop = true;
						top = dropY;
						values["top"] = top;
						delete values["y"];
					}
					
					if (draggedItem.bottom!=undefined) {
						setBottom = true;
						bottom = Number(draggedItem.parent.height) - Number(draggedItem.height) - Number(dropY);
						values["bottom"] = bottom;
						
					}
					
					////////////////////////////////////////
					// Left and Right
					////////////////////////////////////////
					if (draggedItem.left!=undefined) {
						setLeft = true;
						left = dropX;
						values["left"] = left;
						delete values["x"];
					}
					
					if (draggedItem.right!=undefined) {
						setRight = true;
						right = Number(draggedItem.parent.width) - Number(draggedItem.width) - Number(dropX);
						values["right"] = right;
					}
					
					////////////////////////////////////////
					// Vertical and Horizontal Center
					////////////////////////////////////////
					if (draggedItem.verticalCenter!=undefined) {
						setVerticalCenter = true;
						verticalCenter = dropY - draggedItem.parent.height /2;
						values["verticalCenter"] = verticalCenter;
						delete values["y"];
						//delete values["top"]; need to test
						//delete values["bottom"];
					}
					
					if (draggedItem.horizontalCenter!=undefined) {
						setHorizontalCenter = true;
						horizontalCenter = dropX - draggedItem.parent.width/2;
						values["horizontalCenter"] = horizontalCenter;
						delete values["x"];
						//delete values["left"];
						//delete values["right"];
					}
				}
				
				// build affected properties array
				//for (var propertyName:String in values) {
				//	properties.push(propertyName);
				//}
				
				properties 				= ClassUtils.getPropertiesFromObject(draggedItem, values, true);
				styles 					= ClassUtils.getStylesFromObject(draggedItem, values);
				
				if (draggedItem.parent==null) {
					addResult = Radiate.addElement(draggedItem, dropTarget, properties, styles, null, values, eventDescription);
				}
				else {
					moveResult = Radiate.moveElement(draggedItem, dropTarget, properties, styles, null, values, eventDescription);
				}
				
				if (animateSnapToEdge && !(draggedItem is Line) && 
					(properties.indexOf("x")!=-1 || properties.indexOf("y")!=-1) &&
					(hasSnapX || hasSnapY || hasSnapVertical || hasSnapBottom || hasSnapRight || hasSnapHorizontal) ) {
					var lineColor:uint = SnapToElementDropIndicator(dropLayout.dropIndicator).lineColor;
					var lineWeight:Number = SnapToElementDropIndicator(dropLayout.dropIndicator).lineWeight;
					//SnapToElementDropIndicator(dropLayout.dropIndicator).lineColor = 0x2222FF;
					SnapToElementDropIndicator(dropLayout.dropIndicator).lineWeight = 2;
					SnapToElementDropIndicator(dropLayout.dropIndicator).setLines(snapX, snapY, snapRight, snapBottom, snapHorizontalCenter, snapVerticalCenter);
					SnapToElementDropIndicator(dropLayout.dropIndicator).validateDisplayList();
					SnapToElementDropIndicator(dropLayout.dropIndicator).lineColor = lineColor;
					SnapToElementDropIndicator(dropLayout.dropIndicator).lineWeight = lineWeight;
					snapEndDropPoint.x = dropX;
					snapEndDropPoint.y = dropY;
					animateSnapPoint(draggedItem, snapEndDropPoint, snapStartDropPoint);
				}
				else {
					destroyDropIndicator();
				}
			}
			// tile, vertical or horizontal layout
			else {
				
				if (draggedItem.parent==null) {
					addResult = Radiate.addElement(draggedItem, dropTarget, null, null, null, null, eventDescription, null, null, index);
				}
				else {
					moveResult = Radiate.moveElement(draggedItem, dropTarget, null, null, null, null, eventDescription, null, null, index);
				}
				
				destroyDropIndicator();
			}
			
			// try and reduce the delay of the new component showing up after screen updates
			event.updateAfterEvent();
			
			var dragCompleteEvent:DragDropEvent;
			dragCompleteEvent 						= new DragDropEvent(DragDropEvent.DRAG_DROP_COMPLETE, false, true);
			dragCompleteEvent.offsetPoint 			= offset;
			dragCompleteEvent.dragEvent				= event;
			dragCompleteEvent.dropTarget 			= dropTarget;
			dragCompleteEvent.dragInitiator 		= event.dragInitiator;
			dragCompleteEvent.dragSource 			= event.dragSource;
			dragCompleteEvent.draggedItem 			= draggedItem;
			dragCompleteEvent.dropLocation 			= dropLocation;
			dragCompleteEvent.dropPoint 			= dropLocation ? dropLocation.dropPoint : new Point(event.localX, event.localY);
			dragCompleteEvent.isGroup 				= isGroup;
			dragCompleteEvent.isTile 				= isTile;
			dragCompleteEvent.isVertical 			= isVertical;
			dragCompleteEvent.isHorizontal 			= isHorizontal;
			dragCompleteEvent.isBasicLayout			= isBasicLayout;
			dragCompleteEvent.isSkinnableContainer	= isSkinnableContainer;
			dragCompleteEvent.isDropTargetParent 	= (dropTarget == draggedItem.parent);
			dragCompleteEvent.isDropTargetOwner 	= (dropTarget == draggedItem.owner);
			dragCompleteEvent.replaceTarget 		= replaceTarget;
			
			dispatchEvent(dragCompleteEvent);
			
			// TODO: should possibly use events to update the drop location
			// or move to the drop indicator classes
			updateDropLocation();
			
			// try and reduce the delay of the new component showing up after screen updates
			//event.updateAfterEvent();
		}
		
		protected function dragCompleteHandler(event:Event):void {
			if (debug) {
				logTarget(draggedItem);
			}
			restoreHiddenItems();
			removeDragInitiatorProxy();
			removeDragListeners(dragListener);
			removeDragDisplayObjects();
			//removeGroupListeners(targetApplication);
			removeMouseHandlers(dragInitiator as IVisualElement);
			destroySnapPointsCache();
			
			if (snapToEdgeAnimation && !snapToEdgeAnimation.isPlaying) {
				destroyDropIndicator();
			}
			
			dragging = false;
			dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_END));
			Radiate.instance.dispatchDocumentUpdatedEvent(Radiate.instance.selectedDocument);
		}
		
		public function restoreHiddenItems():void {
			for (var item:Object in hiddenItemsDictionary) {
				if ("visible" in item) {
					item.visible = true;
				}
				delete hiddenItemsDictionary[item];
			}
		}
		
		private function addDragListeners(dragInitiator:IUIComponent, dragListener:DisplayObject):void {
			
			dragListener.addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
			dragListener.addEventListener(DragEvent.DRAG_EXIT, dragExitHandler);
			dragListener.addEventListener(DragEvent.DRAG_OVER, dragOverHandler);
			dragListener.addEventListener(DragEvent.DRAG_DROP, dragDropHandler);
			
			dragInitiator.addEventListener(DragEvent.DRAG_COMPLETE, dragCompleteHandler);
		}
		
		private function removeDragListeners(dragListener:DisplayObject):void {
			dragListener.removeEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
			dragListener.removeEventListener(DragEvent.DRAG_EXIT, dragExitHandler);
			dragListener.removeEventListener(DragEvent.DRAG_OVER, dragOverHandler);
			dragListener.removeEventListener(DragEvent.DRAG_DROP, dragDropHandler);
			
			dragInitiator.removeEventListener(DragEvent.DRAG_COMPLETE, dragCompleteHandler);
		}
		
		private function removeDragDisplayObjects():void {
			selectionGroup.width = 0;
			selectionGroup.height = 0;
			
			PopUpManager.removePopUp(selectionGroup);
			
			PopUpManager.removePopUp(mouseLocationLines);
			
			if (mouseLocationLines) {
				mouseLocationLines.width = 0;
				mouseLocationLines.height = 0;
			}
			
		}
		
		/**
		 * Remove listeners from selected target
		 * */
		protected function mouseUpHandler(event:Event):void {
			if (debug) {
				logTarget(event.currentTarget);
			}
			
			if (dragInitiator && hideDragInitiatorOnDrag) { 
				restoreHiddenItems();
			}
			
			if (dragging) {
				dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_DROP_INCOMPLETE));
				dragCompleteHandler(event);
				dragging = false;
			}
			
			// hopefully the following code is not necessary by listening to the stage
			// attempt to fix hidden elements bug
			if (event.currentTarget is InvalidatingSprite) {
				if (dragInitiator is IGraphicElement) {
					removeMouseHandlers((dragInitiator as IGraphicElement).displayObject);
					removeMouseHandlers((dragInitiator as IGraphicElement));
				}
				else {
					if (event.currentTarget is EventDispatcher) {
						removeMouseHandlers(event.currentTarget);
					}
				}
			}
			else {
				removeMouseHandlers(event.currentTarget);
				
				if (dragInitiator) {
					removeMouseHandlers(dragInitiator);
				}
				if (dragInitiator is GraphicElement) {
					removeMouseHandlers(GraphicElement(dragInitiator).displayObject);
				}
			}
		}
		
		public function addToHiddenItemsDictionary(dragInitiator:IVisualElement):void {
			dragInitiator.visible = false;
			hiddenItemsDictionary[dragInitiator] = 1;
		}
		
		/**
		 * Remove listeners from selected target and swfroot. 
		 * */
		protected function removeMouseHandlers(target:Object):void {
			if (target==null) return;
			target.removeEventListener(DragEvent.DRAG_COMPLETE, dragCompleteHandler);
			target.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			swfRoot.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			swfRoot.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			swfRoot.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpSomewhereHandler);
			swfRoot.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpSomewhereHandler, true);
			
			var topSystemManager:SystemManager = SystemManagerGlobals.topLevelSystemManagers[0];
			topSystemManager.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpSomewhereHandler);
			topSystemManager.stage.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpSomewhereHandler);
			
		}
		
		/**
		 * Creates the drop indicator instance for horizontal, vertical and tile layouts 
		 * */
		public function createDropIndicator():DisplayObject {
			
			// Do we have a drop indicator already?
			if (dropIndicatorInstance && dropIndicatorInstance is ListDropIndicator) {
				return DisplayObject(dropIndicatorInstance);
			}
			
			var dropIndicatorClass:Class;
			
			if (dropIndicatorFactory) {
				//dropIndicatorInstance = DisplayObject(parentApplication.createDynamicPartInstance("dropIndicator"));
				dropIndicatorInstance = DisplayObject(dropIndicatorFactory.newInstance());
			}
			else {
				dropIndicatorClass = spark.skins.spark.ListDropIndicator;
				
				if (dropIndicatorClass) {
					dropIndicatorInstance = new dropIndicatorClass();
				}
			}
			
			if (dropIndicatorInstance is IVisualElement) {
				IVisualElement(dropIndicatorInstance).owner = targetApplication;
			}
			
			// Set it in the layout
			//layout.dropIndicator = dropIndicatorInstance;
			return dropIndicatorInstance;
		}
		
		/**
		 * Create a indicator for basic layout that shows edge lines
		 * */
		public function createBasicLayoutDropIndicator(target:GroupBase):DisplayObject {
			
			// Do we have a drop indicator already?
			if (dropIndicatorInstance && dropIndicatorInstance is SnapToElementDropIndicator && dropIndicatorInstance==target.layout.dropIndicator) {
				return DisplayObject(dropIndicatorInstance);
			}
			
			var dropIndicatorClass:Class;
			
			dropIndicatorClass = SnapToElementDropIndicator;
			
			if (dropIndicatorClass) {
				dropIndicatorInstance = new dropIndicatorClass();
			}
			
			if (dropIndicatorInstance is IVisualElement) {
				IVisualElement(dropIndicatorInstance).owner = targetApplication;
			}
			
			dropIndicatorInstance.x = 0;
			dropIndicatorInstance.y = 0;
			dropIndicatorInstance.width = target.width;
			dropIndicatorInstance.height = target.height;
			dropIndicatorInstance.alpha = .5;
			
			// Set it in the layout
			//layout.dropIndicator = dropIndicatorInstance;
			return dropIndicatorInstance;
		}
		
		/**
		 * Remove snap points cache
		 * */
		public function destroySnapPointsCache():void {
			//trace("Destroying snap points");
			
			if (snapPointsCache) {
				var keys:Array = DictionaryUtils.getKeys(snapPointsCache);
				DictionaryUtils.deleteKeys(snapPointsCache, keys);
			}
		}
		
		/**
		 * Need to clean this up
		 * */
		public function destroyDropIndicator():DisplayObject {
			if (snapToEdgeAnimation && snapToEdgeAnimation.isPlaying) {
				return null;
			}
			
			if (dropLayout) {
				dropLayout.hideDropIndicator();
			}
			
			var dropIndicatorInstance:DisplayObject = dropIndicatorFactory as DisplayObject;
			
			if (!dropIndicatorInstance)
				return null;
			
			dropIndicatorInstance.visible = false;
			
			// Release the reference from the layout
			dropIndicatorFactory = null;
			
			
			// Release it if it's a dynamic skin part
			/*var count:int = parentApplication.numDynamicParts("dropIndicator");
			
			for (var i:int = 0; i < count; i++) {
			if (dropIndicatorInstance == parentApplication.getDynamicPartAt("dropIndicator", i)) {
			// This was a dynamic part, remove it now:
			parentApplication.removeDynamicPartInstance("dropIndicator", dropIndicatorInstance);
			break;
			}
			}*/
			
			return dropIndicatorInstance;
		}
		
		/**
		 * Fade out drop indicator
		 * */
		public function fadeOutDropIndicator():void {
			if (snapToEdgeAnimation && snapToEdgeAnimation.isPlaying) {
				return;
			}
			
			if (fadeDropIndicatorAnimation==null) {
				fadeDropIndicatorAnimation = new Fade();
			}
			
			fadeDropIndicatorAnimation.addEventListener(EffectEvent.EFFECT_END, fadeDropIndicatorAnimation_effectEndHandler);
			fadeDropIndicatorAnimation.duration = fadeDropIndicatorAnimationDuration;
			fadeDropIndicatorAnimation.play([dropLayout.dropIndicator]);
		}
		
		public function getSnapPoints(target:GroupBase, excludeObject:Object = null, skipOwner:Boolean = true, edges:Boolean = true):SnapPoints {
			var numberOfElements:int;
			var element:IVisualElement;
			var topSnapPoints:Array = [];
			var bottomSnapPoints:Array = [];
			var leftSnapPoints:Array = [];
			var horizontalSnapPoints:Array = [];
			var verticalSnapPoints:Array = [];
			var rightSnapPoints:Array = [];
			var horizontalPoints:Array = [];
			var verticalPoints:Array = [];
			var elementRectangle:Rectangle;
			var groupRectangle:Rectangle;
			var line:Line;
			var snapPoints:SnapPoints;
			
			
			if (target==null) return null;
			if (snapPointsCache[target]) {
				//trace("Getting snap points from cache");
				return snapPointsCache[target] as SnapPoints;
			}
			//trace("Getting snap points");
			
			groupRectangle = target.getBounds(target);
			numberOfElements = target.numElements;
			
			for (var i:int = 0; i < numberOfElements; i++) {
				element = target.getElementAt(i);
				
				if (excludeObject) {
					if (element==excludeObject) {
						continue;
					}
				}
				
				if (element.visible == false) {
					continue;
				}
				
				if (skipOwner && "owner" in element && element==excludeObject.owner) {
					continue;
				}
				
				// drag initiator is created for things like graphic elements
				// drag manager needs a uicomponent to drag not graphic element so we create one before drag
				// it seems like it's getting added to the stage at some point by the drag manager class
				if (element==dragInitiator) {
					continue;
				}
				
				//elementRectangle = target.layout.getElementBounds(i);
				//elementRectangle = target.layout.getChildElementBounds(element);
				
				if (element is Line) {
					line = element as Line;
					leftSnapPoints.push(Math.min(line.xFrom, line.xTo));
					rightSnapPoints.push(Math.max(line.xTo, line.xFrom));
					//horizontalSnapPoints.push((line.xTo - line.xFrom)/2);
					
					topSnapPoints.push(Math.min(line.yTo, line.yFrom));
					bottomSnapPoints.push(Math.max(line.yTo, line.yFrom));
				}
				else {
					leftSnapPoints.push(element.x);
					rightSnapPoints.push(element.x + element.width);
					horizontalSnapPoints.push(element.x + element.width/2);
					
					topSnapPoints.push(element.y);
					bottomSnapPoints.push(element.y + element.height);
					verticalSnapPoints.push(element.y + element.height/2);
				}
			}
			
			snapPoints = new SnapPoints();
			
			if (edges) {
				leftSnapPoints.push(0);
				topSnapPoints.push(0);
				rightSnapPoints.push(target.width);
				bottomSnapPoints.push(target.height);
				horizontalSnapPoints.push(target.width/2);
				verticalSnapPoints.push(target.height/2);
			}
			
			horizontalPoints = leftSnapPoints.concat(rightSnapPoints).concat(horizontalSnapPoints);
			verticalPoints = topSnapPoints.concat(bottomSnapPoints).concat(verticalSnapPoints);
			/*
			snapPoints.left = leftSnapPoints.concat(rightSnapPoints);
			snapPoints.top = topSnapPoints.concat(bottomSnapPoints);
			snapPoints.right = rightSnapPoints.concat(leftSnapPoints);
			snapPoints.bottom = bottomSnapPoints.concat(topSnapPoints);
			snapPoints.verticalCenter = verticalSnapPoints;
			snapPoints.horizontalCenter = horizontalSnapPoints;
			*/
			
			snapPoints.left 			= horizontalPoints;
			snapPoints.right 			= horizontalPoints;
			snapPoints.horizontalCenter = horizontalPoints;
			
			snapPoints.top 				= verticalPoints;
			snapPoints.bottom 			= verticalPoints;
			snapPoints.verticalCenter 	= verticalPoints;
			
			snapPointsCache[target] = snapPoints;
			
			return snapPoints;
		}
		
		/**
		 * Find the target under mouse pointer
		 * */
		public function findDropTarget(event:DragEvent, draggingOver:Boolean = true, applicationScale:Number = 1):DragData {
			/*var eventTarget:FlexSprite = FlexSprite(event.target); */
			var visualElementContainer:IVisualElementContainer;
			var skinnableContainer:SkinnableContainer;
			var componentDescription:ComponentDescription;
			var isSkinnableContainer:Boolean;
			var topLeftEdgePoint:Point;
			var isApplication:Boolean;
			var isBasicLayout:Boolean;
			var isHorizontal:Boolean;
			var isVertical:Boolean;
			var isGroup:Boolean;
			var isBasic:Boolean;
			var isTile:Boolean;
			var layout:LayoutBase;
			var numberOfTargets:int;
			var target:Object;
			var debug:Boolean;
			var dropIndex:int;
			var location:DropLocation;
			var offscreen:Boolean;
			var replaceTarget:Boolean;
			var targetToReplace:Object;
			var allowedParent:Object;
			var adjustedX:Number;
			var adjustedY:Number;
			
			dragData = new DragData();
			
			// get targets under mouse pointer
			if (adjustMouseOffset) {
				adjustedX = event.stageX-(offset.x / applicationScale);
				adjustedY = event.stageY-(offset.y / applicationScale);
				topLeftEdgePoint = new Point(adjustedX, adjustedY);
			}
			else {
				topLeftEdgePoint = new Point(event.stageX, event.stageY);
			}
			
			// get items under point
			// according to DragProxy the player doesn't handle getObjectsUnderPoint correctly 
			// and uses it's own method. maybe use that if any issues
			targetsUnderPoint = topLevelApplication.getObjectsUnderPoint(topLeftEdgePoint);
			//targetsUnderPoint = [];
			//getObjectsUnderPoint(topLevelApplication, topLeftEdgePoint, targetsUnderPoint);
			
			numberOfTargets = targetsUnderPoint.length;
			
			// start from highest component and go back to application
			targetsUnderPoint = targetsUnderPoint.reverse();
			
			if (!isDragOutAllowed && "owner" in draggedItem && draggedItem.owner) {
				allowedParent = draggedItem.owner;
			}
			
			////////////////////////////////////////////////////////////
			// find drop target
			////////////////////////////////////////////////////////////
			
			componentTreeLoop:
			
			// loop through items under point until we find one on the *component* tree
			for (var i:int;i<numberOfTargets;i++) {
				target = targetsUnderPoint[i];
				// if parent application does not contain the target
				if (!targetApplication.contains(DisplayObject(target))) {
					continue;
				}
				
				// check if target is self
				if (target==draggedItem) {
					continue;
				}
				
				// check if target is child of self
				if ("contains" in draggedItem && draggedItem.contains(target)) {
					continue;
				}
				
				// as soon as we find a visual element we can find the owner
				if (target is IVisualElement) {
					
					// if dragging over image we can swap out the source if shift key is down
					if (event.shiftKey && (target is Image || target is ImageSkin)) {
						replaceTarget = true;
						if (target is ImageSkin) {
							target = target.hostComponent;
						}
						
						// if drag out is not allowed then match only allowed parent
						if (allowedParent!=null) {
							if ("owner" in target && target.owner==allowedParent) {
								targetToReplace = target;
								break;
							}
						}
						else {
							targetToReplace = target;
							break;
						}
					}
					
					componentDescription = DisplayObjectUtils.getVisualElementContainerFromElement(IVisualElement(target), componentTree);
					
					
					if (componentDescription) {
						target = componentDescription.instance;
						
						if (allowedParent!=null) {
							if ("owner" in target && target.owner==allowedParent) {
								target = allowedParent;
								break;
							}
							else if (target==targetApplication) {
								target = allowedParent;
								break;
							}
						}
						else {
							break;
						}
					}
				}
			}
			
			
			// check if target is self
			if (target==draggedItem) {
				target = targetApplication;
				if (debug) Radiate.info("Cannot drag onto self");
				if (draggingOver) return null;
				//continue;
			}
			
			// check if target is child of self
			if (target && "contains" in draggedItem && 
				draggedItem.contains(target)) {
				if (debug) Radiate.info("Cannot drag into child of self");
				if (draggingOver) return null;
				//return null;
			}
			
			// this shouldn't be here but if document is not set then we get all sorts of targets
			if (target && 
				target != targetApplication && 
				!targetApplication.contains(DisplayObject(target))) {
				
				if (allowedParent!=null) {
					target = allowedParent;
				}
				
				if (debug) Radiate.info("Target application doesn't contain drop target");
				if (draggingOver) return null;
				//return null;
			}
			
			// still no target then we are on the application (most likely)
			if (!target) {
				target = targetApplication;
			}
			
			if (target==targetApplication) {
				isApplication = true;
			}
			
			// check if target is a group
			if (target is IVisualElementContainer) {
				
				dropIndex = -1;
				
				// skip skins
				if (target is Skin && !includeSkins) {
					//throw new Error("target cannot be a skin");
					target = targetApplication;
				}
				
				// skip skins (for groups in checkbox skin for example)
				if ("owner" in target && target.owner is Skin && !includeSkins) {
					target = targetApplication;
				}
				
				visualElementContainer = target as IVisualElementContainer;
				groupBase = target as GroupBase;
				skinnableContainer = target as SkinnableContainer;
				
				//isGroup = groupBase!=null;
				//isSkinnableContainer = skinnableContainer!=null;
				
				// ReferenceError: Error #1069: Property layout not found on mx.containers.TabNavigator and there is no default value.
				layout = "layout" in target ? target.layout : null;
				
				
				if (!layout) return null;
				// we found a group
				//dropTarget = target;
				
				// TypeError: Error #1009: Cannot access a property or method of a null object reference.
				// get drop indicator location
				location = layout.calculateDropLocation(event);
				
				var stagePoint:Point = new Point(event.stageX, event.stageY);
				offscreen = location.dropPoint.equals(stagePoint);
				
				if (location) {
					dropIndex = location.dropIndex;
				}
				
				// reset group layout values
				isBasic = isTile = isVertical = isHorizontal = false;
				
				// check the type
				//if (targetGroup) {
				//	targetGroupLayout = targetGroup.layout;
				
				if (layout is BasicLayout) {
					isBasic = true;
				}
				else if (layout is HorizontalLayout) {
					isHorizontal = true;
				}
				else if (layout is VerticalLayout) {
					isVertical = true;
				}
				else if (layout is TileLayout) {
					isTile = true;
				}
				//}
			}
			
			dragData.target = target;
			dragData.offscreen = offscreen;
			dragData.dropLocation = location;
			dragData.dropIndex = dropIndex;
			dragData.description = componentDescription;
			dragData.isApplication = isApplication;
			dragData.isHorizontal = isHorizontal;
			dragData.isVertical = isVertical;
			dragData.isTile = isTile;
			dragData.isBasicLayout = isBasic;
			dragData.layout = layout;
			dragData.isGroup = groupBase!=null;
			dragData.isSkinnableContainer = skinnableContainer!=null;
			dragData.isVisualElementContainer = visualElementContainer!=null;
			dragData.replaceTarget = replaceTarget;
			
			return dragData;
		}
		
		/**
		 * Finds the first visual element container
		 * */
		public static function getContainerUnderPoint(event:Object, topLevelContainer:DisplayObjectContainer, adjustMouseOffset:Boolean = true, offset:Point = null):* {
			var topLevelApplication:Object = FlexGlobals.topLevelApplication;
			var adjustMouseOffset:Boolean;
			var targetsUnderPoint:Array;
			var topLeftEdgePoint:Point;
			var isHorizontal:Boolean;
			var rectangle:Rectangle;
			var isVertical:Boolean;
			var dropTarget:Object;
			var isTile:Boolean;
			var isGroup:Boolean;
			var isBasicLayout:Boolean;
			var isVerticalLayout:Boolean;
			var isHorizontalLayout:Boolean;
			var includeSkins:Boolean;
			var dropIndex:int = -1;
			var target:Object;
			var numberOfTargets:int;
			
			
			// get targets under point
			if (adjustMouseOffset) {
				topLeftEdgePoint = new Point(event.stageX-offset.x, event.stageY-offset.y);
			}
			else {
				topLeftEdgePoint = new Point(event.stageX, event.stageY);
			}
			
			// get items under point
			//targetsUnderPoint = topLevelApplication.getObjectsUnderPoint(topLeftEdgePoint);
			targetsUnderPoint = topLevelContainer.getObjectsUnderPoint(topLeftEdgePoint);
			
			numberOfTargets = targetsUnderPoint.length;
			
			targetsUnderPoint = targetsUnderPoint.reverse();
			
			// loop through objects under pointer from the highest to the lowest
			outerloop: 
			
			////////////////////////////////////////////////////////////
			// find first available group
			////////////////////////////////////////////////////////////
			for (var i:int;i<numberOfTargets;i++) {
				target = targetsUnderPoint[i];
				
				if (DisplayObjectContainer(topLevelContainer).contains(DisplayObject(target))) {
					//trace(i + " parent application is " + parentApplication);
					//trace(i + " parent application contains " + target);
				}
				else {
					//trace(i + " parent application does not contain " + target);
					//continue;
					// if the top level container doesn't contain 
					break;
				}
				
				
				isGroup = false;
				
				// check if target is a group
				if (target is GroupBase || target is SkinnableContainer) {
					dropIndex = -1;
					
					
					// skip skins
					if (target is ApplicationSkin) {
						target = target.owner;
					}
					
					// skip skins
					if (target is Skin && !includeSkins) {
						continue;
					}
					
					isGroup = target is GroupBase ? true : false;
					
					var isSkinnableContainer:Object = target is SkinnableContainer ? true : false;
					var targetGroup:Object = target as GroupBase;
					var targetSkinnableContainer:Object = target as SkinnableContainer;
					
					// we found a group
					dropTarget = target;
					
					// check the type
					if (target) { // may not need this check
						var targetGroupLayout:Object = target.layout;
						
						// get drop indicator location
						var dropLocation:Object = targetGroupLayout.calculateDropLocation(event);
						
						if (dropLocation) {
							dropIndex = dropLocation.dropIndex;
						}
						
						// reset group layout values
						isTile = isVertical = isHorizontal = false;
						
						if (targetGroupLayout is HorizontalLayout) {
							isHorizontal = true;
						}
						else if (targetGroupLayout is VerticalLayout) {
							isVertical = true;
						}
						else if (targetGroupLayout is TileLayout) {
							isTile = true;
						}
						else if (targetGroupLayout is BasicLayout) {
							isBasicLayout = true;
						}
					}
					
					//trace("found target " + targetCandidate);
					// found a target break
					break;
				}
				
			}
			
			// end loop to find target
			if (!dropTarget) {
				//trace("Group not found. Setting to application");
				dropTarget = topLevelContainer;
			}
			
			return dropTarget;
		}

		/**
		 * Finds the first visual element under the point. 
		 * Selection manager also has a method like this. 
		 * */
		public function findTargetUnderPoint(event:MouseEvent):IVisualElement {
			var topLeftEdgePoint:Point;
			var rectangle:Rectangle;
			var isHorizontal:Boolean;
			var isVertical:Boolean;
			var isTile:Boolean;
			var target:Object;
			var numberOfTargets:int;
			
			// get targets under point
			if (adjustMouseOffset) {
				topLeftEdgePoint = new Point(event.stageX-offset.x, event.stageY-offset.y);
			}
			else {
				topLeftEdgePoint = new Point(event.stageX, event.stageY);
			}
			
			// get items under point
			targetsUnderPoint = topLevelApplication.getObjectsUnderPoint(topLeftEdgePoint);
			
			numberOfTargets = targetsUnderPoint.length;
			
			targetsUnderPoint = targetsUnderPoint.reverse();
			
			// loop through objects under pointer from the highest to the lowest
			outerloop: 
			
			////////////////////////////////////////////////////////////
			// find first available group
			////////////////////////////////////////////////////////////
			for (var i:int;i<numberOfTargets;i++) {
				target = targetsUnderPoint[i];
				//trace(i + " of " + length+ " target:"+NameUtil.getUnqualifiedClassName(target));
				
				if (targetApplication.contains(DisplayObject(target))) {
					//trace(i + " parent application is " + parentApplication);
					//trace(i + " parent application contains " + target);
				}
				else {
					//trace(i + " parent application does not contain " + target);
					continue;
				}
				
				// check if target is a group
				if (target is GroupBase) {
					groupBase = target as GroupBase;
					
					// skip skins
					if (target is Skin && !includeSkins) {
						continue;
					}
					
					// we found a group
					dropTarget = target;
					
					// check the type
					if (groupBase) {
						dropLayout = groupBase.layout;
						
						// reset group layout values
						isTile = isVertical = isHorizontal = false;
						
						if (dropLayout is HorizontalLayout) {
							isHorizontal = true;
						}
						else if (dropLayout is VerticalLayout) {
							isVertical = true;
						}
						else if (dropLayout is TileLayout) {
							isTile = true;
						}
					}
					
					//trace("found target " + targetCandidate);
					// found a target break
					break;
				}
			}
			
			// end loop to find target
			
			if (!dropTarget) {
				//trace("Group not found. Setting to application");
				dropTarget = targetApplication;
			}
			else {
				//trace("Target found. Target is " + targetCandidate);
			}
			
			return dropTarget as IVisualElement;
		}
		
		private var _displayList:Array;
		private var setDragManagerOffset:Boolean = false;
		
		public var hideDragInitiatorOnDrag:Boolean = true;
		public var dropShadowFilter:DropShadowFilter = new DropShadowFilter(4, 45, 0, 1, 2, 2, .3);
		public var addDropShadow:Boolean = true;

		public var componentTree:ComponentDescription;

		private var distanceFromLeft:int;

		private var distanceFromTop:int;
		private static var _instance:DragManagerUtil;
		
		public var dragging:Boolean;

		private var snapX:Number;

		private var snapY:Number;

		private var snapRight:Number;

		private var snapBottom:Number;

		private var snapVerticalCenter:Number;

		private var snapHorizontalCenter:Number;
		
		private var snapBaseline:Number;
		
		public var leftDifference:Number;
		
		public var topDifference:Number;
		
		public var rightDifference:Number;
		
		public var bottomDifference:Number;
		
		public var horizontalDifference:Number;
		
		public var verticalDifference:Number;
		
		public var snapThreshold:int = 6;
		
		public var snapToNearbyElements:Boolean;

		
		/**
		 * Gets the display list. The parentApplication needs to be set
		 * or this returns null. 
		 * */
		public function get displayList():Array {
			
			return _displayList; 
		}
		
		/**
		 * @private
		 * */
		public function set displayList(value:Array):void {
			if (_displayList == value)
				return;
			_displayList = value;
		}
		
		/**
		 * @see com.flexcapacitor.utils.DisplayObjectUtils#enableDragBehaviorOnDisplayList
		 * */
		public function addGroupListeners(element:IVisualElement):void {
			//enableDragBehaviorOnDisplayList(displayObject);
			applicationGroups = DisplayObjectUtils.enableDragBehaviorOnDisplayList(element, true);
		}
		
		public function removeGroupListeners(element:IVisualElement):void {
			//enableDragBehaviorOnDisplayList(displayObject, null, 0, false);
			applicationGroups = DisplayObjectUtils.enableDragBehaviorOnDisplayList(element, false, applicationGroups);
		}
				
		public static function addGroupMouseSupport(group:GroupBase, applicationGroups:Dictionary):void {
			DisplayObjectUtils.addGroupMouseSupport(group, applicationGroups);
			//applicationGroups[group] = new GroupOptions(group.mouseEnabledWhereTransparent);
			//group.mouseEnabledWhereTransparent = true;
			//group.addEventListener(MouseEvent.MOUSE_OUT, enableGroupMouseHandler, false, 0, true);
		}
		
		public static function removeGroupMouseSupport(group:GroupBase, applicationGroups:Dictionary):void {
			DisplayObjectUtils.removeGroupMouseSupport(group, applicationGroups);
			//group.mouseEnabledWhereTransparent = applicationGroups[group].mouseEnabledWhereTransparent;
			//group.removeEventListener(MouseEvent.MOUSE_OUT, enableGroupMouseHandler);
			//applicationGroups[group] = null;
		}
		
		public static function enableGroupMouseHandler(event:MouseEvent):void
		{
			// this is used to enable mouse events where transparent 
		}
		
		/**
		 * Gets the display list
		 * */
		public function getDisplayList(element:Object, parentItem:Object = null, depth:int = 0):Object {
			
			/* 
			if (displayList.length <= depth) {
			displayList.push(new ArrayCollection());
			} */
			
			
			if (!parentItem) {
				parentItem = {name:"root", element:element.parent, children:new ArrayCollection()};
			}
			
			
			if ("numElements" in element) {
				var length:int = element.numElements;
				
				for (var i:int; i < length; i++) {
					var child:Object = element.getElementAt(i);
					var item:Object = {name:"test", element:child, children:new ArrayCollection()};
					
					parentItem.children.addItem(item);
					
					if ("numElements" in child) {
						getDisplayList(child, item, depth + 1);
					}
					
					
					//displayList[depth].push(object);
					
				}
			}
			return parentItem;
		}
		
		/**
		 *  Player doesn't handle this correctly so we have to do it ourselves
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public static function getObjectsUnderPoint(obj:DisplayObject, pt:Point, arr:Array):void
		{
			if (!obj.visible)
				return;
			
			if ((obj is UIComponent) && !UIComponent(obj).$visible)
				return;
			
			if (obj.hitTestPoint(pt.x, pt.y, true))
			{
				if (obj is InteractiveObject && InteractiveObject(obj).mouseEnabled)
					arr.push(obj);
				if (obj is DisplayObjectContainer)
				{
					var doc:DisplayObjectContainer = obj as DisplayObjectContainer;
					if (doc.mouseChildren)
					{
						// we use this test so we can test in other application domains
						if ("rawChildren" in doc)
						{
							var rc:Object = doc["rawChildren"];
							n = rc.numChildren;
							for (i = 0; i < n; i++)
							{
								try
								{
									getObjectsUnderPoint(rc.getChildAt(i), pt, arr);
								}
								catch (e:Error)
								{
									//another sandbox?
								}
							}
						}
						else
						{
							if (doc.numChildren)
							{
								var n:int = doc.numChildren;
								for (var i:int = 0; i < n; i++)
								{
									try
									{
										var child:DisplayObject = doc.getChildAt(i);
										getObjectsUnderPoint(child, pt, arr);
									}
									catch (e:Error)
									{
										//another sandbox?
									}
								}
							}
						}
					}
				}
			}
		}
		
		public var fadeDropIndicatorAnimation:Fade;
		public var fadeDropIndicatorAnimationDuration:int = 150;
		public var animateSnapToEdge:Boolean = true; 
		public var snapToEdgeAnimation:Animate;
		public var snapToEdgeAnimationDuration:int = 250;
		public var snapToEdgeAnimationStartDelay:int = 0;
		public var snapToEdgeAnimationEaser:IEaser = new Power();//new Elastic();//new Sine(.75);// = new Bounce();
		private var snapPointsCache:Dictionary = new Dictionary(true);

		private var replaceImageFilterIndex:int;
		
		public function animateSnapPoint(target:Object, newPoint:Point, oldPoint:Point = null):void {
			var snapMotionPaths:Vector.<MotionPath>;
			var snapHorizontalPath:SimpleMotionPath;
			var snapVerticalPath:SimpleMotionPath;
			
			if (snapToEdgeAnimation==null) {
				snapToEdgeAnimation = new Animate();
			}
			snapToEdgeAnimation.addEventListener(EffectEvent.EFFECT_END, snapToEdgeAnimation_effectEndHandler);
			snapToEdgeAnimation.duration = snapToEdgeAnimationDuration;
			snapToEdgeAnimation.startDelay = snapToEdgeAnimationStartDelay;
			snapToEdgeAnimation.easer = snapToEdgeAnimationEaser;
			
			if (oldPoint) {
				snapHorizontalPath = new SimpleMotionPath("x", oldPoint.x, newPoint.x);
				snapVerticalPath = new SimpleMotionPath("y", oldPoint.y, newPoint.y);
			}
			else {
				snapHorizontalPath = new SimpleMotionPath("x", null, newPoint.x);
				snapVerticalPath = new SimpleMotionPath("y", null, newPoint.y);
			}
			
			snapMotionPaths = Vector.<MotionPath>([snapHorizontalPath, snapVerticalPath]);
			snapToEdgeAnimation.motionPaths = snapMotionPaths;
			snapToEdgeAnimation.play([target]);
			Radiate.hideToolsLayer();
		}
		
		protected function snapToEdgeAnimation_effectEndHandler(event:Event):void {
			snapToEdgeAnimation.removeEventListener(EffectEvent.EFFECT_END, snapToEdgeAnimation_effectEndHandler);
			fadeOutDropIndicator();
			//Radiate.showToolsLayer();
			///Radiate.updateSelection(Radiate.instance.target);
		}
		
		protected function fadeDropIndicatorAnimation_effectEndHandler(event:Event):void {
			fadeDropIndicatorAnimation.removeEventListener(EffectEvent.EFFECT_END, fadeDropIndicatorAnimation_effectEndHandler);
			destroyDropIndicator();
			Radiate.showToolsLayer();
			Radiate.updateSelection(Radiate.instance.target);
		}
		
		public static function getInstance():DragManagerUtil {
			if (_instance==null) _instance = new DragManagerUtil();
			return _instance;
		}
		
		/**
		 * Create a duplicate and place it in the same location 
		 * */
		public static function createGraphicElementProxy(graphicElement:IGraphicElement, transparent:Boolean = true, fillColor:uint = 0xFFFFFFFF, useLocalSpace:Boolean = true, clipRectangle:Rectangle = null):Image {
			var bitmapData:BitmapData = DisplayObjectUtils.getGraphicElementBitmapData(graphicElement as IGraphicElement, transparent, fillColor, useLocalSpace, clipRectangle);
			var container:Object = graphicElement.owner ? graphicElement.owner : graphicElement.parent;
			var image:Image = new Image();
			var x:Number;
			var y:Number;
			image.source = bitmapData;
			//image.includeInLayout = false;
			x = graphicElement.getLayoutBoundsX();
			y = graphicElement.getLayoutBoundsY();
			
			image.x = x;
			image.y = y;
			//image.width = bitmapData.width;
			//image.height = bitmapData.height;
			
			if (container is IVisualElementContainer) {
				container.addElement(image);
			}
			else if (container is DisplayObjectContainer) {
				container.addChild(image);
			}
			
			if (container is IInvalidating) {
				IInvalidating(container).validateNow();
			}
			
			return image;
		}
	}
}
