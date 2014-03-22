package com.nbilyk.file {
	import flash.utils.ByteArray;

	/**
	 * This class is used to create 
	 */
	public class FormContent {
		
		/**
		 * @default form-data
		 */
		public var contentDisposition:String = "form-data";
		
		/**
		 * The name of the variable.
		 */
		public var name:String;
		
		/**
		 * The name of the file (leave null if not a file).
		 */
		public var fileName:String;
		
		/**
		 * The mime type of the file (leave null if not a file).
		 */
		public var contentType:String;
		
		/**
		 * The contents of the value.
		 */
		public var contents:ByteArray;
		
		public function FormContent(nameVal:String = "", contentsVal:ByteArray = null, fileNameVal:String = null, contentTypeVal:String = null) {
			name = nameVal;
			contents = contentsVal;
			fileName = fileNameVal;
			contentType = contentTypeVal;
		}
		
		/**
		 * Given a simple object of name=>value pairs, this utility method 
		 * returns a Vector of FormContent objects to represent the simple data parameters.
		 */
		public static function convertVariablesToFormContents(data:Object):Vector.<FormContent> {
			var v:Vector.<FormContent> = new Vector.<FormContent>();
			for (var all:String in data) {
				var formContent:FormContent = new FormContent();
				formContent.name = all;
				var bA:ByteArray = new ByteArray();
				bA.writeUTFBytes(String(data[all]));
				formContent.contents = bA;
				v.push(formContent);
			}
			return v;
		}
		
		/**
		 * Given a simple object of name=>value pairs, this utility method 
		 * returns a Vector of FormContent objects to represent the simple data parameters.
		 */
		public static function createFromVariable(name:String, value:String):FormContent {
			var f:FormContent = new FormContent();
			f.name = name;
			var bA:ByteArray = new ByteArray();
			bA.writeUTFBytes(value);
			f.contents = bA;
			return f;
		}
	}
}