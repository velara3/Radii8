package com.flexcapacitor.model {
	import flash.system.ApplicationDomain;
	
	/**
	 * Data about a document view. 
	 * For example, we have an MXML Design View, we have Code editor that supports 
	 * various languages and syntaxes. We could have a component inspector that 
	 * shows different states of a button that you can edit.
	 * We have a HTML preview view that could be viewed with the AIR HTML webkit
	 * or the StageWebView component that uses the system browser.
	 * */
	public class DocumentDescription {
		
		public function DocumentDescription() {
			
		}
		
		/**
		 * Name of document type. For example, "code editor", "HTML preview" 
		 * */
		public var name:String;
		
		/**
		 * Label of document type.
		 * */
		public var label:String;
		
		/**
		 * Reference to the class path 
		 * */
		public var classPath:String;
		
		/**
		 * Reference to the class definition 
		 * */
		public var classType:Object;
		
		/**
		 * Import settings from XML
		 * */
		public function importXML(item:XML):void {
			classPath = String(item.attribute("classPath"));
			label = String(item.attribute("label"));
			name = String(item.attribute("name"));
			
			var hasDefinition:Boolean = ApplicationDomain.currentDomain.hasDefinition(classPath);
			
			if (hasDefinition) {
				classType = ApplicationDomain.currentDomain.getDefinition(classPath);
				
				if (classType) {
					
				}
			}
			else {
				//throw new Error("Document transcoder class for " + type + " not found: " + classPath);
			}
		}
	}
}