
package com.flexcapacitor.model {
	import com.flexcapacitor.services.IWPService;
	
	import flash.net.FileReference;
	
	/**
	 * Interface for Document Data. This class may not be necessary. 
	 * Was using it to store less data than IDocument but more than 
	 * IDocumentMetaData.  
	 * */
	public interface IDocumentData extends IDocumentMetaData {
		
		
		/**
		 * Exporter that exports the document
		 * Deprecated use code manager
		 * */
		function set exporter(value:IDocumentExporter):void;
		function get exporter():IDocumentExporter;
		
		/**
		 * Exporter that exports the document to HTML
		 * Deprecated use code manager
		 * */
		function set htmlExporter(value:IDocumentExporter):void;
		function get htmlExporter():IDocumentExporter;
		
		/**
		 * Original source code of the document before importing
		 * */
		function set originalSource(value:String):void;
		function get originalSource():String;
		
		/**
		 * Source code of the document
		 * */
		function set source(value:String):void;
		function get source():String;
		
		/**
		 * Set the template for a document
		 * */
		function get template():String;
		function set template(value:String):void;
		
		/**
		 * Reference to the document
		 * */
		function set document(value:IDocument):void;
		function get document():IDocument;
		
		/**
		 * Is open
		 * */
		function set isOpen(value:Boolean):void;
		function get isOpen():Boolean;
		
		/**
		 * An array of attachment or document data 
		 * */
		function set assets(value:Array):void;
		function get assets():Array;
		
		/**
		 * Is changed
		 * */
		function set isChanged(value:Boolean):void;
		function get isChanged():Boolean;
		
		/**
		 * Is example 
		 * */
		function set isExample(value:Boolean):void;
		function get isExample():Boolean;
		
		/**
		 * Indicates if last save was successful. Only valid immediately after call to save. 
		 * */
		function set saveSuccessful(value:Boolean):void;
		function get saveSuccessful():Boolean;
		
		/**
		 * Indicates if last open was successful. Only valid immediately after call to open. 
		 * */
		function set openSuccessful(value:Boolean):void;
		function get openSuccessful():Boolean;
		
		/**
		 * True if save is in progress. 
		 * */
		function set saveInProgress(value:Boolean):void;
		function get saveInProgress():Boolean;
		
		/**
		 * If connected to WordPress represents the post object 
		 * */
		function set post(value:Object):void;
		function get post():Object;
		
		/**
		 * True if open is in progress. 
		 * */
		function set openInProgress(value:Boolean):void;
		function get openInProgress():Boolean;
		
		/**
		 * Reference to the save service
		 * */
		function set saveService(value:IWPService):void;
		function get saveService():IWPService;
		
		/**
		 * Reference to physical file
		 * */
		function set file(value:FileReference):void;
		function get file():FileReference;
		
		/**
		 * Array of revisions
		 * */
		function get revisions():Array;
		function set revisions(value:Array):void;
		
		/**
		 * Adds a revision of a document
		 * */
		function addRevision(revision:DocumentRevision):void;
		
		/**
		 * Parse assets
		 * */
		function parseAttachments(data:Array):void;
		
		/**
		 * Create the document
		 * */
		function createInstance(data:Object = null):IDocument;
		
		/**
		 * Save the document. String of locations to save to separated by comma.
		 * */
		function save(locations:String = null, options:Object = null):Boolean;
		
		/**
		 * Retrieve the document
		 * */
		function retrieve(local:Boolean = false):void;
		
		/**
		 * Open the document 
		 * */
		function open(location:String = null):void;
		
		/**
		 * Close the document 
		 * */
		function close():void;
		
		/**
		 * Mark the document changed or dirty.
		 * */
		function markDirty():void;
		
		/**
		 * Mark the document not changed or dirty.
		 * */
		function markClean():void;
		
		/**
		 * Get source of document such as MXML, HTML, etc
		 * */
		function getSource(target:Object = null):String;
		
		/**
		 * Translates the document to a metadata object
		 * */
		function toMetaData():IDocumentMetaData;
		
		/**
		 * Translates the project into an XML representation
		 * */
		function toXML(representation:Boolean = false):XML;
		
		/**
		 * Translates the project into a XML string
		 * */
		function toString():String;
		
	}
}