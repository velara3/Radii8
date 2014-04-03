
package com.flexcapacitor.model {
	
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.MXMLDocumentExporter;
	import com.flexcapacitor.utils.MXMLImporter;
	import com.flexcapacitor.utils.XMLUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.core.IVisualElement;
	import mx.utils.UIDUtil;
	
	
	
	/**
	 * Document model
	 * */
	public class Document extends DocumentData implements IDocument, ISavable {
		
		/**
		 * Constructor
		 * */
		public function Document(target:IEventDispatcher=null) {
			super(target);
			uid = UIDUtil.createUID();
		}

		
		/**
		 * URL to get code
		 * */
		public var URL:String;
		
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
		
		private var _scale:Number = 1;

		/**
		 * Scale of document
		 * */
		public function get scale():Number {
			return _scale;
		}

		/**
		 * Scale of document
		 * */
		public function set scale(value:Number):void {
			_scale = value;
			
			if (instance) {
				DisplayObject(instance).scaleX = value;
				DisplayObject(instance).scaleY = value;
			}
		}

		private var _projectID:String;

		/**
		 * ID of project. Can be part of multiple projects so we may need to change this. 
		 * */
		public function get projectID():String {
			return _projectID;
		}

		/**
		 * @private
		 */
		public function set projectID(value:String):void {
			_projectID = value;
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
		
		private var _containerType:Class;

		/**
		 * @inheritDoc
		 * */
		public function get containerType():Class {
			return _containerType;
		}

		public function set containerType(value:Class):void {
			_containerType = value;
		}

		private var _containerTypeName:String;

		/**
		 * @inheritDoc
		 * */
		public function get containerTypeName():String {
			return _containerTypeName;
		}

		public function set containerTypeName(value:String):void {
			_containerTypeName = value;
		}

		
		/**
		 * @private
		 * */
		private var _componentDescription:ComponentDescription;

		/**
		 * Reference to the component description
		 * */
		public function get componentDescription():ComponentDescription {
			if (!_componentDescription) {
				
				if (instance) {
					_componentDescription = DisplayObjectUtils.getComponentDisplayList2(instance, null, 0, descriptionsDictionary);
				}
			}
			// com.flexcapacitor.utils.supportClasses.ComponentDescription (@1234c3539)
			_componentDescription = DisplayObjectUtils.getComponentDisplayList2(instance, null, 0, descriptionsDictionary);
			
			return _componentDescription;
		}

		/**
		 * @private
		 */
		public function set componentDescription(value:ComponentDescription):void {
			_componentDescription = value;
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

		
		private var _historyIndex:int = -1;

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
			
			if (value != lastSavedHistoryIndex) {
				isChanged = true;
			}
			else {
				isChanged = false;
			}
		}

		
		private var _lastSavedHistoryIndex:int = -1;

		/**
		 * Index of event in history when the document was last saved
		 * */
		public function get lastSavedHistoryIndex():int {
			return _lastSavedHistoryIndex;
		}

		/**
		 * @private
		 */
		[Bindable]
		public function set lastSavedHistoryIndex(value:int):void {
			_lastSavedHistoryIndex = value;
			
			isChanged = historyIndex!=value;
		}
		
		private var _isPreviewOpen:Boolean;

		/**
		 * @inheritDoc
		 * */
		public function get isPreviewOpen():Boolean {
			return _isPreviewOpen;
		}

		public function set isPreviewOpen(value:Boolean):void {
			_isPreviewOpen = value;
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
		
		private var _documentData:IDocumentData;

		/**
		 * Reference to the last saved data that was loaded in
		 * */
		public function get documentData():IDocumentData {
			return _documentData;
		}

		/**
		 * @private
		 */
		public function set documentData(value:IDocumentData):void {
			_documentData = value;
		}
		
		/**
		 * @inheritDoc
		 * */
		override public function close():void {
			super.close();
			//Radiate.log.info("Close:" + source);
			clearHistory();
		}
		
		/**
		 * Removes the history events
		 * */
		public function clearHistory():void {
			//history.refresh();
			history.removeAll();
			historyIndex = -1;
			isChanged = false;
		}
		
		/**
		 * Save 
		 * */
		override public function save(locations:String = REMOTE_LOCATION, options:Object = null):Boolean {
			var savedLocallyResult:Boolean = super.save(locations, options);
			
			lastSavedHistoryIndex = historyIndex;
			
			return savedLocallyResult;
		}
		
		

		/**
		 * 
		 * */
		override public function toString():String {
			var output:String = exporter.export(this);
			
			return output;
		}
		
		/**
		 * Exports to XML object
		 * */
		override public function toXML(representation:Boolean = false):XML {
			var output:XML = exporter.exportXML(this, representation);
			
			return output;
		}

		/**
		 * Exports an XML string.
		 * If reference is true then just returns just enough basic information to locate it. 
		 * */
		/*override public function toXMLString(reference:Boolean = false):String {
			var output:String;
			
			output = exporter.exportXMLString(this, reference);
			
			return output;
		}*/

		/**
		 * Exports an MXML string.
		 * If reference is true then just enough basic information to locate it. 
		 * */
		/*override public function toMXMLString(reference:Boolean = false):String {
			var output:String;
			
			output = internalExporter.exportXMLString(this, reference);
			
			return output;
			
		}*/
		
		/**
		 * Exports a string
		 * */
		/*public function export(exporter:IDocumentExporter):String {
			var output:String = exporter.exportXMLString(this);
			
			return output;
			
		}*/
		
		/**
		 * Get basic document data
		 * */
		override public function unmarshall(data:Object):void {
			super.unmarshall(data); 
			
			if (data is IDocumentData) {
				//documentData = IDocumentData(data);// this and
				//IDocumentData(data).document = this;// this should be removed just have references somewhere 
			}
		}
		
		/**
		 * Get source code for document. 
		 * Exporters may not work if the document is not open. 
		 * */
		override public function getSource(target:Object = null):String {
			var value:String;
			
			if (isOpen) {
				if (this.historyIndex==-1) {
					//Radiate.log.info("Document history is empty!");
				}
				
				if (isChanged || source==null || source=="") {
					value = internalExporter.export(this);
				}
				else if (source) {
					value = source;
				}
				else if (originalSource) {
					value = originalSource;
				}
				
				/*
				Radiate.log.info("is changed=" + isChanged);
				Radiate.log.info("original source null=" + (originalSource==null));
				Radiate.log.info("history length=" + history.length);
				Radiate.log.info("history index=" + historyIndex);
				Radiate.log.info("instance stage=" + (instance?instance.stage:null));
				Radiate.log.info("date saved=" + dateSaved);
				Radiate.log.info(value);*/
/*				Main Thread (Suspended)	
	com.flexcapacitor.model::Document/getSource	
	com.flexcapacitor.model::DocumentData/close	
	com.flexcapacitor.model::Document/close	
	com.flexcapacitor.controller::Radiate/closeDocument	
	com.flexcapacitor.controller::Radiate/closeProject	
	com.flexcapacitor.views.panels::ProjectInspector/closeProjectIcon_clickHandler	
	com.flexcapacitor.views.panels::ProjectInspector/__closeProjectIcon_click	
*/
				return value;
				
			}
			// return source;
			return source;
		}
		
		/**
		 * Parses the code and builds a document. 
		 * If code is null and source is set then parses source.
		 * If parent is set then imports code to the parent. 
		 * */
		public function parseSource(code:String = null, parent:IVisualElement = null):void {
			var codeToParse:String = code ? code : source;
			var currentChildren:XMLList;
			var nodeName:String;
			var child:XML;
			var xml:XML;
			var root:String;
			var isValid:Boolean;
			var rootNodeName:String = "RootWrapperNode";
			var updatedCode:String;
			
			isValid = XMLUtils.isValidXML(codeToParse);
			
			if (!isValid) {
				root = '<'+rootNodeName+ ' xmlns:fx="http://ns.adobe.com/mxml/2009" xmlns:s="library://ns.adobe.com/flex/spark" xmlns:mx="library://ns.adobe.com/flex/mx">';
				updatedCode = root + codeToParse + "</"+rootNodeName+">";
				
				isValid = XMLUtils.isValidXML(updatedCode);
				if (isValid) {
					codeToParse = updatedCode;
				}
			}
			
			// check for valid XML
			try {
				xml = new XML(codeToParse);
			}
			catch (error:Error) {
				Radiate.log.error("Could not parse code for document " + name + ". " + error.message);
			}
			
			
			if (xml) {
				// loop through each item and create an instance 
				// and set the properties and styles on it
				/*currentChildren = xml.children();
				while (child in currentChildren) {
					nodeName = child.name();
					
				}*/
				//Radiate.log.info("Importing document: " + name);
				//var mxmlLoader:MXMLImporter = new MXMLImporter( "testWindow", new XML( inSource ), canvasHolder  );
				var mxmlLoader:MXMLImporter;
				var container:IVisualElement = parent ? parent as IVisualElement : instance as IVisualElement;
				mxmlLoader = new MXMLImporter(this, "testWindow", xml, container);
				
				if (container) {
					Radiate.getInstance().setTarget(container);
				}
			}
			
			
			/*_toolTipChildren = new SystemChildrenList(this,
            new QName(mx_internal, "topMostIndex"),
            new QName(mx_internal, "toolTipIndex"));*/
			//return true;
		}
		
		/**
		 * Resets the save status after loading a document
		 * */
		public function resetSaveStatus():void {
			lastSavedHistoryIndex = historyIndex;
		}
	}
}