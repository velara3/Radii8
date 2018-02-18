/**
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

package com.flexcapacitor.components {
	import com.flexcapacitor.controls.RichTextEditorBar;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import mx.core.IVisualElementContainer;
	
	import spark.components.Scroller;
	
	
	/**
	 * An interface for the different types of documents. 
	 * */
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
		/*function parseDocument(code:String):Boolean;*/
		
		/**
		 * Imports code 
		 * */
		function importDocument(code:String):Boolean;
		
		/**
		 * Reference to the document. Named documentDescription since
		 * document is already a property on UIComponent.
		 * */
		function set iDocument(value:IDocument):void;
		function get iDocument():IDocument;
		
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
		
		/**
		 * Reference to the text editor component
		 * */
		function set editorComponent(value:RichTextEditorBar):void;
		function get editorComponent():RichTextEditorBar;
		
		
	}
}