package com.flexcapacitor.managers
{
	import com.flexcapacitor.controller.Console;
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.model.DocumentData;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IProject;
	import com.flexcapacitor.model.ImportOptions;
	import com.flexcapacitor.model.SourceData;
	import com.flexcapacitor.model.TranscoderDescription;
	import com.flexcapacitor.utils.DocumentTranscoder;
	import com.flexcapacitor.utils.MXMLDocumentConstants;
	import com.flexcapacitor.utils.MXMLDocumentImporter;
	import com.flexcapacitor.utils.SVGUtils;
	import com.flexcapacitor.utils.TextFieldHTMLExporter2;
	import com.flexcapacitor.utils.XMLUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import mx.core.IVisualElement;
	
	import spark.components.Application;
	
	import flashx.textLayout.conversion.ITextImporter;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.IConfiguration;

	/**
	 * Manages importing text documents
	 **/
	public class ImportManager extends Console {
		
		public function ImportManager(s:SINGLEDOUBLE) {
			
		}
		
		public static var textFieldHTMLFormatImporter:ITextImporter;
		public static var textfieldHTMLFormatConfiguration:IConfiguration;
		
		/**
		 * Configure updated HTML exporter from TLF text flow
		 * */
		public static function setUpdatedHTMLImporterAndExporter():void {
			textFieldHTMLFormatImporter = TextConverter.getImporter(TextConverter.TEXT_FIELD_HTML_FORMAT);
			textfieldHTMLFormatConfiguration = textFieldHTMLFormatImporter.configuration;
			
			TextConverter.removeFormat(TextConverter.TEXT_FIELD_HTML_FORMAT);
			TextConverter.addFormat(TextConverter.TEXT_FIELD_HTML_FORMAT, flashx.textLayout.conversion.TextFieldHtmlImporter, TextFieldHTMLExporter2, null);
			
			textFieldHTMLFormatImporter = TextConverter.getImporter(TextConverter.TEXT_FIELD_HTML_FORMAT);
			textFieldHTMLFormatImporter.configuration = textfieldHTMLFormatConfiguration;			
		}
		
		/**
		 * Parses the code and builds a document. 
		 * If code is null and source is set then parses source.
		 * If parent is set then imports code to the parent
		 * */
		public static function parseSource(document:IDocument, code:String = null, parent:Object = null, containerIndex:int = -1, options:ImportOptions = null, dispatchEvents:Boolean = true, reportErrors:Boolean = false):SourceData {
			var codeToParse:String;
			var currentChildren:XMLList;
			var nodeName:String;
			var child:XML;
			var xml:XML;
			var root:String;
			var isValid:Boolean;
			var rootNodeName:String;
			var updatedCode:String;
			var mxmlDocumentImporter:MXMLDocumentImporter;
			var componentDescription:ComponentDescription;
			var sourceDataLocal:SourceData;
			var transcoder:TranscoderDescription;
			var importer:DocumentTranscoder;
			var message:String;
			var openPopUpOnError:Boolean;
			var radiate:Radiate = Radiate.instance;
			
			rootNodeName = MXMLDocumentConstants.ROOT_NODE_NAME;
			codeToParse = code ? code : document.source;
			
			// I don't like this here - should move or dispatch events to handle import
			transcoder = CodeManager.getImporter(CodeManager.MXML);
			importer = transcoder.importer;
			
			if (codeToParse=="" || codeToParse=="null") {
				message = "No code to parse for document, \"" + document.name + "";
				error(message);
				return null;
			}
			
			isValid = XMLUtils.isValidXML(codeToParse);
			
			if (!isValid) {
				root = "<" + rootNodeName + " " + MXMLDocumentConstants.getDefaultNamespaceDeclarations() + ">";
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
			catch (errorError:Error) {
				message = "Could not parse code for document, \"" + document.name + "\". Fix the code before you import.";
				error("Could not parse code for document, \"" + document.name + "\". \n" + errorError.message + " \nCode: \n" + codeToParse);
				
				ViewManager.openImportMXMLWindow(message, codeToParse);
			}
			
			
			if (xml) {
				// loop through each item and create an instance 
				// and set the properties and styles on it
				/*currentChildren = xml.children();
				while (child in currentChildren) {
				nodeName = child.name();
				
				}*/
				//Radiate.info("Importing document: " + name);
				//var mxmlLoader:MXMLImporter = new MXMLImporter( "testWindow", new XML( inSource ), canvasHolder  );
				
				//var container:IVisualElement = parent ? parent as IVisualElement : instance as IVisualElement;
				var container:IVisualElement = parent as IVisualElement;
				
				if (container is Application && "activate" in container) {
					Object(container).activate();
				}
				
				if (document && document.instance is Application && "activate" in document.instance) {
					Object(document.instance).activate();
				}
				
				if (parent) {
					componentDescription = document.getItemDescription(parent);
				}
				
				if (componentDescription==null) {
					componentDescription = document.componentDescription;
				}
				
				sourceDataLocal = importer.importare(codeToParse, document, componentDescription, containerIndex, options, dispatchEvents);
				
				if (container && dispatchEvents) {
					radiate.setTarget(container);
				}
				
				if (sourceDataLocal.errors && sourceDataLocal.errors.length && reportErrors) {
					Radiate.outputMXMLErrors("", sourceDataLocal.errors);
				}
			}
			
			
			/*_toolTipChildren = new SystemChildrenList(this,
			new QName(mx_internal, "topMostIndex"),
			new QName(mx_internal, "toolTipIndex"));*/
			//return true;
			
			return sourceDataLocal;
		}
		
		/**
		 * Import MXML code
		 * */
		public static function importMXMLDocument(project:IProject, iDocument:IDocument, code:String, container:Object = null, containerIndex:int = -1, name:String = null, options:ImportOptions = null, dispatchEvents:Boolean = true, reportErrors:Boolean = true):SourceData {
			var result:Object;
			var newDocument:Boolean;
			var sourceData:SourceData;
			
			if (!iDocument) {
				iDocument = DocumentManager.createDocument(name);
				newDocument = true;
				
				if (project) {
					DocumentManager.addDocument(iDocument, project);
				}
			}
			
			if (!newDocument) {
				sourceData = parseSource(iDocument, code, container, containerIndex, options, dispatchEvents, reportErrors);
				
				return sourceData;
			}
			else {
				iDocument.originalSource = code;
				iDocument.source = code;
				// we load a blank application (swf), once it's loaded, 
				// in DocumentContainer we call Radiate.parseSource(iDocument);
				result = DocumentManager.openDocument(iDocument, DocumentData.INTERNAL_LOCATION, true, dispatchEvents);
			}
			
			return sourceData;
		}
		
		/**
		 * Import SVG code
		 * */
		public static function importSVGDocument(project:IProject, iDocument:IDocument, code:String, container:Object = null, containerIndex:int = -1, name:String = null, options:ImportOptions = null, dispatchEvents:Boolean = true, reportErrors:Boolean = true):SourceData {
			var result:Object;
			var newDocument:Boolean;
			var sourceData:SourceData;
			var fxgCode:String;
			
			try {
				fxgCode = SVGUtils.convert(code);
			}
			catch (error:Error) {
				warn("Could not import SVG. " + error);
				
			}
			
			if (fxgCode) {
				sourceData = importFXGDocument(project, iDocument, fxgCode, container, containerIndex, name, options, dispatchEvents, reportErrors);
			}
			
			
			return sourceData;
		}
		
		/**
		 * Import FXG code
		 * */
		public static function importFXGDocument(project:IProject, iDocument:IDocument, code:String, container:Object = null, containerIndex:int = -1, name:String = null, options:ImportOptions = null, dispatchEvents:Boolean = true, reportErrors:Boolean = true):SourceData {
			var result:Object;
			var newDocument:Boolean;
			var sourceData:SourceData;
			
			if (!iDocument) {
				iDocument = DocumentManager.createDocument(name);
				newDocument = true;
				
				if (project) {
					DocumentManager.addDocument(iDocument, project);
				}
			}
			
			if (!newDocument) {
				sourceData = parseSource(iDocument, code, container, containerIndex, options, dispatchEvents, reportErrors);
				
				return sourceData;
			}
			else {
				iDocument.originalSource = code;
				iDocument.source = code;
				// we load a blank application (swf), once it's loaded, 
				// in DocumentContainer we call Radiate.parseSource(iDocument);
				result = DocumentManager.openDocument(iDocument, DocumentData.INTERNAL_LOCATION, true, dispatchEvents);
			}
			
			return sourceData;
		}
		
		/**
		 * Update imported code so you can import it
		 * */
		public static function editImportingCode(message:String, ...Arguments):void {
			Radiate.log.info("The document did not contain valid source code. Open the import window and edit the code or choose an earlier revision.");
		}
		
		//----------------------------------
		//  instance
		//----------------------------------
		
		public static function get instance():ImportManager
		{
			if (!_instance) {
				_instance = new ImportManager(new SINGLEDOUBLE());
			}
			return _instance;
		}
		
		public static function getInstance():ImportManager {
			return instance;
		}
		
		private static var _instance:ImportManager;
	}
}

class SINGLEDOUBLE{}