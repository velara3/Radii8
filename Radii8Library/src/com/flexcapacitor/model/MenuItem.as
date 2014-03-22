
package com.flexcapacitor.model {
	import flash.events.EventDispatcher;
	
	
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

		[Bindable]
		public var enabled:Boolean = true;

		[Bindable]
		public var toggled:Boolean;
		public var name:String = null;
		public var group:String = null;
		public var parent:MenuItem = null;
		public var label:String = null;
		
		[Inspectable(category="General", enumeration="check,radio,separator")]
		public var type:String = null;
		public var icon:Object = null;

		private var _children:Array = null;
				
	    [Inspectable(category="General", arrayType="MenuItem")]
	    public function set children(c:Array):void
	    {
	    	_children = c;
	    	if (c)
		    	for (var i:int = 0; i < c.length; i++)
		    		c[i].parent = this;
	    }

		public function get children():Array
		{
			return _children;
		}
		
		// functions for manipulating children:
		
		public function addChild(child:MenuItem):void
		{
			addChildAt(child, children.length);
		}
		
		public function addChildAt(child:MenuItem, index:int):void
		{
			if (!children)
				children = [];
			
			children.splice(index, 0, child);
			child.parent = this;
		}
		
		public function getChildAt(index:int):MenuItem
		{
			return children[index];
		}
		
		public function getChildByName(name:String):MenuItem
		{
			var item:MenuItem = null;
	    	
	    	if (this.name == name)
	    		item = this;
	    	else if (children)
	    	{
	    		for (var i:int = 0; i < children.length; i++)
	    			if ((item = MenuItem(children[i]).getChildByName(name)))
	    				break;
	    	}
	    	return item;
		}
		
		public function getChildIndex(item:MenuItem):int
		{
			if (!children)
				return -1;
			
    		for (var i:int = 0; i < children.length; i++)
    		{
    			if (item == children[i])
    				return i;
    		}
    		
    		return -1;		
		}
		
		public function removeAllChildren():void
		{
			children = null;
		}
		
		public function removeChild(item:MenuItem):void
		{
			var index:int = getChildIndex(item);
			
			if (index >= 0)
				removeChildAt(index);
		}
		
		public function removeChildAt(index:int):void
		{
			if (index >= 0 && index < children.length)
				children.splice(index, 1);
			
			if (children.length == 0)
				children = null;
		}
		
		public function setChildIndex(item:MenuItem, index:int):void
		{
			var oldIndex:int = getChildIndex(item);
			
			if (oldIndex >= 0)
			{
				removeChildAt(oldIndex);
				var newIndex:int = oldIndex < index ? index - 1 : index;
				addChildAt(item, newIndex);
			}
				
		}

	    public function findItemsByGroup(group:String):Array
	    {
	    	var items:Array = [];
	    	if (this.group == group)
	    		items.push(this);
	    	
	    	if (children)
	    	{
		    	for (var i:int = 0; i < children.length; i++)
		    	{
		    		items.splice(items.length, 0, MenuItem(children[i]).findItemsByGroup(group));
		    	}
		    }
		    
		    return items;
	    }
	}
}