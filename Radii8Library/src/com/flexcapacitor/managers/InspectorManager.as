package com.flexcapacitor.managers
{
	import com.flexcapacitor.controller.Console;
	import com.flexcapacitor.model.InspectableClass;
	import com.flexcapacitor.model.InspectorData;
	import com.flexcapacitor.performance.PerformanceMeter;
	import com.flexcapacitor.utils.ClassUtils;
	import com.flexcapacitor.views.IInspector;
	
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.core.IInvalidating;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.managers.LayoutManager;
	
	import spark.components.Application;
	import spark.components.VGroup;

	/**
	 * Manages inspector panels
	 **/
	public class InspectorManager extends Console {
		
		public function InspectorManager() {
		
		}
		
		//----------------------------------
		//
		//  Inspector Management
		// 
		//----------------------------------
		
		/**
		 * Collection of inspectors that can be added or removed to 
		 * */
		[Bindable]
		public static var inspectorsDescriptions:ArrayCollection = new ArrayCollection();
		
		/**
		 * Dictionary of classes that have inspectors
		 * */
		[Bindable]
		public static var inspectableClassesDictionary:Dictionary = new Dictionary();
		
		/**
		 * Dictionary of instances of inspectors searched by class name
		 * */
		[Bindable]
		public static var inspectorsDictionary:Dictionary = new Dictionary();
		
		/**
		 * Dictionary of instances of containers by class name
		 * */
		[Bindable]
		public static var inspectorContainerDictionary:Dictionary = new Dictionary();
		
		/**
		 * Add the named inspector class to the list of available inspectors
		 * */
		public static function addInspectorType(name:String, className:String, classType:Object, icon:Object = null, defaults:Object=null):Boolean {
			var inspectorData:InspectorData;
			
			if (inspectorsDictionary[className]==null) {
				inspectorData = new InspectorData();
				inspectorData.name = name==null ? className : name;
				inspectorData.className = className;
				inspectorData.classType = classType;
				inspectorData.icon = icon;
				inspectorData.defaults = defaults;
				inspectorsDictionary[className] = inspectorData;
			}
			
			
			return true;
		}
		
		/**
		 * Gets inspector classes or null if the definition is not found.
		 * */
		public static function getInspectableClassData(className:String):InspectableClass {
			var inspectableClass:InspectableClass = inspectableClassesDictionary[className];
			
			return inspectableClass;
		}
		
		/**
		 * Gets an instance of the inspector class or null if the definition is not found.
		 * */
		public static function getInspectorInstance(className:String):IInspector {
			var inspectorData:InspectorData = inspectorsDictionary[className];
			
			if (inspectorData) {
				if (inspectorData.instance) {
					return inspectorData.instance;
				}
				
				var instance:IInspector = inspectorData.getInstance();
				
				return instance;
				
			}
			
			return null;
		}
		
		/**
		 * Gets an instance of the inspector class or null if the definition is not found.
		 * */
		public static function getInspector(target:Object, domain:ApplicationDomain = null):IInspector {
			var className:String;
			
			if (target) {
				className = ClassUtils.getQualifiedClassName(target);
				
				var instance:IInspector = getInspectorInstance(className);
				
				return instance;
			}
			
			return null;
		}
		
		/**
		 * Gets array of inspector data for the given fully qualified class or object
		 * */
		public static function getInspectors(target:Object, fallBackOnSuperClasses:Boolean = false):Array {
			var className:String;
			var inspectors:Array;
			var inspectorDataArray:Array;
			var inspectableClass:InspectableClass;
			
			if (target==null) return [];
			
			className = getInspectableClassName(target);
			
			inspectableClass = getInspectableClassData(className);
			
			if (inspectableClass) {
				return inspectableClass.inspectors;
			}
			
			return [];
		}
		
		/**
		 * Get class name used as key for dictionary and lookup
		 **/
		public static function getInspectableClassName(target:Object):String {
			var className:String;
			
			if (target is Object) {
				className = ClassUtils.getQualifiedClassName(target);
				
				if (target is Application) {
					className = ClassUtils.getSuperClassName(target);
				}
			}
			
			if (target is String) {
				className = String(target);
			}
			
			className = className ? className.split("::").join(".") : className;
			
			return className;
		}
		
		/**
		 * Creates the list of inspectors.
		 * */
		public static function createInspectorsList(xml:XML):void {
			var numberOfItems:uint;
			var inspectorsLength:uint;
			var items:XMLList;
			var className:String;
			var alternativeClassName:String;
			var alternativeClasses:XMLList;
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
			var altItem:XML;
			var inspectorItems:XMLList;
			var inspector:XML;
			var inspectableClass:InspectableClass;
			var inspectorData:InspectorData;
			
			
			// get list of inspector classes 
			items = XML(xml).item;
			
			numberOfItems = items.length();
			
			// add inspectable classes to the dictionary
			for (var i:int;i<numberOfItems;i++) {
				item = items[i];
				inspectableClass = new InspectableClass(item);
				className = inspectableClass.className;
				alternativeClasses = item..alternative;
				
				if (inspectableClassesDictionary[className]==null) {
					inspectableClassesDictionary[className] = inspectableClass;
					
					// get other classes that can use the same inspectors
					for (var k:int = 0; k < alternativeClasses.length(); k++)  {
						altItem = alternativeClasses[k];
						alternativeClassName = altItem.attribute("className");
						
						if (inspectableClassesDictionary[alternativeClassName]==null) {
							inspectableClassesDictionary[alternativeClassName] = inspectableClass;
						}
						else {
							warn("Inspectable alternative class, '" + alternativeClassName + "', was listed more than once during import.");
						}
					}
					
				}
				else {
					warn("Inspectable class, '" + className + "', was listed more than once during import.");
				}
				
			}
			
			// check that definitions exist in domain
			for each (inspectableClass in inspectableClassesDictionary) {
				
				numberOfItems = inspectableClass.inspectors.length;
				j = 0;
				
				for (var j:int;j<numberOfItems;j++) {
					inspectorData = inspectableClass.inspectors[j];
					className = inspectorData.className;
					
					if (inspectorsDictionary[className]==null) {
						
						hasDefinition = ClassUtils.hasDefinition(className);
						
						if (hasDefinition) {
							classType = ClassUtils.getDefinition(className);
						}
						else {
							error("Inspector class not found: " + className + " Add a reference to RadiateReferences. Also check the spelling.");
						}
						
						// not passing in classType now since we may load it in later dynamically
						addInspectorType(inspectorData.name, className, null, inspectorData.icon, defaults);
					}
					else {
						//warn("Inspector class: " + className + ", is already in the dictionary");
					}
				}
			}
			
			// inspectorsInstancesDictionary should now be populated
		}
		
		/**
		 * Get container for class
		 **/
		public static function getInspectorContainer(target:Object):IVisualElementContainer {
			var inspectorInstance:UIComponent;
			var inspectorData:InspectorData;
			var inspectors:Array = getInspectors(target);
			var numberOfDynamicInspectors:int = inspectors.length;
			var className:String = getInspectableClassName(target);
			var contentGroup:UIComponent = inspectorContainerDictionary[className];
			
			if (contentGroup) {
				return contentGroup as IVisualElementContainer;
			}
			
			contentGroup = new VGroup();
			contentGroup.percentWidth = 100;
			
			// add and activate inspectors
			PerformanceMeter.start("Add inspectors");
			for (var i:int;i<numberOfDynamicInspectors;i++) {
				inspectorData = InspectorData(inspectors[i]);
				inspectorInstance = inspectorData.getNewInstance() as UIComponent;
				
				if (inspectorInstance) {
					//PerformanceMeter.start("Adding inspector");
					//inspectorInstance.includeInLayout = false;
					IVisualElementContainer(contentGroup).addElement(inspectorInstance);
					//inspectorInstance.includeInLayout = true;
					//PerformanceMeter.stop("Adding inspector", true);
				}
			}
			PerformanceMeter.stop("Add inspectors", true);
			
			PerformanceMeter.start("Including layout");
			//UIComponent(contentGroup).includeInLayout = true;
			//LayoutManager.getInstance().validateClient(contentGroup, true);
			PerformanceMeter.stop("Including layout", true);
			
			inspectorContainerDictionary[className] = contentGroup;
			
			return contentGroup as IVisualElementContainer;
		}
	}
}