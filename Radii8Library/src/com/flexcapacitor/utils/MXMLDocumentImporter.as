
	

package com.flexcapacitor.utils {
	
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.ImportOptions;
	import com.flexcapacitor.model.IssueData;
	import com.flexcapacitor.model.SourceData;
	import com.flexcapacitor.model.ValuesObject;
	import com.flexcapacitor.utils.supportClasses.ComponentDefinition;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import flash.system.ApplicationDomain;
	import flash.utils.getTimer;
	
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;

	
	/**
	 * Import MXML into a IDocument. Basic support of creating components and apply properties and styles. 
	 * */
	public class MXMLDocumentImporter extends DocumentTranscoder {

		/**
		 * Import the MXML document into the IDocument. 
		 * */
		public function MXMLDocumentImporter() {
			supportsImport = true;
		}
		
		//override public function importare(iDocument:IDocument, id:String, container:IVisualElement) {
		override public function importare(source:*, document:IDocument, componentDescription:ComponentDescription = null, options:ImportOptions = null):SourceData {
			var componentDefinition:ComponentDefinition;
			var sourceData:SourceData;
			var container:IVisualElementContainer;
			var rootNodeName:String = "RootWrapperNode";
			var elName:String;
			var root:String;
			var timer:int;
			var mxml:XML;
			var updatedCode:String;
			var isValid:Boolean;
			
			
			// VALID XML BEFORE IMPORTING
			isValid = XMLUtils.isValidXML(source);
			sourceData = new SourceData();
			
			if (!isValid) {
				// not valid so try adding namespaces and a root node
				root = "<"+rootNodeName + " " + defaultNamespaceDeclarations + ">";
				updatedCode = root + "\n" + source + "\n</"+rootNodeName+">";
				
				isValid = XMLUtils.isValidXML(updatedCode);
				
				if (!isValid) {
					//codeToParse = updatedCode;
					Radiate.error("Could not parse code source code. " + XMLUtils.validationErrorMessage);
					Radiate.editImportingCode(updatedCode);
					sourceData.errors = [IssueData.getIssue(XMLUtils.validationError.name, XMLUtils.validationErrorMessage)];
					return sourceData;
				}
			}
			else {
				updatedCode = source;
			}
			
			
			// SHOULD BE VALID - TRY IMPORTING INTO XML OBJECT
			try {
				mxml = new XML(updatedCode);
			}
			catch (error:Error) {
				Radiate.error("Could not parse code " + document.name + ". " + error.message);
			}
			
			// IF VALID XML OBJECT BEGIN IMPORT 
			if (mxml) {
				elName = mxml.localName();
				timer = getTimer();
				container = componentDescription.instance as IVisualElementContainer;
				
				// set import to true to prevent millions of events from dispatching all over the place
				Radiate.importingDocument = true;
				
				// TODO this is a special case we check for since 
				// we should have already created the application by now
				// we should handle this case before we get here (pass in the children of the application xml not application itself)
				if (elName=="Application") {
					componentDefinition = Radiate.getDynamicComponentType(elName);
					Radiate.setAttributesOnComponent(document.instance, mxml, componentDefinition);
				}
				else {
					createChildFromNode(mxml, container, document);
				}
				
				// LOOP THROUGH EACH CHILD NODE
				for each (var childNode:XML in mxml.children()) {
					createChildFromNode(childNode, container, document, 1);
				}
			}
			
			Radiate.importingDocument = false;
			
			// using importing document flag it goes down from 5 seconds to 1 second
			//Radiate.info("Time to import: " + (getTimer()-timer));
			
			sourceData.source = source;
			
			return sourceData;
		}

		/**
		 * Create child from node
		 * */
		private function createChildFromNode(node:XML, parent:Object, iDocument:IDocument, depth:int = 0):IVisualElement {
			var elementName:String = node.localName();
			var domain:ApplicationDomain = ApplicationDomain.currentDomain;
			var componentDefinition:ComponentDefinition = Radiate.getDynamicComponentType(elementName);
			var includeChildren:Boolean = true;
			var className:String;
			var classType:Class;
			var componentInstance:Object;
			
			if (componentDefinition==null) {
				
			}
			
			className = componentDefinition ? componentDefinition.className :null;
			classType = componentDefinition ? componentDefinition.classType as Class :null;
			
			
			if (componentDefinition==null && elementName!="RootWrapperNode") {
				//message += " Add this class to Radii8LibrarySparkAssets.sparkManifestDefaults or add the library to the project that contains it.";
				var message:String = "Could not find definition for " + elementName + ". The document will be missing elements.";
				Radiate.error(message);
				return null;
			}
			
			// classes to look into for decoding XML
			// XMLDecoder, SchemaTypeRegistry, SchemaManager, SchemaProcesser
			
			
			// special case for radio button group
			/*var object:* = SchemaTypeRegistry.getInstance().getClass(classType);
			var object2:* = SchemaTypeRegistry.getInstance().getClass(elementName);
			var object3:* = SchemaTypeRegistry.getInstance().getClass(node);
			var sm:mx.rpc.xml.SchemaManager = new mx.rpc.xml.SchemaManager();
			
			sm.addNamespaces({s:new Namespace("s", "library://ns.adobe.com/flex/spark")});
			var o:Object = sm.unmarshall(node);
			
			var q:QName = new QName(null, elementName);*/
			//var object2:* = SchemaTypeRegistry.getInstance().registerClass(;
			
	
			if (componentDefinition!=null) {
				
				// we should NOT be setting defaults on import!!!
				// defaults should only be used when creating NEW components
				// when you save the document the first time the properties will be saved
				// so the next time you import you shouldn't need to set them again
				// the user may have even removed the defaults
				
				//instance = Radiate.createComponentForAdd(document, componentDefinition, true);
				componentInstance = Radiate.createComponentToAdd(iDocument, componentDefinition, false);
				//Radiate.info("MXML Importer adding: " + elementName);
				
				// calling add before setting properties because some 
				// properties such as borderVisible and trackingLeft/trackingRight need to be set after 
				// the component is added (maybe)
				var valuesObject:ValuesObject = Radiate.getPropertiesStylesFromNode(componentInstance, node, componentDefinition);
				var attributes:Array = valuesObject.attributes;
				//var typedValueObject:Object = Radiate.getTypedValueFromStyles(instance, valuesObject.values, valuesObject.styles);
				
				Radiate.addElement(componentInstance, parent, valuesObject.properties, valuesObject.styles, valuesObject.values);
				
				Radiate.removeExplictSizeOnComponent(componentInstance, node, componentDefinition, false);
				
				Radiate.updateComponentAfterAdd(iDocument, componentInstance);
				
				var lockedName:String = "library://ns.flexcapacitor.com/flex/::locked";
				
				if (attributes.indexOf(lockedName)!=-1) {
					var item:ComponentDescription = iDocument.getItemDescription(componentInstance);
					item.locked = valuesObject.values[lockedName];
				}
				
				// might want to get a properties object from the attributes 
				// and then use that in the add element call above 
				//Radiate.setAttributesOnComponent(instance, node, componentDefinition, false);
				//HistoryManager.mergeLastHistoryEvent(document);
			}
			
			
			if (includeChildren) {
				
				for each (var childNode:XML in node.children()) {
					createChildFromNode(childNode, componentInstance, iDocument, depth+1);
				}
			}
			
			return componentInstance as IVisualElement;
		}
	}
}
