package com.flexcapacitor.managers {
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.effects.popup.OpenPopUp;
	import com.flexcapacitor.model.DocumentData;
	import com.flexcapacitor.views.MainView;
	import com.flexcapacitor.views.Remote;
	import com.flexcapacitor.views.windows.PasteImageFromClipboardWindow;
	import com.flexcapacitor.views.windows.GalleryWindow;
	import com.flexcapacitor.views.windows.CopyImageToClipboardWindow;
	
	import flash.display.BitmapData;
	
	import spark.components.Application;
	
	public class ViewManager {
		
		public function ViewManager() {
			
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
			var radiate:Radiate = Radiate.instance;
			
			if (mainView) {
				mainView.currentState = MainView.DESIGN_STATE;
				
				if (remoteView) {
					remoteView.showDocumentationPanel();
					
					if (url) {
						radiate.dispatchDocumentationChangeEvent(url);
					}
				}
			}
		}
		
		/**
		 * Opens and displays the API documentation panel
		 * */
		public static function showAPIPanel(url:String):void {
			var radiate:Radiate = Radiate.instance;
			
			if (mainView) {
				mainView.currentState = MainView.DESIGN_STATE;
				
				if (remoteView) {
					remoteView.showAPIPanel();
					
					if (url) {
						radiate.dispatchDocumentationChangeEvent(url);
					}
				}
			}
		}
		
		/**
		 * Opens and displays the console panel
		 * */
		public static function showConsolePanel(value:String=""):void {
			var radiate:Radiate = Radiate.instance;
			
			if (mainView) {
				mainView.currentState = MainView.DESIGN_STATE;
				
				if (remoteView) {
					remoteView.showConsolePanel();
					
					if (value) {
						radiate.dispatchConsoleValueChangeEvent(value);
					}
				}
			}
		}
		
		/**
		 * Opens and displays the properties panel
		 * */
		public static function showPropertiesPanel(showFirstPage:Boolean = false):void {
			var radiate:Radiate = Radiate.instance;
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
	}
}