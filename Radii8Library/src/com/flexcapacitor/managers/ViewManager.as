package com.flexcapacitor.managers {
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.effects.popup.OpenPopUp;
	import com.flexcapacitor.model.DocumentData;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IProject;
	import com.flexcapacitor.views.MainView;
	import com.flexcapacitor.views.Remote;
	import com.flexcapacitor.views.windows.ContactWindow;
	import com.flexcapacitor.views.windows.CopyImageToClipboardWindow;
	import com.flexcapacitor.views.windows.CreditsWindow;
	import com.flexcapacitor.views.windows.DeleteDocumentWindow;
	import com.flexcapacitor.views.windows.ExportDocumentWindow;
	import com.flexcapacitor.views.windows.ExportSnippetWindow;
	import com.flexcapacitor.views.windows.GalleryWindow;
	import com.flexcapacitor.views.windows.HelpWindow;
	import com.flexcapacitor.views.windows.ImportWindow;
	import com.flexcapacitor.views.windows.LoginWindow;
	import com.flexcapacitor.views.windows.NewDocumentWindow;
	import com.flexcapacitor.views.windows.PasteImageFromClipboardWindow;
	import com.flexcapacitor.views.windows.PrintWindow;
	import com.flexcapacitor.views.windows.SettingsWindow;
	
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
		
		public static var defaultPercentWidth:int = 70;
		public static var defaultPercentHeight:int = 90;
		public static var modalDuration:int = 150;
		public static var modalBackgroundAlpha:Number = .5;
		public static var fileTransferWindowClass:String = "com.flexcapacitor.views.FileTransferWindow";
		
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
		 * Opens an export snippets window
		 **/
		public static var openSnippetsPopUp:OpenPopUp;
		
		/**
		 * Opens the import code window 
		 */
		public static var openImportPopUp:OpenPopUp;
		
		/**
		 * Opens the contact window
		 */
		public static var openContactPopUp:OpenPopUp;
		
		/**
		 * Opens the login window
		 */
		public static var openLoginPopUp:OpenPopUp;
		
		/**
		 * Opens the logout window
		 */
		public static var openLogoutPopUp:OpenPopUp;
		
		/**
		 * Opens the new project window
		 */
		public static var openNewProjectPopUp:OpenPopUp;
		
		/**
		 * Opens the delete project window
		 */
		public static var openDeleteProjectPopUp:OpenPopUp;
		
		/**
		 * Opens the delete document window
		 */
		public static var openDeleteDocumentPopUp:OpenPopUp;
		
		/**
		 * Opens the export document window
		 */
		public static var openExportDocumentPopUp:OpenPopUp;
		
		/**
		 * Opens the upload to server window
		 */
		public static var openUploadToServerPopUp:OpenPopUp;
		
		/**
		 * Opens the print window
		 */
		public static var openPrintPopUp:OpenPopUp;
		
		/**
		 * Opens the registration window
		 */
		public static var openRegistrationPopUp:OpenPopUp;
		
		/**
		 * Opens the lost login window
		 */
		public static var openLostLoginPopUp:OpenPopUp;
		
		/**
		 * Opens the help window
		 */
		public static var openHelpPopUp:OpenPopUp;
		
		/**
		 * Opens the credits window
		 */
		public static var openCreditsPopUp:OpenPopUp;
		
		/**
		 * Opens the settings window
		 */
		public static var openSettingsPopUp:OpenPopUp;
		
		/**
		 * Shows the welcome home screen
		 * */
		public static function goToHomeScreen():void {
			if (mainView) {
				mainView.currentState = MenuManager.HOME_STATE;
			}
		}
		
		/**
		 * Shows the design screen
		 * */
		public static function goToDesignScreen(validate:Boolean = true):void {
			if (mainView) {
				mainView.currentState = MenuManager.DESIGN_STATE;
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
				mainView.currentState = MenuManager.DESIGN_STATE;
				
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
				mainView.currentState = MenuManager.DESIGN_STATE;
				
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
				mainView.currentState = MenuManager.DESIGN_STATE;
				
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
				mainView.currentState = MenuManager.DESIGN_STATE;
				
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
				mainView.currentState = MenuManager.DESIGN_STATE;
				
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
				mainView.currentState = MenuManager.DESIGN_STATE;
				
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
				mainView.currentState = MenuManager.DESIGN_STATE;
				
				if (remoteView) {
					remoteView.showLibraryPanel(data, clearSearch);
				}
			}
		}
		
		/**
		 * Show paste image from clipboard panel
		 * */
		public static function openPasteImageWindow():void {
			
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
		public static function openGalleryWindow():void {
			
			if (openGalleryPopUp ==null) {
				openGalleryPopUp = new OpenPopUp();
				openGalleryPopUp.popUpType = GalleryWindow;
				openGalleryPopUp.modalDuration = 100;
				openGalleryPopUp.backgroundAlpha = .5;
			}
			
			openGalleryPopUp.play();
		}
		
		/**
		 * Show export snippet window
		 * */
		public static function openExportSnippetWindow():void {
			
			if (openSnippetsPopUp ==null) {
				openSnippetsPopUp = new OpenPopUp();
				openSnippetsPopUp.popUpType = ExportSnippetWindow;
				openSnippetsPopUp.modalDuration = modalDuration;
				openSnippetsPopUp.backgroundAlpha = modalBackgroundAlpha;
				openSnippetsPopUp.percentWidth = 70;
				openSnippetsPopUp.percentHeight = 90;
				openSnippetsPopUp.width = 800;
			}
			
			openSnippetsPopUp.play();
		}
		
		/**
		 * Open contact window
		 * */
		public static function openContactWindow():void {
			
			if (openContactPopUp ==null) {
				openContactPopUp = new OpenPopUp();
				openContactPopUp.popUpType = ContactWindow;
				openContactPopUp.modalDuration = modalDuration;
				openContactPopUp.backgroundAlpha = modalBackgroundAlpha;
				openContactPopUp.percentWidth = 70;
				openContactPopUp.percentHeight = 90;
				openContactPopUp.width = 600;
			}
			
			openContactPopUp.play();
		}
		
		/**
		 * Open login window
		 * */
		public static function openLoginWindow(handler:Function = null):void {
			
			if (openLoginPopUp ==null) {
				openLoginPopUp = new OpenPopUp();
				openLoginPopUp.popUpType = LoginWindow;
				openLoginPopUp.modalDuration = modalDuration;
				openLoginPopUp.backgroundAlpha = modalBackgroundAlpha;
				openLoginPopUp.percentWidth = 70;
				openLoginPopUp.percentHeight = 90;
				openLoginPopUp.width = 600;
				openLoginPopUp.popUpOptions = {currentState:LoginWindow.LOGIN};
			}
			
			if (handler!=null) {
				openLoginPopUp.addEventListener(OpenPopUp.CLOSE, handler, false, 0, true);
			}
			
			openLoginPopUp.play();
		}
		
		
		/**
		 * Open logout window
		 * */
		public static function openLogoutWindow(handler:Function = null):void {
			
			if (openLogoutPopUp ==null) {
				openLogoutPopUp = new OpenPopUp();
				openLogoutPopUp.popUpType = LoginWindow;
				openLogoutPopUp.modalDuration = modalDuration;
				openLogoutPopUp.backgroundAlpha = modalBackgroundAlpha;
				openLogoutPopUp.percentWidth = 70;
				openLogoutPopUp.percentHeight = 90;
				openLogoutPopUp.width = 600;
				openLogoutPopUp.popUpOptions = {currentState:LoginWindow.LOGOUT};
			}
			
			if (handler!=null) {
				openLogoutPopUp.addEventListener(OpenPopUp.CLOSE, handler, false, 0, true);
			}
			
			openLogoutPopUp.play();
		}
		
		/**
		 * Open new project window
		 * */
		public static function openNewProjectWindow(handler:Function = null):void {
			
			if (openNewProjectPopUp ==null) {
				openNewProjectPopUp = new OpenPopUp();
				openNewProjectPopUp.popUpType = NewDocumentWindow;
				openNewProjectPopUp.modalDuration = modalDuration;
				openNewProjectPopUp.backgroundAlpha = modalBackgroundAlpha;
				openNewProjectPopUp.percentWidth = 70;
				openNewProjectPopUp.percentHeight = 90;
				openNewProjectPopUp.width = 600;
				openNewProjectPopUp.popUpOptions = {currentState:NewDocumentWindow.PROJECT};
			}
			
			if (handler!=null) {
				openNewProjectPopUp.addEventListener(OpenPopUp.CLOSE, handler, false, 0, true);
			}
			
			openNewProjectPopUp.play();
		}
		
		/**
		 * Open delete project window
		 * */
		public static function openDeleteProjectWindow(documentData:DocumentData, handler:Function = null):void {
			
			if (openDeleteProjectPopUp ==null) {
				openDeleteProjectPopUp = new OpenPopUp();
				openDeleteProjectPopUp.popUpType = DeleteDocumentWindow;
				openDeleteProjectPopUp.modalDuration = modalDuration;
				openDeleteProjectPopUp.backgroundAlpha = modalBackgroundAlpha;
				openDeleteProjectPopUp.percentWidth = 70;
				openDeleteProjectPopUp.percentHeight = 90;
				openDeleteProjectPopUp.width = 600;
				openDeleteProjectPopUp.popUpOptions = {currentState:DeleteDocumentWindow.PROJECT};
			}
			
			openDeleteProjectPopUp.popUpOptions.documentData = documentData;
			
			if (handler!=null) {
				openDeleteProjectPopUp.addEventListener(OpenPopUp.CLOSE, handler, false, 0, true);
			}
			
			openDeleteProjectPopUp.play();
		}
		
		/**
		 * Open delete document window
		 * */
		public static function openDeleteDocumentWindow(handler:Function = null):void {
			
			if (openDeleteDocumentPopUp ==null) {
				openDeleteDocumentPopUp = new OpenPopUp();
				openDeleteDocumentPopUp.popUpType = DeleteDocumentWindow;
				openDeleteDocumentPopUp.modalDuration = modalDuration;
				openDeleteDocumentPopUp.backgroundAlpha = modalBackgroundAlpha;
				openDeleteDocumentPopUp.percentWidth = defaultPercentWidth;
				openDeleteDocumentPopUp.percentHeight = 90;
				openDeleteDocumentPopUp.width = 600;
				openDeleteDocumentPopUp.popUpOptions = {currentState:DeleteDocumentWindow.DOCUMENT};
			}
			
			if (handler!=null) {
				openDeleteDocumentPopUp.addEventListener(OpenPopUp.CLOSE, handler, false, 0, true);
			}
			
			openDeleteDocumentPopUp.play();
		}
		
		/**
		 * Open export document window
		 * */
		public static function openExportDocumentWindow():void {
			
			if (openExportDocumentPopUp ==null) {
				openExportDocumentPopUp = new OpenPopUp();
				openExportDocumentPopUp.popUpType = ExportDocumentWindow;
				openExportDocumentPopUp.modalDuration = modalDuration;
				openExportDocumentPopUp.backgroundAlpha = modalBackgroundAlpha;
				openExportDocumentPopUp.percentWidth = defaultPercentWidth;
				openExportDocumentPopUp.percentHeight = 90;
				openExportDocumentPopUp.width = 600;
			}
			
			openExportDocumentPopUp.play();
		}
		
		/**
		 * Open upload to server window
		 * */
		public static function openUploadToServerWindow():void {
			
			if (openUploadToServerPopUp ==null) {
				openUploadToServerPopUp = new OpenPopUp();
				openUploadToServerPopUp.popUpType = fileTransferWindowClass;
				openUploadToServerPopUp.modalDuration = modalDuration;
				openUploadToServerPopUp.backgroundAlpha = modalBackgroundAlpha;
				openUploadToServerPopUp.percentWidth = defaultPercentWidth;
				openUploadToServerPopUp.percentHeight = 90;
				openUploadToServerPopUp.width = 600;
			}
			
			openUploadToServerPopUp.play();
		}
		
		/**
		 * Open print window
		 * */
		public static function openPrintWindow():void {
			
			if (openPrintPopUp ==null) {
				openPrintPopUp = new OpenPopUp();
				openPrintPopUp.popUpType = PrintWindow;
				openPrintPopUp.modalDuration = modalDuration;
				openPrintPopUp.backgroundAlpha = modalBackgroundAlpha;
				openPrintPopUp.percentWidth = defaultPercentWidth;
				openPrintPopUp.percentHeight = 90;
				openPrintPopUp.width = 600;
			}
			
			openPrintPopUp.play();
		}
		
		/**
		 * Open lost login window
		 * */
		public static function openLostLoginWindow(handler:Function = null):void {
			
			if (openLostLoginPopUp ==null) {
				openLostLoginPopUp = new OpenPopUp();
				openLostLoginPopUp.popUpType = LoginWindow;
				openLostLoginPopUp.modalDuration = modalDuration;
				openLostLoginPopUp.backgroundAlpha = modalBackgroundAlpha;
				openLostLoginPopUp.percentWidth = defaultPercentWidth;
				openLostLoginPopUp.percentHeight = 90;
				openLostLoginPopUp.width = 600;
				openLostLoginPopUp.popUpOptions = {currentState:LoginWindow.LOST_PASSWORD, openingState:LoginWindow.LOST_PASSWORD};
			}
			
			if (handler!=null) {
				openLostLoginPopUp.addEventListener(OpenPopUp.CLOSE, handler, false, 0, true);
			}
			
			openLostLoginPopUp.play();
		}
		
		/**
		 * Open registration with site window
		 * */
		public static function openRegistrationWindow(handler:Function = null):void {
			
			if (openRegistrationPopUp ==null) {
				openRegistrationPopUp = new OpenPopUp();
				openRegistrationPopUp.popUpType = LoginWindow;
				openRegistrationPopUp.modalDuration = modalDuration;
				openRegistrationPopUp.backgroundAlpha = modalBackgroundAlpha;
				openRegistrationPopUp.percentWidth = defaultPercentWidth;
				openRegistrationPopUp.percentHeight = 90;
				openRegistrationPopUp.width = 600;
				openRegistrationPopUp.popUpOptions = {currentState:LoginWindow.REGISTRATION_WITH_SITE};
			}
			
			if (handler!=null) {
				openRegistrationPopUp.addEventListener(OpenPopUp.CLOSE, handler, false, 0, true);
			}
			
			openRegistrationPopUp.play();
		}
		
		/**
		 * Open credits window
		 * */
		public static function openCreditsWindow():void {
			
			if (openCreditsPopUp ==null) {
				openCreditsPopUp = new OpenPopUp();
				openCreditsPopUp.popUpType = CreditsWindow;
				openCreditsPopUp.modalDuration = modalDuration;
				openCreditsPopUp.backgroundAlpha = modalBackgroundAlpha;
				openCreditsPopUp.percentWidth = defaultPercentWidth;
				openCreditsPopUp.percentHeight = 90;
				openCreditsPopUp.width = 720;
			}
			
			openCreditsPopUp.play();
		}
		
		/**
		 * Open help window
		 * */
		public static function openHelpWindow():void {
			
			if (openHelpPopUp ==null) {
				openHelpPopUp = new OpenPopUp();
				openHelpPopUp.popUpType = HelpWindow;
				openHelpPopUp.modalDuration = modalDuration;
				openHelpPopUp.backgroundAlpha = modalBackgroundAlpha;
				openHelpPopUp.percentWidth = defaultPercentWidth;
				openHelpPopUp.percentHeight = defaultPercentHeight;
				openHelpPopUp.width = 720;
			}
			
			openHelpPopUp.play();
		}
		
		/**
		 * Open settings window
		 * */
		public static function openSettingsWindow():void {
			
			if (openSettingsPopUp ==null) {
				openSettingsPopUp = new OpenPopUp();
				openSettingsPopUp.popUpType = SettingsWindow;
				openSettingsPopUp.modalDuration = modalDuration;
				openSettingsPopUp.backgroundAlpha = modalBackgroundAlpha;
				openSettingsPopUp.percentWidth = defaultPercentWidth;
				openSettingsPopUp.percentHeight = defaultPercentHeight;
				openSettingsPopUp.width = 720;
			}
			
			openSettingsPopUp.play();
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