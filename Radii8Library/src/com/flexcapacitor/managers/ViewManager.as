package com.flexcapacitor.managers {
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.effects.popup.OpenPopUp;
	import com.flexcapacitor.model.DocumentData;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IProject;
	import com.flexcapacitor.views.MainView;
	import com.flexcapacitor.views.Remote;
	import com.flexcapacitor.views.windows.CopyImageToClipboardWindow;
	import com.flexcapacitor.views.windows.GalleryWindow;
	import com.flexcapacitor.views.windows.ImportWindow;
	import com.flexcapacitor.views.windows.PasteImageFromClipboardWindow;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	
	import mx.core.IVisualElement;
	
	import spark.components.Application;
	
	public class ViewManager {
		
		public function ViewManager() {
			
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
		 * Reference to the application
		 */
		[Bindable]
		public static var application:Application;
		
		/**
		 * Reference to the application main view
		 */
		[Bindable]
		public static var mainView:MainView;
		
		/**
		 * Reference to the application main layout
		 */
		[Bindable]
		public static var remoteView:Remote;
		
		/**
		 * Opens a window to accept paste image data from the clipboard when running in the browser
		 **/
		public static var pasteImageFromClipboard:OpenPopUp;
		
		/**
		 * Opens a window to allow you to copy the image to the clipboard when running in the browser
		 **/
		public static var copyImageToClipboard:OpenPopUp;
		
		/**
		 * Opens a window to an image gallery
		 **/
		public static var openGalleryPopUp:OpenPopUp;
		
		/**
		 * Reference to the application main view importPopUp
		 */
		[Bindable]
		public static var openImportPopUp:OpenPopUp;
		
		/**
		 * Shows the welcome home screen
		 * */
		public static function goToHomeScreen():void {
			if (mainView) {
				mainView.currentState = MainView.HOME_STATE;
			}
		}
		
		/**
		 * Shows the design screen
		 * */
		public static function goToDesignScreen(validate:Boolean = true):void {
			if (mainView) {
				mainView.currentState = MainView.DESIGN_STATE;
			}
			
			if (validate) {
				mainView.validateNow();
			}
		}
		
		/**
		 * Opens and displays the documentation panel
		 * */
		public static function showDocumentationPanel(url:String):void {
			
			if (mainView) {
				mainView.currentState = MainView.DESIGN_STATE;
				
				if (remoteView) {
					remoteView.showDocumentationPanel();
					
					if (url) {
						Radiate.dispatchDocumentationChangeEvent(url);
					}
				}
			}
		}
		
		/**
		 * Opens and displays the API documentation panel
		 * */
		public static function showAPIPanel(url:String):void {
			
			if (mainView) {
				mainView.currentState = MainView.DESIGN_STATE;
				
				if (remoteView) {
					remoteView.showAPIPanel();
					
					if (url) {
						Radiate.dispatchDocumentationChangeEvent(url);
					}
				}
			}
		}
		
		/**
		 * Opens and displays the console panel
		 * */
		public static function showConsolePanel(value:String=""):void {
			
			if (mainView) {
				mainView.currentState = MainView.DESIGN_STATE;
				
				if (remoteView) {
					remoteView.showConsolePanel();
					
					if (value) {
						Radiate.dispatchConsoleValueChangeEvent(value);
					}
				}
			}
		}
		
		/**
		 * Opens and displays the properties panel
		 * */
		public static function showPropertiesPanel(showFirstPage:Boolean = false):void {
			if (mainView) {
				mainView.currentState = MainView.DESIGN_STATE;
				
				if (remoteView) {
					remoteView.showPropertiesPanel(showFirstPage);
				}
			}
		}
		
		/**
		 * Opens and displays the layout panel
		 * */
		public static function showLayoutPanel():void {
			if (mainView) {
				mainView.currentState = MainView.DESIGN_STATE;
				
				if (remoteView) {
					remoteView.showLayoutPanel();
				}
			}
		}
		
		/**
		 * Opens and displays the filters panel
		 * */
		public static function showFiltersPanel():void {
			if (mainView) {
				mainView.currentState = MainView.DESIGN_STATE;
				
				if (remoteView) {
					remoteView.showFiltersPanel();
				}
			}
		}
		
		/**
		 * Shows the library panel
		 * */
		public static function showLibraryPanel(data:DocumentData, clearSearch:Boolean = false):void {
			if (mainView) {
				mainView.currentState = MainView.DESIGN_STATE;
				
				if (remoteView) {
					remoteView.showLibraryPanel(data, clearSearch);
				}
			}
		}
		
		/**
		 * Show paste image from clipboard panel
		 * */
		public static function showPasteImagePanel():void {
			
			if (pasteImageFromClipboard ==null) {
				pasteImageFromClipboard = new OpenPopUp();
				pasteImageFromClipboard.popUpType = PasteImageFromClipboardWindow;
				pasteImageFromClipboard.modalDuration = 100;
				pasteImageFromClipboard.backgroundAlpha = .5;
			}
			
			pasteImageFromClipboard.play();
		}
		
		/**
		 * Show gallery panel
		 * */
		public static function showGalleryPanel():void {
			
			if (openGalleryPopUp ==null) {
				openGalleryPopUp = new OpenPopUp();
				openGalleryPopUp.popUpType = GalleryWindow;
				openGalleryPopUp.modalDuration = 100;
				openGalleryPopUp.backgroundAlpha = .5;
			}
			
			openGalleryPopUp.play();
		}
		
		/**
		 * Returns true if paste image from the clipboard panel is open
		 * */
		public static function isPasteImageFromClipboardOpen():Boolean {
			
			if (pasteImageFromClipboard && pasteImageFromClipboard.isOpen) {
				return true;
			}
			
			return false;
		}
		
		/**
		 * Returns true if copy image to the clipboard panel is open
		 * */
		public static function isCopyImageToClipboardPanelOpen():Boolean {
			
			if (copyImageToClipboard && copyImageToClipboard.isOpen) {
				return true;
			}
			
			return false;
		}
		
		/**
		 * Show copy image to the clipboard panel
		 * */
		public static function showCopyImageToClipboardPanel(bitmapData:BitmapData = null):void {
			
			if (copyImageToClipboard==null) {
				copyImageToClipboard = new OpenPopUp();
				copyImageToClipboard.popUpType = CopyImageToClipboardWindow;
				copyImageToClipboard.modalDuration = 100;
				copyImageToClipboard.backgroundAlpha = .5;
			}
			
			copyImageToClipboard.data = {bitmapData:bitmapData};
			
			copyImageToClipboard.play();
		}
		
		/**
		 * Open import MXML window
		 * */
		public static function openImportMXMLWindow(title:String, code:String = "", showRevisions:Boolean = false, snippet:String = ""):void {
			
			if (openImportPopUp==null) {
				createOpenImportPopUp();
			}
			
			if (!openImportPopUp.isOpen) {
				openImportPopUp.popUpOptions = {title:title, code:code, showRevisions:showRevisions, snippetID:snippet};
				openImportPopUp.play();
			}
		}
		
		/**
		 * Creates the import window pop up
		 **/
		public static function createOpenImportPopUp():void {
			if (openImportPopUp==null) {
				openImportPopUp = new OpenPopUp();
				openImportPopUp.popUpType = ImportWindow; 
				openImportPopUp.modalDuration = 150;
				openImportPopUp.percentWidth = 80;
				openImportPopUp.percentHeight = 76;
				openImportPopUp.useHardPercent = true;
				openImportPopUp.parent = ViewManager.application;
				openImportPopUp.closeOnMouseDownOutside = false;
				openImportPopUp.closeOnMouseDownInside = false;
				openImportPopUp.closeOnEscapeKey = false;
				openImportPopUp.addEventListener(OpenPopUp.CLOSE, closeImportWindowHandler);
			}
		}
		
		/**
		 * When import MXML window is closed we check for requested action 
		 * and import if necessary 
		 * */
		public static function closeImportWindowHandler(event:Event):void {
			var selectedDocument:IDocument = selectedDocument;
			var popUp:ImportWindow = ImportWindow(openImportPopUp.popUp);
			var type:String = popUp.importLocation.selectedValue as String;
			var action:String = popUp.action;
			var code:String = popUp.code;
			var target:Object = Radiate.instance.target;
			
			if (action==ImportWindow.IMPORT) {
				if (type==ImportWindow.NEW_DOCUMENT) {
					ImportManager.importMXMLDocument(selectedProject, null, code);
				}
				else if (type==ImportWindow.CURRENT_DOCUMENT && selectedDocument) {
					ImportManager.importMXMLDocument(selectedProject, selectedDocument, code);
				}
				else if (type==ImportWindow.CURRENT_SELECTION && target is IVisualElement) {
					if (target is IVisualElement) {
						ImportManager.importMXMLDocument(selectedProject, selectedDocument, code, IVisualElement(target));
					}
					//Alert.show("Please select a visual element");
				}
				else {
					//Alert.show("Please select a document");
				}
			}
			
			popUp.action = null;
			popUp.code = null;
		}
	}
}