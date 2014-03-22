
package com.flexcapacitor.model {
	
	/**
	 * Defines required serializable project data properties
	 * */
	public interface IProjectData extends IDocumentData {
		
		
		/**
		 * Array of documents that are part of this project
		 * */
		function set documents(value:Array):void;
		function get documents():Array;
		
	}
}