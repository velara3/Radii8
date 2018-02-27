package com.flexcapacitor.managers
{
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IDocumentData;
	import com.flexcapacitor.model.MenuItem;
	import com.flexcapacitor.utils.ClassUtils;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ListCollectionView;
	
	import org.as3commons.lang.DictionaryUtils;

	/**
	 * Manages menus
	 **/
	public class MenuManager {
		
		public function MenuManager() {
			
		}
		
		/**
		 * Get the current document.
		 * */
		public static function get selectedDocument():IDocument {
			return Radiate.selectedDocument;
		}
		
		/**
		 * Application menu
		 * */
		[Bindable]
		public static var applicationMenu:Object;
		
		/**
		 * Application window menu
		 * */
		[Bindable]
		public static var applicationWindowMenu:Object;
		
		public static var windowMenuDictionary:Dictionary = new Dictionary(true);
		
		/**
		 * Update the window menu item
		 * */
		public static function updateWindowMenu(windowItem:MenuItem, nativeMenuItem:Object = null):void {
			var numberOfItems:int = windowItem.children ? windowItem.children.length : 0;
			var menu:Object;
			var menuItem:MenuItem;
			var numberOfDocuments:int;
			var iDocumentData:IDocumentData;
			var menuFound:Boolean;
			var applicationMenusCollection:ListCollectionView;
			var items:Array;
			var numberOfMenus:int;
			var isNativeMenu:Boolean;
			var documents:Array = DocumentManager.documents;
			
			numberOfDocuments = documents.length;
			
			
			if (applicationMenu is Class(MenuItem.NativeMenuDefinition)) {
				var keys:Array = org.as3commons.lang.DictionaryUtils.getKeys(windowMenuDictionary);
				org.as3commons.lang.DictionaryUtils.deleteKeys(windowMenuDictionary, keys);
				items = applicationMenu.items;
				numberOfMenus = items ? items.length : 0;
				isNativeMenu = true;
				return;
			}
			else {
				windowItem.removeAllChildren();
				isNativeMenu = false;
				applicationMenusCollection = applicationMenu ? applicationMenu.dataProvider : ViewManager.mainView.mainMenuBar.dataProvider as ListCollectionView;
				numberOfMenus = applicationMenusCollection ? applicationMenusCollection.length : 0;
				
				for (var j:int; j < numberOfDocuments; j++) {
					iDocumentData = documents[j];
					
					menuItem = new MenuItem();
					menuItem.data = iDocumentData;
					menuItem.type = "radio";//ClassUtils.getQualifiedClassName(iDocumentData);
					menuItem.label = iDocumentData.name;
					
					if (iDocumentData==selectedDocument) {
						windowItem.checked = true;
					}
					else {
						windowItem.checked = false;
					}
					windowItem.addItem(menuItem);
				}
			}
			
			
			for (var i:int; i < numberOfMenus; i++) {
				if (applicationMenusCollection.getItemAt(i)==applicationWindowMenu) {
					applicationMenusCollection.removeItemAt(i);
					applicationMenusCollection.addItemAt(windowItem, i);
					//windowItem.checked = true;
					menuFound = true;
					break;
				}
			}
			
			if (menuFound) {
				windowItem.checked = true;
			}
			else {
				applicationMenusCollection.addItem(windowItem);
			}
			
			applicationMenu.dataProvider = applicationMenusCollection;
			
		}
	}
}