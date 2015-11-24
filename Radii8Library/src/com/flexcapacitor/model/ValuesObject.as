package com.flexcapacitor.model
{
	
	/**
	 * Used to store properties, styles and values from XML nodes during import
	 * */
	public class ValuesObject {
		public var properties:Array = [];
		public var styles:Array = [];
		public var values:Object = {};
		public var attributes:Array;
		public var childNodeNames:Array;
		public var childNodeValues:Object;
	}
}