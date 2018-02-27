package com.flexcapacitor.tools {
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.managers.ComponentManager;
	import com.flexcapacitor.managers.DocumentManager;
	import com.flexcapacitor.model.Document;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDefinition;
	import com.flexcapacitor.utils.supportClasses.log;
	import com.flexcapacitor.views.IInspector;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.display.IGraphicsData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
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
	
	import spark.primitives.Path;
	
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
		public var localStartPointTranslated:Point = new Point();
		public var line:UIComponent;
		public var pathElement:Path;
		public var isOverApplication:Boolean;
		public var isOverCanvasBackground:Boolean;
		public var isDragging:Boolean;
		public var isDrawing:Boolean;
		public var isMouseDown:Boolean;
		public var lastMouseEvent:MouseEvent;
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
		
		public var pixelHinting:Boolean = true;
		public var lineColor:Number = 0x383838;
		public var lineAlpha:Number = 1;
		public var lineWeight:Number = 2;
		
		private var previousPoint:Point = new Point();
		private var drawCommands:Vector.<int>;
		private var pathData:Vector.<Number>;
		public var simplePath:String;
		public var isFreeformDrawing:Boolean = false;
		public var useDynamicGraphicsData:Boolean = true;
		
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
			
			radiate = Radiate.instance;
			
			if (Radiate.selectedDocument) {
				updateDocument(Radiate.selectedDocument);
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
			removePath();
		}
		
		/**
		 * Add canvas listeners for scrolling
		 * */
		public function addCanvasListeners():void {
			removeCanvasListeners();
			
			if (radiate && DocumentManager.toolLayer) {
				toolLayer = DocumentManager.toolLayer;
			}
			
			if (radiate && DocumentManager.canvasBackground) {
				canvasBackground = DocumentManager.canvasBackground;
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
				targetApplication = null;
			}
			
			removeLine();
			removePath();
			
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
			
			if (isMouseDown && lastMouseEvent) {
				lastMouseEvent.shiftKey = event.shiftKey;
				mouseMoveHandler(lastMouseEvent);
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
			
			
			if (line) {
				line.graphics.clear();
			}
			
			if (pathElement) {
				pathElement.data = null;
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
			
			addLine();
			addPath();
			
			//mouseDownPoint = new Point(event.stageX, event.stageY);
			localStartPoint = DisplayObjectUtils.getDisplayObjectPosition(targetApplication as DisplayObject, event);
			localStartPointTranslated = DisplayObjectUtils.getDisplayObjectPosition(targetApplication as DisplayObject, event, true);
			
			systemManager.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			
			if (isFreeformDrawing) {
				pathData = new Vector.<Number>();
				drawCommands = new Vector.<int>();
				drawCommands.push(GraphicsPathCommand.MOVE_TO);
				pathData.push(localStartPointTranslated.x);
				pathData.push(localStartPointTranslated.y);
				previousPoint = new Point(localStartPointTranslated.x, localStartPointTranslated.y);
				simplePath = "M " + localStartPointTranslated.x + " " + localStartPointTranslated.y;
			}
		}
		
		/**
		 * Handle mouse move on application
		 * */
		public function mouseMoveHandler(event:MouseEvent):void {
			var displayObject:DisplayObject = event.currentTarget as DisplayObject;
			
			lastMouseEvent = event;
			
			if (isMouseDown) {
				
				
				if (isOverApplication) {
					if (line.parent==null) {
						addLine();
					}
					
					if (pathElement.parent==null) {
						addPath();
					}
					
					isDrawing = true;
					
					if (isFreeformDrawing) {
						updateLinePosition(event);
					}
					else {
						updateArrowPosition(event);
					}
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
			var tooSmall:Boolean;
			var stroke:SolidColorStroke;
			var setPrimitivesDefaults:Boolean;
			var makeInteractive:Boolean;
			var setComponentDefaults:Boolean;
			var pathString:String;
			var pathDataVector:Vector.<String>;
			
			//trace("4 sm hasListeners:" + systemManager.hasEventListener(KeyboardEvent.KEY_DOWN));
			//trace("5 stage hasListeners:" + stageReference.hasEventListener(KeyboardEvent.KEY_DOWN));
			
			if (isMouseDown && isOverApplication) {
				systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
				
				if (isDrawing && event) {
					
					if (isFreeformDrawing) {
						//updateLinePosition(event);
						
						definition = ComponentManager.getComponentType("Path");
						componentInstance = ComponentManager.createComponentToAdd(Radiate.selectedDocument, definition, setComponentDefaults) as Path;
						//pathElement = componentInstance as Path;
						
						properties = ["data"];
						propertiesObject = {};
						
						if (useDynamicGraphicsData) {
							pathDataVector = getPathData(line.graphics, false);
							pathString = pathDataVector.join(" ");
							pathString = getAdjustedPath(pathElement, pathString);
							
							properties.push("x");
							properties.push("y");
							propertiesObject.x = pathElement.x;
							propertiesObject.y = pathElement.y;
						}
						else {
							pathString = simplePath;
						}
						
						propertiesObject.data = pathString;
						
						stroke = new SolidColorStroke();
						stroke.color = lineColor;
						stroke.weight = lineWeight;
						
						properties.push("stroke");
						propertiesObject.stroke = stroke;
						
						setPrimitivesDefaults = false;
						
						// make interactive in Selection tool (show hand cursor when over line path)
						makeInteractive = false;
						
						ComponentManager.addElement(componentInstance, 
							Radiate.selectedDocument.instance, 
							properties, 
							null, 
							null, 
							propertiesObject);
						
						ComponentManager.updateComponentAfterAdd(Radiate.selectedDocument, componentInstance, false, makeInteractive, setPrimitivesDefaults);
						
						radiate.setTarget(componentInstance);
						
					}
					else {
						//updateArrowPosition(event);
					
						tooSmall = (Math.abs(startX-event.stageX) + Math.abs(startY-event.stageY)) <= 4 && scaleX<=1 && scaleY<=1;
						
						if (!tooSmall) {
							
							definition = ComponentManager.getComponentType("Line");
							componentInstance = ComponentManager.createComponentToAdd(Radiate.selectedDocument, definition, true);
							
							properties = ["xFrom","xTo","yFrom","yTo"];
							propertiesObject = {};
							
							propertiesObject.xFrom 	= startX;
							propertiesObject.xTo 	= endX;
							propertiesObject.yFrom 	= startY;
							propertiesObject.yTo 	= endY;
							
							setPrimitivesDefaults = true;
							
							stroke = new SolidColorStroke();
							stroke.color = lineColor;
							stroke.weight = lineWeight;
							
							properties.push("stroke");
							propertiesObject.stroke = stroke;
							
							ComponentManager.addElement(componentInstance, 
								Radiate.selectedDocument.instance, 
								properties, 
								null, 
								null, 
								propertiesObject);
							
							ComponentManager.updateComponentAfterAdd(Radiate.selectedDocument, componentInstance, false, false, setPrimitivesDefaults);
							
							radiate.setTarget(componentInstance);
						}
						
						if (toolTipPopUp && toolTipPopUp.stage) {
							ToolTipManager.destroyToolTip(toolTipPopUp);
							ToolTipManager.currentToolTip = null;
							toolTipPopUp = null;
						}
					}
				}
				
				// removing too early creates a disappear and reappear effect
				if (event) event.updateAfterEvent();
				
				removePath();
				removeLine();
			}
			
			startX = 0;
			startY = 0;
			endX = 0;
			endY = 0;
			
			isDrawing				= false;
			isMouseDown 			= false;
			isOverApplication		= false;
			isOverCanvasBackground 	= false;
		}
		
		private function getAdjustedPath(path:Path, pathData:String = null):String {
			var pathDataVector:Vector.<String>;
			var offset:Point;
			
			path.left = 0;
			path.top = 0;
			
			if (pathData) {
				path.data = pathData;
			}
			
			//IInvalidating(path.owner).validateNow();
			path.validateNow();
			
			path.left = Math.abs(path.x);
			path.top = Math.abs(path.y);
			
			offset = new Point(path.x, path.y);
			
			pathDataVector = getPathData(Sprite(path.displayObject).graphics, false, offset.x, offset.y);
			
			pathData = pathDataVector.join(" ");
			path.data = pathData;
			
			//path.left = Math.abs(offset.x);
			//path.top = Math.abs(offset.y);
			path.validateNow();
			
			return pathData;
		}
		
		public function mouseUpSomewhereHandler(event:SandboxMouseEvent):void {
			systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			removeLine();
			
			mouseUpHandler(null);
		}
		
		public var translateLine:Boolean = false;
		private var useSimplePath:Boolean = true;
		private var useLocal:Boolean = true;
		
		/**
		 * Updates the line position when using free hand drawing
		 **/
		public function updateLinePosition(event:MouseEvent):void {
			var localPoint:Point;
			var localPointTranslated:Point;
			var scaleX:Number;
			var scaleY:Number;
			var scaledPoint:Point;
			
			scaleX = targetApplication.scaleX;
			scaleY = targetApplication.scaleY;
			
			localPoint = DisplayObjectUtils.getDisplayObjectPosition(targetApplication as DisplayObject, event);
			localPointTranslated = DisplayObjectUtils.getDisplayObjectPosition(targetApplication as DisplayObject, event, translateLine);
			
			line.graphics.lineStyle(lineWeight, lineColor, lineAlpha, pixelHinting);
			line.graphics.moveTo(previousPoint.x, previousPoint.y);
			
			scaledPoint = new Point(localPoint.x/scaleX, localPoint.y/scaleY);
			
			if (pixelHinting) {
				scaledPoint.x = Math.round(scaledPoint.x);
				scaledPoint.y = Math.round(scaledPoint.y);
			}
			
			if (useLocal) {
				line.graphics.lineTo(scaledPoint.x, scaledPoint.y);
				previousPoint.x = scaledPoint.x;
				previousPoint.y = scaledPoint.y;
				
				drawCommands.push(GraphicsPathCommand.LINE_TO);
				pathData.push(scaledPoint.x);
				pathData.push(scaledPoint.y);
				
			}
			
			simplePath += " L " + scaledPoint.x + " " + scaledPoint.y;
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
		
		public function addLine():void {
			
			if (line==null) {
				line = new UIComponent();
			}
			
			if (line) {
				if (line.parent && !targetApplication.contains(line)) {
					removeLine();
				}
				//trace("adding line");
				targetApplication.addElement(line);
				
				if (document is Document) {
					Document(document).addExclusion(line);
				}
			}
			
		}
		
		public function addPath():void {
			
			if (pathElement==null) {
				pathElement = new Path();
				//pathElement.data = "M0 0 L0 100 L 100 100 L 100 0z";
				//pathElement.alwaysCreateDisplayObject = true;
				pathElement.stroke = new SolidColorStroke(0xFF0000, lineWeight);
			}
			
			if (pathElement) {
				if (pathElement.parent && pathElement.displayObject && !targetApplication.contains(pathElement.displayObject)) {
					removePath();
				}
				
				//trace("adding path");
				targetApplication.addElement(pathElement);
				
				if (document is Document) {
					Document(document).addExclusion(pathElement);
				}
			}
		}
		
		public function removeLine():void {
			
			if (line && line.parent) {
				//trace("removing line:" + line.parent);
				IVisualElementContainer(line.parent).removeElement(line);
				line.graphics.clear();
				
				if (document is Document) {
					Document(document).removeExclusion(line);
				}
			}
			
		}
		
		public function removePath():void {
			
			if (pathElement && pathElement.parent) {
				//trace("removing line:" + line.parent);
				IVisualElementContainer(pathElement.parent).removeElement(pathElement);
				//trace("removing path");
				//pathElement.data = null;
				
				if (document is Document) {
					Document(document).removeExclusion(pathElement);
				}
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
			updateDocument(Radiate.selectedDocument);
		}
		
		public function getPathData(graphics:Graphics, recursive:Boolean = false, offsetX:int = 0, offsetY:int = 0):Vector.<String> {
			var graphicsDataVector:Vector.<IGraphicsData>;
			var path:String;
			var graphicsPath:GraphicsPath;
			var index:int;
			var numberOfCommands:int;
			var command:int;
			var pathVector:Vector.<Number>;
			var vectorOfData:Vector.<String>;
			var numberOfGraphics:int;
			
			// this doesn't seem to have the correct path data
			graphicsDataVector = graphics.readGraphicsData(recursive);
			numberOfGraphics = graphicsDataVector && graphicsDataVector.length ? graphicsDataVector.length : 0;
			
			path = "";
			vectorOfData = new Vector.<String>;
			
			for(var i:int;i<numberOfGraphics;i++) {
				graphicsPath = graphicsDataVector[i] as GraphicsPath;
				
				if (graphicsPath==null) continue;
				
				drawCommands = graphicsPath.commands;
				numberOfCommands = drawCommands.length;
				pathVector = graphicsPath.data;
				index = 0;
				
				for (var j:int = 0; j < numberOfCommands; j++) {
					command = drawCommands[j];
					
					switch (command) {
						case GraphicsPathCommand.MOVE_TO:
							//path  += "M" + pathVector[index] + " " + pathVector[index+1];
							vectorOfData.push("M");
							vectorOfData.push(pathVector[index] + offsetX);
							vectorOfData.push(pathVector[index+1] + offsetY);
							index += 2;
							break;
						case GraphicsPathCommand.LINE_TO:
							//path  += "L" + pathVector[index] + " " + pathVector[index+1];
							vectorOfData.push("L");
							vectorOfData.push(pathVector[index] + offsetX);
							vectorOfData.push(pathVector[index+1] + offsetY);
							index += 2;
							break;
						case GraphicsPathCommand.CURVE_TO:
							//path  += "C" + pathVector[index] + " " + pathVector[index+1];
							//path  += " " + pathVector[index+2] + " " + pathVector[index+3];
							vectorOfData.push("C");
							vectorOfData.push(pathVector[index]);
							vectorOfData.push(pathVector[index+1]);
							vectorOfData.push(pathVector[index+2]);
							vectorOfData.push(pathVector[index+3]);
							index += 4;
							break;
						case GraphicsPathCommand.CUBIC_CURVE_TO:
							//path  += "Q" + pathVector[index] + " " + pathVector[index+1];
							//path  += " " + pathVector[index+2] + " " + pathVector[index+3];
							vectorOfData.push("Q");
							vectorOfData.push(pathVector[index]);
							vectorOfData.push(pathVector[index+1]);
							vectorOfData.push(pathVector[index+2]);
							vectorOfData.push(pathVector[index+3]);
							index += 4;
							break;
					}
					
					if (j!=numberOfCommands) {
						//path += " ";
					}
				}
				
				//path += " ";
			}
			
			return vectorOfData;
		}
	}
}