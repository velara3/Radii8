
package com.flexcapacitor.utils {
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.model.ExportOptions;
	import com.flexcapacitor.model.FileInfo;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IDocumentExporter;
	import com.flexcapacitor.model.ImageData;
	import com.flexcapacitor.model.IssueData;
	import com.flexcapacitor.model.SourceData;
	import com.flexcapacitor.utils.supportClasses.ComponentDefinition;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	import com.flexcapacitor.utils.supportClasses.XMLValidationInfo;
	
	import flash.display.BitmapData;
	import flash.xml.XMLNode;
	import flash.xml.XMLNodeType;
	
	import spark.components.Application;
	import spark.components.Image;
	import spark.primitives.BitmapImage;
	
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	
	/**
	 * Exports a document to MXML
	 * */
	public class MXMLDocumentExporter extends DocumentTranscoder implements IDocumentExporter {
		
		public function MXMLDocumentExporter(definitons:Array = null) {
			supportsExport = true;
			language = "MXML";
			
			if (definitions) {
				this.definitions = definitions;
			}
		}
		
		public var xmlEncoder:SimpleXMLEncoder;
		
		/**
		 * Sets styles inline
		 * */
		public var useInlineStyles:Boolean;
		
		/**
		 * Any styles not set inline are placed in an external stylesheet
		 * */
		public var useExternalStylesheet:Boolean;
		/**
		 * Default file extension. Default is mxml. 
		 * This can be changed by setting the export options.
		 * */
		public var fileExtension:String = "mxml";
		
		public var stylesheets:String;
		
		public var template:String;
		
		public var markup:String = "";
		
		public var styles:String = "";
		
		/**
		 * The XML document used when creating new nodes
		 * */
		public var xml:XML;
		
		/**
		 * The parent XMLNode used when creating new nodes
		 * */
		public var xmlParentNode:XMLNode;
		
		/**
		 * Styles added by users 
		 * */
		public var userStyles:String;
		
		/**
		 * @inheritDoc
		 * */
		override public function export(document:IDocument, componentDescription:ComponentDescription = null, parameterOptions:ExportOptions = null, dispatchEvents:Boolean = false):SourceData {
			var output:String;
			var files:Array = [];
			var file:FileInfo;
			var pageOutput:String = "";
			var bodyContent:String;
			var sourceData:SourceData;
			var warningData:IssueData;
			var stylesheetLinks:String;
			var validationInfo:XMLValidationInfo;
			
			errors = [];
			warnings = [];
			styles = "";
			markup = "";
			template = "";
			
			///////////////////////
			// SET OPTIONS
			///////////////////////
			
			if (parameterOptions) {
				savePresets();
				applyPresets(parameterOptions);
			}
			
			
			///////////////////////
			// GET SOURCE CODE
			///////////////////////
			
			if (!componentDescription) {
				componentDescription = document.componentDescription;
			}
			
			if (document.xml) {
				xml = document.xml;
			}
			else {
				xml = getDefaultDocumentXML();
			}
			
			if (xmlParentNode==null) {
				xmlParentNode = new XMLNode(XMLNodeType.DOCUMENT_TYPE_NODE, "<root/>");
			}
			
			if (document.isOpen) {
				markup = getMXMLOutputString(document, componentDescription);
			}
			else {
				warningData = IssueData.getIssue("Document is not open", "At this time you must open the document to export");
				warnings.push(warningData);
			}
			
			if (styles==null) {
				styles = "";
			}
			
			// add user styles
			if (userStyles) {
				styles += "\n" + userStyles;
			}
			
			// wrap CSS with style tags
			// when not inline and not external
			if (!useExternalStylesheet && styles!="") {
				bodyContent = markup + "\n" + wrapStylesInTags(styles);
			}
			else {
				bodyContent = markup;
			}
			
			// replace content
			if (template) {
				pageOutput = replaceContentToken(template, bodyContent);
			}
			else {
				pageOutput = bodyContent;
			}
			
			// replace title
			pageOutput = replacePageTitleToken(pageOutput, document.name);
			
			// replace scripts
			pageOutput = pageOutput.replace(scriptsToken, "");
			
			
			// styles
			if (useExternalStylesheet) {
				file = new FileInfo();
				file.contents = styles;
				file.fileName = document.name;
				file.fileExtension = "css";
				files.push(file);
				
				// create link to stylesheet
				stylesheetLinks = getExternalStylesheetLink(file.getFullFileURI());
				
				pageOutput = replaceStylesheetsToken(pageOutput, stylesheetLinks, false);
			}
			
			validationInfo = XMLUtils.validateXML(pageOutput);
			
			if (validationInfo && !validationInfo.valid) {
				warningData = IssueData.getIssue("Possibly Invalid Markup", validationInfo.internalErrorMessage);
				warnings.push(warningData);
			}
			else {
				error = null;
				errorMessage = null;
			}
			
			if (createFiles) {
				file = new FileInfo();
				file.contents = pageOutput;
				file.fileName = document.name;
				file.fileExtension = fileExtension;
				files.push(file);
			}
			
			sourceData = new SourceData();
			
			sourceData.markup = markup;
			sourceData.styles = styles;
			sourceData.source = pageOutput;
			sourceData.files = files;
			sourceData.errors = errors;
			sourceData.warnings = warnings;
			
			if (parameterOptions) {
				restorePreviousPresets();
			}
			
			return sourceData;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function exportXML(document:IDocument, reference:Boolean = false):XML {
			return null;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function exportJSON(document:IDocument, reference:Boolean = false):JSON {
			return null;
		}
	
		/**
		 * Gets the formatted MXML output from a component. 
		 * TODO: This should be using namespaces an XML object
		 * */
		public function getMXMLOutputString(iDocument:IDocument, componentDescription:ComponentDescription, addLineBreak:Boolean = false, tabs:String = ""):String {
			var validationInfo:XMLValidationInfo;
			var properties:Object;
			var styles:Object;
			var events:Object;
			var componentChild:ComponentDescription;
			var componentDefinition:ComponentDefinition;
			var childNodes:Array = [];
			var className:String;
			var output:String = "";
			var outputValue:String = "";
			var namespaces:String;
			var numberOfChildren:int;
			var value:*;
			var warningData:IssueData;
			var errorData:IssueData;
			var childNodesValues:Object;
			var childNodeNames:Array = [];
			var xmlNode:XMLNode;
			
			if (exportFromHistory) {
				getAppliedPropertiesFromHistory(iDocument, componentDescription);
			}
			
			componentDefinition = componentDescription.componentDefinition;
			
			if (!componentDefinition) {
				componentDefinition = getComponentDefinition(componentDescription.className);
			}
			
			//exportChildDescriptors = componentDescription.exportChildDescriptors;
			
			if (exportChildDescriptors==false || componentDescription.exportChildDescriptors==false) {
				//contentToken = "";
			}
			
			properties = componentDescription.properties;// ? componentDescription.properties : {};
			styles = componentDescription.styles;// ? componentDescription.styles : {};
			events = componentDescription.events;// ? componentDescription.events : {};
			className = componentDescription.className;
			
			// we need to make sure there is always a component definition below
			// checking for null at the moment
			if (componentDefinition) {
				childNodes = componentDefinition.childNodes;
			}
			
			childNodesValues = {};
			//childNodeValueObject 	= XMLUtils.getChildNodesValueObject(node);
			const TEXT_FLOW:String = "textFlow";
			const FILTERS:String = "filters";
			const HTML_OVERRIDE:String = "htmlOverride";
			
			// properties
			for (var propertyName:String in properties) {
				value = properties[propertyName];
				
				if (value===undefined || value===null) {
					continue;
				}
				
				// set later as a child node
				if (childNodes.indexOf(propertyName)!=-1) {
					childNodesValues[propertyName] = value;
					childNodeNames.push(propertyName);
					
					
					if (propertyName==TEXT_FLOW) {
						//value = TextConverter.export(value, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
						value = TextConverter.export(value, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
						
						if (value) {
							value = addNamespaceToTextFlow(value);
							value = XML(value).toXMLString();
						}
						
						childNodesValues[propertyName] = value;
					}
					
					if (propertyName==FILTERS) {
						//value = TextConverter.export(value, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
						value = TextConverter.export(value, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.XML_TYPE) as XML;
						
						xmlEncoder = new SimpleXMLEncoder();
						
						//xmlNode = xmlEncoder.encodeValue(value, null, xmlParentNode);
						//output += xmlNode.toString();
						if (value) {
							value = addNamespaceToTextFlow(value);
							value = XML(value).toXMLString();
						}
						
						childNodesValues[propertyName] = value;
					}
					
					continue;
				}
				
				output += " ";
				
				// TODO REFACTOR
				// add support to check for image source tags. if [object BitmapData] then we need 
				// an error or warning or embed the data
				
				// TODO we should be converting objects into tags
				if (value is Object) {
					// get a class exporter / dictionary - for example register "dataProvider" exporter 
					
					outputValue = XMLUtils.getAttributeSafeString(Object(value).toString());
					output += propertyName + "=\"" + outputValue + "\"";
					
				}
				else {
					output += propertyName + "=\"" + XMLUtils.getAttributeSafeString(Object(value).toString()) + "\"";
				}
			}
			
			// styles
			for (var styleName:String in styles) {
				value = styles[styleName];
				
				if (value===undefined || value==null) {
					continue;
				}
				
				// set later as a child node
				if (childNodes.indexOf(styleName)!=-1) {
					childNodesValues[styleName] = value;
					continue;
				}
				
				output += " ";
				// we could be using XML itself to set values. It should encode as necessary
				// todo: Refactor
				output += styleName + "=\"" + XMLUtils.getAttributeSafeString(Object(styles[styleName]).toString()) + "\"";
			}
			
			
			// adding extra attributes
			// refactor
			
			if (componentDescription.htmlOverride) {
				childNodeNames.push(HTML_OVERRIDE);
				childNodesValues[HTML_OVERRIDE] = componentDescription.htmlOverride;
			}
			
			if (componentDescription.locked) {
				output += " ";
				output += fcNamespace + ":" + "locked=\"true\"";
			}
			
			if (componentDescription.name!=componentDescription.className) {
				output += " ";
				output += fcNamespace + ":" + "name=\"" + componentDescription.name + "\"";
			}
			
			// maybe change this to htmlUserStyles and use fcNamespace
			if (componentDescription.userStyles) {
				output += " ";
				output += htmlNamespace + ":" + "style=\"" + XMLUtils.getAttributeSafeString(componentDescription.userStyles) + "\"";
			}
			
			if (componentDescription.convertElementToImage) {
				output += " ";
				output += fcNamespace + ":" + "convertToImage=\"" + componentDescription.convertElementToImage + "\"";
			}
			
			if (componentDescription.createBackgroundSnapshot) {
				output += " ";
				output += fcNamespace + ":" + "createBackgroundSnapshot=\"" + componentDescription.createBackgroundSnapshot + "\"";
			}
			
			if (componentDescription.wrapWithAnchor) {
				output += " ";
				output += fcNamespace + ":" + "wrapWithAnchor=\"" + componentDescription.wrapWithAnchor + "\"";
				
				if (componentDescription.anchorURL) {
					output += " ";
					output += fcNamespace + ":" + "anchorURL=\"" + componentDescription.anchorURL + "\"";
				}
				
				if (componentDescription.anchorTarget) {
					output += " ";
					output += fcNamespace + ":" + "anchorTarget=\"" + componentDescription.anchorTarget + "\"";
				}
			}
			
			if (componentDescription.htmlTagName) {
				output += " ";
				output += fcNamespace + ":" + "htmlTagName=\"" + componentDescription.htmlTagName + "\"";
			}
			
			if (componentDescription.instance is Image || componentDescription.instance is BitmapImage) {
				
				if (componentDescription.instance.source is BitmapData) {
					var imageData:ImageData = Radiate.getImageDataFromBitmapData(componentDescription.instance.source);
					if (imageData && imageData.uid) {
						output += " ";
						output += fcNamespace + ":" + "bitmapDataId=\"" +imageData.uid + "\"";
					}
					
					warningData = IssueData.getIssue("Image data was not uploaded", "If you don't upload the image it will not be visible online.");
					warnings.push(warningData);
				}
			}
			
			if (className) {
				if (componentDescription.instance is Application) {
					className = "Application";
					namespaces = defaultNamespaceDeclarations;
					output = output + " " + fcNamespace + ":version=\"" + version + "\"";
					output = namespaces + output;
					
				}
				
				if (output.indexOf(" ")==0) {
					output = output.substr(1);
				}
				
				// we are not handling namespaces here - we could use component descriptor / component definitions
				output = tabs + "<" + sparkNamespace + ":" + className + " " + output;
				
				if ((exportChildDescriptors && 
					componentDescription.children && 
					componentDescription.children.length>0) || 
					childNodeNames.length) {
					
					output += ">\n";
					
					var childNode:String
					var childNodeNamespace:String;
					var useCDATA:Boolean;
					
					for (propertyName in childNodesValues) {
						value = childNodesValues[propertyName];
						
						if (propertyName==HTML_OVERRIDE) {
							childNodeNamespace = htmlNamespace;
							useCDATA = true;
						}
						else {
							childNodeNamespace = sparkNamespace;
							useCDATA = false;
						}
						
						childNode = tabs + "\t" + "<" + childNodeNamespace + ":" + propertyName + ">";
						
						// we would want to use a Encoder class - maybe redo the SimpleXMLEncoder
						// using E4X instead of original Flash XML classes
						// maybe add converters for each child node
						
						//xmlEncoder = new SimpleXMLEncoder(null);
						
						//xmlNode = xmlEncoder.encodeValue(value, null, xmlParentNode);
						//output += xmlNode.toString();
						
						value = StringUtils.indent(value.toString(), tabs + "\t\t");
						
						if (useCDATA) {
							output += childNode + "<![CDATA[\n" + value.toString() + "]]>\n";
							childNode = tabs + "\t" + "</" + childNodeNamespace + ":" + propertyName + ">";
						}
						else {
							output += childNode + "\n" + value.toString() + "\n";
							childNode = tabs + "\t" + "</" + childNodeNamespace + ":" + propertyName + ">";
						}
						
						output += childNode + "\n";
						
					}
					
					numberOfChildren = componentDescription.children ? componentDescription.children.length : 0;
					
					for (var i:int;i<numberOfChildren;i++) {
						componentChild = componentDescription.children[i];
						// we should get the properties and styles from the 
						// the component description
						if (exportFromHistory) {
							getAppliedPropertiesFromHistory(iDocument, componentChild);
						}
						output += getMXMLOutputString(iDocument, componentChild, false, tabs + "\t");
					}
					
					output += tabs + "</" + sparkNamespace + ":" + className + ">\n";
				}
				else {
					 output += "/>\n";
				}
			}
			else {
				output = "";
			}
			
			return output;
		}
		
		public function getComponentDefinition(componentName:Object, fullyQualified:Boolean = false):ComponentDefinition {
			var definition:ComponentDefinition;
			var numberOfDefinitions:uint = definitions.length;
			var item:ComponentDefinition;
			var className:String;
			var fullyQualified:Boolean;
			
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
			
			for (var i:uint;i<numberOfDefinitions;i++) {
				item = ComponentDefinition(definitions.getItemAt(i));
				
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
			
			return item;
		}
		
		/**
		 * Wrap in Style tags
		 * */
		public function wrapStylesInTags(value:String, namespaces:String = null):String {
			var out:String;
			
			if (namespaces==null) {
				namespaces = "@namespace fc \"com.flexcapacitor.controls.*\";";
				namespaces += "@namespace s \"library://ns.adobe.com/flex/spark\";"
				namespaces += "@namespace mx \"library://ns.adobe.com/flex/mx\";"
			}
			
			out = "<" + fxNamespace + ":Style>\n" + namespaces + "\n\n" + value + "\n</" + fxNamespace + ":Style>";
			
			return out;
		}
		
		/**
		 * Gets the markup for a link to an external stylesheet
		 * <pre>
		 * &lt;Style source="styles.css" />
		 * </pre>
		 * */
		public function getExternalStylesheetLink(filePath:String):String {
			var xml:XML = new XML("<" + fxNamespace + ":Style/>");
			xml.@source = filePath;
			
			return xml.toXMLString();
		}
		
		/**
		 * Get text flow object and add the correct namespace
		 * */
		public function addNamespaceToTextFlow(value:Object):XML {
			var xml:XML = value as XML;
			var tlfNamespace:Namespace = new Namespace(tlfNamespace, tlfNamespaceURI);
			xml.removeNamespace(new Namespace(sparkNamespace, sparkNamespaceURI));
			xml.setNamespace(tlfNamespace);
			
			for each (var node:XML in xml.descendants()) {
				node.setNamespace(tlfNamespace);
				
				for each (var attribute:XML in node.attributes()) {
					attribute.setNamespace(tlfNamespace);
				}
			}
			
			return xml;
		}
	}
}