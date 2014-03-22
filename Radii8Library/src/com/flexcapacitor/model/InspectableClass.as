
package com.flexcapacitor.model {
	
	/**
	 * Holds data on inspector
	 * */
	public class InspectableClass {
		
		public function InspectableClass(data:XML = null) {
			
			if (data) {
				unmarshall(data);
			}
		}
		
		/**
		 * Name 
		 * */
		public var name:String;
		
		/**
		 * Name of class
		 * */
		public var className:String;
		
		/**
		 * List of inspectors
		 * */
		public var inspectors:Array = [];
		
		public function unmarshall(data:XML):InspectableClass {
			var inspectorsXMLList:XMLList;
			var inspectorXML:XML;
			var length:uint;
			var inspectorArray:uint;
			var inspectorData:InspectorData;
			
			// get list of inspectors
			// create instances
			// store in inspectors list
			
			name = data.attribute("name");
			className = data.attribute("className");
			
			inspectorsXMLList = data..inspector;
			length = inspectorsXMLList.length();
			
			for (var i:int;i<length;i++) {
				inspectorXML = inspectorsXMLList[i];
				inspectorData = new InspectorData(inspectorXML);
				inspectors.push(inspectorData);
			}
			
			return this;
		}
	}
}