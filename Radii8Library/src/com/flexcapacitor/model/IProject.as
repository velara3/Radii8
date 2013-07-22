
package com.flexcapacitor.model {
	
	import mx.collections.ArrayCollection;
	
	public interface IProject {
		
		function set documents(value:ArrayCollection):void;
		function get documents():ArrayCollection;
		
		function set name(value:String):void;
		function get name():String;
		function addDocument(document:IDocument):void;
		function toXMLString():String;
	}
}