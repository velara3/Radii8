package com.flexcapacitor.managers {
	
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.effects.popup.OpenPopUp;
	import com.flexcapacitor.model.DocumentData;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.ImageData;
	import com.flexcapacitor.services.WPService;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.views.ImageView;
	
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	
	import mx.core.UIComponent;

	
	/**
	 * Helper class to run common commands
	 * */
	public class RunManager extends EventDispatcher {
		
		
		public function RunManager():void {
			
		}
		
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
		public static function openDocumentInBrowserButton(windowName:String=null):void {
			var iDocument:IDocument = Radiate.instance.selectedDocument;
			
			if (iDocument) {
				
				if (iDocument.status!=WPService.STATUS_PUBLISH) {
					if (documentNotPublishedWarning) {
						Radiate.openInBrowser(iDocument, windowName);
					}
					else {
						documentNotPublishedWarning = true;
						Radiate.warn("The document is not published. You may need to login in your browser to see it. Otherwise set to publish and save.")
						Radiate.callAfter(2500, Radiate.openInBrowser, iDocument, windowName);
					}
				}
				else {
					Radiate.openInBrowser(iDocument);
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
		
		
		public static var openPopUp:OpenPopUp;
	}
}
