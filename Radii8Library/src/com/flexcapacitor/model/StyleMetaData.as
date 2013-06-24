
package com.flexcapacitor.model {
	import mx.styles.IStyleClient;
	
	/**
	 * Contains information on style metadata
	 * */
	public class StyleMetaData extends MetaData {
		
		
		public function StyleMetaData(item:XML = null, target:* = null)
		{
			if (item) unmarshall(item, target);
		}
		
		
		public var inherit:Boolean;
		
		/**
		 * Set to true if style is defined on the target. 
		 * In other words the user set it in MXML or AS3 and it is not inherited.
		 * styleClient.getStyle(thisStyle)!==undefined. 
		 * */
		public var definedInline:Boolean;
		
		public var inheritedValue:*;
		
		public var nonInheritedValue:*;
		
		/**
		 * Import metadata XML Style node into this instance
		 * */
		override public function unmarshall(item:XML, target:* = null):void {
			super.unmarshall(item, target);
			
			var args:XMLList = item.arg;
			var keyName:String;
			var keyValue:String;
			
			
			for each (var arg:XML in args) {
				keyName = arg.@key;
				
				if (keyName=="inherit") {
					inherit = keyValue=="no";
					break;
				}
				
			}
			
			// this shows if it's defined at all 
			definedInline = target && target is IStyleClient && target.getStyle(name)!==undefined;
			
			if (!definedInline) {
				inheritedValue = target.getStyle(name);
				nonInheritedValue = undefined;
				value = inheritedValue;
				textValue = "" + inheritedValue;
			}
			else {
				inheritedValue = undefined; // don't know how to get this value
				nonInheritedValue = target.getStyle(name);
				value = nonInheritedValue;
				textValue = "" + nonInheritedValue;
			}
			
			
			
		}
	}
}