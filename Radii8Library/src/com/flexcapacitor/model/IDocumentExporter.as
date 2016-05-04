
package com.flexcapacitor.model {
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	
	
	/**
	 * Handles exporting to various formats
	 * */
	public interface IDocumentExporter {
		
		/**
		 * Is valid
		 * */
		function set isValid(value:Boolean):void;
		function get isValid():Boolean;
		
		/**
		 * Error event
		 * */
		function set error(value:Error):void;
		function get error():Error;
		
		/**
		 * Error message
		 * */
		function set errorMessage(value:String):void;
		function get errorMessage():String;
		
		/**
		 * Errors
		 * */
		function set errors(value:Array):void;
		function get errors():Array;
		
		/**
		 * Warnings
		 * */
		function set warnings(value:Array):void;
		function get warnings():Array;
		
		/**
		 * Exports to an XML string. When reference is true it returns
		 * a shorter string with a URI to the document details
		 * */
		function export(document:IDocument, target:ComponentDescription = null, options:ExportOptions = null, dispatchEvents:Boolean = false):SourceData;
		
		/**
		 * Export to XML. When reference is true it returns
		 * a shorter string with a URI to the document details
		 * */
		function exportXML(document:IDocument, reference:Boolean = false):XML;
		
		/**
		 * Export to JSON representation. When reference is true it returns
		 * a shorter string with a URI to the document details
		 * */
		function exportJSON(document:IDocument, reference:Boolean = false):JSON;
	}
}