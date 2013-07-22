
package com.flexcapacitor.model {
	
	import com.flexcapacitor.events.HistoryEvent;
	import com.flexcapacitor.events.HistoryEventItem;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	
	
	/**
	 * Document model
	 * */
	public class Document extends EventDispatcher implements IDocument {
		
		/**
		 * Exports the document to string
		 * */
		public static var exporter:IDocumentExporter;
		
		/**
		 * Constructor
		 * */
		public function Document(target:IEventDispatcher=null) {
			super(target);
		}
		
		
		
		private var _name:String;

		/**
		 * Name of Document
		 * */
		public function get name():String {
			return _name;
		}

		/**
		 * @private
		 */
		public function set name(value:String):void {
			_name = value;
		}

		private var _project:IProject;

		/**
		 * Reference to parent project
		 * */
		public function get project():IProject {
			return _project;
		}

		/**
		 * @private
		 */
		public function set project(value:IProject):void {
			_project = value;
		}
		
		/**
		 * @private
		 * */
		private var _description:ComponentDescription;

		/**
		 * Reference to the component description
		 * */
		public function get description():ComponentDescription {
			if (!_description) {
				
				if (instance) {
					_description = DisplayObjectUtils.getComponentDisplayList2(instance, null, 0, descriptionsDictionary);
				}
			}
			
			_description = DisplayObjectUtils.getComponentDisplayList2(instance, null, 0, descriptionsDictionary);
			
			return _description;
		}

		/**
		 * @private
		 */
		public function set description(value:ComponentDescription):void {
			_description = value;
		}

		
		private var _instance:Object;

		/**
		 * Instance of document
		 * */
		public function get instance():Object {
			return _instance;
		}

		/**
		 * @private
		 */
		public function set instance(value:Object):void {
			_instance = value;
		}
		
		/**
		 * @private
		 * */
		private var _history:ArrayCollection = new ArrayCollection();

		/**
		 * History
		 * */
		public function get history():ArrayCollection {
			return _history;
		}

		/**
		 * @private
		 */
		[Bindable]
		public function set history(value:ArrayCollection):void {
			_history = value;
		}

		
		private var _historyIndex:int;

		/**
		 * Index of current event in history
		 * */
		public function get historyIndex():int {
			return _historyIndex;
		}

		/**
		 * @private
		 */
		[Bindable]
		public function set historyIndex(value:int):void {
			_historyIndex = value;
		}
		
		private var _descriptionsDictionary:Dictionary = new Dictionary(true);

		/**
		 * Reference to component description for each component instance
		 * */
		public function get descriptionsDictionary():Dictionary {
			return _descriptionsDictionary;
		}

		/**
		 * @private
		 */
		public function set descriptionsDictionary(value:Dictionary):void {
			_descriptionsDictionary = value;
		}


		/**
		 * Code
		 * */
		public var code:String;
		
		/**
		 * URL to get code
		 * */
		public var URL:String;
		
		/**
		 * Class type of document
		 * */
		public var type:Class;
		
		/**
		 * Class name of document
		 * */
		public var className:String;
		
		/**
		 * Dots per inch
		 * */
		public var DPI:int;
		
		/**
		 * Width of document
		 * */
		public var width:String;
		
		/**
		 * Height of document
		 * */
		public var height:String;

		
		override public function toString():String {
			var output:String = exporter.export(this);
			
			return output;
			
		}
		

		/**
		 * Exports to XML object
		 * */
		public function toXML():XML {
			var output:XML = exporter.exportXML(this);
			
			return output;
			
		}

		/**
		 * Exports an XML string
		 * */
		public function toXMLString():String {
			var output:String = exporter.export(this);
			
			return output;
			
		}
		
		/**
		 * Exports a string
		 * */
		public function export(exporter:IDocumentExporter):String {
			var output:String = exporter.export(this);
			
			return output;
			
		}
		
		/**
		 * Get an object that contains the properties that have been set on the component.
		 * This does this by going through the history events and checking the changes.
		 * */
		public function getAppliedPropertiesFromHistory(component:ComponentDescription, addToProperties:Boolean = true):Object {
			var historyEventItem:HistoryEventItem;
			var historyEventItems:Array;
			var historyEvent:HistoryEvent;
			var eventsLength:int;
			var propertiesObject:Object = {};
			var stylesObject:Object = {};
			var properties:Array;
			var styles:Array;
			
			// go back through the history of changes and 
			// add the properties that have been set to an object
			for (var i:int=historyIndex+1;i--;) {
				historyEvent = HistoryEvent(history.getItemAt(i));
				historyEventItems = historyEvent.historyEventItems;
				eventsLength = historyEventItems.length;
				
				for (var j:int=0;j<eventsLength;j++) {
					historyEventItem = HistoryEventItem(historyEventItems[j]);
					properties = historyEventItem.properties;
					styles = historyEventItem.styles;
		
					if (historyEventItem.targets.indexOf(component.instance)!=-1) {
						
						for each (var property:String in properties) {
							
							if (property in propertiesObject) {
								continue;
							}
							else {
								propertiesObject[property] = historyEventItem.propertyChanges.end[property];
							}
						}
						
						for each (var style:String in styles) {
							
							if (style in stylesObject) {
								continue;
							}
							else {
								stylesObject[style] = historyEventItem.propertyChanges.end[style];
							}
						}
					}
					
				}
			}
			
			component.properties = propertiesObject;
			component.styles = stylesObject;
			
			return propertiesObject;
		}
	}
}