
package com.flexcapacitor.model {
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	
	/**
	 * Project model
	 * */
	public class Project extends EventDispatcher implements IProject {
		
		
		public function Project(target:IEventDispatcher=null) {
			super(target);
		}
		
		private var _name:String;

		/**
		 * Name of project
		 * */
		public function get name():String {
			return _name;
		}

		/**
		 * @private
		 */
		public function set name(value:String):void {
			_name = value;
		}

		
		private var _documents:ArrayCollection = new ArrayCollection();

		/**
		 * Array of documents
		 * */
		public function get documents():ArrayCollection {
			return _documents;
		}

		/**
		 * @private
		 */
		public function set documents(value:ArrayCollection):void {
			_documents = value;
		}

		/**
		 * Adds a document if it hasn't been added yet
		 * */
		public function addDocument(document:IDocument):void {
			if (_documents.getItemIndex(document)==-1) {
				_documents.addItem(document);
				document.project = this;
			}
		}
		
		public function toXMLString():String {
			var document:IDocument;
			var documentXML:String;
			var xml:XML = new XML();
			xml.@name = name;
			xml.documents = new XML();
			
			for (var i:int;i<documents.length;i++) {
				document = documents[i];
				
				documentXML = document.toXMLString();
				XML(xml.documents).appendChild(new XML(documentXML));
			}
			
			
			return xml.toXMLString();
		}
	}
}