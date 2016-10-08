
package com.flexcapacitor.model {
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.managers.ServicesManager;
	import com.flexcapacitor.services.IServiceEvent;
	import com.flexcapacitor.services.IWPServiceEvent;
	import com.flexcapacitor.utils.XMLUtils;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.URLVariables;
	
	/**
	 * Dispatched when a project has been saved
	 * */
	[Event(name="projectSaved", type="com.flexcapacitor.model.SaveResultsEvent")]
	
	/**
	 * Dispatched when project is opened
	 * */
	[Event(name="projectOpened", type="flash.events.Event")]
	
	/**
	 * Project model
	 * */
	public class Project extends ProjectData implements IProject, ISavable {
		
		/**
		 * Constructor
		 * */
		public function Project() {
			super();
			nodeName = "project";
			nameIndex++;
		}
		
		public static var PROJECT_OPENED:String = "projectOpened";
		public static var PROJECT_SAVED:String = "projectSaved";
		
		/**
		 * Used when creating incremental project names
		 * */
		public static var nameIndex:int;
		

		/**
		 * Identity of post that is the home page for this project. Default is 0. 
		 * */
		public function get homePage():int {
			return _homePage;
		}

		/**
		 * @private
		 */
		public function set homePage(value:int):void {
			_homePage = value;
		}
		private var _homePage:int;

		
		/**
		 * Used when creating incremental document names
		 * */
		public var documentNameIndex:int;
		
		/**
		 * Default name for new documents
		 * */
		public var defaultDocumentName:String = "Document";
		
		/**
		 * Set to true when saving because we need to wait until we get IDs for the documents
		 * */
		private var deferSave:Boolean;
		
		/**
		 * Set to true when saving because we need to wait until we get IDs for the documents
		 * */
		private var deferSaveLocations:String;
		
		
		private var _documentsMetaData:Array = [];

		/**
		 * Array of documents meta data
		 * */
		public function get documentsMetaData():Array {
			return _documentsMetaData;
		}

		public function set documentsMetaData(value:Array):void {
			_documentsMetaData = value;
		}


		private var _projectData:IProjectData;

		/**
		 * Defines the last restored saved project data object
		 * */
		public function get projectData():IProjectData {
			return _projectData;
		}

		/**
		 * @private
		 */
		public function set projectData(value:IProjectData):void {
			_projectData = value;
		}

		/**
		 * Create unique document name
		 * */
		public function createDocumentName(document:IDocument = null):String {
			var name:String;
			
			if (document) {
				name = document.name ? document.name : defaultDocumentName;
			}
			
			var length:int = documents.length;
			
			for (var i:int;i<length;i++) {
				if (IDocument(documents[i])!=document) {
					if (name==IDocument(documents[i]).name) {
						name = name + " " + ++documentNameIndex; // update name
						i = 0; // start over checking again 
					}
				}
			}
			
			return name;
			
		}
		
		/**
		 * Adds a document if it hasn't been added yet
		 * */
		public function addDocument(document:IDocument, overwrite:Boolean = false):void {
			var exists:Boolean = getDocumentExists(document);
			
			if (!exists || overwrite) {
				
				if (exists && overwrite) {
					var documentToRemove:IDocumentData = getDocumentByUID(document.uid);
					removeDocument(documentToRemove);
				}
				
				documents.push(document);
				document.name = createDocumentName(document);
				document.project = this;
				document.projectID = uid;
				isChanged = true;
			}
			else {
				Radiate.info("Document already added");
			}
		}
		
		/**
		 * Remove a document 
		 * */
		public function removeDocument(document:IDocumentData):void {
			var documentIndex:int = getDocumentIndexByUID(document.uid);
			
			if (documentIndex!=-1) {
				var removedArray:Array = documents.splice(documentIndex, 1);
				
				if (removedArray.length!=0 && removedArray[0]==document) {
					//Radiate.info("Document removed " + document.name);
				}
				isChanged = true;
			}
			else {
				//Radiate.info("Document not removed " + document.name);
			}
		}
		
		/**
		 * Imports documents 
		 * */
		public function importDocumentInstances(documentsToImport:Array, overwrite:Boolean = false):void {
			var metaDataLength:int = documentsMetaData.length;
			var iDocument:IDocument;
			var currentDocumentData:IDocumentData;
			var iDocumentMetaData:IDocumentMetaData;
			var documentsDataArrayLength:int;


			// loop through project's documents metadata
			for (var i:int;i<metaDataLength;i++) {
				iDocumentMetaData = IDocumentMetaData(documentsMetaData[i]);
				documentsDataArrayLength = documentsToImport.length;
				j = 0;
				
				// loop through all documents for match with project that owns document
				for (var j:int;j<documentsDataArrayLength;j++) {
					iDocument = IDocument(documentsToImport[j]);
					
					
					if (iDocument.uid == iDocumentMetaData.uid) {
						//iDocument = currentDocumentData;
						// should be created already
						/*if (!(currentDocumentData is IDocument)) {
							iDocument = currentDocumentData.createInstance(currentDocumentData);
						}*/
						
						//Radiate.instance.addDocument(iDocument, this);
						//Radiate.instance.openDocument(iDocument);
						
						addDocument(iDocument);//changed to document from documentdata
						//log.info("  document added: " + iDocumentData.name);
					}
					else {
						//log.info("  document not added. " + iDocumentData.name);
					}
				}
			}
		}
		
		/**
		 * Opens a document if it isn't already open
		 * */
		public function openDocument(document:IDocument, overwrite:Boolean = false):void {
			//document.open();
			//Radiate.instance.openDocument(document);
		}
		
		/**
		 * Returns true if the document data is contained in the documents array
		 * */
		public function getDocumentExists(data:IDocumentMetaData):Boolean {
			var length:int = documents.length;
			
			for (var i:int;i<length;i++) {
				if (IDocumentData(documents[i]).uid == data.uid) {
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Returns true if the document exists in the documents array
		 * */
		public function getDocumentExistsByID(uid:String):Boolean {
			var length:int = documents.length;
			
			for (var i:int;i<length;i++) {
				if (IDocumentData(documents[i]).uid == uid) {
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Returns the document if it exists or null if not
		 * */
		public function getDocumentByUID(uid:String):IDocumentData {
			var length:int = documents.length;
			
			for (var i:int;i<length;i++) {
				if (IDocumentData(documents[i]).uid == uid) {
					return IDocumentData(documents[i]);
				}
			}
			
			return null;
		}
		
		
		/**
		 * Returns the document index
		 * */
		public function getDocumentIndexByUID(uid:String):int {
			var length:int = documents.length;
			
			for (var i:int;i<length;i++) {
				if (IDocumentData(documents[i]).uid == uid) {
					return i;
				}
			}
			
			return -1;
		}
		
		/**
		 * @inheritDoc
		 * */
		override public function toXML(representation:Boolean = false):XML {
			return marshall(XML_TYPE, representation) as XML;
		}
		
		/**
		 * @inheritDoc
		 * */
		override public function toString():String {
			
			return marshall(STRING_TYPE, true) as String;
			
			/*var documentData:IDocumentData;
			var documentXML:String;
			var xml:XML = new XML(<project/>);
			
			xml.@host = host;
			xml.@id = id;
			xml.@name = name;
			xml.@URI = URI;
			xml.@uid = uid;
			xml.documents = new XML(<documents/>);
			xml.@dateSaved = getTimeInHistory();
			
			if (!representation) {
				for (var i:int;i<documents.length;i++) {
					documentData = documents[i];
					documentXML = documentData.toMXMLString(true);
					XML(xml.documents).appendChild( new XML(documentXML) );
				}
			}
			else {
				throw new Error("Representative XML is not implemented");
			}
			
			return xml.toXMLString();*/
		}
		
		
		/**
		 * Get source code for document. 
		 * Don't really like the way I'm doing this.
		 * I think it would be better to keep exporting and importing to external classes
		 * */
		/*override public function getSource(target:Object = null):String {
			var documentData:IDocumentData;
			var documentXML:String;
			var xml:XML = new XML(<project/>);
			
			xml.@host = host;
			xml.@id = id;
			xml.@name = name;
			xml.@uri = uri;
			xml.@uid = uid;
			xml.@dateSaved = getTimeInHistory();
			
			//if (!representation) {
				xml.documents = new XML(<documents/>);
				
				for (var i:int;i<documents.length;i++) {
					documentData = documents[i];
					documentXML = documentData.marshall(METADATA_TYPE, true);
					XML(xml.documents).appendChild( new XML(documentXML) );
				}
				
				for (var m:int;m<documents.length;m++) {
					documentData = IDocumentData(documents[m]);
					documentXML = XML(documentData.marshall(XML_TYPE, true));
					XML(xml.documents).appendChild( documentXML );
				}
			//}
			
			return xml.toXMLString();
			
		}*/
		
		
		/**
		 * Serialize project data for saving. Export.
		 * */
		override public function marshall(format:String = PROJECT_TYPE, representation:Boolean = false):Object {
			var documentsCount:int = documents.length;
			var documentsArray:Array = [];
			var documentData:IDocumentData;
			var projectData:ProjectData;
			var object:Object;
			
			// if string type get xml object. we will translate later
			if (format==STRING_TYPE || format==XML_TYPE ) {
				object = super.marshall(XML_TYPE, representation);
			}
			
			if (format==PROJECT_TYPE || format==METADATA_TYPE) {
				// get default document data information
				object = super.marshall(DOCUMENT_TYPE, representation);
				projectData = new ProjectData();
				projectData.unmarshall(object);
				
				for (var i:int;i<documentsCount;i++) {
					documentData = IDocumentData(documents[i]);
					documentsArray.push(documentData.marshall(METADATA_TYPE, true));
				}
				
				// we're saving meta data but for readability we call it documents
				projectData.documents = documentsArray;
			
				return projectData;
			}
			else if (format==STRING_TYPE || format==XML_TYPE ) {
				var documentXML:XML;
				var xml:XML = XML(object);
				
				xml.documents = new XML(<documents/>);
				
				//if (!representation) {
					for (var m:int;m<documents.length;m++) {
						documentData = IDocumentData(documents[m]);
						documentXML = XML(documentData.marshall(XML_TYPE, true));
						XML(xml.documents).appendChild( documentXML );
					}
				//}
				
				if (format==STRING_TYPE) {
					return xml.toXMLString();
				}
				
				if (format==XML_TYPE) {
					return xml;
				}
			}
			
			
			return object;
		}
		
		/**
		 * Deserialize project data. 
		 * */
		override public function unmarshall(data:Object):void {
			super.unmarshall(data);
			
			
			if (data is IDocumentMetaData || data is IDocumentData) {
				
				if (data is IDocumentData) {
					source = data.source;
				}
				
				if (data is IProjectData) {
					documentsMetaData = IProjectData(data).documents;
				}
				
				if (data.homePage) {
					homePage = data.homePage;
				}
			}
			else if (data is XML) {
				var documentsMetaDataList:XMLList = data.documents.document;
				
				source = XML(data).toXMLString();
				originalSource = XML(data).toXMLString();
				
				if (data && XMLUtils.hasAttribute(data as XML, "homePage")) {
					homePage = data.@homePage;
				}
				
				if (data && documentsMetaDataList.length()>0) {
					var documentsCount:int = documentsMetaDataList.length();
					var documentMetaData:DocumentMetaData;
					var documentXML:XML;
					var dateCreated:int;
					
					
					for (var i:int;i<documentsCount;i++) {
						documentXML = XML(documentsMetaDataList[i]);
						documentMetaData = new DocumentMetaData();
						documentMetaData.unmarshall(documentXML);
						documentsMetaData.push(documentMetaData);
					}
				}
			}
			/*
			var iProjectData:IProjectData = data as IProjectData;
			
			if (iProjectData) {
				projectData = iProjectData;
				documentsMetaData = iProjectData.documents;
			}*/
		}
		
		/**
		 * Deserialize XML project data. 
		 * NOTE: TODO. We need to keep these in sync with the object representation. 
		 * */
		/*public function unmarshallXML(data:XML):void {
			super.unmarshallXML(data);
			
			var documentsList:XMLList = data.documents.document;
			var documentXML:XML;
			var documentData:DocumentData;
			var dateCreated:int;
			
			if (data && documentsList.length()>0) {
				
				var length:int = documentsList.length();
				for (var i:int;i<length;i++) {
					
					documentXML = XML(documentsList[i]);
					documentData = new DocumentData();
					documentData.unmarshallXML(documentXML);
					documentsMetaData.push(documentData);
					//dateSaved = documentData.dateSaved;
					//Radiate.instance.createDocumentFromData(documentData);
					//Radiate.instance.addDocument(documentData.document);
				}
			}
		}*/
		
		/**
		 * @inheritDoc
		 * */
		override public function close():void {
			super.close();
			isOpen = false;
		}
		
		/**
		 * @inheritDoc
		 * */
		override public function open(location:String = REMOTE_LOCATION):void {
			var numberOfDocuments:int = documents.length; //fromMetaData ? documentsMetaData.length : documents.length;
			var documentsArray:Array = documents; //fromMetaData ? documentsMetaData : documents;
			var documentMetaData:IDocumentMetaData;
			var documentData:IDocumentData;
			var iDocument:IDocument;
			var documentCreated:Boolean;
			var isRemote:Boolean = ServicesManager.getIsRemoteLocation(location);
			var isLocal:Boolean = ServicesManager.getIsLocalLocation(location);
			var isInternal:Boolean = ServicesManager.getIsInternalLocation(location);
			
			// do documents have remote ID? if so we have to open from the server
			var needToWaitForDocumentsOpenResults:Boolean;
			
			// should set isOpen to true
			isOpen = true;
			
			//Radiate.instance.openPreviouslyOpenDocuments();
			
			
			// open documents
			
			//if (!fromMetaData) {
			
			if (openAllDocumentOnOpen) {
				
				for (var i:int;i<numberOfDocuments;i++) {
					iDocument = IDocument(documentsArray[i]);
					
					
					if (isRemote) {
						//documentCreated = getDocumentExists(iDocument);
						
						//if (!documentCreated) {
						
						if (iDocument && !iDocument.isOpen && iDocument.id!=null) {
							
							if (iDocument) {
								DocumentData(iDocument).addEventListener(LoadResultsEvent.LOAD_RESULTS, documentRetrievedResultsHandler, false, 0, true);
 							}
							
							//Radiate.info("calling retrieve on document " + iDocument.name);
							iDocument.retrieve();
						}
						
						//}
						//else {
							//iDocument = getDocumentByID(documentMetaData.uid);
							//iDocument.open();
							//Radiate.instance.openDocumentByData(iDocument, true);
						//}
					}
					else if (isLocal) {
						iDocument.open(DocumentData.LOCAL_LOCATION);
						Radiate.instance.openDocumentByData(iDocument, true, true);
					}
					else if (isInternal) {
						iDocument.open();
						Radiate.instance.openDocument(iDocument, location, true);
					}
				}
			}
			
			/*	
			}
			else {
				
				for (var j:int;j<length;j++) {
					documentMetaData = IDocumentMetaData(documentsArray[j]);
					
					documentCreated = getDocumentExists(documentMetaData);
					
					if (!documentCreated) {
						if (documentData is DocumentData) {
							DocumentData(documentData).addEventListener(DocumentData.RETRIEVED_RESULTS, documentRetrievedResultsHandler, false, 0, true);
						}
						
						Radiate.info("calling retrieve on document " + documentData.name);
						documentData.retrieve();
					}
					else {
						iDocument = getDocumentByID(documentMetaData.uid);
						iDocument.open();
						Radiate.instance.openDocumentByData(iDocument, true);
					}
				}
			}*/
			
			/*
			if (!needToWaitForDocumentsOpenResults) {
				//super.open(local);
			}
			else {
				// we need to open the project with the remote ID
				deferOpen = true;
			}*/
		
		}
		
		/**
		 * Open all documents when open() is called
		 * */
		public var openAllDocumentOnOpen:Boolean = true;
		
		public var openDocumentOnResults:Boolean;

		public var allDocumentsSaved:Boolean;
		
		/**
		 * @inheritDoc
		 * */
		public function openAllDocuments(location:String = REMOTE_LOCATION):void {
			var numberOfDocuments:int = documents.length; //fromMetaData ? documentsMetaData.length : documents.length;
			var documentsArray:Array = documents; //fromMetaData ? documentsMetaData : documents;
			var documentMetaData:IDocumentMetaData;
			var documentData:IDocumentData;
			var iDocument:IDocument;
			var documentCreated:Boolean;
			var isRemote:Boolean = ServicesManager.getIsRemoteLocation(location);
			var isLocal:Boolean = ServicesManager.getIsLocalLocation(location);
			var isInternal:Boolean = ServicesManager.getIsInternalLocation(location);
			
			// do documents have remote ID? if so we have to open from the server
			var needToWaitForDocumentsOpenResults:Boolean;
			
			// should set isOpen to true
			isOpen = true;
			
			//Radiate.instance.openPreviouslyOpenDocuments();
			
			
			// open documents
			//if (!fromMetaData) {
			
			openDocumentOnResults = true;
			var isLoadingDocuments:Boolean;
			
			for (var i:int;i<numberOfDocuments;i++) {
				iDocument = IDocument(documentsArray[i]);
				
				
				if (isRemote) {
					//documentCreated = getDocumentExists(iDocument);
					
					//if (!documentCreated) {
					
					if (iDocument && !iDocument.isOpen && iDocument.id!=null) {
						
						if (iDocument) {
							DocumentData(iDocument).addEventListener(LoadResultsEvent.LOAD_RESULTS, documentRetrievedResultsHandler, false, 0, true);
 						}
						
						//Radiate.info("calling retrieve on document " + iDocument.name);
						iDocument.retrieve();
						isLoadingDocuments = true;
					}
					
				}
				else if (isLocal) {
					iDocument.open(DocumentData.LOCAL_LOCATION);
					Radiate.instance.openDocumentByData(iDocument, true, true);
				}
				else if (isInternal) {
					iDocument.open();
					Radiate.instance.openDocument(iDocument, location, true);
				}
			}
			
			if (!isLoadingDocuments) {
				openDocumentOnResults = false;
			}
			/*	
			}
			else {
				
				for (var j:int;j<length;j++) {
					documentMetaData = IDocumentMetaData(documentsArray[j]);
					
					documentCreated = getDocumentExists(documentMetaData);
					
					if (!documentCreated) {
						if (documentData is DocumentData) {
							DocumentData(documentData).addEventListener(DocumentData.RETRIEVED_RESULTS, documentRetrievedResultsHandler, false, 0, true);
						}
						
						Radiate.info("calling retrieve on document " + documentData.name);
						documentData.retrieve();
					}
					else {
						iDocument = getDocumentByID(documentMetaData.uid);
						iDocument.open();
						Radiate.instance.openDocumentByData(iDocument, true);
					}
				}
			}*/
			
			/*
			if (!needToWaitForDocumentsOpenResults) {
				//super.open(local);
			}
			else {
				// we need to open the project with the remote ID
				deferOpen = true;
			}*/
		
		}
		
		/**
		 * @inheritDoc
		 * */
		public function openFromMetaData(location:String = REMOTE_LOCATION):void {
			var numberOfDocuments:int = documentsMetaData.length;
			var documentsArray:Array = documentsMetaData;
			var documentMetaData:IDocumentMetaData;
			//var documentData:IDocumentData;
			var iDocument:IDocument;
			var iDocumentData:IDocumentData;
			var documentCreated:Boolean;
			var radiate:Radiate = Radiate.getInstance();
			
			// do documents have remote ID? if so we have to open from the server
			var needToWaitForDocumentsOpenResults:Boolean;
			
			// should set isOpen to true
			isOpen = true;
			
			//Radiate.instance.openPreviouslyOpenDocuments();
			
			for (var j:int;j<numberOfDocuments;j++) {
				documentMetaData = IDocumentMetaData(documentsArray[j]);
				
				documentCreated = getDocumentExists(documentMetaData);
				
				if (!documentCreated) {
					iDocument = radiate.createDocumentFromMetaData(documentMetaData);
					
					if (iDocument.id==null || iDocument.id=="") {
						Radiate.error("The document, \"" + iDocument.name + "\" was never saved. You have to remember to save new documents. Please save the project to prevent seeing this error again.");
						continue;
					}
					
					DocumentData(iDocument).addEventListener(LoadResultsEvent.LOAD_RESULTS, documentRetrievedResultsHandler, false, 0, true);
					//Radiate.info("calling retrieve on document " + iDocument.name);
					iDocument.retrieve();
					documents.push(iDocument);
					iDocument.project = this;
					
					/*
					if (documentData.id==null) {
						needToWaitForDocumentsOpenResults = true;
					}*/
				}
				else {
					iDocumentData = getDocumentByUID(documentMetaData.uid);
					iDocumentData.open(location);
					Radiate.instance.openDocumentByData(iDocumentData, true, true);
				}
			}
			
			
			// project is already open...?
			/*if (!needToWaitForDocumentsOpenResults) {
				//super.open(local);
			}
			else {
				// we need to open the project with the remote ID
				deferOpen = true;
			}*/
		
		}
		
		/**
		 * @inheritDoc
		 * */
		override public function retrieve(local:Boolean = false):void {
			var length:int = documentsMetaData.length;
			var documentData:IDocumentData;
			var documentsArray:Array = documents.length ? documents : documentsMetaData;
			
			// do documents have remote ID? if so we have to open from the server
			var needToWaitForDocumentsOpenResults:Boolean = false;
			
			// open documents
			for (var i:int;i<length;i++) {
				documentData = IDocumentData(documentsArray[i]);
				
				if (documentData is DocumentData) {
					DocumentData(documentData).addEventListener(LoadResultsEvent.LOAD_RESULTS, documentRetrievedResultsHandler, false, 0, true);
				}
				
				Radiate.info("calling open on document " + documentData.name);
				documentData.retrieve(local);
				
				if (documentData.id==null || documentData.id=="") {
					needToWaitForDocumentsOpenResults = true;
				}
			}
			
			if (!needToWaitForDocumentsOpenResults) {
				//super.open(local);
			}
			else {
				// we need to open the project with the remote ID
				//deferOpen = true;
			}
		
		}
		
		/**
		 * @inheritDoc
		 * */
		override public function save(locations:String = REMOTE_LOCATION, options:Object = null):Boolean {
			var numOfDocuments:int = documents.length;
			var documentData:IDocumentData;
			var saveRemote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var saveLocally:Boolean = ServicesManager.getIsLocalLocation(locations);
			var savedLocally:Boolean;
			var needToWaitForDocumentsSaveResults:Boolean;
			
			//trace("Project save");
			
			// do all documents have remote ID? if not we have to save again when 
			// we get an ID from the server
			needToWaitForDocumentsSaveResults = false;
			allDocumentsSaved = false;
			
			if (id==null || id=="") {
				firstTimeSave = true;
			}
			
			// if importing projects but save doesn't happen while online
			if (uid=="null" || uid==null) {
				uid = createUID();
			}
			
			// save documents
			for (var i:int;i<numOfDocuments;i++) {
				documentData = IDocumentData(documents[i]);
				
				// gonna save anyway even if not changed bc change system has flaws
				//if (documentData.isChanged || documentData.id==null) {
				//if (documentData.id==null) {
					if (saveRemote && documentData is DocumentData) {
						DocumentData(documentData).addEventListener(SaveResultsEvent.SAVE_RESULTS, documentSaveResultsHandler, false, 0, true);
					}
					
					if (saveRemote && (documentData.id==null || documentData.id=="")) {
						needToWaitForDocumentsSaveResults = true;
					}
					
					Radiate.instance.saveDocument(documentData as IDocument, locations);
				//}
			}
		
			if (!needToWaitForDocumentsSaveResults) {
				savedLocally = super.save(locations);
			}
			else {
				// we need to save the project when we receive the response with the remote ID
				deferSave = true;
				deferSaveLocations = locations;
			}
		
			return savedLocally;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function saveOnlyProject(locations:String = REMOTE_LOCATION, options:Object = null):Boolean {
			var saveRemote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var saveLocally:Boolean = ServicesManager.getIsLocalLocation(locations);
			var savedLocally:Boolean;
			
			if (id==null || id=="") {
				firstTimeSave = true;
			}
			
			// if importing projects but save doesn't happen while online
			if (uid=="null" || uid==null) {
				uid = createUID();
			}
			
			savedLocally = super.save(locations);
			
			return savedLocally;
		}
		
		/**
		 * Creates an object to send to the server
		 * */
		override public function toSaveFormObject():URLVariables {
			var object:URLVariables = super.toSaveFormObject();
			var content:String;
			
			object.categories = PROJECT_CATEGORY;
			content = String(marshall(STRING_TYPE, false));
			object.content = content;
			object["custom[source]"] = content;
			object["custom[homePage]"] = homePage;
			source = content;
			
			return object;
		}
		
		/**
		 * Result from project save fault
		 * */
		override public function saveFaultHandler(event:IServiceEvent):void {
			super.saveFaultHandler(event);
			
			//trace("Save Project Fault");
			Radiate.error("Error when trying to save "+ name + ".");
			deferSave = false;
			dispatchEvent(event as Event);
		}
		
		/**
		 * Result from project save 
		 * */
		override public function saveResultsHandler(event:IWPServiceEvent):void {
			var saveResultsEvent:SaveResultsEvent;
			
			super.saveResultsHandler(event);
			
			//trace(" Project save results id " + id);
			//checkProjectHasChanged();
			markClean();
			
			
			if (firstTimeSave) {
				firstTimeSave = false;
				
				//trace(" Project save results first time save. Resaving.");
				super.save(REMOTE_LOCATION);
				return;
			}
			else {
				deferSave = false;
				dispatchEvent(event as Event);
				//Radiate.instance.setLastSaveDate();
			}
			
			if (allDocumentsSaved) {
				//trace(" Project all documents saved. project id " + id);
				saveResultsEvent = new SaveResultsEvent(PROJECT_SAVED);
				saveResultsEvent.multipleSaved = true;
				dispatchEvent(saveResultsEvent);
				allDocumentsSaved = false;
			}
			
			//Radiate.info("PROJECT - Success saving project "+ name + ".");
		}
		
		/**
		 * Result from open result
		 * */
		override public function openResultsHandler(event:IServiceEvent):void {
			super.openResultsHandler(event);
			
			// add assets
			if (documents.length==0) {
				dispatchProjectOpened();
			}
		}
		
		/**
		 * Project opened. Not sure if this is accurate
		 * Documents may still need to parse their source code
		 * Maybe add event listeners to each document complete event. 
		 * */
		public function dispatchProjectOpened():void {
			//Radiate.info("Project open complete");
			isOpen = true;
			dispatchEvent(new Event(PROJECT_OPENED));
		}
		
		/**
		 * Result from retrieved results
		 * */
		public function documentRetrievedResultsHandler(event:LoadResultsEvent):void {
			var currentDocumentData:IDocumentData;
			var documentsArray:Array;
			var numberOfDocuments:int;
			var documentData:IDocumentData;
			var iDocument:IDocument;
			var resultsNotIn:Array;
			var openNotSuccessful:Array;
			var data:Object;
			var message:String;
			
			
			currentDocumentData = IDocumentData(event.currentTarget);
			documentsArray = documents; //documentsMetaData;//documents.length ? documents : documentsMetaData;
			numberOfDocuments = documentsArray.length;
			resultsNotIn = [];
			openNotSuccessful = [];
			data = event.data;
			
			//Radiate.info("Is document " + event.currentTarget.name + " open: "+ event.successful);
			
			DocumentData(currentDocumentData).removeEventListener(LoadResultsEvent.LOAD_RESULTS, documentRetrievedResultsHandler);
			
			//trace(" Project document retrieved results " + currentDocumentData.id);
			
			// check if all documents have loaded
			for (var i:int;i<numberOfDocuments;i++) {
				documentData = IDocumentData(documentsArray[i]);
				
				if (documentData is DocumentData) {
					
					// check if open is in progress
					if (DocumentData(documentData).openInProgress) {
						resultsNotIn.push(documentData);
					}
					
					// check if open is unsuccessful
					if (!documentData.openSuccessful) {
						openNotSuccessful.push(documentData.name);
					}
				}
			}
			
			if (!currentDocumentData.openSuccessful) {
				currentDocumentData.isOpen = false;
				message = event.message ? event.message : event.text;
				
				Radiate.info("The document '" + currentDocumentData.name + "' could not be loaded because of the following error: " + message);
				
				if (event.faultEvent) {
					Radiate.info(event.faultEvent + "");
				}
			}
			
			// open document now that it's loaded
			// move this to Radiate in project open event (its a new event)
			if (currentDocumentData.openSuccessful) {
				if (!(currentDocumentData is IDocument)) {
					iDocument = currentDocumentData.createInstance(currentDocumentData);
				}
				else {
					iDocument = IDocument(currentDocumentData);
				}
				
				// we are over writing the previous instance - 
				// but should we unmarshall it? 
				Radiate.instance.addDocument(iDocument, this, true);
				currentDocumentData.isOpen = false;
				
				if (openDocumentOnResults) {
					Radiate.instance.openDocument(iDocument);
				}
			}
			
			
			// ALSO NEED TO UPDATE CODE IN OPEN RESULTS HANDLER
			// all documents opened
			if (resultsNotIn.length==0) {
				
				if (openNotSuccessful.length>0) {
					//Radiate.info("These documents could not be opened: " + openNotSuccessful);
					//Radiate.info("Document error occurred for "+documentData.name+": " + event.message);
				}
				
				// open the last document if valid
				if (iDocument) {
					Radiate.instance.openDocument(iDocument);
				}
				
				
				dispatchProjectOpened();
				
				openDocumentOnResults = false;
			}
			
			/*if (deferOpen) {
				super.open();
				deferOpen = false;
			} else {
				
			}*/
		}
		
		/**
		 * Result from save results
		 * */
		public function documentSaveResultsHandler(event:SaveResultsEvent):void {
			//trace("Document save results");
			//Radiate.info("Is document " + event.currentTarget.name + " saved: "+ event.successful);
			var numberOfDocuments:int = documents.length;
			var document:IDocumentData;
			var resultsNotIn:Array = [];
			var unsuccessfulSaves:Array = [];
			var currentDocument:IDocumentData;
			
			
			currentDocument = DocumentData(event.currentTarget);
			
			//trace(" Project document save results current document id " + currentDocument.id);
			
			if (currentDocument is IEventDispatcher) {
				IEventDispatcher(currentDocument).removeEventListener(SaveResultsEvent.SAVE_RESULTS, documentSaveResultsHandler);
			}
			
			for (var i:int;i<numberOfDocuments;i++) {
				document = IDocumentData(documents[i]);
				
				if (document is DocumentData) {
					
					// check if saving is in progress
					if (DocumentData(document).saveInProgress) {
						resultsNotIn.push(document);
					}
					
					// check if save is unsuccessful
					if (!document.saveSuccessful) {
						unsuccessfulSaves.push(document.name);
					}
					else {
						DocumentData(document).markClean();
					}
				}
			}
			
			if (!currentDocument.saveSuccessful) {
				
				if (!Radiate.getInstance().isUserLoggedIn) {
					Radiate.info("The document, '" + currentDocument.name + "' was not saved because the user is not logged in.");
				}
				else {
					Radiate.info("The document, '" + currentDocument.name + "' was not saved because of the following error: " + event.message);
				}
				
				if (event.faultEvent) {
					Radiate.info(event.faultEvent + "");
				}
			}
			
			if (resultsNotIn.length==0) {
				//trace(" Project document save results. all results in. Saving. project id " + id);
				allDocumentsSaved = true;
				super.save(deferSaveLocations);
				return;
				//Radiate.info(name + " save complete");
				
				// if document was not saved recently saveSuccessful may be false?
				if (unsuccessfulSaves.length>0) {
					//Radiate.info("These documents could not be saved: " + unsuccessfulSaves);
				}
				else {
					//isChanged = false; // hardcoding for now until checkProjectHasChanged is fixed
				}
			}
			
			// not sure what's going on here. an attempt was made. 
			if (deferSave) {
				//trace(" Project document save results. Saving. project id " + id);
				super.save(deferSaveLocations);
				deferSave = false;
			} else {
				//trace(" Project document save results. Saving. project id " + id);
				super.save(deferSaveLocations);				
			}
			
			
			
			//DocumentData(document).addEventListener(DocumentData.SAVE_RESULTS, documentSaveResultsHandler, false, 0, true);
			
		}
		
		/**
		 * Check if project source has changed
		 * */
		public function checkProjectHasChanged():Boolean {
			//var content:String = String(marshall(STRING_TYPE, false));
			var contentXML:XML = XML(marshall(XML_TYPE, false));
			var sourceXML:XML = new XML(source);
			var pattern:RegExp = / dateSaved=\"\d+\"/g;
			
			//delete contentXML.@dateSaved;
			
			var contentXMLValue:String = contentXML.toXMLString().replace(pattern, "");
			var sourceXMLValue:String = sourceXML.toXMLString().replace(pattern, "");
			
			if (contentXMLValue!=sourceXMLValue) { // will always be false because date and time is saved on each call
				isChanged = true;
			}
			else {
				isChanged = false;
			}
			//isChanged = false; // setting to false for now until we find a better way
			
			return isChanged;
		}
		
		
		/**
		 * Get a list of documents for local storage. If open is set to true then only returns open documents.
		 * */
		public function getSavableDocumentsData(open:Boolean = false, metaData:Boolean = false):Array {
			var documentsArray:Array = [];
			var length:int = documents.length;
			var iDocument:IDocument;
			
			
			for (var i:int;i<length;i++) {
				iDocument = IDocument(documents[i]);
				//Radiate.info("Exporting document " + iDocument.name);
				
				if (open) {
					if (iDocument.isOpen) {
						if (metaData) {
							documentsArray.push(iDocument.toMetaData());
						}
						else {
							documentsArray.push(iDocument.marshall());
							//Radiate.info("Exporting document " + iDocument.source);
						}
					}
				}
				else {
					if (metaData) {
						documentsArray.push(iDocument.toMetaData());
					}
					else {
						documentsArray.push(iDocument.marshall(DOCUMENT_TYPE, false));
					}
				}
			}
			
			
			return documentsArray;
		}
	}
}