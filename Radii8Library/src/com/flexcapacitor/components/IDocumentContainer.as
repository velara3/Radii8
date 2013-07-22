
package com.flexcapacitor.components {
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import flash.display.DisplayObjectContainer;
	
	import mx.core.IVisualElementContainer;
	
	import spark.components.Scroller;
	
	
	
	public interface IDocumentContainer {

		/**
		 * The root component description for this document.
		 * */
		function get componentDescription():ComponentDescription;
		
		/**
		 * @private
		 * */
		function set componentDescription(value:ComponentDescription):void;
		
		/**
		 * Parses the code
		 * */
		function parseDocument(code:String):Boolean;
		
		/**
		 * Imports code 
		 * */
		function importDocument(code:String):Boolean;
		
		/**
		 * Reference to the document. Named documentDescription since
		 * document is already a property on UIComponent.
		 * */
		function set documentDescription(value:IDocument):void;
		function get documentDescription():IDocument;
		
		/**
		 * Reference to the tool layer.
		 * */
		function set toolLayer(value:IVisualElementContainer):void;
		function get toolLayer():IVisualElementContainer;
		
		/**
		 * Reference to the canvas border.
		 * */
		function set canvasBorder(value:IVisualElementContainer):void;
		function get canvasBorder():IVisualElementContainer;
		
		/**
		 * Reference to the canvas background.
		 * */
		function set canvasBackground(value:IVisualElementContainer):void;
		function get canvasBackground():IVisualElementContainer;
		
		/**
		 * Reference to the canvas scroller.
		 * */
		function set canvasScroller(value:Scroller):void;
		function get canvasScroller():Scroller;
		
		
	}
}