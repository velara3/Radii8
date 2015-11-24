
package com.flexcapacitor.model {
	
	/**
	 * Used to store basic information about a project for later retrieval.
	 * */
	[RemoteClass(alias="ProjectMetaData")]
	public class ProjectMetaData extends DocumentMetaData implements IProjectMetaData {
		
		public function ProjectMetaData() {
			super();
		}
		
	}
}