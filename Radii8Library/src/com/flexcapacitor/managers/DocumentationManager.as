package com.flexcapacitor.managers
{
	import com.flexcapacitor.model.EventMetaData;
	import com.flexcapacitor.model.MetaData;
	import com.flexcapacitor.model.StyleMetaData;

	public class DocumentationManager
	{
		public function DocumentationManager()
		{
		}
		
		//----------------------------------
		//
		//  Documentation Utility
		// 
		//----------------------------------
		
		public static var docsURL:String = "https://flex.apache.org/asdoc/";
		public static var docsURL2:String = "https://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/";
		public static var w3URL:String = "https://www.w3.org/TR/DOM-Level-3-Events/events.html#event-DOMSubtreeModified";
		public static var mozillaURL:String = "https://developer.mozilla.org/en-US/";
		
		/**
		 * Returns the URL to the help document online based on MetaData passed to it. 
		 * 
		 * For HTML, check out W3C 
		 * */
		public static function getURLToHelp(metadata:Object, useBackupURL:Boolean = true):String {
			var path:String = "";
			var currentClass:String;
			var sameClass:Boolean;
			var prefix:String = "";
			var url:String;
			var packageName:String;
			var declaredBy:String;
			var backupURLNeeded:Boolean;
			
			if (metadata=="application") {
				metadata = "spark.components::Application";
			}
			
			if (metadata && metadata is MetaData && metadata.declaredBy) {
				declaredBy = metadata.declaredBy;
				currentClass = declaredBy.replace(/::|\./g, "/");
				
				if (declaredBy.indexOf(".")!=-1) {
					packageName = declaredBy.split(".")[0];
					if (packageName=="flash") {
						backupURLNeeded = true;
					}
				}
				
				if (metadata is StyleMetaData) {
					prefix = "style:";
				}
				else if (metadata is EventMetaData) {
					prefix = "event:";
				}
				
				
				path = currentClass + ".html#" + prefix + metadata.name;
			}
			else if (metadata is String) {
				currentClass = metadata.replace(/::|\./g, "/");
				path = currentClass + ".html";
			}
			
			if (useBackupURL && backupURLNeeded) {
				url  = docsURL2 + path;
			}
			else {
				url  = docsURL + path;
			}
			
			return url;
		}
	}
}