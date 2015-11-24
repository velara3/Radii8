package com.flexcapacitor.model {
	
	/**
	 * Contains data from a code export
	 * */
	public class SourceData {
		
		public function SourceData() {
			
		}
		
		/**
		 * Markup from target
		 * */
		public var markup:String;
		
		/**
		 * Styles from target
		 * */
		public var styles:String;
		
		/**
		 * Template for document
		 * */
		public var template:String;
		
		/**
		 * Source code from target
		 * */
		public var source:String;
		
		/**
		 * An array of data used to create files from the export
		 * */
		public var files:Array;
		
		/**
		 * Array of warnings
		 * */
		public var warnings:Array;
		
		/**
		 * Array of errors
		 * */
		public var errors:Array;
		
		/**
		 * Array of new objects created during an import
		 * */
		public var targets:Array;
		
	}
}