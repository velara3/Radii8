package com.flexcapacitor.tools {
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.managers.HistoryManager;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDefinition;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	import com.flexcapacitor.utils.supportClasses.log;
	import com.flexcapacitor.views.IInspector;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import mx.containers.TabNavigator;
	import mx.controls.ToolTip;
	import mx.core.EventPriority;
	import mx.core.FlexGlobals;
	import mx.core.FlexSprite;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.events.SandboxMouseEvent;
	import mx.graphics.SolidColorStroke;
	import mx.managers.SystemManager;
	import mx.managers.SystemManagerGlobals;
	import mx.managers.ToolTipManager;
	
	import spark.components.Application;
	import spark.primitives.supportClasses.StrokedElement;
	
	/**
	 * Draws a rectangle used for selection
	 * */
	public class Line extends FlexSprite implements ITool {
		
		public function Line()
		{
			
		}
		
		private var _icon:Class = Radii8LibraryToolAssets.Line;
		
		public function get icon():Class {
			return _icon;
		}
		
		public var debug:Boolean;
		public var mouseDownPoint:Point = new Point();
		public var applicationPoint:Point = new Point();
		public var localStartPoint:Point = new Point();
		public var line:UIComponent;
		public var isOverApplication:Boolean;
		public var isOverCanvasBackground:Boolean;
		public var isDragging:Boolean;
		public var isDrawing:Boolean;
		public var isMouseDown:Boolean;
		public var targetApplication:Object;
		public var toolLayer:IVisualElementContainer;
		public var document:IDocument;
		public var canvasBackground:Object;
		
		public var startX:int;
		public var startY:int;
		public var endX:int;
		public var endY:int;
		
		public var systemManager:SystemManager;
		public var stageReference:Stage;
		
		public var lineColor:Number = 0x000000;
		public var lineWeight:Number = 1;
		
		/**
		 * Tooltip when using popup
		 **/
		public var toolTipPopUp:ToolTip;
		
		/**
		 * Recreate ruler tooltip if needed. If an app has tool tips 
		 * it will destroy the current tool tip we are using for the ruler.
		 * Setting this to true takes back the tool tip. 
		 **/
		public var recreateToolTipIfNeeded:Boolean = true;
		
		/**
		 * Minimum tool tip width
		 * */
		public var minToolTipWidth:int = 70;
		
		public var inspector:IInspector;
		
		public var radiate:Radiate;
		
		public function enable():void {
			
			if (systemManager==null) {
				systemManager = getSystemManager();
			}
			
			if (stageReference==null) {
				stageReference = systemManager.stage;
			}
			
			systemManager.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
			systemManager.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
			systemManager.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpSomewhereHandler, false, 0, true);
			
			radiate = Radiate.getInstance();
			
			if (radiate.selectedDocument) {
				updateDocument(radiate.selectedDocument);
			}
			
			Mouse.cursor = MouseCursor.AUTO;
			
			addRadiateListeners();
			addCanvasListeners();
			addKeyboardListeners();
		}
		
		public function disable():void {
			
			if (systemManager==null) {
				systemManager = getSystemManager();
			}
			
			systemManager.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			systemManager.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			systemManager.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpSomewhereHandler);
			
			removeRadiateListeners();
			removeCanvasListeners();
			removeKeyboardListeners();
			removeLine();
		}
		
		/**
		 * Add canvas listeners for scrolling
		 * */
		public function addCanvasListeners():void {
			removeCanvasListeners();
			
			if (radiate && radiate.toolLayer) {
				toolLayer = radiate.toolLayer;
			}
			
			if (radiate && radiate.canvasBackground) {
				canvasBackground = radiate.canvasBackground;
			}
		}
		
		/**
		 * Removes canvas listeners
		 * */
		public function removeCanvasListeners():void {
			
		}
		
		/**
		 * Add event listeners to new document and remove listeners from previous
		 * */
		public function updateDocument(iDocument:IDocument):void {
			
			// remove listeners
			if (iDocument==null || 
				(targetApplication && iDocument && targetApplication!=iDocument.instance)) {
				//removeAllListeners();
			}
			
			document = iDocument;
			targetApplication = iDocument ? iDocument.instance : null;
			
			// add listeners
			if (targetApplication) {
				//addAllListeners();
			}
			
		}
		
		/**
		 * Adds listeners to radiate instance
		 * */
		public function addRadiateListeners():void {
			radiate.addEventListener(RadiateEvent.DOCUMENT_CHANGE, 	documentChangeHandler, 	false, EventPriority.DEFAULT_HANDLER, true);
			radiate.addEventListener(RadiateEvent.DOCUMENT_CLOSE, 	documentCloseHandler, 	false, EventPriority.DEFAULT_HANDLER, true);
		}
		
		/**
		 * Removes listeners from radiate instance
		 * */
		public function removeRadiateListeners():void {
			radiate.removeEventListener(RadiateEvent.DOCUMENT_CHANGE, 	documentChangeHandler);
			radiate.removeEventListener(RadiateEvent.DOCUMENT_CLOSE, 	documentCloseHandler);
		}
		
		/**
		 * Add keyboard listeners
		 * 
		 * EventPriority.CURSOR_MANAGEMENT; //200
		 * EventPriority.BINDING;//100
		 * EventPriority.EFFECT;//-100
		 * EventPriority.DEFAULT;// 0
		 * EventPriority.DEFAULT_HANDLER;//-50
		 * */
		public function addKeyboardListeners(application:Object = null):void {
			//var systemManager:SystemManager = getCurrentSystemManager(application);
			//var stage:Stage = getSystemManager().stage;
			
			//trace("1 sm hasListeners:" + systemManager.hasEventListener(KeyboardEvent.KEY_DOWN));
			systemManager.addEventListener(KeyboardEvent.KEY_DOWN, keyUpHandler, false, 0, true);
			systemManager.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler, false, 0, true);
			//trace("2 sm hasListeners:" + systemManager.hasEventListener(KeyboardEvent.KEY_DOWN));
			
			stageReference.addEventListener(KeyboardEvent.KEY_DOWN, keyUpHandler, false, 0, true);
			//trace("3 stage hasListeners:" + stageReference.hasEventListener(KeyboardEvent.KEY_DOWN));
		}
		
		/**
		 * Removes keyboard listeners
		 * */
		public function removeKeyboardListeners(application:Object = null):void {
			//var systemManager:SystemManager = getCurrentSystemManager(application);
			
			systemManager.removeEventListener(KeyboardEvent.KEY_DOWN, keyUpHandler);
			systemManager.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			
			stageReference.removeEventListener(KeyboardEvent.KEY_DOWN, keyUpHandler);
		}
		
		/**
		 * Get top most system manager or system manager from passed in application
		 * */
		public function getCurrentSystemManager(application:Object = null):SystemManager {
			
			// get system manager from application
			if (application && "systemManager" in application) {
				return application.systemManager;
			}
			
			// get system manager from top level system managers
			return SystemManagerGlobals.topLevelSystemManagers[0];
		}
		
		/**
		 * Handles keyboard position changes. 
		 * Up left right down, etc.
		 * */
		protected function keyUpHandler(event:KeyboardEvent):void {
			if (debug) {
				log("Key: " + event.keyCode);
			}
			
			var constant:int;
			var index:int;
			var applicable:Boolean;
			var systemManager:SystemManager;
			var topApplication:Object;
			var focusedObject:Object;
			var isApplication:Boolean;
			var actionOccured:Boolean;
			var eventTarget:Object;
			var eventCurrentTarget:Object;
			var tabNav:TabNavigator;
			var componentDescription:ComponentDescription;
			var isGraphicElement:Boolean;
			var targets:Array;
			var keyCode:uint;
			
			topApplication = FlexGlobals.topLevelApplication;
			focusedObject = topApplication.focusManager.getFocus();
			eventTarget = event.target;
			eventCurrentTarget = event.currentTarget;
			tabNav = radiate.documentsTabNavigator;
			systemManager = SystemManagerGlobals.topLevelSystemManagers[0];
			constant = event.shiftKey ? 10 : 1;
			keyCode = event.keyCode;
			
			if (radiate==null) {
				return;
			}
			
			//componentDescription = DisplayObjectUtils.getComponentFromDisplayObject(DisplayObject(eventTarget), componentTree);
			
			// capture key presses when application has focus
			if (eventTarget is Stage) {
				if (focusedObject==null) {
					applicable = true;
				}
				else if (targetApplication && targetApplication.contains(focusedObject)) {
					applicable = true;
				}
				else if (eventCurrentTarget is Stage) {
					applicable = true;
				}
			}
			
			if (focusedObject is Application) {
				isApplication = true;
			}
			
			// check that the target is in the target application
			if (isApplication || 
				(targetApplication && 
					(targetApplication.contains(eventCurrentTarget) || 
						targetApplication.contains(eventTarget)))) {
				applicable = true;
			}
			else if (eventTarget==tabNav) {
				if (componentDescription && 
					componentDescription.isGraphicElement) {
					isGraphicElement = true;
				}
				applicable = true;
			}
			else {
				return;
			}
			
			targets = radiate.targets;
			
			// Radiate.info("Selection key up");
			if (targets.length>0) {
				applicable = true;
			}
			
			if (event.keyCode==Keyboard.Z && event.ctrlKey && !event.shiftKey) {
				HistoryManager.undo(radiate.selectedDocument, true);
				actionOccured = true;
			}
			else if (event.keyCode==Keyboard.Z && event.ctrlKey && event.shiftKey) {
				HistoryManager.redo(radiate.selectedDocument, true);
				actionOccured = true;
			}
			else if (event.keyCode==Keyboard.Y && event.ctrlKey) {
				HistoryManager.redo(radiate.selectedDocument, true); // legacy redo
				actionOccured = true;
			}
			
			if (applicable && actionOccured) {
				event.stopImmediatePropagation();
				event.stopPropagation();
				event.preventDefault();
				//dispatchKeyEvent(event);
			}
			
			if (actionOccured) {
				//dispathKeyEvent(event);
			}
		}
		
		
		/**
		 * Handle mouse down on application
		 * 
		 * One scenario: 
		 * 
		 * 1. Drawing a line
		 * */
		public function mouseDownHandler(event:MouseEvent):void {
			var eventTarget:DisplayObject = event.target as DisplayObject;
			
			isMouseDown = true;
			isOverApplication = false;
			isOverCanvasBackground = false;
			
			mouseDownPoint.x = event.stageX;
			mouseDownPoint.y = event.stageY;
			
			if (line==null) {
				line = new UIComponent();
			}
				
			if (eventTarget==targetApplication || DisplayObjectContainer(targetApplication).contains(eventTarget)) {
				isOverApplication = true;
				isOverCanvasBackground = true;
			}
			else if (DisplayObjectContainer(canvasBackground).contains(eventTarget)){
				isOverCanvasBackground = true;
			}
			
			if (!isOverCanvasBackground) {
				return;
			}
			
			
			//mouseDownPoint = new Point(event.stageX, event.stageY);
			localStartPoint = DisplayObjectUtils.getDisplayObjectPosition(targetApplication as DisplayObject, event);
			
			systemManager.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		
		/**
		 * Handle mouse move on application
		 * */
		public function mouseMoveHandler(event:MouseEvent):void {
			var displayObject:DisplayObject = event.currentTarget as DisplayObject;
			
			if (isMouseDown) {
				
				
				if (isOverApplication) {
					if (line.parent==null) {
						addLine();
					}
					isDrawing = true;
					updateArrowPosition(event);
				}
			}
		}
		
		/**
		 * Handles mouse up
		 * */
		public function mouseUpHandler(event:MouseEvent):void {
			var componentInstance:Object;
			var definition:ComponentDefinition;
			var properties:Array;
			var propertiesObject:Object;
			var setPrimitivesDefaults:Boolean;
			var tooSmall:Boolean;
			var stroke:SolidColorStroke;
			
			//trace("4 sm hasListeners:" + systemManager.hasEventListener(KeyboardEvent.KEY_DOWN));
			//trace("5 stage hasListeners:" + stageReference.hasEventListener(KeyboardEvent.KEY_DOWN));
			
			if (isMouseDown && isOverApplication) {
				systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
				
				if (isDrawing && event) {
					//if (isOverApplication && event) || (isOverCanvasBackground && event)) {
					
					updateArrowPosition(event);
					
					if (toolTipPopUp && toolTipPopUp.stage) {
						ToolTipManager.destroyToolTip(toolTipPopUp);
						ToolTipManager.currentToolTip = null;
						toolTipPopUp = null;
					}
				
					tooSmall = (Math.abs(startX-event.stageX) + Math.abs(startY-event.stageY)) <= 4 && scaleX<=1 && scaleY<=1;
					
					if (!tooSmall) {
						removeLine();
						
						definition = Radiate.getComponentType("Line");
						componentInstance = Radiate.createComponentToAdd(radiate.selectedDocument, definition, true);
						
						properties = ["xFrom","xTo","yFrom","yTo"];
						propertiesObject = {};
						
						propertiesObject.xFrom 	= startX;
						propertiesObject.xTo 	= endX;
						propertiesObject.yFrom 	= startY;
						propertiesObject.yTo 	= endY;
						
						setPrimitivesDefaults = true;
						
						if (componentInstance is StrokedElement && componentInstance.stroke==null) {
							stroke = new SolidColorStroke();
							stroke.color = lineColor;
							stroke.weight = lineWeight;
							componentInstance.stroke = stroke;
						}
						
						Radiate.addElement(componentInstance, 
							radiate.selectedDocument.instance, 
							properties, 
							null, 
							null, 
							propertiesObject);
						
						Radiate.updateComponentAfterAdd(radiate.selectedDocument, componentInstance, false, false, setPrimitivesDefaults);
						
						
						radiate.setTarget(componentInstance);
					}
				}
			}
			
			removeLine();
			
			startX = 0;
			startY = 0;
			endX = 0;
			endY = 0;
			
			isDrawing				= false;
			isMouseDown 			= false;
			isOverApplication		= false;
			isOverCanvasBackground 	= false;
		}
		
		public function mouseUpSomewhereHandler(event:SandboxMouseEvent):void {
			systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			removeLine();
			
			mouseUpHandler(null);
		}
		
		public function addLine():void {
			
			if (line) {
				if (line.parent!=targetApplication) {
					removeLine();
				}
				//trace("adding line");
				targetApplication.addElement(line);
			}
		}
		
		public function removeLine():void {
			
			if (line && line.parent) {
				//trace("removing line:" + line.parent);
				IVisualElementContainer(line.parent).removeElement(line);
				line.graphics.clear();
			}
		}
			
		public function updateArrowPosition(event:MouseEvent):void {
			var distance:Number;
			var deltaX:Number;
			var deltaY:Number;
			var includeAngles:Boolean;
			var angleInDegrees:int;
			var sign:int;
			var angle2:int;
			var message:String;
			var localPoint:Point;
			var scaleX:Number;
			var scaleY:Number;
			
			scaleX = targetApplication.scaleX;
			scaleY = targetApplication.scaleY;
			
			localPoint = DisplayObjectUtils.getDisplayObjectPosition(targetApplication as DisplayObject, event);
			
			endX = localPoint.x/scaleX;
			endY = localPoint.y/scaleY;
			startX = localStartPoint.x/scaleX;
			startY = localStartPoint.y/scaleY;
			deltaX = Number(Number(endX - startX).toFixed(1));
			deltaY = Number(Number(endY - startY).toFixed(1));
			includeAngles = true;
			
			line.graphics.clear();
			line.graphics.lineStyle(lineWeight, lineColor);
			
			
			// This may not be correct. Or we may want to show an alternative degree unit
			//var angleInDegrees:int = Math.abs(Math.atan2(deltaY, deltaX) * 180 / Math.PI);
			angleInDegrees = -(Math.atan2(deltaY, deltaX) * 180 / Math.PI);
			sign = angleInDegrees<0 ? -1 : 1;
			angle2 = Math.atan2(-deltaY, -deltaX) * 180 / Math.PI - 90;
			angle2 = angle2 < 0 ? 360 + angle2 : angle2;
			
			distance = Math.max(Math.abs(startX-endX), Math.abs(startY-endY));
			distance = Number(distance.toFixed(1));
			
			if (event.shiftKey) {
				//angleInDegrees = Math.abs(angleInDegrees);
				
				if (includeAngles) {
					if (angleInDegrees>=0 && angleInDegrees<=26) {
						endY = startY;
						angleInDegrees = 0;
						angle2 = 90;
					}
					else if (angleInDegrees>=26 && angleInDegrees<=63) {
						endX = startX + distance;
						endY = startY + -distance;
						angleInDegrees = 45;
						angle2 = 45;
					}
					else if (angleInDegrees>=63 && angleInDegrees<=116) {
						endX = startX;
						angleInDegrees = 90;
						angle2 = 0;
					}
					else if (angleInDegrees>=116 && angleInDegrees<=154) {
						endX = startX + -distance;
						endY = startY + -distance;
						angleInDegrees = 135;
						angle2 = 315;
					}
					else if (angleInDegrees>=154 && angleInDegrees<=180) {
						endY = startY;
						angleInDegrees = 180;
						angle2 = 270;
					}
					else if (angleInDegrees<=0 && angleInDegrees>=-26) {
						endY = startY;
						angleInDegrees = 0;
						angle2 = 90;
					}
					else if (angleInDegrees<=-26 && angleInDegrees>=-63) {
						endX = startX + distance;
						endY = startY + distance;
						angleInDegrees = -45;
						angle2 = 135;
					}
					else if (angleInDegrees<=-63 && angleInDegrees>=-116) {
						endX = startX;
						angleInDegrees = -90;
						angle2 = 180;
					}
					else if (angleInDegrees<=-116 && angleInDegrees>=-154) {
						endX = startX + -distance;
						endY = startY + distance;
						angleInDegrees = -135;
						angle2 = 125;
					}
					else if (angleInDegrees<=-154 && angleInDegrees>=-180) {
						endY = startY;
						angleInDegrees = -180;
						angle2 = 170;
					}
				}
				else {
					
					if (angleInDegrees>=0 && angleInDegrees<=45) {
						endY = startY;
						angleInDegrees = 0;
						angle2 = 90;
					}
					else if (angleInDegrees>=45 && angleInDegrees<=135) {
						endX = startX;
						angleInDegrees = 90;
						angle2 = 0;
					}
					else if (angleInDegrees>=135 && angleInDegrees<=180) {
						endY = startY;
						angleInDegrees = 180;
						angle2 = 270;
					}
					else if (angleInDegrees<=0 && angleInDegrees>=-45) {
						endY = startY;
						angleInDegrees = 0;
						angle2 = 90;
					}
					else if (angleInDegrees<=-45 && angleInDegrees>=-135) {
						endX = startX;
						angleInDegrees = -90;
						angle2 = 180;
					}
					else if (angleInDegrees<=-135 && angleInDegrees>=-180) {
						endY = startY;
						angleInDegrees = -180;
						angle2 = 270;
					}
				}
			}
			
			line.graphics.moveTo(startX, startY);
			line.graphics.lineTo(endX, endY);
			
			//message = "" + distance + "px";
			message = "w:" + deltaX + " h:" + deltaY;
			//message += "\nx:" + targetX + ",y:" + targetY;
			message += "\n" + angle2 + "°" + "  " + angleInDegrees + "°";
			
			if (ToolTipManager.currentToolTip || recreateToolTipIfNeeded) {
				
				if (!ToolTipManager.currentToolTip && recreateToolTipIfNeeded) {
					createLineToolTip(event.stageX, event.stageY);
				}
				
				ToolTipManager.currentToolTip.x = event.stageX + 10;
				ToolTipManager.currentToolTip.y = event.stageY;
				toolTipPopUp.text = message;
			}
		}
		
		/**
		 * Creates a tool tip and sets the toolTipPopUp property
		 * */
		public function createLineToolTip(x:Number, y:Number):void {
			toolTipPopUp = ToolTipManager.createToolTip("", x, y) as ToolTip;
			toolTipPopUp.minWidth = minToolTipWidth;
			ToolTipManager.currentToolTip = toolTipPopUp;
		}
		
		public function getSystemManager():SystemManager {
			var systemManager:SystemManager = FlexGlobals.topLevelApplication.systemManager;
			var marshallPlanSystemManager:Object = systemManager.getImplementation("mx.managers.IMarshallPlanSystemManager");
			var targetCoordinateSpace:SystemManager;
			
			if (marshallPlanSystemManager && marshallPlanSystemManager.useSWFBridge()) {
				targetCoordinateSpace = systemManager.getSandboxRoot() as SystemManager;
			}
			
			if (targetCoordinateSpace==null) {
				targetCoordinateSpace = systemManager;
			}
			
			return targetCoordinateSpace;
		}
		
		public function getStage():Stage {
			var systemManager:SystemManager = getSystemManager();
			
			return systemManager.stage;
		}
		
		
		/**
		 * Document change
		 * */
		protected function documentChangeHandler(event:RadiateEvent):void {
			updateDocument(IDocument(event.selectedItem));
		}
		
		/**
		 * Document close
		 * */
		protected function documentCloseHandler(event:RadiateEvent):void {
			
		}
	}
}