
	

package com.flexcapacitor.utils {
	
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.model.ErrorData;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.ImportOptions;
	import com.flexcapacitor.model.IssueData;
	import com.flexcapacitor.model.SourceData;
	import com.flexcapacitor.model.ValuesObject;
	import com.flexcapacitor.utils.supportClasses.ComponentDefinition;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import flash.display.BitmapData;
	import flash.system.ApplicationDomain;
	import flash.utils.getTimer;
	
	import mx.core.IVisualElementContainer;
	
	import spark.components.Application;
	
	import flashx.textLayout.conversion.BaseTextLayoutExporter;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.ITextImporter;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.conversion.TextLayoutImporter;
	import flashx.textLayout.elements.IConfiguration;
	import flashx.textLayout.elements.TextFlow;

	
	/**
	 * Import MXML into a IDocument. Basic support of creating components and apply properties and styles. 
	 * Should consider moving setProperties, setStyles methods from Radiate into this class
	 * */
	public class MXMLDocumentImporter extends DocumentTranscoder {

		/**
		 * Import the MXML document into the IDocument. 
		 * */
		public function MXMLDocumentImporter() {
			supportsImport = true;
		}
		
		//override public function importare(iDocument:IDocument, id:String, container:IVisualElement) {
		override public function importare(source:*, document:IDocument, componentDescription:ComponentDescription = null, options:ImportOptions = null, dispatchEvents:Boolean = false):SourceData {
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
			var codeWasWrapped:Boolean;
			
			errors = [];
			warnings = [];
			
			newComponents = [];
			
			source = StringUtils.trim(source);
			
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
					Radiate.editImportingCode(updatedCode); // dispatch event instead or return 
					sourceData.errors = [IssueData.getIssue(XMLUtils.validationError.name, XMLUtils.validationErrorMessage)];
					return sourceData;
				}
				
				codeWasWrapped = true;
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
			
			if (componentDescription==null) {
				componentDescription = document.componentDescription;
			}
			
			// IF VALID XML OBJECT BEGIN IMPORT 
			if (mxml) {
				elName = mxml.localName();
				timer = getTimer();
				container = componentDescription.instance as IVisualElementContainer;
				
				// set import to true to prevent millions of events from dispatching all over the place
				// might want to check on this - events are still getting dispatched 
				// try - doNotAddEventsToHistory
				Radiate.importingDocument = true;
				//HistoryManager.doNotAddEventsToHistory = false;
				// also check moveElement
				
				if (removeAllOnImport) {
					
					// TypeError: Error #1034: Type Coercion failed: cannot convert application@3487f91a80a1 to spark.components.Application.
					// loading an application from different sdk causes cannot convert error
					if ("removeAllElements" in document.instance) {
						Object(document.instance).removeAllElements();
					}
				}
				
				// TODO this is a special case we check for since 
				// we should have already created the application by now
				// we should handle this case before we get here (pass in the children of the application xml not application itself)
				if (elName=="Application" || elName=="WindowedApplication") {
					//componentDefinition = Radiate.getDynamicComponentType(elName);
					//Radiate.setAttributesOnComponent(document.instance, mxml, componentDefinition);
					createChildFromNode(mxml, container, document, 0, document.instance);
				}
				else {
					
					if (elName==rootNodeName || codeWasWrapped) {
						for each (var childNode:XML in mxml.children()) {
							createChildFromNode(childNode, container, document, 0);
						}
					}
					else {
						createChildFromNode(mxml, container, document);
					}
				}
				
				
				// LOOP THROUGH EACH CHILD NODE
				// i think this is done above - commenting out this section
				
				//for each (var childNode:XML in mxml.children()) {
				//	createChildFromNode(childNode, container, document, 1);
				//}
			}
			
			Radiate.importingDocument = false;
			//HistoryManager.doNotAddEventsToHistory = true;
			
			// using importing document flag it goes down from 5 seconds to 1 second
			//Radiate.info("Time to import: " + (getTimer()-timer));
			
			sourceData.source = source;
			sourceData.targets = newComponents.slice();
			sourceData.errors = errors;
			sourceData.warnings = warnings;
			
			if (newComponents && newComponents.length) {
				sourceData.componentDescription = document.getItemDescription(newComponents[0]);
				newComponents = null;
			}
			
			
			return sourceData;
		}

		/**
		 * Create child from node
		 * */
		private function createChildFromNode(node:XML, parent:Object, iDocument:IDocument, depth:int = 0, componentInstance:Object = null):Object {
			var elementName:String;
			var qualifiedName:QName;
			var kind:String;
			var domain:ApplicationDomain;
			var componentDefinition:ComponentDefinition;
			var includeChildren:Boolean = true;
			var className:String;
			var classType:Class;
			var componentDescription:ComponentDescription;
			var componentAlreadyAdded:Boolean;
			var message:String;
			var errorData:ErrorData;
			var issueData:IssueData;
			var property:String;
			var event:String;
			var style:String;
			var attributeNotFound:String;
			var handledChildNodes:Array = [];
			var localName:String;
			var textFlowXML:XML;
			var textFlow:TextFlow;
			var parser:ITextImporter;
			var tlfErrors:Vector.<String>;
			var tlfError:String;
			var TEXT_FLOW:String = "textFlow";
			var HTML_OVERRIDE:String = "htmlOverride";
			var flowNamespace:Namespace;
			var fixTextFlowNamespaceBug:Boolean = true;
			
			elementName = node.localName();
			qualifiedName = node.name();
			kind = node.nodeKind();
			domain = ApplicationDomain.currentDomain;
			
			if (elementName==null || kind=="text") {
				
			}
			else {
				componentDefinition = Radiate.getDynamicComponentType(elementName);
			}
			
			if (componentDefinition==null) {
				message = "Could not find the definition for " + elementName + ". The document will be missing elements.";
			}
			
			className = componentDefinition ? componentDefinition.className :null;
			classType = componentDefinition ? componentDefinition.classType as Class :null;
			
			
			if (componentDefinition==null && elementName!="RootWrapperNode") {
				//message += " Add this class to Radii8LibrarySparkAssets.sparkManifestDefaults or add the library to the project that contains it.";
				
				errorData = ErrorData.getIssue("Element not found", message);
				errors.push(errorData);
				
				Radiate.error(message);
				return null;
			}
			
			// classes to look into for decoding XML
			// XMLDecoder, SchemaTypeRegistry, SchemaManager, SchemaProcesser
			// SimpleXMLDecoder
			
			// special case for radio button group
			/*var object:* = SchemaTypeRegistry.getInstance().getClass(classType);
			var object2:* = SchemaTypeRegistry.getInstance().getClass(elementName);
			var object3:* = SchemaTypeRegistry.getInstance().getClass(node);
			var sm:mx.rpc.xml.SchemaManager = new mx.rpc.xml.SchemaManager();
			
			sm.addNamespaces({s:new Namespace("s", "library://ns.adobe.com/flex/spark")});
			var o:Object = sm.unmarshall(node);
			
			var q:QName = new QName(null, elementName);*/
			//var object2:* = SchemaTypeRegistry.getInstance().registerClass(;
			
	
			// more xml namespaces example code
			/*
			var a:Object = attribute.namespace().prefix     //returns prefix i.e. rdf
			var b:Object = attribute.namespace().uri        //returns uri of prefix i.e. http://www.w3.org/1999/02/22-rdf-syntax-ns#
			
			var c:Object = attribute.inScopeNamespaces()   //returns all inscope namespace as an associative array like above
			
			//returns all nodes in an xml doc that use the namespace
			var nsElement:Namespace = new Namespace(attribute.namespace().prefix, attribute.namespace().uri);
			
			var usageCount:XMLList = attribute..nsElement::*;
			*/

			// TODO during import check for [object BitmapData] and use missing image url
			if (componentDefinition!=null) {
				
				// we should NOT be setting defaults on import!!!
				// defaults should only be used when creating NEW components
				// when you save the document the first time the properties will be saved
				// so the next time you import you shouldn't need to set them again
				// the user may have even removed the defaults
				
				//instance = Radiate.createComponentForAdd(document, componentDefinition, true);
				if (componentInstance==null) {
					componentInstance = Radiate.createComponentToAdd(iDocument, componentDefinition, false);
				}
				else {
					componentAlreadyAdded = true;
				}
				
				//Radiate.info("MXML Importer adding: " + elementName);
				
				// calling add before setting properties because some 
				// properties such as borderVisible and trackingLeft/trackingRight need to be set after 
				// the component is added (maybe)
				var valuesObject:ValuesObject = Radiate.getPropertiesStylesEventsFromNode(componentInstance, node, componentDefinition);
				var attributes:Array = valuesObject.attributes;
				var childNodeNames:Array = valuesObject.childNodeNames;
				//var typedValueObject:Object = Radiate.getTypedValueFromStyles(instance, valuesObject.values, valuesObject.styles);
				
				var bitmapDataID:String = fcNamespaceURI + "::bitmapDataId";
				
				if (attributes.indexOf(bitmapDataID)!=-1) {
					var bitmapDataId:String = valuesObject.values[bitmapDataID];
					var bitmapData:BitmapData = Radiate.getBitmapDataFromImageDataID(bitmapDataId);
					
					if (bitmapData) {
						valuesObject.values["source"] = bitmapData;
					}
				}
				
				
				if (childNodeNames.indexOf(TEXT_FLOW)!=-1) {
					//textFlow = TextConverter.importToFlow(valuesObject.childNodeValues[TEXT_FLOW], TextConverter.TEXT_LAYOUT_FORMAT);

					
					if (textFlow==null) {
						//parser = TextConverter.getImporter(TextConverter.TEXT_LAYOUT_FORMAT) as ITextImporter;
						//tlfErrors = parser.errors;
						parser = TextConverter.getImporter(TextConverter.TEXT_LAYOUT_FORMAT, null);
						//if (!parser)
						//	return null;
						parser.throwOnError = false;
						flowNamespace = TextLayoutImporter(parser).ns;
						textFlowXML = new XML(valuesObject.childNodeValues[TEXT_FLOW]);
						
						if (fixTextFlowNamespaceBug) {
							textFlowXML = getTextFlowWithNamespace(textFlowXML);
						}
						if (valuesObject.childNodeValues[TEXT_FLOW]!="") {
							
						}
						//textFlowXML = new XML(valuesObject.childNodeValues[TEXT_FLOW]);
						textFlow = parser.importToFlow(textFlowXML);
						tlfErrors = parser.errors;
					}
					
					valuesObject.values[TEXT_FLOW] = textFlow;
					handledChildNodes.push(TEXT_FLOW);
				}
				
				if (!componentAlreadyAdded) {
					Radiate.addElement(componentInstance, parent, valuesObject.properties, valuesObject.styles, valuesObject.events, valuesObject.values);
				}
				else if (valuesObject.propertiesStylesEvents && valuesObject.propertiesStylesEvents.length) {
					Radiate.setPropertiesStylesEvents(componentInstance, valuesObject.propertiesStylesEvents, valuesObject.values);
				}
				
				Radiate.removeExplictSizeOnComponent(componentInstance, node, componentDefinition, false);
				
				Radiate.updateComponentAfterAdd(iDocument, componentInstance, false, makeInteractive);
				
				//Radiate.makeInteractive(componentInstance, makeInteractive);
				
				// in case width or height or relevant was changed
				if (componentInstance is Application) {
					Radiate.instance.dispatchDocumentSizeChangeEvent(componentInstance);
				}
				
				componentDescription = iDocument.getItemDescription(componentInstance);
				
				// save node XML
				componentDescription.nodeXML = node;
				
				// setting namespace attributes - refactor
				var lockedName:String = fcNamespaceURI + "::locked";
				
				if (attributes.indexOf(lockedName)!=-1) {
					componentDescription.locked = valuesObject.values[lockedName];
				}
				
				var userStylesName:String = htmlNamespaceURI + "::style";
				
				if (attributes.indexOf(userStylesName)!=-1) {
					componentDescription.userStyles = valuesObject.values[userStylesName];
				}
				
				var convertToImage:String = fcNamespaceURI + "::convertToImage";
				
				if (attributes.indexOf(convertToImage)!=-1) {
					componentDescription.convertElementToImage = valuesObject.values[convertToImage];
				}
				
				var createBackgroundSnapshot:String = fcNamespaceURI + "::createBackgroundSnapshot";
				
				if (attributes.indexOf(createBackgroundSnapshot)!=-1) {
					componentDescription.createBackgroundSnapshot = valuesObject.values[createBackgroundSnapshot];
				}
				
				var wrapWithAnchor:String = fcNamespaceURI + "::wrapWithAnchor";
				
				if (attributes.indexOf(wrapWithAnchor)!=-1) {
					componentDescription.wrapWithAnchor = valuesObject.values[wrapWithAnchor];
					
					var anchorURL:String = fcNamespaceURI + "::anchorURL";
					var anchorTarget:String = fcNamespaceURI + "::anchorTarget";
					
					if (attributes.indexOf(anchorURL)!=-1) {
						componentDescription.anchorURL = valuesObject.values[anchorURL];
					}
					
					if (attributes.indexOf(anchorTarget)!=-1) {
						componentDescription.anchorTarget = valuesObject.values[anchorTarget];
					}
				}
				
				var layerName:String = fcNamespaceURI + "::name";
				
				if (attributes.indexOf(layerName)!=-1) {
					componentDescription.name = valuesObject.values[layerName];
				}
				
				var htmlTagName:String = fcNamespaceURI + "::htmlTagName";
				
				if (attributes.indexOf(htmlTagName)!=-1) {
					componentDescription.htmlTagName = valuesObject.values[htmlTagName];
				}
				
				var htmlOverrideName:String;
				var htmlOverride:String;
				var tabCount:int;
				
				htmlOverrideName = htmlNamespaceURI + "::" + HTML_OVERRIDE;
				
				if (childNodeNames.indexOf(HTML_OVERRIDE)!=-1) {
					htmlOverride = valuesObject.values[HTML_OVERRIDE];
					htmlOverride = htmlOverride.indexOf("\n")==0 ? htmlOverride.substr(1) : htmlOverride.substr();
					tabCount = StringUtils.getTabCountBeforeContent(htmlOverride);
					htmlOverride = StringUtils.outdent(htmlOverride, tabCount);
					componentDescription.htmlOverride = htmlOverride;
					handledChildNodes.push(HTML_OVERRIDE);
				}
				
				for each (tlfError in tlfErrors) {
					errorData = ErrorData.getIssue("Invalid TLF Markup", tlfError + " in element " + elementName);
					errors.push(errorData);
				}
				
				for (property in valuesObject.propertiesErrorsObject) {
					errorData = ErrorData.getIssue("Invalid property value", "Value for property '" + property + "' was not applied to " + elementName);
					errorData.errorID = valuesObject.propertiesErrorsObject[property].errorID;
					errorData.message = valuesObject.propertiesErrorsObject[property].message;
					errorData.name = valuesObject.propertiesErrorsObject[property].name;
					errors.push(errorData);
				}
				
				for (style in valuesObject.stylesErrorsObject) {
					errorData = ErrorData.getIssue("Invalid style value", "Value for style '" + style + "' was not applied to " + elementName);
					errorData.errorID = valuesObject.stylesErrorsObject[style].errorID;
					errorData.message = valuesObject.stylesErrorsObject[style].message;
					errorData.name = valuesObject.stylesErrorsObject[style].name;
					errors.push(errorData);
				}
				
				for (event in valuesObject.eventsErrorsObject) {
					errorData = ErrorData.getIssue("Invalid event value", "Value for event '" + event + "' was not applied to " + elementName);
					errorData.errorID = valuesObject.stylesErrorsObject[event].errorID;
					errorData.message = valuesObject.stylesErrorsObject[event].message;
					errorData.name = valuesObject.stylesErrorsObject[event].name;
					errors.push(errorData);
				}
				
				for each (attributeNotFound in valuesObject.attributesNotFound) {
					errorData = ErrorData.getIssue("Invalid attribute", "Attribute '" + attributeNotFound + "' was not found on " + elementName);
					errors.push(errorData);
				}
				
				newComponents.push(componentInstance);
				// might want to get a properties object from the attributes 
				// and then use that in the add element call above 
				//Radiate.setAttributesOnComponent(instance, node, componentDefinition, false);
				//HistoryManager.mergeLastHistoryEvent(document);
			}
			
			
			var instance:Object;
			
			if (includeChildren) {
				
				for each (var childNode:XML in node.children()) {
					localName = childNode.localName();
					
					if (handledChildNodes.indexOf(localName)!=-1) {
						// needs to be more robust
						continue;
					}
					
					instance = createChildFromNode(childNode, componentInstance, iDocument, depth+1);
				}
			}
			
			return componentInstance;
		}
		
		/**
		 * Get text flow object with correct flow namespace
		 * */
		public function getTextFlowWithNamespace(value:Object):XML {
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
