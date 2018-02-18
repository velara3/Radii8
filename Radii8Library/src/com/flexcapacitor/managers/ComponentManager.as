package com.flexcapacitor.managers
{
	import com.flexcapacitor.controller.Console;
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.utils.ClassUtils;
	import com.flexcapacitor.utils.StringUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDefinition;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	
	import spark.components.Application;
	import spark.core.ContentCache;

	/**
	 * Manages components 
	 **/
	public class ComponentManager extends Console {
		
		public function ComponentManager() {
			
		}
		
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
				Radiate.instance.dispatchComponentDefinitionAddedEvent(componentDefinition);
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
				componentDefinition = ComponentManager.getDynamicComponentType(instance);
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
				Radiate.setDefaultProperties(componentDescription);
			}
			
			componentDescription.componentDefinition = componentDefinition;
			
			iDocument.setItemDescription(componentInstance, componentDescription);
			//iDocument.descriptionsDictionary[componentInstance] = componentDescription;
			
			Radiate.lastCreatedComponent = componentInstance;
			
			return componentInstance;
		}
		
	}
}