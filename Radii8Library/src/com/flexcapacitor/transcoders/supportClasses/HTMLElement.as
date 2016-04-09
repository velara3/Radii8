package com.flexcapacitor.transcoders.supportClasses {
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import mx.core.IVisualElement;
	
	public class HTMLElement {
		
		public function HTMLElement() {
			
		}
		
		public var name:String;
		public var id:String;
		public var hasClosingSlash:Boolean;
		public var hasOpenCloseTags:Boolean;
		public var namespaceName:String;
		public var elementName:String;
		public var styleName:String;
		public var defaultElementName:String;
		public var stylesModel:HTMLStyles;
		public var stylesStates:Array;
		private var _rightAdjacentElements:Array;

		public function get rightAdjacentElements():Array
		{
			if (_rightAdjacentElements==null) _rightAdjacentElements = [];
			return _rightAdjacentElements;
		}

		public function set rightAdjacentElements(value:Array):void
		{
			_rightAdjacentElements = value;
		}

		private var _leftAdjacentElements:Array;

		public function get leftAdjacentElements():Array
		{
			if (_leftAdjacentElements==null) _leftAdjacentElements = [];
			return _leftAdjacentElements;
		}

		public function set leftAdjacentElements(value:Array):void
		{
			_leftAdjacentElements = value;
		}

		private var _parentElements:Array;

		public function get parentElements():Array
		{
			if (_parentElements==null) _parentElements = [];
			return _parentElements;
		}

		public function set parentElements(value:Array):void
		{
			_parentElements = value;
		}

		private var _childElements:Array;

		public function get childElements():Array
		{
			if (_childElements==null) _childElements = [];
			return _childElements;
		}

		public function set childElements(value:Array):void
		{
			_childElements = value;
		}

		/**
		 * Pass in a component description to update the values in the element
		 * You usually will override this 
		 * */
		public function updateDescription(componentDescription:ComponentDescription):void {
			var componentInstance:Object;
			
			if (stylesModel==null) stylesModel = new HTMLStyles();
			
			componentInstance = componentDescription.instance;
			
			if (componentInstance==null) {
				return;
			}
			
			id = getIdentifierOrName(componentInstance);
			name = getName(componentInstance);
			styleName = getStyleName(componentInstance);
			
		}
		
		/**
		 * Get HTML element class using UIComponent stylename 
		 * */
		public function getStyleName(instance:Object):String {
			var styleName:String = styleName in instance ? instance.styleName : null;
			
			return styleName;
		}
		
		/**
		 * Gets the ID of the target object
		 * 
		 * @param name if id is not available then if the name parameter is true then use name
		 * @param appendID if id is null and name is set then returns name and value of append ID 
		 * returns id or name
		 * */
		public function getIdentifierOrName(element:Object, name:Boolean = true, appendID:String = ""):String {
			
			if (element && "id" in element && element.id) {
				return element.id + appendID;
			}
			else if (element && name && "name" in element && element.name) {
				return element.name + appendID;
			}
			
			return "";
		}
		
		/**
		 * Gets the name from the target object
		 * */
		public function getName(element:Object, appended:String = ""):String {
			
			if (element && name && "name" in element && element.name) {
				return element.name + appended;
			}
			
			return "";
		}
		
		/**
		 * Set width and height styles
		 * If explicit width is set then we should use inline-block 
		 * because inline does not respect width and height
		 * */
		public function setSizeString(instance:IVisualElement, explicitSize:Boolean = false, format:String = "px"):void {
			var hasExplicitSize:Boolean;
			var hasBorder:Boolean;
			
			// width 
			if (!isNaN(instance.percentWidth)) {
				stylesModel.width = instance.percentWidth + "%;";
			}
			else if ("explicitWidth" in instance) {
				if (Object(instance).explicitWidth!=null && !isNaN(Object(instance).explicitWidth)) {
					stylesModel.width = instance.width + format;
					hasExplicitSize = true;
				}
			}
			
			if ("explicitMinWidth" in instance) {
				if (Object(instance).explicitMinWidth!=null && !isNaN(Object(instance).explicitMinWidth)) {
					stylesModel.minWidth = Object(instance).minWidth + format;
					hasExplicitSize = true;
				}
			}
			
			if ("explicitMaxWidth" in instance) {
				if (Object(instance).explicitMaxWidth!=null && !isNaN(Object(instance).explicitMaxWidth)) {
					stylesModel.maxWidth = Object(instance).maxWidth + format;
					hasExplicitSize = true;
				}
			}
			
			// height
			if (!isNaN(instance.percentHeight)) {
				stylesModel.width = instance.percentHeight + "%";
			}
			else if ("explicitHeight" in instance) {
				if (Object(instance).explicitHeight!=null && !isNaN(Object(instance).explicitHeight)) {
					stylesModel.height = instance.height + format;
					hasExplicitSize = true;
				}
			}
			
			if ("explicitMinHeight" in instance) {
				if (Object(instance).explicitMinHeight!=null && !isNaN(Object(instance).explicitMinHeight)) {
					stylesModel.minHeight = Object(instance).minHeight + format;
					hasExplicitSize = true;
				}
			}
			
			if ("explicitMaxHeight" in instance) {
				if (Object(instance).explicitMaxHeight!=null && !isNaN(Object(instance).explicitMaxHeight)) {
					stylesModel.maxHeight = Object(instance).maxHeight + format;
					hasExplicitSize = true;
				}
			}
			
		}
		
		/**
		 * Override in sub classes
		 * */
		public function toString():String {
			return "";
		}
	}
}