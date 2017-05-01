package com.flexcapacitor.preloaders {

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;
	
	import mx.core.Singleton;
	import mx.events.FlexEvent;
	import mx.preloaders.SparkDownloadProgressBar;
	
	public class RegisteringPreloader extends SparkDownloadProgressBar {
		
		public function RegisteringPreloader() {
			
		}
		
		public var replaceDefault:Boolean;
		public var preloaderSprite:Sprite;
		
		override public function set preloader(value:Sprite):void {
			super.preloader = value;
			
			preloaderSprite = value;
			
			value.addEventListener(FlexEvent.PRELOADER_DOC_FRAME_READY, preloaderCompleteHandler);
			
		}
		
		protected function preloaderCompleteHandler(event:Event):void {
			var dragManagerClass:Class;
			var classPath:String;
			var hasDefinition:Boolean;
			
			preloaderSprite.addEventListener(FlexEvent.PRELOADER_DOC_FRAME_READY, preloaderCompleteHandler);
			
			classPath = "com.flexcapacitor.managers::DragManagerImpl";
			hasDefinition = ApplicationDomain.currentDomain.hasDefinition(classPath);
			
			if (hasDefinition && replaceDefault) {
				dragManagerClass = Class(getDefinitionByName(classPath));
				
				Singleton.registerClass("mx.managers::IDragManager", dragManagerClass);
			}
			
		}
		
	}
}