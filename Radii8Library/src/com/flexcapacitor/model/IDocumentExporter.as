
package com.flexcapacitor.model {
	
	
	
	/**
	 * Handles exporting to various formats
	 * */
	public interface IDocumentExporter {
		
		function export(document:IDocument):String;
		function exportXML(document:IDocument):XML;
		function exportJSON(document:IDocument):JSON;
	}
}