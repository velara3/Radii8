
package com.flexcapacitor.controller {
	import com.flexcapacitor.events.HistoryEvent;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.logging.RadiateLogTarget;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	import com.flexcapacitor.utils.supportClasses.TargetSelectionGroup;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	import mx.core.FlexGlobals;
	import mx.core.IFlexDisplayObject;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.effects.effectClasses.PropertyChanges;
	import mx.logging.AbstractTarget;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.ISystemManager;
	import mx.managers.LayoutManager;
	import mx.managers.PopUpManager;
	import mx.states.AddItems;
	import mx.utils.ArrayUtil;
	
	import spark.components.Application;
	import spark.components.supportClasses.GroupBase;
	import spark.components.supportClasses.ItemRenderer;
	import spark.core.ContentCache;
	import spark.effects.SetAction;
	import spark.layouts.BasicLayout;
	import spark.skins.spark.ListDropIndicator;
	
	use namespace mx_internal;
	
	/**
	 * Dispatched when an item is added to the target
	 * */
	[Event(name="addItem", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when an item is removed from the target
	 * */
	[Event(name="removeTarget", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when the target is changed
	 * */
	[Event(name="targetChange", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when a property on the target is changed
	 * */
	[Event(name="propertyChange", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when a property edit is requested
	 * */
	[Event(name="propertyEdit", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatches events when the target or targets property changes or is about to change. 
	 * This class supports an Undo / Redo history. The architecture is loosely based on 
	 * the structure found in the Effects classes. 
	 * 
	 * To change a property call request property change. It will be in the history
	 * To add a component call request item add. It will be in the history
	 * 
	 * To undo call undo
	 * To redo call redo
	 * 
	 * To get the history index access history index
	 * To check if history exists call the has history
	 * To check if undo can be performed access has undo
	 * To check if redo can be performed access has redo 
	 * */
	public class Radiate extends EventDispatcher {
		
		public static const SAME_OWNER:String = "sameOwner";
		public static const SAME_PARENT:String = "sameParent";
		public static const ADDED:String = "added";
		public static const MOVED:String = "moved";
		public static const ADD_ERROR:String = "addError";
		public static const RADIATE_LOG:String = "radiate";
		
		public function Radiate(s:SINGLEDOUBLE) {
			super(target as IEventDispatcher);
			
			// Create a target
			setLoggingTarget(defaultLogTarget);
			
		}
		
		//----------------------------------
		//  instance
		//----------------------------------
		private static var _instance:Radiate;
		
		/**
		 * Attempt to support a console part 2
		 * */
		public static function get log():ILogger {
			
			if (_log) {
				return _log;
			}
			else {
				setLoggingTarget(defaultLogTarget);
				return _log;
			}
		}

		/**
		 * @private
		 */
		public static function set log(value:ILogger):void {
			_log = value;
		}

		/**
		 * Attempt to support a console part 3
		 * */
		public static function get console():Object {
			return _console;
		}

		/**
		 * @private
		 */
		public static function set console(value:Object):void {
			_console = value;
			
			if ("console" in logTarget) {
				logTarget["console"] = value;
			}
		}

		public static function get instance():Radiate
		{
			if (!_instance) {
				_instance = new Radiate(new SINGLEDOUBLE());
			}
			return _instance;
		}
		
		public static function getInstance():Radiate {
			return instance;
		}
		
		//----------------------------------
		//
		//  Events Management
		// 
		//----------------------------------
		
		/**
		 * Dispatch target change event
		 * */
		public function dispatchTargetChangeEvent(target:*, multipleSelection:Boolean = false):void {
			var targetChangeEvent:RadiateEvent = new RadiateEvent(RadiateEvent.TARGET_CHANGE, false, false, target, null, null, multipleSelection);
			
			if (hasEventListener(RadiateEvent.TARGET_CHANGE)) {
				targetChangeEvent.selectedItem = target && target is Array ? target[0] : target;
				targetChangeEvent.targets = ArrayUtil.toArray(target);
				dispatchEvent(targetChangeEvent);
			}
		}
		
		/**
		 * Dispatch target change event with a null target. 
		 * */
		public function dispatchTargetClearEvent():void {
			var targetChangeEvent:RadiateEvent = new RadiateEvent(RadiateEvent.TARGET_CHANGE);
			
			if (hasEventListener(RadiateEvent.TARGET_CHANGE)) {
				dispatchEvent(targetChangeEvent);
			}
		}
		
		/**
		 * Dispatch property change event
		 * */
		public function dispatchPropertyChangeEvent(target:*, changes:Array, properties:Array, multipleSelection:Boolean = false):void {
			var propertyChangeEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROPERTY_CHANGE, false, false, target, changes, properties, multipleSelection);
			
			if (hasEventListener(RadiateEvent.PROPERTY_CHANGE)) {
				propertyChangeEvent.properties = properties;
				propertyChangeEvent.changes = changes;
				propertyChangeEvent.multipleSelection = multipleSelection;
				propertyChangeEvent.selectedItem = target && target is Array ? target[0] : target;
				propertyChangeEvent.targets = ArrayUtil.toArray(target);
				dispatchEvent(propertyChangeEvent);
			}
		}
		
		/**
		 * Dispatch add items event
		 * */
		public function dispatchAddEvent(target:*, changes:Array, properties:Array, multipleSelection:Boolean = false):void {
			var event:RadiateEvent = new RadiateEvent(RadiateEvent.ADD_ITEM, false, false, target, changes, properties, multipleSelection);
			var length:int = changes ? changes.length : 0;
			
			if (hasEventListener(RadiateEvent.ADD_ITEM)) {
				event.properties = properties;
				event.changes = changes;
				event.multipleSelection = multipleSelection;
				event.selectedItem = target && target is Array ? target[0] : target;
				event.targets = ArrayUtil.toArray(target);
				for (var i:int;i<length;i++) {
					if (changes[i] is AddItems) {
						event.addItemsInstance = changes[i];
						event.moveItemsInstance = changes[i];
					}
				}
				dispatchEvent(event);
			}
		}
		
		/**
		 * Dispatch add items event
		 * */
		public function dispatchMoveEvent(target:*, changes:Array, properties:Array, multipleSelection:Boolean = false):void {
			var event:RadiateEvent = new RadiateEvent(RadiateEvent.ADD_ITEM, false, false, target, changes, properties, multipleSelection);
			var length:int = changes ? changes.length : 0;
			
			if (hasEventListener(RadiateEvent.MOVE_ITEM)) {
				event.properties = properties;
				event.changes = changes;
				event.multipleSelection = multipleSelection;
				event.selectedItem = target && target is Array ? target[0] : target;
				event.targets = ArrayUtil.toArray(target);
				for (var i:int;i<length;i++) {
					if (changes[i] is AddItems) {
						event.addItemsInstance = changes[i];
						event.moveItemsInstance = changes[i];
					}
				}
				dispatchEvent(event);
			}
		}
		
		/**
		 * Dispatch remove items event
		 * */
		public function dispatchRemoveItemsEvent(target:*, changes:Array, properties:*, multipleSelection:Boolean = false):void {
			var event:RadiateEvent = new RadiateEvent(RadiateEvent.ADD_ITEM, false, false, target, changes, properties, multipleSelection);
			var length:int = changes ? changes.length : 0;
			
			if (hasEventListener(RadiateEvent.REMOVE_ITEM)) {
				event.properties = properties;
				event.changes = changes;
				event.multipleSelection = multipleSelection;
				event.selectedItem = target && target is Array ? target[0] : target;
				event.targets = ArrayUtil.toArray(target);
				for (var i:int;i<length;i++) {
					if (changes[i] is AddItems) {
						event.addItemsInstance = changes[i];
						event.moveItemsInstance = changes[i];
					}
				}
				dispatchEvent(event);
			}
		}
		
		/**
		 * Dispatch to invoke property edit event
		 * */
		public function dispatchTargetPropertyEditEvent(target:Object, changes:Array, properties:Array, multipleSelection:Boolean = false):void {
			var propertyEditEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROPERTY_EDIT, false, false, target, changes, properties, null, multipleSelection);
			
			if (hasEventListener(RadiateEvent.PROPERTY_EDIT)) {
				dispatchEvent(propertyEditEvent);
			}
		}
		
		/**
		 * Dispatch document change event
		 * */
		public function dispatchDocumentChangeEvent(document:Object, multipleSelection:Boolean = false):void {
			var documentChangeEvent:RadiateEvent = new RadiateEvent(RadiateEvent.DOCUMENT_CHANGE, false, false, document, null, null, multipleSelection);
			
			if (hasEventListener(RadiateEvent.DOCUMENT_CHANGE)) {
				dispatchEvent(documentChangeEvent);
			}
		}
		
		/**
		 * Dispatch a history change event
		 * */
		public function dispatchHistoryChangeEvent(newIndex:int, oldIndex:int):void {
			var event:RadiateEvent = new RadiateEvent(RadiateEvent.HISTORY_CHANGE);
			
			if (hasEventListener(RadiateEvent.HISTORY_CHANGE)) {
				event.newIndex = newIndex;
				event.oldIndex = oldIndex;
				event.historyEvent = getHistoryEventByIndex(newIndex);
				dispatchEvent(event);
			}
		}
		
		/**
		 * 
		 * */
		public static function setLoggingTarget(target:AbstractTarget = null, category:String = null, consoleObject:Object = null):void {
			
			// Log only messages for the classes in the mx.rpc.* and 
			// mx.messaging packages.
			//logTarget.filters=["mx.rpc.*","mx.messaging.*"];
			
			// Begin logging.
			if (target) {
				logTarget = target;
				Log.addTarget(target);
			}
			
			// set reference to logger
			if (category) {
				log = Log.getLogger(category);
			}
			else {
				log = Log.getLogger(RADIATE_LOG);
			}
			
			if (consoleObject) {
				console = consoleObject;
			}
		}
		
		//----------------------------------
		//  target
		//----------------------------------
		
		/**
		 *  
		 * */
		public function get target():Object {
			if (_targets.length > 0)
				return _targets[0];
			else
				return null;
		}
		
		/**
		 *  @private
		 */
		/*[Bindable]
		public function set target(value:Object):void {
			if (_targets.length == 1 && target==value) return;
			
			_targets.splice(0);
			
			if (value) {
				_targets[0] = value;
			}
		}*/

		
		//----------------------------------
		//  targets
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the targets property.
		 */
		private var _targets:Array = [];
		
		/**
		 * Selected targets
		 * */
		public function get targets():Array {
			return _targets;
		}
		
		/**
		 * Selected targets
		 *  @private
		 * */
		/*public function set targets(value:Array):void {
			// remove listeners from previous targets
			var n:int = _targets.length;
			
			for (var i:int = n - 1; i >= 0; i--) {
				if (_targets[i] == null) {
					continue;
				}
				
				//removeHandlers(_targets[i]);
			}
			
			// Strip out null values.
			// Binding will trigger again when the null targets are created.
			n = value.length;
			
			for (i = n - 1; i >= 0; i--) {
				if (value[i] == null) {
					value.splice(i,1);
					continue;
				}
				
				//addHandlers(value[i]);
			}
			
			_targets = value;
			
		}*/
		
		//----------------------------------
		//  document
		//----------------------------------
		
		/**
		 *  
		 * */
		public function get document():IEventDispatcher {
			if (_documents.length > 0)
				return _documents[0];
			else
				return null;
		}
		
		/**
		 *  @private
		 */
		public function set document(value:IEventDispatcher):void {
			_documents.splice(0);
			
			if (value) {
				_documents[0] = value;
			}
			
		}
		
		
		//----------------------------------
		//  documents
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the documents property.
		 */
		private var _documents:Array = [];
		
		/**
		 * Selected documents
		 * */
		public function get documents():Array {
			return _documents;
		}
		
		/**
		 * Selected documents
		 *  @private
		 * */
		public function set documents(value:Array):void {
			// remove listeners from previous documents
			var n:int = _documents.length;
			
			for (var i:int = n - 1; i >= 0; i--) {
				if (_documents[i] == null) {
					continue;
				}
				
				//removeHandlers(_documents[i]);
			}
			
			// Strip out null values.
			// Binding will trigger again when the null documents are created.
			n = value.length;
			
			for (i = n - 1; i >= 0; i--) {
				if (value[i] == null) {
					value.splice(i,1);
					continue;
				}
				
				//addHandlers(value[i]);
			}
			
			_documents = value;
			
		}
		
		/**
		 * Default log target
		 * */
		public static var defaultLogTarget:AbstractTarget = new RadiateLogTarget();
		
		/**
		 * Attempt to support a console
		 * */
		public static var logTarget:AbstractTarget;
		
		private static var _log:ILogger;
		
		private static var _console:Object;
		
		//----------------------------------
		//
		//  Component Management
		// 
		//----------------------------------
		
		/**
		 * Collection of visual elements that can be added or removed to 
		 * */
		[Bindable]
		public static var componentDescriptions:ArrayCollection = new ArrayCollection();
		
		/**
		 * Cache for component icons
		 * */
		[Bindable]
		public static var contentCache:ContentCache = new ContentCache();
		
		/**
		 * Add the named component class to the list of available components
		 * */
		public static function addComponentType(name:String, className:String, classType:Object, icon:Object = null, defaultProperties:Object=null, defaultStyles:Object=null):Boolean {
			var definition:ComponentDescription;
			var length:uint = componentDescriptions.length;
			var item:ComponentDescription;
			
			
			for (var i:uint;i<length;i++) {
				item = componentDescriptions.getItemAt(i) as ComponentDescription;
				
				// check if it exists already
				if (item && item.classType==classType) {
					return false;
				}
			}
			
			
			definition = new ComponentDescription();
			
			definition.name = name;
			definition.icon = icon;
			definition.className = className;
			definition.classType = classType;
			definition.defaultStyles = defaultStyles;
			definition.defaultProperties = defaultProperties;
			
			componentDescriptions.addItem(definition);
			
			return true;
		}
		
		/**
		 * Sets the document
		 * */
		public function setDocument(value:Object, dispatchEvent:Boolean = true, cause:String = ""):void {
			if (_documents.length == 1 && documents==value) return;
			
			_documents = null;// without this, the contents of the array would change across all instances
			_documents = [];
			
			if (value) {
				_documents[0] = value;
			}
			
			if (dispatchEvent) {
				instance.dispatchDocumentChangeEvent(document);
			}
			
			// move this later
			if (_documents.length==0) {
				clearSelection();
			}
		}
		
		/**
		 * Selects the target
		 * */
		public function setDocuments(value:*, dispatchEvent:Boolean = true, cause:String = ""):void {
			value = ArrayUtil.toArray(value);
			
			// remove listeners from previous documents
			var n:int = _documents.length;
			
			for (var i:int = n - 1; i >= 0; i--) {
				if (_documents[i] == null) {
					continue;
				}
				
				//removeHandlers(_documents[i]);
			}
			
			// Strip out null values.
			// Binding will trigger again when the null documents are created.
			n = value.length;
			
			for (i = n - 1; i >= 0; i--) {
				if (value[i] == null) {
					value.splice(i,1);
					continue;
				}
				
				//addHandlers(value[i]);
			}
			
			_documents = value;
			
			if (dispatchEvent) {
				instance.dispatchDocumentChangeEvent(documents);
			}
			
			// move this later
			if (_documents.length==0) {
				clearSelection();
			}
		}
		
		/**
		 * Selects the target
		 * */
		public function setTarget(value:*, dispatchEvent:Boolean = true, cause:String = ""):void {
			if (_targets.length == 1 && target==value) return;
			
			_targets = null;// without this, the contents of the array would change across all instances
			_targets = [];
			
			if (value) {
				_targets[0] = value;
			}
			
			if (dispatchEvent) {
				instance.dispatchTargetChangeEvent(target);
			}
			
			// move this later
			if (_targets.length==0) {
				clearSelection();
			}
		}
		
		/**
		 * Selects the target
		 * */
		public function setTargets(value:*, dispatchEvent:Boolean = true, cause:String = ""):void {
			value = ArrayUtil.toArray(value);
			
			// remove listeners from previous targets
			var n:int = _targets.length;
			
			for (var i:int = n - 1; i >= 0; i--) {
				if (_targets[i] == null) {
					continue;
				}
				
				//removeHandlers(_targets[i]);
			}
			
			// Strip out null values.
			// Binding will trigger again when the null targets are created.
			n = value.length;
			
			for (i = n - 1; i >= 0; i--) {
				if (value[i] == null) {
					value.splice(i,1);
					continue;
				}
				
				//addHandlers(value[i]);
			}
			
			_targets = value;
			
			
			if (dispatchEvent) {
				instance.dispatchTargetChangeEvent(_targets, true);
			}
			
			// move this later
			if (_targets.length==0) {
				clearSelection();
			}
		}
		
		/**
		 * Deselects the passed in targets
		 * */
		public function desetTargets(value:*, dispatchEvent:Boolean = true, cause:String = ""):void {
			value = ArrayUtil.toArray(value);
			
			throw new Error("not done");
			
			// go through current targets and remove any that match the ones in the values
			
			// remove listeners from previous targets
			var targetsLength:int = _targets.length;
			var valuesLength:int = value ? value.length : 0;
			
			for (var i:int=0;i<targetsLength;i++) {
				for (var j:int=0;j<valuesLength;j++) {
					if (value[j]==_targets[i]) {
						_targets.splice(i,1);
						continue;
					}
				}
			}
			
			
			if (dispatchEvent) {
				instance.dispatchTargetChangeEvent(_targets, true);
			}
		}
		
		/**
		 * Deselects the target
		 * */
		public function deselectedTarget(dispatchEvent:Boolean = true, cause:String = ""):void {
			
			// go through current targets and remove any that match the ones in the values
			setTarget(null, dispatchEvent, cause);
			
		}
		
		/**
		 * Deselects the target
		 * */
		public static function clearTarget(dispatchEvent:Boolean = true, cause:String = ""):void {
			setTarget(null, dispatchEvent, cause);
		}
		
		/**
		 * Selects the target
		 * */
		public static function setTarget(value:DisplayObject, dispatchEvent:Boolean = true, cause:String = ""):void {
			instance.setTarget(value, dispatchEvent, cause);
		}
		
		/**
		 * Selects the target
		 * */
		public static function setTargets(value:Object, dispatchEvent:Boolean = true, cause:String = ""):void {
			instance.setTargets(value, dispatchEvent, cause);
		}
		
		/**
		 * Selects the document
		 * */
		public static function setDocuments(value:Object, dispatchEvent:Boolean = false, cause:String = ""):void {
			instance.setDocuments(value, dispatchEvent, cause);
		}
		
		/**
		 * Deselects the documents
		 * */
		public static function desetDocuments(dispatchEvent:Boolean = true, cause:String = ""):void {
			instance.setDocuments(null, dispatchEvent, cause);
		}
		
		/**
		 * Gets the display list of the current document
		 * */
		public static function getComponentDisplayList():ComponentDescription {
			return DisplayObjectUtils.getComponentDisplayList(instance.document);
		}
		
		public static var targetSelectionGroup:ItemRenderer = new TargetSelectionGroup();
		public static var mouseLocationLines:IFlexDisplayObject = new ListDropIndicator();
		public static var showSelectionLabel:Boolean = true;
		public static var showSelectionLabelOnDocument:Boolean = false;
		public static var showSelectionBackground:Boolean = true;
		public static var showSelectionBackgroundOnDocument:Boolean = false;
		public static var lastTargetCandidate:Object;
		
		/**
		 * Show selection box on target change
		 * */
		public static var showSelectionRectangle:Boolean = true;
		
		/**
		 * Clears the outline around a target display object
		 * */
		public static function clearSelection():void {
			
			if (targetSelectionGroup) {
				targetSelectionGroup.visible = false;
			}
		}
		
		/**
		 * Draws outline around target display object
		 * */
		public static function drawSelection(target:Object):void {
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
				
				// draw the selection rectangle only if it's changed
				if (lastTargetCandidate!=target) {
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
					
					// get target bounds
					if (target is UIComponent) {
						rectangle = UIComponent(target).getVisibleRect(target.parent);
					}
					else {
						rectangle = DisplayObject(target).getBounds(targetCoordinateSpace);
					}
					
					// size and position fill
					targetSelectionGroup.width = rectangle.width;
					targetSelectionGroup.height = rectangle.height;
					targetSelectionGroup.x = rectangle.x;
					targetSelectionGroup.y = rectangle.y;
					
					targetSelectionGroup.data = target;
					
					// unhide target selection group
					if (!targetSelectionGroup.visible) {
						targetSelectionGroup.visible = true;
					}
					
					// show selection / bounding box 
					PopUpManager.addPopUp(targetSelectionGroup, targetCoordinateSpace);
					targetSelectionGroup.validateNow();
				}
				
			}
		}
		
		/**
		 * Returns true if the property was changed
		 * Usage:
		 * setProperty(myButton, "x", 40);
		 * setProperty([myButton,myButton2], "x", 40);
		 * */
		public static function setProperty(target:Object, property:String, value:*, description:String = null, keepUndefinedValues:Boolean = false):Boolean {
			var targets:Array = ArrayUtil.toArray(target);
			var propertyChanges:Array = createPropertyChange(targets, property, value, description);
			var effectInstances:Array;
			
			if (!keepUndefinedValues) {
				propertyChanges = stripUnchangedValues(propertyChanges);
			}
			
			if (changesAvailable(propertyChanges)) {
				applyChanges(targets, propertyChanges, property);
				LayoutManager.getInstance().validateNow();
				addHistoryItem(propertyChanges);
				instance.dispatchPropertyChangeEvent(targets, propertyChanges, ArrayUtil.toArray(property));
				return true;
			}
			
			return false;
		}
		
		/**
		 * Returns true if the property(s) were changed.
		 * Usage:
		 * setProperties([myButton,myButton2], ["x","y"], {x:40,y:50});
		 * setProperties(myButton, "x", 40);
		 * setProperties(button, ["x", "left"], {x:50,left:undefined});
		 * */
		public static function setProperties(target:Object, property:*, value:*, description:String = null, keepUndefinedValues:Boolean = false):Boolean {
			var targets:Array = ArrayUtil.toArray(target);
			var properties:Array = ArrayUtil.toArray(property);
			var propertyChanges:Array = createPropertyChanges(targets, properties, value, description);
			
			if (!keepUndefinedValues) {
				propertyChanges = stripUnchangedValues(propertyChanges);
			}
			
			if (changesAvailable(propertyChanges)) {
				applyChanges(targets, propertyChanges, properties);
				LayoutManager.getInstance().validateNow();
				addHistoryItem(propertyChanges);
				instance.dispatchPropertyChangeEvent(targets, propertyChanges, properties);
				return true;
			}
			
			return false;
		}
		
		
		
		/**
		 * Move a component in the display list and sets any properties 
		 * such as positioning
		 * 
		 * Usage:
		 * Radiate.moveDisplayItems(new Button(), event.targetCandidate);
		 * */
		public static function moveElement(items:*, 
										   destination:Object, 
										   properties:Array, 
										   values:Object, 
										   description:String 	= RadiateEvent.MOVE_ITEM, 
										   position:String		= AddItems.LAST, 
										   relativeTo:Object	= null, 
										   index:int			= -1, 
										   propertyName:String	= null, 
										   isArray:Boolean		= false, 
										   isStyle:Boolean		= false, 
										   vectorClass:Class	= null,
										   keepUndefinedValues:Boolean = true):String {
			var visualElement:IVisualElement;
			var moveItems:AddItems;
			var childIndex:int;
			var changes:Array;
			var propertyChangeChange:PropertyChanges;
			var isSameOwner:Boolean;
			var isSameParent:Boolean;
			
			items = ArrayUtil.toArray(items);
			
			
			// set default description
			if (!description) {
				description = ADD_ITEM_DESCRIPTION;
			}
			
			// if it's a basic layout then don't try to add it
			if (destination is GroupBase || destination is Application) {
				//destinationGroup = destination as GroupBase;
				
				if (destination.layout is BasicLayout) {
					// does not support multiple items?
					
					// check if group parent and destination are the same
					if (items && items[0].owner==destination) {
						//trace("can't add to the same owner in a basic layout");
						isSameOwner = true;
						//return SAME_OWNER;
					}
					
					// check if group parent and destination are the same
					if (items && items[0].parent==destination) {
						//trace("can't add to the same parent in a basic layout");
						isSameParent = true;
						//return SAME_PARENT;
					}
				}
				// if element is already child of layout container and there is only one element 
				else if (items 
					&& items[0].parent==destination 
					&& destination is IVisualElementContainer 
					&& destination.numElements==1) {
					
					isSameParent = true;
					isSameOwner = true;
					//trace("can't add to the same parent in a basic layout");
					//return SAME_PARENT;
					
				}
			}
			
			
			// set default
			if (!position) {
				position = AddItems.LAST;
			}
			
			// if destination is not a basic layout Group and the index is set 
			// then find and override position and set the relative object 
			// so we can position the target in the drop location point index
			if (destination is IVisualElementContainer 
				&& !relativeTo 
				&& index!=-1
				&& destination.numElements>0) {
				
				// add as first item
				if (index==0) {
					position = AddItems.FIRST;
				}
					
					// get relative to object
				else if (index<=destination.numElements) {
					visualElement = items is Array && (items as Array).length ? items[0] as IVisualElement : items as IVisualElement;
					
					// if element is already child of container account for removal of element before add
					if (visualElement && visualElement.parent == destination) {
						childIndex = destination.getElementIndex(visualElement);
						index = childIndex < index ? index-1: index;
						
						if (index<=0) {
							position = AddItems.FIRST;
						}
						else {
							relativeTo = destination.getElementAt(index-1);
							position = AddItems.AFTER;
						}
					}
						// add as last item
					else if (index>=destination.numElements) {
						position = AddItems.LAST;
					}
						// add after first item
					else if (index>0) {
						relativeTo = destination.getElementAt(index-1);
						position = AddItems.AFTER;
					}
				}
			}
			
			
			// create a new AddItems instance and add it to the changes
			moveItems = new AddItems();
			moveItems.items = items;
			moveItems.destination = destination;
			moveItems.position = position;
			moveItems.relativeTo = relativeTo;
			moveItems.propertyName = propertyName;
			moveItems.isArray = isArray;
			moveItems.isStyle = isStyle;
			moveItems.vectorClass = vectorClass;
			
			// add properties that need to be modified
			if (properties) { 
				changes = createPropertyChanges(items, properties, values, description, false);
				
				// get the property change part
				propertyChangeChange = changes[0];
			}
			else {
				changes = [];
			}
			
			// constraints use undefined values 
			// so if we use constraints do not strip out values
			if (!keepUndefinedValues) {
				changes = stripUnchangedValues(changes);
			}
			
			
			// attempt to add or move and set the properties
			try {
				
				// insert moving of items before it
				// if it's the same owner we don't want to run add items 
				// but if it's a vgroup or hgroup does this count
				if (!isSameParent && !isSameOwner) {
					changes.unshift(moveItems); //add before other changes 
				}
				else {
					//trace("NOT ADDING move add items");
				}
				
				if (changes.length==0) {
					return "Nothing to change or add";
				}
				
				// store changes
				storeHistoryEvent(items, changes, properties, values, description, RadiateEvent.MOVE_ITEM);
				
				// try moving
				if (!isSameParent && !isSameOwner) {
					moveItems.apply(moveItems.destination as UIComponent);
					LayoutManager.getInstance().validateNow();
				}
				
				// try setting properties
				if (changesAvailable([propertyChangeChange])) {
					applyChanges(items, [propertyChangeChange], properties);
					LayoutManager.getInstance().validateNow();
				}
				
				// add to history
				addHistoryItem(changes);
				
				// check for changes before dispatching
				if (changes.indexOf(moveItems)!=-1) {
					instance.dispatchMoveEvent(items, changes, properties);
				}
				
				if (properties) {
					instance.dispatchPropertyChangeEvent(items, changes, properties);
				}
				
				setTargets(items, true);
				
				return MOVED; // we assume moved if it got this far - needs more checking
			}
			catch (error:Error) {
				// this is clunky - needs to be upgraded
				removeHistoryEvent(changes);
				removeHistoryItem(changes);
				return String(error.message);
			}
			
			
			return ADD_ERROR;
			
		}
		
		/**
		 * Adds a component to the display list.
		 * It should not have a parent or owner! If it does
		 * it will return an error message
		 * Returns true if the component was added
		 * 
		 * Usage:
		 * Radiate.addElement(new Button(), event.targetCandidate);
		 * */
		public static function addElement(items:*, 
										  destination:Object, 
										  properties:Array, 
										  values:Object, 
										  description:String 	= RadiateEvent.ADD_ITEM, 
										  position:String		= AddItems.LAST, 
										  relativeTo:Object		= null, 
										  index:int				= -1, 
										  propertyName:String	= null, 
										  isArray:Boolean		= false, 
										  isStyle:Boolean		= false, 
										  vectorClass:Class		= null,
										  keepUndefinedValues:Boolean = true):String {
			
			// this is way too long :(
			return moveElement(items, destination, properties, values, 
								description, position, relativeTo, index, propertyName, 
								isArray, isStyle, vectorClass, keepUndefinedValues);
			
			var visualElement:IVisualElement;
			var removeItems:AddItems;
			var addItems:AddItems;
			var numOfElements:int;
			var childIndex:int;
			var changes:Array;
			
			items = ArrayUtil.toArray(items);
			
			
			// set default description
			if (!description) {
				description = ADD_ITEM_DESCRIPTION;
			}
			
			////////////////////////
			// NOTE: This is an add, so there shouldn't be a previous owner or parent
			// maybe remove this? may keep it to prevent misuse of api call
			////////////////////////
			
			// if it's a basic layout then don't try to add it
			if (destination is GroupBase || destination is Application) {
				//destinationGroup = destination as GroupBase;
				
				if (destination.layout is BasicLayout) {
					// does not support multiple items?
					
					// check if group parent and destination are the same
					if (items && items[0].owner==destination) {
						//trace("can't add to the same owner in a basic layout");
						return SAME_OWNER;
					}
					
					// check if group parent and destination are the same
					if (items && items[0].parent==destination) {
						//trace("can't add to the same parent in a basic layout");
						return SAME_PARENT;
					}
				}
				// if element is already child of layout container and there is only one element 
				else if (items 
						&& items[0].parent==destination 
						&& destination is IVisualElementContainer 
						&& destination.numElements==1) {
					
					//trace("can't add to the same parent in a basic layout");
					return SAME_PARENT;
					
				}
			}
			
			// create a new AddItems instance and add it to the changes
			addItems = new AddItems();
			removeItems = new AddItems();
			changes = [addItems];
			
			// set default
			if (!position) {
				position = AddItems.LAST;
			}
			
			// if destination is not a basic layout Group and the index is set 
			// then find and override position and set the relative object 
			// so we can position the target in the drop location point index
			if (destination is IVisualElementContainer 
				&& !relativeTo 
				&& index!=-1
				&& destination.numElements>0) {
				
				// add as first item
				if (index==0) {
					position = AddItems.FIRST;
				}
				
				// get relative to object
				else if (index<=destination.numElements) {
					visualElement = items is Array && (items as Array).length ? items[0] as IVisualElement : items as IVisualElement;
					
					// if element is already child of container account for removal of element before add
					if (visualElement && visualElement.parent == destination) {
						childIndex = destination.getElementIndex(visualElement);
						index = childIndex < index ? index-1: index;
						
						if (index<=0) {
							position = AddItems.FIRST;
						}
						else {
							relativeTo = destination.getElementAt(index-1);
							position = AddItems.AFTER;
						}
					}
					// add as last item
					else if (index>=destination.numElements) {
						position = AddItems.LAST;
					}
					// add after first item
					else if (index>0) {
						relativeTo = destination.getElementAt(index-1);
						position = AddItems.AFTER;
					}
				}
			}
			
			
			addItems.items = ArrayUtil.toArray(items);
			addItems.destination = destination;
			addItems.position = position;
			addItems.relativeTo = relativeTo;
			addItems.propertyName = propertyName;
			addItems.isArray = isArray;
			addItems.isStyle = isStyle;
			addItems.vectorClass = vectorClass;
			
			
			// add property changes array to the history dictionary
			storeHistoryEvent(ArrayUtil.toArray(items), changes, propertyName, null, description, RadiateEvent.ADD_ITEM);
			
			
			// check for changes
			if (true) {
				
				try {
					addItems.apply(addItems.destination as UIComponent);
					LayoutManager.getInstance().validateNow();
					addHistoryItem(changes);
					instance.dispatchAddEvent(items, changes, ArrayUtil.toArray(propertyName), false);
					setTargets(items, true);
					return ADDED; // we assume add was successful if we got this far - needs more work
				}
				catch (error:Error) {
					removeHistoryEvent(changes);
					removeHistoryItem(changes);
					return String(error.message);
				}
			}
			
			return ADD_ERROR;
		}
		
		/**
		 * Apply changes to targets
		 * @param setStartValues applies the start values rather 
		 * than applying the end values
		 * */
		public static function applyChanges(targets:Array, changes:Array, property:*, setStartValues:Boolean=false):Boolean {
			var length:int = changes ? changes.length : 0;
			var effect:SetAction = new SetAction();
			var onlyPropertyChanges:Array = [];
			var directApply:Boolean = true;
			
			for (var i:int;i<length;i++) {
				if (changes[i] is PropertyChanges) { 
					onlyPropertyChanges.push(changes[i]);
				}
			}
			
			effect.targets = targets;
			effect.propertyChangesArray = onlyPropertyChanges;
			effect.relevantProperties = ArrayUtil.toArray(property);
			
			// this works for styles and properties
			// note: the property applyActualDimensions is used to enable width and height values to stick
			if (directApply) {
				effect.applyEndValuesWhenDone = false;
				effect.applyActualDimensions = false;
				
				if (setStartValues) {
					effect.applyStartValues(onlyPropertyChanges, targets);
				}
				else {
					effect.applyEndValues(onlyPropertyChanges, targets);
				}
				
				// Revalidate after applying
				LayoutManager.getInstance().validateNow();
			}
				
				// this works for properties but not styles
				// the style value is restored at the end
			else {
				
				effect.applyEndValuesWhenDone = false;
				effect.play(targets, setStartValues);
				effect.playReversed = false;
				effect.end();
			}
			return true;
		}
		
		/**
		 * Removes properties changes for null or same value targets
		 * @private
		 */
		public static function stripUnchangedValues(propChanges:Array):Array {
			
			// Go through and remove any before/after values that are the same.
			for (var i:int = 0; i < propChanges.length; i++) {
				if (propChanges[i].stripUnchangedValues == false)
					continue;
				
				for (var prop:Object in propChanges[i].start) {
					if ((propChanges[i].start[prop] ==
						propChanges[i].end[prop]) ||
						(typeof(propChanges[i].start[prop]) == "number" &&
							typeof(propChanges[i].end[prop])== "number" &&
							isNaN(propChanges[i].start[prop]) &&
							isNaN(propChanges[i].end[prop])))
					{
						delete propChanges[i].start[prop];
						delete propChanges[i].end[prop];
					}
				}
			}
			
			return propChanges;
		}
		
		
		
		/**
		 * Checks if changes are available. 
		 * */
		public static function changesAvailable(changes:Array):Boolean {
			var length:int = changes.length;
			var changesAvailable:Boolean;
			var item:PropertyChanges;
			var name:String;
			
			for (var i:int;i<length;i++) {
				if (!(changes[i] is PropertyChanges)) continue;
				
				item = changes[i];
				
				for (name in item.start) {
					changesAvailable = true;
					return true;
				}
				
				for (name in item.end) {
					changesAvailable = true;
					return true;
				}
			}
			
			return changesAvailable;
		}
		
		
		//----------------------------------
		//
		//  History Management
		// 
		//----------------------------------
		
		// NOTE: THIS IS WRITTEN THIS WAY TO WORK WITH FLEX STATES AND TRANSITIONS
		// there is probably a better way but I am attempting to use the flex sdk's
		// own code to apply changes 
		
		public static var ADD_ITEM_DESCRIPTION:String = "Add";
		private static var BEGINNING_OF_HISTORY:String;
		
		/**
		 * Collection of items in the property change history
		 * */
		[Bindable]
		public static var history:ArrayCollection = new ArrayCollection();
		
		/**
		 * Dictionary of property change objects
		 * */
		public static var historyEventsDictionary:Dictionary = new Dictionary(true);
		
		
		/**
		 * Undo last change. Returns the current index in the changes array. 
		 * The property change object sets the property "reversed" to 
		 * true.
		 * Going to fast causes some issues (call validateNow somewhere)?
		 * */
		public static function undo():int {
			var changeIndex:int = getPreviousHistoryIndex(); // index of next change to undo 
			var currentIndex:int = getHistoryIndex();
			var setStartValues:Boolean = true;
			var length:int = history.length;
			var historyEvent:HistoryEvent;
			var effectInstances:Array;
			var dictionary:Dictionary;
			var reverseItems:AddItems;
			var eventTargets:Array;
			var changesLength:int;
			var targetsLength:int;
			var addItems:AddItems;
			var added:Boolean;
			var changes:Array;
			var change:Object;
			var action:String;
			
			// no changes
			if (!length) {
				return -1;
			}
			
			// all changes have already been undone
			if (changeIndex<0) {
				if (instance.hasEventListener(RadiateEvent.BEGINNING_OF_UNDO_HISTORY)) {
					instance.dispatchEvent(new RadiateEvent(RadiateEvent.BEGINNING_OF_UNDO_HISTORY));
				}
				return -1;
			}
			
			// get current change to be redone
			changes = history.length ? history.getItemAt(changeIndex) as Array : null;
			changesLength = changes ? changes.length: 0;
			
			
			// loop through changes
			for (var i:int;i<changesLength;i++) {
				change = changes[i];
				
				// get property change description object
				historyEvent = historyEventsDictionary[change];
				addItems = historyEvent.addItemsInstance;
				action = historyEvent.action;//==RadiateEvent.MOVE_ITEM && addItems ? RadiateEvent.MOVE_ITEM : RadiateEvent.PROPERTY_CHANGE;
				
				
				// undo the add
				if (action==RadiateEvent.ADD_ITEM) {
					eventTargets = historyEvent.targets;
					targetsLength = eventTargets.length;
					dictionary = historyEvent.reverseAddItemsDictionary;
					
					for (var j:int=0;j<targetsLength;j++) {
						reverseItems = dictionary[eventTargets[j]];
						addItems.remove(null);
						
						// check if it's reverse or property changes
						if (reverseItems) {
							reverseItems.apply(reverseItems.destination as UIComponent);
							
							// was it added - can be refactored
							if (reverseItems.destination==null) {
								added = true;
							}
						}
					}
					
					historyEvent.reversed = true;
					instance.dispatchRemoveItemsEvent(historyEvent.targets, changes, historyEvent.properties);
				}
				
				// undo the move
				if (action==RadiateEvent.MOVE_ITEM) {
					eventTargets = historyEvent.targets;
					targetsLength = eventTargets.length;
					dictionary = historyEvent.reverseAddItemsDictionary;
					
					for (j=0;j<targetsLength;j++) {
						reverseItems = dictionary[eventTargets[j]];
						
						// check if it's reverse or property changes
						if (reverseItems) {
							addItems.remove(null);
							reverseItems.apply(reverseItems.destination as UIComponent);
							instance.dispatchRemoveItemsEvent(historyEvent.targets, [change], historyEvent.properties);
							
							// was it added - note: can be refactored
							if (reverseItems.destination==null) {
								added = true;
							}
						}
						else {
							applyChanges(historyEvent.targets, [change], historyEvent.properties, 
								setStartValues);
							historyEvent.reversed = true;
							instance.dispatchPropertyChangeEvent(historyEvent.targets, [change], historyEvent.properties);
						}
					}
					
					historyEvent.reversed = true;
				}
				// undo the remove
				else if (action==RadiateEvent.REMOVE_ITEM) {
					addItems.apply(addItems.destination as UIComponent);
					historyEvent.reversed = true;
					instance.dispatchAddEvent(historyEvent.targets, changes, historyEvent.properties);
				}
				// undo the property changes
				else if (action==RadiateEvent.PROPERTY_CHANGE) {
				
					applyChanges(historyEvent.targets, changes, historyEvent.properties, 
						setStartValues);
					historyEvent.reversed = true;
					instance.dispatchPropertyChangeEvent(historyEvent.targets, changes, historyEvent.properties);
				}
			}
			
			// select the target
			if (selectTargetOnHistoryChange) {
				if (added) {
					instance.setTarget(null, true);
				}
				else {
					instance.setTargets(historyEvent.targets, true);
				}
			}
			
			if (changesLength) {
				historyIndex = getHistoryIndex();
				instance.dispatchHistoryChangeEvent(historyIndex, currentIndex);
				return changeIndex-1;
			}
			
			return length;
		}
		
		/**
		 * Redo last change
		 * */
		public static function redo():int {
			var changeIndex:int = getNextHistoryIndex();
			var currentIndex:int = getHistoryIndex();
			var length:int = history.length;
			var historyEvent:HistoryEvent;
			var setStartValues:Boolean;
			var effectInstances:Array;
			var changesLength:int;
			var addItems:AddItems;
			var changes:Array;
			var change:Object;
			var action:String;
			
			// no changes made
			if (!length) {
				return -1;
			}
			
			// cannot redo any more changes
			if (changeIndex==-1 || changeIndex>=length) {
				if (instance.hasEventListener(RadiateEvent.END_OF_UNDO_HISTORY)) {
					instance.dispatchEvent(new RadiateEvent(RadiateEvent.END_OF_UNDO_HISTORY));
				}
				return length-1;
			}
			
			// get current change to be redone
			changes = history.length ? history.getItemAt(changeIndex) as Array : null;
			changesLength = changes ? changes.length: 0;
			
			for (var i:int;i<changesLength;i++) {
				change = changes[i];
				
				// get property changes description object
				historyEvent = historyEventsDictionary[change];
				addItems = historyEvent.addItemsInstance;
				action = historyEvent.action;
				
				
				if (action==RadiateEvent.ADD_ITEM) {
					// redo the add
					addItems.apply(addItems.destination as UIComponent);
					historyEvent.reversed = false;
					instance.dispatchAddEvent(historyEvent.targets, changes, historyEvent.properties);
					/*historyIndex = getHistoryIndex();
					instance.dispatchHistoryChangeEvent(historyIndex, currentIndex);
					return changeIndex;*/
				}
				else if (action==RadiateEvent.MOVE_ITEM) {
					// redo the move
					if (addItems) {
						addItems.apply(addItems.destination as UIComponent);
						historyEvent.reversed = false;
						instance.dispatchMoveEvent(historyEvent.targets, changes, historyEvent.properties);
					}
					else {
						
						applyChanges(historyEvent.targets, changes, historyEvent.properties, 
							setStartValues);
						historyEvent.reversed = false;
						instance.dispatchPropertyChangeEvent(historyEvent.targets, changes, historyEvent.properties);
					}
					
				}
				else if (action==RadiateEvent.REMOVE_ITEM) {
					// redo the remove
					addItems.remove(addItems.destination as UIComponent);
					historyEvent.reversed = false;
					instance.dispatchRemoveItemsEvent(historyEvent.targets, changes, historyEvent.properties);
				}
				else if (action==RadiateEvent.PROPERTY_CHANGE) {
					applyChanges(historyEvent.targets, changes, historyEvent.properties, 
						setStartValues);
					historyEvent.reversed = false;
					instance.dispatchPropertyChangeEvent(historyEvent.targets, changes, historyEvent.properties);
				}
			}
			
			// select target
			if (selectTargetOnHistoryChange) {
				instance.setTargets(historyEvent.targets, true);
			}
			
			if (changesLength) {
				historyIndex = getHistoryIndex();
				instance.dispatchHistoryChangeEvent(historyIndex, currentIndex);
				return changeIndex;
			}
			
			return length;
		}
		
		
		private static var _historyIndex:int = -1;
		
		/**
		 * Selects the target on undo and redo
		 * */
		public static var selectTargetOnHistoryChange:Boolean = true;

		/**
		 * Current history index. 
		 * The history index is the index of last applied change. Or
		 * to put it another way the index of the last reversed change
		 * -1. If there are 10 total changes and one has been reversed 
		 * we would be at the 9 the change. The history index would 
		 * be 8 since 9-1 = 8 since the array is a zero based index. 
		 * */
		[Bindable]
		public static function get historyIndex():int {
			return _historyIndex;
		}

		/**
		 * @private
		 */
		public static function set historyIndex(value:int):void {
			if (_historyIndex==value) return;
			_historyIndex = value;
		}
		
		/**
		 * Get the index of the next item that can be undone. 
		 * If there are 10 changes and one has been reversed the 
		 * history index would be 8 since 10-1=9-1=8 since the array is 
		 * a zero based index. 
		 * */
		public static function getPreviousHistoryIndex():int {
			var length:int = history.length;
			var propertyChangesItems:Array;
			var historyEvent:HistoryEvent;
			var change:Object;
			var index:int;
			
			for (var i:int;i<length;i++) {
				propertyChangesItems = history.getItemAt(i) as Array;
				change = propertyChangesItems && propertyChangesItems.length ? propertyChangesItems[0] : null;
				historyEvent = historyEventsDictionary[change];
				
				if (historyEvent.reversed) {
					return i-1;
				}
			}
			
			return length-1;
		}
		
		/**
		 * Get the index of the next item that can be redone in the history array. 
		 * If there are 10 changes and one has been reversed the 
		 * next history index would be 9 since 10-1=9-1=8+1=9 since the array is 
		 * a zero based index. 
		 * */
		public static function getNextHistoryIndex():int {
			var length:int = history.length;
			var change:Object;
			var historyEvent:HistoryEvent;
			var propertyChangesItems:Array;
			var index:int;
			
			// start at the beginning and find the next item to redo
			for (var i:int;i<length;i++) {
				propertyChangesItems = history.getItemAt(i) as Array;
				change = propertyChangesItems && propertyChangesItems.length ? propertyChangesItems[0] : null;
				historyEvent = historyEventsDictionary[change];
				
				if (historyEvent.reversed) {
					return i;
				}
			}
			
			return length;
		}
		
		/**
		 * Get history index
		 * */
		public static function getHistoryIndex():int {
			var length:int = history.length;
			var historyEvent:HistoryEvent;
			var changes:Array;
			var change:Object;
			var index:int;
			
			for (var i:int;i<length;i++) {
				changes = history.getItemAt(i) as Array;
				change = changes && changes.length ? changes[0] : null;
				historyEvent = historyEventsDictionary[change];
				
				if (historyEvent && historyEvent.reversed) {
					return i-1;
				}
			}
			
			return length-1;
		}
		
		/**
		 * Returns the history event by index
		 * */
		public function getHistoryEventByIndex(index:int):HistoryEvent {
			var length:int = history.length;
			var historyArray:Array;
			var change:Object;
			var historyEvent:HistoryEvent;
			
			// no changes
			if (!length) {
				return null;
			}
			
			// all changes have already been undone
			if (index<0) {
				return null;
			}
			
			// get change 
			historyArray = history.length ? history.getItemAt(index) as Array : null;
			change = historyArray && historyArray.length ? historyArray[0] : null;
			
			// get property change description object
			historyEvent = historyEventsDictionary[change];
			
			return historyEvent;
		}

		
		/**
		 * Given a target or targets, property name and value
		 * returns an array of PropertyChange objects.
		 * */
		public static function createPropertyChange(targets:Array, property:String, value:*, description:String = ""):Array {
			var values:Object = {};
			var changes:Array;
			values[property] = value;
			changes = createPropertyChanges(targets, ArrayUtil.toArray(property), values, description);
			
			return changes;
		}
		
		/**
		 * Given a target or targets, properties and value object (name value pair)
		 * returns an array of PropertyChange objects.
		 * Value must be an object containing the properties mentioned in the properties array
		 * */
		public static function createPropertyChanges(targets:Array, properties:Array, value:Object, description:String = "", storeInHistory:Boolean = true):Array {
			var tempEffect:SetAction = new SetAction();
			var propertyChanges:PropertyChanges;
			var changes:Array;
			var property:String;
			
			tempEffect.targets = targets;
			tempEffect.relevantProperties = properties;
			
			// get start values for undo
			changes = tempEffect.captureValues(null, true);
			
			// This may be hanging on to bindable objects
			// set the values to be set to the property
			for each (propertyChanges in changes) {
				for each (property in properties) {
					
					// value may be an object with properties or a string
					if (value && property in value) {
						propertyChanges.end[property] = value[property];
					}
					else {
						propertyChanges.end[property] = value;
					}
				}
			}
			
			// we should move this out
			// add property changes array to the history dictionary
			if (storeInHistory) {
				storeHistoryEvent(targets, changes, properties, value, description);
			}
			
			return changes;
		}
		
		/**
		 * Stores a history event in the history events dictionary
		 * Changes can contain a property changes object or add items object
		 * */
		public static function storeHistoryEvent(targets:Array, changes:Array, properties:*, value:*, description:String = null, action:String="propertyChange"):void {
			var factory:ClassFactory = new ClassFactory(HistoryEvent);
			var historyEvent:HistoryEvent;
			var reverseAddItems:AddItems;
			var change:Object;
			var length:int;
			
			// create property change objects for each
			for each (change in changes) {
				historyEvent 						= factory.newInstance();
				historyEvent.action 				= action;
				historyEvent.properties 			= ArrayUtil.toArray(properties);
				historyEvent.targets 				= targets;
				historyEvent.description 			= description;
				
				// check for property change or add display object
				if (change is PropertyChanges) {
					historyEvent.propertyChanges 	= PropertyChanges(change);
				}
				else if (change is AddItems) {
					historyEvent.addItemsInstance 	= AddItems(change);
					length = targets.length;
					
					// trying to add support for multiple targets - it's not all there yet
					// probably not the best place to get the previous values or is it???
					for (var i:int;i<length;i++) {
						historyEvent.reverseAddItemsDictionary[targets[i]] = createReverseAddItems(targets[i]);
					}
				}
				
				historyEventsDictionary[change] 	= historyEvent;
			}
			
		}
		
		public static function createReverseAddItems(target:Object):AddItems {
			var elementContainer:IVisualElementContainer;
			var position:String = AddItems.LAST;
			var visualElement:IVisualElement;
			var reverseAddItems:AddItems;
			var elementIndex:int = -1;
			var propertyName:String; 
			var destination:Object;
			var description:String;
			var relativeTo:Object; 
			var vectorClass:Class;
			var isStyle:Boolean; 
			var isArray:Boolean; 
			var index:int = -1; 
			
			if (!target) return null;
			
			// create add items with current values we can revert back to
			reverseAddItems = new AddItems();
			reverseAddItems.destination = target.parent;
			reverseAddItems.items = target;
			
			destination = reverseAddItems.destination;
			
			visualElement = target as IVisualElement;
			
			// set default
			if (!position) {
				position = AddItems.LAST;
			}
			
			// Check for non basic layout destination
			// if destination is not a basic layout
			// find the position and set the relative object 
			if (destination is IVisualElementContainer 
				&& destination.numElements>0) {
				elementContainer = destination as IVisualElementContainer;
				index = elementContainer.getElementIndex(visualElement);
				
				
				if (elementContainer is GroupBase 
					&& !(GroupBase(elementContainer).layout is BasicLayout)) {
					

					// add as first item
					if (index==0) {
						position = AddItems.FIRST;
					}
					
					// get relative to object
					else if (index<=elementContainer.numElements) {
						
						
						// if element is already child of container account for remove of element before add
						if (visualElement && visualElement.parent == destination) {
							elementIndex = destination.getElementIndex(visualElement);
							index = elementIndex < index ? index-1: index;
							
							if (index<=0) {
								position = AddItems.FIRST;
							}
							else {
								relativeTo = destination.getElementAt(index-1);
								position = AddItems.AFTER;
							}
						}
							// add as last item
						else if (index>=destination.numElements) {
							position = AddItems.LAST;
						}
							// add after first item
						else if (index>0) {
							relativeTo = destination.getElementAt(index-1);
							position = AddItems.AFTER;
						}
					}
				}
			}
			
			
			reverseAddItems.destination = destination;
			reverseAddItems.position = position;
			reverseAddItems.relativeTo = relativeTo;
			reverseAddItems.propertyName = propertyName;
			reverseAddItems.isArray = isArray;
			reverseAddItems.isStyle = isStyle;
			reverseAddItems.vectorClass = vectorClass;
			
			return reverseAddItems;
		}
		
		/**
		 * Stores a history event in the history events dictionary
		 * Changes can contain a property changes object or add items object
		 * */
		public static function removeHistoryEvent(changes:Array):void {
			var historyEvent:HistoryEvent;
			var change:Object;
			
			// delete change objects
			for each (change in changes) {
				historyEventsDictionary[change] = null;
				delete historyEventsDictionary[change];
			}
			
		}
		
		/**
		 * Adds property change items to the history array
		 * */
		public static function addHistoryItem(changes:Array):void {
			var currentIndex:int = getHistoryIndex();
			var length:int = history.length;
			
			history.disableAutoUpdate();
			
			// trim history 
			if (currentIndex!=length-1) {
				for (var i:int = length-1;i>currentIndex;i--) {
					history.removeItemAt(i);
				}
			}
			
			history.addItem(changes);
			history.enableAutoUpdate();
			
			historyIndex = getHistoryIndex();
			
			instance.dispatchHistoryChangeEvent(currentIndex+1, currentIndex);
		}
		
		/**
		 * Removes property change items in the history array
		 * */
		public static function removeHistoryItem(changes:Array):void {
			var currentIndex:int = getHistoryIndex();
			
			var itemIndex:int = history.getItemIndex(changes);
			
			if (itemIndex>0) {
				history.removeItemAt(itemIndex);
			}
			
			historyIndex = getHistoryIndex();
			
			instance.dispatchHistoryChangeEvent(currentIndex-1, currentIndex);
		}
		
		/**
		 * Removes all history in the history array
		 * */
		public static function removeAllHistory():void {
			var currentIndex:int = getHistoryIndex();
			history.removeAll();
			instance.dispatchHistoryChangeEvent(-1, currentIndex);
		}
	}
}

class SINGLEDOUBLE{}