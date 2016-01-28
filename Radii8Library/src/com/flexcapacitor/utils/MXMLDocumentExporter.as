
package com.flexcapacitor.utils {
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.model.ExportOptions;
	import com.flexcapacitor.model.FileInfo;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IDocumentExporter;
	import com.flexcapacitor.model.ImageData;
	import com.flexcapacitor.model.IssueData;
	import com.flexcapacitor.model.SourceData;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	import com.flexcapacitor.utils.supportClasses.XMLValidationInfo;
	
	import flash.display.BitmapData;
	
	import spark.components.Application;
	import spark.components.Image;
	import spark.primitives.BitmapImage;
	
	/**
	 * Exports a document to MXML
	 * */
	public class MXMLDocumentExporter extends DocumentTranscoder implements IDocumentExporter {
		
		public function MXMLDocumentExporter() {
			supportsExport = true;
			language = "MXML";
		}
		
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
		 * Styles added by users 
		 * */
		public var userStyles:String;
		
		/**
		 * @inheritDoc
		 * */
		override public function export(document:IDocument, componentDescription:ComponentDescription = null, parameterOptions:ExportOptions = null):SourceData {
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
			
			markup = getMXMLOutputString(document, componentDescription);
			
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
			var className:String;
			var output:String = "";
			var outputValue:String = "";
			var namespaces:String;
			var numberOfChildren:int;
			var value:*;
			var warningData:IssueData;
			var errorData:IssueData;
			
			if (exportFromHistory) {
				getAppliedPropertiesFromHistory(iDocument, componentDescription);
			}
			
			
			//exportChildDescriptors = componentDescription.exportChildDescriptors;
			
			if (!exportChildDescriptors) {
				//contentToken = "";
			}
			
			properties = componentDescription.properties;// ? componentDescription.properties : {};
			styles = componentDescription.styles;// ? componentDescription.styles : {};
			events = componentDescription.events;// ? componentDescription.events : {};
			className = componentDescription.className;
			
			
			for (var propertyName:String in properties) {
				value = properties[propertyName];
				if (value===undefined || value==null) {
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
			
			for (var styleName:String in styles) {
				value = styles[styleName];
				if (value===undefined || value==null) {
					continue;
				}
				output += " ";
				// we could be using XML itself to set values. It should encode as necessary Refactor
				output += styleName + "=\"" + XMLUtils.getAttributeSafeString(Object(styles[styleName]).toString()) + "\"";
			}
			
			// adding extra attributes
			// we should refactor this
			
			if (componentDescription.locked) {
				output += " ";
				output += fcNamespace + ":" + "locked=\"true\"";
			}
			
			if (componentDescription.name!=componentDescription.className) {
				output += " ";
				output += fcNamespace + ":" + "name=\"" + componentDescription.name + "\"";
			}
			
			if (componentDescription.userStyles) {
				output += " ";
				output += htmlNamespace + ":" + "style=\"" + XMLUtils.getAttributeSafeString(componentDescription.userStyles) + "\"";
			}
			
			if (componentDescription.convertElementToImage) {
				output += " ";
				output += fcNamespace + ":" + "convertToImage=\"" +componentDescription.convertElementToImage + "\"";
			}
			
			if (componentDescription.createBackgroundSnapshot) {
				output += " ";
				output += fcNamespace + ":" + "createBackgroundSnapshot=\"" +componentDescription.createBackgroundSnapshot + "\"";
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
				
				// we are not handling namespaces here - we could use component descriptor
				output = tabs + "<" + sparkNamespace + ":" + className + " " + output;
				
				if (exportChildDescriptors && componentDescription.children && componentDescription.children.length>0) {
					output += ">\n";
					numberOfChildren = componentDescription.children.length;
					
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
	}
}