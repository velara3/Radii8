
package com.flexcapacitor.utils {
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IDocumentExporter;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import spark.components.Application;
	
	/**
	 * Exports a document to MXML
	 * */
	public class MXMLDocumentExporter extends DocumentExporter implements IDocumentExporter {
		
		public function MXMLDocumentExporter() {
		
		}
		
		/**
		 * @inheritDoc
		 * */
		public function export(iDocument:IDocument, target:ComponentDescription = null, reference:Boolean = false):* {
			var output:String;
			var XML1:XML;
			
			if (!target) {
				target = iDocument.componentDescription;
			}
			
			if (!reference) {
				output = getMXMLOutputString(iDocument, target);
			}
			else {
				XML1 = <document />;
				XML1.@host = iDocument.host;
				XML1.@id = iDocument.id;
				XML1.@name = iDocument.name;
				XML1.@uid = iDocument.uid;
				XML1.@uri = iDocument.uri;
				output = XML1.toXMLString();
			}
			
			return output;
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
		 * TODO: This should be using XML and namespaces. 
		 * */
		public function getMXMLOutputString(iDocument:IDocument, component:ComponentDescription, addLineBreak:Boolean = false, tabs:String = ""):String {
			if (component.instance is Application) {
				getAppliedPropertiesFromHistory(iDocument, component);
			}
			var properties:Object = component.properties;
			var styles:Object = component.styles;
			var componentChild:ComponentDescription;
			var name:String = component.name;
			var output:String = "";
			var outputValue:String = "";
			var namespaces:String;
			var value:*;
			
			
			for (var propertyName:String in properties) {
				value = properties[propertyName];
				if (value===undefined || value==null) {
					continue;
				}
				output += " ";
				
				// we should be converting objects into tags
				if (value is Object) {
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
				output += styleName + "=\"" + XMLUtils.getAttributeSafeString(Object(styles[styleName]).toString()) + "\"";
			}
			
			if (name) {
				if (component.instance is Application) {
					name = "Application";
					namespaces = " xmlns:fx=\"http://ns.adobe.com/mxml/2009\"";
					namespaces += " xmlns:s=\"library://ns.adobe.com/flex/spark\"";
					output = namespaces + output;
				}
				// we are not handling namespaces here - we could use component descriptor
				output = tabs + "<s:" + name + output;
				
				if (component.children && component.children.length>0) {
					output += ">\n";
					
					for (var i:int;i<component.children.length;i++) {
						componentChild = component.children[i];
						// we should get the properties and styles from the 
						// the component description
						getAppliedPropertiesFromHistory(iDocument, componentChild);
						output += getMXMLOutputString(iDocument, componentChild, false, tabs + "\t");
					}
					
					output += tabs + "</s:" + name + ">\n";
				}
				else {
					 output += "/>\n";
				}
			}
			else {
				output = "";
			}
			
			isValid = XMLUtils.isValidXML(output);
			
			if (!isValid) {
				error = XMLUtils.validationError;
				errorMessage = XMLUtils.validationErrorMessage;
			}
			else {
				error = null;
				errorMessage = null;
			}
			
			return output;
		}
		
	
	}
}