
package com.flexcapacitor.model {
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.services.IServiceEvent;
	import com.flexcapacitor.services.IWPServiceEvent;
	
	import flash.events.Event;
	import flash.net.URLVariables;
	
	import mx.utils.UIDUtil;
	
	/**
	 * Dispatched when project is saved
	 * */
	[Event(name="saveResults", type="flash.events.Event")]
	
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
			nodeName = "project";
			nameIndex++;
			uid = UIDUtil.createUID();
		}
		
		public static var PROJECT_OPENED:String = "projectOpened";
		
		/**
		 * Used when creating incremental project names
		 * */
		public static var nameIndex:int;
		
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
					var documentToRemove:IDocumentData = getDocumentByID(document.uid);
					removeDocument(documentToRemove);
				}
				
				documents.push(document);
				document.name = createDocumentName(document);
				document.project = this;
				document.projectID = uid;
			}
			else {
				Radiate.log.info("Document already added");
			}
		}
		
		/**
		 * Remove a document 
		 * */
		public function removeDocument(document:IDocumentData):void {
			var documentIndex:int = getDocumentIndexByID(document.uid);
			
			if (documentIndex!=-1) {
				var removedArray:Array = documents.splice(documentIndex, 1);
				
				if (removedArray.length!=0 && removedArray[0]==document) {
					//Radiate.log.info("Document removed " + document.name);
				}
			}
			else {
				//Radiate.log.info("Document not removed " + document.name);
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
		public function getDocumentByID(uid:String):IDocumentData {
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
		public function getDocumentIndexByID(uid:String):int {
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
			if (format==STRING_TYPE) {
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
				
				if (!representation) {
					for (var m:int;m<documents.length;m++) {
						documentData = IDocumentData(documents[m]);
						documentXML = XML(documentData.marshall(XML_TYPE, true));
						XML(xml.documents).appendChild( documentXML );
					}
				}
				
				if (format==STRING_TYPE) {
					return xml.toXMLString();
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
			}
			else if (data is XML) {
				var documentsMetaDataList:XMLList = data.documents.document;
				
				source = XML(data).toXMLString();
				originalSource = XML(data).toXMLString();
				
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
			isOpen = false;
		}
		
		/**
		 * @inheritDoc
		 * */
		override public function open(location:String = REMOTE_LOCATION):void {
			var count:int = documents.length; //fromMetaData ? documentsMetaData.length : documents.length;
			var documentsArray:Array = documents; //fromMetaData ? documentsMetaData : documents;
			var documentMetaData:IDocumentMetaData;
			var documentData:IDocumentData;
			var iDocument:IDocument;
			var documentCreated:Boolean;
			
			// do documents have remote ID? if so we have to open from the server
			var needToWaitForDocumentsOpenResults:Boolean;
			
			// should set isOpen to true
			isOpen = true;
			
			//Radiate.instance.openPreviouslyOpenDocuments();
			
			
			// open documents
			//if (!fromMetaData) {
				
				for (var i:int;i<count;i++) {
					iDocument = IDocument(documentsArray[i]);
					
					
					if (location==REMOTE_LOCATION) {
						//documentCreated = getDocumentExists(iDocument);
						
						//if (!documentCreated) {
						
						if (iDocument && !iDocument.isOpen && iDocument.id!=null) {
							
							if (iDocument) {
								DocumentData(iDocument).addEventListener(LoadResultsEvent.LOAD_RESULTS, documentRetrievedResultsHandler, false, 0, true);
 							}
							
							//Radiate.log.info("calling retrieve on document " + iDocument.name);
							iDocument.retrieve();
						}
						
						//}
						//else {
							//iDocument = getDocumentByID(documentMetaData.uid);
							//iDocument.open();
							//Radiate.instance.openDocumentByData(iDocument, true);
						//}
					}
					else if (location==LOCAL_LOCATION) {
						iDocument.open();
						Radiate.instance.openDocumentByData(iDocument, true);
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
						
						Radiate.log.info("calling retrieve on document " + documentData.name);
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
			var count:int = documentsMetaData.length;
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
			
			for (var j:int;j<count;j++) {
				documentMetaData = IDocumentMetaData(documentsArray[j]);
				
				documentCreated = getDocumentExists(documentMetaData);
				
				if (!documentCreated) {
					iDocument = radiate.createDocumentFromMetaData(documentMetaData);
					DocumentData(iDocument).addEventListener(LoadResultsEvent.LOAD_RESULTS, documentRetrievedResultsHandler, false, 0, true);
					//Radiate.log.info("calling retrieve on document " + iDocument.name);
					iDocument.retrieve();
					documents.push(iDocument);
					iDocument.project = this;
					/*
					if (documentData.id==null) {
						needToWaitForDocumentsOpenResults = true;
					}*/
				}
				else {
					iDocumentData = getDocumentByID(documentMetaData.uid);
					iDocumentData.open(location);
					Radiate.instance.openDocumentByData(iDocumentData, true);
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
				
				Radiate.log.info("calling open on document " + documentData.name);
				documentData.retrieve(local);
				
				if (documentData.id==null) {
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
			var length:int = documents.length;
			var documentData:IDocumentData;
			var saveRemote:Boolean = locations.indexOf(REMOTE_LOCATION)!=-1;
			var saveLocally:Boolean = locations.indexOf(LOCAL_LOCATION)!=-1;
			
			// do all documents have remote ID? if not we have to save again when 
			// we get an ID from the server
			var needToWaitForDocumentsSaveResults:Boolean = false;
			
			if (id==null) {
				firstTimeSave = true;
			}
			
			// save documents
			for (var i:int;i<length;i++) {
				documentData = IDocumentData(documents[i]);
				
				if (saveRemote && documentData is DocumentData) {
					DocumentData(documentData).addEventListener(SaveResultsEvent.SAVE_RESULTS, documentSaveResultsHandler, false, 0, true);
				}
				
				if (saveRemote && documentData.id==null) {
					needToWaitForDocumentsSaveResults = true;
				}
				
				//if (locations.indexOf(SAVE_LOCAL)!=-1) {
				Radiate.log.info("Calling save on document " + documentData.name);
				documentData.save(locations);
				//}
			}
			
			if (!needToWaitForDocumentsSaveResults) {
				var savedLocally:Boolean = super.save(locations);
			}
			else {
				// we need to save the project when we receive the response with the remote ID
				deferSave = true;
				deferSaveLocations = locations;
			}
		
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
			source = content;
			
			return object;
		}
		
		/**
		 * Result from project save fault
		 * */
		override public function saveFaultHandler(event:IServiceEvent):void {
			super.saveFaultHandler(event);
			
			//trace("Save Project Fault");
			Radiate.log.info("PROJECT - Error when trying to save "+ name + ".");
			deferSave = false;
			dispatchEvent(event as Event);
		}
		
		/**
		 * Result from project save results 
		 * */
		override public function saveResultsHandler(event:IWPServiceEvent):void {
			super.saveResultsHandler(event);
			
			
			checkProjectHasChanged();
			
			if (firstTimeSave) {
				firstTimeSave = false;
				super.save(REMOTE_LOCATION);
			}
			else {
				deferSave = false;
				dispatchEvent(event as Event);
			}
			//Radiate.log.info("PROJECT - Success saving project "+ name + ".");
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
		 * Project opened
		 * */
		public function dispatchProjectOpened():void {
			//Radiate.log.info("Project open complete");
			isOpen = true;
			dispatchEvent(new Event(PROJECT_OPENED));
		}
		
		/**
		 * Result from retrieved results
		 * */
		public function documentRetrievedResultsHandler(event:LoadResultsEvent):void {
			var currentDocumentData:IDocumentData = IDocumentData(event.currentTarget);
			var documentsArray:Array = documents; //documentsMetaData;//documents.length ? documents : documentsMetaData;
			var length:int = documentsArray.length;
			var documentData:IDocumentData;
			var iDocument:IDocument;
			var resultsNotIn:Array = [];
			var openNotSuccessful:Array = [];
			var data:Object = event.data;
			
			//Radiate.log.info("Is document " + event.currentTarget.name + " open: "+ event.successful);
			
			DocumentData(currentDocumentData).removeEventListener(LoadResultsEvent.LOAD_RESULTS, documentRetrievedResultsHandler);
			
			// check if all documents have loaded
			for (var i:int;i<length;i++) {
				documentData = IDocumentData(documentsArray[i]);
				
				if (documentData is DocumentData) {
					
					// check if saving is in progress
					if (DocumentData(documentData).openInProgress) {
						resultsNotIn.push(documentData);
					}
					
					// check if save is unsuccessful
					if (!documentData.openSuccessful) {
						openNotSuccessful.push(documentData.name);
					}
				}
			}
			
			// ALSO NEED TO UPDATE CODE IN OPEN RESULTS HANDLER
			// all documents opened
			if (resultsNotIn.length==0) {
				
				if (openNotSuccessful.length>0) {
					Radiate.log.info("These documents could not be opened: " + openNotSuccessful);
				}
				
				dispatchProjectOpened();
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
				Radiate.instance.openDocument(iDocument);
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
			Radiate.log.info("Is document " + event.currentTarget.name + " saved: "+ event.successful);
			var length:int = documents.length;
			var document:IDocumentData;
			var resultsNotIn:Array = [];
			var unsuccessfulSaves:Array = [];
			
			DocumentData(event.currentTarget).removeEventListener(SaveResultsEvent.SAVE_RESULTS, documentSaveResultsHandler);
			
			for (var i:int;i<length;i++) {
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
				}
			}
			
			if (resultsNotIn.length==0) {
				Radiate.log.info("Project '" + name + "' save complete");
				
				if (unsuccessfulSaves.length>0) {
					Radiate.log.info("These documents could not be saved: " + unsuccessfulSaves);
				}
				else {
					//isChanged = false; // hardcoding for now until checkProjectHasChanged is fixed
				}
			}
			
			if (deferSave) {
				super.save(deferSaveLocations);
				deferSave = false;
			} else {
				
			}
			
			
			//DocumentData(document).addEventListener(DocumentData.SAVE_RESULTS, documentSaveResultsHandler, false, 0, true);
			
		}
		
		/**
		 * Check if project source has changed
		 * */
		public function checkProjectHasChanged():Boolean {
			var content:String = String(marshall(STRING_TYPE, false));
			
			if (content!=source) { // will always be false because date and time is saved on each call
				isChanged = true;
			}
			
			isChanged = false; // setting to false for now until we find a better way
			
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
				Radiate.log.info("Exporting document " + iDocument.name);
				
				if (open) {
					if (iDocument.isOpen) {
						if (metaData) {
							documentsArray.push(iDocument.toMetaData());
						}
						else {
							documentsArray.push(iDocument.marshall());
							Radiate.log.info("Exporting document " + iDocument.source);
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