
package com.flexcapacitor.model {
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	
	
	public interface IDocument {
		
		function set name(value:String):void;
		function get name():String;
		function get project():IProject;
		function set project(value:IProject):void;
		function get instance():Object;
		function set instance(value:Object):void;
		function get description():ComponentDescription;
		function set description(value:ComponentDescription):void;
		function get history():ArrayCollection;
		function set history(value:ArrayCollection):void;
		function get historyIndex():int;
		function set historyIndex(value:int):void;
		function get descriptionsDictionary():Dictionary;
		function set descriptionsDictionary(value:Dictionary):void;
		function toXMLString():String;
		function toXML():XML;
	}
}