package com.flexcapacitor.managers {
	
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.effects.popup.OpenPopUp;
	import com.flexcapacitor.model.DocumentData;
	import com.flexcapacitor.model.HTMLExportOptions;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.ImageData;
	import com.flexcapacitor.model.MetaData;
	import com.flexcapacitor.model.SourceData;
	import com.flexcapacitor.services.WPService;
	import com.flexcapacitor.utils.ClassUtils;
	import com.flexcapacitor.views.ImageView;
	import com.google.code.flexiframe.IFrame;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.BitmapData;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.core.UIComponent;
	import mx.validators.IValidator;

	
	/**
	 * Helper class to run common commands
	 * */
	public class RunManager extends EventDispatcher {
		
		
		public function RunManager():void {
			
		}
		
		public static var openPopUp:OpenPopUp;
		
		public static var documentNotPublishedWarning:Boolean;
		
		/**
		 * Opens the home page in the browser. If home page is not set then 
		 * opens the home page. Shows a message if home page is not set
		 * */
		public static function openHomePageInBrowserButton():void {
			
			if (Radiate.instance.projectHomePageID<1) {
				Radiate.warn("A home page has not been set. Showing the default theme home page");
				Radiate.callAfter(2500, Radiate.openUsersWebsite);
			}
			else {
				Radiate.openUsersWebsite();
			}
		}
		
		/**
		 * Opens the document in a browser window
		 * */
		public static function openDocumentInBrowser(windowName:String=null):void {
			var iDocument:IDocument = Radiate.instance.selectedDocument;
			
			if (iDocument) {
				
				if (iDocument.status!=WPService.STATUS_PUBLISH) {
					if (documentNotPublishedWarning) {
						Radiate.openInBrowser(iDocument, windowName);
					}
					else {
						documentNotPublishedWarning = true;
						Radiate.warn("The document is not published. Publish and save first or login into your browser to see it.");
						Radiate.callAfter(2500, Radiate.openInBrowser, iDocument, windowName);
					}
				}
				else {
					Radiate.openInBrowser(iDocument);
				}
			}
		}
		
		/**
		 * Opens the document in a browser screenshot website
		 * */
		public static function openDocumentInBrowserScreenshot(windowName:String=null):void {
			var iDocument:IDocument = Radiate.instance.selectedDocument;
			
			if (iDocument) {
				
				if (iDocument.status!=WPService.STATUS_PUBLISH) {
					
					/*if (documentNotPublishedWarning) {
						Radiate.openInBrowserScreenshot(iDocument, windowName);
					}
					else {*/
						//documentNotPublishedWarning = true;
						// always warn
						Radiate.warn("The document is not published. Publish and save the document first.");
						Radiate.callAfter(2500, Radiate.openInBrowserScreenshot, iDocument, windowName);
					//}
				}
				else {
					Radiate.openInBrowserScreenshot(iDocument, windowName);
				}
			}
		}
		
		/**
		 * Opens the document in a browser site scanner website
		 * */
		public static function openDocumentInBrowserSiteScanner(windowName:String=null):void {
			var iDocument:IDocument = Radiate.instance.selectedDocument;
			
			if (iDocument) {
				
				if (iDocument.status!=WPService.STATUS_PUBLISH) {
					
					/*if (documentNotPublishedWarning) {
						Radiate.openInBrowserScreenshot(iDocument, windowName);
					}
					else {*/
						//documentNotPublishedWarning = true;
						// always warn
						Radiate.warn("The document is not published. Publish and save the document first.");
						Radiate.callAfter(2500, Radiate.openInBrowserSiteScanner, iDocument, windowName);
					//}
				}
				else {
					Radiate.openInBrowserSiteScanner(iDocument, windowName);
				}
			}
		}
		
		/**
		 * Open document or image data as an image in a popup
		 * */
		public static function openDocumentAsImageInPopUp(documentData:DocumentData):void {
			// show full view of image
			//trace("space button pressed");
			var imageData:ImageData = documentData as ImageData;
			var bitmapData:BitmapData;
			
			if (openPopUp==null) {
				openPopUp = new OpenPopUp();
				openPopUp.modalDuration = 250;
				openPopUp.showDropShadow = true;
				openPopUp.popUpType = ImageView;
				openPopUp.autoCenter = true;
				openPopUp.percentWidth = 80;
				openPopUp.percentHeight = 80;
				openPopUp.closePreviousInstanceIfOpen = true;
				openPopUp.closeOnMouseDownOutside = true;
				openPopUp.closeOnMouseDownInside = true;
				openPopUp.fitMaxSizeToApplication = true;
				openPopUp.closeOnResize = true;
			}
			
			// image data
			if (imageData) {
				if (imageData.bitmapData) {
					openPopUp.data = imageData.bitmapData;
				}
				else if (imageData.url) {
					openPopUp.data = imageData.url;
				}
			}
			// take snapshot of document
			else if (documentData is IDocument) {
				bitmapData = Radiate.getDocumentSnapshot(IDocument(documentData));
				openPopUp.data = bitmapData;
			}
			
			if (!openPopUp.isOpen) {
				openPopUp.play();
			}
			else {
				openPopUp.close();
			}
			
		}
		
		/**
		 * Close document or image data as an image in a popup
		 * */
		public static function closeDocumentAsImageInPopUp(documentData:DocumentData):void {
			
			if (openPopUp) {
				openPopUp.close();
			}
		}
		
		/**
		 * Open HTML document inside the app
		 * */
		public static function openDocumentInInternalWeb(iDocument:IDocument):void {
			var previewDocument:Object;
			var radiate:Radiate = Radiate.getInstance();
			var sourceData:SourceData;
			var htmlOptions:HTMLExportOptions;
			
			if (iDocument==null) {
				Radiate.warn("Please open a document before trying to preview it");
				return;
			}
			
			htmlOptions = CodeManager.getExportOptions(CodeManager.HTML) as HTMLExportOptions;
			
			
			//htmlOptions.template = html5boilerplate;
			//htmlOptions.bordersCSS = bordersCSS;
			//htmlOptions.showBorders = showBorders;
			//htmlOptions.useBorderBox = useBoderBox;
			//htmlOptions.useInlineStyles = setStylesInline.selected;
			//htmlOptions.template = iDocument.template;
			//htmlOptions.disableTabs = true;
			//htmlOptions.useExternalStylesheet = false;
			//htmlOptions.exportChildDescriptors = showChildDescriptors.selected;
			//htmlOptions.reverseInitialCSS = true;
			
			/*if (updateCodeLive.selected && isCodeModifiedByUser) {
				htmlOptions.useCustomMarkup = true;
				htmlOptions.markup = aceEditor.text;
				htmlOptions.styles = aceCSSEditor.text;
			}
			else {
				htmlOptions.useCustomMarkup = false;
				htmlOptions.markup = "";
				htmlOptions.styles = "";
			}*/
			
			htmlOptions.reverseInitialCSS = false;
			
			// get source code
			sourceData = CodeManager.getSourceData(iDocument.instance, iDocument, CodeManager.HTML, htmlOptions);
			
			iDocument.errors = sourceData.errors;
			iDocument.warnings = sourceData.warnings;
			
			if (Radiate.isDesktop) {
				if (!radiate.isPreviewDocumentVisible()) {
					radiate.openDocumentPreview(iDocument, true);
				}
				
				previewDocument = radiate.getDocumentPreview(iDocument);
				
				
				if (previewDocument is UIComponent && sourceData) {
					previewDocument.htmlText = sourceData.source;
					previewDocument.addEventListener("ready", function(e:Event):void {
						previewDocument.htmlText = sourceData.source;
					});
					previewDocument.addEventListener("readystate", function(e:Event):void {
						previewDocument.htmlText = sourceData.source;
					});
					previewDocument.addEventListener("onreadystatechange", function(e:Event):void {
						previewDocument.htmlText = sourceData.source;
					});
					
					if (previewDocument is IValidator) {
						previewDocument.validateNow(); // prevent editor change event
					}
				}
				
			}
			else {
				// allow to swap between preview and non preview
				if (!radiate.isPreviewDocumentVisible()) {
					radiate.openDocumentPreview(radiate.selectedDocument, true);
					previewDocument = radiate.getDocumentPreview(radiate.selectedDocument);
					
					if (previewDocument is IFrame) {
						previewDocument.content = sourceData.source;
					}
					
					//radiate.dispatchPreviewEvent(codeModelTextArea.text, String(codeType.selectedItem));
				}
				else {
					radiate.openDocument(radiate.selectedDocument);
					//radiate.dispatchPreviewEvent(codeModelTextArea.text, "");
				}
			}
		}
		
		/**
		 * Copies URL to home page. This is the users WordPress sub site url
		 * If the user does not have a home page set then this goes to their blog
		 * In the future we should try to setup a way to have more than one
		 * home page. So one home page per project. Maybe if they visit
		 * the project document (which stores the project data) it instead
		 * shows their home page if set. 
		 * */
		public static function copyURLToHomePage(documentData:DocumentData):void {
			var clipboard:Clipboard = Clipboard.generalClipboard;
			var formatText:String = ClipboardFormats.TEXT_FORMAT;
			var formatURL:String = ClipboardFormats.URL_FORMAT;
			var serializable:Boolean;
			var url:String;
			/*
			if (documentData==null) {
				Radiate.warn("No document was selected.");
				return;
			}
			
			if (documentData.id==null) {
				Radiate.warn("The document is not saved. It will not have a URL until has been saved.");
				return;
			}
			*/
			url = Radiate.getWPURL();
			
			if (documentData) {
				
				/*
				if (documentData is ImageData) {
					url = ImageData(documentData).url;
				}
				else {
					url = documentData.uri;
				}
				
				if (documentData.status!=WPService.STATUS_PUBLISH) {
					Radiate.warn("The document is not published. Until it is published it will only be visible when logged in with edit priviledges.");
					//return;
				}*/
			}
			
			// it's recommended to clear the clipboard before setting new content
			clipboard.clear();
			
			try {
				clipboard.setData(formatText, String(url), serializable);
				
				if (Radiate.isDesktop) {
					clipboard.setData(formatURL, String(url), serializable);
				}
				
				Radiate.info("A link to the home page was copied to the clipboard");
			}
			catch (error:ErrorEvent) {
				Radiate.error("Couldn't copy link to the home page");
			}
			
		}
		
		/**
		 * Copy URL to document or media data to the clipboard
		 * */
		public static function copyURLToDocument(documentData:DocumentData, name:String = "document"):void {
			var clipboard:Clipboard = Clipboard.generalClipboard;
			var formatText:String = ClipboardFormats.TEXT_FORMAT;
			var formatURL:String = ClipboardFormats.URL_FORMAT;
			var serializable:Boolean;
			var url:String;
			
			if (documentData==null) {
				Radiate.warn("No " + name + " was selected.");
				return;
			}
			
			if (documentData.id==null) {
				Radiate.warn("The " + name + " is not saved. It will not have a URL until has been saved.");
				return;
			}
			
			if (documentData) {
				
				if (documentData is ImageData) {
					url = ImageData(documentData).url;
				}
				else {
					url = documentData.uri;
				}
				
				if (!(documentData is ImageData) && documentData.status!=WPService.STATUS_PUBLISH) {
					Radiate.warn("The " + name + " is not published. Until it is published it will only be visible when logged in with edit priviledges.");
					//return;
				}
			}
			
			// it's recommended to clear the clipboard before setting new content
			clipboard.clear();
			
			try {
				clipboard.setData(formatText, String(url), serializable);
				
				if (Radiate.isDesktop) {
					clipboard.setData(formatURL, String(url), serializable);
				}
				Radiate.info("A link to the " + name + " was copied to the clipboard");
			}
			catch (error:ErrorEvent) {
				Radiate.error("Couldn't copy link to the " + name + "");
			}
		}
		
		/**
		 * Copies URL to the clipboard. 
		 * */
		public static function copyURLToClipboard(url:String, name:String = "page"):void {
			var clipboard:Clipboard = Clipboard.generalClipboard;
			var formatText:String = ClipboardFormats.TEXT_FORMAT;
			var formatURL:String = ClipboardFormats.URL_FORMAT;
			var serializable:Boolean;
			
			if (url) {
				
				// it's recommended to clear the clipboard before setting new content
				clipboard.clear();
				
				try {
					clipboard.setData(formatText, String(url), serializable);
					
					if (Radiate.isDesktop) {
						clipboard.setData(formatURL, String(url), serializable);
					}
					
					Radiate.info("A link to the " + name + " was copied to the clipboard");
				}
				catch (error:ErrorEvent) {
					Radiate.error("Couldn't copy a link to the " + name);
				}
			}
		}
		
		/**
		 * Copies source code to the clipboard. 
		 * */
		public static function copyCodeToClipboard(code:String, name:String = "page"):void {
			var clipboard:Clipboard = Clipboard.generalClipboard;
			var formatText:String = ClipboardFormats.TEXT_FORMAT;
			var serializable:Boolean;
			
			if (code) {
				
				// it's recommended to clear the clipboard before setting new content
				clipboard.clear();
				
				try {
					clipboard.setData(formatText, String(code), serializable);
					
					Radiate.info("The " + name + " code was copied to the clipboard");
				}
				catch (error:ErrorEvent) {
					Radiate.error("Couldn't copy the " + name + " code");
				}
			}
		}
		
		/**
		 * Opens the documentation for the object in a browser window
		 * */
		public static function openDocumentationInBrowserButton(object:Object, showInternally:Boolean = true, showInAPIPanel:Boolean = true):void {
			var metadata:MetaData;
			var path:String = "";
			var prefix:String = "";
			var url:String;
			var className:String;
			var request:URLRequest;
			
			if (object is MetaData) {
				metadata = MetaData(object);
				url = Radiate.getURLToHelp(metadata);
			}
			else if (object) {
				className = ClassUtils.getQualifiedClassName(object);
				
				// flex capacitor classes usually extend spark classes
				// get documentation for spark class
				if (className.indexOf("flexcapacitor")!=-1) {
					className = ClassUtils.getSuperClass(object);
				}
				
				url = Radiate.getURLToHelp(className);
			}
			
			
			if (url) {
				
				if (showInternally) {
					if (showInAPIPanel) {
						Radiate.showAPIPanel(url);
					}
					else {
						Radiate.showDocumentationPanel(url);
					}
				}
				else {
					request = new URLRequest(url);
					navigateToURL(request, "asdocs");
				}
				
			}
		}
	}
}
