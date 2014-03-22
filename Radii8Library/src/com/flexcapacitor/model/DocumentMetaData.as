
package com.flexcapacitor.model {
	import flash.events.EventDispatcher;
	
	/**
	 * Used to store the least amount of information about a document so it can be retrieved later.
	 * 
	 * DocumentMetaData - stores basic data about a document and how to find it (filesystem, online id, local store)
	 * DocumentData - extends DocumentMetaData and adds more info about the document including source code. somewhat abstract
	 * ProjectData - extends DocumentData. abstract class for Project
	 * Project - extends ProjectData and is an instance created for use at runtime
	 * Document - extends DocumentData and is an instance created for use at runtime 
	 * */
	[RemoteClass(alias="DocumentMetaData")]
	public class DocumentMetaData extends EventDispatcher implements IDocumentMetaData {
		
		/**
		 * Constructor
		 * */
		public function DocumentMetaData() {
		
		}

		[Transient]
		public static const METADATA_TYPE:String = "metaDataType";
		
		[Transient]
		public static const DOCUMENT_TYPE:String = "documentType";
		
		[Transient]
		public static const PROJECT_TYPE:String = "projectType";
		
		[Transient]
		public static const XML_TYPE:String = "XMLType";
		
		[Transient]
		public static const STRING_TYPE:String = "XMLStringType";
		
		/**
		 * Name to use for node when exporting to XML
		 * */
		public var nodeName:String = "document";
		
		private var _name:String;

		/**
		 * @inheritDoc
		 * */
		public function get name():String {
			return _name;
		}

		/**
		 * @private
		 * */
		public function set name(value:String):void {
			_name = value;
		}
		
		private var _contentType:String;

		/**
		 * @inheritDoc
		 * */
		public function get contentType():String {
			return _contentType;
		}

		/**
		 * @private
		 */
		public function set contentType(value:String):void {
			_contentType = value;
		}
		
		private var _type:String;

		/**
		 * @inheritDoc
		 * */
		public function get type():String {
			return _type;
		}

		/**
		 * @private
		 */
		public function set type(value:String):void {
			_type = value;
		}

		private var _className:String;

		/**
		 * @inheritDoc
		 * */
		public function get className():String {
			return _className;
		}

		public function set className(value:String):void {
			_className = value;
		}

		private var _uid:String;

		/**
		 * @inheritDoc
		 * */
		public function get uid():String {
			return _uid;
		}

		/**
		 * @private
		 * */
		public function set uid(value:String):void {
			_uid = value;
		}
		
		private var _uri:String;

		/**
		 * @inheritDoc
		 * */
		public function get uri():String {
			return _uri;
		}

		/**
		 * @private
		 * */
		public function set uri(value:String):void {
			_uri = value;
		}
		
		private var _host:String;

		/**
		 * @inheritDoc
		 * */
		public function get host():String {
			return _host;
		}

		/**
		 * @private
		 * */
		public function set host(value:String):void {
			_host = value;
		}
		
		private var _isOpen:Boolean;

		/**
		 * Indicates if the project is open
		 * */
		public function get isOpen():Boolean {
			return _isOpen;
		}

		/**
		 * @private
		 */
		[Bindable]
		public function set isOpen(value:Boolean):void {
			_isOpen = value;
		}
		
		private var _id:String;

		/**
		 * @inheritDoc
		 * */
		public function get id():String {
			return _id;
		}

		/**
		 * @private
		 * */
		public function set id(value:String):void {
			_id = value;
		}
		
		private var _parentId:String;

		/**
		 * Parent ID
		 * */
		public function get parentId():String {
			return _parentId;
		}

		public function set parentId(value:String):void {
			_parentId = value;
		}

		
		private var _status:String;

		/**
		 * @inheritDoc
		 * */
		public function get status():String {
			return _status;
		}

		/**
		 * @private
		 * */
		public function set status(value:String):void {
			_status = value;
		}

		private var _dateSaved:String;

		/**
		 * Date saved
		 * */
		public function get dateSaved():String {
			return _dateSaved;
		}

		public function set dateSaved(value:String):void {
			_dateSaved = value;
		}

		/**
		 * Returns the date
		 * */
		public function getTimeInHistory():String {
			return new Date().time.toString();
		}
		
		/**
		 * Serialize. Export for saving to disk or server
		 * */
		public function marshall(objectType:String = DOCUMENT_TYPE, representation:Boolean = false):Object {
			var output:Object;
			
			if (objectType==METADATA_TYPE) {
				var metadata:DocumentMetaData = new DocumentMetaData();
				
				metadata.className = className;
				metadata.dateSaved = getTimeInHistory();
				metadata.host = host;
				metadata.id = id;
				metadata.isOpen = isOpen;
				metadata.name = name;
				metadata.type = type;
				metadata.uid = uid;
				metadata.uri = uri;
				
				return metadata;
			}
			else if (objectType==DOCUMENT_TYPE) {
				var documentData:DocumentData = new DocumentData();
				
				documentData.className = className;
				documentData.dateSaved = getTimeInHistory();
				documentData.host = host;
				documentData.id = id;
				documentData.isOpen = isOpen;
				documentData.name = name;
				documentData.type = type;
				documentData.uid = uid;
				documentData.uri = uri;
			
				return documentData;
			}
			else if (objectType==STRING_TYPE || objectType==XML_TYPE ) {
				var xml:XML = new XML("<" + nodeName +"/>"); // support document or project types
				
				xml.@className = className!=null ? className : "";
				xml.@dateSaved = getTimeInHistory();
				xml.@host = host;
				xml.@id = id!=null ? id : "";
				xml.@isOpen = isOpen;
				xml.@name = name;
				xml.@type = type!=null ? type : "";
				xml.@uid = uid;
				xml.@uri = uri!=null ? uri : "";

				
				if (objectType==STRING_TYPE) {
					return xml.toXMLString();
				}
				
				return xml;
			}
			
			return output;
		}
		
		
		/**
		 * Deserialize document data. Import.
		 * */
		public function unmarshall(data:Object):void {
			
			if (data is IDocumentMetaData || data is IDocumentData) {
				className 	= data.className;
				dateSaved 	= data.dateSaved;
				host 		= data.host;
				id 			= data.id;
				isOpen 		= data.isOpen; // note we are repurposing this at runtime
				name 		= data.name;
				parentId 	= data.parentId;
				type 		= data.type;
				uid 		= data.uid;
				uri 		= data.uri;
				
			}
			else if (data is XML) {
				className 	= data.@className=="null" ? null : data.@className;
				dateSaved 	= data.@dateSaved;
				host 		= data.@host;
				id 			= data.@id=="null" ? null : data.@id;
				isOpen 		= data.@isOpen;
				name 		= data.@name;
				parentId 	= data.@parentId;
				type 		= data.@type=="null" ? null : data.@type;
				uid 		= data.@uid;
				uri 		= data.@uri=="null" ? null : data.@uri;
				
			}
		}
	}
}