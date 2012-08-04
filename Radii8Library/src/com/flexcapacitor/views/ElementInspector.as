/**
 * Allows you to inspect your application at runtime. Press CMD + SHIFT + I to enable
 * It will also appear in the context menu as Inspect. This is disabled by default.
 *
 *
 *
 *
 *
 *
 *
 *
 *
 * */
package com.flexcapacitor.views {
	import com.flexcapacitor.views.ElementInspectorGroup;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.system.Capabilities;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;
	
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.managers.SystemManager;

	public class ElementInspector {
		private var systemManager:SystemManager;
		private var _currItem:InteractiveObject;
		private var _clonedEvent:MouseEvent;
		private var created:Boolean;
		private var application:Object;
		private var menuItem:ContextMenuItem = new ContextMenuItem("");

		public var enableInReleaseSWF:Boolean;

		public var enable:Boolean = true;

		public var currentTarget:Object;

		public var currentCaptureTarget:Object;

		/**
		 * A comma separated list of sites that inspector will be enabled on
		 * Default is "http://localhost"
		 * */
		public var enabledSites:String = "http://localhost";

		public var showInContextMenu:Boolean = true;

		[Bindable]
		public var menu:ContextMenu = new ContextMenu();

		public var showNewPanel:Boolean = true;
		
		private var elementInspectorWindow:ElementInspectorGroup;

		private var isDebugPlayer:Boolean;

		// assume it is debug
		private var isDebugSWF:Boolean;

		public function ElementInspector() {


			if (!enable) {
				return;
			}

			// disable in non debug swfs - NOT ENABLED 
			isDebugPlayer = flash.system.Capabilities.isDebugger;

			application = FlexGlobals.topLevelApplication;
			
			if (!application.initialized) {
				application.addEventListener(FlexEvent.APPLICATION_COMPLETE, setupMouseManager, false, 0, true);
			}
			else {
				setupMouseManager(null);
			}

		}

		// gets item mouse is over
		private function setupMouseManager(event:FlexEvent):void {
			var sites:Array = enabledSites.split(",");
			var url:String = application.url;
			var siteFound:Boolean = false;

			// search through sites specified to enable or disable inspector
			for (var i:int = 0; i < sites.length; i++) {
				if (url.indexOf(sites[i]) != -1) {
					siteFound = true;
				}
			}

			if (enabledSites == "" || enabledSites == null) {
				// return
			}

			// disable for sites not specified
			if (enabledSites!="*" && enabledSites != "" 
				&& enabledSites != null && !siteFound) {
				return;
			}


			if (!enable) {
				return;
			}
			
			// Check code https://gist.github.com/596639
			
			// disable in non debug swfs
			/*if (!enableInReleaseSWF) {
				if (!isDebugSWF) {
					return;
				}
			}*/
			
			
			application = FlexGlobals.topLevelApplication;
			application.removeEventListener(FlexEvent.APPLICATION_COMPLETE, setupMouseManager);

			if (showInContextMenu) {
				menu = new ContextMenu();
				menu.addEventListener(ContextMenuEvent.MENU_SELECT, menuSelect, false, 0, false);
				if (application.contextMenu == null) {
					application.contextMenu = menu;
					menu.hideBuiltInItems();
				}
				else {
					menu = application.contextMenu;
					menu.addEventListener(ContextMenuEvent.MENU_SELECT, menuSelect, false, 0, false);
				}
			}

			created = true;
			systemManager = application.systemManager; // should add to stage
			systemManager.addEventListener(KeyboardEvent.KEY_DOWN, keydownHandler, false, 0, true);

		}

		private function keydownHandler(event:KeyboardEvent):void {
			// 73 is I and i
			if (event.keyCode == 73) {
				if (event.ctrlKey) {
					if (event.shiftKey) {
						displayPopUp();
					}
				}
			}
		}

		private function getItemUnderMouse(event:MouseEvent):void {
			_currItem = InteractiveObject(event.target);
			_clonedEvent = MouseEvent(event);

			currentTarget = event.target;

			if (event.eventPhase == 2) {
				currentTarget = event.target;
			}
			else {
				currentCaptureTarget = event.target;
			}
		}

		public function menuSelect(event:ContextMenuEvent):void {

			if (!menuItem.hasEventListener(ContextMenuEvent.MENU_ITEM_SELECT)) {
				menuItem.caption = "Inspect";
				menuItem.separatorBefore = true;
				menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, inspectSelectedItem);
				menu.customItems.push(menuItem);
			}
		}

		public function inspectSelectedItem(event:ContextMenuEvent):void {
			//elementInspectorPanel.currentTarget = currentTarget;
			displayPopUp();
		}
		
		public function displayPopUp():void {
			if (showNewPanel) {
				if (elementInspectorWindow==null) elementInspectorWindow = new ElementInspectorGroup();
				PopUpManager.addPopUp(elementInspectorWindow, DisplayObject(FlexGlobals.topLevelApplication));
				
				PopUpManager.centerPopUp(elementInspectorWindow);
			}
			else {
				//if (elementInspectorPanel==null) elementInspectorPanel = new ElementInspectorPanel();
				//PopUpManager.addPopUp(elementInspectorPanel, DisplayObject(ApplicationUtils.getInstance()));
				//PopUpManager.centerPopUp(elementInspectorPanel);
			}
		}
	}
}