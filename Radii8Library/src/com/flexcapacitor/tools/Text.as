
package com.flexcapacitor.tools {
	import com.flexcapacitor.components.DocumentContainer;
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.events.DragDropEvent;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.managers.HistoryManager;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.tools.supportClasses.VisualElementHandle;
	import com.flexcapacitor.tools.supportClasses.VisualElementRotationHandle;
	import com.flexcapacitor.utils.ClassUtils;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.DragManagerUtil;
	import com.flexcapacitor.utils.MXMLDocumentConstants;
	import com.flexcapacitor.utils.supportClasses.ComponentDefinition;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	import com.flexcapacitor.utils.supportClasses.ISelectionGroup;
	import com.flexcapacitor.utils.supportClasses.TargetSelectionGroup;
	import com.flexcapacitor.utils.supportClasses.log;
	import com.flexcapacitor.utils.supportClasses.logTarget;
	import com.roguedevelopment.DisplayModel;
	import com.roguedevelopment.DragGeometry;
	import com.roguedevelopment.Flex4ChildManager;
	import com.roguedevelopment.Flex4HandleFactory;
	import com.roguedevelopment.IHandle;
	import com.roguedevelopment.ObjectChangedEvent;
	import com.roguedevelopment.ObjectHandles;
	import com.roguedevelopment.ObjectHandlesSelectionManager;
	import com.roguedevelopment.constraints.MaintainProportionConstraint;
	import com.roguedevelopment.constraints.SizeConstraint;
	import com.roguedevelopment.constraints.SnapToGridConstraint;
	import com.roguedevelopment.decorators.AlignmentDecorator;
	import com.roguedevelopment.decorators.DecoratorManager;
	import com.roguedevelopment.decorators.ObjectLinesDecorator;
	import com.roguedevelopment.decorators.OutlineDecorator;
	import com.roguedevelopment.decorators.WebDecorator;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Dictionary;
	
	import mx.containers.TabNavigator;
	import mx.core.EventPriority;
	import mx.core.FTETextField;
	import mx.core.FlexGlobals;
	import mx.core.FlexHTMLLoader;
	import mx.core.FlexSprite;
	import mx.core.IFlexDisplayObject;
	import mx.core.ILayoutElement;
	import mx.core.IUIComponent;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	import mx.managers.ILayoutManagerClient;
	import mx.managers.ISystemManager;
	import mx.managers.LayoutManager;
	import mx.managers.PopUpManager;
	import mx.managers.SystemManager;
	import mx.managers.SystemManagerGlobals;
	
	import spark.components.Application;
	import spark.components.ComboBox;
	import spark.components.DataGrid;
	import spark.components.Image;
	import spark.components.List;
	import spark.components.RichEditableText;
	import spark.components.Scroller;
	import spark.components.TextArea;
	import spark.components.VideoPlayer;
	import spark.components.supportClasses.GroupBase;
	import spark.components.supportClasses.InvalidatingSprite;
	import spark.components.supportClasses.ItemRenderer;
	import spark.components.supportClasses.ListBase;
	import spark.components.supportClasses.SkinnableTextBase;
	import spark.components.supportClasses.TextBase;
	import spark.core.IEditableText;
	import spark.core.IGraphicElement;
	import spark.layouts.BasicLayout;
	import spark.layouts.supportClasses.LayoutBase;
	import spark.primitives.supportClasses.GraphicElement;
	import spark.skins.spark.ListDropIndicator;
		
	/**
		 Alex Harui Tue, 04 Mar 2008 21:03:35 -0800
	
	For the record, so there is no more guessing:
	
	 
	1)       The Application or WindowedApplication is not the top-level
	window and does not parent popup and thus events from popups do not
	bubble through the application
	
	2)       SystemManager is the top-level window, and all events from all
	display objects bubble through the SM unless their propagation has been
	stopped
	
	3)       Capture phase listeners on the SystemManager should get all
	events for all child display objects
	
	4)       If no display object has focus, but the player does have focus,
	then the Stage dispatches keyboard events which will not be caught by a
	listener on SystemManager
	
	5)       Capture phase listeners on the Stage will not catch events
	dispatched from the Stage, only events dispatched by children of the
	Stage and thus if no display object has focus, there is no place to hook
	a capture-phase listener that will catch the keyboard events dispatched
	from the stage.
	
	 
	This is why Rick's suggestion of both a capture and non-capture phase
	listener on stage is correct.
	
	Stage.addEventListener( KeyboardEvent.KEY_DOWN, handleKeyDn, true );

	Stage.addEventListener( KeyboardEvent.KEY_DOWN, handleKeyDn, false );
	* */
	
	
	/**
	 * Shows the text editor when clicking on a text field
	 * or adds a text field when not clicking on a text field
	 * */
	public class Text extends FlexSprite implements ITool {
		
		
		public function Text() {
			
		}
		
		private var _icon:Class = Radii8LibraryToolAssets.Text;
		
		public function get icon():Class {
			return _icon;
		}
		
		/**
		 * The radiate instance.
		 * */
		public var radiate:Radiate;
		
		public static var debug:Boolean;
		
		/**
		 * The document
		 * */
		public var document:IDocument;
		
		/**
		 * The application
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
		 * Highlights items that are locked
		 * */
		public var highlightLockedItems:Boolean = true;
		
		/**
		 * Reference to the current or last target.
		 * */
		public var lastTarget:Object;
		
		/**
		 * Sets to focus for keyboard events. 
		 * */
		public var setFocusOnSelect:Boolean = true;
		
		/**
		 * Indicates if the group should be selected
		 * */
		public var selectGroup:Boolean = true;
		
		
		/**
		 * Enable this tool. 
		 * */
		public function enable():void {
			if (debug) {
				log();
			}
			radiate = Radiate.getInstance();
			removeRadiateListeners();
			
			if (radiate.selectedDocument) {
				updateDocument(radiate.selectedDocument);
			}
			
			if (!dragManagerInstance) {
				dragManagerInstance = DragManagerUtil.getInstance();
			}
			
			addRadiateListeners();
			addListeners();
			
			Mouse.cursor = MouseCursor.IBEAM;
		}
		
		
		
		/**
		 * Disable this tool.
		 * */
		public function disable():void {
			if (debug) {
				log();
			}
			removeRadiateListeners();
			removeListeners();
		}
		
		
		/**
		 * Adds listeners to radiate instance
		 * */
		public function addRadiateListeners():void {
			if (debug) {
				log();
			}
			radiate = Radiate.getInstance();
			
			// handle events last so that we get correct size
			radiate.addEventListener(RadiateEvent.DOCUMENT_CHANGE, 		documentChangeHandler, 	false, EventPriority.DEFAULT_HANDLER, true);
			radiate.addEventListener(RadiateEvent.DOCUMENT_CLOSE, 		documentCloseHandler, 	false, EventPriority.DEFAULT_HANDLER, true);
			radiate.addEventListener(RadiateEvent.TARGET_CHANGE, 		targetChangeHandler, 	false, EventPriority.DEFAULT_HANDLER, true);
			radiate.addEventListener(RadiateEvent.SCALE_CHANGE, 		scaleChangeHandler, 	false, EventPriority.DEFAULT_HANDLER, true);
			radiate.addEventListener(RadiateEvent.DOCUMENT_SIZE_CHANGE, scaleChangeHandler, 	false, EventPriority.DEFAULT_HANDLER, true);
			
			radiate.addEventListener(RadiateEvent.HISTORY_CHANGE, 		historyEventHandler, 	false, EventPriority.DEFAULT_HANDLER, true);
			radiate.addEventListener(RadiateEvent.BEGINNING_OF_UNDO_HISTORY, beginningOfUndoHistoryHandler, false, EventPriority.DEFAULT_HANDLER, true);
			radiate.addEventListener(RadiateEvent.END_OF_UNDO_HISTORY, 	endOfUndoHistoryHandler, false, EventPriority.DEFAULT_HANDLER, true);
		}
		
		protected function beginningOfUndoHistoryHandler(event:Event):void
		{
			
			if (debug) {
				log();
			}
		}
		
		protected function endOfUndoHistoryHandler(event:Event):void
		{
			
			if (debug) {
				log();
			}
		}
		
		/**
		 * Removes listeners from radiate instance
		 * */
		public function removeRadiateListeners():void {
			if (debug) {
				log();
			}
			radiate = Radiate.getInstance();
			
			radiate.removeEventListener(RadiateEvent.DOCUMENT_CHANGE, 		documentChangeHandler);
			radiate.removeEventListener(RadiateEvent.DOCUMENT_CLOSE, 		documentCloseHandler);
			radiate.removeEventListener(RadiateEvent.TARGET_CHANGE, 		targetChangeHandler);
			radiate.removeEventListener(RadiateEvent.SCALE_CHANGE, 			scaleChangeHandler);
			radiate.removeEventListener(RadiateEvent.DOCUMENT_SIZE_CHANGE, 	scaleChangeHandler);
			
			radiate.removeEventListener(RadiateEvent.HISTORY_CHANGE, 		historyEventHandler);
			radiate.removeEventListener(RadiateEvent.BEGINNING_OF_UNDO_HISTORY, 	beginningOfUndoHistoryHandler);
			radiate.removeEventListener(RadiateEvent.END_OF_UNDO_HISTORY, 	endOfUndoHistoryHandler);
		}
		
		
		/**
		 * Get stage for keyboard events
		 * */
		public function getCurrentStage(application:Object = null):Stage {
			var systemManager:SystemManager = getCurrentSystemManager(application);
			
			return systemManager.stage;
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
		 * Add mouse listeners
		 * 
		 * EventPriority.CURSOR_MANAGEMENT; //200
		 * EventPriority.BINDING;//100
		 * EventPriority.EFFECT;//-100
		 * EventPriority.DEFAULT;// 0
		 * EventPriority.DEFAULT_HANDLER;//-50
		 * */
		public function addListeners(application:Object = null):void {
			if (debug) {
				log();
			}
			application = application ? application : targetApplication;
			var systemManager:SystemManager = getCurrentSystemManager(application);
			var stage:Stage = getCurrentStage(application);
			
			
			dragManagerInstance.addEventListener(DragDropEvent.DRAG_DROP_COMPLETE, handleDragDropComplete, false, 0, true);
			dragManagerInstance.addEventListener(DragDropEvent.DRAG_END, handleDragEnd, false, 0, true);
			
			systemManager.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
			
		}
		
		protected function handleDragEnd(event:DragDropEvent):void
		{
			if (debug) {
				log();
			}
			
		}
		public function removeListeners(application:Object = null):void {
			if (debug) {
				log();
			}
			application = application ? application : targetApplication;
			var systemManager:SystemManager = getCurrentSystemManager(application);
			var stage:Stage = getCurrentStage(application);
			
			
			dragManagerInstance.removeEventListener(DragDropEvent.DRAG_DROP_COMPLETE, handleDragDropComplete);
			dragManagerInstance.addEventListener(DragDropEvent.DRAG_END, handleDragEnd);
			
			systemManager.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
		}
		
		/**
		 * Add event listeners to new document and remove listeners from previous
		 * */
		public function updateDocument(iDocument:IDocument):void {
			if (debug) {
				log();
			}
			
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
		 * Property change
		 * */
		protected function propertyChangeHandler(event:RadiateEvent):void {

		}
		
		/**
		 * History event 
		 * */
		protected function historyEventHandler(event:RadiateEvent):void {

		}
		
		public var lastTransformState:String;
		
		/**
		 * Scale change
		 * */
		protected function scaleChangeHandler(event:RadiateEvent):void {
			
			
		}
		
		/**
		 * Target change
		 * */
		protected function targetChangeHandler(event:RadiateEvent):void {
			//updateSelectionLater(event.selectedItem);
			//updateSelectionAroundTarget(event.selectedItem);
			//updateTransformRectangle(event.selectedItem);
		}
		
		/**
		 * Document change
		 * */
		protected function documentChangeHandler(event:RadiateEvent):void {
			//clearSelection();
			updateDocument(IDocument(event.selectedItem));
		}
		
		/**
		 * Document close
		 * */
		protected function documentCloseHandler(event:RadiateEvent):void {
			//clearSelection();
		}
		
		/**
		 * Drag helper utility.
		 * */
		private var dragManagerInstance:DragManagerUtil;
		
		public var currentComponentDescription:ComponentDescription;
		
		/**
		 * Handle mouse down on application
		 * */
		public function mouseDownHandler(event:MouseEvent):void {
			if (debug) {
				log();
			}
			var point:Point = new Point(event.stageX, event.stageY);
			var targetsUnderPoint:Array = FlexGlobals.topLevelApplication.getObjectsUnderPoint(point);
			var componentTree:ComponentDescription;
			var componentDescription:ComponentDescription;
			var target:Object = event.target;
			var originalTarget:Object = event.target;
			var items:Array = [];
			var numberOfTargets:int;
			var targetIsTextfield:Boolean;
			var component:Object;
			var componentDefinition:ComponentDefinition;
			var possibleTarget:Object;
			
			/*radiate = Radiate.getInstance();
			targetApplication = radiate.document;*/
			
			// test url for remote image: 
			// http://www.google.com/intl/en_com/images/srpr/logo3w.png
			// file:///Users/monkeypunch/Documents/Adobe%20Flash%20Builder%2045/Radii8/src/assets/images/eye.png
			
			// clicked outside of this container. is there a way to prevent hearing
			// events from everywhere? stage sandboxroot?
			if (!targetApplication || !Object(targetApplication).contains(target)) {
				//trace("does not contain");
				return;
			}
			
			if (target is IHandle) {
				return;
			}
			
			// clicked on background area
			if (target==canvasBackground || target==canvasBackgroundParent) {
				//radiate.setTarget(targetApplication, true);
				return;
			}
			
			
			// check if target is loader
			if (target is Loader) {
				//Error: Request for resource at http://www.google.com/intl/en_com/images/srpr/logo3w.png by requestor from http://www.radii8.com/debug-build/RadiateExample.swf is denied due to lack of policy file permissions.
				
				//*** Security Sandbox Violation ***
				//	Connection to http://www.google.com/intl/en_com/images/srpr/logo3w.png halted - not permitted from http://www.radii8.com/debug-build/RadiateExample.swf
				targetsUnderPoint.push(target);
			}
			
			numberOfTargets = targetsUnderPoint.length;
			targetsUnderPoint = targetsUnderPoint.reverse();
			
			// loop through items under point until we find one on the *component* tree
			componentTree = radiate.selectedDocument.componentDescription;
			
			componentTreeLoop:
			for (var i:int;i<numberOfTargets;i++) {
				target = targetsUnderPoint[i];
				
				// check for window application
				if (!targetApplication.contains(DisplayObject(target))) {
					continue;
				}
				
				// if somehow we get here return null so we don't select anything
				if (target is DocumentContainer) {
					return;
				}
				
				componentDescription = DisplayObjectUtils.getComponentFromDisplayObject(DisplayObject(target), componentTree);
				
				
				// check if target is a text field
				if (componentDescription.instance) {
					possibleTarget = componentDescription.instance;
					
					if (possibleTarget is RichEditableText ||
						possibleTarget is IEditableText ||
						possibleTarget is SkinnableTextBase || 
						possibleTarget is TextBase) {
						
						targetIsTextfield = true;
						break;
					}
				}
				
				// check if over basic layout if not add to application
				componentDescription = componentDescription.getFirstAncestorWithLayout(BasicLayout);
				
				// later we can support other layout types like hgroup or vgroup 
				// we could use layout.calculateDropLocation(mouseEvent) except 
				// we would need to externalize it? (no) to get the drop index position
				// or we could start a drag operation when we enter the target application
				// and cancel the drag if over existing text field
				// check NATIVEDRAGMANAGERimpl for creating a DragEvent() line 700
				break;
					
			}
			
			if (componentDescription) {
				target = componentDescription.instance;
			}
			else {
				
				// if application is not basic layout we can't absolutely position it
				// so we should try and use layout.calculatDropLocation() to get drop index
				// if we can't do that then we should add it to the top or bottom position whichever
				// is mostly in view
				target = targetApplication;
			}
			
			if (debug) {
				logTarget(target);
			}
			
			if (target==null) {
				return;
			}
			
			// if we are over text field show editor
			if (targetIsTextfield) {
				if (debug) {
					logTarget(target, "Showing editor");
				}
				
				Radiate.callAfter(10, Radiate.showTextEditor, target);
			}
			else {
				
				// otherwise add a text field to the stage
				if (debug) {
					log("Creating text field");
				}
				
				// create rich text component
				componentDefinition = Radiate.getComponentType("RichText");
				component = Radiate.createComponentToAdd(document, componentDefinition, false);
				currentComponentDescription = document.getItemDescription(component);
				
				//currentComponentDescription.defaultProperties = componentDefinition.defaultProperties;
				//currentComponentDescription.defaultStyles = componentDefinition.defaultStyles;
				
				
				// get mouse location
				var stagePoint:Point = new Point(event.stageX, event.stageY);
				var dropLocationOnTarget:Point = target.localToGlobal(new Point());
				dropLocationOnTarget = stagePoint.subtract(dropLocationOnTarget);
				
				dropLocationOnTarget = DisplayObjectUtils.getDisplayObjectPosition(target as DisplayObject, event, true);
				var values:Object = {x:dropLocationOnTarget.x, y:dropLocationOnTarget.y, text:"Text"};
				var properties:Array = [MXMLDocumentConstants.X, MXMLDocumentConstants.Y, "text"];
				
				/*
				var point1:Point = new Point(event.localX, event.localY);
				
				var distanceFromLeftEdge:Number = targetApplication.localToGlobal(new Point()).x;
				var distanceFromTopEdge:Number = targetApplication.localToGlobal(new Point()).y;
				
				
				var location:Point = DisplayObjectContainer(target).localToGlobal(new Point());
				var dropPoint:Point = location.subtract(new Point(event.stageX, event.stageY));
				var dropPoint2:Point = location.add(new Point(event.stageX, event.stageY));*/
				//DisplayObjectUtils.getDistanceBetweenDisplayObjects();
				
				Radiate.addElement(component, target, properties, null, null, values, null);
				
				updateTextAfterDragOrAdd(component);
				/*
				dragManagerInstance.draggedItem = component;
				dragManagerInstance.startDrag(component as IUIComponent, targetApplication as Application, event);
				*/
			}
		}
		
		/**
		 * Dispatched after drag drop event. Drag drop can be canceled. If it
		 * is not canceled this event happens. 
		 * */
		protected function handleDragDropComplete(event:DragDropEvent):void {
			updateTextAfterDragOrAdd(event.draggedItem);
		}
		
		private function updateTextAfterDragOrAdd(component:Object):void {
			//var o:LayoutDebugHelper = debugHelper;
			if (debug) {
				logTarget(component);
			}
			
			if (currentComponentDescription==null) return;
			
			// if new component then need to add defaults
			Radiate.setDefaultProperties(currentComponentDescription);
			
			Radiate.updateComponentAfterAdd(document, component);
			
			//o.addElement(component as ILayoutElement);
			dragManagerInstance.removeEventListener(DragDropEvent.DRAG_DROP_COMPLETE, handleDragDropComplete);
			
			radiate.setTarget(component);
			
			if (component is ILayoutManagerClient) {
				LayoutManager.getInstance().validateClient(component as ILayoutManagerClient);
			}
			
			Radiate.callAfter(10, Radiate.showTextEditor, component, true);
		}
		
		/**
		 * Handle mouse up on the stage
		 * */
		protected function mouseUpHandler(event:MouseEvent):void {
			if (debug) {
				log();
			}
			
			var target:Object = event.currentTarget;
			var componentTree:ComponentDescription;
			var componentDescription:ComponentDescription;
			
			componentTree = radiate.selectedDocument.componentDescription;
			componentDescription = DisplayObjectUtils.getComponentFromDisplayObject(DisplayObject(target), componentTree);
			//Radiate.info("Selection Mouse up");
			
			if (target is List) {
				//target.dragEnabled = true; // restore drag and drop if it was enabled
			}
			
			target.visible = true;
			
			// clean up
			if (target.hasEventListener(MouseEvent.MOUSE_UP)) {
				//Radiate.info("1 has event listener");
			}
			
			removeTargetListeners(target);
			
			if (target.hasEventListener(MouseEvent.MOUSE_UP)) {
				//Radiate.info("2 has event listener");
			}
			else {
				//Radiate.info("listener removed");
			}
			
			var actualTarget:GraphicElement;
			if (target is InvalidatingSprite) {
				actualTarget = currentComponentDescription && currentComponentDescription.instance ? currentComponentDescription.instance as GraphicElement : null;
				componentDescription = document.getItemDescription(target);
				
				if (componentDescription!=null) {
					target = componentDescription.instance;
				}
				else if (actualTarget is GraphicElement && actualTarget.displayObject==target) {
					target = actualTarget;
				}
			}
			
			
			// select only groups or items on the application
			if (selectGroup) {
				
				// if parent is application let user select it
				if (componentDescription.parent==componentTree) {
					// it's on the root so we're good
				}
				else if (componentDescription.instance is IVisualElementContainer) {
					// it's a group so we're good
				}
				else {
					// select group container
					componentDescription = componentDescription.parent;
					target = componentDescription.instance;
				}
			}
			
		}
		
		/**
		 * Remove target event listeners. 
		 * */
		public function removeTargetListeners(target:Object = null):void {
			if (debug) {
				log();
			}
			target = target ? target : lastTarget;
			
			if (target) {
				target.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			}
			
		}
		
		
	}
}

