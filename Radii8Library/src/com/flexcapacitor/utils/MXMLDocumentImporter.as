
	

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
	import flash.utils.Dictionary;
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
			var rootNodeName:String;
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
			
			// VALIDATE XML BEFORE IMPORTING
			isValid = XMLUtils.isValidXML(source);
			sourceData = new SourceData();
			
			if (!isValid) {
				rootNodeName = "RootWrapperNode";
				
				// not valid so try adding namespaces and a root node
				root = "<"+rootNodeName + " " + MXMLDocumentConstants.getDefaultNamespaceDeclarations() + ">";
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
			var includeChildNodes:Boolean;
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
			var fullNodeName:String;
			var tlfErrors:Vector.<String>;
			var tlfError:String;
			var fixTextFlowNamespaceBug:Boolean;
			var attributesErrorMessage:String;
			var elementID:String;
			var ignoreNamespaceAttributes:Boolean;
			var htmlOverrideName:String;
			var htmlAttributesName:String;
			var valuesObject:ValuesObject;
			var attributes:Array;
			var attributesNotFound:Array;
			var childNodeNames:Array;
			var qualifiedChildNodeNames:Array;
			
			includeChildNodes = true;
			fixTextFlowNamespaceBug = true;
			
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
				valuesObject = Radiate.getPropertiesStylesEventsFromNode(componentInstance, node, componentDefinition);
				attributes = valuesObject.attributes;
				
				// remove attributes with namespaces for now but warn about attributes that are not found
				attributesNotFound = ArrayUtils.removeAllItems(valuesObject.attributesNotFound, valuesObject.qualifiedAttributes);
				childNodeNames = valuesObject.childNodeNames;
				qualifiedChildNodeNames = valuesObject.qualifiedChildNodeNames;
				//var typedValueObject:Object = Radiate.getTypedValueFromStyles(instance, valuesObject.values, valuesObject.styles);
				
				// when copying images that do not have a URL then we use a internal reference id
				// used when copying and pasting MXML
				if (attributes.indexOf(MXMLDocumentConstants.BITMAP_DATA_ID_NS)!=-1) {
					setBitmapData(componentDescription, valuesObject, MXMLDocumentConstants.BITMAP_DATA_ID_NS);
				}
				
				// import TextFlow
				if (childNodeNames.indexOf(MXMLDocumentConstants.TEXT_FLOW)!=-1 || 
					qualifiedChildNodeNames.indexOf(MXMLDocumentConstants.TEXT_FLOW_NS)!=-1) {
					tlfErrors = setTextFlow(componentDescription, valuesObject, fixTextFlowNamespaceBug);
					handledChildNodes.push(MXMLDocumentConstants.TEXT_FLOW_NS);
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
				
				// first refactor - this may be slower than what we're doing but not sure how much slower
				// would need to create functions to handle each attribute
				/*
				*/
				var importFunction:Function;
				
				if (specializedMembers==null) {
					specializedMembers = getValidNamespaceAttributes();
				}
				
				for (var namespaceAttribute:String in specializedMembers) {
					
					if (attributes.indexOf(namespaceAttribute)!=-1 || 
						childNodeNames.indexOf(namespaceAttribute)!=-1 || 
						qualifiedChildNodeNames.indexOf(namespaceAttribute)!=-1) {
						importFunction = specializedMembers[namespaceAttribute] as Function;
						
						if (importFunction!=null) {
							if (importFunction.length==2) {
								importFunction(componentDescription, valuesObject.values[namespaceAttribute]);
							}
							else {
								importFunction(componentDescription, valuesObject, namespaceAttribute);
							}
							
							if (childNodeNames.indexOf(namespaceAttribute)!=-1 || 
								qualifiedChildNodeNames.indexOf(namespaceAttribute)!=-1) {
								handledChildNodes.push(namespaceAttribute);
							}
						}
					}
				}
				
				// original code
				/*
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
				
				var htmlOverride:String;
				var htmlAttributes:String;
				var tabCount:int;
				
				htmlOverrideName = htmlNamespaceURI + "::" + MXMLDocumentConstants.HTML_OVERRIDE;
				
				if (childNodeNames.indexOf(MXMLDocumentConstants.HTML_OVERRIDE)!=-1) {
					htmlOverride = valuesObject.values[MXMLDocumentConstants.HTML_OVERRIDE];// should be htmlOverrideName?
					htmlOverride = htmlOverride.indexOf("\n")==0 ? htmlOverride.substr(1) : htmlOverride.substr();
					tabCount = StringUtils.getTabCountBeforeContent(htmlOverride);
					htmlOverride = StringUtils.outdent(htmlOverride, tabCount);
					componentDescription.htmlOverride = htmlOverride;
					handledChildNodes.push(MXMLDocumentConstants.HTML_OVERRIDE);
				}
				
				htmlAttributesName = htmlNamespaceURI + "::" + MXMLDocumentConstants.HTML_ATTRIBUTES;
				
				if (childNodeNames.indexOf(MXMLDocumentConstants.HTML_ATTRIBUTES)!=-1) {
					htmlAttributes = valuesObject.values[MXMLDocumentConstants.HTML_ATTRIBUTES]; // should be htmlAttributesName?
					htmlAttributes = htmlAttributes.indexOf("\n")==0 ? htmlAttributes.substr(1) : htmlAttributes.substr();
					tabCount = StringUtils.getTabCountBeforeContent(htmlAttributes);
					htmlAttributes = StringUtils.outdent(htmlAttributes, tabCount);
					componentDescription.htmlAttributes = htmlAttributes;
					handledChildNodes.push(MXMLDocumentConstants.HTML_ATTRIBUTES);
				}
				*/
				
				
				if (childNodeNames.indexOf(MXMLDocumentConstants.HTML_OVERRIDE_NS)!=-1) {
					handledChildNodes.push(MXMLDocumentConstants.HTML_OVERRIDE_NS);
				}
				
				if (childNodeNames.indexOf(MXMLDocumentConstants.HTML_ATTRIBUTES_NS)!=-1) {
					handledChildNodes.push(MXMLDocumentConstants.HTML_ATTRIBUTES_NS);
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
				
				// right now we are skipping any attributes that have a namespace 
				// and have removed them in code above but still warn about normal attributes that are not found
				for each (attributeNotFound in attributesNotFound) {
					attributesErrorMessage = "Attribute '" + attributeNotFound + "' was not found on " + elementName;
					errorData = ErrorData.getIssue("Invalid attribute", "Attribute '" + attributeNotFound + "' was not found on " + elementName);
					errors.push(errorData);
				}
				
				if (newComponents) {
					newComponents.push(componentInstance);
				}
				
				// might want to get a properties object from the attributes 
				// and then use that in the add element call above 
				//Radiate.setAttributesOnComponent(instance, node, componentDefinition, false);
				//HistoryManager.mergeLastHistoryEvent(document);
			}
			
			
			var instance:Object;
			
			if (includeChildNodes) {
				
				for each (var childNode:XML in node.children()) {
					localName = childNode.localName();
					fullNodeName = childNode.name().toString();
					
					if (handledChildNodes.indexOf(localName)!=-1 || 
						handledChildNodes.indexOf(fullNodeName)!=-1) {
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
			var tlfNamespace:Namespace = new Namespace(tlfNamespace, MXMLDocumentConstants.tlfNamespaceURI);
			xml.removeNamespace(new Namespace(MXMLDocumentConstants.sparkNamespacePrefix, MXMLDocumentConstants.sparkNamespaceURI));
			xml.setNamespace(tlfNamespace);
			
			for each (var node:XML in xml.descendants()) {
				node.setNamespace(tlfNamespace);
				
				for each (var attribute:XML in node.attributes()) {
					attribute.setNamespace(tlfNamespace);
				}
			}
			
			return xml;
		}
		
		/**
		 * For now, we create an array of valid namespace attributes
		 * */
		public function getValidNamespaceAttributes():Dictionary {
			if (specializedMembers==null) {
				specializedMembers = new Dictionary(true);
				
				specializedMembers[MXMLDocumentConstants.BITMAP_DATA_ID_NS] = setBitmapData;
				
				specializedMembers[MXMLDocumentConstants.LOCKED_NS] = setLockedStatus;
				specializedMembers[MXMLDocumentConstants.CONVERT_TO_IMAGE_NS] = convertToImage;
				specializedMembers[MXMLDocumentConstants.CREATE_BACKGROUND_SNAPSHOT_NS] = createBackgroundSnapshot;
				specializedMembers[MXMLDocumentConstants.WRAP_WITH_ANCHOR_NS] = wrapWithAnchor;
				specializedMembers[MXMLDocumentConstants.ANCHOR_TARGET_NS] = setAnchorTarget;
				specializedMembers[MXMLDocumentConstants.ANCHOR_URL_NS] = setAnchorURL;
				
				specializedMembers[MXMLDocumentConstants.LAYER_NAME_NS] = setLayerName;
				
				specializedMembers[MXMLDocumentConstants.HTML_TAG_NAME_NS] = setHTMLTagName;
				specializedMembers[MXMLDocumentConstants.HTML_OVERRIDE_NS] = setHTMLOverride;
				specializedMembers[MXMLDocumentConstants.HTML_ATTRIBUTES_NS] = setHTMLAttributes;
				specializedMembers[MXMLDocumentConstants.HTML_BEFORE_NS] = setHTMLBefore;
				specializedMembers[MXMLDocumentConstants.HTML_AFTER_NS] = setHTMLAfter;
				specializedMembers[MXMLDocumentConstants.HTML_STYLES_NS] = setHTMLStyle;
				
			}
			
			return specializedMembers;
		}
		
		public var specializedMembers:Dictionary;
		
		public function setLockedStatus(componentDescription:ComponentDescription, value:*):void {
			componentDescription.locked = value;
		}
		
		public function setBitmapData(componentDescription:ComponentDescription, valuesObject:ValuesObject, attributeName:String):void {
			var bitmapDataId:String;
			var bitmapData:BitmapData;
			
			bitmapDataId = valuesObject.values[attributeName];
			bitmapData = Radiate.getBitmapDataFromImageDataID(bitmapDataId);
			
			if (bitmapData) {
				valuesObject.values["source"] = bitmapData;
			}
		}
		
		public function convertToImage(componentDescription:ComponentDescription, value:*):void {
			componentDescription.convertElementToImage = value;
		}
		
		public function createBackgroundSnapshot(componentDescription:ComponentDescription, value:*):void {
			componentDescription.createBackgroundSnapshot = value;
		}
		
		public function wrapWithAnchor(componentDescription:ComponentDescription, value:*):void {
			componentDescription.wrapWithAnchor = value;
		}
		
		public function setAnchorURL(componentDescription:ComponentDescription, value:String):void {
			componentDescription.anchorURL = value;
		}
		
		public function setAnchorTarget(componentDescription:ComponentDescription, value:String):void {
			componentDescription.anchorTarget = value;
		}
		
		public function setLayerName(componentDescription:ComponentDescription, value:String):void {
			componentDescription.name = value;
		}
		
		public function setHTMLTagName(componentDescription:ComponentDescription, value:String):void {
			componentDescription.htmlTagName = value;
		}
		
		public function setHTMLOverride(componentDescription:ComponentDescription, value:String):void {
			var htmlOverride:String;
			var tabCount:int;
			
			htmlOverride = value;
			htmlOverride = htmlOverride.indexOf("\n")==0 ? htmlOverride.substr(1) : htmlOverride.substr();
			tabCount = StringUtils.getTabCountBeforeContent(htmlOverride);
			htmlOverride = StringUtils.outdent(htmlOverride, tabCount);
			componentDescription.htmlOverride = htmlOverride;
			
		}
		
		public function setHTMLBefore(componentDescription:ComponentDescription, value:String):void {
			var htmlBefore:String;
			var tabCount:int;
			
			htmlBefore = value;
			htmlBefore = htmlBefore.indexOf("\n")==0 ? htmlBefore.substr(1) : htmlBefore.substr();
			tabCount = StringUtils.getTabCountBeforeContent(htmlBefore);
			htmlBefore = StringUtils.outdent(htmlBefore, tabCount);
			componentDescription.htmlBefore = htmlBefore;
			
		}
		
		public function setHTMLAfter(componentDescription:ComponentDescription, value:String):void {
			var htmlAfter:String;
			var tabCount:int;
			
			htmlAfter = value;
			htmlAfter = htmlAfter.indexOf("\n")==0 ? htmlAfter.substr(1) : htmlAfter.substr();
			tabCount = StringUtils.getTabCountBeforeContent(htmlAfter);
			htmlAfter = StringUtils.outdent(htmlAfter, tabCount);
			componentDescription.htmlAfter = htmlAfter;
			
		}
		
		public function setHTMLAttributes(componentDescription:ComponentDescription, value:String):void {
			var htmlAttributes:String;
			var tabCount:int;
			
			htmlAttributes = value; // should be htmlAttributesName?
			htmlAttributes = htmlAttributes.indexOf("\n")==0 ? htmlAttributes.substr(1) : htmlAttributes.substr();
			tabCount = StringUtils.getTabCountBeforeContent(htmlAttributes);
			htmlAttributes = StringUtils.outdent(htmlAttributes, tabCount);
			componentDescription.htmlAttributes = htmlAttributes;
			
		}
		
		public function setHTMLStyle(componentDescription:ComponentDescription, value:String):void {
			componentDescription.userStyles = value;
		}
		
		
		public var textFlowParser:ITextImporter;
		
		/**
		 * Convert TextFlow XML into actual text flow instance and set the value object to it
		 * */
		public function setTextFlow(componentDescription:ComponentDescription, valuesObject:ValuesObject, fixTextFlowNamespaceBug:Boolean):Vector.<String> {
			var textFlowString:String;
			var textFlowXML:XML;
			var textFlow:TextFlow;
			var parser:ITextImporter;
			var flowNamespace:Namespace;
			
			if (textFlow==null) {
				//parser = TextConverter.getImporter(TextConverter.TEXT_LAYOUT_FORMAT) as ITextImporter;
				//tlfErrors = parser.errors;
				
				if (textFlowParser==null) {
					parser = TextConverter.getImporter(TextConverter.TEXT_LAYOUT_FORMAT, null);
				}
				//if (!parser)
				//	return null;
				
				parser.throwOnError = false;
				flowNamespace = TextLayoutImporter(parser).ns;
				
				textFlowString = valuesObject.childNodeValues[MXMLDocumentConstants.TEXT_FLOW];
				
				// if not found it may be using an alternate namespace
				if (textFlowString==null) {
					textFlowString = valuesObject.childNodeValues[MXMLDocumentConstants.TEXT_FLOW_NS];
				}
				
				textFlowXML = new XML(textFlowString);
				
				if (fixTextFlowNamespaceBug) {
					textFlowXML = getTextFlowWithNamespace(textFlowXML);
				}
				
				//if (valuesObject.childNodeValues[MXMLDocumentConstants.TEXT_FLOW]!="") {
					
				//}
				
				//textFlowXML = new XML(valuesObject.childNodeValues[TEXT_FLOW]);
				textFlow = parser.importToFlow(textFlowXML);
			}
			
			valuesObject.values[MXMLDocumentConstants.TEXT_FLOW] = textFlow;
			
			return parser.errors;
		}
		
	}
}
