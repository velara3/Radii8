
package com.flexcapacitor.model {
	
	
	/**
	 * Class used to store settings and projects
	 * */
	[RemoteClass(alias="Settings")]
	public class Settings implements ISettings {
		
		public function Settings() {
			
			lastOpened = modified = created = new Date().time;
		}
		
		private var _version:uint = 1;

		public function get version():uint {
			return _version;
		}

		public function set version(value:uint):void {
			_version = value;
		}
		
		
		public var created:uint;
		public var modified:uint;
		private var _modifiedValue:uint;

		public function get modifiedValue():uint {
			return new Date().time;
		}

		public function set modifiedValue(value:uint):void {
			_modifiedValue = value;
		}

		public var lastOpened:uint; 
		
		public var configuration:Object;
		
		public var openProjects:Array = [];
		
		public var openDocuments:Array = [];
		
		public var openWorkspace:Array = [];
		
		public var selectedDocument:IDocumentMetaData;
		
		public var selectedProject:IDocumentMetaData;
		
		public var saveCount:int;
		
		public var enableAutoSave:Boolean = false;
		public var enableWordWrap:Boolean = false;
		public var embedImages:Boolean = false;
		public var startInDesignView:Boolean = false;
		public var useCallOutForEditing:Boolean = true;
		
		public function unmarshall(data:Object):void {
			
			
			
		}
		
	}
}