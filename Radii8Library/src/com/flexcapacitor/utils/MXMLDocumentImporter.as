
	

package com.flexcapacitor.utils {
	
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.utils.supportClasses.ComponentDefinition;
	
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;
	import flash.utils.getTimer;
	
	import mx.core.IVisualElement;

	
	/**
	 * Import MXML into a IDocument. Basic support of creating components and apply properties and styles. 
	 * */
	public class MXMLDocumentImporter extends EventDispatcher {
	
		public var document:IDocument;

		/**
		 * Import the MXML document into the IDocument. 
		 * */
		public function MXMLDocumentImporter(iDocument:IDocument, id:String, mxml:XML, container:IVisualElement) {
			document = iDocument;
			
			var elName:String = mxml.localName();
			var timer:int = getTimer(); 
			
			Radiate.importingDocument = true;
			
			// TODO this is a special case we check for since 
			// we should have already created the application by now
			// we should handle this case before we get here (pass in the children of the application xml not application itself)
			if (elName=="Application") {
				Radiate.setAttributesOnComponent(document.instance, mxml);
			}
			else {
				createChildFromNode(mxml, container);
			}
			
			
			for each (var childNode:XML in mxml.children()) {
				createChildFromNode(childNode, container);
			}
			
			Radiate.importingDocument = false;
			
			// using importing document flag it goes down from 5 seconds to 1 second
			//Radiate.log.info("Time to import: " + (getTimer()-timer));
			
		}

		/**
		 * Create child from node
		 * */
		private function createChildFromNode(node:XML, parent:Object):IVisualElement {
			var elementName:String = node.localName();
			var domain:ApplicationDomain = ApplicationDomain.currentDomain;
			var componentDefinition:ComponentDefinition = Radiate.getDynamicComponentType(elementName);
			var className:String;
			var classType:Class;
			var includeChildren:Boolean = true;
			var instance:Object;
			
			if (componentDefinition==null) {
				
			}
			
			className =componentDefinition ? componentDefinition.className :null;
			classType = componentDefinition ? componentDefinition.classType as Class :null;
			
			
			if (componentDefinition==null && elementName!="RootWrapperNode") {
				//message += " Add this class to Radii8LibrarySparkAssets.sparkManifestDefaults or add the library to the project that contains it.";
				var message:String = "Could not find definition for " + elementName + ". The document will be missing elements.";
				Radiate.log.error(message);
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
				instance = Radiate.createComponentForAdd(document, componentDefinition, true);
				//Radiate.log.info("MXML Importer adding: " + elementName);
				
				// calling add before setting properties because some 
				// properties such as borderVisible need to be set after 
				// the component is added (maybe)
				Radiate.addElement(instance, parent);
				
				Radiate.setAttributesOnComponent(instance, node);
				
			}
			
			
			if (includeChildren) {
				
				for each (var childNode:XML in node.children()) {
					createChildFromNode(childNode, instance);
				}
			}
			
			return instance as IVisualElement;
		}
	}
}
