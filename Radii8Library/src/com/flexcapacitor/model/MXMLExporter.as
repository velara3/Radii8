
package com.flexcapacitor.model {
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import spark.components.Application;
	
	/**
	 * Exports to MXML
	 * */
	public class MXMLExporter implements IDocumentExporter {
		
		public function MXMLExporter() {
			
		}
		
		public function export(document:IDocument):String {
			var output:String = getMXMLOutputString(document.description);
			
			return output;
		}
		
		public function exportXML(document:IDocument):XML {
			var output:XML
			
			return output;
		}
		
		public function exportJSON(document:IDocument):JSON {
			var output:JSON;
			
			return output;
		}
	
		/**
		 * Gets the formatted MXML output from a component
		 * */
		public function getMXMLOutputString(component:ComponentDescription, addLineBreak:Boolean = false, tabs:String = ""):String {
			var properties:Object = component.properties;
			var styles:Object = component.styles;
			var componentChild:ComponentDescription;
			var name:String = component.name;
			var output:String = "";
			var namespaces:String;
			var value:*;
			
			
			for (var propertyName:String in properties) {
				value = properties[propertyName];
				if (value===undefined || value==null) continue;
				output += " ";
				output += propertyName + "=\"" + Object(properties[propertyName]).toString() + "\"";
			}
			
			for (var styleName:String in styles) {
				value = styles[styleName];
				if (value===undefined || value==null) continue;
				output += " ";
				output += styleName + "=\"" + Object(styles[styleName]).toString() + "\"";
			}
			
			if (name) {
				if (component.instance is Application) {
					name = "Application";
					namespaces = " xmlns:fx=\"http://ns.adobe.com/mxml/2009\"";
					namespaces += " xmlns:s=\"library://ns.adobe.com/flex/spark\"";
					output = namespaces + " " + output;
				}
				
				output = tabs + "<s:" + name + output;
				
				if (component.children && component.children.length>0) {
					output += ">\n";
					
					for (var i:int;i<component.children.length;i++) {
						componentChild = component.children[i];
						output += getMXMLOutputString(componentChild, false, tabs + "\t");
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
			
			return output;
		}
			
	}
}