package com.flexcapacitor.managers
{
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.tools.ITool;
	import com.flexcapacitor.utils.ClassUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.ui.MouseCursorData;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	import mx.core.UIComponent;

	/**
	 * Tools Management
	 **/
	public class ToolManager {
		
		public function ToolManager() {
			
		}
		
		/**
		 * Creates the list of tools. Read the howto.txt to see how to add 
		 * new tools. 
		 * */
		public static function createToolsList(xml:XML):void {
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
			var numberOfItems:uint;
			var attributesLength:int;
			var defaults:Object;
			var propertyName:String;
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
			var key:String;
			
			// get list of tool classes 
			items = XML(xml).tool;
			
			numberOfItems = items.length();
			
			for (var i:int;i<numberOfItems;i++) {
				item = items[i];
				
				name = String(item.id);
				className = item.attribute("class");
				inspectorClassName = item.attribute("inspector");
				cursorItems = item..cursor;
				key = item.attribute("key");
				
				includeItem = item.attribute("include")=="false" ? false : true;
				
				if (!includeItem) continue;
				
				hasDefinition = ClassUtils.hasDefinition(className);
				
				if (hasDefinition) {
					toolClassDefinition = ClassUtils.getDefinition(className);
					
					
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
					if ("getInstance" in toolClassDefinition) {
						toolInstance = toolClassDefinition.getInstance();
					}
					else {
						toolClassFactory = new ClassFactory(toolClassDefinition as Class);
						toolClassFactory.properties = defaults;
						toolInstance = toolClassFactory.newInstance();
					}
					
					
					// create inspector
					if (inspectorClassName!="") {
						hasDefinition = ClassUtils.hasDefinition(inspectorClassName);
						
						if (hasDefinition) {
							inspectorClassDefinition = ClassUtils.getDefinition(inspectorClassName);
							
							// Create tool inspector
							inspectorClassFactory = new ClassFactory(inspectorClassDefinition as Class);
							//classFactory.properties = defaults;
							inspectorInstance = inspectorClassFactory.newInstance();
							
						}
						else {
							var errorMessage:String = "Could not find inspector, '" + inspectorClassName + "' for tool, '" + className + "'. ";
							errorMessage += "You may need to add a reference to it in RadiateReferences.";
							Radiate.error(errorMessage);
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
						
						if (cursorClass==null) {
							Radiate.error("Tool cursor not found: " + cursorName);
							break;
						}
						// TypeError: Error #1007: Instantiation attempted on a non-constructor.
						// reason: class did not have the static property as described in the xml  
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
						Radiate.mouseCursors[className] = cursors;
					}
					
					// add keyboard shortcut
					
					//trace("tool cursors:", cursors);
					var toolDescription:ComponentDescription = ToolManager.addToolType(item.@id, className, toolClassDefinition, toolInstance, inspectorClassName, null, defaults, null, cursors, key);
					//trace("tool cursors:", toolDescription.cursors);
				}
				else {
					//trace("Tool class not found: " + classDefinition);
					Radiate.error("Tool class not found: " + className);
				}
				
			}
			
			// toolDescriptions should now be populated
		}
		
		/**
		 * Restores the previously selected tool.
		 * 
		 * This restores the previous selected tool.
		 * */
		public static function restoreTool(dispatchEvent:Boolean = true, cause:String = ""):void {
			if (Radiate.previousSelectedTool && Radiate.previousSelectedTool!=Radiate.selectedTool) {
				setTool(Radiate.previousSelectedTool, dispatchEvent, cause);
			}
		}
		
		
		/**
		 * Enables the selected tool
		 * @see disableTool()
		 * */
		public static function enableTool(dispatchEvent:Boolean = true, cause:String = ""):void {
			
			if (Radiate.selectedTool) {
				Radiate.selectedTool.enable();
			}
			
			if (dispatchEvent) {
				//instance.dispatchToolChangeEvent(selectedTool);
			}
			
		}
		
		/**
		 * Disables the selected tool
		 * @see enableTool()
		 * */
		public static function disableTool(dispatchEvent:Boolean = true, cause:String = ""):void {
			
			if (Radiate.selectedTool) {
				Radiate.selectedTool.disable();
			}
			
			if (dispatchEvent) {
				//instance.dispatchToolChangeEvent(selectedTool);
			}
			
		}
		
		/**
		 * Get tool description.
		 * @see getToolByType()
		 * @see getToolByName()
		 * */
		public static function getToolDescription(instance:ITool):ComponentDescription {
			var numberOfTools:int = Radiate.toolsDescriptions.length;
			var componentDescription:ComponentDescription;
			
			for (var i:int;i<numberOfTools;i++) {
				componentDescription = ComponentDescription(Radiate.toolsDescriptions.getItemAt(i));
				
				if (componentDescription.instance==instance) {
					return componentDescription;
				}
			}
			
			return null;
		}
		
		/**
		 * Get tool by name. Pass in the class name or tool name. Match is case insensitive. 
		 * List of class names are in tools-manifest-defaults.xml or radiate.toolsDescription
		 * @see getToolByType()
		 * */
		public static function getToolByName(name:String):ComponentDescription {
			var numberOfTools:int = Radiate.toolsDescriptions.length;
			var componentDescription:ComponentDescription;
			var nameLowerCase:String = name? name.toLowerCase() : null;
			
			if (name==null || name=="") return null;
			
			for (var i:int;i<numberOfTools;i++) {
				componentDescription = ComponentDescription(Radiate.toolsDescriptions.getItemAt(i));
				
				if (componentDescription.className.toLowerCase()==nameLowerCase ||
					componentDescription.name.toLowerCase()==nameLowerCase) {
					return componentDescription;
				}
			}
			
			return null;
		}
		
		/**
		 * Get tool by type.
		 * */
		public static function getToolByType(type:Class):ComponentDescription {
			var numberOfTools:int = Radiate.toolsDescriptions.length;
			var componentDescription:ComponentDescription;
			
			for (var i:int;i<numberOfTools;i++) {
				componentDescription = ComponentDescription(Radiate.toolsDescriptions.getItemAt(i));
				
				if (componentDescription.classType==type) {
					return componentDescription;
				}
			}
			
			return null;
		}
		
		/**
		 * Save current tool
		 * */
		public static function saveCurrentTool():void {
			Radiate.previousSelectedTool = Radiate.selectedTool;
		}
		
		/**
		 * Sets the selected tool to the tool passed in
		 * */
		public static function setTool(value:ITool, dispatchEvent:Boolean = true, cause:String = ""):void {
			var previousTool:ITool = Radiate.selectedTool;
			
			if (previousTool) {
				previousTool.disable();
			}
			
			Radiate.selectedTool = value;
			
			if (value) {
				value.enable();
			}
			
			if (dispatchEvent) {
				Radiate.dispatchToolChangeEvent(value);
			}
			
		}
		
		/**
		 * Add the named tool class to the list of available tools.
		 * 
		 * Not sure if we should create an instance here or earlier or later. 
		 * */
		public static function addToolType(name:String, className:String, classType:Object, instance:ITool, 
										   inspectorClassName:String, icon:Object = null, defaultProperties:Object=null, 
										   defaultStyles:Object=null, cursors:Dictionary = null, key:String = null):ComponentDescription {
			
			var definition:ComponentDescription;
			var toolsDescriptions:ArrayCollection = Radiate.toolsDescriptions;
			var numberOfTools:uint = toolsDescriptions.length;
			var item:ComponentDescription;
			
			for (var i:uint;i<numberOfTools;i++) {
				item = toolsDescriptions.getItemAt(i) as ComponentDescription;
				
				// check if it exists already
				if (item && item.classType==classType) {
					return item;
					//return false;
				}
			}
			
			definition = new ComponentDescription();
			
			definition.name 			= name;
			definition.icon 			= icon;
			definition.className 		= className;
			definition.classType 		= classType;
			definition.defaultStyles 	= defaultStyles;
			definition.defaultProperties = defaultProperties;
			definition.instance 		= instance;
			definition.inspectorClassName = inspectorClassName;
			definition.cursors 			= cursors;
			definition.key 				= key;
			
			toolsDescriptions.addItem(definition);
			
			return definition;
		}
		
		/**
		 * Shows the tool layer if it's been hidden
		 * */
		public static function showToolsLayer():void {
			
			if (DocumentManager.toolLayer) {
				Object(DocumentManager.toolLayer).visible = true;
			}
		}
		
		/**
		 * Hides the tool layer if it's visible
		 * */
		public static function hideToolsLayer():void {
			
			if (DocumentManager.toolLayer) {
				Object(DocumentManager.toolLayer).visible = false;
			}
		}
		
		/**
		 * Helper method to get the ID of the mouse cursor by name.
		 * */
		public static function getMouseCursorID(tool:ITool, name:String = "Cursor"):String {
			var component:ComponentDescription = getToolDescription(tool);
			
			
			if (component.cursors && component.cursors[name]) {
				return component.cursors[name].id;
			}
			
			return null;
		}
	}
}