package com.flexcapacitor.utils
{
	import com.flexcapacitor.model.MetaData;
	
	import flash.filesystem.File;

	public class XMLCompare
	{
		public function XMLCompare()
		{
		}
		
		
		
		private function checkForDifferences(filePath:String = null):void {
			var mxmlFile:File;
			
			if (filePath!=null && filePath!="") {
				try {
					mxmlFile = new File(filePath);
					
					if (mxmlFile.exists && mxmlFile.modificationDate.time == lastModifiedTime) {
						return;
					}
				} catch (e:Error) {
					// might check while file is open to be written so just ignore
					// and check on the next interval;
					return;
				}
			}
			
			parseFile();
			computeChanges();
			applyChanges();
		}
		
		private function parseFile():void {
			var xml:XML = new XML(aceEditor.text);
			newDB = {};
			generatedIDCounter = 0;
			parseChildren(newDB, xml);
		}
		
		private function parseChildren(newDB:Object, parent:XML):void {
			var effectiveID:String;
			var elementAttributes:XMLList;
			var numberOfAttributes:int;
			var attributeMap:Object;
			var attributeName:String;
			var children:XMLList;
			var childNode:XML;
			var childNodeName:String;
			var numberOfChildren:int;
			var memberName:String;
			var isStateSpecific:Boolean;
			var metaData:MetaData;
			
			children = parent.children();
			numberOfChildren = children.length();
			
			for (var i:int = 0; i < numberOfChildren; i++){
				childNode = children[i];
				childNodeName = childNode.name();
				
				if (childNodeName == null) {
					continue; // saw this for CDATA children
				}
				
				// items to ignore
				if (filteredMXMLNodes[childNodeName]) {
					continue;
				}
				
				// we go deep first because that's how the Falcon compiler
				// generates IDs for tags that don't have id attributes set.
				parseChildren(newDB, childNode);
				
				// check if a class rather than property, style or event
				if (isInstance(childNodeName)) {
					if (childNode.@id.length() == 0) {
						effectiveID = "#" + generatedIDCounter++;
					}
					else {
						effectiveID = childNode.@id;
					}
					
					elementAttributes = childNode.attributes();
					numberOfAttributes = elementAttributes.length();
					
					attributeMap = {};
					newDB[effectiveID] = attributeMap;
					
					for (var j:int = 0; j < numberOfAttributes; j++) {
						attributeName = elementAttributes[j].name();
						isStateSpecific = attributeName.indexOf(".")!=-1;
						memberName = getAttributeName(attributeName);
						//metaData = ClassUtils.getMetaDataOfMember(childNodeName, memberName);
						
						//if (supportedAttributes.hasOwnProperty()) {
						//if (supportedAttributes.hasOwnProperty(getAttributeName(attributeName))) {
						attributeMap[attributeName] = childNode["@" + attributeName].toString();
						//}
					}
				}
			}
		}
		
		private function computeChanges():void {
			var newValues:Object;
			var oldValues:Object;
			var newValue:Object;
			var oldValue:Object;
			var removeList:Object;
			var attributeName:String;
			var parts:Array;
			var changeList:Object;
			var supportedAttributes:Object;
			var fullAttributeName:String;
			
			changes = {};
			removals = {};
			
			if (oldDB == null) {
				oldDB = newDB;
				return;
			}
			
			// assume set of components with ids and their ids won't change
			for (var nodeID:String in newDB) {
				newValues = newDB[nodeID];
				oldValues = oldDB[nodeID];
				
				if (oldValues==null) continue;
				
				for (fullAttributeName in newValues) {
					newValue = newValues[fullAttributeName];
					oldValue = oldValues[fullAttributeName];
					
					if (newValue != oldValue) {
						changeList = changes[nodeID];
						
						if (!changeList) {
							changeList = changes[nodeID] = {};
						}
						
						changeList[fullAttributeName] = newValue;
					}
				}
				
				// look for deletions and set value back to default value
				for (fullAttributeName in oldValues) {
					
					if (!newValues.hasOwnProperty(fullAttributeName)) {
						removeList = removals[nodeID];
						
						if (!removeList) {
							removeList = removals[nodeID] = {};
						}
						
						attributeName = fullAttributeName;
						
						if (fullAttributeName.indexOf(".") > -1) {
							parts = fullAttributeName.split(".");
							attributeName = parts[0];
						}
						
						// 
						//removeList[fullAttributeName] = supportedAttributes[attributeName];
					}
				}
				
				//supportedAttributes = ClassUtils.getMemberNames(nodeID);
			}
			
			oldDB = newDB;
		}
		
		private function applyChanges():void {
			var changedValues:Object;
			var removedValues:Object;
			var attributeName:String;
			var nodeID:String;
			
			for (nodeID in changes) {
				changedValues = changes[nodeID];
				trace("Node ID:" + nodeID);
				
				for (attributeName in changedValues) {
					trace(" - Attribute to change: " + attributeName);
					trace(" - New value: " + changedValues[attributeName]);
					//commandconnection.send("_MXMLLiveEditPluginCommands", "setValue", nodeID, attributeName, changedValues[attributeName]);
				}
			}
			
			for (nodeID in removals) {
				removedValues = removals[nodeID];
				trace(nodeID);
				
				for (attributeName in removedValues)
				{
					trace(" - Attribute removed: " + attributeName);
					//commandconnection.send("_MXMLLiveEditPluginCommands", "setValue", p, q, removedValues[q]);
				}
			}
		}
		
		// assume it is an instance if the tag name starts with a capital letter
		private function isInstance(tagName:String):Boolean {
			var hasNamespace:int = tagName.indexOf("::");
			var firstCharacter:String;
			var isCapitalLetter:Boolean;
			
			if (hasNamespace > -1) {
				tagName = tagName.substring(hasNamespace + 2);
			}
			
			firstCharacter = tagName.charAt(0);
			isCapitalLetter = firstCharacter >= "A" && firstCharacter <= "Z";
			
			return isCapitalLetter;
		}
		
		/**
		 * If it contains a period we need to set the attribute in that state if the state exists
		 * */
		private function getAttributeName(attributeName:String):String {
			var containsPeriod:int = attributeName.indexOf(".");
			
			if (containsPeriod > -1) {
				attributeName = attributeName.substring(0, containsPeriod);
			}
			
			return attributeName;
		}
		
		
		private var lastModifiedTime:Number = 0;
		private var generatedIDCounter:int = 0;
		private var newDB:Object;
		private var oldDB:Object;
		private var changes:Object;
		private var removals:Object;
		
		private var filteredMXMLNodes:Object = {
			"http://ns.adobe.com/mxml/2009::Script": 1,
			"http://ns.adobe.com/mxml/2009::Declarations": 1,
			"http://ns.adobe.com/mxml/2009::Style": 1
		}
	}
}