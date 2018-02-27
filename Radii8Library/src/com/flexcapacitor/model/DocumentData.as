
package com.flexcapacitor.model {
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.controller.RadiateUtilities;
	import com.flexcapacitor.managers.DateManager;
	import com.flexcapacitor.managers.LibraryManager;
	import com.flexcapacitor.managers.ServicesManager;
	import com.flexcapacitor.managers.SettingsManager;
	import com.flexcapacitor.services.IServiceEvent;
	import com.flexcapacitor.services.IWPService;
	import com.flexcapacitor.services.IWPServiceEvent;
	import com.flexcapacitor.services.WPService;
	import com.flexcapacitor.services.WPServiceBase;
	import com.flexcapacitor.services.WPServiceEvent;
	import com.flexcapacitor.utils.XMLUtils;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.FileReference;
	import flash.net.URLVariables;
	import flash.system.ApplicationDomain;
	
	/**
	 * Event dispatched when the save results are returned. 
	 * SaveResultsEvent
	 * */
	[Event(name="saveResults", type="com.flexcapacitor.model.SaveResultsEvent")]
	
	/**
	 * Event dispatched when the document data is retrieved. 
	 * LoadResultsEvent
	 * */
	[Event(name="loadResults", type="com.flexcapacitor.model.LoadResultsEvent")]
	
	/**
	 * Holds document data. 
	 * */
	[RemoteClass(alias="DocumentData")]
	public class DocumentData extends DocumentMetaData implements IDocumentData {
		
		/**
		 * Constructor
		 * */
		public function DocumentData(target:IEventDispatcher = null) {
			super();
		}
		
		public static const REVISIONS:String = "revisions";
		
		/**
		 * Default class that exports the document 
		 * Deprecated. Use Code Manager
		 * */
		[Transient]
		public static var internalExporter:IDocumentExporter;
		
		private var _exporter:IDocumentExporter = internalExporter;

		/**
		 * Exports the document to string
		 * Deprecated. Use Code Manager
		 * */
		[Transient]
		public function get exporter():IDocumentExporter {
			return _exporter;
		}

		/**
		 * @private
		 */
		public function set exporter(value:IDocumentExporter):void {
			_exporter = value;
		}
		
		/**
		 * List of exporters
		 * Deprecated. Use Code Manager
		 * */
		public var exporters:Array = [];
		
		private var _htmlExporter:IDocumentExporter;

		/**
		 * Default class that exports the document to HTML 
		 * Deprecated. Use Code Manager
		 * */
		[Transient]
		public function get htmlExporter():IDocumentExporter {
			return _htmlExporter;
		}

		/**
		 * @private
		 */
		public function set htmlExporter(value:IDocumentExporter):void {
			_htmlExporter = value;
		}

		
		/**
		 * Constant used to save locally to a shared object
		 * */
		[Transient]
		public static const LOCAL_LOCATION:String = "local";
		
		/**
		 * Constant used to open from internal references
		 * */
		[Transient]
		public static const INTERNAL_LOCATION:String = "internal";
		
		/**
		 * Constant used to save to the local file system
		 * */
		[Transient]
		public static const FILE_LOCATION:String = "file";
		
		/**
		 * Constant used to save to a database
		 * */
		[Transient]
		public static const DATABASE_LOCATION:String = "database";
		
		/**
		 * Constant used to save to the server
		 * */
		[Transient]
		public static const REMOTE_LOCATION:String = "remote";
		
		/**
		 * Constant used to save to the server
		 * */
		[Transient]
		public static const ALL_LOCATIONS:String = "all";
		
		/**
		 * Used to set the type of category used for projects on the server
		 * */
		[Transient]
		public static const PROJECT_CATEGORY:String = "project";
		
		/**
		 * Used to set the type of category used for documents on the server
		 * */
		[Transient]
		public static const DOCUMENT_CATEGORY:String = "document";
		
		public static var DefaultDocumentType:Object;

		private var _description:String;

		/**
		 * Description
		 * */
		public function get description():String {
			return _description;
		}

		/**
		 * @private
		 */
		public function set description(value:String):void {
			_description = value;
		}

		private var _post:Object;

		/**
		 * Data object from WordPress representing the post object
		 * */
		public function get post():Object
		{
			return _post;
		}

		/**
		 * @private
		 */
		public function set post(value:Object):void
		{
			_post = value;
		}

		
		private var _file:FileReference;

		/**
		 * File reference
		 * */
		public function get file():FileReference {
			return _file;
		}

		/**
		 * @private
		 */
		public function set file(value:FileReference):void {
			_file = value;
		}
		
		private var _template:String;

		public function get template():String
		{
			return _template;
		}

		public function set template(value:String):void
		{
			_template = value;
		}
		
		private var _isExample:Boolean;
		
		public function get isExample():Boolean {
			return _isExample;
		}
		
		public function set isExample(value:Boolean):void {
			_isExample = value;
		}

		
		private var _source:String;

		/**
		 * 
		 * */
		public function get source():String {
			return _source;
		}

		/**
		 * @inheritDoc
		 */
		public function set source(value:String):void {
			_source = value;
		}

		
		private var _originalSource:String;

		/**
		 * 
		 * */
		public function get originalSource():String {
			return _originalSource;
		}

		/**
		 * @inheritDoc
		 */
		public function set originalSource(value:String):void {
			_originalSource = value;
		}
		
		private var _assets:Array = [];

		public function get assets():Array {
			return _assets;
		}

		public function set assets(value:Array):void {
			_assets = value;
		}
		

		private var _document:IDocument;

		/**
		 * @inheritDoc
		 * */
		[Transient]
		public function get document():IDocument {
			return _document;
		}

		public function set document(value:IDocument):void {
			_document = value;
		}
		
		private var _isChanged:Boolean;

		/**
		 * Indicates if the document is changed or dirty
		 * */
		public function get isChanged():Boolean {
			return _isChanged;
		}

		/**
		 * @private
		 */
		[Bindable]
		public function set isChanged(value:Boolean):void {
			_isChanged = value;
		}
		
		/**
		 * Sets the isChanged property to true. 
		 * */
		public function markDirty():void {
			isChanged = true;
		}
		
		/**
		 * Sets the isChanged property to false. 
		 * */
		public function markClean():void {
			isChanged = false;
		}
		
		private var _saveSuccessful:Boolean;

		/**
		 * @inheritDoc
		 * */
		[Transient]
		public function get saveSuccessful():Boolean {
			return _saveSuccessful;
		}

		public function set saveSuccessful(value:Boolean):void {
			_saveSuccessful = value;
		}

		
		private var _saveInProgress:Boolean;

		/**
		 * Indicates if a save is in progress. 
		 * */
		[Bindable]
		[Transient]
		public function get saveInProgress():Boolean {
			return _saveInProgress;
		}

		public function set saveInProgress(value:Boolean):void {
			_saveInProgress = value;
		}
		
		private var _openSuccessful:Boolean;

		/**
		 * Indicates if open was successful.
		 * */
		[Transient]
		public function get openSuccessful():Boolean {
			return _openSuccessful;
		}

		public function set openSuccessful(value:Boolean):void {
			_openSuccessful = value;
		}

		private var _openInProgress:Boolean;

		/**
		 * Indicates if open is in progress.
		 * */
		[Bindable]
		public function get openInProgress():Boolean {
			return _openInProgress;
		}

		public function set openInProgress(value:Boolean):void {
			_openInProgress = value;
		}
		
		public var firstTimeSave:Boolean;

		
		private var _saveService:IWPService;

		/**
		 * Service that saves to WP installation
		 * */
		[Transient]
		public function get saveService():IWPService {
			return _saveService;
		}

		/**
		 * @private
		 */
		public function set saveService(value:IWPService):void {
			_saveService = value;
		}

		/**
		 * Used to open document
		 * */
		public var openService:WPService;
		
		/**
		 * @inheritDoc
		 * */
		public function save(locations:String = LOCAL_LOCATION, options:Object = null):Boolean {
			var saveRemote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var saveLocally:Boolean = ServicesManager.getIsLocalLocation(locations);
			var form:URLVariables;
			
			// if importing document but save doesn't happen while online
			if (uid=="null" || uid==null) {
				uid = createUID();
			}
			
			if (saveRemote) {
			//Radiate.info("Save");
				// we need to create service
				if (saveService==null) {
					saveService = new WPService();
					saveService.host = host;
					saveService.addEventListener(WPServiceBase.RESULT, saveResultsHandler, false, 0, true);
					saveService.addEventListener(WPServiceBase.FAULT, saveFaultHandler, false, 0, true);
				}
				
				saveSuccessful = false;
				saveInProgress = true;
				
				form = toSaveFormObject();
				
				// check that it's valid XML before saving
				if (id!=null && !originalSource && !XMLUtils.isValidXML(form['custom[source]'])) {
					var error:Object = XMLUtils.validationError;
					error = XMLUtils.validationErrorMessage;
					Radiate.error("XML is invalid. Not saving. " + XMLUtils.validationErrorMessage + " Please report error with XML code below: \n"+form['custom[source]']);
					saveFaultHandler(null);
					return false;
				}
				
				// save project
				saveService.save(form);
			}
			
			if (saveLocally) {
				// check if remote id is not set. 
				// if we can't save remotely we should still save locally
				// but if we can save remotely and we need to save
				// again when we have an id from the server
				var result:Boolean = saveDocumentLocally()
				return result;
			}
			
			return false;
		}
		
		/**
		 * Open 
		 * */
		public function open(location:String = null):void {
			var loadRemote:Boolean = ServicesManager.getIsRemoteLocation(location);
			var loadLocally:Boolean = ServicesManager.getIsLocalLocation(location);
			
			if (location==REMOTE_LOCATION) {
				//Radiate.info("Open Document Remote");
				retrieve();
			}
			else if (location==LOCAL_LOCATION) {
				//var documentData:IDocumentData = Radiate.instance.getDocumentLocally(this);
				//Radiate.info("Open Document Local");
			}
			else {
				//Radiate.info("Open Document normal");
				//source = getSource();
			}
			
			isOpen = true;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function close():void {
			//Radiate.info("Close Document");
			source = getSource();
			isOpen = false;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function retrieve(local:Boolean = false):void {
			var form:Object;
			
			// we need to create service
			if (openService==null) {
				openService = new WPService();
				openService.addEventListener(WPServiceBase.RESULT, openResultsHandler, false, 0, true);
				openService.addEventListener(WPServiceBase.FAULT, openFaultHandler, false, 0, true);
			}
			
			openService.host = host;
			
			openSuccessful = false;
			openInProgress = true;
			
			form = toLoadFormObject();
			
			// open project
			openService.open(id, false);
		}
		
		/**
		 * Creates an object to send to the server
		 * */
		public function toSaveFormObject():URLVariables {
			var object:URLVariables = new URLVariables();
			var value:String = getSource(); // move this to Radiate.saveFunction()
			object.title = name;
			//object.content = value;
			object.categories = "document";
			
			if (id) 		object.id 		= id;
			if (status)		object.status 	= status;
			//object.type 	= "page";
			
			object["custom[uid]"] = uid;
			//object["custom[sponge]"] = 1;
			//object["custom[sandpaper]"] = 1;
			
			if (value==null || value=="") {
				//trace("Saved source code is null");
			}
			else {
				object["custom[source]"] = value;
			}
			
			if (revisions) {
				object["custom[revisions]"] = JSON.stringify(revisions);
			}
			
			return object;
		}
		
		/**
		 * Creates an object to send to the server
		 * */
		public function toLoadFormObject():Object {
			var object:Object = {};
			
			if (id) object.id = id;
			
			return object;
		}
		
		/**
		 * Result from save result
		 * */
		public function saveResultsHandler(event:IWPServiceEvent):void {
			var saveResultsEvent:SaveResultsEvent = new SaveResultsEvent(SaveResultsEvent.SAVE_RESULTS);
			var data:Object = event.data;
			var post:Object = data ? data.post : null;
			//Radiate.info("Save result handler on document " + name);
			
			saveResultsEvent.call = event.call;
			saveResultsEvent.data = event.data;
			saveResultsEvent.message = event.message;
			saveResultsEvent.text = event.text;
			//trace("- DocumentData save results handler " + name);
			
			if (post) {
				//trace("- - document id " + id);
				//trace("- - post id " + post.id);
				if (id==null || id=="") {
					//Radiate.info("Document does not have an id. Needs to be resaved: "+ name);
					id = post.id;
					// we don't have id so we need to save again
					// doing it in the sub classes because we need to 
					// update the source (for project)
					//save(REMOTE_LOCATION);
					//return;
				}
				
				//trace("- - document uri " + uri);
				//trace("- - post url " + post.url);
				uri = post.url;
				status = post.status;
				
				saveResultsEvent.successful = true;
				saveSuccessful = true;
				//Radiate.info("Document saved: "+ name);
				markClean();
				
				DateManager.setLastSaveDate();
			}
			else {
				saveSuccessful = false;
				//Radiate.info("Document not saved: "+ name);
			}
			
			
			saveInProgress = false;
			
			dispatchEvent(saveResultsEvent);
		}
		
		/**
		 * Result from save fault
		 * */
		public function saveFaultHandler(event:IServiceEvent):void {
			var saveResultsEvent:SaveResultsEvent = new SaveResultsEvent(SaveResultsEvent.SAVE_RESULTS);
			var service:IWPService = saveService;
			var errorEvent:Object = service && "errorEvent" in service ? WPService(service).errorEvent : null;
			var errorID:int;
			var errorText:String;
			var errorType:String;
			
			if (errorEvent) {
				errorText = "text" in errorEvent ? errorEvent.text : "";
				errorText = "message" in errorEvent ? errorEvent.message : errorText;
				errorID = "errorID" in errorEvent ? errorEvent.errorID : 0;
				errorType = "type" in errorEvent ? errorEvent.type : "";
				
				Radiate.error("Error when saving document: "+ name + ". You may be disconnected. Check your connection and try again", errorEvent);
			}
			else {
				Radiate.error("Error when trying to save document: "+ name + ".", saveResultsEvent);
			}
			
			saveInProgress = false;
			
			saveResultsEvent.faultEvent = event as Event;
			saveResultsEvent.errorEvent = errorEvent;
			
			dispatchEvent(saveResultsEvent);
		}
		
		/**
		 * Result from open result
		 * */
		public function openResultsHandler(event:IServiceEvent):void {
			var openResultsEvent:LoadResultsEvent = new LoadResultsEvent(LoadResultsEvent.LOAD_RESULTS);
			var data:Object = event.data;
			var post:Object;
			var error:String;
			var hasError:Boolean;
			
			//Radiate.log..info("Open result handler on document " + name);
			// when the post id was null then we ended up receiving the latest post 
			
			if (data) {
				
				if (data.error) {
					if (data.status=="error" || data.error=="Not found.") {
						error = data.error;
						hasError = true;
					}
				}
				// if we switched to pages we assign data.post 
				// so we assign page to data.post so we can continue to use the same code 
				if (data.page) {
					data.post = data.page;
					//unmarshallPost(data.page);
				}
				
				if (data.post) {
					unmarshallPost(data.post);
					
					openResultsEvent.successful = true;
					openSuccessful = true;
				}
				else {
					openResultsEvent.successful = false;
					openSuccessful = false;
				}
				//Radiate.info("Document open: "+ name);
			}
			else {
				
				if (event is WPServiceEvent) {
					openResultsEvent.message = WPServiceEvent(event).message;
				}
				//Radiate.info("Document not opened: "+ name);
			}
			
			// add assets
			LibraryManager.addAssetsToDocument(assets, this);
			
			openResultsEvent.hasError = hasError;
			openResultsEvent.data = data;
			openResultsEvent.text = event.text;
			openResultsEvent.message = WPServiceEvent(event).message ? WPServiceEvent(event).message : null;
			openInProgress = false;
			
			isOpen = true;
			dispatchEvent(openResultsEvent);
		}
		
		/**
		 * Get values from WordPress post object
		 * */
		public function unmarshallPost(value:Object):void {
			post = value; //TODO create value object
			
			status = post.status;
			
			// why aren't we setting the id here?
			if (id==null) {
				id = post.id;
			}
			
			uri = post.url;
			
			if (post.title) {
				name = post.title;
			}
			
			// we don't use post.content because 
			// content is formatted and modified by WordPress
			// UPDATE: using custom fields
			//source = data.post.content;
			if ("source" in post.custom_fields) {
				source = post.custom_fields.source;
				template = post.custom_fields.template!="null" ? post.custom_fields.template : template;
				originalSource = source;
			}
			else {
				source = post.content;
			}
			
			// this is because WP adds formating to the content
			// there is a plugin that disables formatting that was enabled on the site but not currently
			// but you have to set custom fields on the post to enable it
			// this should eventually be fixed
			// UPDATE: using custom fields now
			/*
			if (source.indexOf("<p>")==0) {
				source = source.substr(3);
				var li:int = source.lastIndexOf("</p>");
				source = source.substr(0, li);
			}
			*/
			
			//if (source.indexOf("<br />")!=-1) {
			//	source = source.replace(/<br \/>/g, "");
			//}
			
			if (post.attachments && post.attachments.length>0) {
				parseAttachments(post.attachments);
			}
			
			if (REVISIONS in post.custom_fields) {
				var revisionsObject:Object = JSON.parse(post.custom_fields[REVISIONS]);
				var object:Object;
				var revision:DocumentRevision;
				revisions = [];
				
				for each (object in revisionsObject) {
					revision = DocumentRevision.unmarshall(object);
					revisions.push(revision);
				}
				
			}
		}
		
		/**
		 * Result from open fault
		 * */
		public function openFaultHandler(event:IServiceEvent):void {
			var openResultsEvent:OpenResultsEvent = new OpenResultsEvent(SaveResultsEvent.SAVE_RESULTS);
			
			Radiate.info("Error when trying to open document: "+ name + ".");
			
			saveInProgress = false;
			
			dispatchEvent(openResultsEvent);
		}
		
		/**
		 * Parses attachments
		 * */
		public function parseAttachments(attachments:Array):void {
			var numberOfAttachments:int;
			var object:Object;
			var attachmentData:AttachmentData;
			numberOfAttachments = attachments ? attachments.length : 0;
			
				
			for (var i:int;i<numberOfAttachments;i++) {
				object = attachments[i];
				
				if (String(object.mime_type).indexOf("image/")!=-1) {
					attachmentData = new ImageData();
					attachmentData.unmarshall(object);
				}
				else {
					attachmentData = new AttachmentData();
					attachmentData.unmarshall(object);
				}
				
				addAsset(attachmentData);
			}
		}
		
		/**
		 * Add an asset
		 * */
		public function addAsset(asset:AttachmentData):Boolean {
			var numberOfAssets:int = assets ? assets.length:0;
			var exists:Boolean;
			
			for (var i:int;i<numberOfAssets;i++) {
				if (assets[i].id==asset.id) {
					exists = true;
					break;
				}
			}
			
			if (!exists) {
				assets.push(asset);
				return true;
			}
			
			return false;
		}
		
		/**
		 * Removes an asset
		 * */
		public function removeAsset(asset:AttachmentData):Boolean {
			var length:int = assets ? assets.length:0;
			var exists:Boolean;
			
			for (var i:int;i<length;i++) {
				if (assets[i].id==asset.id) {
					exists = true;
					break;
				}
			}
			
			if (exists) {
				assets.splice(i, 1);
				return true;
			}
			
			return false;
		}

		/**
		 * Get source code for document. 
		 * If document isn't created yet get last stored source code
		 * 
		 * This is overridden in Document
		 * TODO test this
		 * */
		public function getSource(target:Object = null):String {
			
			// if document isn't created yet get stored source code - refactor
			if (!document) {
				return source;
			}
			/*else {
				return internalExporter.exportXMLString(this);
			}*/
			
			// you are in DocumentData
			return source;
			//throw new Error("GetSource not implemented. Override in sub class");
		}
		
		
		/**
		 * Serialize. Export for saving to disk or server
		 * */
		override public function marshall(dataType:String = DOCUMENT_TYPE, representation:Boolean = false):Object {
			var object:Object;
			
			// if string type get xml object. we will translate later
			if (dataType==STRING_TYPE || dataType==XML_TYPE) {
				object = super.marshall(XML_TYPE, representation);
			}
			
			if (dataType==METADATA_TYPE) {
				object = super.marshall(METADATA_TYPE, representation);
				return DocumentMetaData(object);
			}
			else if (dataType==DOCUMENT_TYPE) {
				// get default document data information
				object = super.marshall(METADATA_TYPE, representation);
				var documentData:DocumentData = new DocumentData();
				documentData.unmarshall(object);
				documentData.source = getSource();
			
				return DocumentData(documentData);
			}
			else if (dataType==STRING_TYPE || dataType==XML_TYPE ) {				
				var xml:XML = object as XML;
				
				// add source
				if (!representation) {
					//source = getSource();
					
					if (source) {
						//xml = XMLUtils.setItemContents(xml, "source", source);
					}
				}
				
				
				if (dataType==STRING_TYPE) {
					return xml.toXMLString();
				}
				
				return xml;
			}
			
			return object;
		}
		
		/**
		 * Deserialize document data. Import.
		 * */
		override public function unmarshall(data:Object):void {
			super.unmarshall(data);
			
			// this should probably be overriden by sub classes
			if (data is IDocumentData) {
				source 	= data.source;
				notes = data.notes;
			}
			else if (data is XML) {
				source 	= data.content;
				notes = data.notes;
				originalSource = XML(data).toXMLString();
			}
		}
		
		/**
		 * Get basic project metadata
		 * */
		public function toMetaData():IDocumentMetaData {
			return marshall(METADATA_TYPE, true) as IDocumentMetaData;
		}
		
		/**
		 * Exports to XML
		 * */
		public function toXML(representation:Boolean = false):XML {
			return marshall(XML_TYPE, representation) as XML;
		}

		/**
		 * Exports an XML string.
		 * If representation is true then just returns just enough basic information to locate it. 
		 * */
		override public function toString():String {
			return marshall(STRING_TYPE, false) as String;
		}
		
		/**
		 * Creates an instance of the document type
		 * */
		public function createInstance(data:Object = null):IDocument {
			var iDocument:IDocument;
			var hasDefinition:Boolean = ApplicationDomain.currentDomain.hasDefinition(className);
			var DocumentType:Object = Document;
			
			if (hasDefinition) {
				DocumentType = ApplicationDomain.currentDomain.getDefinition(className);
			}
			
			iDocument = new DocumentType();
			
			if (data) {
				iDocument.unmarshall(data);
			}
			
			
			return iDocument;
		}
		
		/**
		 * Save document locally
		 * */
		public function saveDocumentLocally():Boolean {
			// for now just passing to saveDocument
			var result:Boolean = SettingsManager.saveDocumentLocally(this);
			
			
			/*var result:Object = SharedObjectUtils.getSharedObject(SAVED_DATA_NAME);
			var so:SharedObject;
			
			if (result is SharedObject) {
				updateSaveDataForDocument(document);
				so = SharedObject(result);
				so.setProperty(SAVED_DATA_NAME, savedData);
				so.flush();
				//log.info("Saved Data: " + ObjectUtil.toString(so.data));
			}
			else {
				log.error("Could not save data. " + ObjectUtil.toString(result));
				//return false;
			}
			
			return true;*/
			return result;
		}
		
		private var _revisions:Array = []
		public function get revisions():Array
		{
			return _revisions;
		}

		public function set revisions(value:Array):void
		{
			_revisions = value;
		}

;
		public function addRevision(revision:DocumentRevision):void {
			if (revisions) {
				revisions.push(revision);
			}
		}
	}
}