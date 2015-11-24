
package com.flexcapacitor.model {
	import flash.events.EventDispatcher;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	
	
	/**
	 *  Dispatched when selection changes as a result
	 *  of user interaction. 
	 *
	 *  @eventType mx.events.MenuEvent.CHANGE
	 */
	[Event(name="change", type="mx.events.MenuEvent")]
	
	/**
	 *  Dispatched when a menu item is selected. 
	 *
	 *  @eventType mx.events.MenuEvent.ITEM_CLICK
	 */
	[Event(name="itemClick", type="mx.events.MenuEvent")]
	
	/**
	 *  Dispatched when a menu or submenu is dismissed.
	 *
	 *  @eventType mx.events.MenuEvent.MENU_HIDE
	 */
	[Event(name="menuHide", type="mx.events.MenuEvent")]
	
	/**
	 *  Dispatched when a menu or submenu opens. 
	 *
	 *  @eventType mx.events.MenuEvent.MENU_SHOW
	 */
	[Event(name="menuShow", type="mx.events.MenuEvent")]
	
	/**
	 *  Dispatched when a user rolls the mouse out of a menu item.
	 *
	 *  @eventType mx.events.MenuEvent.ITEM_ROLL_OUT
	 */
	[Event(name="itemRollOut", type="mx.events.MenuEvent")]
	
	/**
	 *  Dispatched when a user rolls the mouse over a menu item.
	 *
	 *  @eventType mx.events.MenuEvent.ITEM_ROLL_OVER
	 */
	[Event(name="itemRollOver", type="mx.events.MenuEvent")]
	
	[DefaultProperty("children")]
	
	/**
	 * Holds information about the menu item
	 * */
	public class MenuItem extends EventDispatcher {
		
		/**
		 * 
		 * */
		public function MenuItem() {
		}

		/**
		 * Specifies if it is enabled
		 * */
		[Bindable]
		public var enabled:Boolean = true;

		/**
		 * Specifies if it is a toggle
		 * */
		[Bindable]
		public var toggled:Boolean;
		
		/**
		 * Name of the menu 
		 * */
		public var name:String;
		
		/**
		 * Data used for whatever you need
		 * */
		public var data:Object;
		
		/**
		 * Keyboard key equivalent.
		 * http://help.adobe.com/en_US/flex/using/WSacd9bdd0c5c09f4a-690d4877120e8b878b0-7fea.html#WSacd9bdd0c5c09f4a-690d4877120e8b878b0-7fde
		 * */
		public var keyEquivalent:String;
		
		/**
		 * Specifies if the control key needs to be pressed when using a key modifier
		 * */
		public var controlKey:Boolean;
		
		/**
		 * Specifies if the shift key needs to be pressed when using a key modifier
		 * */
		public var shiftKey:Boolean;
		
		/**
		 * Specifies if the command key needs to be pressed when using a key modifier
		 * */
		public var commandKey:Boolean;
		
		/**
		 * Specifies if the alt key needs to be pressed when using a key modifier
		 * */
		public var altKey:Boolean;
		
		/**
		 * Specifies if part of a radio like group of menu items
		 * */
		public var group:String = null;
		
		/**
		 * The parent of this menu item if this menu item is nested. If not it is null
		 * */
		public var parent:MenuItem = null;
		
		/**
		 * Label displayed in the menu
		 * */
		public var label:String = null;
		
		/**
		 * Function to override default keyboard key combinations for when on different operating systems
		 * */
		public var keyEquivalentModifiersFunction:Function;
		
		/**
		 * Specifies type of menu item if it's a checkbox, radio button, or separator
		 * Default is null. 
		 * */
		[Inspectable(category="General", enumeration="check,radio,separator")]
		public var type:String = null;
		
		/**
		 * Specifies an icon. Default is null.
		 * */
		public var icon:Object = null;

		private var _children:Array = [];
		
		/**
		 * Nested menu items. Removing requirement to see if we can 
		 * combine different types of menu items so we can 
		 * reuse the default WindowApplication Edit menu with our 
		 * menu items.
		 * */
	    //[Inspectable(category="General", arrayType="MenuItem")]
	    public function set children(value:Array):void {
	    	_children = value;
	    	
			if (value) {
		    	for (var i:int = 0; i < value.length; i++) {
		    		value[i].parent = this;
				}
			}
	    }

		/**
		 * @private
		 * */
		public function get children():Array {
			return _children;
		}
		
		/**
		 * Add a child menu item to this menu
		 * */
		public function addChild(child:MenuItem):void {
			addChildAt(child, children.length);
		}
		
		/**
		 * Add a child menu item at the specified index
		 * */
		public function addChildAt(child:MenuItem, index:int):void {
			
			if (!children) {
				children = [];
			}
			
			children.splice(index, 0, child);
			child.parent = this;
		}
		
		/**
		 * Get the child menu item at the specified index
		 * */
		public function getChildAt(index:int):MenuItem {
			return children[index];
		}
		
		/**
		 * Get child menu item by name
		 * */
		public function getChildByName(name:String):MenuItem {
			var item:MenuItem = null;
	    	
	    	if (this.name == name) {
	    		item = this;
			}
	    	else if (children) {
	    		for (var i:int;i<children.length;i++) {
	    			if ((item = MenuItem(children[i]).getChildByName(name))) {
	    				break;
					}
				}
	    	}
			
	    	return item;
		}
		
		/**
		 * Get child menu item by index
		 * */
		public function getChildIndex(item:MenuItem):int {
			if (!children) {
				return -1;
			}
			
    		for (var i:int;i<children.length;i++) {
    			if (item == children[i]) {
    				return i;
				}
    		}
    		
    		return -1;		
		}
		
		/**
		 * Remove all child menu items
		 * */
		public function removeAllChildren():void {
			children = [];
		}
		
		/**
		 * Remove child menu item
		 * */
		public function removeChild(item:MenuItem):void {
			var index:int = getChildIndex(item);
			
			if (index >= 0) {
				removeChildAt(index);
			}
		}
		
		/**
		 * Remove child menu item at specified index
		 * */
		public function removeChildAt(index:int):void {
			if (index >= 0 && index < children.length) {
				children.splice(index, 1);
			}
			
			if (children.length == 0) {
				children = [];
			}
		}
		
		/**
		 * Set child menu item index
		 * */
		public function setChildIndex(item:MenuItem, index:int):void {
			var oldIndex:int = getChildIndex(item);
			var newIndex:int;
			
			if (oldIndex >= 0) {
				removeChildAt(oldIndex);
				newIndex = oldIndex < index ? index - 1 : index;
				addChildAt(item, newIndex);
			}
				
		}

		/**
		 * Find child menu items by group
		 * */
	    public function findItemsByGroup(group:String):Array {
	    	var items:Array = [];
			
	    	if (this.group == group) {
	    		items.push(this);
			}
	    	
	    	if (children) {
		    	for (var i:int = 0; i < children.length; i++) {
		    		items.splice(items.length, 0, MenuItem(children[i]).findItemsByGroup(group));
		    	}
		    }
		    
		    return items;
	    }
		
		/*
		
		EXAMPLE OF      keyEquivalentModifiers
		
		*/
		private var isWin:Boolean;
		private var isMac:Boolean;
		
		private function init():void {
			isWin = (Capabilities.os.indexOf("Windows") >= 0);
			isMac = (Capabilities.os.indexOf("Mac OS") >= 0);
		}
		
		/**
		 * Example modifier function
		 * http://help.adobe.com/en_US/flex/using/WSacd9bdd0c5c09f4a-690d4877120e8b878b0-7fea.html#WSacd9bdd0c5c09f4a-690d4877120e8b878b0-7fde
		 * */
		private function keyEquivalentModifiers(item:Object):Array { 
			var result:Array = new Array();
			var menu:Object;
			
			//var keyEquivField:String = menu.keyEquivalentField;
			var keyEquivField:String = menu.keyEquivalentField;
			var altKeyField:String;
			var controlKeyField:String;
			var shiftKeyField:String;
			
			if (item is XML) { 
				altKeyField = "@altKey";
				controlKeyField = "@controlKey";
				shiftKeyField = "@shiftKey";
			}
			else if (item is Object) { 
				altKeyField = "altKey";
				controlKeyField = "controlKey";
				shiftKeyField = "shiftKey";
			}
			
			if (item[keyEquivField] == null || item[keyEquivField].length == 0) { 
				return result;
			}
			
			if (item[altKeyField] != null && item[altKeyField] == true) 
			{
				if (isWin)
				{
					result.push(Keyboard.ALTERNATE); 
				}
			}
			
			if (item[controlKeyField] != null && item[controlKeyField] == true) 
			{
				if (isWin)
				{
					result.push(Keyboard.CONTROL);
				}
				else if (isMac) 
				{
					result.push(Keyboard.COMMAND);
				}
			}
			
			if (item[shiftKeyField] != null && item[shiftKeyField] == true) 
			{
				result.push(Keyboard.SHIFT);
			}
			
			return result;
		}
	}
}