
package com.flexcapacitor.model {
	
	
	
	/**
	 * Describes the interface of a project
	 * */
	public interface IProject extends IDocumentData {
		
		/**
		 * Project documents
		 * */
		function set documents(value:Array):void;
		function get documents():Array;
		
		/**
		 * Project home page id
		 * */
		function set homePage(value:int):void;
		function get homePage():int;
		
		/**
		 * Project documents meta data
		 * */
		function set documentsMetaData(value:Array):void;
		function get documentsMetaData():Array;
		
		/**
		 * Reference to the last saved project data object
		 * */
		function get projectData():IProjectData;
		function set projectData(value:IProjectData):void;
		
		/**
		 * Set to true when opened from metadata
		 * */
		function get openedFromMetaData():Boolean;
		function set openedFromMetaData(value:Boolean):void;
		
		
		/**
		 * Import documents
		 * */
		function importDocumentInstances(documents:Array, overwrite:Boolean = false):void;
		
		/**
		 * Add document
		 * */
		function addDocument(document:IDocument, overwrite:Boolean = false):void;
		
		/**
		 * Get savable document data. If open is true then only returns open documents. 
		 * */
		function getSavableDocumentsData(open:Boolean = false, metaData:Boolean = false):Array;
		
		/**
		 * Open the project documents from meta data
		 * */
		function openFromMetaData(location:String = null):void;

		/**
		 * Checks if project has any changes and marks isChanged to true if true
		 * */
		function checkProjectHasChanged():Boolean;

		/**
		 * Gets document by UID.
		 * */
		function getDocumentByUID(uid:String):IDocumentData;

		/**
		 * Save only the project not the project documents
		 * String of locations to save to separated by comma.
		 * */
		function saveOnlyProject(locations:String = null, options:Object = null):Boolean;
	}
}