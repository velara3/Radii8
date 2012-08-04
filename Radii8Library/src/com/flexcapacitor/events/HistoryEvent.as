
package com.flexcapacitor.events {
	import flash.utils.Dictionary;
	
	import mx.core.UIComponent;
	import mx.effects.effectClasses.PropertyChanges;
	import mx.states.AddItems;
	
	/**
	 * Contains the information used to go forward and back in history.
	 * 
	 * This is a description value object of a history event not a dispatched Event object. 
	 * 
	 * There are three types of events, 
	 * add display object
	 * remove display object
	 * set property / style
	 * */
	public class HistoryEvent {
		
		
		public function HistoryEvent() {
			
		}
		
		/**
		 * Names of affected properties
		 * */
		public var properties:Array;
		
		/**
		 * Names of affected styles
		 * */
		public var styles:Array;
		
		/**
		 * Contains the original property changes object
		 * */
		public var propertyChanges:PropertyChanges;
		
		/**
		 * List of targets
		 * */
		public var targets:Array;
		
		/**
		 * Indicates if the property change has been reversed
		 * */
		[Bindable]
		public var reversed:Boolean;
		
		/**
		 * Description of change. 
		 * */
		public var description:String;
		
		/**
		 * Description of the action this event contains
		 * */
		[Inspectable(enumeration="addItem,removeItem,propertyChange")]
		public var action:String;
		
		/**
		 * @copy mx.states.AddItems
		 * */
		public var addItemsInstance:AddItems;
		
		/**
		 * @copy mx.states.AddItems
		 * */
		public var reverseItemsInstance:AddItems;
		
		/**
		 * @copy mx.states.AddItems.apply()
		 * */
		public var parent:UIComponent;
		
		/**
		 * Stores the parents
		 * */
		public var reverseAddItemsDictionary:Dictionary = new Dictionary();
	}
}