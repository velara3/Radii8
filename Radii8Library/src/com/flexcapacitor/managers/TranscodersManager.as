package com.flexcapacitor.managers {
	import com.flexcapacitor.model.TranscoderDescription;
	import com.flexcapacitor.utils.ClassUtils;
	import com.flexcapacitor.controller.Console;

	/**
	 * Managers transcoders
	 **/
	public class TranscodersManager extends Console {
		
		public function TranscodersManager() {
			
		}
		
		/**
		 * Create the list of document transcoders.
		 * var languages:Array = CodeManager.getLanguages();
		 * var sourceData:SourceData = CodeManager.getSourceData(target, iDocument, language, options);	
		 * */
		public static function createDocumentTranscoders(xml:XML):void {
			var hasDefinition:Boolean;
			var items:XMLList;
			var item:XML;
			var numberOfItems:uint;
			var classType:Object;
			var transcoder:TranscoderDescription;
			
			// get list of transcoder classes 
			items = XML(xml).transcoder;
			
			numberOfItems = items.length();
			
			for (var i:int;i<numberOfItems;i++) {
				item = items[i];
				
				transcoder = new TranscoderDescription();
				transcoder.importXML(item);
				
				hasDefinition = ClassUtils.hasDefinition(transcoder.classPath);
				
				if (hasDefinition) {
					//classType = ClassUtils.getDefinition(transcoder.classPath);
					addTranscoder(transcoder);
				}
				else {
					error("Document transcoder class for " + transcoder.type + " not found: " + transcoder.classPath);
					// we need to add it to Radii8LibraryExporters
					// such as Radii8LibraryExporters
				}
			}
			
		}
		
		/**
		 * Adds a transcoder to the Code Manager and adds the current component definitions
		 * */
		public static function addTranscoder(transcoder:TranscoderDescription):void {
			
			CodeManager.registerTranscoder(transcoder);
			CodeManager.setComponentDefinitions(ComponentManager.componentDefinitions.source);
		}
	}
}