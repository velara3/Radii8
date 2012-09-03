
package managers {
	import com.flexcapacitor.controller.Radiate;
	
	import data.Item;
	import data.Perspective;
	import data.Preferences;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.registerClassAlias;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.events.FlexEvent;
	import mx.utils.ObjectUtil;
	
	/**
	 * 
	 * */
	public class RemoteManager extends EventDispatcher {
		
		
		public static const SHARED_OBJECT_NAME:String 	= "save";
		public static const ITEMS_UPDATED:String 		= "itemsUpdated";
		public static const ITEMS_UPDATE_FAULT:String 	= "itemsUpdateFault";
		public static const SETTINGS_CHANGE:String 	= "settingChange";
		
		public function RemoteManager(s:SINGLEDOUBLE) {
			
			//super(target as IEventDispatcher);
			
			
			// listen to changes to settings and save
			addEventListener(SETTINGS_CHANGE, settingChangeHandler);
			addEventListener(ITEMS_UPDATED, itemsUpdatedHandler);
		}
		
		/////////////////////////////////////////////////////////
		/// Variables
		/////////////////////////////////////////////////////////
		
		/**
		 * 
		 * */
		public static var clearSharedObject:Boolean;
		
		/**
		 * Indicates if getting list of items from the server
		 * */
		[Bindable]
		public static var retrievingData:Boolean;
		
		/**
		 * Items received successfully
		 * */
		[Bindable]
		public static var itemsReceived:Boolean;
		
		/**
		 * 
		 * */
		public static var modulesArray:Array;
		
		/**
		 * 
		 * */
		public static var menubarXML:XML;
		
		/**
		 * 
		 * */
		public static var preferencesXML:XML;
		
		/**
		 * 
		 * */
		public static var loader:URLLoader;
		
		/**
		 * URL of preferences file
		 * Default will be "http://www.radii8.com/panels/preferences.xml"
		 * */
		public static var preferencesURL:String = "preferences.xml";
		
		/**
		 * Default types
		 * */
		public static var defaultTypes:Array = ["com.radii8.views.properties", "com.radii8.tools.selector"];
		
		/**
		 * 
		 * */
		[Bindable]
		public static var preferences:Preferences;
		
		/**
		 * 
		 * */
		[Bindable]
		public static var perspectives:Array = [];
		
		/**
		 * 
		 * */
		[Bindable]
		public static var selectedPerspective:Perspective;
		
		/**
		 * 
		 * */
		[Bindable]
		public static var defaultPerspective:Perspective;
		
		/**
		 * List of XML item nodes from the server
		 * */
		[Bindable]
		public static var itemsXMLList:XMLList;
		
		/**
		 * List of items from the server
		 * */
		[Bindable]
		public static var remoteItemsList:ArrayCollection = new ArrayCollection();
		
		/**
		 * 
		 * */
		[Bindable]
		public static var preferencesList:ArrayList = new ArrayList();
		
		/**
		 * 
		 * */
		[Bindable]
		public static var perspectivesList:ArrayList = new ArrayList();
		
		/**
		 * Must be declared before modules are loaded for singleton
		 * */
		public static var radiate:Radiate = Radiate.getInstance();
		
		/**
		 * Loading status text message
		 * */
		[Bindable]
		public static var loadingStatusText:String;
		
		
		/**
		 * Adds an item to the selected perspective
		 * */
		public static function updatePerspectiveItem(perspective:Perspective, item:Item, add:Boolean):void {
			var types:Array = perspective.types;
			var count:int = types ? types.length : 0;
			var exists:Boolean;
			var i:int;
			
			// add item
			if (add) {
				for (i;i<count;i++) {
					
					// check if item is already added
					if (types[i]==item.type) {
						exists = true;
						break;
					}
				}
				
				if (!exists) {
					types.push(item.type);
				}
			}
			else {
				for (i;i<count;i++) {
					
					// check if item is in perspective
					if (types[i]==item.type) {
						types.splice(i, 1);
						break;
					}
				}
			}
		}
		
		/**
		 * Register classes for saving settings
		 * */
		public static function init(clearCache:Boolean = false):void {
			var saveData:SharedObject = SharedObject.getLocal(SHARED_OBJECT_NAME);
			clearSharedObject = clearCache;
			
			registerClassAlias("Item", Item);
			registerClassAlias("Preferences", Preferences);
			registerClassAlias("Perspective", Perspective);
			
			// clear the saved data
			if (clearSharedObject) {
				saveData.clear();
			}
			
			createInitialPreferences();
			getSettings();
			//getRemoteItems();
		}
		
		
		/**
		 * Creates settings if they don't exist
		 * */
		public static function createInitialPreferences():void {
			var saveData:SharedObject = SharedObject.getLocal(SHARED_OBJECT_NAME);
			preferences = saveData.data.preferences;
			
			// create default settings
			if (!preferences) {
				createDefaultPreferences();
				saveSettings();
			}
			else {
				
				defaultPerspective = preferences.defaultPerspective;
				selectedPerspective = preferences.selectedPerspective;
				perspectives = preferences.perspectives;
			}
			
		}
		
		/**
		 * Create default preferences locally. 
		 * Sets default perspective and selected perspective
		 * */
		public static function createDefaultPreferences():void {
			var newPerspective:Perspective;
			var newPreferences:Preferences;
			
			newPreferences 			= new Preferences();
			newPreferences.name 	= "Default Preferences";
			newPreferences.url 		= preferencesURL;
			
			newPerspective 			= new Perspective();
			newPerspective.name 	= "Default Perspective";
			newPerspective.types 	= defaultTypes;
			
			defaultPerspective 		= newPerspective;
			selectedPerspective 	= newPerspective;
			
			newPreferences.perspectives = perspectives;
			
			perspectives.push(newPerspective);
			
			preferences = newPreferences;
		}
		
		/**
		 * Gets settings from disk
		 * */
		public static function getSettings():void {
			var saveData:SharedObject = SharedObject.getLocal(SHARED_OBJECT_NAME); 
			var savedPreferences:Preferences = saveData.data.preferences;
			
			
			// set selected perspective
			if (savedPreferences && !savedPreferences.selectedPerspective) {
				preferences.selectedPerspective = savedPreferences.defaultPerspective;
			}
			
			trace("Getting Settings:\n" + ObjectUtil.toString(saveData.data.preferences));
			
		}
		
		/**
		 * Saves changes to settings when dispatched from modules
		 * */
		public static function settingChangeHandler(event:Event):void {
			saveSettings();
		}
		
		/**
		 * Saves settings to disk
		 * */
		public static function saveSettings():void {
			var saveData:SharedObject = SharedObject.getLocal(SHARED_OBJECT_NAME);
			
			preferences.defaultPerspective = defaultPerspective;
			preferences.selectedPerspective = selectedPerspective;
			
			saveData.data.preferences = preferences;
			
			saveData.flush();
			
			//trace("Saving Settings:" + saveData.data.preferences);
		}
		
		/**
		 * Get Remote Items
		 * */
		public function getRemoteItems():void {
			retrievingData = true;
			itemsReceived = false;
			
			// if there are no items then get remote list of items
			addEventListener(ITEMS_UPDATED, itemsUpdatedHandler);
			addEventListener(ITEMS_UPDATE_FAULT, itemsUpdateFaultHandler);
			
			retrieveRemoteItems();
			
			
			loadingStatusText = "Getting Remote Items...";
			
			
		}
		
		/**
		 * 
		 * */
		protected function itemsUpdatedHandler(event:Event):void {
			trace("received items");
		}
		
		/**
		 * Parses list of views available on the server
		 * */
		public function getRemoteItemsHandler(event:Event):void {
			var data:String = loader.data as String;
			retrievingData = false;
			
			try {
				var xml:XML = new XML(data);
				itemsXMLList = xml.items.item;
				
				loadingStatusText += "\nData received...";
				
				addRemoteItemsList();
				
				loadingStatusText += "\nParsed data items...";
				loadingStatusText += "\nLoading Complete...";
				
				itemsReceived = true;
				
				updatedPerspectivesHandler();
				
				dispatchEvent(new Event(ITEMS_UPDATED));
			}
			catch (error:Error) {
				
				itemsReceived = false;
				
				loadingStatusText += "\nError in data: " + error.message;
				
			}
			
		}
		
		/**
		 * Offline 
		 * */
		public function ioErrorHandler(event:IOErrorEvent):void {
			var error:String;
			retrievingData = false;
			dispatchEvent(new Event(ITEMS_UPDATE_FAULT));
			itemsReceived = false;
			
			loadingStatusText += "\n" +  event.text;
		}
		
		/**
		 * Offline 
		 * */
		public function securityErrorHandler(event:SecurityErrorEvent):void {
			var error:String;
			retrievingData = false;
			itemsReceived = false;
			
			dispatchEvent(new Event(ITEMS_UPDATE_FAULT));
			
			loadingStatusText += "\n" +  event.text;
		}
		
		
		
		/**
		 * Converts items to objects
		 * */
		public static function addRemoteItemsList():void {
			var count:int = itemsXMLList.length();
			remoteItemsList.removeAll();
			
			for (var i:int;i<count;i++) {
				var item:Item = new Item(itemsXMLList[i]);
				remoteItemsList.addItem(item);
			}
			
		}
		
		/**
		 * Loads the available remote items from the preferences URL
		 * */
		public function retrieveRemoteItems():void {
			var request:URLRequest = new URLRequest(preferencesURL);
			
			loader = new URLLoader(request);
			loader.addEventListener(Event.COMPLETE, getRemoteItemsHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			
		}
		
		/**
		 * Updates the items in the 
		 * */
		public function updateSelectedItemsHandler(event:Event):void {
			
			//updateDefaultItems();
			//saveSettings();
			
			//removeEventListener(ITEMS_UPDATED, updateSelectedItemsHandler);
			//removeEventListener(ITEMS_UPDATE_FAULT, itemsUpdateFaultHandler);
		}
		
		
		/**
		 * 
		 * */
		public function itemsUpdateFaultHandler(event:Event):void {
			//removeEventListener(ITEMS_UPDATED, updateSelectedItemsHandler);
			//removeEventListener(ITEMS_UPDATE_FAULT, itemsUpdateFaultHandler);
		}
		
		/**
		 * Updates and adds remote items to all perspectives
		 * */
		public function updatedPerspectivesHandler():void {
			var perspectiveCount:int = perspectives.length;
			var currentPerspective:Perspective;
			var remoteItemsCount:int = remoteItemsList.length;
			var types:Array;
			var items:Array;
			var item:Item;
			
			for (var j:int;j<perspectiveCount;j++) {
				currentPerspective = perspectives[j];
				types = currentPerspective.types;
				currentPerspective.items = [];
				
				for (var i:int;i<remoteItemsCount;i++) {
					item = remoteItemsList.getItemAt(i) as Item;
					
					if (currentPerspective.types.indexOf(item.type)!=-1) {
						updatePerspectiveItem(currentPerspective, item, true);
					}
				}
			}
		}
		
		//----------------------------------
		//  instance
		//----------------------------------
		private static var _instance:RemoteManager;
		
		public static function get instance():RemoteManager
		{
			if (!_instance) {
				_instance = new RemoteManager(new SINGLEDOUBLE());
			}
			return _instance;
		}
		
		public static function getInstance():RemoteManager {
			return instance;
		}
	}
}


class SINGLEDOUBLE{}