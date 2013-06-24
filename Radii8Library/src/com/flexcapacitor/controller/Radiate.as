
package com.flexcapacitor.controller {
	import com.flexcapacitor.components.IDocument;
	import com.flexcapacitor.events.HistoryEventItem;
	import com.flexcapacitor.events.HistoryItem;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.logging.RadiateLogTarget;
	import com.flexcapacitor.model.Device;
	import com.flexcapacitor.model.EventMetaData;
	import com.flexcapacitor.model.MetaData;
	import com.flexcapacitor.model.StyleMetaData;
	import com.flexcapacitor.tools.ITool;
	import com.flexcapacitor.utils.TypeUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.system.ApplicationDomain;
	import flash.ui.Mouse;
	import flash.ui.MouseCursorData;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	import mx.core.FlexGlobals;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.effects.effectClasses.PropertyChanges;
	import mx.logging.AbstractTarget;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.LayoutManager;
	import mx.states.AddItems;
	import mx.utils.ArrayUtil;
	
	import spark.components.Application;
	import spark.components.Scroller;
	import spark.components.supportClasses.GroupBase;
	import spark.core.ContentCache;
	import spark.core.IViewport;
	import spark.effects.SetAction;
	import spark.layouts.BasicLayout;
	
	import org.as3commons.lang.ArrayUtils;
	
	use namespace mx_internal;
	
	/**
	 * Dispatched when an item is added to the target
	 * */
	[Event(name="addItem", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when an item is removed from the target
	 * */
	[Event(name="removeItem", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
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
	 * Dispatched when a property is selected on the target
	 * */
	[Event(name="propertySelected", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when a property edit is requested
	 * */
	[Event(name="propertyEdit", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when the tool changes
	 * */
	[Event(name="toolChange", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when the scale changes
	 * */
	[Event(name="scaleChange", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when the document size or scale changes
	 * */
	[Event(name="documentSizeChange", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Not used yet. 
	 * */
	[Event(name="initialized", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Used when the tools list has been updated. 
	 * */
	[Event(name="toolsUpdated", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Used when the components list is updated. 
	 * */
	[Event(name="componentsUpdated", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Used when the document canvas is updated. 
	 * */
	[Event(name="canvasChange", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Event to request a preview if available. Used for HTML preview. 
	 * */
	[Event(name="requestPreview", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when the generated code is updated. 
	 * */
	[Event(name="codeUpdated", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when a color is selected. 
	 * */
	[Event(name="colorSelected", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
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
		public static const REMOVE_ERROR:String = "removeError";
		public static const RADIATE_LOG:String = "radiate";
		
		public function Radiate(s:SINGLEDOUBLE) {
			super(target as IEventDispatcher);
			
			// Create a target
			setLoggingTarget(defaultLogTarget);
			
			
			// initialize
			initialize();
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
		
		/**
		 * Create references for classes we need.
		 * */
		public static var radiateReferences:RadiateReferences;
		
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
		 * Dispatch scale change event
		 * */
		public function dispatchScaleChangeEvent(target:*, scaleX:Number = NaN, scaleY:Number = NaN):void {
			var scaleChangeEvent:RadiateEvent = new RadiateEvent(RadiateEvent.SCALE_CHANGE, false, false, target, null, null);
			
			if (hasEventListener(RadiateEvent.SCALE_CHANGE)) {
				scaleChangeEvent.scaleX = scaleX;
				scaleChangeEvent.scaleY = scaleY;
				dispatchEvent(scaleChangeEvent);
			}
		}
		
		/**
		 * Dispatch document size change event
		 * */
		public function dispatchDocumentSizeChangeEvent(target:*):void {
			var scaleChangeEvent:RadiateEvent = new RadiateEvent(RadiateEvent.DOCUMENT_SIZE_CHANGE, false, false, target, null, null);
			
			if (hasEventListener(RadiateEvent.DOCUMENT_SIZE_CHANGE)) {
				dispatchEvent(scaleChangeEvent);
			}
		}
		
		/**
		 * Dispatch preview event
		 * */
		public function dispatchPreviewEvent(code:String, type:String):void {
			var previewEvent:RadiateEvent = new RadiateEvent(RadiateEvent.REQUEST_PREVIEW);
			
			if (hasEventListener(RadiateEvent.REQUEST_PREVIEW)) {
				previewEvent.previewType = type;
				previewEvent.value = code;
				dispatchEvent(previewEvent);
			}
		}
		
		
		/**
		 * Dispatch code updated event
		 * */
		public function dispatchCodeUpdatedEvent(code:String, type:String):void {
			var codeUpdatedEvent:RadiateEvent = new RadiateEvent(RadiateEvent.CODE_UPDATED);
			
			if (hasEventListener(RadiateEvent.CODE_UPDATED)) {
				codeUpdatedEvent.previewType = type;
				codeUpdatedEvent.value = code;
				dispatchEvent(codeUpdatedEvent);
			}
		}
		
		/**
		 * Dispatch color selected event
		 * */
		public function dispatchColorSelectedEvent(color:uint, invalid:Boolean = false):void {
			var colorSelectedEvent:RadiateEvent = new RadiateEvent(RadiateEvent.COLOR_SELECTED);
			
			if (hasEventListener(RadiateEvent.COLOR_SELECTED)) {
				colorSelectedEvent.color = color;
				colorSelectedEvent.invalid = invalid;
				dispatchEvent(colorSelectedEvent);
			}
		}
		
		/**
		 * Dispatch property selected event
		 * */
		public function dispatchPropertySelectedEvent(property:String, node:MetaData = null):void {
			var colorSelectedEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROPERTY_SELECTED);
			
			if (hasEventListener(RadiateEvent.PROPERTY_SELECTED)) {
				colorSelectedEvent.property = property;
				colorSelectedEvent.selectedItem = node;
				dispatchEvent(colorSelectedEvent);
			}
		}
		
		/**
		 * Dispatch color preview event
		 * */
		public function dispatchColorPreviewEvent(color:uint, invalid:Boolean = false):void {
			var colorPreviewEvent:RadiateEvent = new RadiateEvent(RadiateEvent.COLOR_PREVIEW);
			
			if (hasEventListener(RadiateEvent.COLOR_PREVIEW)) {
				colorPreviewEvent.color = color;
				colorPreviewEvent.invalid = invalid;
				dispatchEvent(colorPreviewEvent);
			}
		}
		
		/**
		 * Dispatch canvas change event
		 * */
		public function dispatchCanvasChangeEvent(canvas:*, canvasBackgroundParent:*, scroller:Scroller):void {
			var targetChangeEvent:RadiateEvent = new RadiateEvent(RadiateEvent.CANVAS_CHANGE);
			
			if (hasEventListener(RadiateEvent.CANVAS_CHANGE)) {
				dispatchEvent(targetChangeEvent);
			}
		}
		
		/**
		 * Dispatch tool change event
		 * */
		public function dispatchToolChangeEvent(value:ITool):void {
			var toolChangeEvent:RadiateEvent = new RadiateEvent(RadiateEvent.TOOL_CHANGE);
			
			if (hasEventListener(RadiateEvent.TOOL_CHANGE)) {
				toolChangeEvent.selectedItem = target && target is Array ? target[0] : target;
				toolChangeEvent.targets = targets;
				toolChangeEvent.tool = value;
				dispatchEvent(toolChangeEvent);
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
				event.historyEventItem = getHistoryItemAtIndex(newIndex);
				dispatchEvent(event);
			}
		}
		
		/**
		 * Sets the logging target
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
		
		/**
		 * Creates the list of components and tools.
		 * */
		public static function initialize():void {
			
			
			createComponentList();
			
			createToolsList();
			
			createDevicesList();
		}
		
		/**
		 * Creates the list of components.
		 * */
		public static function createComponentList():void {
			var xml:XML;
			var length:uint;
			var items:XMLList;
			var className:String;
			var skinClassName:String;
			var inspectorClassName:String;
			var hasDefinition:Boolean;
			var classType:Object;
			var includeItem:Boolean;
			var attributes:XMLList;
			var attributesLength:int;
			var defaults:Object;
			var propertyName:String;
			var item:XML;
			
			
			
			xml = new XML(new Radii8LibrarySparkAssets.sparkManifestDefaults());
			
			// get list of component classes 
			items = XML(xml).component;
			
			length = items.length();
			
			for (var i:int;i<length;i++) {
				item = items[i];
				
				var name:String = String(item.id);
				className = item.attribute("class");
				skinClassName = item.attribute("skinClass");
				inspectorClassName = item.attribute("inspector");
				
				includeItem = item.attribute("include")=="false" ? false : true;
				
				if (!includeItem) continue;
				
				
				// check that definitions exist in domain
				// skip any support classes
				if (className.indexOf("mediaClasses")==-1 && 
					className.indexOf("gridClasses")==-1 &&
					className.indexOf("windowClasses")==-1 &&
					className.indexOf("supportClasses")==-1) {
					
					hasDefinition = ApplicationDomain.currentDomain.hasDefinition(className);
					
					if (hasDefinition) {
						classType = ApplicationDomain.currentDomain.getDefinition(className);
						
						// need to check if we have the skin as well
						
						//hasDefinition = ApplicationDomain.currentDomain.hasDefinition(skinClassName);
						
						if (hasDefinition) {
							
							// get default values
							if (item.defaults) {
								attributes = item.defaults.attributes();
								attributesLength = attributes.length();
								defaults = {};
								
								for each (var value:Object in attributes) {
									propertyName = String(value.name());
									
									if (propertyName=="dataProvider") {
										var array:Array = String(value).split(",");
										defaults[propertyName] = new ArrayCollection(array);
									}
									else {
										defaults[propertyName] = String(value);
									}
								}
							}
							
							addComponentType(item.@id, className, classType, inspectorClassName, null, defaults);
						}
						else {
							log.error("Component skin class, '" + skinClassName + "' not found for '" + className + "'.");
						}
					}
					else {
						log.error("Component class not found: " + className);
					}
					
				}
				else {
					// delete support classes
					// may need to refactor why we are including them in the first place
					delete items[i];
					length--;
				}
			}
			
			// componentDescriptions should now be populated
		}
		
		
		/**
		 * Creates the list of tools.
		 * */
		public static function createToolsList():void {
			var inspectorClassName:String;
			var hasDefinition:Boolean;
			var toolClassDefinition:Object;
			var inspectorClassDefinition:Object;
			var inspectorClassFactory:ClassFactory;
			var toolClassFactory:ClassFactory;
			var items:XMLList;
			var className:String;
			var includeItem:Boolean;
			var attributes:XMLList;
			var length:uint;
			var attributesLength:int;
			var defaults:Object;
			var propertyName:String;
			var xml:XML;
			var toolInstance:ITool;
			var inspectorInstance:UIComponent;
			var name:String;
			var cursorItems:XMLList;
			var cursorItem:XML;
			var cursorName:String;
			var cursors:Dictionary;
			var cursorsCount:int;
			var cursorData:MouseCursorData;
			var cursorBitmapDatas:Vector.<BitmapData>;
			var cursorBitmap:Bitmap;
			var cursorClass:Class;
			var cursorID:String;
			var cursorX:int;
			var cursorY:int;
			var item:XML;
			
			
			xml = new XML(new Radii8LibraryToolAssets.toolManifestDefaults());
			
			// get list of tool classes 
			items = XML(xml).tool;
			
			length = items.length();
			
			for (var i:int;i<length;i++) {
				item = items[i];
				
				name = String(item.id);
				className = item.attribute("class");
				inspectorClassName = item.attribute("inspector");
				cursorItems = item..cursor;
				
				includeItem = item.attribute("include")=="false" ? false : true;
				
				if (!includeItem) continue;
				
				hasDefinition = ApplicationDomain.currentDomain.hasDefinition(className);
				
				if (hasDefinition) {
					toolClassDefinition = ApplicationDomain.currentDomain.getDefinition(className);
					
					
					// get default values
					if (item.defaults) {
						attributes = item.defaults.attributes();
						attributesLength = attributes.length();
						defaults = {};
						
						for each (var value:Object in attributes) {
							propertyName = String(value.name());
							
							if (propertyName=="dataProvider") {
								defaults[propertyName] = new ArrayCollection(String(value).split(","));
							}
							else {
								defaults[propertyName] = String(value);
							}
						}
					}
					
					// create tool
					toolClassFactory = new ClassFactory(toolClassDefinition as Class);
					toolClassFactory.properties = defaults;
					toolInstance = toolClassFactory.newInstance();
					
					
					// create inspector
					if (inspectorClassName!="") {
						hasDefinition = ApplicationDomain.currentDomain.hasDefinition(inspectorClassName);
						
						if (hasDefinition) {
							inspectorClassDefinition = ApplicationDomain.currentDomain.getDefinition(inspectorClassName);
							
							// Create tool inspector
							inspectorClassFactory = new ClassFactory(inspectorClassDefinition as Class);
							//classFactory.properties = defaults;
							inspectorInstance = inspectorClassFactory.newInstance();
					
						}
						else {
							var errorMessage:String = "Could not find inspector, '" + inspectorClassName + "' for tool, '" + className + "'. ";
							errorMessage += "You may need to add a reference to it in RadiateReferences.";
							log.error(errorMessage);
						}
					}
					
					
					cursorsCount = cursorItems.length();
					
					if (cursorsCount>0) {
						cursors = new Dictionary(false);
					}

					// create mouse cursors
					for (var j:int=0;j<cursorsCount;j++) {
						cursorItem = cursorItems[j];
						cursorName = cursorItem.@name.toString();
						cursorX = int(cursorItem.@x.toString());
						cursorY = int(cursorItem.@y.toString());
						cursorID = cursorName != "" ? className + "." + cursorName : className;
			
						// Create a MouseCursorData object 
						cursorData = new MouseCursorData();
						
						// Specify the hotspot 
						cursorData.hotSpot = new Point(cursorX, cursorY); 
						
						// Pass the cursor bitmap to a BitmapData Vector 
						cursorBitmapDatas = new Vector.<BitmapData>(1, true); 
						
						// Create the bitmap cursor 
						// The bitmap must be 32x32 pixels or smaller, due to an OS limitation
						//CursorClass = Radii8LibraryToolAssets.EyeDropper;
						
						if (cursorName) {
							cursorClass = toolClassDefinition[cursorName];
						}
						else {
							cursorClass = toolClassDefinition["Cursor"];
						}
						
						cursorBitmap = new cursorClass();
						
						// Pass the value to the bitmapDatas vector 
						cursorBitmapDatas[0] = cursorBitmap.bitmapData;
						
						// Assign the bitmap to the MouseCursor object 
						cursorData.data = cursorBitmapDatas;
						
						// Register the MouseCursorData to the Mouse object with an alias 
						Mouse.registerCursor(cursorID, cursorData);
						
						cursors[cursorName] = {cursorData:cursorData, id:cursorID};
					}
					
					if (cursorsCount>0) {
						mouseCursors[className] = cursors;
					}
					
					//trace("tool cursors:", cursors);
					var toolDescription:ComponentDescription = addToolType(item.@id, className, toolClassDefinition, toolInstance, inspectorClassName, null, defaults, null, cursors);
					//trace("tool cursors:", toolDescription.cursors);
				}
				else {
					//trace("Tool class not found: " + classDefinition);
					log.error("Tool class not found: " + toolClassDefinition);
				}
				
			}
			
			// toolDescriptions should now be populated
		}
		
		/**
		 * Creates the list of devices.
		 * */
		public static function createDevicesList():void {
			var includeItem:Boolean;
			var items:XMLList;
			var length:uint;
			var name:String;
			var item:XML;
			var xml:XML;
			var device:Device;
			var type:String;
			
			const RES_WIDTH:String = "resolutionWidth";
			const RES_HEIGHT:String = "resolutionHeight";
			const USABLE_WIDTH_PORTRAIT:String = "usableWidthPortrait";
			const USABLE_HEIGHT_PORTRAIT:String = "usableHeightPortrait";
			const USABLE_WIDTH_LANDSCAPE:String = "usableWidthLandscape";
			const USABLE_HEIGHT_LANDSCAPE:String = "usableHeightLandscape";
			
			xml = new XML(new Radii8LibraryDeviceAssets.deviceManifestDefaults());
			
			// get list of device classes 
			items = XML(xml).size;
			
			length = items.length();
			
			for (var i:int;i<length;i++) {
				item = items[i];
				
				name = item.attribute("name");
				type = item.attribute("type");
				
				device = new Device();
				device.name = name;
				device.type = type;
				
				if (type=="device") {
					device.ppi 					= item.attribute("ppi");
					
					device.resolutionWidth 		= item.attribute(RES_WIDTH);
					device.resolutionHeight 	= item.attribute(RES_HEIGHT);
					device.usableWidthPortrait 	= item.attribute(USABLE_WIDTH_PORTRAIT);
					device.usableHeightPortrait = item.attribute(USABLE_HEIGHT_PORTRAIT);
					device.usableWidthLandscape = item.attribute(USABLE_WIDTH_LANDSCAPE);
					device.usableHeightLandscape = item.attribute(USABLE_HEIGHT_LANDSCAPE);
				}
				else if (type=="screen") {
					device.ppi 					= item.attribute("ppi");
					device.resolutionWidth 		= item.attribute(RES_WIDTH);
					device.resolutionHeight 	= item.attribute(RES_HEIGHT);
					continue;
				}
				
				includeItem = item.attribute("include")=="false" ? false : true;
				
				deviceCollections.addItem(device);
				
			}
			
			// componentDescriptions should now be populated
		}
		
		/**
		 * Helper method to get the ID of the mouse cursor by name.
		 * 
		 * */
		public function getMouseCursorID(tool:ITool, name:String = "Cursor"):String {
			var component:ComponentDescription = getToolDescription(tool);
			
			
			if (component.cursors && component.cursors[name]) {
				return component.cursors[name].id;
			}
			
			return null;
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
		
		/**
		 *  Get's a non null document. Should not be doing this for production. 
		 * */
		public function getNonNullDocument():Object {
			if (_documents.length > 0)
				return _documents[0];
			else
				return FlexGlobals.topLevelApplication;
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
		
		public var toolLayer:IVisualElementContainer;
		
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
		
		/**
		 * Is true when preview is visible. This is manually set. 
		 * Needs refactoring. 
		 * */
		public var isPreviewVisible:Boolean;
		
		/**
		 * Collection of mouse cursors that can be added or removed to 
		 * */
		[Bindable]
		public static var mouseCursors:Dictionary = new Dictionary(true);
		
		//----------------------------------
		//
		//  Device Management
		// 
		//----------------------------------
		
		/**
		 * Collection of devices
		 * */
		[Bindable]
		public static var deviceCollections:ArrayCollection = new ArrayCollection();
		
		
		//----------------------------------
		//
		//  Tools Management
		// 
		//----------------------------------
		
		public var _selectedTool:ITool;
		
		/**
		 * Get selected tool.
		 * */
		public function get selectedTool():ITool {
			return _selectedTool;
		}
		
		/**
		 * Collection of tools that can be added or removed to 
		 * */
		[Bindable]
		public static var toolsDescriptions:ArrayCollection = new ArrayCollection();
		
		/**
		 * Add the named tool class to the list of available tools.
		 * 
		 * Not sure if we should create an instance here or earlier or later. 
		 * */
		public static function addToolType(name:String, className:String, classType:Object, instance:ITool, inspectorClassName:String, icon:Object = null, defaultProperties:Object=null, defaultStyles:Object=null, cursors:Dictionary = null):ComponentDescription {
			var definition:ComponentDescription;
			var length:uint = toolsDescriptions.length;
			var item:ComponentDescription;
			
			for (var i:uint;i<length;i++) {
				item = toolsDescriptions.getItemAt(i) as ComponentDescription;
				
				// check if it exists already
				if (item && item.classType==classType) {
					return item;
					//return false;
				}
			}
			
			definition = new ComponentDescription();
			
			definition.name = name;
			definition.icon = icon;
			definition.className = className;
			definition.classType = classType;
			definition.defaultStyles = defaultStyles;
			definition.defaultProperties = defaultProperties;
			definition.instance = instance;
			definition.inspectorClassName = inspectorClassName;
			definition.cursors = cursors;
			
			toolsDescriptions.addItem(definition);
			
			return definition;
		}
		
		/**
		 * Sets the selected tool
		 * */
		public function setTool(value:ITool, dispatchEvent:Boolean = true, cause:String = ""):void {
			
			if (selectedTool) {
				selectedTool.disable();
			}
			
			_selectedTool = value;
			
			if (selectedTool) {
				selectedTool.enable();
			}
			
			if (dispatchEvent) {
				instance.dispatchToolChangeEvent(selectedTool);
			}
			
		}
		
		/**
		 * Get tool description.
		 * */
		public function getToolDescription(instance:ITool):ComponentDescription {
			var length:int = toolsDescriptions.length;
			var componentDescription:ComponentDescription;
			
			for (var i:int;i<length;i++) {
				componentDescription = ComponentDescription(toolsDescriptions.getItemAt(i));
				
				if (componentDescription.instance==instance) {
					return componentDescription;
				}
			}
			
			return null;
		}
		
		/**
		 * Get tool by name.
		 * */
		public function getToolByName(name:String):ComponentDescription {
			var length:int = toolsDescriptions.length;
			var componentDescription:ComponentDescription;
			
			for (var i:int;i<length;i++) {
				componentDescription = ComponentDescription(toolsDescriptions.getItemAt(i));
				
				if (componentDescription.className==name) {
					return componentDescription;
				}
			}
			
			return null;
		}
		
		/**
		 * Get tool by type.
		 * */
		public function getToolByType(type:Class):ComponentDescription {
			var length:int = toolsDescriptions.length;
			var componentDescription:ComponentDescription;
			
			for (var i:int;i<length;i++) {
				componentDescription = ComponentDescription(toolsDescriptions.getItemAt(i));
				
				if (componentDescription.classType==type) {
					return componentDescription;
				}
			}
			
			return null;
		}
		
		//----------------------------------
		//
		//  Scale Management
		// 
		//----------------------------------
		
		/**
		 * Stops on the scale
		 * */
		public var scaleStops:Array = [.05,.0625,.0833,.125,.1666,.25,.333,.50,.667,1,1.25,1.50,1.75,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
		
		/**
		 * Increases the zoom of the target application to next value 
		 * */
		public function increaseScale(valueFrom:Number = NaN, dispatchEvent:Boolean = true):void {
			var newScale:Number;
			var currentScale:Number;
			
		
			if (isNaN(valueFrom)) {
				currentScale = Number(DisplayObject(document).scaleX.toFixed(4));
			}
			else {
				currentScale = valueFrom;
			}
			
			//newScale = DisplayObject(document).scaleX;
			
			for (var i:int=0;i<scaleStops.length;i++) {
				if (currentScale<scaleStops[i]) {
					newScale = scaleStops[i];
					break;
				}
			}
			
			if (i==scaleStops.length-1) {
				newScale = scaleStops[i];
			}
			
			newScale = Number(newScale.toFixed(4));
			
			setScale(newScale, dispatchEvent);
				
		}
		
		/**
		 * Decreases the zoom of the target application to next value 
		 * */
		public function decreaseScale(valueFrom:Number = NaN, dispatchEvent:Boolean = true):void {
			var newScale:Number;
			var currentScale:Number;
		
			if (isNaN(valueFrom)) {
				currentScale = Number(DisplayObject(document).scaleX.toFixed(4));
			}
			else {
				currentScale = valueFrom;
			}
			
			//newScale = DisplayObject(document).scaleX;
			
			for (var i:int=scaleStops.length;i--;) {
				if (currentScale>scaleStops[i]) {
					newScale = scaleStops[i];
					break;
				}
			}
			
			if (i==0) {
				newScale = scaleStops[i];
			}
			
			newScale = Number(newScale.toFixed(4));
			
			setScale(newScale, dispatchEvent);
				
		}
		
		/**
		 * Sets the zoom of the target application to value. 
		 * */
		public function setScale(value:Number, dispatchEvent:Boolean = true):void {
			
			if (document && !isNaN(value) && value>0) {
				DisplayObject(document).scaleX = value;
				DisplayObject(document).scaleY = value;
				
				if (dispatchEvent) {
					dispatchScaleChangeEvent(document, value, value);
				}
			}
		}
		
		/**
		 * Gets the scale of the target application. 
		 * */
		public function getScale():Number {
			
			if (document && document is DisplayObject) {
				return Math.max(DisplayObject(document).scaleX, DisplayObject(document).scaleY);
			}
			
			return NaN;
		}
			
		/**
		 * Center the application
		 * */
		public function centerApplication(vertically:Boolean = true, verticallyTop:Boolean = true, totalDocumentPadding:int = 0):void {
			var viewport:IViewport = canvasScroller.viewport;
			//var contentHeight:int = viewport.contentHeight * getScale();
			//var contentWidth:int = viewport.contentWidth * getScale();
			// get document size NOT scroll content size
			var contentHeight:int = DisplayObject(document).height * getScale();
			var contentWidth:int = DisplayObject(document).width * getScale();
			var newHorizontalPosition:int;
			var newVerticalPosition:int;
			var needsValidating:Boolean;
			var vsbWidth:int = canvasScroller.verticalScrollBar ? canvasScroller.verticalScrollBar.width : 11;
			var hsbHeight:int = canvasScroller.horizontalScrollBar ? canvasScroller.horizontalScrollBar.height : 11;
			var availableWidth:int = canvasScroller.width;// - vsbWidth;
			var availableHeight:int = canvasScroller.height;// - hsbHeight;
			
			if (LayoutManager.getInstance().isInvalid()) {
				needsValidating = true;
				//LayoutManager.getInstance().validateClient(canvasScroller as ILayoutManagerClient);
				//LayoutManager.getInstance().validateNow();
			}
			
			
			if (vertically) {
				// scroller height 359, content height 504, content height validated 550
				// if document is taller than available space and 
				// verticalTop is true then keep it at the top
				if (contentHeight > availableHeight && verticallyTop) {
					newVerticalPosition = canvasBackground.y - totalDocumentPadding;
					viewport.verticalScrollPosition = Math.max(0, newVerticalPosition);
				}
				else if (contentHeight > availableHeight) {
					newVerticalPosition = (contentHeight + hsbHeight - availableHeight) / 2;
					viewport.verticalScrollPosition = Math.max(0, newVerticalPosition);
				}
				else {
					// content height 384, scroller height 359, vsp 12
					newVerticalPosition = (availableHeight + hsbHeight - contentHeight) / 2;
					viewport.verticalScrollPosition = Math.max(0, newVerticalPosition);
				}
			}
			
			// if width of content is wider than canvasScroller width then center
			if (canvasScroller.width < contentWidth) {
				newHorizontalPosition = (contentWidth - availableWidth) / 2;
				viewport.horizontalScrollPosition = Math.max(0, newHorizontalPosition);
			}
			else {
				//newHorizontalPosition = (contentWidth - canvasScroller.width) / 2;
				//viewport.horizontalScrollPosition = Math.max(0, newHorizontalPosition);
			}
		}
		
		/**
		 * Restores the scale of the target application to 100%.
		 * */
		public function restoreDefaultScale(dispatchEvent:Boolean = true):void {
			if (document) {
				setScale(1, dispatchEvent);
			}
		}
		
		/**
		 * Sets the scale to fit the available space. 
		 * */
		public function scaleToFit(dispatchEvent:Boolean = true):void {
			var width:int;
			var height:int;
			var availableWidth:int;
			var availableHeight:int;
			var widthScale:Number;
			var heightScale:Number;
			var newScale:Number;
			
			if (document) {
			
				//width = DisplayObject(document).width;
				//height = DisplayObject(document).height;
				width = DisplayObject(document).width;
				height = DisplayObject(document).height;
				var vsbWidth:int = canvasScroller.verticalScrollBar ? canvasScroller.verticalScrollBar.width : 20;
				var hsbHeight:int = canvasScroller.horizontalScrollBar ? canvasScroller.horizontalScrollBar.height : 20;
				availableWidth = canvasScroller.width - vsbWidth*2.5;
				availableHeight = canvasScroller.height - hsbHeight*2.5;
				
				//var scrollerPaddedWidth:int = canvasScroller.width + documentPadding;
				//var scrollerPaddedHeight:int = canvasScroller.height + documentPadding;
			
                // if the visible area is less than our content then scale down
                if (height > availableHeight || width > availableWidth) {
					heightScale = availableHeight/height;
					widthScale = availableWidth/width;
					newScale = Math.min(widthScale, heightScale);
					width = newScale * width;
					height = newScale * height;
                }
				else if (height < availableHeight && width < availableWidth) {
					newScale = Math.min(availableHeight/height, availableWidth/width);
					width = newScale * width;
					height = newScale * height;
					//newScale = Math.min(availableHeight/height, availableWidth/width);
					//newScale = Math.max(availableHeight/height, availableWidth/width);
                }

				setScale(newScale, dispatchEvent);
				
				////////////////////////////////////////////////////////////////////////////////
				/*var documentRatio:Number = width / height;
				var canvasRatio:Number = availableWidth / availableHeight;
				
				var newRatio:Number = documentRatio / canvasRatio;
				newRatio = canvasRatio / documentRatio;
				newRatio = 1-documentRatio / canvasRatio;*/
					
			}
		}
		
		//----------------------------------
		//
		//  Documentation Utility
		// 
		//----------------------------------
		
		//public static var docsURL:String = "http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/";
		public static var docsURL:String = "http://flex.apache.org/asdoc/";
		
		public static function getURLToHelp(metadata:MetaData):String {
			var path:String = "";
			var currentClass:String;
			var sameClass:Boolean;
			var prefix:String = "";
			var url:String;
			
			if (metadata && metadata.declaredBy) {
				currentClass = String(metadata.declaredBy).replace(/::|\./g, "/");
				
				if (metadata is StyleMetaData) {
					prefix = "style:";
				}
				else if (metadata is EventMetaData) {
					prefix = "event:";
				}
				
				
				path = currentClass + ".html#" + prefix + metadata.name;
			}
			
			url  = docsURL + path;
			
			return url;
		}
		
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
		public static function addComponentType(name:String, className:String, classType:Object, inspectorClassName:String, icon:Object = null, defaultProperties:Object=null, defaultStyles:Object=null):Boolean {
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
			definition.inspectorClassName = inspectorClassName;
			
			componentDescriptions.addItem(definition);
			
			return true;
		}
		
		/**
		 * Remove the named component class
		 * */
		public static function removeComponentType(className:String):Boolean {
			var definition:ComponentDescription;
			var length:uint = componentDescriptions.length;
			var item:ComponentDescription;
			
			for (var i:uint;i<length;i++) {
				item = componentDescriptions.getItemAt(i) as ComponentDescription;
				
				if (item && item.classType==className) {
					componentDescriptions.removeItemAt(i);
				}
			}
			
			return true;
		}
		
		/**
		 * Removes all components. If components were removed then returns true. 
		 * */
		public static function removeAllComponents():Boolean {
			var length:uint = componentDescriptions.length;
			
			if (length) {
				componentDescriptions.removeAll();
				return true;
			}
			
			return false;
		}
		
		/**
		 * The canvas border.
		 * */
		public var canvasBorder:Object;
		
		/**
		 * The canvas background.
		 * */
		public var canvasBackground:Object;
		
		/**
		 * The canvas scroller.
		 * */
		public var canvasScroller:Scroller;
		
		/**
		 * Sets the canvas and canvas parent. Not sure if going to be used. 
		 * May use canvas property on document.
		 * */
		public function setCanvas(canvasBorder:Object, canvasBackground:Object, canvasScroller:Scroller, dispatchEvent:Boolean = true, cause:String = ""):void {
			//if (this.canvasBackground==canvasBackground) return;
			
			this.canvasBorder = canvasBorder;
			this.canvasBackground = canvasBackground;
			this.canvasScroller = canvasScroller;
			
			if (dispatchEvent) {
				instance.dispatchCanvasChangeEvent(canvasBackground, canvasBorder, canvasScroller);
			}
			
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
			/*if (_documents.length==0) {
				clearSelection();
			}*/
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
			/*if (_documents.length==0) {
				clearSelection();
			}*/
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
			return IDocument(instance.document).componentDescription;
		}
		
		/**
		 * Returns true if the property was changed. Use setProperties for 
		 * setting multiple properties.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.setProperty(myButton, "x", 40);</pre>
		 * <pre>Radiate.setProperty([myButton,myButton2], "x", 40);</pre>
		 * */
		public static function clearStyle(target:Object, style:String, description:String = null):Boolean {
			
			return setStyle(target, style, undefined, description, true);
		}
		
		/**
		 * Returns true if the property was changed. Use setProperties for 
		 * setting multiple properties.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.setProperty(myButton, "x", 40);</pre>
		 * <pre>Radiate.setProperty([myButton,myButton2], "x", 40);</pre>
		 * */
		public static function setStyle(target:Object, style:String, value:*, description:String = null, keepUndefinedValues:Boolean = false):Boolean {
			var targets:Array = ArrayUtil.toArray(target);
			var propertyChanges:Array;
			var historyEvents:Array;
			
			propertyChanges = createPropertyChange(targets, null, style, value, description);
			
			
			if (!keepUndefinedValues) {
				propertyChanges = stripUnchangedValues(propertyChanges);
			}
			
			if (changesAvailable(propertyChanges)) {
				applyChanges(targets, propertyChanges, null, style);
				//LayoutManager.getInstance().validateNow(); // applyChanges calls this
				
				historyEvents = createHistoryEvents(targets, propertyChanges, null, style, value);
				
				addHistoryEvents(historyEvents, description);
				instance.dispatchPropertyChangeEvent(targets, propertyChanges, ArrayUtil.toArray(style));
				return true;
			}
			
			return false;
		}
		
		/**
		 * Returns true if the property was changed. Use setProperties for 
		 * setting multiple properties.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.setProperty(myButton, "x", 40);</pre>
		 * <pre>Radiate.setProperty([myButton,myButton2], "x", 40);</pre>
		 * */
		public static function setProperty(target:Object, property:String, value:*, description:String = null, keepUndefinedValues:Boolean = false):Boolean {
			var targets:Array = ArrayUtil.toArray(target);
			var propertyChanges:Array;
			var historyEvents:Array;
			
			propertyChanges = createPropertyChange(targets, property, null, value, description);
			
			
			if (!keepUndefinedValues) {
				propertyChanges = stripUnchangedValues(propertyChanges);
			}
			
			if (changesAvailable(propertyChanges)) {
				applyChanges(targets, propertyChanges, property, null);
				//LayoutManager.getInstance().validateNow(); // applyChanges calls this
				//addHistoryItem(propertyChanges, description);
				
				historyEvents = createHistoryEvents(targets, propertyChanges, property, null, value);
				
				addHistoryEvents(historyEvents, description);
				
				instance.dispatchPropertyChangeEvent(targets, propertyChanges, ArrayUtil.toArray(property));
				
				if (targets.indexOf(instance.document)!=-1 && ArrayUtils.containsAny(notableApplicationProperties, [property])) {
					instance.dispatchDocumentSizeChangeEvent(targets);
				}
				
				return true;
			}
			
			return false;
		}
		
		/**
		 * Properties on the application to listen for for document size change event
		 * */
		public static var notableApplicationProperties:Array = ["width","height","scaleX","scaleY"];
		
		/**
		 * Returns true if the property(s) were changed.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>setProperties([myButton,myButton2], ["x","y"], {x:40,y:50});</pre>
		 * <pre>setProperties(myButton, "x", 40);</pre>
		 * <pre>setProperties(button, ["x", "left"], {x:50,left:undefined});</pre>
		 * 
		 * @see setStyle()
		 * @see setStyles()
		 * @see setProperty()
		 * */
		public static function setProperties(target:Object, properties:Array, value:*, description:String = null, keepUndefinedValues:Boolean = false):Boolean {
			var propertyChanges:Array;
			var historyEvents:Array;
			var targets:Array;
			
			targets = ArrayUtil.toArray(target);
			properties = ArrayUtil.toArray(properties);
			propertyChanges = createPropertyChanges(targets, properties, null, value, description, false);
			
			if (!keepUndefinedValues) {
				propertyChanges = stripUnchangedValues(propertyChanges);
			}
			
			if (changesAvailable(propertyChanges)) {
				applyChanges(targets, propertyChanges, properties, null);
				//LayoutManager.getInstance().validateNow();
				//addHistoryItem(propertyChanges);
				
				historyEvents = createHistoryEvents(targets, propertyChanges, properties, null, value);
				
				addHistoryEvents(historyEvents, description);
				
				instance.dispatchPropertyChangeEvent(targets, propertyChanges, properties);
				
				if (targets.indexOf(instance.document)!=-1 && ArrayUtils.containsAny(notableApplicationProperties, properties)) {
					instance.dispatchDocumentSizeChangeEvent(targets);
				}
				return true;
			}
			
			return false;
		}
		
		/**
		 * Returns true if the property(s) were changed.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>setProperties([myButton,myButton2], ["x","y"], {x:40,y:50});</pre>
		 * <pre>setProperties(myButton, "x", 40);</pre>
		 * <pre>setProperties(button, ["x", "left"], {x:50,left:undefined});</pre>
		 * 
		 * @see setStyle()
		 * @see setProperty()
		 * @see setProperties()
		 * */
		public static function setStyles(target:Object, styles:Array, value:*, description:String = null, keepUndefinedValues:Boolean = false):Boolean {
			var stylesChanges:Array;
			var historyEvents:Array;
			var targets:Array;
			
			targets = ArrayUtil.toArray(target);
			styles = ArrayUtil.toArray(styles);
			stylesChanges = createPropertyChanges(targets, styles, null, value, description, false);
			
			if (!keepUndefinedValues) {
				stylesChanges = stripUnchangedValues(stylesChanges);
			}
			
			if (changesAvailable(stylesChanges)) {
				applyChanges(targets, stylesChanges, null, styles);
				//LayoutManager.getInstance().validateNow();
				
				historyEvents = createHistoryEvents(targets, stylesChanges, null, styles, value);
				
				addHistoryEvents(historyEvents, description);
				instance.dispatchPropertyChangeEvent(targets, stylesChanges, styles);
				return true;
			}
			
			return false;
		}
		
		/**
		 * Gets the value translated into a type. 
		 * */
		public static function getTypedValue(value:*, valueType:*):* {
			
			return TypeUtils.getTypedValue(value, valueType);
		}
		
		
		/**
		 * Move a component in the display list and sets any properties 
		 * such as positioning<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.moveElement(new Button(), parentComponent, [], null);</pre>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.moveElement(radiate.target, null, ["x"], 15);</pre>
		 * */
		public static function moveElement(items:*, 
										   destination:Object, 
										   properties:Array, 
										   styles:Array,
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
			var propertyChangeChange:PropertyChanges;
			var changes:Array;
			var historyEvents:Array;
			var isSameOwner:Boolean;
			var isSameParent:Boolean;
			var removeBeforeAdding:Boolean;
			var currentIndex:int;
			var movingIndexWithinParent:Boolean;
			
			items = ArrayUtil.toArray(items);
			
			var item:Object = items ? items[0] : null;
			var itemOwner:Object = item ? item.owner : null;
			
			visualElement = item as IVisualElement;
			var visualElementParent:Object = visualElement ? visualElement.parent : null;
			var visualElementOwner:IVisualElementContainer = itemOwner as IVisualElementContainer;
			var applicationGroup:GroupBase = destination is Application ? Application(destination).contentGroup : null;
			
			isSameParent = visualElementParent && (visualElementParent==destination || visualElementParent==applicationGroup);
			isSameOwner = visualElementOwner && visualElementOwner==destination;
			
			// set default description
			if (!description) {
				description = ADD_ITEM_DESCRIPTION;
			}
			
			// if it's a basic layout then don't try to add it
			// NO DO ADD IT bc we may need to swap indexes
			if (destination is IVisualElementContainer) {
				//destinationGroup = destination as GroupBase;
				
				if (destination.layout is BasicLayout) {
					
					// does not support multiple items?
					// check if group parent and destination are the same
					if (item && itemOwner==destination) {
						//trace("can't add to the same owner in a basic layout");
						isSameOwner = true;
						
						//return SAME_OWNER;
					}
					
					// check if group parent and destination are the same
					// NOTE: if the item is an element on application this will fail
					if (item && visualElementParent && (visualElementParent==destination || visualElementParent==applicationGroup)) {
						//trace("can't add to the same parent in a basic layout");
						isSameParent = true;
						//return SAME_PARENT;
					}
				}
				// if element is already child of layout container and there is only one element 
				else if (items && destination is IVisualElementContainer 
						&& destination.numElements==1
						&& visualElementParent
						&& (visualElementParent==destination || visualElementParent==applicationGroup)) {
					
					isSameParent = true;
					isSameOwner = true;
					//trace("can't add to the same parent in a basic layout");
					//return SAME_PARENT;
					
				}
			}
			
			// if destination is null then we assume we are moving
			// WRONG! null should mean remove
			else {
				//isSameParent = true;
				//isSameOwner = true;
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
					visualElement = items is Array && (items as Array).length>0 ? items[0] as IVisualElement : items as IVisualElement;
					
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
						
						// we need to remove first or we get an error in AddItems
						// or we can set relativeTo item and set AFTER
						if (isSameParent && destination.numElements>1) {
							removeBeforeAdding = true;
							relativeTo = destination.getElementAt(destination.numElements-1);
							position = AddItems.AFTER;
						}
						else if (isSameParent) {
							removeBeforeAdding = true;
							position = AddItems.LAST;
						}
						else {
							position = AddItems.LAST;
						}
					}
						// add after first item
					else if (index>0) {
						relativeTo = destination.getElementAt(index-1);
						position = AddItems.AFTER;
					}
				}
				
				
				// check if moving to another index within the same parent 
				if (visualElementOwner && visualElement) {
					currentIndex = visualElementOwner.getElementIndex(visualElement);
					
					if (currentIndex!=index) {
						movingIndexWithinParent = true;
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
			/* euripidies, numenamena, hermermerphermer*/
			// add properties that need to be modified
			if (properties && properties.length>0 ||
				styles && styles.length>0) {
				changes = createPropertyChanges(items, properties, styles, values, description, false);
				
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
				if ((!isSameParent && !isSameOwner) || movingIndexWithinParent) {
					changes.unshift(moveItems); //add before other changes 
				}
				
				if (changes.length==0) {
					return "Nothing to change or add";
				}
				
				// store changes
				historyEvents = createHistoryEvents(items, changes, properties, styles, values, description, RadiateEvent.MOVE_ITEM);
				
				// try moving
				if ((!isSameParent && !isSameOwner) || movingIndexWithinParent) {
					
					// this is to prevent error in AddItem when adding to the last position
					// and we get an index is out of range. 
					// 
					// for example, if an element is at index 0 and there are 3 elements 
					// then addItem will get the last index. 
					// but since the parent is the same the addElement call removes 
					// the element. the max index is reduced by one and previously 
					// determined last index is now out of range. 
					// AddItems was not meant to add an element that has already been added
					// so we remove it before hand so addItems can add it again. 
					if (removeBeforeAdding) {
						visualElementOwner.removeElement(visualElement);
					}
					
					moveItems.apply(moveItems.destination as UIComponent);
					LayoutManager.getInstance().validateNow();
				}
				
				// try setting properties
				if (changesAvailable([propertyChangeChange])) {
					applyChanges(items, [propertyChangeChange], properties, styles);
					LayoutManager.getInstance().validateNow();
				}
				
				// add to history
				addHistoryEvents(historyEvents);
				
				// check for changes before dispatching
				if (changes.indexOf(moveItems)!=-1) {
					instance.dispatchMoveEvent(items, changes, properties);
				}
				
				setTargets(items, true);
				
				if (properties) {
					instance.dispatchPropertyChangeEvent(items, changes, properties);
				}
				
				return MOVED; // we assume moved if it got this far - needs more checking
			}
			catch (error:Error) {
				// this is clunky - needs to be upgraded
				Radiate.log.error("Move error: " + error.message);
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
										  styles:Array,
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
			
			return moveElement(items, destination, properties, styles, values, 
								description, position, relativeTo, index, propertyName, 
								isArray, isStyle, vectorClass, keepUndefinedValues);
			
		}
		
		
		/**
		 * Removes a component from the display list.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.removeElement(radiate.targets);</pre>
		 * */
		public static function removeElement(items:*, description:String = RadiateEvent.REMOVE_ITEM):String {
			
			return moveElement(items, null, null, null, null, 
								description);
		}
		
		/**
		 * Apply changes to targets. You do not call this. Set properties through setProperties method. 
		 * 
		 * @param setStartValues applies the start values rather 
		 * than applying the end values
		 * 
		 * @param property string or array of strings containing the 
		 * names of the properties to set or null if setting styles
		 * 
		 * @param style string or araray of strings containing the 
		 * names of the styles to set or null if setting properties
		 * */
		public static function applyChanges(targets:Array, changes:Array, property:*, style:*, setStartValues:Boolean=false):Boolean {
			var length:int = changes ? changes.length : 0;
			var effect:SetAction = new SetAction();
			var onlyPropertyChanges:Array = [];
			var directApply:Boolean = true;
			var isStyle:Boolean = style && style.length>0;
			
			for (var i:int;i<length;i++) {
				if (changes[i] is PropertyChanges) { 
					onlyPropertyChanges.push(changes[i]);
				}
			}
			
			effect.targets = targets;
			effect.propertyChangesArray = onlyPropertyChanges;
			if (isStyle) {
				effect.property = style;
			}
			effect.relevantProperties = ArrayUtil.toArray(property);
			effect.relevantStyles = ArrayUtil.toArray(style);
			
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
				LayoutManager.getInstance().validateNow();
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
		 * Travel to the specified history index.
		 * Going to fast may cause some issues. Need to test thoroughly 
		 * We may need to call validateNow somewhere and set usePhasedInstantiation?
		 * */
		public static function goToHistoryIndex(index:int, dispatchEvents:Boolean = false):int {
			var newIndex:int = index;
			var oldIndex:int = historyIndex;
			var time:int = getTimer();
			var currentIndex:int;
			var difference:int;
			
			if (newIndex<oldIndex) {
				difference = oldIndex - newIndex;
				for (var i:int;i<difference;i++) {
					currentIndex = undo(dispatchEvents);
				}
			}
			else if (newIndex>oldIndex) {
				difference = oldIndex<0 ? newIndex+1 : newIndex - oldIndex;
				for (var j:int;j<difference;j++) {
					currentIndex = redo(dispatchEvents);
				}
			}
			
			if (currentIndex!=newIndex) {
				historyIndex = getHistoryIndex();
				
				if (dispatchEvents) {
					instance.dispatchHistoryChangeEvent(historyIndex, oldIndex);
				}
			}
			
			return currentIndex;
		}
		
		/**
		 * Undo last change. Returns the current index in the changes array. 
		 * The property change object sets the property "reversed" to 
		 * true.
		 * Going too fast causes some issues (call validateNow somewhere)?
		 * */
		public static function undo(dispatchEvents:Boolean = false, dispatchForApplication:Boolean = true):int {
			var changeIndex:int = getPreviousHistoryIndex(); // index of next change to undo 
			var currentIndex:int = getHistoryIndex();
			var historyLength:int = history.length;
			var historyEvent:HistoryEventItem;
			var currentDocument:Object = instance.document;
			var setStartValues:Boolean = true;
			var historyItem:HistoryItem;
			var affectsDocument:Boolean;
			var historyEvents:Array;
			var dictionary:Dictionary;
			var reverseItems:AddItems;
			var eventTargets:Array;
			var eventsLength:int;
			var targetsLength:int;
			var addItems:AddItems;
			var added:Boolean;
			var action:String;
			
			// no changes
			if (!historyLength) {
				return -1;
			}
			
			// all changes have already been undone
			if (changeIndex<0) {
				if (dispatchEvents && instance.hasEventListener(RadiateEvent.BEGINNING_OF_UNDO_HISTORY)) {
					instance.dispatchEvent(new RadiateEvent(RadiateEvent.BEGINNING_OF_UNDO_HISTORY));
				}
				
				return -1;
			}
			
			// get current change to be redone
			historyItem = history.length ? history.getItemAt(changeIndex) as HistoryItem : null;
			historyEvents = historyItem.historyEvents;
			eventsLength = historyEvents.length;
			
			
			// loop through changes
			for (var i:int=eventsLength;i--;) {
				//changesLength = changes ? changes.length: 0;
				
				historyEvent = historyEvents[i];
				addItems = historyEvent.addItemsInstance;
				action = historyEvent.action;//==RadiateEvent.MOVE_ITEM && addItems ? RadiateEvent.MOVE_ITEM : RadiateEvent.PROPERTY_CHANGE;
				affectsDocument = dispatchForApplication && historyEvent.targets.indexOf(currentDocument)!=-1;
				
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
					
					if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
						instance.dispatchRemoveItemsEvent(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties);
					}
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
							
							if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
								instance.dispatchRemoveItemsEvent(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties);
							}
							
							// was it added - note: can be refactored
							if (reverseItems.destination==null) {
								added = true;
							}
						}
						else {
							applyChanges(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties, historyEvent.styles,
								setStartValues);
							historyEvent.reversed = true;
							
							if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
								instance.dispatchPropertyChangeEvent(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties);
							}
						}
					}
					
					historyEvent.reversed = true;
				}
				// undo the remove
				else if (action==RadiateEvent.REMOVE_ITEM) {
					addItems.apply(addItems.destination as UIComponent);
					historyEvent.reversed = true;
					
					if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
						instance.dispatchAddEvent(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties);
					}
				}
				// undo the property changes
				else if (action==RadiateEvent.PROPERTY_CHANGE) {
				
					applyChanges(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties, historyEvent.styles,
						setStartValues);
					historyEvent.reversed = true;
					
					if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
						instance.dispatchPropertyChangeEvent(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties);
					}
				}
			}
			
			historyItem.reversed = true;
			
			// select the target
			if (selectTargetOnHistoryChange) {
				if (added) {
					instance.setTarget(null, true);
				}
				else {
					instance.setTargets(historyEvent.targets, true);
				}
			}
			
			if (eventsLength) {
				historyIndex = getHistoryIndex();
				
				if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
					instance.dispatchHistoryChangeEvent(historyIndex, currentIndex);
				}
				return changeIndex-1;
			}
			
			return historyLength;
		}
		
		/**
		 * Redo last change
		 * */
		public static function redo(dispatchEvents:Boolean = false, dispatchForApplication:Boolean = true):int {
			var currentDocument:Object = instance.document;
			var changeIndex:int = getNextHistoryIndex();
			var currentIndex:int = getHistoryIndex();
			var historyLength:int = history.length;
			var historyEvent:HistoryEventItem;
			var historyItem:HistoryItem;
			var affectsDocument:Boolean;
			var setStartValues:Boolean;
			var historyEvents:Array;
			var eventsLength:int;
			var addItems:AddItems;
			//var changes:Array;
			//var change:Object;
			var action:String;
			
			// no changes made
			if (!historyLength) {
				return -1;
			}
			
			// cannot redo any more changes
			if (changeIndex==-1 || changeIndex>=historyLength) {
				if (instance.hasEventListener(RadiateEvent.END_OF_UNDO_HISTORY)) {
					instance.dispatchEvent(new RadiateEvent(RadiateEvent.END_OF_UNDO_HISTORY));
				}
				return historyLength-1;
			}
			
			// get current change to be redone
			historyItem = history.length ? history.getItemAt(changeIndex) as HistoryItem : null;
			
			historyEvents = historyItem.historyEvents;
			eventsLength = historyEvents.length;
			//changes = historyEvents;
			
			for (var j:int;j<eventsLength;j++) {
				historyEvent = HistoryEventItem(historyEvents[j]);
				//changesLength = changes ? changes.length: 0;
				
				addItems = historyEvent.addItemsInstance;
				action = historyEvent.action;
				affectsDocument = dispatchForApplication && historyEvent.targets.indexOf(currentDocument)!=-1;

				
				if (action==RadiateEvent.ADD_ITEM) {
					// redo the add
					addItems.apply(addItems.destination as UIComponent);
					historyEvent.reversed = false;
					
					if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
						instance.dispatchAddEvent(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties);
					}
					
				}
				else if (action==RadiateEvent.MOVE_ITEM) {
					// redo the move
					if (addItems) {
						addItems.apply(addItems.destination as UIComponent);
						historyEvent.reversed = false;
						
						if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
							instance.dispatchMoveEvent(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties);
						}
					}
					else {
						
						applyChanges(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties, historyEvent.styles,
							setStartValues);
						historyEvent.reversed = false;
						
						if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
							instance.dispatchPropertyChangeEvent(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties);
						}
					}
					
				}
				else if (action==RadiateEvent.REMOVE_ITEM) {
					// redo the remove
					addItems.remove(addItems.destination as UIComponent);
					historyEvent.reversed = false;
					
					if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
						instance.dispatchRemoveItemsEvent(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties);
					}
				}
				else if (action==RadiateEvent.PROPERTY_CHANGE) {
					applyChanges(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties, historyEvent.styles,
						setStartValues);
					historyEvent.reversed = false;
					
					if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
						instance.dispatchPropertyChangeEvent(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties);
					}
				}
			}
			
			
			historyItem.reversed = false;
			
			// select target
			if (selectTargetOnHistoryChange) {
				instance.setTargets(historyEvent.targets, true);
			}
			
			if (eventsLength) {
				historyIndex = getHistoryIndex();
				
				if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
					instance.dispatchHistoryChangeEvent(historyIndex, currentIndex);
				}
				
				return changeIndex;
			}
			
			return historyLength;
		}
		
		
		private static var _historyIndex:int = -1;
		
		/**
		 * Selects the target on undo and redo
		 * */
		public static var selectTargetOnHistoryChange:Boolean = true;

		/**
		 * Current history index. 
		 * The history index is the index of last applied change. Or
		 * to put it another way the index of the last reversed change minus 1. 
		 * If there are 10 total changes and one has been reversed then 
		 * we would be at the 9th change. The history index would 
		 * be 8 since 9-1 = 8 since the array is a zero based index. 
		 * 
		 * value -1 means no history
		 * value 0 means one item
		 * value 1 means two items
		 * value 2 means three items
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
			var historyItem:HistoryItem;
			var index:int;
			
			for (var i:int;i<length;i++) {
				historyItem = history.getItemAt(i) as HistoryItem;
				
				if (historyItem.reversed) {
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
			var historyItem:HistoryItem;
			var index:int;
			
			// start at the beginning and find the next item to redo
			for (var i:int;i<length;i++) {
				historyItem = history.getItemAt(i) as HistoryItem;
				
				if (historyItem.reversed) {
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
			var historyItem:HistoryItem;
			var index:int;
			
			// go through and find last item that is reversed
			for (var i:int;i<length;i++) {
				historyItem = history.getItemAt(i) as HistoryItem;
				
				if (historyItem.reversed) {
					return i-1;
				}
			}
			
			return length-1;
		}
		
		/**
		 * Returns the history event by index
		 * */
		public function getHistoryItemAtIndex(index:int):HistoryItem {
			var length:int = history.length;
			var historyItem:HistoryItem;
			
			// no changes
			if (!length) {
				return null;
			}
			
			// all changes have already been undone
			if (index<0) {
				return null;
			}
			
			// get change 
			historyItem = history.length ? history.getItemAt(index) as HistoryItem : null;
			
			return historyItem;
		}

		
		/**
		 * Given a target or targets, property name and value
		 * returns an array of PropertyChange objects.
		 * Points to createPropertyChanges()
		 * 
		 * @see createPropertyChanges()
		 * */
		public static function createPropertyChange(targets:Array, property:String, style:String, value:*, description:String = ""):Array {
			var values:Object = {};
			var changes:Array;
			
			if (property) {
				values[property] = value;
			}
			else if (style) {
				values[style] = value;
			}
			
			changes = createPropertyChanges(targets, ArrayUtil.toArray(property), ArrayUtil.toArray(style), values, description, false);
			
			return changes;
		}
		
		/**
		 * Given a target or targets, properties and value object (name value pair)
		 * returns an array of PropertyChange objects.
		 * Value must be an object containing the properties mentioned in the properties array
		 * */
		public static function createPropertyChanges(targets:Array, properties:Array, styles:Array, value:Object, description:String = "", storeInHistory:Boolean = true):Array {
			var tempEffect:SetAction = new SetAction();
			var propertyChanges:PropertyChanges;
			var changes:Array;
			var propertyOrStyle:String;
			var isStyle:Boolean = styles && styles.length>0;
			
			tempEffect.targets = targets;
			tempEffect.property = isStyle ? styles[0] : properties[0];
			tempEffect.relevantProperties = properties;
			tempEffect.relevantStyles = styles;
			
			// get start values for undo
			changes = tempEffect.captureValues(null, true);
			
			// This may be hanging on to bindable objects
			// set the values to be set to the property 
			// ..later - what??? give an example
			for each (propertyChanges in changes) {
				
				// for properties 
				for each (propertyOrStyle in properties) {
					
					// value may be an object with properties or a string
					// because we accept an object containing the values with 
					// the name of the properties or styles
					if (value && propertyOrStyle in value) {
						propertyChanges.end[propertyOrStyle] = value[propertyOrStyle];
					}
					else {
						propertyChanges.end[propertyOrStyle] = value;
					}
				}
				
				// for styles
				for each (propertyOrStyle in styles) {
					
					// value may be an object with properties or a string
					// because we accept an object containing the values with 
					// the name of the properties or styles
					if (value && propertyOrStyle in value) {
						propertyChanges.end[propertyOrStyle] = value[propertyOrStyle];
					}
					else {
						propertyChanges.end[propertyOrStyle] = value;
					}
				}
			}
			
			// we should move this out
			// add property changes array to the history dictionary
			if (storeInHistory) {
				return createHistoryEvents(targets, changes, properties, styles, value, description);
			}
			
			return [propertyChanges];
		}
		
		/**
		 * Creates a history event in the history 
		 * Changes can contain a property or style changes or add items 
		 * */
		public static function createHistoryEvents(targets:Array, changes:Array, properties:*, styles:*, value:*, description:String = null, action:String="propertyChange"):Array {
			var factory:ClassFactory = new ClassFactory(HistoryEventItem);
			var historyEvent:HistoryEventItem;
			var events:Array = [];
			var reverseAddItems:AddItems;
			var change:Object; 
			var length:int;
			
			// create property change objects for each
			for (var i:int;i<changes.length;i++) {
				change = changes[i];
				historyEvent 						= factory.newInstance();
				historyEvent.action 				= action;
				historyEvent.targets 				= targets;
				historyEvent.description 			= description;
				
				// check for property change or add display object
				if (change is PropertyChanges) {
					historyEvent.properties 		= ArrayUtil.toArray(properties);
					historyEvent.styles 			= ArrayUtil.toArray(styles);
					historyEvent.propertyChanges 	= PropertyChanges(change);
				}
				else if (change is AddItems) {
					historyEvent.addItemsInstance 	= AddItems(change);
					length = targets.length;
					
					// trying to add support for multiple targets - it's not all there yet
					// probably not the best place to get the previous values or is it???
					for (var j:int=0;j<length;j++) {
						historyEvent.reverseAddItemsDictionary[targets[j]] = createReverseAddItems(targets[j]);
					}
				}
				events[i] = historyEvent;
			}
			
			return events;
			
		}
		
		/**
		 * Creates a remove item from an add item. 
		 * */
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
			var historyEvent:HistoryEventItem;
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
		public static function addHistoryItem(historyEventItem:HistoryEventItem, description:String = null):void {
			addHistoryEvents(ArrayUtil.toArray(historyEventItem), description);
		}
		
		/**
		 * Adds property change items to the history array
		 * */
		public static function addHistoryEvents(historyEvents:Array, description:String = null):void {
			var historyItem:HistoryItem = new HistoryItem();
			var currentIndex:int = getHistoryIndex();
			var length:int = history.length;
			
			history.disableAutoUpdate();
			
			// trim history 
			if (currentIndex!=length-1) {
				for (var i:int = length-1;i>currentIndex;i--) {
					historyItem = history.removeItemAt(i) as HistoryItem;
					historyItem.purge();
				}
			}
			
			historyItem.description = description ? HistoryEventItem(historyEvents[0]).description : description;
			historyItem.historyEvents = historyEvents;
			
			history.addItem(historyItem);
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
		 * Removes all history in the history array. 
		 * Note: We should set the changes to null. 
		 * */
		public static function removeAllHistory():void {
			var currentIndex:int = getHistoryIndex();
			history.removeAll();
			history.refresh(); // we should loop through and run purge on each HistoryItem
			instance.dispatchHistoryChangeEvent(-1, currentIndex);
		}
	}
}

class SINGLEDOUBLE{}