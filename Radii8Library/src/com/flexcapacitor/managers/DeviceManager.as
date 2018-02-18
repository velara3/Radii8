package com.flexcapacitor.managers {
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.model.Device;
	
	public class DeviceManager {
		
		public function DeviceManager() {
			
		}
		
		/**
		 * Creates the list of devices.
		 * */
		public static function createDevicesList(xml:XML):void {
			var includeItem:Boolean;
			var items:XMLList;
			var numberOfItems:uint;
			var name:String;
			var item:XML;
			var device:Device;
			var type:String;
			
			const RES_WIDTH:String = "resolutionWidth";
			const RES_HEIGHT:String = "resolutionHeight";
			const USABLE_WIDTH_PORTRAIT:String = "usableWidthPortrait";
			const USABLE_HEIGHT_PORTRAIT:String = "usableHeightPortrait";
			const USABLE_WIDTH_LANDSCAPE:String = "usableWidthLandscape";
			const USABLE_HEIGHT_LANDSCAPE:String = "usableHeightLandscape";
			
			
			// get list of device classes 
			items = XML(xml).size;
			
			numberOfItems = items.length();
			
			for (var i:int;i<numberOfItems;i++) {
				item = items[i];
				
				name = item.attribute("name");
				type = item.attribute("type");
				
				device = new Device();
				device.name = name;
				device.type = type;
				
				if (type=="device") {
					device.ppi 					= item.attribute("ppi");
					
					device.resolutionWidth 		= item.attribute(RES_WIDTH);
					device.resolutionHeight 	= item.attribute(RES_HEIGHT);
					device.usableWidthPortrait 	= item.attribute(USABLE_WIDTH_PORTRAIT);
					device.usableHeightPortrait = item.attribute(USABLE_HEIGHT_PORTRAIT);
					device.usableWidthLandscape = item.attribute(USABLE_WIDTH_LANDSCAPE);
					device.usableHeightLandscape = item.attribute(USABLE_HEIGHT_LANDSCAPE);
				}
				else if (type=="screen") {
					device.ppi 					= item.attribute("ppi");
					device.resolutionWidth 		= item.attribute(RES_WIDTH);
					device.resolutionHeight 	= item.attribute(RES_HEIGHT);
					continue;
				}
				
				includeItem = item.attribute("include")=="false" ? false : true;
				
				Radiate.deviceCollections.addItem(device);
				
			}
			
			// deviceDescriptions should now be populated
		}
	}
}