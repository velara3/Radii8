
package com.flexcapacitor.model {
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.core.IVisualElement;
	
	
	/**
	 * Interface for document
	 * */
	public interface IDocument extends IDocumentData {
		
		/**
		 * ID of parent project. May support multiple projects in the future. 
		 * */
		function set projectID(value:String):void;
		function get projectID():String;
		
		/**
		 * Parent project. Some documents may not need projects. 
		 * */
		function get project():IProject;
		function set project(value:IProject):void;
		
		/**
		 * Reference to the last saved document data object
		 * */
		function get documentData():IDocumentData;
		function set documentData(value:IDocumentData):void;
		
		/**
		 * Class type that contains this document
		 * */
		function get containerType():Class;
		function set containerType(value:Class):void;
		
		/**
		 * Name of class type that contains this document
		 * */
		function get containerTypeName():String;
		function set containerTypeName(value:String):void;
		
		/**
		 * Reference to the document instance. 
		 * */
		function get instance():Object;
		function set instance(value:Object):void;
		
		/**
		 * Reference to component tree
		 * */
		function get componentDescription():ComponentDescription;
		function set componentDescription(value:ComponentDescription):void;
		
		/**
		 * Collection of history events
		 * */
		function get history():ArrayCollection;
		function set history(value:ArrayCollection):void;
		
		/**
		 * Current history event index
		 * */
		function get historyIndex():int;
		function set historyIndex(value:int):void;
		
		/**
		 * Index that history was at when last saved. 
		 * */
		function get lastSavedHistoryIndex():int;
		function set lastSavedHistoryIndex(value:int):void;
		
		/**
		 * Property that tells if document preview is open
		 * */
		function get isPreviewOpen():Boolean;
		function set isPreviewOpen(value:Boolean):void;
		
		/**
		 * A dictionary of information about...
		 * */
		function get descriptionsDictionary():Dictionary;
		function set descriptionsDictionary(value:Dictionary):void;
		
		/**
		 * Scale of the document for design view
		 * */
		function get scale():Number;
		function set scale(value:Number):void;
		
		/**
		 * Parses the code in the source property or the passed in value if set
		 * */
		function parseSource(value:String = null, container:IVisualElement = null):void;
		
		/**
		 * Resets the save status after loading a document
		 * */
		function resetSaveStatus():void;
	}
}