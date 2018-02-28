package com.flexcapacitor.managers 
{
	import com.flexcapacitor.components.DocumentContainer;
	import com.flexcapacitor.components.IDocumentContainer;
	import com.flexcapacitor.controller.Console;
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.controls.RichTextEditorBar;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.model.AttachmentData;
	import com.flexcapacitor.model.Document;
	import com.flexcapacitor.model.DocumentData;
	import com.flexcapacitor.model.ExportOptions;
	import com.flexcapacitor.model.HTMLDragData;
	import com.flexcapacitor.model.HTMLExportOptions;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IDocumentData;
	import com.flexcapacitor.model.IDocumentMetaData;
	import com.flexcapacitor.model.IProject;
	import com.flexcapacitor.model.ImageData;
	import com.flexcapacitor.model.SaveResultsEvent;
	import com.flexcapacitor.model.SavedData;
	import com.flexcapacitor.model.Settings;
	import com.flexcapacitor.model.SourceData;
	import com.flexcapacitor.services.IServiceEvent;
	import com.flexcapacitor.services.WPService;
	import com.flexcapacitor.utils.ClassUtils;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.MXMLDocumentConstants;
	import com.flexcapacitor.utils.PopUpOverlayManager;
	import com.flexcapacitor.utils.SharedObjectUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	import com.flexcapacitor.utils.supportClasses.FileData;
	import com.google.code.flexiframe.IFrame;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.StageQuality;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.containers.TabNavigator;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.managers.LayoutManager;
	import mx.utils.NameUtil;
	import mx.utils.ObjectUtil;
	
	import spark.components.Application;
	import spark.components.Image;
	import spark.components.NavigatorContent;
	import spark.components.Scroller;
	import spark.components.supportClasses.GroupBase;
	import spark.core.IViewport;
	import spark.effects.Animate;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	
	import org.as3commons.lang.DictionaryUtils;
	
	/**
	 * Manages documents
	 **/
	public class DocumentManager extends Console {
		
		public function DocumentManager(s:SINGLEDOUBLE) {
			super();
		}
		
		public static var DEFAULT_DOCUMENT_WIDTH:int = 800;
		public static var DEFAULT_DOCUMENT_HEIGHT:int = 500;//792;
		
		/**
		 * Service to delete document
		 * */
		public static var deleteDocumentService:WPService;
		
		/**
		 * Set to true when a document is being saved to the server
		 * */
		[Bindable]
		public static var saveDocumentInProgress:Boolean;
		
		/**
		 * Set to true when deleting a document
		 * */
		[Bindable]
		public static var deleteDocumentInProgress:Boolean;
		
		/**
		 * When deleting a document this is the id of the project it was part of
		 * since you need to save the project after a delete.
		 * */
		[Bindable]
		public static var deleteDocumentProjectId:int;
		
		/**
		 * The different statuses a document can have
		 * Based on WordPress posts status, "draft", "publish", etc
		 * */
		[Bindable]
		public static var documentStatuses:ArrayCollection = new ArrayCollection([WPService.STATUS_NONE, WPService.STATUS_DRAFT, WPService.STATUS_PUBLISH]);
		
		/**
		 * Is true when preview is visible. This is manually set. 
		 * Needs refactoring. 
		 * */
		public var isDocumentPreviewVisible:Boolean;
		
		private static var _documentsTabNavigator:TabNavigator;
		
		/**
		 * Reference to the tab navigator that creates documents
		 * */
		public static function get documentsTabNavigator():TabNavigator {
			return _documentsTabNavigator;
		}
		
		/**
		 * @private
		 */
		public static function set documentsTabNavigator(value:TabNavigator):void {
			_documentsTabNavigator = value;
		}
		
		/**
		 * Reference to the tab that the document belongs to
		 * */
		public static var documentsContainerDictionary:Dictionary = new Dictionary(true);
		
		/**
		 * Reference to the tab that the document preview belongs to
		 * */
		public static var documentsPreviewDictionary:Dictionary = new Dictionary(true);
		
		/**
		 * Storage when dropping file onto window before document is created 
		 **/
		public static var fileToBeLoaded1:Object;
		
		/**
		 * Name of file to be loaded
		 **/
		public static var fileToBeLoadedName1:String;
		
		/**
		 * Storage for option to resize dropped file to fit document 
		 **/
		public static var resizeNewFileIfNeeded1:Boolean;
		
		/**
		 * Storage for option to resize document to fit dropped file 
		 **/
		public static var resizeDocumentToNewFileIfNeeded1:Boolean;
		
		/**
		 * When deleting a document 
		 * you need to save the project after. Set this to true to save 
		 * after results are in from document delete call.
		 * */
		[Bindable]
		public static var saveProjectAfterDelete:Boolean;
		
		/**
		 *  @private
		 *  Storage for the documents property.
		 */
		private static var _documents:Array = [];
		
		/**
		 * Selected documents
		 * */
		public static function get documents():Array {
			return _documents;
		}
		
		/**
		 * Selected documents
		 *  @private
		 * */
		[Bindable]
		public static function set documents(value:Array):void {
			// the following comments are old possibly irrelevant...
			// remove listeners from previous documents
			var n:int = _documents.length;
			
			for (var i:int = n - 1; i >= 0; i--) {
				if (_documents[i] == null) {
					continue;
				}
				
				//removeHandlers(_documents[i]);
			}
			
			// Strip out null values.
			// Binding will trigger again when the null documents are created.
			n = value.length;
			
			for (i = n - 1; i >= 0; i--) {
				if (value[i] == null) {
					value.splice(i,1);
					continue;
				}
				
				//addHandlers(value[i]);
			}
			
			_documents = value;
			
		}
		
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
		 * The canvas border.
		 * */
		public static var canvasBorder:Object;
		
		/**
		 * The canvas background.
		 * */
		public static var canvasBackground:Object;
		
		/**
		 * The canvas scroller.
		 * */
		public static var canvasScroller:Scroller;
		
		// Tools
		private static var _toolLayer:IVisualElementContainer;
		
		/**
		 * Container that tools can draw too
		 * */
		public static function get toolLayer():IVisualElementContainer {
			return _toolLayer;
		}
		
		/**
		 * @private
		 */
		public static function set toolLayer(value:IVisualElementContainer):void {
			_toolLayer = value;
		}
		
		
		private static var _editorComponent:RichTextEditorBar;
		
		/**
		 * Text editor component that has formatting tools on it
		 * */
		public static function get editorComponent():RichTextEditorBar {
			return _editorComponent;
		}
		
		/**
		 * @private
		 */
		public static function set editorComponent(value:RichTextEditorBar):void {
			_editorComponent = value;
		}
		/**
		 * Sets the canvas and canvas parent. Not sure if going to be used. 
		 * May use canvas property on document.
		 * */
		public static function setCanvas(border:Object, background:Object, scroller:Scroller, dispatchEvent:Boolean = true, cause:String = ""):void {
			//if (this.canvasBackground==canvasBackground) return;
			
			canvasBorder = border;
			canvasBackground = background;
			canvasScroller = scroller;
			
			if (dispatchEvent) {
				Radiate.dispatchCanvasChangeEvent(canvasBackground, canvasBorder, canvasScroller);
			}
			
		}
		
		/**
		 * Select the document
		 * */
		public static function selectDocument(document:IDocument, dispatchEvent:Boolean = true, cause:String = ""):void {
			return Radiate.selectDocument(document, dispatchEvent, cause);
		}
		
		/**
		 * Gets a snapshot of document and returns bitmap data
		 * */
		public static function getDocumentSnapshot(iDocument:IDocument, scale:Number = 1, quality:String = StageQuality.BEST):BitmapData {
			var bitmapData:BitmapData;
			
			if (iDocument && iDocument.instance) {
				bitmapData = DisplayObjectUtils.getUIComponentWithQuality(iDocument.instance as UIComponent, quality) as BitmapData;
			}
			
			return bitmapData;
		}
		
		/**
		 * Get a list of documents. If open is set to true then gets only open documents.
		 * */
		public static function getOpenDocumentsSaveData(metaData:Boolean = false):Array {
			var documentsArray:Array = SettingsManager.getSaveDataForAllDocuments(true, metaData);
			return documentsArray;
		}
		
		/**
		 * Get a list of documents data for storage by project. If open is set to true then only returns open documents.
		 * */
		public static function getDocumentsSaveDataByProject(project:IProject, open:Boolean = false):Array {
			var documentsArray:Array = project.getSavableDocumentsData(open);
			
			return documentsArray;
		}
		
		/**
		 * Updates the saved data with the changes from the document passed in
		 * */
		public static function updateSaveDataForDocument(iDocumentData:IDocumentData, metaData:Boolean = false):SavedData {
			var savedData:SavedData = SettingsManager.savedData;
			var documentsArray:Array = savedData.documents;
			var numberOfDocuments:int = documentsArray.length;
			var documentMetaData:IDocumentMetaData;
			var found:Boolean;
			var foundIndex:int = -1;
			
			for (var i:int;i<numberOfDocuments;i++) {
				documentMetaData = IDocumentMetaData(documentsArray[i]);
				//Radiate.info("Exporting document " + iDocument.name);
				
				if (documentMetaData.uid == iDocumentData.uid) {
					found = true;
					foundIndex = i;
				}
			}
			
			if (found) {
				
				if (metaData) {
					documentsArray[foundIndex] = iDocumentData.toMetaData();
				}
				else {
					documentsArray[foundIndex] = iDocumentData.marshall();
				}
			}
			else {
				if (metaData) {
					documentsArray.push(iDocumentData.toMetaData());
				}
				else {
					documentsArray.push(iDocumentData.marshall());
				}
			}
			
			
			return savedData;
		}
		
		/**
		 * Copy document image to the clipboard
		 **/
		public static function copyDocumentImageToClipboard(iDocument:IDocument):void {
			var bitmapData:BitmapData = getDocumentSnapshot(iDocument);
			ClipboardManager.instance.copyBitmapDataToClipboard(bitmapData);
		}
		
		/**
		 * Get MXML source of the document 
		 * */
		public static function getDocumentMXML(iDocument:IDocument, target:Object = null, options:ExportOptions = null):SourceData {
			var options:ExportOptions;
			var sourceItemData:SourceData;
			
			if (options==null) {
				options = new ExportOptions();
				options.useInlineStyles = true;
				options.exportChildDescriptors = true;
			}
			
			if (target==null) {
				target = iDocument.componentDescription.instance;
			}
			
			if (iDocument.getItemDescription(target)) {
				sourceItemData = CodeManager.getSourceData(target, iDocument, CodeManager.MXML, options);
				
				if (sourceItemData) {
					return sourceItemData;
				}
			}
			
			return null;
		}
		
		/**
		 * Gets the display list of the current document
		 * */
		public static function getComponentDisplayList(document:IDocument):ComponentDescription {
			return IDocumentContainer(document).componentDescription;
		}
		
		/**
		 * Creates a new project and document and if a file is 
		 * provided then it imports the file and sizes the document to the fit. 
		 * 
		 * This is to support drag and drop of file onto application icon
		 * and open with methods. 
		 * */
		public static function createNewDocumentAndSwitchToDesignView(file:Object = null, iProject:Object = null, resizeIfNeeded:Boolean = true, resizeDocumentToContent:Boolean = false, name:String = null):IDocument {
			var documentName:String = "Document";
			var iDocument:IDocument;
			var radiate:Radiate = Radiate.instance;
			var newDeferredData:AttachmentData;
			
			ViewManager.goToDesignScreen();
			
			iDocument = createBlankDemoDocument(iProject, documentName);
			
			//if (fileToBeLoaded) {
			if (file) {
				newDeferredData = new AttachmentData();
				newDeferredData.file = file as FileReference;
				newDeferredData.data = file;
				newDeferredData.name = name;
				newDeferredData.resizeToFitDocument = resizeIfNeeded;
				newDeferredData.resizeDocumentToFit = resizeDocumentToContent;
				
				iDocument.deferredData = newDeferredData;
				
				radiate.addEventListener(RadiateEvent.DOCUMENT_OPEN, documentOpenedHandler, false, 0, true);
			}
			
			if (ProfileManager.isUserLoggedIn && iDocument) {
				ProjectManager.saveProjectOnly(iDocument.project);
			}
			
			return iDocument
		}
				
		/**
		 * Refreshes the document by closing and opening
		 * */
		public static function refreshDocument(iDocument:IDocument, rebuildFromHistory:Boolean = false):Boolean {
			var documentInstance:Object = iDocument.instance;
			
			if (rebuildFromHistory) {
				info("Rebuilding document");
				Radiate.setTarget(null);
				DeferManager.callAfter(250, HistoryManager.rebuild, iDocument);
			}
			else if (iDocument.isOpen) {
				closeDocument(iDocument);
				openDocument(iDocument, DocumentData.REMOTE_LOCATION, true);
				Radiate.info("Document rebuilt");
			}
			
			return true;
		}
		
		/**
		 * Handles when new document has been created after dropping or importing a file  
		 **/
		public static function documentOpenedHandler(event:RadiateEvent):void {
			var iDocument:IDocument = event.selectedItem as IDocument;
			var deferredData:AttachmentData = iDocument.deferredData;
			var newFileData:Object;
			var fileName:String;
			var fileData:FileData;
			var destination:Object;
			var resizeNewFileIfNeeded:Boolean;
			var resizeDocumentToNewFileIfNeeded:Boolean;
			
			if (deferredData && deferredData.isLoaded==false) {
				newFileData = deferredData.data;
				fileName = deferredData.name;
				resizeNewFileIfNeeded = deferredData.resizeToFitDocument;
				resizeDocumentToNewFileIfNeeded = deferredData.resizeDocumentToFit;
			}
			
			if (newFileData is FileReference) {
				if (newFileData.exists && newFileData.isDirectory==false) {
					Radiate.addEventListener(RadiateEvent.ASSET_LOADED, fileLoadedHandler, false, 0, true);
					LibraryManager.addFileListDataToDocument(iDocument, [newFileData]);
				}
			}
			else if (newFileData is DragEvent) {
				LibraryManager.dropItem(newFileData as DragEvent);
			}
			else if (newFileData is HTMLDragData) {
				LibraryManager.dropItemWeb(newFileData, false, true, resizeNewFileIfNeeded, resizeDocumentToNewFileIfNeeded);
			}
			else if (newFileData is FileData) {
				fileData = newFileData as FileData;
				LibraryManager.addBase64ImageDataToDocument(selectedDocument, fileData, null, fileData.name, true, resizeNewFileIfNeeded, resizeDocumentToNewFileIfNeeded);
			}
			else if (newFileData is Array && newFileData.length) {
				//destination = getDestinationForExternalFileDrop();
				LibraryManager.addFileListDataToDocument(selectedDocument, newFileData as Array);
			}
			else if (newFileData is BitmapData) {
				LibraryManager.addBitmapDataToDocument(selectedDocument, newFileData as BitmapData, null, fileName, true, resizeNewFileIfNeeded, resizeDocumentToNewFileIfNeeded);
			}
			
			Radiate.instance.removeEventListener(RadiateEvent.DOCUMENT_OPEN, documentOpenedHandler);
			
			if (deferredData) {
				deferredData.isLoaded = true;
			}
		}
		
		/**
		 * Handles when loading a file opened from dialog or dropped on the application
		 **/
		protected static function fileLoadedHandler(event:RadiateEvent):void {
			var successful:Boolean = event.successful;
			var imageData:ImageData = event.data as ImageData;
			var iDocument:IDocument = event.selectedItem as IDocument;
			var importedImageResized:Boolean = event.resized;
			var bitmapData:BitmapData = imageData && imageData.bitmapData ? imageData.bitmapData : null;
			var fileReference:FileReference;
			
			Radiate.instance.removeEventListener(RadiateEvent.ASSET_LOADED, fileLoadedHandler);
			
			if (!successful) {
				warn("File was not imported.");
				return;
			}
			
			if (bitmapData && bitmapData.width>0 && bitmapData.height>0) {
				DocumentManager.sizeDocumentToBitmapData(iDocument, bitmapData);
				
				if (importedImageResized && Radiate.instance.target) {
					ComponentManager.sizeSelectionToDocument();
				}
				
				ScaleManager.scaleToFit(false);
				DocumentManager.centerDocumentInViewport();
			}
			
		}
		
		/**
		 * Show message when document has been rebuilt
		 * */
		public static function refreshDocumentHandler(event:RadiateEvent):void {
			Radiate.info("Document rebuilt");
		}
		
		/**
		 * Open document for editing in browser. 
		 * */
		public static function editDocumentInBrowser(documentData:IDocumentData):void {
			var request:URLRequest;
			var url:String;
			request = new URLRequest();
			
			if (documentData && documentData.id==null) {				
				error("The document ID is not set. You may need to save the document first.");
			}
			
			if (documentData is ImageData) {
				url = ImageData(documentData).url;
			}
			else {
				url = Radiate.getWPEditPostURL(documentData);
			}
			
			if (url) {
				request.url = url;
				navigateToURL(request, "editInBrowser");
			}
			else {
				error("URL to the document was not set. You may need to save the document first.");
			}
		}
		
		/**
		 * Resizes the current document to show all of it's content
		 * */
		public static function expandDocumentToContents():Boolean {
			var radiate:Radiate = Radiate.instance;
			var iDocument:IDocument = selectedDocument;
			var targetObject:Object = iDocument.instance;
			var documentRectangle:Rectangle;
			var contentRectangle:Rectangle;
			var resized:Boolean;
			var width:Number;
			var height:Number;
			
			contentRectangle = new Rectangle();
			documentRectangle = new Rectangle();
			
			width = targetObject.contentGroup.contentWidth;
			height = targetObject.contentGroup.contentHeight;
			
			contentRectangle.width = width;
			contentRectangle.height = height;
			
			documentRectangle.width = targetObject.width;
			documentRectangle.height = targetObject.height;
			
			if (contentRectangle.width>documentRectangle.width || contentRectangle.height>documentRectangle.height) {
				contentRectangle.width = Math.max(contentRectangle.width, documentRectangle.width);
				contentRectangle.height = Math.max(contentRectangle.height, documentRectangle.height);
				ComponentManager.setProperties(targetObject, ["width","height"], contentRectangle, "Expand document");
				resized = true;
			}
			
			return resized;
		}
		
		/**
		 * Open document in browser. Right now you must be 
		 * logged in or the document must be published
		 * */
		public static function openInBrowser(documentData:IDocumentData, windowName:String = null):void {
			var request:URLRequest;
			var url:String;
			
			if (documentData==null) {
				warn("Please select a document.");
				return;
			}
			
			request = new URLRequest();
			
			if (windowName==null && documentData.name) {
				windowName = documentData.name;
			}
			
			if (documentData is ImageData) {
				url = ImageData(documentData).url;
			}
			else {
				url = documentData.uri;
			}
			
			if (url) {
				request.url = url;
				navigateToURL(request, windowName);
			}
			else {
				error("The URL was not set. You may need to save the document first.");
			}
		}
		
		/**
		 * Open document in browser screenshot site. 
		 * The document must be published so the external site can view it
		 * */
		public static function openInBrowserScreenshot(documentData:IDocumentData, windowName:String = null):void {
			var request:URLRequest;
			var url:String;
			
			if (documentData==null) {
				warn("Please select a document.");
				return;
			}
			
			request = new URLRequest();
			
			if (windowName==null && documentData.name) {
				windowName = documentData.name;
			}
			
			if (documentData is ImageData) {
				url = ImageData(documentData).url;
			}
			else {
				url = documentData.uri;
			}
			
			if (url) {
				request.url = Radiate.SCREENSHOT_PATH + url;
				navigateToURL(request, windowName);
			}
			else {
				error("The URL was not set. You may need to publish and save the document first.");
			}
		}
		
		/**
		 * Open document in browser site scanner site. 
		 * The document must be published so the external site can view it
		 * */
		public static function openInBrowserSiteScanner(documentData:IDocumentData, windowName:String = null):void {
			var request:URLRequest;
			var url:String;
			
			if (documentData==null) {
				warn("Please select a document.");
				return;
			}
			
			request = new URLRequest();
			
			if (windowName==null && documentData.name) {
				windowName = documentData.name;
			}
			
			if (documentData is ImageData) {
				url = ImageData(documentData).url;
			}
			else {
				url = documentData.uri;
			}
			
			if (url) {
				request.url = Radiate.SITE_SCANNER_PATH + encodeURI(url);
				navigateToURL(request, windowName);
			}
			else {
				error("The URL was not set. You may need to publish and save the document first.");
			}
		}
		
		/**
		 * Sizes the document to the bitmap data target
		 * */
		public static function sizeDocumentToBitmapData(iDocument:IDocument, bitmapData:BitmapData):Boolean {
			var documentInstance:Object = iDocument.instance;
			var rectangle:Rectangle;
			var resized:Boolean;
			
			if (documentInstance) {
				rectangle = new Rectangle(0, 0, bitmapData.width, bitmapData.height);
				
				if (rectangle.width>0 && rectangle.height>0) {
					ComponentManager.setProperties(documentInstance, ["width","height"], rectangle, "Size document to image");
					resized = true;
				}
			}
			
			return resized;
		}
		
		/**
		 * Sizes the document to the current selected target
		 * */
		public static function sizeDocumentToSelection():void {
			var iDocument:IDocument = Radiate.selectedDocument;
			
			if (Radiate.instance.target && iDocument) {
				var rectangle:Rectangle = ComponentManager.getSize(Radiate.instance.target);
				
				if (rectangle.width>0 && rectangle.height>0) {
					ComponentManager.setProperties(iDocument.instance, ["width","height"], rectangle, "Size document to selection");
				}
			}
		}
		
		/**
		 * Sizes the document to the original size of the image 
		 * */
		public static function sizeDocumentToOriginalImageSize():void {
			var iDocument:IDocument = Radiate.selectedDocument;
			
			if (Radiate.target && iDocument) {
				var componentDescription:ComponentDescription = iDocument ? iDocument.getItemDescription(Radiate.target.target) : null;
				var image:Image = componentDescription ? componentDescription.instance as Image : null;
				var bitmapData:BitmapData = image ? image.bitmapData : null;
				
				if (bitmapData && bitmapData.width>0 && bitmapData.height>0) {
					ImageManager.restoreImageToOriginalSize(image);
					DocumentManager.sizeDocumentToBitmapData(iDocument, image.bitmapData);
				}
			}
		}
		
		/**
		 * Center the document in the design view when the document is larger than viewport 
		 * 
		 * @param vertically enable vertically centering options. if verticalTop is false top and bottom may be cut off. if true, scroll to top
		 * @param verticallyTop if document is taller than avialable space keep it at the top
		 * @param horizontalLeft if document is wider than avialable space keep it to the left
		 * @param totalDocumentPadding adjustment for space at the top of the document. not sure really
		 * */
		public static function centerDocumentInViewport(vertically:Boolean = true, verticallyTop:Boolean = true, horizontalLeft:Boolean=true, totalDocumentPadding:int = 0):void {
			if (!canvasScroller) return;
			var viewport:IViewport = canvasScroller.viewport;
			var documentVisualElement:IVisualElement = IVisualElement(selectedDocument.instance);
			var contentWidth:int = documentVisualElement.width * ScaleManager.getScale();
			var contentHeight:int = documentVisualElement.height * ScaleManager.getScale();
			var newHorizontalPosition:int;
			var newVerticalPosition:int;
			var needsValidating:Boolean;
			//var vsbWidth:int = canvasScroller.verticalScrollBar ? canvasScroller.verticalScrollBar.width : 11;
			var hsbHeight:int = canvasScroller.horizontalScrollBar ? canvasScroller.horizontalScrollBar.height : 11;
			var availableWidth:int = canvasScroller.width;// - vsbWidth;
			var availableHeight:int = canvasScroller.height;// - hsbHeight;
			
			if (LayoutManager.getInstance().isInvalid()) {
				needsValidating = true;
			}
			
			
			if (vertically) {
				// scroller height 359, content height 504, content height validated 550
				// if document is taller than available space and 
				// verticalTop is true then keep it at the top
				if (contentHeight > availableHeight && verticallyTop) {
					newVerticalPosition = canvasBackground.y - totalDocumentPadding;
					viewport.verticalScrollPosition = Math.max(0, newVerticalPosition);
				}
				else if (contentHeight > availableHeight) {
					newVerticalPosition = (contentHeight + hsbHeight - availableHeight) / 2;
					viewport.verticalScrollPosition = Math.max(0, newVerticalPosition);
				}
				else {
					// content height 384, scroller height 359, vsp 12
					newVerticalPosition = (availableHeight + hsbHeight - contentHeight) / 2;
					viewport.verticalScrollPosition = Math.max(0, newVerticalPosition);
				}
			}
			
			// if width of content is wider than canvasScroller width then center
			if (canvasScroller.width < contentWidth) {
				
				if (horizontalLeft) {
					newHorizontalPosition = 0;
					viewport.horizontalScrollPosition = newHorizontalPosition;
				}
				else {
					newHorizontalPosition = (contentWidth - availableWidth) / 2;
					viewport.horizontalScrollPosition = Math.max(0, newHorizontalPosition);
				}
			}
			else {
				//newHorizontalPosition = (contentWidth - canvasScroller.width) / 2;
				//viewport.horizontalScrollPosition = Math.max(0, newHorizontalPosition);
			}
		}
		
		/**
		 * Center the document in viewport on a point
		 * */
		public static function centerDocumentOnPosition(point:Point):void {
			if (!canvasScroller) return;
			
			var viewport:IViewport = canvasScroller.viewport;
			var scrollerWidth:int = canvasScroller.width;// - vsbWidth;
			var scrollerHeight:int = canvasScroller.height;// - hsbHeight;
			var vsbWidth:int = canvasScroller.verticalScrollBar ? canvasScroller.verticalScrollBar.width : 11;
			var hsbHeight:int = canvasScroller.horizontalScrollBar ? canvasScroller.horizontalScrollBar.height : 11;
			var documentVisualElement:IVisualElement = IVisualElement(selectedDocument.instance);
			var currentScale:Number = ScaleManager.getScale();
			var scaledWidth:int = documentVisualElement.width * currentScale;
			var scaledHeight:int = documentVisualElement.height * currentScale;
			
			var newX:int;
			var newY:int;
			
			newX = scrollerWidth/2 - (scaledWidth/2 - point.x);
			newX = scrollerWidth/2 - (scaledWidth/2 + (scaledWidth/2-point.x));
			newX = (scaledWidth/2 + (scaledWidth/2-(point.x*currentScale))) - scrollerWidth/2;
			newY = (scaledHeight/2 + (scaledHeight/2-(point.y*currentScale))) - scrollerHeight/2;
			newY = canvasScroller.verticalScrollBar.value;
			setDocumentScrollPosition(newX, newY);
		}
		
		/**
		 * Set the scroll position of the document in the viewport
		 * */
		public static function setDocumentScrollPosition(x:int, y:int):void {
			if (!canvasScroller) return;
			
			var viewport:IViewport = canvasScroller.viewport;
			var vsbWidth:int = canvasScroller.verticalScrollBar ? canvasScroller.verticalScrollBar.width : 11;
			var hsbHeight:int = canvasScroller.horizontalScrollBar ? canvasScroller.horizontalScrollBar.height : 11;
			var availableWidth:int = canvasScroller.width;// - vsbWidth;
			var availableHeight:int = canvasScroller.height;// - hsbHeight;
			
			viewport.horizontalScrollPosition = Math.max(0, x);
			viewport.verticalScrollPosition = Math.max(0, y);
			
		}
		
		/**
		 * Reverts the document template
		 * */
		public static function revertDocumentTemplate(iDocument:IDocument):void {
			iDocument.createTemplate();
		}
		
		/**
		 * Get document locally
		 * */
		public static function getDocumentLocally(iDocumentData:IDocumentData):IDocumentData {
			var result:Object = SharedObjectUtils.getSharedObject(SettingsManager.SAVED_DATA_NAME);
			var so:SharedObject;
			
			if (result is SharedObject) {
				so = SharedObject(result);
				//var data:Object = savedData;
				var documentsArray:Array = so.data.savedData.documents;
				var numberOfDocuments:int = documentsArray.length;
				var documentData:IDocumentData;
				var found:Boolean;
				var foundIndex:int = -1;
				
				for (var i:int;i<numberOfDocuments;i++) {
					documentData = IDocumentData(documentsArray[i]);
					
					if (documentData.uid == iDocumentData.uid) {
						found = true;
						foundIndex = i;
						
						break;
					}
				}
				
				return documentData;
			}
			else {
				error("Could not get saved data. " + ObjectUtil.toString(result));
			}
			
			return null;
		}
		
		/**
		 * Delete document results handler. You should save the project after
		 * document is deleted.
		 * */
		public static function deleteDocumentResultsHandler(event:IServiceEvent):void {
			//..Radiate.info("Delete document results");
			var data:Object = event.data;
			//var status:Boolean;
			var successful:Boolean;
			var error:String;
			var message:String;
			
			
			if (data && data is Object && "status" in data) {
				successful = data.status!="error";
			}
			
			deleteDocumentInProgress = false;
			LibraryManager.deleteAttachmentInProgress = false;
			
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
			
			//status = message;
			
			//dispatchDocumentRemovedEvent(null);
			
			Radiate.dispatchDocumentDeletedEvent(successful, data);
			
			if (successful) {
				
				if (deleteDocumentProjectId!=-1 && saveProjectAfterDelete) {
					var iProject:IProject = ProjectManager.getProjectByID(deleteDocumentProjectId);
					
					if (iProject) {
						iProject.saveOnlyProject();
					}
				}
				
			}
			
			saveProjectAfterDelete = false;
		}
		
		/**
		 * Result from delete project fault
		 * */
		public static function deleteDocumentFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.info("Could not connect to the server to delete the document. ");
			
			deleteDocumentInProgress = false;
			
			Radiate.dispatchDocumentDeletedEvent(false, data);
		}
		
		
		/**
		 * Save all documents
		 * */
		public static function saveAllDocuments(locations:String = null, saveEvenIfClean:Boolean = true):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var loadLocally:Boolean = ServicesManager.getIsLocalLocation(locations);
			var loadRemote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var numberOfDocuments:int = documents.length;
			var document:IDocument;
			var anyDocumentSaved:Boolean;
			
			if (numberOfDocuments==0) {
				warn("No douments to save");
				return false;
			}
			
			for (var i:int;i<numberOfDocuments;i++) {
				document = documents[i];
				
				if (document.isChanged || saveEvenIfClean) {
					document.save(locations);
					// TODO add support to save after response from server 
					// because ID's may have been added from new documents
					//saveData();
					//document.saveCompleteCallback = saveData;
					SettingsManager.saveDocumentLocally(document);
					anyDocumentSaved = true;
				}
			}
			
			return anyDocumentSaved;
		}
		
		/**
		 * Save document as
		 * */
		public static function saveDocumentAs(document:IDocument, extension:String = "html"):void {
			/*
			document.save();
			// TODO add support to save after response from server 
			// because ID's may have been added from new documents
			//saveData();
			//document.saveCompleteCallback = saveData;
			saveDocumentLocally(document);*/
			//return true;
		}
		
		/**
		 * Handles results from document save
		 * */
		protected static function documentSaveResultsHandler(event:SaveResultsEvent):void {
			var document:IDocument = IDocument(event.currentTarget);
			saveDocumentInProgress = false;
			
			if (document is Document) {
				Document(document).removeEventListener(SaveResultsEvent.SAVE_RESULTS, documentSaveResultsHandler);
			}
			
			
			if (event.successful) {
				DateManager.setLastSaveDate();
				Radiate.dispatchDocumentSaveCompleteEvent(document);
			}
			else {
				Radiate.dispatchDocumentSaveFaultEvent(document);
			}
		}
		
		/**
		 * This gets called on save. It allows you to modify what is saved. 
		 * */
		public static function saveDocumentHook(iDocument:IDocument, data:Object):Object {
			var htmlOptions:HTMLExportOptions;
			var language:String = CodeManager.HTML;
			var output:String = "";
			var sourceData:SourceData;
			
			if (language == CodeManager.HTML) {
				htmlOptions = CodeManager.getExportOptions(language) as HTMLExportOptions;
				
				htmlOptions.template = iDocument.template;
				//htmlOptions.bordersCSS = bordersCSS;
				//htmlOptions.showBorders = showBorders;
				//htmlOptions.useBorderBox = useBoderBox;
				//htmlOptions.useInlineStyles = setStylesInline.selected;
				//htmlOptions.template = iDocument.template;
				//htmlOptions.disableTabs = true;
				//htmlOptions.useExternalStylesheet = false;
				
				//if (updateCodeLive.selected && isCodeModifiedByUser) {
				//htmlOptions.useCustomMarkup = true;
				//htmlOptions.markup = aceEditor.text;
				//htmlOptions.styles = aceCSSEditor.text;
				//}
				
				sourceData = CodeManager.getSourceData(iDocument.instance, iDocument, language, htmlOptions);
				
				data["custom[html]"] = sourceData.source;
				data["custom[styles]"] = sourceData.styles;
				data["custom[userStyles]"] = sourceData.userStyles;
				data["custom[template]"] = sourceData.template;
				data["custom[markup]"] = sourceData.markup;
				iDocument.errors = sourceData.errors;
				iDocument.warnings = sourceData.warnings;
				
			}
			
			return data;
		}
		
		/**
		 * Save document. Uses constants, DocumentData.LOCAL_LOCATION, DocumentData.REMOTE_LOCATION, etc
		 * Separate them by ",". 
		 * */
		public static function saveDocument(iDocument:IDocument, locations:String = null, options:Object = null):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var saveLocally:Boolean = ServicesManager.getIsLocalLocation(locations);
			var saveRemote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var saveLocallySuccessful:Boolean;
			
			//trace("- Radiate save document " + iDocument.name);
			
			if (iDocument==null) {
				error("No document to save");
				return false;
			}
			
			if (saveRemote && iDocument && iDocument is EventDispatcher) {
				EventDispatcher(iDocument).addEventListener(SaveResultsEvent.SAVE_RESULTS, documentSaveResultsHandler, false, 0, true);
				saveDocumentInProgress = true;
			}
			
			iDocument.saveFunction = saveDocumentHook;
			
			saveLocallySuccessful = iDocument.save(locations, options);
			
			// TODO add support to save after response from server 
			// because ID's may have been added from new documents
			//saveData();
			//document.saveCompleteCallback = saveData;
			//saveDocumentLocally(document);
			return saveLocallySuccessful;
		}
		
		/**
		 * Show previously opened document
		 * */
		public static function showPreviouslyOpenDocument():void {
			var settings:Settings = SettingsManager.settings;
			var openDocuments:Array = settings.openDocuments;
			var iDocumentMetaData:IDocumentMetaData;
			var iDocument:IDocument;
			
			// Showing previously selected document
			if (settings.selectedDocument) {
				iDocument = getDocumentByUID(settings.selectedDocument.uid);
				
				if (iDocument && iDocument.isOpen) {
					info("Showing previously selected document " + iDocument.name);
					showDocument(iDocument);
					selectDocument(iDocument);
				}
			}
		}
		
		/**
		 * Create new document. 
		 * */
		public static function createNewDocument(name:String = null, type:Object = null, project:IProject = null):void {
			var newDocument:IDocument;
			
			newDocument = createDocument(name, type);
			addDocument(newDocument, selectedProject, true, true);
			openDocument(newDocument, DocumentData.INTERNAL_LOCATION, true);
			/*
			
			if (project) {
			project.addDocument(iDocument, overwrite);
			}
			
			if (documentAdded && dispatchEvents) {
			dispatchDocumentAddedEvent(iDocument);
			}
			
			if (!selectedProject) {
			project = createProject(); // create project
			addProject(project);       // add to projects array - shows up in application
			}
			else {
			project = selectedProject;
			}
			
			newDocument = createDocument(name, type); // create document
			addDocument(newDocument, project); // add to project and documents array - shows up in application
			
			//openProject(newProject); // should open documents - maybe we should do all previous steps in this function???
			openDocument(newDocument, true, true); // add to application and parse source code if any
			
			setProject(project); // selects project 
			setDocument(newDocument);*/
		}
		
		/**
		 * Create and add saved documents of array of type IDocumentData. 
		 * */
		public static function createAndAddDocumentsData(documentsData:Array, add:Boolean = true):Array {
			var potentialDocuments:Array = [];
			var iDocumentMetaData:IDocumentMetaData;
			var iDocumentData:IDocumentData;
			var iDocument:IDocument;
			var numberOfDocuments:int;
			
			// get documents and add them to the documents array
			
			// TRYING TO NOT create documents until they are needed
			// but then we have issues when we want to save
			if (documentsData && documentsData.length>0) {
				numberOfDocuments = documentsData.length;
				
				for (var i:int;i<numberOfDocuments;i++) {
					// TypeError: Error #1034: Type Coercion failed: cannot convert com.flexcapacitor.model::DocumentMetaData
					// to com.flexcapacitor.model.IDocumentData. check export and marshall options
					// saved as wrong data type
					iDocumentData = IDocumentData(documentsData[i]);
					
					// document doesn't exist - add it
					if (getDocumentByUID(iDocumentData.uid)==null) {
						iDocument = createDocumentFromData(iDocumentData);
						potentialDocuments.push(iDocument);
						
						if (add) {
							addDocument(iDocument);
						}
					}
					else {
						info("Document " + iDocumentData.name + " is already open.");
					}
				}
			}
			
			return potentialDocuments;
		}
		
		/**
		 * Rename document
		 * */
		public static function renameDocument(iDocument:IDocument, name:String):void {
			var tab:NavigatorContent;
			
			// todo check if name already exists
			iDocument.name = name;
			tab = getNavigatorTabByDocument(iDocument);
			
			if (iDocument.instance is Application) {
				ComponentManager.setProperty(iDocument.instance, "pageTitle", name);
			}
			
			if (tab) {
				tab.label = iDocument.name;
			}
			
			Radiate.dispatchDocumentRenameEvent(iDocument, name);
		}
		
		/**
		 * Get first project that owns this document
		 * */
		public static function getDocumentProject(iDocument:IDocument):IProject {
			var projectsList:Array = getDocumentProjects(iDocument);
			var iProject:IProject;
			
			if (projectsList.length>0) {
				iProject = projectsList.shift();
			}
			
			return iProject;
		}
		
		/**
		 * Get a list of projects that own this document
		 * */
		public static function getDocumentProjects(iDocument:IDocument):Array {
			var numberOfDocuments:int;
			var projectDocument:IDocument;
			var projects:Array = ProjectManager.projects;
			var numberOfProjects:int = projects.length;
			var iProject:IProject;
			var projectDocuments:Array;
			var projectsList:Array = [];
			
			for (var A:int;A<numberOfProjects;A++) {
				iProject = IProject(projects[A]);
				projectDocuments = iProject.documents;
				numberOfDocuments = projectDocuments ? projectDocuments.length : 0;
				
				for (var B:int;B<numberOfDocuments;B++) {
					projectDocument = IDocument(projectDocuments[B]);
					
					if (projectDocuments.uid==iDocument.uid) {
						projectsList.push(iProject);
					}
				}
			}
			
			return projectsList;
		}
		
		/**
		 * Open previously opened documents
		 * */
		public static function openPreviouslyOpenDocuments(project:IProject = null):void {
			var settings:Settings = SettingsManager.settings;
			var openDocuments:Array = settings.openDocuments;
			var iDocumentMetaData:IDocumentMetaData;
			var iDocument:IDocument;
			
			// open previously opened documents
			for (var i:int;i<openDocuments.length;i++) {
				iDocumentMetaData = IDocumentMetaData(openDocuments[i]);
				
				iDocument = getDocumentByUID(iDocumentMetaData.uid);
				
				if (iDocument) {
					
					if (project && project.documents.indexOf(iDocument)!=-1) {
						info("Opening project document " + iDocument.name);
						openDocument(iDocument, DocumentData.INTERNAL_LOCATION, false, true);
					}
					else if (project==null) {
						info("Opening document " + iDocument.name);
						openDocument(iDocument, DocumentData.INTERNAL_LOCATION, false, true);
					}
				}
				
			}
		}
		
		/**
		 * Get document by UID
		 * */
		public static function getDocumentByUID(id:String):IDocument {
			var numberOfDocuments:int = documents.length;
			var iDocument:IDocument;
			
			for (var i:int;i<numberOfDocuments;i++) {
				iDocument = IDocument(documents[i]);
				
				if (id==iDocument.uid) {
					return iDocument;
				}
			}
			
			return null;
		}
		
		/**
		 * Check if document exists in documents array
		 * */
		public static function doesDocumentExist(id:String):Boolean {
			var numberOfDocuments:int = documents.length;
			var iDocument:IDocument;
			
			for (var i:int;i<numberOfDocuments;i++) {
				iDocument = IDocument(documents[i]);
				
				if (id==iDocument.uid) {
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Selects the document in the tab navigator
		 * */
		public static function showDocument(iDocumentData:IDocumentData, isPreview:Boolean = false, dispatchEvent:Boolean = true):Boolean {
			var documentIndex:int = getDocumentTabIndex(iDocumentData, isPreview);
			var result:Boolean;
			
			if (documentIndex!=-1) {
				result = showDocumentAtNavigatorIndex(documentIndex, dispatchEvent);
			}
			
			return result;
		}
		
		
		/**
		 * Selects the document at the specifed index
		 * */
		public static function showDocumentAtNavigatorIndex(index:int, dispatchEvent:Boolean = true):Boolean {
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var tab:NavigatorContent;
			var tabContent:Object;
			var document:IDocument;
			
			documentsTabNavigator.selectedIndex = index;
			
			tab = NavigatorContent(documentsTabNavigator.selectedChild);
			tabContent = tab && tab.numElements ? tab.getElementAt(0) : null;
			
			if (tabContent && tabContent is DocumentContainer && dispatchEvent) {
				document = getDocumentAtNavigatorIndex(index);
				Radiate.dispatchDocumentChangeEvent(DocumentContainer(tabContent).iDocument);
			}
			
			return documentsTabNavigator.selectedIndex == index;
		}
		
		/**
		 * Get the document at the index in the tab navigator
		 * */
		public static function getDocumentAtNavigatorIndex(index:int):IDocument {
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var tab:NavigatorContent;
			var tabContent:Object;
			var document:IDocument;
			
			if (index<0) {
				return null;
			}
			
			tab = index < openTabs.length ? openTabs[index] : null;
			tabContent = tab.numElements ? tab.getElementAt(0) : null;
			
			for (var key:* in documentsContainerDictionary) {
				if (documentsContainerDictionary[key] === tabContent) {
					return key;
				}
			}
			
			
			for (key in documentsPreviewDictionary) {
				if (documentsPreviewDictionary[key] === tabContent) {
					return key;
				}
			}
			
			return null;
			
		}
		
		/**
		 * Returns tab that document is in
		 * */
		public static function getNavigatorTabByDocument(iDocument:IDocument, isPreview:Boolean = false):NavigatorContent {
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var tab:NavigatorContent;
			var tabContent:Object;
			var documentContainer:Object = isPreview ? documentsPreviewDictionary[iDocument] : documentsContainerDictionary[iDocument];
			
			for (var i:int;i<tabCount;i++) {
				tab = NavigatorContent(documentsTabNavigator.getChildAt(i));
				tabContent = tab.numElements ? tab.getElementAt(0) : null;
				
				if (tabContent && tabContent==documentContainer) {
					return tab;
				}
			}
			
			return null;
		}
		
		/**
		 * Opens a new document with MXML specified
		 * */
		public static function openMXMLDocument(name:String, mxml:String):void {
			name = name.lastIndexOf(".")!=-1 ? name.substr(0, name.lastIndexOf(".")) : name;
			ImportManager.importMXMLDocument(selectedProject, null, mxml, null, -1, name);
		}
		
		/**
		 * Returns if the visible document is a preview
		 * */
		public static function isPreviewDocumentVisible():Boolean {
			var tabContainer:NavigatorContent = documentsTabNavigator.selectedChild as NavigatorContent;
			var tabContent:Object = tabContainer && tabContainer.numElements ? tabContainer.getElementAt(0) : null;
			var isPreview:Boolean;
			
			isPreview = DictionaryUtils.containsValue(documentsPreviewDictionary, tabContent);
			
			//if (!isDocument) {
			//	isDocument = DictionaryUtils.containsValue(documentsPreviewDictionary, tabContainer);
			//}
			
			return isPreview;
		}
		
		/**
		 * Opens the document. If the document is already open it selects it. 
		 * When the document loads (it's a blank application swf) then the mxml is parsed. Check the DocumentContainer class.  
		 * 
		 * It returns the document container. 
		 * */
		public static function openDocument(iDocument:IDocument, locations:String = null, showDocumentInTab:Boolean = true, dispatchEvents:Boolean = true):IDocument {
			var documentContainer:DocumentContainer;
			var navigatorContent:NavigatorContent;
			var openingEventDispatched:Boolean;
			var containerTypeInstance:Object;
			var isAlreadyOpen:Boolean;
			var container:Object;
			var documentIndex:int;
			var previewName:String;
			var index:int;
			
			if (iDocument==null || documentsTabNavigator==null) {
				error("No document to open");
				return null;
			}
			
			// NOTE: If the document is empty or all of the components are in the upper left hand corner
			// and they have no properties then my guess is that the application was never fully loaded 
			// or activated. this happens with multiple documents opening too quickly where some 
			// do not seem to activate. you see them activate when you select their tab for the first time
			// so then later if it hasn't activated, when the document is exported none of the components have
			// their properties or styles set possibly because Flex chose to defer applying them.
			// the solution is to make sure the application is fully loaded and activated
			// and also store a backup of the document MXML. 
			// that could mean waiting to open new documents until existing documents have 
			// loaded. listen for the application complete event (or create a parse and import event) 
			// ...haven't had time to do any of this yet
			// UPDATE OCT 4, 2015 - try calling activate() on the application - see Radii8Desktop.mxml menu item
			
			isAlreadyOpen = isDocumentOpen(iDocument);
			
			if (dispatchEvents) {
				openingEventDispatched = Radiate.dispatchDocumentOpeningEvent(iDocument);
				
				if (!openingEventDispatched) {
					//return false;
				}
			}
			
			if (isAlreadyOpen) {
				index = getDocumentTabIndex(iDocument);
				
				if (showDocumentInTab) {
					//showDocument(iDocument, false, false); // the next call will dispatch events
					showDocument(iDocument, false, dispatchEvents); // the next call will dispatch events
					selectDocument(iDocument, dispatchEvents);
				}
				return iDocument;
			}
			else {
				iDocument.open(locations);
			}
			
			// TypeError: Error #1034: Type Coercion failed: cannot convert 
			// com.flexcapacitor.components::DocumentContainer@114065851 to 
			// mx.core.INavigatorContent
			navigatorContent = new NavigatorContent();
			navigatorContent.percentWidth = 100;
			navigatorContent.percentHeight = 100;
			
			navigatorContent.label = iDocument.name ? iDocument.name : "Untitled";
			
			
			if (iDocument.containerType==null) {
				documentContainer = new DocumentContainer();
				documentContainer.percentWidth = 100;
				documentContainer.percentHeight = 100;
				
				documentsContainerDictionary[iDocument] = documentContainer;
				navigatorContent.addElement(documentContainer);
				documentContainer.iDocument = IDocument(iDocument);
			}
			else {
				// custom container
				containerTypeInstance = new iDocument.containerType();
				//containerTypeInstance.id = document.name ? document.name : "";
				containerTypeInstance.percentWidth = 100;
				containerTypeInstance.percentHeight = 100;
				
				documentsContainerDictionary[iDocument] = containerTypeInstance;
				navigatorContent.addElement(containerTypeInstance as IVisualElement);
				containerTypeInstance.iDocument = IDocument(iDocument);
			}
			
			if (documentsTabNavigator) {
				//documentIndex = !isPreview ? 0 : getDocumentIndex(document) + 1;
				documentsTabNavigator.addElement(navigatorContent);
			}
			documentIndex = getDocumentTabIndex(iDocument);
			
			// show document
			if (showDocumentInTab) {
				showDocument(iDocument, false, dispatchEvents);
				selectDocument(iDocument, dispatchEvents);
			}
			
			return iDocument;
		}
		
		/**
		 * Opens a preview of the document. If the document is already open it selects it. 
		 * 
		 * It returns the document container. 
		 * */
		public static function openDocumentPreview(iDocument:IDocument, showDocument:Boolean = false, dispatchEvents:Boolean = true):Object {
			var documentContainer:DocumentContainer;
			var navigatorContent:NavigatorContent;
			var isAlreadyOpen:Boolean;
			var index:int;
			var iframe:IFrame;
			var html:UIComponent;
			var containerTypeInstance:Object;
			var container:Object;
			var openingEventDispatched:Boolean;
			var documentIndex:int;
			var previewName:String;
			var elementId:String;
			var popUpOverlayManager:PopUpOverlayManager;
			var htmlClass:Object;
			
			isAlreadyOpen = isDocumentPreviewOpen(iDocument);
			
			if (dispatchEvents) {
				openingEventDispatched = Radiate.dispatchDocumentOpeningEvent(iDocument, true);
				if (!openingEventDispatched) {
					//return false;
				}
			}
			
			if (isAlreadyOpen) {
				index = getDocumentPreviewIndex(iDocument);
				
				if (showDocument) {
					showDocumentAtNavigatorIndex(index, false); // the next call will dispatch events
					selectDocument(iDocument, dispatchEvents);
				}
				return documentsPreviewDictionary[iDocument];
			}
			else {
				iDocument.isPreviewOpen = true;
			}
			
			// TypeError: Error #1034: Type Coercion failed: cannot convert 
			// com.flexcapacitor.components::DocumentContainer@114065851 to 
			// mx.core.INavigatorContent
			navigatorContent = new NavigatorContent();
			navigatorContent.percentWidth = 100;
			navigatorContent.percentHeight = 100;
			
			navigatorContent.label = iDocument.name ? iDocument.name : "Untitled";
			
			previewName = iDocument.name + " HTML";
			navigatorContent.label = previewName;
			
			// should we be setting id like this?
			elementId = iDocument.name ? iDocument.name : NameUtil.createUniqueName(iDocument);
			elementId = elementId.replace(/ /g, "");
			
			if (iDocument.containerType) {
				containerTypeInstance = new iDocument.containerType();
				containerTypeInstance.id = elementId;
				containerTypeInstance.percentWidth = 100;
				containerTypeInstance.percentHeight = 100;
				
				navigatorContent.addElement(containerTypeInstance as IVisualElement);
				documentsPreviewDictionary[iDocument] = containerTypeInstance;
			}
			else if (Radiate.isDesktop) {
				
				// we should add an option to use stage web instead of 
				// internal webkit browser
				
				// show HTML page
				htmlClass = ApplicationDomain.currentDomain.getDefinition(Radiate.desktopHTMLClassName);
				html = new htmlClass();
				//html.id = elementId;
				html.percentWidth = 100;
				html.percentHeight = 100;
				html.top = -10; // get rid of spacing navigator adds
				html.left = 0;
				//html.setStyle("backgroundColor", "#666666");
				
				// not sure how to get the parsing errors 
				html.addEventListener("uncaughtScriptException", uncaughtScriptExceptionHandler, false, 0, true);//HTMLUncaughtScriptExceptionEvent.uncaughtScriptException
				html.addEventListener("uncaughtException", uncaughtScriptExceptionHandler, false, 0, true);//HTMLUncaughtScriptExceptionEvent.uncaughtScriptException
				html.addEventListener("scriptException", uncaughtScriptExceptionHandler, false, 0, true);//HTMLUncaughtScriptExceptionEvent.uncaughtScriptException
				html.addEventListener("htmlError", uncaughtScriptExceptionHandler, false, 0, true);//HTMLUncaughtScriptExceptionEvent.uncaughtScriptException
				html.addEventListener("error", uncaughtScriptExceptionHandler, false, 0, true);//HTMLUncaughtScriptExceptionEvent.uncaughtScriptException
				
				navigatorContent.addElement(html);
				documentsPreviewDictionary[iDocument] = html;
			}
			else {
				// show HTML page
				iframe = new IFrame();
				iframe.id = NameUtil.createUniqueName(iframe);
				iframe.percentWidth = 100;
				iframe.percentHeight = 100;
				iframe.top = -10;
				iframe.left = 0;
				iframe.setStyle("backgroundColor", "#666666");
				
				popUpOverlayManager = PopUpOverlayManager.getInstance();
				popUpOverlayManager.addOverlay(iframe);
				
				navigatorContent.addElement(iframe);
				documentsPreviewDictionary[iDocument] = iframe;
			}
			
			
			// if preview add after original document location
			documentIndex = getDocumentTabIndex(iDocument) + 1; // add after
			documentsTabNavigator.addElementAt(navigatorContent, documentIndex);
			
			// show document
			if (showDocument) {
				showDocumentAtNavigatorIndex(documentIndex, dispatchEvents);
				selectDocument(iDocument, dispatchEvents);
			}
			
			return documentsPreviewDictionary[iDocument];
		}
		
		/**
		 * Checks if a document preview is open.
		 * @see isDocumentSelected
		 * */
		public static function isDocumentPreviewOpen(document:IDocument):Boolean {
			var openTabs:Array = documentsTabNavigator && documentsTabNavigator.getChildren() ? documentsTabNavigator.getChildren() : [];
			var tabCount:int = openTabs.length;
			var tab:NavigatorContent;
			var tabContent:Object;
			
			if (tabCount==0) {
				return false;
			}
			
			var documentContainer:Object = documentsPreviewDictionary[document];
			
			for (var i:int;i<tabCount;i++) {
				tab = NavigatorContent(documentsTabNavigator.getChildAt(i));
				tabContent = tab.numElements ? tab.getElementAt(0) : null;
				
				if (tabContent && tabContent==documentContainer) {
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Checks if document is open.
		 * @see isDocumentSelected
		 * */
		public static function isDocumentOpen(iDocument:IDocument, isPreview:Boolean = false):Boolean {
			var openTabs:Array;
			var tabCount:int;
			var tab:NavigatorContent;
			var tabContent:Object;
			var documentContainer:Object;
			
			if (!documentsTabNavigator) {
				return false;
			}
			
			openTabs = documentsTabNavigator.getChildren();
			tabCount = openTabs.length;
			documentContainer = isPreview ? documentsPreviewDictionary[iDocument] : documentsContainerDictionary[iDocument];
			
			for (var i:int;i<tabCount;i++) {
				tab = NavigatorContent(documentsTabNavigator.getChildAt(i));
				tabContent = tab.numElements ? tab.getElementAt(0) : null;
				
				if (tabContent && tabContent==documentContainer) {
					return true;
				}
			}
			
			return false;
			
		}
		
		/**
		 * Closes the current visible document regardless if it is a preview or not. 
		 * @see isDocumentSelected
		 * */
		public static function closeVisibleDocument():Boolean {
			
			var selectedDocument:IDocument = getDocumentAtNavigatorIndex(documentsTabNavigator.selectedIndex);
			var isPreview:Boolean = isPreviewDocumentVisible();
			
			return closeDocument(selectedDocument, isPreview, true);
			
		}
		
		/**
		 * Closes document if open.
		 * @see isDocumentSelected
		 * */
		public static function closeDocument(iDocument:IDocument, isPreview:Boolean = false, selectOtherDocument:Boolean = false):Boolean {
			if (iDocument==null || documentsTabNavigator==null) {
				error("No document to close");
				return false;
			}
			
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var navigatorContent:NavigatorContent;
			var navigatorContentDocumentContainer:Object;
			var documentContainer:Object;
			var wasDocumentClosed:Boolean;
			var wasPreviewClosed:Boolean;
			var index:int;
			var isIFrame:Boolean;
			
			documentContainer = isPreview ? documentsPreviewDictionary[iDocument] : documentsContainerDictionary[iDocument];
			
			if (documentContainer is IFrame) {
				PopUpOverlayManager.instance.removeOverlay(documentContainer as DisplayObject);
			}
			
			if (documentContainer && documentContainer.owner) {
				// ArgumentError: Error #2025: The supplied DisplayObject must be a child of the caller.
				// 	at flash.display::DisplayObjectContainer/getChildIndex()
				//var index:int = documentsTabNavigator.getChildIndex(documentContainer.owner as DisplayObject);
				var contains:Boolean = documentsTabNavigator.contains(documentContainer.owner as DisplayObject);
				
				if (contains) {
					index = documentsTabNavigator.getChildIndex(documentContainer.owner);
					documentsTabNavigator.removeChild(documentContainer.owner);
					
					// close previews when the main document is closed
					if (!isPreview) {
						documentContainer = documentsPreviewDictionary[iDocument];
						
						if (documentContainer) {
							wasPreviewClosed = true;
							documentsTabNavigator.removeChild(documentContainer.owner);
						}
						
						iDocument.close();
						//removeDocument(iDocument);
						
						//var documentContainer:Object = isPreview ? documentsPreviewDictionary[iDocument] : documentsDictionary[iDocument];
						
						delete documentsContainerDictionary[iDocument];
						delete documentsPreviewDictionary[iDocument];
						wasDocumentClosed = true;
					}
					else {
						delete documentsPreviewDictionary[iDocument];
						wasPreviewClosed = true;
					}
					
					if (isPreview) {
						// TODO we must remove HTML from IFrame (inline css from previous iframes previews affects current preview)
					}
					else {
						selectDocument(null);
					}
					
					documentsTabNavigator.validateNow();
					
					Radiate.dispatchDocumentCloseEvent(iDocument, wasDocumentClosed, wasPreviewClosed);
				}
			}
			
			var otherDocument:IDocument;
			
			if (selectOtherDocument && wasDocumentClosed && tabCount>1) {
				otherDocument = getVisibleDocument();
				openTabs = documentsTabNavigator.getChildren();
				tabCount = openTabs.length;
				
				if (otherDocument==null) {
					//index = index==0 ? 1 : index-1;
					isPreviewDocumentVisible()
					otherDocument = documents && documents.length ? documents[0] : null;
				}
				if (otherDocument) {
					selectDocument(otherDocument);
					showDocument(otherDocument);
				}
			}
			else {
				openTabs = documentsTabNavigator.getChildren();
				tabCount = openTabs.length;
				
				if (tabCount==0) {
					Radiate.setTarget(null);
				}
			}
			
			return true;
			
			// first attempt
			//info("Closing " + iDocument.name);
			for (var i:int;i<tabCount;i++) {
				navigatorContent = NavigatorContent(documentsTabNavigator.getChildAt(i));
				navigatorContentDocumentContainer = navigatorContent.numElements ? navigatorContent.getElementAt(0) : null;
				//info(" Checking tab " + tab.label);
				
				if (iDocument.name==navigatorContent.label) {
					//info(" Name Match " + iDocument.name);
					if (IDocumentContainer(navigatorContentDocumentContainer).iDocument==iDocument) {
						documentsTabNavigator.removeChild(navigatorContent);
						documentsTabNavigator.validateNow();
						
						return true;
					}
				}
				
				
				// oddly enough after we remove one child using the code below (note: see update)
				// the documentContainer in the documentsDictionary is no longer 
				// connected with the correct document data 
				// if we do this one at a time and remove one per second 
				// then it works but not many documents at a time (see removeProject)
				// so instead we are checking by name and then document reference 
				// in the code above this
				
				// Update: May have spoken too soon - could be problem because document 
				// was used as a variable name and it scoped to document on the UIComponent class :(
				
				if (navigatorContentDocumentContainer && navigatorContentDocumentContainer==documentContainer) {
					documentsTabNavigator.removeChild(navigatorContent);
					documentsTabNavigator.validateNow();
					return true;
				}
			}
			
			return false;
			
		}
		
		/**
		 * Checks if document is open and selected
		 * */
		public static function isDocumentSelected(document:Object, isPreview:Boolean = false):Boolean {
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var tab:NavigatorContent;
			var tabContent:Object;
			var documentIndex:int = -1;
			var documentContainer:Object = isPreview ? documentsPreviewDictionary[document] : documentsContainerDictionary[document];
			
			for (var i:int;i<tabCount;i++) {
				tab = NavigatorContent(documentsTabNavigator.getChildAt(i));
				tabContent = tab.numElements ? tab.getElementAt(0) : null;
				
				if (tabContent && tabContent==documentContainer) {
					documentIndex = i;
					break;
				}
			}
			
			
			if (documentsTabNavigator.selectedIndex==documentIndex) {
				return true;
			}
			
			return false;
			
		}
		
		/**
		 * Get visible document in documents tab navigator
		 * */
		public static function getVisibleDocument():IDocument {
			var selectedTab:NavigatorContent = documentsTabNavigator ? documentsTabNavigator.selectedChild as NavigatorContent : null;
			var tabContent:Object = selectedTab && selectedTab.numElements ? selectedTab.getElementAt(0) : null;
			
			if (tabContent is IDocumentContainer) {
				var iDocument:IDocument = IDocumentContainer(tabContent).iDocument;
				return iDocument;
			}
			
			
			var selectedDocument:IDocument = getDocumentAtNavigatorIndex(documentsTabNavigator.selectedIndex);
			var isPreview:Boolean = isPreviewDocumentVisible();
			
			return selectedDocument;
		}
		
		/**
		 * Get the index of the document in documents tab navigator
		 * 
		 * */
		public static function getDocumentTabIndex(document:Object, isPreview:Boolean = false):int {
			//TypeError: Error #1009: Cannot access a property or method of a null object reference.
			//	at com.flexcapacitor.controller::Radiate/getDocumentTabIndex()[/Users/monkeypunch/Documents/ProjectsGithub/Radii8/Radii8Library/src/com/flexcapacitor/controller/Radiate.as:5649]
			if (documentsTabNavigator==null) {
				info("Documents tab navigator is not created yet so for now you must open the document manually. Close and then open the document.");
				if (document && document is IDocument) {
					closeDocument(IDocument(document));
				}
				return -1;
			}
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var tab:NavigatorContent;
			var documentContainer:Object = isPreview ? documentsPreviewDictionary[document] : documentsContainerDictionary[document];
			var tabContent:Object;
			
			for (var i:int;i<tabCount;i++) {
				tab = NavigatorContent(documentsTabNavigator.getChildAt(i));
				tabContent = tab.numElements ? tab.getElementAt(0) : null;
				
				if (tabContent && tabContent==documentContainer) {
					return i;
				}
			}
			
			return -1;
		}
		
		/**
		 * Get the index of the document preview in documents tab navigator
		 * */
		public static function getDocumentPreviewIndex(document:Object):int {
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var tab:NavigatorContent;
			var documentContainer:Object = documentsPreviewDictionary[document];
			var tabContent:Object;
			
			for (var i:int;i<tabCount;i++) {
				tab = NavigatorContent(documentsTabNavigator.getChildAt(i));
				tabContent = tab.numElements ? tab.getElementAt(0) : null;
				
				if (tabContent && tabContent==documentContainer) {
					return i;
				}
			}
			
			return -1;
		}
		
		/**
		 * Get the document for the given application
		 * */
		public static function getDocumentForApplication(application:Application):IDocument {
			var document:IDocument;
			
			for each (document in documentsContainerDictionary) {
				if (document.instance === application) {
					return document;
					break;
				}
			}
			return null;
		}
		
		/**
		 * Gets the document container for the document preview. 
		 * For example, a document can be previewed as an HTML page. 
		 * If we want to get the document that is previewing HTML then 
		 * we need to get the container of the preview.
		 * */
		public static function getDocumentPreview(document:Object):Object {
			var documentContainer:Object = documentsPreviewDictionary[document];
			return documentContainer;
		}
		
		/**
		 * Creates a blank document and creates a new project if not supplied.
		 * 
		 * @param project if string then creates a new project. if an IProject then does not create a new project.
		 * */
		public static function createBlankDemoDocument(project:Object = null, documentName:String = null, type:Class = null, open:Boolean = true, dispatchEvents:Boolean = false, select:Boolean = true):IDocument {
			var newProject:IProject;
			var newDocument:IDocument;
			
			if (project is String || project==null) {
				newProject = ProjectManager.createProject(project as String); // create project
				ProjectManager.addProject(newProject, false);       // add to projects array - shows up in application
			}
			else if (project is IProject) {
				newProject = project as IProject;
			}
			
			newDocument = DocumentManager.createDocument(documentName); // create document
			DocumentManager.addDocument(newDocument, newProject); // add to project and documents array - shows up in application
			
			ProjectManager.openProject(newProject, DocumentData.INTERNAL_LOCATION); // should open documents - maybe we should do all previous steps in this function???
			openDocument(newDocument, DocumentData.INTERNAL_LOCATION, true, true); // add to application and parse source code if any
			
			Radiate.setProject(newProject, true); // selects project 
			
			return newDocument;
		}
		
		/**
		 * Creates a document
		 * */
		public static function createDocument(name:String = null, Type:Object = null, project:IProject = null):IDocument {
			var hasDefinition:Boolean;
			var DocumentType:Object;
			var iDocument:IDocument;
			
			if (Type is String && Type!="null" && Type!="") {
				hasDefinition = ClassUtils.hasDefinition(String(Type));
				DocumentType = Document;
				
				if (hasDefinition) {
					DocumentType = ClassUtils.getDefinition(String(Type));
					iDocument = new DocumentType();
				}
				else {
					throw new Error("Type specified, '" + String(Type) + "' to create document is not found");
				}
			}
			else if (Type is Class) {
				iDocument = new Type();
			}
			else {
				iDocument = new Document();
			}
			
			iDocument.name = name ? name : "Document";
			iDocument.host = Radiate.getWPURL();
			//document.documentData = document.marshall();
			return iDocument;
		}
		
		/**
		 * Adds a document to a project if set and adds it to the documents array
		 * */
		public static function addDocument(iDocument:IDocument, project:IProject = null, overwrite:Boolean = false, dispatchEvents:Boolean = true):IDocument {
			var documentAlreadyExists:Boolean;
			var documentAdded:Boolean;
			var documentToRemove:IDocument;
			
			documentAlreadyExists = doesDocumentExist(iDocument.uid);
			
			// if not added already add to documents array
			if (!documentAlreadyExists) {
				documents.push(iDocument);
				documentAdded = true;
			}
			
			if (documentAlreadyExists && overwrite) {
				// check dates
				// remove from documents
				// remove from projects
				// add to documents
				// add to projects
				documentToRemove = getDocumentByUID(iDocument.uid);
				removeDocument(documentToRemove, DocumentData.LOCAL_LOCATION);// this is deleting the document
				// should there be a remove (internally) and delete method?
				
				//throw new Error("Document overwrite is not implemented yet");
				documentAdded = true;
			}
			
			if (project) {
				project.addDocument(iDocument, overwrite);
			}
			
			if (documentAdded && dispatchEvents) {
				Radiate.dispatchDocumentAddedEvent(iDocument);
			}
			
			return iDocument;
		}
		
		/**
		 * Reverts a document to its open state
		 * */
		public static function revertDocument(iDocument:IDocument, dispatchEvents:Boolean = true):Boolean {
			if (iDocument==null) {
				error("No document to revert");
				return false;
			}
			
			if ("revert" in iDocument) {
				Object(iDocument).revert();
				Radiate.dispatchDocumentRevertedEvent(iDocument);
				return true;
			}
			
			return false;
		}
		
		/**
		 * Removes a document from the documents array
		 * */
		public static function removeDocument(iDocument:IDocument, locations:String = null, dispatchEvents:Boolean = true, saveProjectAfter:Boolean = true):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var parentProject:IProject = iDocument.project;
			var documentsIndex:int = parentProject.documents.indexOf(iDocument);
			var removedDocument:IDocument;
			var remote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			
			deleteDocumentProjectId = parentProject && parentProject.id!=null ? int(parentProject.id) : -1;
			saveProjectAfterDelete = saveProjectAfter;
			
			if (documentsIndex!=-1) {
				// add remove document to project
				var removedDocuments:Array = parentProject.documents.splice(documentsIndex, 1);
				
				if (removedDocuments[0]==iDocument) {
					//info("Document removed successfully");
				}
			}
			
			closeDocument(iDocument);
			// check if document is open in tab navigator
			/*if (isDocumentOpen(iDocument)) {
			var closed:Boolean = closeDocument(iDocument);
			info("Closed " + iDocument.name);
			}*/
			
			if (remote && iDocument && iDocument.id) { 
				// we need to create service
				if (deleteDocumentService==null) {
					deleteDocumentService = new WPService();
					deleteDocumentService.addEventListener(WPService.RESULT, deleteDocumentResultsHandler, false, 0, true);
					deleteDocumentService.addEventListener(WPService.FAULT, deleteDocumentFaultHandler, false, 0, true);
				}
				
				deleteDocumentService.host = Radiate.getWPURL();
				
				deleteDocumentInProgress = true;
				
				deleteDocumentService.id = iDocument.id
				deleteDocumentService.deletePost();
			}
			else if (remote) { // document not saved yet
				
				if (dispatchEvents) {
					Radiate.dispatchDocumentRemovedEvent(iDocument);
					
					if (deleteDocumentProjectId!=-1 && saveProjectAfter) {
						parentProject.saveOnlyProject(locations);
					}
					
					Radiate.setTarget(null);
					return true;
				}
			}
			else {
				
				if (dispatchEvents) {
					Radiate.dispatchDocumentRemovedEvent(iDocument);
				}
				
			}
			
			// get first or last open document and select the project it's part of
			if (!selectedDocument) {
				
			}
			
			Radiate.setTarget(null);
			
			return true;
		}
		
		/**
		 * Opens the document from it's document data. If the document is already open it selects it. 
		 * 
		 * It returns the document container. 
		 * */
		public static function openDocumentByData(data:IDocumentData, createIfNotFound:Boolean, showDocument:Boolean = true, dispatchEvents:Boolean = true):IDocument {
			var iDocument:IDocument = getDocumentByUID(data.uid);
			
			if (!iDocument && createIfNotFound) {
				iDocument = createDocumentFromData(data);
			}
			
			var newDocument:IDocument = openDocument(iDocument, DocumentData.INTERNAL_LOCATION, showDocument, dispatchEvents);
			
			return newDocument;
		}
		
		/**
		 * Duplicates the document 
		 * 
		 * It returns the document container. 
		 * */
		public static function duplicateDocument(iDocument:IDocument, showDocument:Boolean = true, dispatchEvents:Boolean = true):IDocument {
			var newDocument:IDocument;
			
			if (iDocument) {
				newDocument = createDocumentFromData(iDocument);
				removeUniqueDocumentData(newDocument);
			}
			else {
				error("No document to duplicate");
				return null;
			}
			
			newDocument = openDocument(newDocument, DocumentData.INTERNAL_LOCATION, showDocument, dispatchEvents);
			
			return newDocument;
		}
		
		/**
		 * Removes unique document data such as remote ID and UID. 
		 * Used for duplicating documents and importing example projects
		 * */
		public static function removeUniqueDocumentData(iDocument:Object):void {
			if (iDocument is IDocumentData) {
				IDocument(iDocument).id = null;
				IDocument(iDocument).uid = null;
			}
		}
		
		/**
		 * Create document from document data
		 * */
		public static function createDocumentDataFromMetaData(documentData:IDocumentMetaData, overwrite:Boolean = false):IDocumentData {
			var newDocument:IDocumentData = new DocumentData();
			newDocument.unmarshall(documentData);
			
			return newDocument;
		}
		
		/**
		 * Create document from document data
		 * */
		public static function createDocumentFromData(documentData:IDocumentData, overwrite:Boolean = false):IDocument {
			var newDocument:IDocument = createDocument(documentData.name, documentData.type);
			newDocument.unmarshall(documentData);
			
			return newDocument;
		}
		
		/**
		 * Create document from document meta data
		 * */
		public static function createDocumentFromMetaData(documentMetaData:IDocumentMetaData, overwrite:Boolean = false):IDocument {
			var documentData:IDocumentData = createDocumentDataFromMetaData(documentMetaData, overwrite);
			var iDocument:IDocument = createDocumentFromData(documentData, overwrite);
			
			return iDocument;
		}
		
		/**
		 * Get document container for document
		 **/
		public static function getDocumentContainer(value:IDocument):IDocumentContainer {
			return documentsContainerDictionary[value] as IDocumentContainer;
		}
		
		/**
		 * Handles uncaught errors from an HTML preview document
		 * */
		protected static function uncaughtScriptExceptionHandler(event:*):void {
			//var target:Object = event.currentTarget;
			var exceptionValue:Object = event.exceptionValue;
			
			error("Line " + exceptionValue.line + "  " + exceptionValue.name + ": " + exceptionValue.message);
		}
		
		/**
		 *  Animation to scrollbars clicked area into view
		 */
		public static var scrollBarAnimation:Animate;
		public static var scrollBarAnimationDuration:int = 250;
		public static var scrollBarAnimationStartDelay:int = 0;
		
		/**
		 * Center the view on the specified point
		 **/
		public static function centerViewOnPoint(scroller:Scroller, point:Point, animate:Boolean = false):Point {
			
			if (!point) {
				return null;
			}
			
			var viewport:GroupBase = scroller.viewport as GroupBase;
			var scrollRectangle:Rectangle = getScrollRectangle(viewport);
			
			if (!scrollRectangle || !viewport.clipAndEnableScrolling) {
				return null;
			}
			
			var newX:Number = 0;
			var newY:Number = 0;
			
			var left:Number;
			var top:Number;
			var horizontalCenter:Number;
			var verticalCenter:Number;
			var maxVerticalScrollPosition:int;
			var maxHorizontalScrollPosition:int;
			var currentHorizontalPosition:int;
			var currentVerticalPosition:int;
			
			left = point.x;
			top = point.y;
			
			horizontalCenter = left - (scrollRectangle.width/2);
			verticalCenter = top - (scrollRectangle.height/2);
			
			currentHorizontalPosition = viewport.horizontalScrollPosition;
			currentVerticalPosition = viewport.verticalScrollPosition;
			
			maxHorizontalScrollPosition = scroller.horizontalScrollBar.maximum;
			maxVerticalScrollPosition = scroller.verticalScrollBar.maximum;
			
			newX = horizontalCenter;
			
			if (horizontalCenter<0) {
				newX = 0;
			}
			else if (horizontalCenter > maxHorizontalScrollPosition) {
				newX = maxHorizontalScrollPosition;
			}
			
			newY = verticalCenter;
			
			if (verticalCenter<0) {
				newY = 0;
			}
			else if (verticalCenter > maxVerticalScrollPosition) {
				newY = maxVerticalScrollPosition;
			}
			
			newX = Math.floor(newX);
			newY = Math.floor(newY);
			
			if (!animate) {
				scroller.viewport.horizontalScrollPosition = newX;
				scroller.viewport.verticalScrollPosition = newY;
			}
			else {
				animateScrollPointIntoView(new Point(newX, newY), new Point(currentHorizontalPosition, currentVerticalPosition));
			}
			
			return new Point(newX, newY);
			
		}
		
		/**
		 *  Returns the bounds of the target's scroll rectangle in layout coordinates.
		 * 
		 *  @return The bounds of the target's scrollRect in layout coordinates, null
		 *      if target or clipAndEnableScrolling is false. 
		 */
		public static function getScrollRectangle(target:GroupBase):Rectangle {
			var g:GroupBase = target;
			if (!g || !g.clipAndEnableScrolling)
				return null;
			var hsp:Number = g.horizontalScrollPosition;
			var vsp:Number = g.verticalScrollPosition;
			return new Rectangle(hsp, vsp, g.width, g.height);
		}
		
		/**
		 *  Returns the x and y of the target's scroll rectangle in layout coordinates.
		 * 
		 *  @return The bounds of the target's scrollRect in layout coordinates, null
		 *      if target or clipAndEnableScrolling is false. 
		 */
		public static function getScrollPoint(target:GroupBase):Point {
			var g:GroupBase = target;
			if (!g || !g.clipAndEnableScrolling)
				return null;
			var hsp:Number = g.horizontalScrollPosition;
			var vsp:Number = g.verticalScrollPosition;
			return new Point(hsp, vsp);
		}
		
		/**
		 *  Returns the max scroll bar position of the target's scroll rectangle in layout coordinates.
		 */
		public static function getMaxScrollPoint():Point {
			if (!canvasScroller) return null;
			canvasScroller.verticalScrollBar && canvasScroller.horizontalScrollBar;
			var point:Point = new Point();
			point.x = canvasScroller.verticalScrollBar.maximum;
			point.y = canvasScroller.horizontalScrollBar.maximum;
			return point;
		}
		
		/**
		 * Returns true if both horizontal and vertical scrollbars exist on document
		 **/
		public static function hasScrollBars():Boolean {
			if (!canvasScroller) return false;
			return canvasScroller.verticalScrollBar && canvasScroller.horizontalScrollBar;
		}
		
		/**
		 * Returns true if horizontal scrollbars exist on document
		 **/
		public static function hasHorizontalScrollBar():Boolean {
			if (!canvasScroller) return false;
			return canvasScroller.horizontalScrollBar!=null;
		}
		
		/**
		 * Returns true if vertical scrollbars exist on document
		 **/
		public static function hasVerticalScrollBar():Boolean {
			if (!canvasScroller) return false;
			return canvasScroller.verticalScrollBar!=null;
		}
		
		/**
		 * Returns true if document has at least one scrollbar
		 * Zoom class has these methods
		 **/
		public static function hasScrollBar():Boolean {
			if (!canvasScroller) return false;
			return canvasScroller.verticalScrollBar || canvasScroller.horizontalScrollBar;
		}
		
		/**
		 * Returns point that can be used to locate the current center of the viewport
		 * With this point you could call centerOnPoint and the view should not move
		 **/
		public static function getCurrentScrollPoint(iDocument:IDocument):Point {
			var scroller:Scroller = getDocumentScroller(iDocument);
			if (!scroller) return null;
			var point:Point = new Point();
			
			var applicationPoint:Point = DisplayObjectUtils.getDistanceBetweenDisplayObjects(iDocument.instance, scroller);
			
			var viewport:GroupBase = scroller.viewport as GroupBase;
			var scrollRectangle:Rectangle = getScrollRectangle(viewport);
			var scale:Number = iDocument.scale;
			var offsetWidth:Number = (iDocument.instance.width - iDocument.instance.width*scale)/2;
			var offsetHeight:Number = (iDocument.instance.height - iDocument.instance.height*scale)/2;
			var xOffset:Number = Math.max(applicationPoint.x, 0);
			var yOffset:Number = Math.max(applicationPoint.y, 0);
			
			point.x = scrollRectangle.x - xOffset + offsetWidth + scrollRectangle.width/2;
			point.y = scrollRectangle.y - yOffset + offsetHeight + scrollRectangle.height/2;
			
			//trace("X:" + point.x + " Y:" + point.y);
			// this seems to drift very quickly 
			
			return point;
		}
		
		/**
		 * Get the scroller for the document
		 **/
		public static function getDocumentScroller(iDocument:IDocument):Scroller {
			var documentContainer:IDocumentContainer = getDocumentContainer(iDocument);
			var scroller:Scroller = documentContainer ? documentContainer.canvasScroller : null;
			
			return scroller;
		}
		
		/**
		 * Get the tool layer for the document
		 **/
		public static function getDocumentToolLayer(iDocument:IDocument):IVisualElementContainer {
			var documentContainer:IDocumentContainer = getDocumentContainer(iDocument);
			var layer:IVisualElementContainer = documentContainer ? documentContainer.toolLayer : null;
			
			return layer;
		}
		
		/**
		 * Animate a scroll position into view 
		 **/
		public static function animateScrollPointIntoView(newPoint:Point, oldPoint:Point = null):void {
			var scrollMotionPaths:Vector.<MotionPath>;
			var scrollHorizontalPath:SimpleMotionPath;
			var scrollVerticalPath:SimpleMotionPath;
			
			scrollBarAnimation = new Animate();
			//scrollBarAnimation.addEventListener(EffectEvent.EFFECT_END, hideScrollBarAnimation_effectEndHandler);
			scrollBarAnimation.duration = scrollBarAnimationDuration;
			scrollBarAnimation.startDelay = scrollBarAnimationStartDelay;
			
			if (oldPoint) {
				scrollHorizontalPath = new SimpleMotionPath(MXMLDocumentConstants.HORIZONTAL_SCROLL_POSITION, oldPoint.x, newPoint.x);
				scrollVerticalPath = new SimpleMotionPath(MXMLDocumentConstants.VERTICAL_SCROLL_POSITION, oldPoint.y, newPoint.y);
			}
			else {
				scrollHorizontalPath = new SimpleMotionPath(MXMLDocumentConstants.HORIZONTAL_SCROLL_POSITION, null, newPoint.x);
				scrollVerticalPath = new SimpleMotionPath(MXMLDocumentConstants.VERTICAL_SCROLL_POSITION, null, newPoint.y);
			}
			
			scrollMotionPaths = Vector.<MotionPath>([scrollHorizontalPath, scrollVerticalPath]);
			scrollBarAnimation.motionPaths = scrollMotionPaths;
			scrollBarAnimation.play([canvasScroller.viewport]);
		}
		
		
		
		//----------------------------------
		//  instance
		//----------------------------------
		
		public static function get instance():DocumentManager
		{
			if (!_instance) {
				_instance = new DocumentManager(new SINGLEDOUBLE());
			}
			return _instance;
		}
		
		public static function getInstance():DocumentManager {
			return instance;
		}
		
		private static var _instance:DocumentManager;
	}
}

class SINGLEDOUBLE{}