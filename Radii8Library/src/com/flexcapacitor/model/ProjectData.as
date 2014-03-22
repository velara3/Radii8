
package com.flexcapacitor.model {
	
	
	/**
	 * Holds project data for storage
	 * */
	[RemoteClass(alias="ProjectData")]
	public class ProjectData extends DocumentData implements IProjectData {
		
		
		public function ProjectData() {
			
		}


		private var _documentsData:Array = [];

		/**
		 * @inheritDoc
		 * */
		public function get documentsData():Array {
			return _documentsData;
		}

		public function set documentsData(value:Array):void {
			_documentsData = value;
		}


		private var _documents:Array = [];

		/**
		 * @inheritDoc
		 * */
		public function get documents():Array {
			return _documents;
		}

		public function set documents(value:Array):void {
			_documents = value;
		}
		
	}
}