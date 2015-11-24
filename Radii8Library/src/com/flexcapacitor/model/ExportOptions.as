package com.flexcapacitor.model
{
	
	/**
	 * Base class for options for DocumentExporter class
	 * */
	public class ExportOptions extends TranscoderOptions {
		
		public function ExportOptions() {
			
		}
		
		/**
		 * Indicates if the exporter should create files
		 * */
		public var createFiles:Boolean;
		
		/**
		 * Set styles inline
		 * */
		public var useInlineStyles:Boolean;
		
		/**
		 * Create an external style sheet
		 * */
		public var useExternalStylesheet:Boolean;
		
		/**
		 * Default file extension
		 * */
		public var fileExtension:String;
		
		/**
		 * Default file template
		 * */
		public var template:String;
	}
}