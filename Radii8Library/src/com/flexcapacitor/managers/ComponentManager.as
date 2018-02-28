package com.flexcapacitor.managers
{
	import com.flexcapacitor.controller.Console;
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.controls.Hyperlink;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.model.Document;
	import com.flexcapacitor.model.ExportOptions;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.MetaData;
	import com.flexcapacitor.model.SourceData;
	import com.flexcapacitor.model.ValuesObject;
	import com.flexcapacitor.states.AddItems;
	import com.flexcapacitor.utils.ArrayUtils;
	import com.flexcapacitor.utils.ClassUtils;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.MXMLDocumentConstants;
	import com.flexcapacitor.utils.StringUtils;
	import com.flexcapacitor.utils.TypeUtils;
	import com.flexcapacitor.utils.XMLUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDefinition;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import flash.display.DisplayObject;
	import flash.display.JointStyle;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.containers.Grid;
	import mx.containers.GridItem;
	import mx.containers.GridRow;
	import mx.controls.ColorPicker;
	import mx.controls.LinkButton;
	import mx.core.ClassFactory;
	import mx.core.Container;
	import mx.core.DeferredInstanceFromFunction;
	import mx.core.IInvalidating;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.effects.effectClasses.PropertyChanges;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	import mx.managers.LayoutManager;
	import mx.styles.IStyleClient;
	import mx.utils.ArrayUtil;
	
	import spark.components.Application;
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.ComboBox;
	import spark.components.DropDownList;
	import spark.components.Grid;
	import spark.components.Label;
	import spark.components.NumericStepper;
	import spark.components.RichText;
	import spark.components.SkinnableContainer;
	import spark.components.supportClasses.DropDownListBase;
	import spark.components.supportClasses.GroupBase;
	import spark.components.supportClasses.SkinnableTextBase;
	import spark.components.supportClasses.SliderBase;
	import spark.components.supportClasses.TextBase;
	import spark.components.supportClasses.ToggleButtonBase;
	import spark.core.ContentCache;
	import spark.layouts.BasicLayout;
	import spark.primitives.Ellipse;
	import spark.primitives.Line;
	import spark.primitives.Path;
	import spark.primitives.Rect;
	import spark.primitives.supportClasses.FilledElement;
	import spark.primitives.supportClasses.GraphicElement;
	import spark.primitives.supportClasses.StrokedElement;
	import spark.skins.spark.DefaultGridItemRenderer;
	
	import org.as3commons.lang.ObjectUtils;

	use namespace mx_internal;

	/**
	 * Manages components, setting properties, styles and events
	 **/
	public class ComponentManager extends Console {
		
		public function ComponentManager(s:SINGLEDOUBLE) {
			
		}
		
		public static const ADDED:String = "added";
		public static const MOVED:String = "moved";
		public static const REMOVED:String = "removed";
		public static const ADD_ERROR:String = "addError";
		public static const REMOVE_ERROR:String = "removeError";
		
		/**
		 * Last created component
		 * */
		public static var lastCreatedComponent:Object;
		
		/**
		 * Collection of visual elements that can be added or removed to 
		 * */
		[Bindable]
		public static var componentDefinitions:ArrayCollection = new ArrayCollection();
		
		/**
		 * Cache for component icons
		 * */
		[Bindable]
		public static var componentIconCache:ContentCache = new ContentCache();
		
		/**
		 * Get the current document.
		 * */
		public static function get selectedDocument():IDocument {
			return Radiate.selectedDocument;
		}
		
		/**
		 * Add the named component class to the list of available components
		 * */
		public static function addComponentDefinition(id:String, 
													  displayName:String,
													  className:String, 
													  classType:Object, 
													  inspectors:Array = null, 
													  icon:Object = null, 
													  defaultProperty:String = null,
													  defaultProperties:Object=null, 
													  defaultStyles:Object=null, 
													  enabled:Boolean = true, 
													  childNodes:Array = null, 
													  dispatchEvents:Boolean = true):Boolean {
			var numberOfDefinitions:uint = componentDefinitions.length;
			var componentDefinition:ComponentDefinition;
			var item:ComponentDefinition;
			
			
			for (var i:uint;i<numberOfDefinitions;i++) {
				item = ComponentDefinition(componentDefinitions.getItemAt(i));
				
				// check if it exists already
				if (item && item.classType==classType) {
					return false;
				}
			}
			
			
			componentDefinition = new ComponentDefinition();
			
			componentDefinition.name = id;
			componentDefinition.displayName = displayName;
			componentDefinition.icon = icon;
			componentDefinition.className = className;
			componentDefinition.classType = classType;
			componentDefinition.defaultStyles = defaultStyles;
			componentDefinition.defaultProperties = defaultProperties;
			componentDefinition.inspectors = inspectors;
			componentDefinition.enabled = enabled;
			componentDefinition.childNodes = childNodes;
			
			componentDefinitions.addItem(componentDefinition);
			
			if (dispatchEvents) {
				Radiate.dispatchComponentDefinitionAddedEvent(componentDefinition);
			}
			
			CodeManager.setComponentDefinitions(componentDefinitions.source);
			
			return true;
		}
		
		/**
		 * Remove the named component class
		 * */
		public static function removeComponentType(className:String):Boolean {
			var definition:ComponentDefinition;
			var numberOfDefinitions:uint = componentDefinitions.length;
			var item:ComponentDefinition;
			
			for (var i:uint;i<numberOfDefinitions;i++) {
				item = ComponentDefinition(componentDefinitions.getItemAt(i));
				
				if (item && item.classType==className) {
					componentDefinitions.removeItemAt(i);
				}
			}
			
			return true;
		}
		
		/**
		 * Get the component by class name
		 * */
		public static function getComponentType(className:String, fullyQualified:Boolean = false):ComponentDefinition {
			var definition:ComponentDefinition;
			var numberOfDefinitions:uint = componentDefinitions.length;
			var item:ComponentDefinition;
			
			for (var i:uint;i<numberOfDefinitions;i++) {
				item = ComponentDefinition(componentDefinitions.getItemAt(i));
				
				if (fullyQualified) {
					if (item && item.className==className) {
						return item;
					}
				}
				else {
					if (item && item.name==className) {
						return item;
					}
				}
			}
			
			return null;
		}
		
		/**
		 * Get the component by class name
		 * */
		public static function getDynamicComponentType(componentName:Object, fullyQualified:Boolean = false, createInstance:Boolean = false):ComponentDefinition {
			var definition:ComponentDefinition;
			var numberOfDefinitions:uint;
			var item:ComponentDefinition;
			var className:String;
			var hasDefinition:Boolean;
			var classType:Object;
			var displayName:String;
			var name:String;
			
			if (componentName is QName) {
				className = QName(componentName).localName;
			}
			else if (componentName is String) {
				className = componentName as String;
			}
			else if (componentName is Object) {
				className = ClassUtils.getQualifiedClassName(componentName);
				
				if (className=="application" || componentName is Application) {
					className = ClassUtils.getSuperClassName(componentName, true);
				}
			}
			
			fullyQualified = className.indexOf("::")!=-1 ? true : fullyQualified;
			
			if (fullyQualified) {
				className = className.replace("::", ".");
			}
			
			numberOfDefinitions = componentDefinitions.length;
			
			for (var i:uint;i<numberOfDefinitions;i++) {
				item = ComponentDefinition(componentDefinitions.getItemAt(i));
				
				if (fullyQualified) {
					if (item && item.className==className) {
						if (item.classType && createInstance) {
							item.instance = new item.classType();
						}
						return item;
					}
				}
				else {
					if (item && item.name==className) {
						if (item.classType && createInstance) {
							item.instance = new item.classType();
						}
						return item;
					}
				}
			}
			
			
			hasDefinition = ClassUtils.hasDefinition(className);
			
			if (hasDefinition) {
				if (className.indexOf("::")!=-1) {
					name = className.split("::")[1];
				}
				else {
					name = className;
				}
				classType = ClassUtils.getDefinition(className);
				displayName = StringUtils.prettifyCamelCase(name);
				addComponentDefinition(name, displayName, className, classType, null, null, null, null, null, false);
				item = getComponentType(className, fullyQualified);
				
				if (classType && createInstance) {
					item.instance = new classType();
				}
				
				
				return item;
			}
			
			return null;
		}
		
		/**
		 * Removes all components. If components were removed then returns true. 
		 * */
		public static function removeAllComponents():Boolean {
			var numberOfDefinitions:uint = componentDefinitions.length;
			
			if (numberOfDefinitions) {
				componentDefinitions.removeAll();
				return true;
			}
			
			return false;
		}
		
		
		/**
		 * Creates the list of components.
		 * */
		public static function createComponentList(xml:XML):void {
			var numberOfItems:uint;
			var items:XMLList;
			var item:XML;
			var className:String;
			var skinClassName:String;
			var inspectors:Array;
			var hasDefinition:Boolean;
			var classType:Object;
			var includeItem:Boolean;
			var attributes:XMLList;
			var attributesLength:int;
			var childNodes:Array = [];
			var childNodesList:XMLList;
			var childNodesLength:int;
			var defaults:Object;
			var propertyName:String;
			var descendents:XMLList;
			var id:String;
			var displayName:String;
			var defaultProperty:String;
			var metaData:Object;
			
			// get list of component classes 
			items = XML(xml).component;
			
			numberOfItems = items.length();
			
			for (var i:int;i<numberOfItems;i++) {
				item = items[i];
				
				id = String(item.@id);
				displayName = String(item.@name);
				displayName = displayName=="" ? StringUtils.prettifyCamelCase(id) : displayName;
				className = item.attribute("class");
				skinClassName = item.attribute("skinClass");
				//inspectors = item.inspector;
				
				includeItem = item.attribute("include")=="false" ? false : true;
				descendents = item.descendents.property;
				childNodes = [];
				
				
				// check that definitions exist in domain
				// skip any support classes
				if (className.indexOf("mediaClasses")==-1 && 
					className.indexOf("gridClasses")==-1 &&
					className.indexOf("windowClasses")==-1 &&
					className.indexOf("supportClasses")==-1) {
					
					hasDefinition = ClassUtils.hasDefinition(className);
					
					if (hasDefinition) {
						classType = ClassUtils.getDefinition(className);
						metaData = ClassUtils.getMetaDataOfMember(classType, "DefaultProperty");
						defaultProperty = metaData ? metaData.value : null;
						// need to check if we have the skin as well
						
						//hasDefinition = ClassUtils.hasDefinition(skinClassName);
						
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
							
							if (descendents.length()) {
								childNodesList = descendents.attributes();
								childNodesLength = childNodesList.length();
								
								for each (var node:XML in childNodesList) {
									propertyName = String(node);
									childNodes.push(propertyName);
								}
							}
							
							addComponentDefinition(id, displayName, className, classType, inspectors, null, defaultProperty, defaults, null, includeItem, childNodes, false);
						}
						else {
							error("Component skin class, '" + skinClassName + "' not found for '" + className + "'.");
						}
					}
					else {
						error("Component class not found: " + className);
						// we need to add it to Radii8LibraryAssets 
						// such as Radii8LibrarySparkAssets
					}
					
				}
				else {
					// delete support classes
					// may need to refactor why we are including them in the first place
					delete items[i];
					numberOfItems--;
				}
			}
			
			// componentDescriptions should now be populated
		}
		
		
		/**
		 * Creates an instance of the component in the descriptor and sets the 
		 * default properties. We may need to use setActualSize type of methods here or when added. 
		 * 
		 * For instructions on setting default properties or adding new component types
		 * look in Radii8Desktop/howto/HowTo.txt
		 * 
		 * @see #updateComponentAfterAdd()
		 * */
		public static function createComponentToAdd(iDocument:IDocument, componentDefinition:ComponentDefinition, setDefaults:Boolean = true, instance:Object = null):Object {
			var componentDescription:ComponentDescription;
			var classFactory:ClassFactory;
			var componentInstance:Object;
			var properties:Array = [];
			
			if (instance && componentDefinition==null) {
				componentDefinition = getDynamicComponentType(instance);
			}
			
			// Create component to drag
			if (instance==null) {
				classFactory = new ClassFactory(componentDefinition.classType as Class);
			}
			
			/*if (setDefaults) {
			//classFactory.properties = item.defaultProperties;
			//componentDescription.properties = componentDefinition.defaultProperties;
			componentDescription.defaultProperties = componentDefinition.defaultProperties;
			}*/
			
			if (instance) {
				componentInstance = instance;
			}
			else {
				componentInstance = classFactory.newInstance();
			}
			
			componentDescription 			= new ComponentDescription();
			componentDescription.instance 	= componentInstance;
			componentDescription.name 		= componentDefinition.name;
			componentDescription.className 	= componentDefinition.name;
			
			// add default if we need to access defaults later
			componentDescription.defaultProperties = componentDefinition.defaultProperties;
			
			if (setDefaults) {
				
				for (var property:String in componentDefinition.defaultProperties) {
					//setProperty(component, property, [item.defaultProperties[property]]);
					properties.push(property);
				}
				
				// maybe do not add to history
				//setProperties(componentInstance, properties, item.defaultProperties);
				setDefaultProperties(componentDescription);
			}
			
			componentDescription.componentDefinition = componentDefinition;
			
			iDocument.setItemDescription(componentInstance, componentDescription);
			//iDocument.descriptionsDictionary[componentInstance] = componentDescription;
			
			lastCreatedComponent = componentInstance;
			
			return componentInstance;
		}
		
		/**
		 * Gets the size of the target if it is a UIComponent or a DisplayObject.
		 * If it is neither or it does not have a size it returns null.
		 * Also sets the positionRectangle width and height. Temporary fix to bigger problem.
		 * */
		public static function getSize(target:Object, container:Object = null):Rectangle {
			var rectangle:Rectangle;
			
			if (target) {
				
				if (target is UIComponent) {
					rectangle = DisplayObjectUtils.getRectangleBounds(target as UIComponent, container);
					positionRectangle.width = rectangle.width;
					positionRectangle.height = rectangle.height;
					return rectangle;
				}
				else if (target is DisplayObject) {
					positionRectangle.width = rectangle.width;
					positionRectangle.height = rectangle.height;
					rectangle = DisplayObjectUtils.getRealBounds(target as DisplayObject);
					return rectangle;
				}
			}
			
			return null;
		}
		
		/**
		 * Reuse position rectangle. TODO reuse size rectangle
		 * */
		[Bindable]
		public static var positionRectangle:Rectangle = new Rectangle();
		
		/**
		 * Returns the x and y position of the target in a rectangle instance
		 * if it has x and y properties or null if it doesn't have those properties.
		 * */
		public static function getPosition(target:Object):Rectangle {
			//if (target is DisplayObject || target is IBitmapDrawable || target is IVisualElement) {
			
			if (target is Line) {
				positionRectangle.x = Math.min(target.xFrom, target.xTo);
				positionRectangle.y = Math.min(target.yFrom, target.yTo);
				return positionRectangle;
			}
			else if ("x" in target && "y" in target) {
				positionRectangle.x = target.x;
				positionRectangle.y = target.y;
				return positionRectangle;
			}
			else {
				positionRectangle.x = 0;
				positionRectangle.y = 0;
			}
			return null;
		}
		
		/**
		 * Returns the x and y position of the target relative the document.
		 * */
		public static function getPositionPoint(target:Object, centered:Boolean = false, unscaled:Boolean = true):Point {
			var currentScale:Number = 1;
			var point:Point;
			
			if (unscaled) {
				currentScale = ScaleManager.getScale();
			}
			
			point = DisplayObjectUtils.getDistanceBetweenDisplayObjects(target, selectedDocument.instance, false, currentScale);
			
			if (centered) {
				point.setTo(point.x+target.width/2, point.y+target.height/2);
			}
			
			return point;
		}
		
		/**
		 * Locks or unlocks an item. You cannot lock the application at this time. 
		 * 
		 * @returns true if able to set lock on target. 
		 * */
		public static function lockComponent(target:Object, locked:Boolean = true):Boolean {
			var componentDescription:ComponentDescription = selectedDocument ? selectedDocument.getItemDescription(target) : null;
			
			if (componentDescription && !(componentDescription.instance is Application)) {
				componentDescription.locked = locked;
				
				return true;
			}
			return false;
		}
		
		
		/**
		 * Removes x, y, top, bottom, and so on so that component is positioned to container
		 * */
		public static function removeExplicitPositionFromSelection(target:Object):Boolean {
			var sized:Boolean;
			
			if (target) {
				sized = clearProperties(target, MXMLDocumentConstants.POSITION_PROPERTIES, null, "Remove positioning");
			}
			
			return sized;
		}
		
		/**
		 * Removes width and height so that component is sized to content
		 * */
		public static function removeExplicitSizingFromSelection(target:Object):Boolean {
			var sized:Boolean;
			
			if (target) {
				sized = clearProperties(target, MXMLDocumentConstants.SIZE_PROPERTIES, null, "Removed explicit size");
			}
			
			return sized;
		}
		
		/**
		 * Removes explicit width 
		 * */
		public static function removeExplicitWidthFromSelection(target:Object):Boolean {
			var sized:Boolean;
			
			if (target) {
				sized = clearProperties(target, MXMLDocumentConstants.WIDTH_PROPERTIES, null, "Removed width");
			}
			
			return sized;
		}
		
		/**
		 * Removes explicit height
		 * */
		public static function removeExplicitHeightFromSelection(target:Object):Boolean {
			var sized:Boolean;
			
			if (target) {
				sized = clearProperties(target, MXMLDocumentConstants.HEIGHT_PROPERTIES, null, "Removed height");
			}
			
			return sized;
		}
		
		/**
		 * Sizes the current selected target to the document
		 * */
		public static function sizeSelectionToDocument(target:Object = null):Boolean {
			var targetToResize:Object = target ? target : Radiate.target;
			var rectangle:Rectangle;
			var resized:Boolean;
			
			if (targetToResize && selectedDocument) {
				rectangle = getSize(selectedDocument.instance);
				
				if (rectangle.width>0 && rectangle.height>0 && 
					targetToResize.width!=rectangle.width && 
					targetToResize.height!=rectangle.height) {
					setProperties(targetToResize, MXMLDocumentConstants.SIZE_PROPERTIES_NO_PERCENT, rectangle, "Size selection to document");
					resized = true;
				}
			}
			
			return resized;
		}
		
		/**
		 * Duplicates the selected items
		 * TODO There is a duplicate of this function in clipboard manager
		 * */
		public static function duplicateItem(component:Object, destination:Object = null):Array {
			var exportOptions:ExportOptions;
			var sourceData:SourceData;
			var componentDescription:ComponentDescription;
			var newTargets:Array;
			var containerIndex:int = -1;
			
			exportOptions = new ExportOptions();
			exportOptions.useInlineStyles = true;
			exportOptions.exportChildDescriptors = true;
			
			if (selectedDocument) {
				if (component is ComponentDescription) {
					componentDescription = component as ComponentDescription;
				}
				else {
					componentDescription = selectedDocument.getItemDescription(component);
				}
			}
			else {
				warn("Please open a document before attempting to duplicate");
				return null;
			}
			
			// copy selection
			if (componentDescription) {
				sourceData = CodeManager.getSourceData(componentDescription, selectedDocument, CodeManager.MXML, exportOptions);
			}
			else {
				warn("Could not find item to duplicate in the selected document");
				return null;
			}
			
			// get destination
			if (destination && !(destination is IVisualElementContainer)) {
				destination = destination.owner;
			}
			
			// prevent containers from being duplicated into themselves
			if (componentDescription.instance==destination) {
				if (selectedDocument.instance.contains(destination.owner)) {
					destination = destination.owner;
				}
			}
			
			if (!destination) {
				if (componentDescription.parent) {
					destination = componentDescription.parent.instance;
				}
				
				if (!destination) {
					destination = selectedDocument.instance;
				}
			}
			
			// add duplicate
			sourceData = CodeManager.setSourceData(sourceData.source, destination, selectedDocument, CodeManager.MXML, containerIndex, null);
			
			// dispatch added items
			Radiate.dispatchAddEvent(sourceData.targets, null, null);
			
			// select first target
			if (sourceData && sourceData.targets && sourceData.targets.length) { 
				Radiate.setTarget(sourceData.targets[0], true, null, true);
			}
			else {
				Radiate.setTarget(destination);
			}
			
			newTargets = sourceData.targets.slice();
			
			sourceData = null;
			
			return newTargets;
		}
		
		/////////////////////////////////
		//
		// Component 
		// 
		/////////////////////////////////
		
		
		
		/**
		 * Get values object from attributes and child tags on a component from XML node
		 * */
		public static function getPropertiesStylesEventsFromNode(elementInstance:Object, 
																 node:XML, 
																 item:ComponentDefinition = null):ValuesObject {
			var attributeName:String;
			var attributes:Array;
			var childNodeNames:Array;
			var qualifiedChildNodeNames:Array;
			var childNodeNamespaces:Array;
			var propertiesStylesEvents:Array;
			var attributePropertiesStylesEvents:Array;
			var childNodePropertiesStylesEvents:Array;
			var properties:Array;
			var styles:Array;
			var events:Array;
			var childProperties:Array;
			var childStyles:Array;
			var childEvents:Array;
			var attributesValueObject:Object;
			var childNodeValueObject:Object = {};
			var qualifiedChildNodeValueObject:Object = {};
			var defaultPropertyObject:Object;
			var values:Object = {};
			var valuesObject:ValuesObject;
			var failedToImportStyles:Object = {};
			var failedToImportProperties:Object = {};
			var qualifiedAttributes:Array;
			var defaultPropertyMetaData:MetaData;
			var defaultPropertyName:String;
			var styleClient:IStyleClient;
			var errors:Array = [];
			var handledChildNodeNames:Array = [];
			var elementName:String;
			var skipChildNodes:Boolean;
			var simpleContent:Boolean = true;
			var includeQualifiedNames:Boolean = true;
			var ignoreWhitespace:Boolean = true;
			
			styleClient = elementInstance as IStyleClient;
			elementName = node.localName();
			
			
			// Step 1. Get applicable attributes
			
			// get properties from attributes first
			attributes 				= XMLUtils.getAttributeNames(node);
			qualifiedAttributes 	= XMLUtils.getQualifiedAttributeNames(node);
			
			attributePropertiesStylesEvents = attributes.slice();
			
			properties 				= ClassUtils.getObjectsPropertiesFromArray(elementInstance, attributePropertiesStylesEvents, true);
			styles 					= ClassUtils.getObjectsStylesFromArray(elementInstance, attributePropertiesStylesEvents);
			events 					= ClassUtils.getObjectsEventsFromArray(elementInstance, attributePropertiesStylesEvents);
			
			attributePropertiesStylesEvents = properties.concat(styles).concat(events);
			
			// get concrete values from attribute string values
			if (attributePropertiesStylesEvents.length) {
				attributesValueObject 	= XMLUtils.getAttributesValueObject(node);
				attributesValueObject	= ClassUtils.getTypedStyleValueObject(styleClient, attributesValueObject, styles, failedToImportStyles);
				attributesValueObject	= ClassUtils.getTypedPropertyValueObject(elementInstance, attributesValueObject, properties, failedToImportProperties);
				
				values					= attributesValueObject;
			}
			
			
			// Step 2. Get applicable child nodes
			
			// next get properties from child nodes 
			childNodeNames 			= XMLUtils.getChildNodeNames(node);
			childNodeNamespaces		= XMLUtils.getChildNodeNamesNamespace(node, true);
			qualifiedChildNodeNames	= XMLUtils.getQualifiedChildNodeNames(node);
			
			childProperties 		= ClassUtils.getObjectsPropertiesFromArray(elementInstance, childNodeNames, true);
			childStyles 			= ClassUtils.getObjectsStylesFromArray(elementInstance, childNodeNames);
			childEvents 			= ClassUtils.getObjectsEventsFromArray(elementInstance, childNodeNames);
			
			childNodePropertiesStylesEvents = childProperties.concat(childStyles).concat(childEvents);
			
			if (childNodePropertiesStylesEvents.length) {
				childNodeValueObject 	= XMLUtils.getChildNodesValueObject(node, includeQualifiedNames, simpleContent, false);
				qualifiedChildNodeValueObject 	= XMLUtils.getChildNodesValueObject(node, includeQualifiedNames, !simpleContent, false);
				
				// get concrete values from child node string values
				childNodeValueObject	= ClassUtils.getTypedStyleValueObject(styleClient, childNodeValueObject, childStyles, failedToImportStyles);
				childNodeValueObject	= ClassUtils.getTypedPropertyValueObject(elementInstance, childNodeValueObject, childProperties, failedToImportProperties);
				//childNodeValueObject	= ClassUtils.getTypedEventValueObject(elementInstance, childNodeValueObject, childProperties, failedToImportProperties);
				
				values 					= ObjectUtils.merge(values, childNodeValueObject);
			}
			
			
			// Step 3. Get default property from child nodes
			
			// get default property if one is set
			defaultPropertyMetaData = ClassUtils.getMetaDataOfMetaData(elementInstance, MXMLDocumentConstants.DEFAULT_PROPERTY);
			
			defaultPropertyMetaData = null;
			if (defaultPropertyMetaData!=null) {
				defaultPropertyName = defaultPropertyMetaData.value;
				defaultPropertyObject 	= XMLUtils.getDefaultPropertyValueObject(elementInstance, node, defaultPropertyName, includeQualifiedNames, ignoreWhitespace, [MXMLDocumentConstants.MXML_CONTENT_FACTORY, MXMLDocumentConstants.MXML_CONTENT]);
				
				if (defaultPropertyObject is Error) {
					errors.push(defaultPropertyObject);
				}
				else if (!ClassUtils.isEmptyObject(defaultPropertyObject)) {
					
					// get concrete values from default property string values
					defaultPropertyObject	= ClassUtils.getTypedPropertyValueObject(elementInstance, defaultPropertyObject, [defaultPropertyName], failedToImportProperties);
					
					if (childProperties.indexOf(defaultPropertyName)==-1) {
						childProperties.push(defaultPropertyName);
					}
					
					if (childNodePropertiesStylesEvents.indexOf(defaultPropertyName)==-1) {
						childNodePropertiesStylesEvents.push(defaultPropertyName);
					}
					
					childNodeValueObject = ObjectUtils.merge(childNodeValueObject, defaultPropertyObject);
					
					childNodeNames.push(defaultPropertyMetaData.value);
					
					values = ObjectUtils.merge(values, defaultPropertyObject);
					
					skipChildNodes = true;
				}
			}
			
			propertiesStylesEvents = attributePropertiesStylesEvents.concat(childNodePropertiesStylesEvents);
			
			for (var property:String in values) {
				if (childNodeNames.indexOf(property)!=-1) {
					if (childNodePropertiesStylesEvents.indexOf(property)!=-1) {
						handledChildNodeNames.push(property);
					}
				}
			}
			
			valuesObject 							= new ValuesObject();
			valuesObject.values 					= values;
			
			valuesObject.styles 					= styles;
			valuesObject.properties 				= properties;
			valuesObject.events		 				= events;
			valuesObject.attributes 				= attributes;
			valuesObject.qualifiedAttributes		= qualifiedAttributes;
			
			valuesObject.childStyles	 			= childStyles;
			valuesObject.childProperties 			= childProperties;
			valuesObject.childEvents		 		= childEvents;
			valuesObject.childNodeNames 			= childNodeNames;
			valuesObject.qualifiedChildNodeNames 	= qualifiedChildNodeNames;
			valuesObject.childNodeValues 			= childNodeValueObject;
			valuesObject.qualifiedChildNodeValues 	= qualifiedChildNodeValueObject;
			
			valuesObject.defaultPropertyObject		= defaultPropertyObject;
			
			valuesObject.errors						= errors;
			valuesObject.stylesErrorsObject 		= failedToImportStyles;
			valuesObject.propertiesErrorsObject 	= failedToImportProperties;
			
			valuesObject.attributesNotFound			= ArrayUtils.removeAllItems(attributes, attributePropertiesStylesEvents);
			valuesObject.childNodesNotFound			= ArrayUtils.removeAllItems(childNodeNames, childNodePropertiesStylesEvents);
			
			valuesObject.attributePropertiesStylesEvents	= attributePropertiesStylesEvents;
			valuesObject.childNodePropertiesStylesEvents	= childNodePropertiesStylesEvents;
			valuesObject.propertiesStylesEvents				= propertiesStylesEvents;
			
			valuesObject.handledChildNodeNames				= handledChildNodeNames;
			valuesObject.skipChildNodes						= skipChildNodes;
			
			//valuesObject.nonNsAttributesNotFound	= ArrayUtils.removeAllItems(qualifiedAttributes, valuesObject.propertiesStylesEvents);
			
			/*
			var a:Object = node.namespace().prefix;     //returns prefix i.e. rdf
			var b:Object = node.namespace().uri;        //returns uri of prefix i.e. http://www.w3.org/1999/02/22-rdf-syntax-ns#
			
			var c:Object = node.inScopeNamespaces();   //returns all inscope namespace as an associative array like above
			
			//returns all nodes in an xml doc that use the namespace
			var nsElement:Namespace = new Namespace(node.namespace().prefix, node.namespace().uri);
			
			var usageCount:XMLList = node..nsElement::*;*/
			
			return valuesObject;
		}
		
		/**
		 * Get value object on a component from a properties object
		 * */
		public static function getPropertiesStylesFromObject(elementInstance:Object, dataObject:Object, item:ComponentDefinition = null):ValuesObject {
			var properties:Array;
			var styles:Array;
			var aValueObject:Object;
			var childNodeValueObject:Object;
			var valuesObject:ValuesObject;
			var values:Object = {};
			var failedToImportStyles:Object = {};
			var failedToImportProperties:Object = {};
			
			properties 				= ClassUtils.getPropertiesFromObject(elementInstance, dataObject, true);
			styles 					= ClassUtils.getStylesFromObject(elementInstance, dataObject);
			
			values					= ClassUtils.getTypedPropertyValueObject(elementInstance, dataObject, properties, failedToImportProperties);
			values					= ClassUtils.getTypedStyleValueObject(elementInstance as IStyleClient, dataObject, styles, failedToImportStyles);
			
			
			valuesObject 						= new ValuesObject();
			valuesObject.values 				= values;
			valuesObject.styles 				= styles;
			valuesObject.properties 			= properties;
			valuesObject.stylesErrorsObject 	= failedToImportStyles;
			valuesObject.propertiesErrorsObject = failedToImportProperties;
			valuesObject.propertiesStylesEvents	= properties.concat(styles);
			
			
			return valuesObject;
		}
		
		/**
		 * Removes explict size on a component object because 
		 * we are setting default width and height when creating the component.
		 * I don't know a better way to do this. Maybe use setActualSize but I 
		 * don't think the size stays if you go back and forth in history???
		 * */
		public static function removeExplictSizeOnComponent(elementInstance:Object, node:XML, item:ComponentDefinition = null, dispatchEvents:Boolean = false):void {
			var attributeName:String;
			var elementName:String = node.localName();
			
			var hasWidthAttribute:Boolean = ("@width" in node);
			var hasHeightAttribute:Boolean = ("@height" in node);
			var hasWidthDefault:Boolean = item.defaultProperties && item.defaultProperties.width;
			var hasHeightDefault:Boolean = item.defaultProperties && item.defaultProperties.height;
			
			
			// a default height was set but the user removed it so we need to remove it
			// flex doesn't support a height="auto" or height="content" type of value 
			// flex just removes the height attribute in XML altogether 
			// so if it is not in the mxml then we have to set the size to undefined 
			if (hasHeightDefault && !hasHeightAttribute) {
				//setProperty(elementInstance, "height", undefined, null, true, dispatchEvents);
				elementInstance["height"] = undefined;
			}
			
			if (hasWidthDefault && !hasWidthAttribute) {
				//setProperty(elementInstance, "width", undefined, null, true, dispatchEvents);
				elementInstance["width"] = undefined;
			}
		}
		
		/**
		 * Set attributes on a component object
		 * */
		public static function setAttributesOnComponent(elementInstance:Object, node:XML, item:ComponentDefinition = null, dispatchEvents:Boolean = false):void {
			var attributeName:String;
			var elementName:String = node.localName();
			//var domain:ApplicationDomain = ApplicationDomain.currentDomain;
			//var componentDefinition:ComponentDefinition = Radiate.getComponentType(elementName);
			//var className:String =componentDefinition ? componentDefinition.className :null;
			//var classType:Class = componentDefinition ? componentDefinition.classType as Class :null;
			//var elementInstance:Object = componentDescription.instance;
			
			var properties:Array = [];
			var styles:Array = [];
			var valueObject:Object = {};
			
			for each (var attribute:XML in node.attributes()) {
				attributeName = attribute.name().toString();
				//Radiate.info(" found attribute: " + attributeName); 
				
				
				// TODO we should check if an attribute is an property, style or event using the component definition
				// We can do it this way now since we are only working with styles and properties
				
				
				// check if property 
				if (attributeName in elementInstance) {
					
					//Radiate.info(" setting property: " + attributeName);
					//setProperty(elementInstance, attributeName, attribute.toString(), null, false, dispatchEvents);
					properties.push(attributeName);
					valueObject[attributeName] = attribute.toString();
				}
					
					// could be style or event
				else {
					if (elementInstance is IStyleClient) {
						//Radiate.info(" setting style: " + attributeName);
						//setStyle(elementInstance, attributeName, attribute.toString(), null, false, dispatchEvents);
						styles.push(attributeName);
						valueObject[attributeName] = attribute.toString();
					}
				}
			}
			
			if (styles.length || properties.length) {
				var propertiesStyles:Array = styles.concat(properties);
				setPropertiesStylesEvents(elementInstance, propertiesStyles, valueObject);
			}
			
			
			removeExplictSizeOnComponent(elementInstance, node, item);
		}
		
		/**
		 * Returns true if the style was cleared.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>ComponentManager.clearStyle(myButton, "fontFamily");</pre>
		 * */
		public static function clearStyle(target:Object, style:String, description:String = null, dispatchEvents:Boolean = true):Boolean {
			
			return setStyle(target, style, undefined, description, true, dispatchEvents);
		}
		
		/**
		 * Clears the styles of the target.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>ComponentManager.clearStyles(myButton, ["fontFamily", "fontWeight"]);</pre>
		 * */
		public static function clearStyles(target:Object, styles:Array, description:String = null, dispatchEvents:Boolean = true):Boolean {
			var object:Object = {};
			var numberOfStyles:uint = styles.length;
			
			for (var i:int;i<numberOfStyles;i++) {
				object[styles[i]] = undefined;
			}
			
			return setStyles(target, styles, object, description, true, dispatchEvents);
		}
		
		/**
		 * Returns true if the property was cleared.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>ComponentManager.clearProperty(myButton, "width");</pre>
		 * */
		public static function clearProperty(target:Object, property:String, defaultValue:* = undefined, description:String = null, dispatchEvents:Boolean = true):Boolean {
			var successful:Boolean;
			
			if (description==null) {
				description = "Reset " + property;
			}
			
			if (defaultValue!==undefined && defaultValue!==null) {
				removeComponentProperties([target], [property]);
				successful = setProperty(target, property, defaultValue, description, true, dispatchEvents);
				// undefined values automatically get removed but nonundefined do not so we remove them manually 
			}
			else {
				successful = setProperty(target, property, undefined, description, true, dispatchEvents);
			}
			
			return successful;
		}
		
		/**
		 * Returns true if the property was cleared.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>ComponentManager.clearProperties(myButton, ["width", "percentWidth"]);</pre>
		 * */
		public static function clearProperties(target:Object, properties:Array, defaultValue:* = undefined, description:String = null, dispatchEvents:Boolean = true):Boolean {
			var propertiesObject:Object = {};
			var numberOfProperties:uint = properties.length;
			var successful:Boolean;
			
			if (description==null) {
				description = "Reset " + properties;
			}
			
			for (var i:int;i<numberOfProperties;i++) {
				if (defaultValue!==undefined && defaultValue!==null) {
					propertiesObject[properties[i]] = defaultValue;
				}
				else {
					propertiesObject[properties[i]] = undefined;
				}
			}
			
			if (defaultValue!==undefined && defaultValue!==null) {
				removeComponentProperties([target], properties);
				successful = setProperties(target, properties, propertiesObject, description, true, dispatchEvents);
			}
			else {
				successful = setProperties(target, properties, propertiesObject, description, true, dispatchEvents);
			}
			
			return successful;
		}
		
		/**
		 * Returns true if the property was changed. Use setProperties for 
		 * setting multiple properties.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>ComponentManager.setProperty(myButton, "x", 40);</pre>
		 * <pre>ComponentManager.setProperty([myButton,myButton2], "x", 40);</pre>
		 * */
		public static function setStyle(target:Object, style:String, value:*, description:String = null, removeUnchangedValues:Boolean = false, dispatchEvents:Boolean = true):Boolean {
			var targets:Array = ArrayUtil.toArray(target);
			var styleChanges:Array;
			var historyEvents:Array;
			
			styleChanges = createPropertyChange(targets, null, style, null, value, description);
			
			
			if (!removeUnchangedValues) {
				styleChanges = stripUnchangedValues(styleChanges);
			}
			
			if (changesAvailable(styleChanges)) {
				applyChanges(targets, styleChanges, null, style, null);
				//LayoutManager.getInstance().validateNow(); // applyChanges calls this
				
				historyEvents = HistoryManager.createHistoryEventItems(targets, styleChanges, null, style, null, value, description);
				
				updateComponentStyles(targets, styleChanges, [style]);
				
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.addHistoryEvents(selectedDocument, historyEvents, description);
				}
				
				if (dispatchEvents) {
					Radiate.dispatchPropertyChangeEvent(targets, styleChanges, null, ArrayUtil.toArray(style), null);
				}
				return true;
			}
			
			return false;
		}
		
		/**
		 * Checks if changes are available. 
		 * */
		public static function changesAvailable(changes:Array):Boolean {
			var numberOfChanges:int = changes.length;
			var changesAvailable:Boolean;
			var item:PropertyChanges;
			var name:String;
			
			for (var i:int;i<numberOfChanges;i++) {
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
		
		/**
		 * Restores captured values in changes array.
		 * Some values are removed by this call so may need to change this. 
		 * */
		public static function restoreCapturedValues(changes:Array, property:Array, style:Array = null, event:Array = null, validateLayout:Boolean = true, stripUnchanged:Boolean = true):Boolean {
			var numberOfChanges:int = changes ? changes.length : 0;
			var effect:HistoryEffect = new HistoryEffect();
			var onlyPropertyChanges:Array = [];
			var directApply:Boolean = true;
			var change:PropertyChanges;
			var targets:Array = [];
			
			for (var i:int;i<numberOfChanges;i++) {
				change = changes[i] as PropertyChanges;
				
				if (change) { 
					onlyPropertyChanges.push(change);
					
					if (targets.indexOf(change.target)==-1) {
						targets.push(change.target);
					}
				}
			}
			
			onlyPropertyChanges = captureSizingPropertyValues(targets, ArrayUtil.toArray(property), false, onlyPropertyChanges);
			onlyPropertyChanges = stripUnchanged ? stripUnchangedValues(onlyPropertyChanges) : onlyPropertyChanges;
			
			effect.targets = targets;
			effect.propertyChangesArray = onlyPropertyChanges;
			
			effect.relevantEvents = ArrayUtil.toArray(event);
			effect.relevantProperties = ArrayUtil.toArray(property);
			effect.relevantStyles = ArrayUtil.toArray(style);
			
			// this works for styles and properties
			// note: the property applyActualDimensions is used to enable width and height values to stick
			if (directApply) {
				effect.applyEndValuesWhenDone = false;
				effect.applyActualDimensions = false;
				
				//if (setStartValues) {
				effect.applyStartValues(onlyPropertyChanges, targets);
				//}
				//else {
				//	effect.applyEndValues(onlyPropertyChanges, targets);
				//}
				
				// Revalidate after applying
				if (validateLayout) {
					LayoutManager.getInstance().validateNow();
				}
			}
			
			return true;
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
		 * @param style string or array of strings containing the 
		 * names of the styles to set or null if setting properties
		 * 
		 * @param event string or array of strings containing the 
		 * names of the events to set
		 * */
		public static function applyChanges(targets:Array, changes:Array, property:*, style:*, event:*, setStartValues:Boolean=false, validateLayout:Boolean = false):Boolean {
			var numberOfChanges:int = changes ? changes.length : 0;
			var effect:HistoryEffect = new HistoryEffect();
			var onlyPropertyChanges:Array = [];
			var directApply:Boolean = true;
			// note: i think the Animation effect has an example of using this that verify we are doing it right - nov 27,16
			for (var i:int;i<numberOfChanges;i++) {
				if (changes[i] is PropertyChanges) { 
					onlyPropertyChanges.push(changes[i]);
				}
			}
			
			effect.targets = targets;
			effect.propertyChangesArray = onlyPropertyChanges;
			
			
			effect.relevantEvents = ArrayUtil.toArray(event);
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
				if (validateLayout) {
					LayoutManager.getInstance().validateNow();
				}
			}
				
				// this works for properties but not styles
				// the style value is restored at the end 
				// update: are you sure?
			else {
				
				effect.applyEndValuesWhenDone = false;
				effect.play(targets, setStartValues);
				effect.playReversed = false;
				effect.end();
				
				if (validateLayout) {
					LayoutManager.getInstance().validateNow();
				}
			}
			
			return true;
		}
		
		/**
		 * Returns true if the property was changed. Use setProperties for 
		 * setting multiple properties.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>ComponentManager.setProperty(myButton, "x", 40);</pre>
		 * <pre>ComponentManager.setProperty([myButton,myButton2], "x", 40);</pre>
		 * */
		public static function setProperty(target:Object, property:String, value:*, description:String = null, keepUndefinedValues:Boolean = false, dispatchEvents:Boolean = true):Boolean {
			var targets:Array = ArrayUtil.toArray(target);
			var propertyChanges:Array;
			var historyEventItems:Array;
			
			propertyChanges = createPropertyChange(targets, property, null, null, value, description);
			
			
			if (!keepUndefinedValues) {
				propertyChanges = stripUnchangedValues(propertyChanges);
			}
			
			if (changesAvailable(propertyChanges)) {
				applyChanges(targets, propertyChanges, property, null, null);
				//LayoutManager.getInstance().validateNow(); // applyChanges calls this
				//addHistoryItem(propertyChanges, description);
				
				updateComponentProperties(targets, propertyChanges, [property]);
				
				historyEventItems = HistoryManager.createHistoryEventItems(targets, propertyChanges, property, null, null, value, description);
				
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.addHistoryEvents(selectedDocument, historyEventItems, description, false, dispatchEvents);
				}
				
				
				if (dispatchEvents) {
					Radiate.dispatchPropertyChangeEvent(target, propertyChanges, ArrayUtil.toArray(property), null, null);
				}
				
				if (dispatchEvents) {
					if (targets.indexOf(selectedDocument.instance)!=-1 && ArrayUtils.containsAny(notableApplicationProperties, [property])) {
						Radiate.dispatchDocumentSizeChangeEvent(target);
					}
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
		public static function setProperties(target:Object, properties:Array, value:*, description:String = null, removeUnchangedValues:Boolean = false, dispatchEvents:Boolean = true):Boolean {
			var propertyChanges:Array;
			var historyEvents:Array;
			var targets:Array;
			
			targets = ArrayUtil.toArray(target);
			properties = ArrayUtil.toArray(properties);
			propertyChanges = createPropertyChanges(targets, properties, null, null, value, description, false);
			
			if (!removeUnchangedValues) {
				propertyChanges = stripUnchangedValues(propertyChanges);
			}
			
			if (changesAvailable(propertyChanges)) {
				applyChanges(targets, propertyChanges, properties, null, null);
				//LayoutManager.getInstance().validateNow();
				//addHistoryItem(propertyChanges);
				
				historyEvents = HistoryManager.createHistoryEventItems(targets, propertyChanges, properties, null, null, value, description);
				
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.addHistoryEvents(selectedDocument, historyEvents, description);
				}
				
				updateComponentProperties(targets, propertyChanges, properties);
				
				if (dispatchEvents) {
					Radiate.dispatchPropertyChangeEvent(targets, propertyChanges, properties, null, null);
				}
				
				if (targets.indexOf(selectedDocument)!=-1 && ArrayUtils.containsAny(notableApplicationProperties, properties)) {
					Radiate.dispatchDocumentSizeChangeEvent(targets);
				}
				
				return true;
			}
			
			return false;
		}
		
		/**
		 * Sets the style on the target object.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>setStyles([myButton,myButton2], ["fontSize","fontFamily"], {fontSize:20,fontFamily:"Arial"});</pre>
		 * <pre>setStyles(button, ["fontSize", "fontFamily"], {fontSize:10,fontFamily:"Arial"});</pre>
		 * 
		 * @see setStyle()
		 * @see setProperty()
		 * @see setProperties()
		 * */
		public static function setStyles(target:Object, styles:Array, value:*, description:String = null, removeUnchangedValues:Boolean = false, dispatchEvents:Boolean = true):Boolean {
			var stylesChanges:Array;
			var historyEvents:Array;
			var targets:Array;
			
			targets = ArrayUtil.toArray(target);
			styles = ArrayUtil.toArray(styles);
			stylesChanges = createPropertyChanges(targets, null, styles, null, value, description, false);
			
			if (!removeUnchangedValues) {
				stylesChanges = stripUnchangedValues(stylesChanges);
			}
			
			if (changesAvailable(stylesChanges)) {
				applyChanges(targets, stylesChanges, null, styles, null);
				//LayoutManager.getInstance().validateNow();
				
				historyEvents = HistoryManager.createHistoryEventItems(targets, stylesChanges, null, styles, null, value, description);
				
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.addHistoryEvents(selectedDocument, historyEvents, description);
				}
				
				updateComponentStyles(targets, stylesChanges, styles);
				
				if (dispatchEvents) {
					Radiate.dispatchPropertyChangeEvent(targets, stylesChanges, null, styles, null);
				}
				
				return true;
			}
			
			return false;
		}
		
		/**
		 * Sets the properties or styles of target or targets. Returns true if the properties or styles were changed.<br/><br/>
		 * 
		 * Usage:<br/>
		 <pre>
		 setPropertiesStyles([myButton,myButton2], ["x","y","color"], {x:40,y:50,color:"0xFF0000"});
		 setPropertiesStyles(myButton, "x", 40);
		 setPropertiesStyles(button, ["x", "left"], {x:50,left:undefined});
		 </pre>
		 * 
		 * @see setStyle()
		 * @see setStyles()
		 * @see setProperty()
		 * @see setProperties()
		 * */
		public static function setPropertiesStylesEvents(target:Object, propertiesStylesEvents:Array, value:*, description:String = null, removeUnchangedValues:Boolean = false, dispatchEvents:Boolean = true):Boolean {
			var propertyChanges:Array;
			var historyEvents:Array;
			var targets:Array;
			var properties:Array;
			var styles:Array;
			var events:Array;
			
			targets = ArrayUtil.toArray(target);
			propertiesStylesEvents = ArrayUtil.toArray(propertiesStylesEvents);
			
			// TODO: Add support for multiple targets
			styles = ClassUtils.getObjectsStylesFromArray(target, propertiesStylesEvents);
			properties = ClassUtils.getObjectsPropertiesFromArray(target, propertiesStylesEvents, true);
			events = ClassUtils.getObjectsEventsFromArray(target, propertiesStylesEvents);
			
			propertyChanges = createPropertyChanges(targets, properties, styles, events, value, description, false);
			
			if (!removeUnchangedValues) {
				propertyChanges = stripUnchangedValues(propertyChanges);
			}
			
			if (changesAvailable(propertyChanges)) {
				applyChanges(targets, propertyChanges, properties, styles, events);
				//LayoutManager.getInstance().validateNow();
				//addHistoryItem(propertyChanges);
				
				
				if (!HistoryManager.doNotAddEventsToHistory) {
					historyEvents = HistoryManager.createHistoryEventItems(targets, propertyChanges, properties, styles, events, value, description);
					HistoryManager.addHistoryEvents(selectedDocument, historyEvents, description, false, dispatchEvents);
				}
				
				updateComponentProperties(targets, propertyChanges, properties);
				updateComponentStyles(targets, propertyChanges, styles);
				updateComponentEvents(targets, propertyChanges, events);
				
				if (dispatchEvents) {
					Radiate.dispatchPropertyChangeEvent(targets, propertyChanges, properties, styles, events);
				}
				
				if (targets.indexOf(selectedDocument)!=-1 && ArrayUtils.containsAny(notableApplicationProperties, propertiesStylesEvents)) {
					Radiate.dispatchDocumentSizeChangeEvent(targets);
				}
				
				return true;
			}
			
			return false;
		}
		
		/**
		 * Capture property values. Use to save the current values of the properties, styles or events of an object.
		 * */
		public static function capturePropertyValues(targets:Array, properties:Array, styles:Array = null, events:Array = null):Array {
			var tempEffect:HistoryEffect = new HistoryEffect();
			var propertyChanges:PropertyChanges;
			var changes:Array;
			var propertStyleEvent:String;
			
			tempEffect.targets = targets;
			tempEffect.relevantEvents = events;
			tempEffect.relevantProperties = properties;
			tempEffect.relevantStyles = styles;
			
			// get start values for undo
			changes = tempEffect.captureValues(null, true);
			
			return changes;
		}
		
		/**
		 * Capture sizing property values. Skips height and width unless explicitly set. 
		 * */
		public static function captureSizingPropertyValues(targets:Array, properties:Array = null, startValues:Boolean = true, previousChanges:Array = null):Array {
			var propertyChanges:PropertyChanges;
			var previousChange:PropertyChanges;
			var change:PropertyChanges;
			var effect:HistoryEffect;
			var changes:Array;
			
			if (properties==null) {
				properties = MXMLDocumentConstants.EXPLICIT_SIZE_AND_POSITION_PROPERTIES_ROTATION.slice();
			}
			
			effect = new HistoryEffect();
			effect.targets = targets;
			effect.relevantProperties = properties;
			
			// get start values for undo
			changes = effect.captureValues(null, startValues);
			
			if (startValues) {
				for each (change in changes) {
					
					// if explicit size is not set then do not use size value
					if (change.start[MXMLDocumentConstants.EXPLICIT_WIDTH]===undefined) {
						change.start[MXMLDocumentConstants.WIDTH] = undefined;
					}
					
					if (change.start[MXMLDocumentConstants.EXPLICIT_HEIGHT]===undefined) {
						change.start[MXMLDocumentConstants.HEIGHT] = undefined;
					}
					
					// if the percent is set then to do not use size value
					if (!isNaN(change.start[MXMLDocumentConstants.PERCENT_WIDTH])) {
						change.start[MXMLDocumentConstants.WIDTH] = undefined;
					}
					
					if (!isNaN(change.start[MXMLDocumentConstants.PERCENT_HEIGHT])) {
						change.start[MXMLDocumentConstants.HEIGHT] = undefined;
					}
					
					change.start[MXMLDocumentConstants.EXPLICIT_WIDTH] = undefined;
					change.start[MXMLDocumentConstants.EXPLICIT_HEIGHT] = undefined;
				}
			}
			else if (previousChanges) {
				// if we pass in another change group and we are not start values
				// we are getting end values and so we match the targets and then 
				// return the previous changes array
				for each (previousChange in previousChanges) {
					for each (change in changes) {
						if (change.target==previousChange.target) {
							previousChange.end = change.end;
							//previousChange.start = change.start;
						}
					}
				}
				
				return previousChanges;
			}
			
			return changes;
		}
		
		/**
		 * Given a target or targets, properties and value object (name value pair)
		 * returns an array of PropertyChange objects.
		 * Value must be an object containing the properties mentioned in the properties array
		 * */
		public static function getPropertiesObjectFromBounds(element:Object, model:Object, roundToWhole:Boolean = true):Object {
			var leftValue:Object;
			var rightValue:Object;
			var topValue:Object;
			var bottomValue:Object;
			var horizontalCenter:Object;
			var verticalCenter:Object;
			var properties:Array;
			var propertiesObject:Object;
			var verticalDifference:int;
			var horizontalDifference:int;
			var widthDifference:Number;
			var heightDifference:Number;
			var width:Number;
			var height:Number;
			var elementX:Number;
			var elementY:Number;
			var changes:Array;
			var movedDown:Boolean;
			var movedLeft:Boolean;
			var movedRight:Boolean;
			var movedUp:Boolean;
			
			changes = [];
			properties = [];
			propertiesObject = {};
			
			width = model.width;
			height = model.height;
			
			elementX = element.x;
			elementY = element.y;
			
			if (model.y>elementY) {
				movedDown = true;
			}
			else if (model.y<elementY) {
				movedUp = true;
			}
			
			if (model.x>elementX) {
				movedRight = true;
			}
			else if (model.x<elementX) {
				movedLeft = true;
			}
			
			// get size
			propertiesObject.width = width;
			propertiesObject.height = height;
			properties.push(MXMLDocumentConstants.WIDTH, MXMLDocumentConstants.HEIGHT);
			
			// get vertical changes
			if (movedUp) {
				verticalDifference = (elementY - model.y);
				
				topValue = element.top;
				bottomValue = element.bottom;
				verticalCenter = element.verticalCenter;
				
				if (topValue!=null && bottomValue!=null) {
					propertiesObject.top = Number(element.top) - verticalDifference;
					propertiesObject.bottom = Number(element.bottom) + verticalDifference;
					properties.push(MXMLDocumentConstants.TOP, MXMLDocumentConstants.BOTTOM);
				}
				else if (topValue!=null) {
					propertiesObject.top = Number(element.top) - verticalDifference;
					properties.push(MXMLDocumentConstants.TOP);
				}
				else if (bottomValue!=null) {
					propertiesObject.bottom = Number(element.bottom) + verticalDifference;
					properties.push(MXMLDocumentConstants.BOTTOM);
				}
				else if (verticalCenter!=null) {
					propertiesObject.verticalCenter = Number(element.verticalCenter) - verticalDifference;
					properties.push(MXMLDocumentConstants.VERTICAL_CENTER);
				}
				else {
					propertiesObject.y = element.y - verticalDifference;
					properties.push(MXMLDocumentConstants.Y);
				}
			}
			else if (movedDown) {
				verticalDifference = (model.y - elementY);
				
				topValue = element.top;
				bottomValue = element.bottom;
				verticalCenter = element.verticalCenter;
				
				if (topValue!=null && bottomValue!=null) {
					propertiesObject.top = Number(element.top) + verticalDifference;
					propertiesObject.bottom = Number(element.bottom) - verticalDifference;
					properties.push(MXMLDocumentConstants.TOP, MXMLDocumentConstants.BOTTOM);
				}
				else if (leftValue!=null) {
					propertiesObject.top = Number(element.top) + verticalDifference;
					properties.push(MXMLDocumentConstants.TOP);
				}
				else if (bottomValue!=null) {
					propertiesObject.bottom = Number(element.bottom) - verticalDifference;
					properties.push(MXMLDocumentConstants.BOTTOM);
				}
				else if (verticalCenter!=null) {
					propertiesObject.verticalCenter = Number(element.verticalCenter) + verticalDifference;
					properties.push(MXMLDocumentConstants.VERTICAL_CENTER);
				}
				else {
					propertiesObject.y = element.y + verticalDifference;
					properties.push(MXMLDocumentConstants.Y);
				}
			}
			
			// get horizontal changes
			if (movedLeft) {
				horizontalDifference = (elementX - model.x);
				
				/**
				 * If left is set then set x to nothing
				 * If left and right are set then set width to nothing
				 * If horizontalCenter is set than set left and right to nothing
				 * Otherwise set left to nothing
				 * */
				if (leftValue!=null && rightValue!=null) {
					propertiesObject.left = Number(element.left) - horizontalDifference;
					propertiesObject.right = Number(element.right) + horizontalDifference;
					properties.push(MXMLDocumentConstants.LEFT, MXMLDocumentConstants.RIGHT);
				}
				else if (leftValue!=null) {
					propertiesObject.left = Number(element.left) - horizontalDifference;
					properties.push(MXMLDocumentConstants.LEFT);
				}
				else if (rightValue!=null) {
					propertiesObject.right = Number(element.right) + horizontalDifference;
					properties.push(MXMLDocumentConstants.RIGHT);
				}
				else if (horizontalCenter!=null) {
					propertiesObject.horizontalCenter = Number(element.horizontalCenter) - horizontalDifference;
					properties.push(MXMLDocumentConstants.HORIZONTAL_CENTER);
				}
				else {
					propertiesObject.x = element.x - horizontalDifference;
					properties.push(MXMLDocumentConstants.X);
				}
			}
			else if (movedRight) {
				horizontalDifference = (model.x - elementX);
				
				leftValue = element.left;
				rightValue = element.right;
				horizontalCenter = element.horizontalCenter;
				
				if (leftValue!=null && rightValue!=null) {
					propertiesObject.left = Number(element.left) + horizontalDifference;
					propertiesObject.right = Number(element.right) - horizontalDifference;
					properties.push(MXMLDocumentConstants.LEFT, MXMLDocumentConstants.RIGHT);
				}
				else if (leftValue!=null) {
					propertiesObject.left = Number(element.left) + horizontalDifference;
					properties.push(MXMLDocumentConstants.LEFT);
				}
				else if (rightValue!=null) {
					propertiesObject.right = Number(element.right) - horizontalDifference;
					properties.push(MXMLDocumentConstants.RIGHT);
				}
				else if (horizontalCenter!=null) {
					propertiesObject.horizontalCenter = Number(element.horizontalCenter) + horizontalDifference;
					properties.push(MXMLDocumentConstants.HORIZONTAL_CENTER);
				}
				else {
					propertiesObject.x = element.x + horizontalDifference;
					properties.push(MXMLDocumentConstants.X);
				}
			}
			
			if (roundToWhole) {
				for (var i:int = 0; i < properties.length; i++)  {
					propertiesObject[properties[i]] = Math.ceil(propertiesObject[properties[i]]);
				}
				
			}
			
			return propertiesObject;
		}
		
		/**
		 * Given a target or targets, properties and value object (name value pair)
		 * returns an array of PropertyChange objects.
		 * Value must be an object containing the properties mentioned in the properties array
		 * */
		public static function createPropertyChanges(targets:Array, properties:Array, styles:Array, events:Array, value:Object, description:String = "", storeInHistory:Boolean = true):Array {
			var tempEffect:HistoryEffect = new HistoryEffect();
			var propertyChanges:PropertyChanges;
			var changes:Array;
			var propertStyleEvent:String;
			
			tempEffect.targets = targets;
			tempEffect.relevantEvents = events;
			tempEffect.relevantProperties = properties;
			tempEffect.relevantStyles = styles;
			
			// get start values for undo
			changes = tempEffect.captureValues(null, true);
			
			// This may be hanging on to bindable objects
			// set the values to be set to the property 
			// ..later - what??? give an example
			for each (propertyChanges in changes) {
				
				// for properties 
				for each (propertStyleEvent in properties) {
					
					// value may be an object with properties or a string
					// because we accept an object containing the values with 
					// the name of the properties or styles
					if (value && propertStyleEvent in value) {
						propertyChanges.end[propertStyleEvent] = value[propertStyleEvent];
					}
					else {
						// BUG - this will assign the value object if property is not found in the value object - fix
						propertyChanges.end[propertStyleEvent] = value;
					}
				}
				
				// for styles
				for each (propertStyleEvent in styles) {
					
					// value may be an object with properties or a string
					// because we accept an object containing the values with 
					// the name of the properties or styles
					if (value && propertStyleEvent in value) {
						propertyChanges.end[propertStyleEvent] = value[propertStyleEvent];
					}
					else {
						propertyChanges.end[propertStyleEvent] = value;
					}
				}
				
				// for event
				for each (propertStyleEvent in events) {
					
					// value may be an object with properties or a string
					// because we accept an object containing the values with 
					// the name of the properties or styles
					if (value && propertStyleEvent in value) {
						propertyChanges.end[propertStyleEvent] = value[propertStyleEvent];
					}
					else {
						propertyChanges.end[propertStyleEvent] = value;
					}
				}
			}
			
			// we should move this out
			// add property changes array to the history dictionary
			if (storeInHistory) {
				return HistoryManager.createHistoryEventItems(targets, changes, properties, styles, events, value, description);
			}
			
			return [propertyChanges];
		}
		
		/**
		 * Given a target or targets, property name and value
		 * returns an array of PropertyChange objects.
		 * Points to createPropertyChanges()
		 * 
		 * @see createPropertyChanges()
		 * */
		public static function createPropertyChange(targets:Array, property:String, style:String, event:String, value:*, description:String = ""):Array {
			var values:Object = {};
			var changes:Array;
			
			if (property) {
				values[property] = value;
			}
			else if (style) {
				values[style] = value;
			}
			else if (event) {
				values[event] = value;
			}
			
			changes = createPropertyChanges(targets, ArrayUtil.toArray(property), ArrayUtil.toArray(style), ArrayUtil.toArray(event), values, description, false);
			
			return changes;
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
		 * Updates the properties on a component description
		 * */
		public static function updateComponentProperties(localTargets:Array, propertyChanges:Array, properties:Array, undo:Boolean = false):void {
			var componentDescription:ComponentDescription;
			var numberOfTargets:int = localTargets.length;
			var numberOfChanges:int = propertyChanges.length;
			var propertyChange:Object;
			var localTarget:Object;
			var property:String;
			var value:*;
			var numberOfProperties:int = properties ? properties.length : 0;
			
			
			if (numberOfProperties==0) return;
			
			for (var i:int;i<numberOfTargets;i++) {
				localTarget = localTargets[i];
				componentDescription = selectedDocument.getItemDescription(localTarget);
				
				if (componentDescription) {
					
					for (var j:int=0;j<numberOfChanges;j++) {
						propertyChange = propertyChanges[j];
						
						for (var k:int = 0; k < numberOfProperties; k++) {
							property = properties[k];
							
							if (undo) {
								value = propertyChange.start[property];
							}
							else {
								value = propertyChange.end[property];
							}
							
							if (value===null || 
								value===undefined || 
								value==="") {
								//isNaN(value)) {
								delete componentDescription.properties[property];
							}
							else {
								componentDescription.properties[property] = value;
							}
						}
						
						//componentDescriptor.properties = ObjectUtils.merge(propertyChange.end, componentDescriptor.properties);
					}
				}
				
				// remove nulls and undefined values
				
			}
		}
		
		/**
		 * Updates the styles on a component description
		 * */
		public static function updateComponentStyles(localTargets:Array, propertyChanges:Array, styles:Array, undo:Boolean = false):void {
			var componentDescription:ComponentDescription;
			var numberOfTargets:int = localTargets.length;
			var numberOfChanges:int = propertyChanges.length;
			var propertyChange:Object;
			var localTarget:Object;
			var numberOfStyles:int = styles ? styles.length : 0;
			var style:String;
			var value:*;
			
			if (numberOfStyles==0) return;
			
			for (var i:int;i<numberOfTargets;i++) {
				localTarget = localTargets[i];
				componentDescription = selectedDocument.descriptionsDictionary[localTarget];
				
				if (componentDescription) {
					
					for (var j:int=0;j<numberOfChanges;j++) {
						propertyChange = propertyChanges[j];
						
						for (var k:int = 0; k < numberOfStyles; k++) {
							style = styles[k];
							
							if (undo) {
								value = propertyChange.start[style];
							}
							else {
								value = propertyChange.end[style];
							}
							
							if (value===null || 
								value===undefined || 
								value==="") {
								// || isNaN(value)
								delete componentDescription.styles[style];
							}
							else {
								componentDescription.styles[style] = value;
							}
						}
						
						//componentDescription.styles = ObjectUtils.merge(propertyChange.end, componentDescription.styles);
					}
				}
				
				// remove nulls and undefined values
				
			}
		}
		
		/**
		 * Updates the events on a component description
		 * */
		public static function updateComponentEvents(localTargets:Array, propertyChanges:Array, events:Array, undo:Boolean = false):void {
			var componentDescription:ComponentDescription;
			var numberOfTargets:int = localTargets.length;
			var numberOfChanges:int = propertyChanges.length;
			var propertyChange:Object;
			var localTarget:Object;
			var numberOfEvents:int = events ? events.length : 0;
			var eventName:String;
			var value:*;
			
			if (numberOfEvents==0) return;
			
			for (var i:int;i<numberOfTargets;i++) {
				localTarget = localTargets[i];
				componentDescription = selectedDocument.descriptionsDictionary[localTarget];
				
				if (componentDescription) {
					
					for (var j:int=0;j<numberOfChanges;j++) {
						propertyChange = propertyChanges[j];
						
						for (var k:int = 0; k < numberOfEvents; k++) {
							eventName = events[k];
							
							if (undo) {
								value = propertyChange.start[eventName];
							}
							else {
								value = propertyChange.end[eventName];
							}
							
							if (value===null || 
								value===undefined || 
								value==="") {
								// || isNaN(value)
								delete componentDescription.events[eventName];
							}
							else {
								componentDescription.events[eventName] = value;
							}
						}
						
						//componentDescription.styles = ObjectUtils.merge(propertyChange.end, componentDescription.styles);
					}
				}
				
				// remove nulls and undefined values
				
			}
		}
		
		
		
		/**
		 * Updates the properties on a component description
		 * */
		public static function removeComponentProperties(localTargets:Array, properties:Array):void {
			var componentDescription:ComponentDescription;
			var numberOfTargets:int;
			var localTarget:Object;
			var property:String;
			var numberOfProperties:int;
			
			numberOfTargets = localTargets.length;
			numberOfProperties = properties ? properties.length : 0;
			
			if (numberOfProperties==0) return;
			
			for (var i:int;i<numberOfTargets;i++) {
				localTarget = localTargets[i];
				componentDescription = selectedDocument.getItemDescription(localTarget);
				
				if (componentDescription) {
					for (var k:int = 0; k < numberOfProperties; k++) {
						property = properties[k];
						
						delete componentDescription.properties[property];
					}
				}
			}
		}
		
		
		/**
		 * Gets the value translated into a type. 
		 * */
		public static function getTypedValue(value:*, valueType:*):* {
			
			return TypeUtils.getTypedValue(value, valueType);
		}
		
		/**
		 * Gets the value translated into a type. 
		 * */
		public static function getTypedPropertyValue(target:Object, property:String, value:*):* {
			var propertyType:String;
			propertyType = ClassUtils.getTypeOfProperty(target, property) as String;
			
			return TypeUtils.getTypedValue(value, propertyType);
		}
		
		/**
		 * Gets the value translated into a type from the styles object. 
		 * */
		public static function getTypedValueFromProperty(target:Object, propertiesObject:Object, properties:Array):Object {
			var typedValuesObject:Object;
			var propertyType:Object;
			
			for (var property:String in properties) {
				propertyType = ClassUtils.getTypeOfProperty(target, property);
				typedValuesObject[property] = getTypedValue(propertiesObject[property], propertyType);
			}
			
			return typedValuesObject;
		}
		
		/**
		 * Gets the value translated into a type from the styles object.
		 * Might be duplicate of 
		 attributesValueObject	= ClassUtils.getTypedStyleValueObject(elementInstance as IStyleClient, attributesValueObject, styles); 
		 * */
		public static function getTypedValueFromStyles(target:Object, values:Object, styles:Array):Object {
			var typedValuesObject:Object = {};
			var styleType:Object;
			
			for each (var style:String in styles) {
				styleType = ClassUtils.getTypeOfStyle(target, style);
				typedValuesObject[style] = getTypedValue(values[style], styleType);
			}
			
			return typedValuesObject;
		}
		
		
		/**
		 * Move a component in the display list and sets any properties 
		 * such as positioning. Ensures properties, styles and events are 
		 * all valid.<br/><br/>
		 * 
		 * Usage:
		 <pre>
		 ComponentManager.moveElement(new Button(), container, ["width","color","click"], {width:50,color:red,click:"alert('click')"});
		 </pre>
		 * Usage:
		 <pre>
		 ComponentManager.moveElement(radiate.target, document.instance, ["x"], 15);
		 </pre>
		 * */
		public static function moveElement2(targetItems:*, 
											destination:Object, 
											propertiesStylesEvents:Array,
											values:Object, 
											description:String 	= null, 
											position:String		= AddItems.LAST, 
											relativeTo:Object	= null, 
											index:int			= -1, 
											propertyName:String	= null, 
											isArray:Boolean		= false, 
											isStyle:Boolean		= false, 
											vectorClass:Class	= null,
											keepUndefinedValues:Boolean = true):String {
			
			var items:Array;
			var item:Object;
			var styles:Array;
			var events:Array;
			var properties:Array;
			
			items = ArrayUtil.toArray(targetItems);
			
			propertiesStylesEvents = ArrayUtil.toArray(propertiesStylesEvents);
			
			for (var i:int = 0; i < items.length; i++)  {
				item = items[i];
				
				if (item) {
					styles = ClassUtils.getObjectsStylesFromArray(item, propertiesStylesEvents);
					properties = ClassUtils.getObjectsPropertiesFromArray(item, propertiesStylesEvents, true);
					events = ClassUtils.getObjectsEventsFromArray(item, propertiesStylesEvents);
				}
			}
			
			return moveElement(targetItems, destination, properties, styles, events, values, description, position, relativeTo, index, propertyName, isArray, isStyle);
			
		}
		
		/**
		 * Move a component in the display list and sets any properties 
		 * such as positioning<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>ComponentManager.moveElement(new Button(), parentComponent, [], null);</pre>
		 * 
		 * Usage:<br/>
		 * <pre>ComponentManager.moveElement(radiate.target, null, ["x"], 15);</pre>
		 * */
		public static function moveElement(targetItems:*, 
										   destination:Object, 
										   properties:Array, 
										   styles:Array,
										   events:Array,
										   values:Object, 
										   description:String 	= null, 
										   position:String		= AddItems.LAST, 
										   relativeTo:Object	= null, 
										   index:int			= -1, 
										   propertyName:String	= null, 
										   isArray:Boolean		= false, 
										   isStyle:Boolean		= false, 
										   vectorClass:Class	= null,
										   removeUnchangedValues:Boolean = true, 
										   setPrimitiveDefaults:Boolean = false):String {
			
			var visualElement:IVisualElement;
			var moveItems:AddItems;
			var childIndex:int;
			var propertyChangeChange:PropertyChanges;
			var changes:Array;
			var historyEventItems:Array;
			var isSameOwner:Boolean;
			var isSameParent:Boolean;
			var removeBeforeAdding:Boolean;
			var currentIndex:int;
			var movingIndexWithinParent:Boolean;
			var targetItem:Object;
			var itemOwner:Object;
			var visualElementParent:Object;
			var visualElementOwner:IVisualElementContainer;
			var applicationGroup:GroupBase;
			
			targetItems = ArrayUtil.toArray(targetItems);
			
			targetItem = targetItems ? targetItems[0] : null;
			itemOwner = targetItem ? targetItem.owner : null;
			
			visualElement = targetItem as IVisualElement;
			visualElementParent = visualElement ? visualElement.parent : null;
			visualElementOwner = itemOwner as IVisualElementContainer;
			applicationGroup = destination is Application ? Application(destination).contentGroup : null;
			
			isSameParent = visualElementParent && (visualElementParent==destination || visualElementParent==applicationGroup);
			isSameOwner = visualElementOwner && visualElementOwner==destination;
			
			// set default description
			if (!description) {
				description = HistoryManager.getMoveDescription(targetItem);
			}
			
			// if it's a basic layout then don't try to add it
			// NO DO ADD IT bc we may need to swap indexes
			if (destination is IVisualElementContainer) {
				//destinationGroup = destination as GroupBase;
				
				if (destination is Container) {
					
					if (destination is Canvas) {
						// does not support multiple items?
						if (targetItem && itemOwner==destination) {
							isSameOwner = true;
						}
						
						// check if group parent and destination are the same
						if (targetItem && visualElementParent && (visualElementParent==destination || visualElementParent==applicationGroup)) {
							isSameParent = true;
						}
					}
					
				}
				else 
					if (destination.layout is BasicLayout) {
						
						// does not support multiple items?
						// check if group parent and destination are the same
						if (targetItem && itemOwner==destination) {
							//trace("can't add to the same owner in a basic layout");
							isSameOwner = true;
							
							//return SAME_OWNER;
						}
						
						// check if group parent and destination are the same
						// NOTE: if the item is an element on application this will fail
						if (targetItem && visualElementParent && (visualElementParent==destination || visualElementParent==applicationGroup)) {
							//trace("can't add to the same parent in a basic layout");
							isSameParent = true;
							//return SAME_PARENT;
						}
					}
						// if element is already child of layout container and there is only one element 
					else if (targetItems && destination is IVisualElementContainer 
						&& destination.numElements==1
						&& visualElementParent
						&& (visualElementParent==destination || visualElementParent==applicationGroup)) {
						
						isSameParent = true;
						isSameOwner = true;
						//trace("can't add to the same parent in a basic layout");
						//return SAME_PARENT;
						
					}
			}
				
				// if destination is null then we assume we are moving in same container 
				// or should null mean remove
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
					visualElement = targetItems is Array && (targetItems as Array).length>0 ? targetItems[0] as IVisualElement : targetItems as IVisualElement;
					
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
			moveItems.items = targetItems;
			moveItems.destination = destination;
			moveItems.position = position;
			moveItems.relativeTo = relativeTo;
			moveItems.propertyName = propertyName;
			moveItems.isArray = isArray;
			moveItems.isStyle = isStyle;
			moveItems.vectorClass = vectorClass;
			
			// if we want to check for property facades
			var items:Array;
			var item:Object;
			var propertiesStylesEvents:Array;
			var verifyValidProperties:Boolean;
			
			if (verifyValidProperties) {
				items = ArrayUtil.toArray(targetItems);
				
				propertiesStylesEvents = ArrayUtil.toArray(properties);
				
				for (var i:int = 0; i < items.length; i++)  {
					item = items[i];
					
					if (item) {
						styles = ClassUtils.getObjectsStylesFromArray(properties, propertiesStylesEvents);
						properties = ClassUtils.getObjectsPropertiesFromArray(item, propertiesStylesEvents, true);
						events = ClassUtils.getObjectsEventsFromArray(item, propertiesStylesEvents);
					}
				}
			}
			
			var removeConstraintsFromProperties:Boolean = true;
			var constraintStyles:Array;
			
			// remove constraints from properties array
			if (removeConstraintsFromProperties && properties && properties.length) {
				constraintStyles = ClassUtils.removeConstraintsFromArray(properties);
				
				if (constraintStyles.length) {
					if (styles==null) styles = [];
					ArrayUtils.addMissingItems(styles, constraintStyles);
				}
			}
			
			// add properties that need to be modified
			if ((properties && properties.length) || (styles && styles.length) || (events && events.length)) {
				changes = createPropertyChanges(targetItems, properties, styles, events, values, description, false);
				
				// get the property change part
				propertyChangeChange = changes[0];
			}
			else {
				changes = [];
			}
			
			// constraints use undefined values 
			// so if we use constraints do not strip out values
			if (!removeUnchangedValues) {
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
					//info("Move: Nothing to change or add");
					return "Nothing to change or add";
				}
				
				// store changes
				// add to history
				if (!HistoryManager.doNotAddEventsToHistory) {
					historyEventItems = HistoryManager.createHistoryEventItems(targetItems, changes, properties, styles, events, values, description, RadiateEvent.MOVE_ITEM);
				}
				
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
						visualElementOwner.removeElement(visualElement);// validate now???
						visualElementOwner is IInvalidating ? IInvalidating(visualElementOwner).validateNow() : void;
					}
					
					moveItems.apply(moveItems.destination as UIComponent);
					
					if (moveItems.destination is SkinnableContainer && !SkinnableContainer(moveItems.destination).deferredContentCreated) {
						//Radiate.error("Not added because deferred content not created.");
						var factory:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(deferredInstanceFromFunction);
						SkinnableContainer(moveItems.destination).mxmlContentFactory = factory;
						SkinnableContainer(moveItems.destination).createDeferredContent();
						SkinnableContainer(moveItems.destination).removeAllElements();
						moveItems.apply(moveItems.destination as UIComponent);
					}
					
					LayoutManager.getInstance().validateNow();
				}
				
				// try setting properties
				if (changesAvailable([propertyChangeChange])) {
					applyChanges(targetItems, [propertyChangeChange], properties, styles, events);
					LayoutManager.getInstance().validateNow();
					
					properties 	&& properties.length ? updateComponentProperties(targetItems, [propertyChangeChange], properties) :-1;
					styles 		&& styles.length ? updateComponentStyles(targetItems, [propertyChangeChange], styles) :-(1);
					events 		&& events.length ? updateComponentEvents(targetItems, [propertyChangeChange], events) :-1;
				}
				
				
				// add to history
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.addHistoryEvents(selectedDocument, historyEventItems);
				}
				
				if (Radiate.importingDocument==false) {
					// check for changes before dispatching
					if (changes.indexOf(moveItems)!=-1) {
						Radiate.dispatchMoveEvent(targetItems, changes, properties);
					}
					
					//setTargets(items, true);
					
					if (properties) {
						Radiate.dispatchPropertyChangeEvent(targetItems, changes, properties, styles, events);
					}
				}
				
				return MOVED; // we assume moved if it got this far - needs more checking
			}
			catch (errorEvent:Error) {
				// this is clunky - needs to be upgraded
				
				// Move error: Error #1069: Property null not found on com.flexcapacitor.model.Document and there is no default value.
				// Solution: you are passing in the document not the instance of the document
				error("Move error: " + errorEvent.message);
				
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.removeHistoryEvent(changes);
					HistoryManager.removeHistoryItem(selectedDocument, changes);
				}
				
				return String(errorEvent.message);
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
		 * ComponentManager.addElement(new Button(), event.targetCandidate);
		 * */
		public static function addElement(items:*, 
										  destination:Object, 
										  properties:Array 		= null, 
										  styles:Array			= null,
										  events:Array			= null,
										  values:Object			= null, 
										  description:String 	= null, 
										  position:String		= AddItems.LAST, 
										  relativeTo:Object		= null, 
										  index:int				= -1, 
										  propertyName:String	= null, 
										  isArray:Boolean		= false, 
										  isStyle:Boolean		= false, 
										  vectorClass:Class		= null,
										  keepUndefinedValues:Boolean = true, 
										  setPrimitiveDefaults:Boolean = false):String {
			
			
			if (!description) {
				description = HistoryManager.getAddDescription(items);
			}
			
			var results:String = moveElement(items, destination, properties, styles, events, values, 
				description, position, relativeTo, index, propertyName, 
				isArray, isStyle, vectorClass, keepUndefinedValues, setPrimitiveDefaults);
			
			var component:Object;
			
			var itemsArray:Array;
			
			itemsArray = ArrayUtil.toArray(items);
			
			for (var i:int; i < itemsArray.length; i++) {
				component = itemsArray[0];
				// should remove this when we can refactor
				updateComponentAfterAdd(selectedDocument, component, false, false, setPrimitiveDefaults);
			}
			
			return results;
		}
		
		
		/**
		 * Removes an element from the display list.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>ComponentManager.removeElement(radiate.targets);</pre>
		 * */
		public static function removeElement(items:*, description:String = null):String {
			var visualElement:IVisualElement;
			var removeItems:AddItems;
			var childIndex:int;
			var propertyChangeChange:PropertyChanges;
			var changes:Array;
			var historyEvents:Array;
			var isSameOwner:Boolean;
			var isSameParent:Boolean;
			var removeBeforeAdding:Boolean;
			var currentIndex:int;
			var movingIndexWithinParent:Boolean;
			var destination:Object;
			var index:int;
			var position:String;
			var item:Object;
			var itemOwner:Object;
			var visualElementParent:Object;
			var visualElementOwner:IVisualElementContainer;
			var applicationGroup:GroupBase;
			
			items = ArrayUtil.toArray(items);
			
			item = items ? items[0] : null;
			itemOwner = item && "owner" in item ? item.owner : null;
			
			if (item==null || itemOwner==null) {
				Radiate.info("Cannot delete item:"+ item);
				return REMOVE_ERROR;
			}
			
			visualElement = item as IVisualElement;
			visualElementParent = visualElement ? visualElement.parent : null;
			visualElementOwner = itemOwner as IVisualElementContainer;
			applicationGroup = destination is Application ? Application(destination).contentGroup : null;
			
			isSameParent = visualElementParent && (visualElementParent==destination || visualElementParent==applicationGroup);
			isSameOwner = visualElementOwner && visualElementOwner==destination;
			
			// set default description
			if (!description) {
				description = HistoryManager.getRemoveDescription(item);
			}
			
			if (visualElement is Application) {
				//info("You can't remove the document");
				return REMOVE_ERROR;
			}
			
			
			destination = item.owner;
			index = destination ? destination.getElementIndex(visualElement) : -1;
			changes = [];
			
			
			// attempt to remove
			try {
				removeItems = HistoryManager.createReverseAddItems(items[0]);
				changes.unshift(removeItems);
				
				// store changes
				historyEvents = HistoryManager.createHistoryEventItems(items, changes, null, null, null, null, description, RadiateEvent.REMOVE_ITEM);
				
				// try moving
				//removeItems.apply(destination as UIComponent);
				//removeItems.apply(null);
				visualElementOwner.removeElement(visualElement);
				//removeItems.remove(destination as UIComponent);
				LayoutManager.getInstance().validateNow();
				
				
				// add to history
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.addHistoryEvents(selectedDocument, historyEvents);
				}
				
				// check for changes before dispatching
				Radiate.dispatchRemoveItemsEvent(items, changes, null);
				// select application - could be causing errors - should select previous targets??
				Radiate.setTargets(selectedDocument.instance, true);
				
				return REMOVED; // we assume moved if it got this far - needs more checking
			}
			catch (errorEvent:Error) {
				// this is clunky - needs to be upgraded
				error("Remove error: " + errorEvent.message);
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.removeHistoryEvent(changes);
					HistoryManager.removeHistoryItem(selectedDocument, changes);
				}
				return String(errorEvent.message);
			}
			
			return REMOVE_ERROR;
		}
		
		
		/**
		 * Required for creating BorderContainers
		 * */
		protected static function deferredInstanceFromFunction():Array {
			var label:Label = new Label();
			return [label];
		}
		
		/**
		 * Sets the default properties. We may need to use setActualSize type of methods here or when added. 
		 * 
		 * For instructions on setting default properties or adding new component types
		 * look in Radii8Desktop/howto/HowTo.txt
		 * */
		public static function setDefaultProperties(componentDescription:ComponentDescription):void {
			
			var valuesObject:ValuesObject = getPropertiesStylesFromObject(componentDescription.instance, componentDescription.defaultProperties);
			
			// maybe do not add to history
			setPropertiesStylesEvents(componentDescription.instance, valuesObject.propertiesStylesEvents, valuesObject.values, "Setting defaults");
			//HistoryManager.mergeLastHistoryEvent(instance.selectedDocument);
		}
		
		/**
		 * Updates the component with any additional settings for it to work 
		 * after it's been added to the document.
		 * 
		 * For instructions on setting default properties or adding new component types
		 * look in Radii8Desktop/howto/HowTo.txt
		 * 
		 * @see #createComponentToAdd()
		 * */
		public static function updateComponentAfterAdd(iDocument:IDocument, target:Object, setDefaults:Boolean = false, interactive:Boolean = false, setPrimitiveDefaults:Boolean = true):void {
			var componentDescription:ComponentDescription = iDocument.getItemDescription(target);
			var componentInstance:Object = componentDescription ? componentDescription.instance : null;
			
			// set defaults
			if (componentDescription && setDefaults) {
				setDefaultProperties(componentDescription);
			}
			
			iDocument.updateComponentTree();
			
			// need to add so we can listen for click events on transparent areas of groups
			if (componentInstance is GroupBase) {
				DisplayObjectUtils.addGroupMouseSupport(componentInstance as GroupBase);
			}
			
			// we can't add elements if skinnablecontainer._deferredContentCreated is false
			if (target is BorderContainer) {
				/*var factory:DeferredInstanceFromFunction;
				factory = new DeferredInstanceFromFunction(deferredInstanceFromFunction);
				BorderContainer(component).mxmlContentFactory = factory;
				BorderContainer(component).createDeferredContent();
				BorderContainer(component).removeAllElements();*/
				
				// we could probably also do this: 
				BorderContainer(target).addElement(new Label());
				BorderContainer(target).removeAllElements();
				
				// we do this to get rid of the round joints. this skin joints default to miter
				// UPDATE - this causes an infinite loop somewhere when deleting an element
				// so let's just remove it for now
				//BorderContainer(target).setStyle("skinClass", com.flexcapacitor.skins.BorderContainerSkin);
				BorderContainer(target).setStyle("cornerRadius", 0);
			}
			
			// add fill and stroke to graphic elements
			if (componentInstance is GraphicElement && setPrimitiveDefaults) {
				var fill:SolidColor;
				var stroke:SolidColorStroke;
				var object:Object = {};
				var properties:Array = [];
				
				if (componentInstance is FilledElement && componentInstance.fill==null) {
					fill = new SolidColor();
					fill.color = 0xf6f6f6;
					object.fill = fill;
				}
				
				if (componentInstance is StrokedElement && componentInstance.stroke==null) {
					
					// not adding stroke to rectangle, path, ellipse
					if (componentInstance is Rect || componentInstance is Path || componentInstance is Ellipse) {
						
					}
					else {
						stroke = new SolidColorStroke();
						stroke.color = 0xA6A6A6;
						stroke.joints = JointStyle.MITER;
						object.stroke = stroke;
					}
				}
				
				if (componentInstance is Path && componentInstance.data==null) {
					object.data = "L 80 80 V 0 L 0 80 V 0";
				}
				
				
				for (var property:String in object) {
					//setProperty(component, property, [item.defaultProperties[property]]);
					properties.push(property);
					//componentDescription.defaultProperties[property] = object[property];
				}
				
				if (properties.length) {
					setProperties(componentInstance, properties, object, "Setting graphic element properties");
				}
				//HistoryManager.mergeLastHistoryEvent(instance.selectedDocument);
			}
			
			makeRuntimeInteractive(componentInstance, interactive);
			
			// prevent components from interacting with design view
			
			// we need a custom FlexSprite class to do this
			// do this after drop
			if ("eventListeners" in target && !(target is GroupBase)) {
				target.removeAllEventListeners();
			}
			
			// we need a custom FlexSprite class to do this
			// do this after drop
			/*if ("eventListeners" in component) {
			component.removeAllEventListeners();
			}*/
			
			// we can't add elements if skinnablecontainer._deferredContentCreated is false
			/*if (component is BorderContainer) {
			BorderContainer(component).creationPolicy = ContainerCreationPolicy.ALL;
			BorderContainer(component).initialize();
			BorderContainer(component).createDeferredContent();
			BorderContainer(component).initialize();
			}*/
		}
		
		/**
		 * When set to true, makes a component interactive as in a normal app. 
		 * When false makes component behave as if it was on the design view
		 * @param showTextEditor opens a text editor when set to true and component is a text based
		 * */
		public static function makeRuntimeInteractive(componentInstance:Object, runtime:Boolean = false, showTextEditor:Boolean = true):void {
			
			// graphic elements
			// when we say interactive we mean what the user will interact with
			// do not make graphic elements interactive for user
			if (componentInstance is GraphicElement) {
				GraphicElement(componentInstance).alwaysCreateDisplayObject = !runtime;
				
				// button mode may be preventing keyboard events from reaching the application
				// turning it off seems to fix the problem but if the height or width are
				// but button mode shows a hand cursor so small elements are easier to select 
				if (GraphicElement(componentInstance).displayObject) {
					Sprite(GraphicElement(componentInstance).displayObject).mouseEnabled = !runtime;
					Sprite(GraphicElement(componentInstance).displayObject).buttonMode = !runtime;
					//Sprite(GraphicElement(componentInstance).displayObject).mouseChildren = false;
				}
			}
			
			// if text based or combo box we need to prevent 
			// interaction with cursor
			if (componentInstance is TextBase || componentInstance is SkinnableTextBase) {
				componentInstance.mouseChildren = runtime;
				
				if ("textDisplay" in componentInstance && componentInstance.textDisplay) {
					componentInstance.textDisplay.enabled = runtime;
				}
				
				
				// if show editor on double click then continue to be interactive 
				if (showTextEditor) {
					if (componentInstance is Label || componentInstance is RichText || componentInstance is Hyperlink) {
						componentInstance.doubleClickEnabled = true;
						
						componentInstance.addEventListener(MouseEvent.DOUBLE_CLICK, TextEditorManager.showTextEditorHandler, false, 0, true);
					}
					else {
						componentInstance.doubleClickEnabled = false;
						componentInstance.removeEventListener(MouseEvent.DOUBLE_CLICK, TextEditorManager.showTextEditorHandler);
					}
					
					if (componentInstance is Hyperlink) {
						componentInstance.useHandCursor = true;
					}
				}
				else {
					if (componentInstance is Label || componentInstance is RichText) {
						componentInstance.doubleClickEnabled = runtime;
						
						if (runtime) {
							componentInstance.addEventListener(MouseEvent.DOUBLE_CLICK, TextEditorManager.showTextEditorHandler, false, 0, true);
						}
						else {
							componentInstance.removeEventListener(MouseEvent.DOUBLE_CLICK, TextEditorManager.showTextEditorHandler);
						}
					}
					
					if (componentInstance is Hyperlink) {
						componentInstance.useHandCursor = runtime;
					}
				}
			}
			
			var sparkColorPicker:Class = ClassUtils.getDefinition("spark.components.ColorPicker") as Class;
			
			// spark or mx ColorPicker
			if ((sparkColorPicker && componentInstance is sparkColorPicker) || componentInstance is mx.controls.ColorPicker) {
				Object(componentInstance).mouseChildren = runtime;
				IStyleClient(componentInstance).setStyle("focusThickness", 0);
			}
			
			// NumericStepper
			if (componentInstance is NumericStepper) {
				NumericStepper(componentInstance).mouseChildren = runtime;
			}
			
			// dropdown or combobox
			if (componentInstance is ComboBox || componentInstance is DropDownList) {
				if ("textInput" in componentInstance && componentInstance.textInput && 
					componentInstance.textInput.textDisplay) {
					ComboBox(componentInstance).textInput.textDisplay.enabled = runtime;
				}
				
				DropDownListBase(componentInstance).mouseChildren = runtime;
			}
			
			// Vertical or Horizontal Slider
			if (componentInstance is SliderBase) {
				SliderBase(componentInstance).mouseChildren = runtime;
			}
			
			
			if (componentInstance is LinkButton) {
				LinkButton(componentInstance).useHandCursor = runtime;
			}
			
			if (componentInstance is Hyperlink) {
				// prevent links from clicking use UIGlobals...designMode
				Hyperlink(componentInstance).useHandCursor = !runtime;
				Hyperlink(componentInstance).preventLaunching = runtime;
			}
			
			// checkbox or radio button or toggle button
			if (componentInstance is ToggleButtonBase) {
				
				if (!runtime) {
					IEventDispatcher(componentInstance).addEventListener(MouseEvent.CLICK, disableToggleButtonHandler, false, 0, true);
				}
				else {
					IEventDispatcher(componentInstance).removeEventListener(MouseEvent.CLICK, disableToggleButtonHandler);
				}
				
			}
			
			// test on spark grid
			if (false && componentInstance is spark.components.Grid) {
				spark.components.Grid(componentInstance).itemRenderer= new ClassFactory(DefaultGridItemRenderer);
				spark.components.Grid(componentInstance).dataProvider = new ArrayCollection(["item 1", "item 2", "item 3"]);
			}
			
			// test on mx grid
			if (false && componentInstance is mx.containers.Grid) {
				mx.containers.Grid(componentInstance)
				var grid:mx.containers.Grid = componentInstance as mx.containers.Grid;
				var gridRow:GridRow	= new GridRow();
				var gridItem:GridItem = new GridItem();
				var gridItem2:GridItem = new GridItem();
				
				var gridButton:Button = new Button();
				gridButton.width = 100;
				gridButton.height = 100;
				gridButton.label = "hello";
				var gridButton2:Button = new Button();
				gridButton2.width = 100;
				gridButton2.height = 100;
				gridButton2.label = "hello2";
				
				gridItem.addElement(gridButton);
				gridItem2.addElement(gridButton2);
				gridRow.addElement(gridItem);
				gridRow.addElement(gridItem2);
				grid.addElement(gridRow);
			}
			
		}
		
		/**
		 * Rebuilds the component tree structure
		 * */
		public function updateComponentTree(iDocument:IDocument):void {
			if (iDocument is Document) {
				Document(iDocument).updateComponentTree();
			}
		}
		
		/**
		 * Disables toggle button base classes
		 * */
		public static function disableToggleButtonHandler(event:Event):void {
			ToggleButtonBase(event.currentTarget).selected = !ToggleButtonBase(event.currentTarget).selected;
			event.stopImmediatePropagation();
			event.preventDefault();
		}
		
		/**
		 * Move element left by a specified amount taking into account constraints
		 **/
		public static function moveLeft(element:Object, amount:Number):void {
			var leftValue:Object;
			var rightValue:Object;
			var horizontalCenter:Object;
			var properties:Array = [];
			var propertiesObject:Object = {};
			var line:Line;
			var xFrom:Number;
			var xTo:Number;
			var xDiff:Number;
			
			if (element is Line) {
				line = element as Line;
				
				xDiff = -amount;
				xFrom = line.xFrom + xDiff;
				propertiesObject["xFrom"] = xFrom;
				properties.push("xFrom");
				
				if (isNaN(line.percentWidth)) {
					xTo = line.xTo + xDiff;
					propertiesObject["xTo"] = xTo;
					properties.push("xTo");
				}
				
			}
			else {
				leftValue = element.left;
				rightValue = element.right;
				horizontalCenter = element.horizontalCenter;
				
				/**
				 * If left is set then set x to nothing
				 * If left and right are set then set width to nothing
				 * If horizontalCenter is set than set left and right to nothing
				 * Otherwise set left to nothing
				 * */
				if (leftValue!=null && rightValue!=null) {
					propertiesObject.left = Number(element.left) - amount;
					propertiesObject.right = Number(element.right) + amount;
					properties.push(MXMLDocumentConstants.LEFT, MXMLDocumentConstants.RIGHT);
				}
				else if (leftValue!=null) {
					propertiesObject.left = Number(element.left) - amount;
					properties.push(MXMLDocumentConstants.LEFT);
				}
				else if (rightValue!=null) {
					propertiesObject.right = Number(element.right) + amount;
					properties.push(MXMLDocumentConstants.RIGHT);
				}
				else if (horizontalCenter!=null) {
					propertiesObject.horizontalCenter = Number(element.horizontalCenter) - amount;
					properties.push(MXMLDocumentConstants.HORIZONTAL_CENTER);
				}
				else {
					propertiesObject.x = element.x - amount;
					properties.push(MXMLDocumentConstants.X);
				}
			}
			
			moveElement2(element, null, properties, propertiesObject);
		}
		
		/**
		 * Move element right by a specified amount taking into account constraints
		 **/
		public static function moveRight(element:Object, amount:Number):void {
			var leftValue:Object;
			var rightValue:Object;
			var horizontalCenter:Object;
			var properties:Array = [];
			var propertiesObject:Object = {};
			var line:Line;
			var xFrom:Number;
			var xTo:Number;
			var xDiff:Number;
			
			
			if (element is Line) {
				line = element as Line;
				
				xDiff = amount;
				xFrom = line.xFrom + xDiff;
				propertiesObject["xFrom"] = xFrom;
				properties.push("xFrom");
				
				if (isNaN(line.percentWidth)) {
					xTo = line.xTo + xDiff;
					propertiesObject["xTo"] = xTo;
					properties.push("xTo");
				}
				
			}
			else {
				leftValue = element.left;
				rightValue = element.right;
				horizontalCenter = element.horizontalCenter;
				
				if (leftValue!=null && rightValue!=null) {
					propertiesObject.left = Number(element.left) + amount;
					propertiesObject.right = Number(element.right) - amount;
					properties.push(MXMLDocumentConstants.LEFT, MXMLDocumentConstants.RIGHT);
				}
				else if (leftValue!=null) {
					propertiesObject.left = Number(element.left) + amount;
					properties.push(MXMLDocumentConstants.LEFT);
				}
				else if (rightValue!=null) {
					propertiesObject.right = Number(element.right) - amount;
					properties.push(MXMLDocumentConstants.RIGHT);
				}
				else if (horizontalCenter!=null) {
					propertiesObject.horizontalCenter = Number(element.horizontalCenter) + amount;
					properties.push(MXMLDocumentConstants.HORIZONTAL_CENTER);
				}
				else {
					propertiesObject.x = element.x + amount;
					properties.push(MXMLDocumentConstants.X);
				}
			}
			
			moveElement2(element, null, properties, propertiesObject);
		}
		
		/**
		 * Move element up by a specified amount taking into account constraints
		 **/
		public static function moveUp(element:Object, amount:Number):void {
			var topValue:Object;
			var bottomValue:Object;
			var verticalCenter:Object;
			var properties:Array = [];
			var propertiesObject:Object = {};
			var line:Line;
			var yFrom:Number;
			var yTo:Number;
			var yDiff:Number;
			
			if (element is Line) {
				line = element as Line;
				
				yDiff = -amount;
				yFrom = line.yFrom + yDiff;
				propertiesObject["yFrom"] = yFrom;
				properties.push("yFrom");
				
				if (isNaN(line.percentHeight)) {
					yTo = line.yTo + yDiff;
					propertiesObject["yTo"] = yTo;
					properties.push("yTo");
				}
			}
			else {
				topValue = element.top;
				bottomValue = element.bottom;
				verticalCenter = element.verticalCenter;
				
				if (topValue!=null && bottomValue!=null) {
					propertiesObject.top = Number(element.top) - amount;
					propertiesObject.bottom = Number(element.bottom) + amount;
					properties.push(MXMLDocumentConstants.TOP, MXMLDocumentConstants.BOTTOM);
				}
				else if (topValue!=null) {
					propertiesObject.top = Number(element.top) - amount;
					properties.push(MXMLDocumentConstants.TOP);
				}
				else if (bottomValue!=null) {
					propertiesObject.bottom = Number(element.bottom) + amount;
					properties.push(MXMLDocumentConstants.BOTTOM);
				}
				else if (verticalCenter!=null) {
					propertiesObject.verticalCenter = Number(element.verticalCenter) - amount;
					properties.push(MXMLDocumentConstants.VERTICAL_CENTER);
				}
				else {
					propertiesObject.y = element.y - amount;
					properties.push(MXMLDocumentConstants.Y);
				}
			}
			
			moveElement2(element, null, properties, propertiesObject);
		}
		
		/**
		 * Move element down by a specified amount taking into account constraints
		 **/
		public static function moveDown(element:Object, amount:Number):void {
			var topValue:Object;
			var bottomValue:Object;
			var verticalCenter:Object;
			var properties:Array = [];
			var propertiesObject:Object = {};
			var line:Line;
			var yFrom:Number;
			var yTo:Number;
			var yDiff:Number;
			
			
			if (element is Line) {
				line = element as Line;
				
				yDiff = amount;
				yFrom = line.yFrom + yDiff;
				propertiesObject["yFrom"] = yFrom;
				properties.push("yFrom");
				
				if (isNaN(line.percentHeight)) {
					yTo = line.yTo + yDiff;
					propertiesObject["yTo"] = yTo;
					properties.push("yTo");
				}
			}
			else {
				topValue = element.top;
				bottomValue = element.bottom;
				verticalCenter = element.verticalCenter;
				
				if (topValue!=null && bottomValue!=null) {
					propertiesObject.top = Number(element.top) + amount;
					propertiesObject.bottom = Number(element.bottom) - amount;
					properties.push(MXMLDocumentConstants.TOP, MXMLDocumentConstants.BOTTOM);
				}
				else if (topValue!=null) {
					propertiesObject.top = Number(element.top) + amount;
					properties.push(MXMLDocumentConstants.TOP);
				}
				else if (bottomValue!=null) {
					propertiesObject.bottom = Number(element.bottom) - amount;
					properties.push(MXMLDocumentConstants.BOTTOM);
				}
				else if (verticalCenter!=null) {
					propertiesObject.verticalCenter = Number(element.verticalCenter) + amount;
					properties.push(MXMLDocumentConstants.VERTICAL_CENTER);
				}
				else {
					propertiesObject.y = element.y + amount;
					properties.push(MXMLDocumentConstants.Y);
				}
			}
			
			moveElement2(element, null, properties, propertiesObject);
		}
		
		/**
		 * Move element by a specified amount taking into account constraints.
		 * Use MXMLDocumentConstants for direction
		 **/
		public static function move(target:Object, direction:String, amount:Number):void {
			
			if (direction==MXMLDocumentConstants.LEFT) {
				moveLeft(target, amount);
			}
			else if (direction==MXMLDocumentConstants.RIGHT) {
				moveRight(target, amount);
			}
			else if (direction==MXMLDocumentConstants.UP) {
				moveUp(target, amount);
			}
			else if (direction==MXMLDocumentConstants.DOWN) {
				moveDown(target, amount);
			}
		}
		
		/**
		 * Resets the position of a element
		 **/
		public static function resetPosition(element:Object):void {
			var topValue:Object;
			var bottomValue:Object;
			var verticalCenter:Object;
			var properties:Array = [];
			var propertiesObject:Object = {};
			var line:Line;
			var yFrom:Number;
			var yTo:Number;
			var yDiff:Number;
			var xFrom:Number;
			var xTo:Number;
			var xDiff:Number;
			var reversed:Boolean;
			
			
			if (element is Line) {
				line = element as Line;
				
				if (line.xFrom>line.xTo) {
					propertiesObject["xFrom"] = line.xFrom-line.xTo;
					propertiesObject["xTo"] = 0;
					properties.push("xFrom");
					properties.push("xTo");
				}
				else {
					propertiesObject["xFrom"] = 0;
					propertiesObject["xTo"] = line.xTo-line.xFrom;
					properties.push("xFrom");
					properties.push("xTo");
				}
				
				if (line.yFrom>line.yTo) {
					propertiesObject["yFrom"] = line.yFrom-line.yTo;
					propertiesObject["yTo"] = 0;
					properties.push("yFrom");
					properties.push("yTo");
				}
				else {
					propertiesObject["yFrom"] = 0;
					propertiesObject["yTo"] = line.yTo-line.yFrom;
					properties.push("yFrom");
					properties.push("yTo");
				}
			}
			else {
				if ("verticalCenter" in element && element.verticalCenter!=undefined) {
					properties.push("verticalCenter");
					propertiesObject.verticalCenter = 0;
				}
				else if ("top" in element && element.top!=undefined) {
					properties.push("top");
					propertiesObject.top = 0;
				}
				else {
					properties.push("y");
					propertiesObject.y = 0;
				}
				
				if ("horizontalCenter" in element && element.horizontalCenter!=undefined) {
					properties.push("horizontalCenter");
					propertiesObject.horizontalCenter = 0;
				}
				else if ("left" in element && element.left!=undefined) {
					properties.push("left");
					propertiesObject.left = 0;
				}
				else {
					properties.push("x");
					propertiesObject.x = 0;
				}
			}
			
			setProperties(element, properties, propertiesObject);
		}
		
		/**
		 * Round element positions to integer
		 **/
		public static function roundPositionToIntegers(element:Object):void {
			var topValue:Object;
			var bottomValue:Object;
			var verticalCenter:Object;
			var properties:Array = [];
			var propertiesObject:Object = {};
			var line:Line;
			var yFrom:Number;
			var yTo:Number;
			var yDiff:Number;
			var xFrom:Number;
			var xTo:Number;
			var xDiff:Number;
			var reversed:Boolean;
			
			if (element is Line) {
				line = element as Line;
				
				if (line.xFrom>line.xTo) {
					propertiesObject["xFrom"] = line.xFrom-line.xTo;
					propertiesObject["xTo"] = Math.round(line.xTo);
					properties.push("xFrom");
					properties.push("xTo");
				}
				else {
					propertiesObject["xFrom"] = Math.round(line.xFrom);
					propertiesObject["xTo"] = line.xTo-line.xFrom;
					properties.push("xFrom");
					properties.push("xTo");
				}
				
				if (line.yFrom>line.yTo) {
					propertiesObject["yFrom"] = line.yFrom-line.yTo;
					propertiesObject["yTo"] = Math.round(line.yTo);
					properties.push("yFrom");
					properties.push("yTo");
				}
				else {
					propertiesObject["yFrom"] = Math.round(line.yFrom);
					propertiesObject["yTo"] = line.yTo-line.yFrom;
					properties.push("yFrom");
					properties.push("yTo");
				}
			}
			else {
				if ("verticalCenter" in element && element.verticalCenter!=undefined) {
					properties.push("verticalCenter");
					propertiesObject.verticalCenter = Math.round(element.verticalCenter);
				}
				else if ("top" in element && element.top!=undefined) {
					properties.push("top");
					propertiesObject.top = Math.round(element.top);
				}
				else {
					properties.push("y");
					propertiesObject.y = Math.round(element.y);
				}
				
				if ("horizontalCenter" in element && element.horizontalCenter!=undefined) {
					properties.push("horizontalCenter");
					propertiesObject.horizontalCenter = Math.round(element.horizontalCenter);
				}
				else if ("left" in element && element.left!=undefined) {
					properties.push("left");
					propertiesObject.left = Math.round(element.left);
				}
				else {
					properties.push("x");
					propertiesObject.x = Math.round(element.x);
				}
			}
			
			setProperties(element, properties, propertiesObject);
		}
		
		/**
		 * Returns true if target has single filter
		 **/
		public static function hasSingleFilter(target:Object):Boolean {
			return target && "filters" in target && target.filters.length==1;
		}
		
		/**
		 * Returns filter if it has one
		 **/
		public static function getFirstFilter(target:Object):Object {
			return target && "filters" in target && target.filters.length>0 ? target.filters[0] : null;
		}
		
		//----------------------------------
		//  instance
		//----------------------------------
		
		public static function get instance():ComponentManager
		{
			if (!_instance) {
				_instance = new ComponentManager(new SINGLEDOUBLE());
			}
			return _instance;
		}
		
		public static function getInstance():ComponentManager {
			return instance;
		}
		
		private static var _instance:ComponentManager;
	}
}

class SINGLEDOUBLE{}