package com.flexcapacitor.managers
{
	import com.flexcapacitor.controller.Console;
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.effects.file.LoadFile;
	import com.flexcapacitor.events.HTMLDragEvent;
	import com.flexcapacitor.formatters.HTMLFormatterTLF;
	import com.flexcapacitor.model.AttachmentData;
	import com.flexcapacitor.model.DocumentData;
	import com.flexcapacitor.model.HTMLDragData;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IDocumentData;
	import com.flexcapacitor.model.IProject;
	import com.flexcapacitor.model.ImageData;
	import com.flexcapacitor.services.IServiceEvent;
	import com.flexcapacitor.services.WPAttachmentService;
	import com.flexcapacitor.services.WPService;
	import com.flexcapacitor.utils.ArrayUtils;
	import com.flexcapacitor.utils.ClassUtils;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.HTMLDragManager;
	import com.flexcapacitor.utils.supportClasses.ComponentDefinition;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	import com.flexcapacitor.utils.supportClasses.FileData;
	
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.core.DragSource;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	
	import spark.components.Application;
	import spark.components.Image;
	import spark.components.RichText;
	import spark.primitives.BitmapImage;
	import spark.primitives.supportClasses.GraphicElement;
	
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;

	/**
	 * Manages adding and removing assets, attachments 
	 **/
	public class LibraryManager extends Console {
		
		public function LibraryManager(s:SINGLEDOUBLE) {
			
		}
		
		/**
		 * Upload attachment
		 * */
		public static var uploadAttachmentService:WPAttachmentService;
		
		/**
		 * Service to get list of attachments
		 * */
		public static var getAttachmentsService:WPService;
		
		/**
		 * Service to delete attachments
		 * */
		public static var deleteAttachmentsService:WPService;
		
		/**
		 * Service to delete attachment
		 * */
		public static var deleteAttachmentService:WPService;
		
		/**
		 * Set to true when deleting an attachment
		 * */
		[Bindable]
		public static var deleteAttachmentInProgress:Boolean;
		
		/**
		 * Set to true when deleting attachments
		 * */
		[Bindable]
		public static var deleteAttachmentsInProgress:Boolean;
		
		/**
		 * Set to true when getting list of attachments
		 * */
		[Bindable]
		public static var getAttachmentsInProgress:Boolean;
		
		/**
		 * Set to true when uploading an attachment
		 * */
		[Bindable]
		public static var uploadAttachmentInProgress:Boolean;
		
		private static var _attachments:Array = [];
		
		/**
		 * Attachments
		 * */
		[Bindable]
		public static function get attachments():Array {
			return _attachments;
		}
		
		public static function set attachments(value:Array):void {
			_attachments = value;
		}
		
		private static var _assets:ArrayCollection = new ArrayCollection();
		
		/**
		 * Assets of the current document
		 * */
		[Bindable]
		public static function get assets():ArrayCollection {
			return _assets;
		}
		
		public static function set assets(value:ArrayCollection):void {
			_assets = value;
		}
		
		/**
		 * Templates for creating new projects or documents
		 * */
		[Bindable]
		public static var templates:Array;
		
		public static var deferredFileLoader:LoadFile;
		public static var deferredDocument:IDocument;
		
		public static var loadingMXML:Boolean;
		public static var loadingFXG:Boolean;
		public static var loadingSVG:Boolean;
		public static var loadingPSD:Boolean;
		
		public static var attachmentsToUpload:Array;
		public static var currentAttachmentToUpload:AttachmentData;
		public static var lastAttemptedUpload:Object;
		
		/**
		 * Get the current document.
		 * */
		public static function get selectedDocument():IDocument {
			return Radiate.selectedDocument;
		}
		
		/**
		 * Get the current project.
		 * */
		public static function get selectedProject():IProject {
			return Radiate.selectedProject;
		}
		
		/**
		 * When importing an image via base64 string we 
		 * save a reference to the loader info so it doesn't get garbage collected
		 **/
		public static var contentLoaderDictionary:Dictionary = new Dictionary(true);
		
		/**
		 * Get images from the server
		 * */
		public static function getAttachments(id:int = 0):void {
			// get selected document
			
			// we need to create service
			if (getAttachmentsService==null) {
				getAttachmentsService = new WPService();
				getAttachmentsService.addEventListener(WPService.RESULT, getAttachmentsResultsHandler, false, 0, true);
				getAttachmentsService.addEventListener(WPService.FAULT, getAttachmentsFaultHandler, false, 0, true);
			}
			
			getAttachmentsService.host = Radiate.getWPURL();
			
			if (id!=0) {
				getAttachmentsService.id = String(id);
			}
			
			getAttachmentsInProgress = true;
			
			
			getAttachmentsService.getAttachments(id);
		}
		
		/**
		 * Upload attachment data to the server
		 * */
		public static function uploadAttachmentData(attachmentData:AttachmentData, id:String):void {
			if (attachmentData==null) {
				warn("No attachment to upload");
				return;
			}
			
			var imageData:ImageData = attachmentData as ImageData;
			var formattedName:String = attachmentData.name!=null ? attachmentData.name : null;
			
			if (formattedName) {
				
				if (formattedName.indexOf(" ")!=-1) {
					formattedName = formattedName.replace(/ /g, "");
				}
			}
			
			if (imageData && imageData.bitmapData && imageData.byteArray==null) {
				attachmentData.byteArray = DisplayObjectUtils.getByteArrayFromBitmapData(BitmapData(imageData.bitmapData));
				
				if (formattedName && formattedName.indexOf(".")==-1) {
					formattedName = formattedName + ".png";
				}
				
				imageData.contentType = DisplayObjectUtils.PNG_MIME_TYPE;
			}
			
			
			uploadAttachment(attachmentData.byteArray, id, formattedName, null, attachmentData.contentType, null, attachmentData);
		}
		
		/**
		 * Upload image to the server.
		 * File name cannot have spaces and must have an extension.
		 * If you pass bitmap data it is converted to a PNG
		 * */
		public static function uploadAttachment(data:Object, id:String, fileName:String = null, 
										 dataField:String = null, contentType:String = null, 
										 customData:Object = null, attachmentData:AttachmentData = null):void {
			// get selected document
			
			// we need to create service
			if (uploadAttachmentService==null) {
				uploadAttachmentService = new WPAttachmentService();
				uploadAttachmentService.addEventListener(WPService.RESULT, uploadAttachmentResultsHandler, false, 0, true);
				uploadAttachmentService.addEventListener(WPService.FAULT, uploadAttachmentFaultHandler, false, 0, true);
				//uploadAttachmentService = service;
			}
			
			uploadAttachmentService.host = Radiate.getWPURL();
			
			if (id!=null) {
				uploadAttachmentService.id = id;
			}
			
			if (attachmentData) {
				currentAttachmentToUpload = attachmentData;
				currentAttachmentToUpload.saveInProgress = true;
			}
			
			uploadAttachmentService.customData = customData;
			
			uploadAttachmentInProgress = true;
			
			var formattedName:String = fileName!=null ? fileName : null;
			
			if (formattedName) {
				
				if (formattedName.indexOf(" ")!=-1) {
					formattedName = formattedName.replace(/ /g, "");
				}
				
				if (formattedName.indexOf(".")==-1) {
					
					if (contentType==DisplayObjectUtils.PNG_MIME_TYPE) {
						formattedName = formattedName + ".png";
					}
				}
			}
			
			
			if (data is FileReference) {
				uploadAttachmentService.file = data as FileReference;
				uploadAttachmentService.uploadAttachment();
			}
			else if (data) {
				
				if (data is ByteArray) {
					uploadAttachmentService.fileData = data as ByteArray;
				}
				else if (data is BitmapData) {
					uploadAttachmentService.fileData = DisplayObjectUtils.getByteArrayFromBitmapData(BitmapData(data));
					
					if (formattedName && formattedName.indexOf(".")==-1) {
						formattedName = formattedName + ".png";
					}
					
					contentType = DisplayObjectUtils.PNG_MIME_TYPE;
				}
				
				if (formattedName) {
					uploadAttachmentService.fileName = formattedName;
				}
				
				if (dataField) {
					uploadAttachmentService.dataField = dataField;
				}
				
				// default content type in service is application/octet
				if (contentType) {
					uploadAttachmentService.contentType = contentType;
				}
				
				uploadAttachmentService.uploadAttachment();
			}
			else {
				attachmentData.saveInProgress = false;
				uploadAttachmentInProgress = false;
				warn("No data or file is available for upload. Please select the file to upload.");
			}
			
		}
		
		/**
		 * Get assets available to upload
		 * */
		public static function getAssetsAvailableToUpload():Array {
			var numberOfAssets:int;
			var attachmentData:AttachmentData;
			var assetsToUpload:Array = [];
			
			numberOfAssets = assets.length;
			
			for (var i:int=0;i<numberOfAssets;i++) {
				attachmentData = assets[i] as AttachmentData;
				
				if (attachmentData) {
					
					if (attachmentData.id==null) {
						
						if (assetsToUpload.indexOf(attachmentData)==-1) {
							assetsToUpload.push(attachmentData);
						}
					}
				}
			}
			
			return assetsToUpload;
		}
		
		/**
		 * Save all attachments. 
		 * */
		public static function saveAllAttachments(iDocument:DocumentData, saveToProject:Boolean = false, locations:String = null, saveEvenIfClean:Boolean = true):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var loadLocally:Boolean = ServicesManager.getIsLocalLocation(locations);
			var loadRemote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var document:IDocument;
			var anyDocumentSaved:Boolean;
			var numberOfAttachments:int;
			var numberOfAttachmentsToUpload:int;
			var numberOfAssets:int;
			var attachmentData:AttachmentData;
			var imageData:ImageData;
			var targetPostID:String;
			var projectID:String;
			var attachmentParentID:String;
			var hasAttachments:Boolean;
			var customData:Object;
			var uploadingStillInProgress:Boolean;
			
			// Continues in uploadAttachmentResultsHandler
			
			if (uploadAttachmentInProgress) {
				DeferManager.callAfter(100, saveAllAttachments, iDocument, saveToProject, locations, saveEvenIfClean);
				return true;
			}
			
			if (saveToProject) {
				projectID = iDocument.parentId;
				targetPostID = projectID;
			}
			else {
				targetPostID = iDocument.id;
			}
			
			// save attachments
			numberOfAssets = assets.length;
			
			if (numberOfAssets==0) {
				info("No attachments to save");
				return false;
			}
			
			if (attachmentsToUpload==null) {
				attachmentsToUpload = [];
			}
			else if (attachmentsToUpload.length) {
				uploadingStillInProgress = true;
			}
			
			// get attachments that still need uploading
			
			if (!uploadingStillInProgress) {
				for (var i:int=0;i<numberOfAssets;i++) {
					attachmentData = assets[i] as AttachmentData;
					
					if (attachmentData) {
						attachmentParentID = attachmentData.parentId;
						
						if (attachmentParentID==null) {
							attachmentData.parentId = iDocument.id;
							attachmentParentID = iDocument.id;
						}
						
						// only add if matches document or project
						// you need to set the parent ID at 
						if (attachmentParentID!=targetPostID && attachmentParentID!=projectID) {
							continue;
						}
						
						if (attachmentData.id==null) {
							
							if (attachmentsToUpload.indexOf(attachmentData)==-1) {
								attachmentsToUpload.push(attachmentData);
							}
						}
					}
				}
			}
			
			numberOfAttachmentsToUpload = attachmentsToUpload.length;
			customData = {};
			
			for (var m:int = 0; m < numberOfAttachmentsToUpload; m++) {
				attachmentData = attachmentsToUpload[m];
				
				// trying to add a custom field with the uid - doesn't works
				if (attachmentData.uid) {
					customData["custom[uid]"] = attachmentData.uid;
					customData["caption"] = attachmentData.uid;
					customData["post_excerpt"] = attachmentData.uid;
					customData["post_title"] = attachmentData.name;
				}
				
				imageData = attachmentData as ImageData;
				
				if (imageData) {
					if (imageData.byteArray==null && imageData.bitmapData) {
						imageData.byteArray = DisplayObjectUtils.getByteArrayFromBitmapData(imageData.bitmapData);
						//imageData.name = ClassUtils.getIdentifierNameOrClass(initiator) + ".png";
						imageData.contentType = DisplayObjectUtils.PNG_MIME_TYPE;
						imageData.file = null;
					}
					
					if (!imageData.saveInProgress && imageData.id==null) {
						
						//imageData.save();
						hasAttachments = true;
						imageData.saveInProgress = true;
						currentAttachmentToUpload = imageData;
						
						//trace("Uploading attachment " + currentAttachmentToUpload.name + " to post " + targetPostID);
						
						uploadAttachment(imageData.byteArray, targetPostID, imageData.name, null, imageData.contentType, customData);
						break;
					}
				}
				else {
					
					hasAttachments = true;
					attachmentData.saveInProgress = true;
					currentAttachmentToUpload = attachmentData;
					
					//trace("Uploading attachment " + currentAttachmentToUpload.name + " to post " + targetPostID);
					
					uploadAttachment(attachmentData.byteArray, targetPostID, attachmentData.name, null, attachmentData.contentType, customData);
					break;
				}
			}
			
			
			//for (var i:int;i<numberOfAttachments;i++) {
			//document = documents[i];
			
			//document.upload(locations);
			// TODO add support to save after response from server 
			// because ID's may have been added from new documents
			//saveData();
			//document.saveCompleteCallback = saveData;
			//saveDocumentLocally(document);
			//	anyDocumentSaved = true;
			//}
			
			if (hasAttachments) {
				DeferManager.callAfter(100, saveAllAttachments, iDocument, saveToProject, locations, saveEvenIfClean);
			}
			
			return anyDocumentSaved;
		}
		/**
		 * Result get attachments
		 * */
		public static function getAttachmentsResultsHandler(event:IServiceEvent):void {
			Radiate.info("Retrieved list of attachments");
			var data:Object = event.data;
			var potentialAttachments:Array = [];
			var numberOfAttachments:int;
			var object:Object;
			var attachment:AttachmentData;
			
			if (data && data.count>0) {
				numberOfAttachments = data.count;
				
				for (var i:int;i<numberOfAttachments;i++) {
					object = data.attachments[i];
					
					if (String(object.mime_type).indexOf("image/")!=-1) {
						attachment = new ImageData();
						attachment.unmarshall(object);
					}
					else {
						attachment = new AttachmentData();
						attachment.unmarshall(object);
					}
					
					potentialAttachments.push(attachment);
				}
			}
			
			getAttachmentsInProgress = false;
			
			attachments = potentialAttachments;
			
			Radiate..dispatchAttachmentsResultsEvent(true, attachments);
		}
		
		/**
		 * Result from attachments fault
		 * */
		public static function getAttachmentsFaultHandler(event:IServiceEvent):void {
			
			Radiate.info("Could not get list of attachments");
			
			getAttachmentsInProgress = false;
			
			//dispatchEvent(saveResultsEvent);
			Radiate..dispatchAttachmentsResultsEvent(false, []);
		}
		
		/**
		 * Result upload attachment
		 * */
		public static function uploadAttachmentResultsHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			var successful:Boolean = data && data.status && data.status=="ok" ? true : false;
			var numberOfRemoteAttachments:int;
			var remoteAttachments:Array = data && data.post && data.post.attachments ? data.post.attachments : []; 
			var containsName:Boolean;
			var numberOfAttachmentsToUpload:int;
			var numberOfDocuments:int;
			var foundAttachment:Boolean;
			var lastAddedRemoteAttachment:Object;
			const documents:Array = DocumentManager.documents;
			
			// last attachment successfully uploaded
			lastAddedRemoteAttachment = remoteAttachments && remoteAttachments.length ? remoteAttachments[remoteAttachments.length-1]: null;
			
			var localIDExists:Boolean = com.flexcapacitor.utils.ArrayUtils.hasItem(assets, lastAddedRemoteAttachment.id, "id");
			
			if (currentAttachmentToUpload) {
				currentAttachmentToUpload.saveInProgress = false;
			}
			
			if (lastAddedRemoteAttachment && currentAttachmentToUpload) {
				//trace("Last uploaded attachment is " + lastAddedRemoteAttachment.title + " with id of " + lastAddedRemoteAttachment.id);
				containsName = lastAddedRemoteAttachment.slug.indexOf(currentAttachmentToUpload.slugSafeName)!=-1;
			}
			
			if (!localIDExists) {
				foundAttachment = true;
				
				if (currentAttachmentToUpload) {
					currentAttachmentToUpload.unmarshall(lastAddedRemoteAttachment);
					currentAttachmentToUpload.uploadFailed = false;
				}
				
				// loop through documents and replace bitmap data with url to source
				numberOfDocuments = documents.length;
				k = 0;
				
				for (var k:int;k<numberOfDocuments;k++) {
					var iDocument:IDocument = documents[k] as IDocument;
					
					if (iDocument) {
						DisplayObjectUtils.walkDownComponentTree(iDocument.componentDescription, replaceBitmapDataWithURL, [currentAttachmentToUpload]);
					}
				}
			}
			else {
				warn("Attachment " + currentAttachmentToUpload.name + " could not be uploaded");
				currentAttachmentToUpload ? currentAttachmentToUpload.uploadFailed = true : -1;
				successful = false;
				foundAttachment = false;
			}
			
			lastAttemptedUpload = attachmentsToUpload && attachmentsToUpload.length ? attachmentsToUpload.unshift() : null;
			
			uploadAttachmentInProgress = false;
			
			if (!foundAttachment) {
				successful = false;
				Radiate..dispatchUploadAttachmentResultsEvent(successful, [], data.post);
			}
			else {
				Radiate..dispatchUploadAttachmentResultsEvent(successful, [currentAttachmentToUpload], data.post);
			}
			
			if (attachmentsToUpload && attachmentsToUpload.length) {
				// we should do this sequencially
			}
			
			currentAttachmentToUpload = null;
		}
		
		/**
		 * Result from upload attachment fault
		 * */
		public static function uploadAttachmentFaultHandler(event:IServiceEvent):void {
			Radiate.info("Upload attachment fault");
			
			lastAttemptedUpload = attachmentsToUpload && attachmentsToUpload.length ? attachmentsToUpload.unshift() : null;
			
			uploadAttachmentInProgress = false;
			
			if (currentAttachmentToUpload) {
				currentAttachmentToUpload.saveInProgress = false;
			}
			
			if (attachmentsToUpload.length) {
				// we should do this sequencially
			}
			
			//dispatchEvent(saveResultsEvent);
			Radiate..dispatchUploadAttachmentResultsEvent(false, [], event.data, event.faultEvent);
			
			currentAttachmentToUpload = null;
		}
		
		/**
		 * Delete attachments. You should save the project after
		 * document is deleted.
		 * */
		public static function deleteAttachmentsResultsHandler(event:IServiceEvent):void {
			//..Radiate.info("Delete document results");
			var data:Object = event.data;
			var deletedItems:Object = data ? data.deletedItems : [];
			var successful:Boolean;
			var error:String;
			var message:String;
			
			
			if (data && data is Object && "successful" in data) {
				successful = data.successful != "false";
			}
			
			deleteAttachmentsInProgress = false;
			
			//Include 'id' or 'slug' var in your request.
			if (event.faultEvent is IOErrorEvent) {
				message = "Are you connected to the internet? ";
				
				if (event.faultEvent is IOErrorEvent) {
					message = IOErrorEvent(event.faultEvent).text;
				}
				else if (event.faultEvent is SecurityErrorEvent) {
					
					if (SecurityErrorEvent(event.faultEvent).errorID==2048) {
						
					}
					
					message += SecurityErrorEvent(event.faultEvent).text;
				}
			}
			
			Radiate.dispatchAttachmentsDeletedEvent(successful, data);
			
			if (successful) {
				
				if (DocumentManager.deleteDocumentProjectId!=-1 && DocumentManager.saveProjectAfterDelete) {
					var iProject:IProject = ProjectManager.getProjectByID(DocumentManager.deleteDocumentProjectId);
					
					if (iProject) {
						iProject.saveOnlyProject();
					}
				}
				
			}
			
			DocumentManager.saveProjectAfterDelete = false;
		}
		
		/**
		 * Result from delete attachments fault
		 * */
		public static function deleteAttachmentsFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.info("Could not connect to the server to delete the document. ");
			
			deleteAttachmentsInProgress = false;
			
			Radiate.dispatchAttachmentsDeletedEvent(false, data);
		}
		
		/**
		 * Remove an asset from the documents assets collection
		 * */
		public static function removeAssetFromDocument(assetData:IDocumentData, documentData:DocumentData, locations:String = null, dispatchEvents:Boolean = true):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var remote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var index:int = assets.getItemIndex(assetData);
			var removedInternally:Boolean;
			
			if (index!=-1) {
				assets.removeItemAt(index);
				removedInternally = true;
			}
			
			if (remote && assetData && assetData.id) { 
				// we need to create service
				if (deleteAttachmentService==null) {
					deleteAttachmentService = new WPService();
					deleteAttachmentService.addEventListener(WPService.RESULT, DocumentManager.deleteDocumentResultsHandler, false, 0, true);
					deleteAttachmentService.addEventListener(WPService.FAULT, DocumentManager.deleteDocumentFaultHandler, false, 0, true);
				}
				
				deleteAttachmentService.host = Radiate.getWPURL();
				
				DocumentManager.deleteDocumentInProgress = true;
				
				deleteAttachmentService.deleteAttachment(int(assetData.id), true);
			}
			
			Radiate..dispatchAssetRemovedEvent(assetData, removedInternally);
			
			return removedInternally;
		}
		
		/**
		 * Remove assets from the documents assets collection
		 * */
		public static function removeAssetsFromDocument(attachments:Array, locations:String = null, dispatchEvents:Boolean = true):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var remote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var removedInternally:Boolean;
			var attachmentData:AttachmentData;
			var attachmentIDs:Array = [];
			var numberOfAttachments:int;
			var index:int;
			
			numberOfAttachments = attachments ? attachments.length : 0;
			
			for (var i:int; i < numberOfAttachments; i++) {
				attachmentData = attachments[i];
				index = assets.getItemIndex(attachmentData);
				
				if (index>-1) {
					assets.removeItemAt(index);
					removedInternally = true;
				}
			}
			
			if (remote && attachments && attachments.length) { 
				// we need to create service
				if (deleteAttachmentsService==null) {
					deleteAttachmentsService = new WPService();
					deleteAttachmentsService.addEventListener(WPService.RESULT, deleteAttachmentsResultsHandler, false, 0, true);
					deleteAttachmentsService.addEventListener(WPService.FAULT, deleteAttachmentsFaultHandler, false, 0, true);
				}
				
				deleteAttachmentsService.host = Radiate.getWPURL();
				
				deleteAttachmentsInProgress = true;
				
				for (var j:int = 0; j < attachments.length; j++) {
					attachmentData = attachments[j];
					
					if (attachmentData.id!=null) {
						attachmentIDs.push(attachmentData.id);
					}
				}
				
				if (attachmentIDs.length) {
					deleteAttachmentsService.deleteAttachments(attachmentIDs, true);
				}
				else {
					Radiate..dispatchAttachmentsDeletedEvent(true, {localDeleted:true});
				}
			}
			
			// dispatch assets removed 
			// later dispatch attachment deleted event when result comes back from server 
			Radiate..dispatchAssetsRemovedEvent(attachments, removedInternally);
			
			return removedInternally;
		}
		
		/**
		 * Replaces occurances where the bitmapData in Image and BitmapImage have
		 * been uploaded to the server and we now want to point the image to a URL
		 * rather than bitmap data
		 * */
		public static function replaceBitmapDataWithURL(component:ComponentDescription, imageData:ImageData):void {
			var instance:Object;
			
			if (imageData && component && component.instance) {
				instance = component.instance;
				
				if (instance is Image || instance is BitmapImage) {
					if (instance.source is BitmapData && 
						instance.source == imageData.bitmapData && 
						imageData.bitmapData!=null) {
						ComponentManager.setProperty(instance, "source", imageData.url);
					}
				}
			}
		}
		
		/**
		 * Saves the selected target as an image in the library. 
		 * If successful returns ImageData. If unsuccessful returns Error
		 * Quality is set to BEST by default. There are higher quality settings but there are 
		 * numerous bugs when enabled. Embedded or system fonts are 75% of there normal size and gradients fills are only a few colors.
		 * */
		public static function saveToLibrary(target:Object, clip:Boolean = false, scale:Number = 1, quality:String = StageQuality.BEST):Object {
			var radiate:Radiate = Radiate.instance;
			var snapshot:Object;
			var data:ImageData;
			var previousScaleX:Number;
			var previousScaleY:Number;
			
			if (target && selectedDocument) {
				previousScaleX = target.scaleX;
				previousScaleY = target.scaleY;
				
				target.scaleX = scale;
				target.scaleY = scale;
				
				if (!clip) {
					
					if (target is UIComponent) {
						// new 2015 method from Bitmap utils
						snapshot = DisplayObjectUtils.getSnapshotWithQuality(target as UIComponent, quality);
					}
					else if (target is DisplayObject) {
						snapshot = DisplayObjectUtils.rasterize2(target as DisplayObject);
					}
					else if (target is GraphicElement) {
						snapshot = DisplayObjectUtils.getGraphicElementBitmapData(target as GraphicElement);
					}
				}
				else {
					if (target is UIComponent) {
						snapshot = DisplayObjectUtils.getUIComponentWithQuality(target as UIComponent);
					}
					else if (target is DisplayObject) {
						snapshot = DisplayObjectUtils.rasterize2(target as DisplayObject);
					}
					else if (target is GraphicElement) {
						snapshot = DisplayObjectUtils.getGraphicElementBitmapData(target as GraphicElement);
					}
				}
				
				target.scaleX = previousScaleX;
				target.scaleY = previousScaleY;
				
				if (snapshot is BitmapData) {
					
					// need to trim the transparent areas 
					snapshot = DisplayObjectUtils.trimTransparentBitmapData(snapshot as BitmapData);
					
					data = new ImageData();
					data.bitmapData = snapshot as BitmapData;
					data.byteArray = DisplayObjectUtils.getByteArrayFromBitmapData(snapshot as BitmapData);
					data.name = ClassUtils.getIdentifierNameOrClass(target) + ".png";
					data.contentType = DisplayObjectUtils.PNG_MIME_TYPE;
					data.file = null;
					
					LibraryManager.addAssetToDocument(data, Radiate.selectedDocument);
					
					return data;
				}
				else {
					//Radiate.error("Could not create a snapshot of the selected item. " + snapshot); 
				}
			}
			
			return snapshot;
		}
		
		/**
		 * Get the image data object that is contains this bitmap data.
		 * Note: Getting image.bitmapData returns a clone, bitmapdata.clone(). 
		 * Use image.source if it is bitmapData. 
		 * */ 
		public static function getImageDataFromBitmapData(bitmapData:BitmapData):ImageData {
			var numberOfAssets:int = assets.length;
			var imageData:ImageData;
			
			for (var i:int = 0; i < numberOfAssets; i++) {
				imageData = assets.getItemAt(i) as ImageData;
				
				if (imageData && imageData.bitmapData===bitmapData) {
					return imageData;
				}
			}
			
			return null;
		}
		
		/**
		 * Get bitmap data matching ImageData.uid.
		 * */
		public static function getBitmapDataFromImageDataID(uid:String):BitmapData {
			var numberOfAssets:int = assets.length;
			var imageData:ImageData;
			
			for (var i:int = 0; i < numberOfAssets; i++) {
				imageData = assets.getItemAt(i) as ImageData;
				
				if (imageData && imageData.uid===uid) {
					return imageData.bitmapData;
				}
			}
			
			return null;
		}
		
		
		/**
		 * Add multiple assets to a document or project
		 * */
		public static function addAssetsToDocument(assetsToAdd:Array, documentData:DocumentData, dispatchEvents:Boolean = true):void {
			var numberOfAssets:int;
			var added:Boolean;
			
			numberOfAssets = assetsToAdd ? assetsToAdd.length : 0;
			
			for (var i:int;i<numberOfAssets;i++) {
				addAssetToDocument(assetsToAdd[i], documentData, dispatchEvents);
			}
			
		}
		
		/**
		 * Add an asset to the document assets collection
		 * Should be renamed to something like addAssetToGlobalResourcesAndAssociateWithDocument
		 * */
		public static function addAssetToDocument(attachmentData:DocumentData, documentData:IDocumentData, dispatchEvent:Boolean = true):void {
			var numberOfAssets:int = assets ? assets.length : 0;
			var found:Boolean;
			var addedAttachmentData:DocumentData;
			var reparented:Boolean;
			
			for (var i:int;i<numberOfAssets;i++) {
				addedAttachmentData = assets.getItemAt(i) as DocumentData;
				
				if (attachmentData.id==addedAttachmentData.id && addedAttachmentData.id!=null) {
					found = true;
					break;
				}
			}
			
			
			if (documentData) {
				if (attachmentData.parentId != documentData.id) {
					attachmentData.parentId = documentData.id;
					reparented = true;
				}
			}
			
			if (!found) {
				assets.addItem(attachmentData);
			}
			
			if ((!found || reparented) && dispatchEvent) {
				Radiate..dispatchAssetAddedEvent(attachmentData);
			}
		}
		
		/**
		 * Adds PSD to the document. <br/>
		 * Adds assets to the library and document<br/>
		 * Missing support for masks, shapes and text (text is shown as image)<br/>
		 * Can take quite a while to import. <br/>
		 * Could use performance testing.
		 * */
		public static function addPSDToDocument(psdFileData:ByteArray, iDocument:IDocument, matchDocumentSizeToPSD:Boolean = true, addToAssets:Boolean = true):void {
			
			if (deferredDocument==null) {
				deferredDocument = iDocument;
			}
			
			PSDImporter.addPSDToDocument(deferredDocument, psdFileData, iDocument, matchDocumentSizeToPSD, addToAssets, deferredFileLoader, deferredFileLoader);
			
		}
		
		/**
		 * Adds bitmap data to the document. Since it is asynchronous we listen for init event
		 * */
		public static function addBase64ImageDataToDocument(iDocument:IDocument, fileData:FileData, destination:Object = null, name:String = null, addComponent:Boolean = true, resizeIfNeeded:Boolean = true, resizeDocumentToContent:Boolean = false):void {
			var bitmapData:BitmapData = DisplayObjectUtils.getBitmapDataFromBase64(fileData.dataURI, null, true, fileData.type);
			if (destination==null) destination = getDestinationForExternalFileDrop();
			var imageData:ImageData = addBitmapDataToDocument(iDocument, bitmapData, destination, fileData.name, addComponent, resizeIfNeeded, resizeDocumentToContent);
			
			// it's possible we weren't able to determine the dimensions of the image
			// so we add a listener to check after loading it with a loader
			var contentLoaderInfo:LoaderInfo = DisplayObjectUtils.loader.contentLoaderInfo;
			// save a reference to the loader info so it doesn't get garbage collected
			contentLoaderDictionary[contentLoaderInfo] = ComponentManager.lastCreatedComponent;
			contentLoaderInfo.addEventListener(Event.INIT, handleLoadingImages, false, 0, true);
		}
		
		/**
		 * Handles when image is fully loaded from base 64 string data
		 **/
		public static function handleLoadingImages(event:Event):void {
			var newBitmapData:BitmapData;
			var bitmap:Bitmap;
			var contentLoaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
			var componentInstance:Object = contentLoaderDictionary[contentLoaderInfo];
			
			if (contentLoaderInfo.loader.content) {
				bitmap = contentLoaderInfo.loader.content as Bitmap;
				newBitmapData = bitmap ? bitmap.bitmapData : null;
			}
			
			if (newBitmapData && componentInstance) {
				
				if (newBitmapData.compare(componentInstance.bitmapData)!=0) {
					
					const WIDTH:String = "width";
					const HEIGHT:String = "height";
					
					var properties:Array = [];
					var propertiesObject:Object;
					var documentProperties:Array = [];
					var documentPropertiesObject:Object;
					var imageData:ImageData;
					var originalBitmapData:BitmapData;
					
					//originalBitmapData = componentInstance.bitmapData; returns a clone use image.source 
					originalBitmapData = componentInstance.source;
					imageData = getImageDataFromBitmapData(originalBitmapData);
					
					if (imageData.resizeDocumentToFit) {
						documentPropertiesObject = {};
						documentPropertiesObject[WIDTH] = newBitmapData.width;
						documentPropertiesObject[HEIGHT] = newBitmapData.height;
						documentProperties.push(WIDTH);
						documentProperties.push(HEIGHT);
						
						ComponentManager.setProperties(selectedDocument.instance, documentProperties, documentPropertiesObject, "Document resized to image");
					}
					else if (imageData.resizeToFitDocument) {
						propertiesObject = ImageManager.getConstrainedImageSizeObject(selectedDocument, newBitmapData);
					}
					
					if (propertiesObject==null) {
						ComponentManager.setProperty(componentInstance, "source", newBitmapData, "Source loaded");
					}
					else {
						propertiesObject.source = newBitmapData;
						properties.push(WIDTH);
						properties.push(HEIGHT);
						properties.push("source");
						
						ComponentManager.setProperties(componentInstance, properties, propertiesObject, "Source loaded");
					}
					
					if (imageData) {
						imageData.bitmapData = newBitmapData;
					}
				}
			}
			
			if (contentLoaderInfo) {
				contentLoaderInfo.removeEventListener(Event.INIT, handleLoadingImages);
			}
			
			contentLoaderDictionary[contentLoaderInfo] = null;
			delete contentLoaderDictionary[contentLoaderInfo];
		}
		
		/**
		 * Adds an asset to the document
		 * */
		public static function addImageDataToDocument(imageData:ImageData, iDocument:IDocument, constrainImageToDocument:Boolean = true, smooth:Boolean = true, constrainDocumentToImage:Boolean = false):Boolean {
			var item:ComponentDefinition;
			var application:Application;
			var componentInstance:Object;
			var path:String;
			var bitmapData:BitmapData;
			var resized:Boolean;
			
			item = ComponentManager.getComponentType("Image");
			
			
			application = iDocument && iDocument.instance ? iDocument.instance as Application : null;
			
			if (!application) {
				warn("No document instance was available to add image into. Create a new document and add the image to it manually");
				return false;
			}
			
			// set to true so if we undo it has defaults to start with
			componentInstance = ComponentManager.createComponentToAdd(iDocument, item, true);
			bitmapData = imageData.bitmapData;
			
			
			const WIDTH:String = "width";
			const HEIGHT:String = "height";
			
			var styles:Array = [];
			var properties:Array = [];
			var propertiesObject:Object;
			var documentProperties:Array = [];
			var documentPropertiesObject:Object;
			
			if (constrainDocumentToImage) {
				documentPropertiesObject = {};
				documentPropertiesObject[WIDTH] = bitmapData.width;
				documentPropertiesObject[HEIGHT] = bitmapData.height;
				documentProperties.push(WIDTH);
				documentProperties.push(HEIGHT);
				ComponentManager.setProperties(iDocument.instance, documentProperties, documentPropertiesObject, "Document resized to image");
			}
			else if (constrainImageToDocument) {
				propertiesObject = ImageManager.getConstrainedImageSizeObject(iDocument, bitmapData);
			}
			
			if (propertiesObject==null) {
				propertiesObject = {};
			}
			else {
				resized = true;
				properties.push(WIDTH);
				properties.push(HEIGHT);
			}
			
			propertiesObject.scaleMode = "stretch";
			properties.push("scaleMode");
			
			if (smooth) {
				properties.push("smooth");
				propertiesObject.smooth = true;
				
				// the bitmap is all white when smoothing quality is enabled (safari mac fp 25.0.0.171(
				// changing any settings such as smooth enable or disable then shows the image correctly
				// so disabling for now
				//styles.push("smoothingQuality");
				//propertiesObject.smoothingQuality = "high";
			}
			
			if (imageData is ImageData) {
				path = imageData.url;
				
				if (path) {
					propertiesObject.width = undefined;
					propertiesObject.height = undefined;
					propertiesObject.source = path;
					properties.push(WIDTH);
					properties.push(HEIGHT);
				}
				else if (imageData.bitmapData) {
					propertiesObject.source = imageData.bitmapData;
				}
				
				properties.push("source");
			}
			
			ComponentManager.addElement(componentInstance, iDocument.instance, properties, styles, null, propertiesObject);
			
			ComponentManager.updateComponentAfterAdd(iDocument, componentInstance);
			
			return resized;
		}
		
		/**
		 * Add file list data to a document
		 * */
		public static function addFileListDataToDocument(iDocument:IDocument, fileList:Array, destination:Object = null, operation:String = "drop"):void {
			var createDocument:Boolean = false;
			
			if (fileList==null) {
				error("Not a valid file list");
				return;
			}
			
			if (fileList && fileList.length==0) {
				error("No files in the file list");
				return;
			}
			
			if (iDocument==null) {
				
				if (createDocument) {
					iDocument = DocumentManager.createNewDocumentAndSwitchToDesignView(fileList);
				}
				else {
					error("No document is open. Create a new document first. ");
					return;
				}
			}
			
			var urlFormatData:Object;
			var path_txt:String;
			var extension:String;
			var fileSafeList:Array;
			var hasPSD:Boolean;
			var hasMXML:Boolean;
			var hasFXG:Boolean;
			var hasSVG:Boolean;
			var extensionIndex:int;
			
			fileSafeList = [];
			
			// only accepting image files at this time
			for each (var file:FileReference in fileList) {
				if ("extension" in file) {
					extension = file.extension.toLowerCase();
				}
				else {
					extensionIndex = file.name.lastIndexOf(".");
					extension = extensionIndex!=-1 ? file.name.substring(extensionIndex+1) : null;
				}
				
				if (extension=="png" || 
					extension=="jpg" || 
					extension=="jpeg" || 
					extension=="gif") {
					fileSafeList.push(file);
				}
				else if (extension=="psd") {
					fileSafeList.push(file);
					hasPSD = true;
				}
				else if (extension=="mxml") {
					fileSafeList.push(file);
					hasMXML = true;
				}
				else if (extension=="fxg") {
					fileSafeList.push(file);
					hasFXG = true;
				}
				else if (extension=="svg") {
					fileSafeList.push(file);
					hasSVG = true;
				}
				else {
					path_txt = "Not a recognised file format";  
				}
			}
			
			var fileLoader:LoadFile;
			
			const PASTE:String = "paste";
			const DROP:String = "drop";
			
			if (operation==PASTE) {
				setupPasteFileLoader();
				fileLoader = deferredFileLoader;
			}
			else if (operation==DROP) {
				setupPasteFileLoader();
				fileLoader = deferredFileLoader;
			}
			
			
			fileLoader.removeReferences(true);
			
			
			if (!hasPSD && !hasMXML && !hasSVG && !hasFXG) {
				fileLoader.loadIntoLoader = true;
			}
			else {
				fileLoader.loadIntoLoader = false;
			}
			
			if (fileSafeList.length>0) {
				
				if (fileSafeList.length>1 && hasPSD) {
					warn("You cannot load a PSD and image files at the same time. Select one or the other");
					return;
				}
				else if (fileSafeList.length>1 && hasMXML) {
					warn("You cannot load a MXML file and other files at the same time. Select one or the other");
					return;
				}
				else if (fileSafeList.length>1 && hasFXG) {
					warn("You cannot load a FXG file and other files at the same time. Select one or the other");
					return;
				}
				else if (fileSafeList.length>1 && hasSVG) {
					warn("You cannot load a SVG file and other files at the same time. Select one or the other");
					return;
				}
				
				if (hasPSD) {
					loadingPSD = true;
				}
				else if (hasMXML) {
					loadingMXML = true;
				}
				else if (hasFXG) {
					loadingFXG = true;
				}
				else if (hasSVG) {
					loadingSVG = true;
				}
				else {
					loadingPSD = false;
				}
			
				deferredDocument = iDocument;
				
				fileLoader.filesArray = fileSafeList;
				fileLoader.play();
			}
			else {
				deferredDocument = null;
				info("No files of the acceptable type were found. Acceptable files are PNG, JPEG, GIF, PSD");
			}
		}
		
		/**
		 * Add bitmap data to a document
		 * */
		public static function addBitmapDataToDocument(iDocument:IDocument, bitmapData:BitmapData, destination:Object = null, name:String = null, addComponent:Boolean = false, resizeIfNeeded:Boolean = true, resizeDocumentToContent:Boolean = false):ImageData {
			if (bitmapData==null) {
				error("Not valid bitmap data");
			}
			if (iDocument==null) {
				error("Not a valid document");
			}
			
			if (bitmapData==null || iDocument==null) {
				return null;
			}
			
			var imageData:ImageData = new ImageData();
			var resized:Boolean;
			var smooth:Boolean = true;
			
			imageData.bitmapData = bitmapData;
			imageData.byteArray = DisplayObjectUtils.getByteArrayFromBitmapData(bitmapData);
			
			if (name==null) {
				if (destination) {
					name = ClassUtils.getIdentifierNameOrClass(destination) + ".png";
				}
				else {
					name = ClassUtils.getIdentifierNameOrClass(bitmapData) + ".png";
				}
			}
			
			imageData.name = name;
			imageData.contentType = DisplayObjectUtils.PNG_MIME_TYPE;
			imageData.file = null;
			
			imageData.resizeToFitDocument = resizeIfNeeded;
			imageData.resizeDocumentToFit = resizeDocumentToContent;
			
			if (addComponent) {
				resized = LibraryManager.addImageDataToDocument(imageData, iDocument, resizeIfNeeded, smooth, resizeDocumentToContent);
				
				//uploadAttachment(fileLoader.fileReference);
				if (resized) {
					info("Image was added to the library and the document and resized to fit");
				}
				else {
					info("Image was added to the library and the document");
				}
				
				Radiate.setTarget(ComponentManager.lastCreatedComponent);
				
				//dispatchAssetLoadedEvent(imageData, iDocument, resized, true);
			}
			
			addAssetToDocument(imageData, iDocument);
			
			return imageData;
			//info("An image from the clipboard was added to the library");
		}
		
		/**
		 * Add text data to a document
		 * */
		public static function addTextDataToDocument(iDocument:IDocument, text:String, destination:Object = null, useRichText:Boolean = true):void {
			if (text==null || text=="") {
				error("Not valid text data");
			}
			if (iDocument==null) {
				error("Not a valid document");
			}
			
			if (text==null || iDocument==null) {
				return;
			}
			
			var componentType:String = useRichText ? "spark.components.RichText" : "spark.components.Label";
			var definition:ComponentDefinition =  ComponentManager.getDynamicComponentType(componentType, true);
			var component:Object = ComponentManager.createComponentToAdd(iDocument, definition, false);
			var textFlow:TextFlow;
			
			if (useRichText) {
				textFlow = TextConverter.importToFlow(text, TextConverter.PLAIN_TEXT_FORMAT);
				ComponentManager.addElement(component, destination, ["textFlow"], null, null, {textFlow:textFlow});
			}
			else {
				ComponentManager.addElement(component, destination, ["text"], null, null, {text:text});
			}
			
			ComponentManager.updateComponentAfterAdd(iDocument, component);
			
			//info("Text from the clipboard was added to the document");
		}
		
		/**
		 * Add html data to a document. The importer is awful 
		 * */
		public static function addHTMLDataToDocument(iDocument:IDocument, text:String, destination:Object = null):void {
			if (text==null || text=="") {
				error("Not valid text data");
			}
			if (iDocument==null) {
				error("Not a valid document");
			}
			
			if (text==null || iDocument==null) {
				return;
			}
			
			var definition:ComponentDefinition =  ComponentManager.getDynamicComponentType("spark.components.RichText", true);
			
			if (!definition) {
				return;
			}
			
			var componentInstance:RichText = ComponentManager.createComponentToAdd(iDocument, definition, false) as RichText;
			var formatter:HTMLFormatterTLF = HTMLFormatterTLF.staticInstance;
			var translatedHTMLText:String;
			var textFlow:TextFlow;
			
			formatter.replaceLinebreaks = true;
			formatter.replaceMultipleBreaks = true;
			formatter.replaceEmptyBlockQoutes = true;
			translatedHTMLText = formatter.format(text);
			textFlow = TextConverter.importToFlow(translatedHTMLText, TextConverter.TEXT_FIELD_HTML_FORMAT);
			
			componentInstance.textFlow = textFlow;
			
			ComponentManager.addElement(componentInstance, destination, ["textFlow"], null, null, {textFlow:textFlow});
			
			ComponentManager.updateComponentAfterAdd(iDocument, componentInstance);
			
			//info("HTML from the clipboard was added to the library");
		}
		
		public static var acceptablePasteFormats:Array = ["Object", "UIComponent", "air:file list", "air:url", "air:bitmap", "air:text"];
		public static var acceptableDropFormats:Array = ["UIComponent", "air:file list", "air:url", "air:bitmap"];
		
		/**
		 * Returns true if it's a type of content we can accept to be pasted in
		 * */
		public static function isAcceptablePasteFormat(formats:Array):Boolean {
			if (formats==null || formats.length==0) return false;
			
			if (ArrayUtils.containsAny(formats, acceptablePasteFormats)) {
				return true;
			}
			
			return false;
		}
		
		/**
		 * Returns true if it's a type of content we can accept to be dragged and dropped.
		 * If we are dragging a UIComponent we don't want to accept it by default because
		 * it could be us dragging a component around the design view
		 * */
		public static function isAcceptableDragAndDropFormat(dragSource:DragSource, includeUIComponents:Boolean = false):Boolean {
			if (dragSource==null) return false;
			
			if ((dragSource.hasFormat("UIComponent") && includeUIComponents) || 
				dragSource.hasFormat("air:file list") || 
				dragSource.hasFormat("air:url") || 
				dragSource.hasFormat("air:bitmap")) {
				var url:String;
				
				// if internal html preview is visible we should return false since
				// dragged images are triggering the drop panel
				if (DocumentManager.isDocumentPreviewOpen(selectedDocument) && 
					dragSource.hasFormat("air:url")) {
					// http://www.radii8.com/.../image.jpg
					//url = dragSource.dataForFormat(ClipboardFormats.URL_FORMAT) as String;
					return false;
				}
				return true;
			}
			
			return false;
		}
		
		protected static function setupPasteFileLoader():void {
			if (deferredFileLoader==null) {
				deferredFileLoader = new LoadFile();
				//pasteFileLoader.addEventListener(LoadFile.LOADER_COMPLETE, pasteFileCompleteHandler, false, 0, true);
				//pasteFileLoader.addEventListener(LoadFile.COMPLETE, pasteFileCompleteHandler, false, 0, true);
				deferredFileLoader.addEventListener(LoadFile.LOADER_COMPLETE, dropFileCompleteHandler, false, 0, true);
				deferredFileLoader.addEventListener(LoadFile.COMPLETE, dropFileCompleteHandler, false, 0, true);
			}
		}/*
		
		// mostly a duplicate of setup paste file loader but haven't had chance to test it 
		protected function setupDropFileLoader():void {
			if (dropFileLoader==null) {
				dropFileLoader = new LoadFile();
				dropFileLoader.addEventListener(LoadFile.LOADER_COMPLETE, dropFileCompleteHandler, false, 0, true);
				dropFileLoader.addEventListener(LoadFile.COMPLETE, dropFileCompleteHandler, false, 0, true);
			}
		}*/
		
		/**
		 * Occurs after files are dropped into the document are fully loaded 
		 * */
		protected static function dropFileCompleteHandler(event:Event):void {
			var resized:Boolean;
			var imageData:ImageData;
			
			// if we need to load the images ourselves then skip complete event
			// and wait until loader complete event
			if (deferredFileLoader.loadIntoLoader && event.type!=LoadFile.LOADER_COMPLETE) {
				return;
			}
			
			if (!deferredDocument) {
				error("No document was found to add a file into");
				return;
			}
			
			if (loadingPSD) {
				loadingPSD = false;
				info("Importing PSD");
				DeferManager.callAfter(250, addPSDToDocument, deferredFileLoader.data, deferredDocument);
				return;
			}
			
			if (loadingMXML) {
				loadingMXML = false;
				info("Importing MXML");
				DeferManager.callAfter(250, ImportManager.importMXMLDocument, selectedProject, deferredDocument, deferredFileLoader.dataAsString, deferredDocument.instance);
				return;
			}
			
			if (loadingFXG) {
				loadingFXG = false;
				info("Importing FXG");
				DeferManager.callAfter(250, ImportManager.importFXGDocument, selectedProject, deferredDocument, deferredFileLoader.dataAsString, deferredDocument.instance);
				return;
			}
			
			if (loadingSVG) {
				loadingSVG = false;
				info("Importing SVG");
				DeferManager.callAfter(250, ImportManager.importSVGDocument, selectedProject, deferredDocument, deferredFileLoader.dataAsString, deferredDocument.instance);
				return;
			}
			
			imageData = new ImageData();
			imageData.bitmapData = deferredFileLoader.bitmapData;
			imageData.byteArray = deferredFileLoader.data;
			imageData.name = deferredFileLoader.currentFileReference.name;
			imageData.contentType = deferredFileLoader.loaderContentType;
			imageData.file = deferredFileLoader.currentFileReference;
			
			addAssetToDocument(imageData, deferredDocument);
			resized = addImageDataToDocument(imageData, deferredDocument);
			//list.selectedItem = data;
			
			//uploadAttachment(fileLoader.fileReference);
			
			if (resized) {
				info("An image was added to the library and the document and resized to fit");
			}
			else {
				info("An image was added to the library");
			}
			
			Radiate.setTarget(ComponentManager.lastCreatedComponent);
			
			Radiate..dispatchAssetLoadedEvent(imageData, deferredDocument, resized, true);
		}
		
		/**
		 * Get destination component or application when image files are 
		 * dropped from an external source
		 * */
		public static function getDestinationForExternalFileDrop():Object {
			var destination:Object = Radiate.instance.target;
			var addToDocumentForNow:Boolean = true;
			
			// get destination of clipboard contents
			if (destination && !(destination is IVisualElementContainer)) {
				if (addToDocumentForNow) {
					destination = null;
				}
				else {
					destination = destination.owner;
				}
			}
			
			if (!destination && selectedDocument) {
				destination = selectedDocument.instance;
			}
			
			return destination;
		}
		
		public static function dropItemWeb(object:Object, createNewDocument:Boolean = false, createDocumentIfNeeded:Boolean = true, resizeIfNeeded:Boolean = true, resizeDocumentToContent:Boolean = false):void {
			var fileData:FileData;
			var byteArray:ByteArray;
			var destination:Object;
			var htmlDragData:HTMLDragData;
			var extension:String;
			var hasPSD:Boolean;
			var hasMXML:Boolean;
			var hasFXG:Boolean;
			var hasSVG:Boolean;
			var hasImage:Boolean;
			var fileSafeList:Array;
			var value:String;
			var smooth:Boolean = true;
			fileSafeList = [];
			
			if (object is HTMLDragEvent) {
				htmlDragData = object.data as HTMLDragData;
			}
			else if (object is HTMLDragData) {
				htmlDragData = object as HTMLDragData;
			}
			
			if (htmlDragData.mimeType==HTMLDragManager.INVALID) {
				warn("The dropped file was not valid.");
				return;
			}
			
			fileData = new FileData(htmlDragData);
			ViewManager.mainView.dropImagesLocation.visible = false;
			extension = htmlDragData.getExtension();
			
			if (extension=="png" || 
				extension=="jpg" || 
				extension=="jpeg" || 
				extension=="gif") {
				hasImage = true;
				fileSafeList.push(fileData);
			}
			else if (extension=="psd") {
				fileSafeList.push(fileData);
				hasPSD = true;
			}
			else if (extension=="mxml") {
				fileSafeList.push(fileData);
				hasMXML = true;
			}
			else if (extension=="fxg") {
				fileSafeList.push(fileData);
				hasFXG = true;
			}
			else if (extension=="svg") {
				fileSafeList.push(fileData);
				hasSVG = true;
			}
			else {
				//path_txt = "Not a recognised file format";  
			}
			
			if (createNewDocument || (createDocumentIfNeeded && selectedDocument==null)) {
				DocumentManager.createNewDocumentAndSwitchToDesignView(htmlDragData, selectedProject, resizeIfNeeded, resizeDocumentToContent);
			}
			else {
				if (hasImage) {
					addBase64ImageDataToDocument(selectedDocument, fileData, destination, fileData.name, true, resizeIfNeeded, resizeDocumentToContent);
				}
				else if (hasPSD) {
					byteArray = htmlDragData.getByteArray();
					addPSDToDocument(byteArray, selectedDocument);
				}
				else if (hasMXML) {
					value = htmlDragData.getString();
					ImportManager.importMXMLDocument(selectedProject, selectedDocument, value, selectedDocument.instance);
				}
				else if (hasFXG) {
					value = htmlDragData.getString();
					ImportManager.importFXGDocument(selectedProject, selectedDocument, value, selectedDocument.instance);
				}
				else if (hasSVG) {
					value = htmlDragData.getString();
					ImportManager.importSVGDocument(selectedProject, selectedDocument, value, selectedDocument.instance);
				}
			}
		}
		
		public static function dropItem(event:DragEvent, createNewDocument:Boolean = false):void {
			var dragSource:DragSource;
			var hasFileListFormat:Boolean;
			var hasFilePromiseListFormat:Boolean;
			var hasURLFormat:Boolean;
			var isSelf:Boolean;
			var AIR_URL:String = "air:url";
			var isHTMLPreviewOpen:Boolean;
			
			AIR_URL = ClipboardFormats.URL_FORMAT;
			
			dragSource = event.dragSource;
			hasFileListFormat = dragSource.hasFormat(ClipboardFormats.FILE_LIST_FORMAT);
			hasFilePromiseListFormat = dragSource.hasFormat(ClipboardFormats.FILE_PROMISE_LIST_FORMAT);
			hasURLFormat = dragSource.hasFormat(AIR_URL);
			
			isHTMLPreviewOpen = DocumentManager.isDocumentPreviewOpen(selectedDocument);
			
			
			var destination:Object;
			var droppedFiles:Array;
			
			if (isAcceptableDragAndDropFormat(dragSource)) {
				
				if (hasFileListFormat) {
					droppedFiles = dragSource.dataForFormat(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				}
				else if (hasFilePromiseListFormat) {
					droppedFiles = dragSource.dataForFormat(ClipboardFormats.FILE_PROMISE_LIST_FORMAT) as Array;
				}
					
					// not handling URL format. need to load it and check the file type
				else if (hasURLFormat) {
					
					// if internal html preview is visible we should return false since
					if (isHTMLPreviewOpen) {
						
						// dragged images are triggering the drop panel
					}
					
					return;
				}
				
				if (droppedFiles) {
					
					if (selectedDocument==null || createNewDocument) {
						DocumentManager.createNewDocumentAndSwitchToDesignView(droppedFiles, selectedProject);
					}
					else if (selectedDocument) {
						destination = getDestinationForExternalFileDrop();
						addFileListDataToDocument(selectedDocument, droppedFiles as Array, destination);
					}
					else {
						
					}
				}
				
			}
			
			// Error: Attempt to access a dead clipboard
			//  at flash.desktop::Clipboard/checkAccess()
			//  at flash.desktop::Clipboard/getData()
			// Occurs when accessing a dragSource at a later time than the drop event
			// droppedFiles = dragSource.dataForFormat(ClipboardFormats.FILE_LIST_FORMAT) as Array;
		}
		
		/**
		 * 
		 **/
		public static function dropInBitmapData(bitmapData:BitmapData, createNewDocument:Boolean = false, createDocumentIfNeeded:Boolean = true):void {
			var fileData:FileData;
			var destination:Object;
			var imageData:ImageData;
			
			if (createNewDocument || (createDocumentIfNeeded && selectedDocument==null)) {
				DocumentManager.createNewDocumentAndSwitchToDesignView(bitmapData, selectedProject);
			}
			else {
				destination = getDestinationForExternalFileDrop();
				imageData = addBitmapDataToDocument(selectedDocument, bitmapData, destination, null, true);
			}
		}
		
		/**
		 * Used on select event when browsing for file
		 * */
		public static function loadSelectedFile(files:Object):void {
			var destination:Object;
			var filesToAdd:Array = [];
			
			if (files is FileReferenceList) {
				filesToAdd = FileReferenceList(files).fileList;
			}
			else if (files is FileReference) {
				filesToAdd = [files];
			}
			else if (files is Array) {
				filesToAdd = (files as Array).slice();
			}
			
			if (filesToAdd && filesToAdd.length) {
				destination = getDestinationForExternalFileDrop();
				deferredDocument = selectedDocument;
				addFileListDataToDocument(selectedDocument, filesToAdd, destination);
			}
			else {
				warn("No files were selected.");
			}
			
		}
		
		//----------------------------------
		//  instance
		//----------------------------------
		
		public static function get instance():LibraryManager
		{
			if (!_instance) {
				_instance = new LibraryManager(new SINGLEDOUBLE());
			}
			return _instance;
		}
		
		public static function getInstance():LibraryManager {
			return instance;
		}
		
		private static var _instance:LibraryManager;
	}
}

class SINGLEDOUBLE{}