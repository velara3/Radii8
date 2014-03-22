
package com.flexcapacitor.model {
	
	
	/**
	 * Class used to store projects, documents and resources
	 * */
	[RemoteClass(alias="SavedData")]
	public class SavedData implements ISavedData {
		
		public function SavedData() {
			modified = created = new Date().time;
		}
		
		
		private var _version:uint = 1;

		public function get version():uint {
			return _version;
		}

		public function set version(value:uint):void {
			_version = value;
		}
		
		public var saveCount:int;
		
		
		public var created:uint;
		public var modified:uint;
		private var _modifiedValue:uint;

		public function get modifiedValue():uint {
			return _modifiedValue;
		}

		public function set modifiedValue(value:uint):void {
			_modifiedValue = value;
		}

		
		public var workspaces:Array = [];
		
		public var projects:Array = [];
		
		public var documents:Array = [];
		
		public var resources:Array = [];
		
		
		
		public function unmarshall(data:Object):void {
			
			
			
		}
	}
}