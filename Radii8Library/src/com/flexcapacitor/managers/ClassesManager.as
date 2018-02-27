package com.flexcapacitor.managers
{
	import com.flexcapacitor.controller.Console;
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.utils.ClassLoader;
	import com.flexcapacitor.utils.ClassRegistry;
	import com.flexcapacitor.utils.DocumentTranscoder;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;

	/**
	 * Manages classes
	 **/
	public class ClassesManager extends Console {
		
		public function ClassesManager(s:SINGLEDOUBLE) {
			
		}
		
		/**
		 * Registers and maps classes with namespaces 
		 * */
		public static var classRegistry:ClassRegistry;
		
		/**
		 * Loads flex config and component manifests
		 * */
		public static var classLoader:ClassLoader;
		
		/**
		 * Indicates classes are loading
		 * */
		public static var loadingClasses:Boolean;
		
		/**
		 * Indicates all classes have loaded
		 * */
		public static var classesLoaded:Boolean;
		
		public static function registerClasses():void {
			classRegistry = ClassRegistry.getInstance();
			classRegistry.targetNamespace = new Namespace("s", "library://ns.adobe.com/flex/spark");
			
			classLoader = new ClassLoader();
			classLoader.configPath = "assets/manifest/";
			classLoader.configFileName = "flex-config-template.xml";
			classLoader.addEventListener(ClassLoader.NAMESPACE_LOADED, namespaceLoaded, false, 0, true);
			classLoader.addEventListener(ClassLoader.NAMESPACES_LOADED, namespacesLoaded, false, 0, true);
			classLoader.addEventListener(IOErrorEvent.IO_ERROR, namespacesIOErrorEvent, false, 0, true);
			classLoader.load();
			
			var transcoder:DocumentTranscoder = new DocumentTranscoder();
			var defaultMXMLApplication:XML = transcoder.getDefaultMXMLDocumentXML();
			
			classRegistry.addNamespaces(defaultMXMLApplication);
		}
		
		protected static function namespaceLoaded(event:Event):void {
			var uri:String = classLoader.lastNamespaceURI;
		}
		
		protected static function namespacesLoaded(event:Event):void {
			loadingClasses = false;
			classesLoaded = true;
			
			Radiate.dispatchNamespacesLoadedEvent();
		}
		
		protected static function namespacesIOErrorEvent(event:Event):void {
			error("Namespace files were not loaded", event);
		}
		
		//----------------------------------
		//  instance
		//----------------------------------
		
		public static function get instance():ClassesManager
		{
			if (!_instance) {
				_instance = new ClassesManager(new SINGLEDOUBLE());
			}
			return _instance;
		}
		
		public static function getInstance():ClassesManager {
			return instance;
		}
		
		private static var _instance:ClassesManager;
	}
}

class SINGLEDOUBLE{}