
package com.flexcapacitor.model {
	
	
	/**
	 * Contains information on metadata
	 * */
	public class MetaData {
		
		
		public function MetaData(item:XML = null, target:* = null)
		{
			if (item) unmarshall(item, target);
			
		}
		
		public var name:String;
		
		public var type:String;
		
		public var value:*;
		
		public var format:String;
		
		public var minValue:Number;
		
		public var maxValue:Number;
		
		public var category:String;
		
		public var defaultValue:String;
		
		public var environment:String;
		
		public var enumeration:Array;
		
		public var theme:String;
		
		public var arrayElementType:String;
		
		public var arrayType:String;
		
		public var helpPositions:Array;
		
		public var bindable:Array;
		
		public var percentProxy:Array;
		
		public var skinPart:Array;
		
		public var verbose:Boolean;
		
		/**
		 * A string representation of the value. 
		 * Empty string is empty string, null or undefined. 
		 * */
		public var textValue:String = "";
		
		/**
		 * Raw XML formatted string from describe type
		 * */
		public var raw:String;
		
		/**
		 * Class that defined this style
		 * */
		public var declaredBy:String;
		
		/**
		 * Import metadata XML node into this instance
		 * */
		public function unmarshall(item:XML, target:* = null):void {
			var args:XMLList = item.arg;
			var keyName:String;
			var keyValue:String;
			var propertyValue:*;
			
			declaredBy = item.@declaredBy;
			
			for each (var arg:XML in args) {
				keyName = arg.@key;
				keyValue = String(arg.@value);
			
						
				if (keyName=="arrayType") {
					arrayType = keyValue;
					continue;
				}
				
				else if (keyName=="category") {
					category = keyValue;
					continue;
				}
				
				else if (keyName=="defaultValue") {
					defaultValue = keyValue;
					continue;
				}
				
				if (keyName=="enumeration") {
					enumeration = keyValue.split(",");
					continue;
				}
				
				else if (keyName=="environment") {
					environment = keyValue;
					continue;
				}
		
				else if (keyName=="format") {
					format = keyValue;
					continue;
				}
				
				else if (keyName=="minValue") {
					minValue = Number(keyValue);
					continue;
				}
				
				else if (keyName=="maxValue") {
					maxValue = Number(keyValue);
					continue;
				}
				
				else if (keyName=="name") {
					name = keyValue;
					continue;
				}
			
				else if (keyName=="theme") {
					theme = keyValue;
					continue;
				}
			
				else if (keyName=="type") {
					type = keyValue;
					continue;
				}
				
				else if (keyName=="verbose") {
					verbose = keyValue=="1";
					continue;
				}
			}
			
			value = target && name in target ? target[name] : undefined;
			
			textValue = value===undefined ? "": "" + value;
			
			raw = item.toXMLString();
			
		}
	}
}