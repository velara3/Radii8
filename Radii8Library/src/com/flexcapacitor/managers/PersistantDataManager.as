
package com.flexcapacitor.managers {
	import com.flexcapacitor.model.Settings;
	import com.flexcapacitor.utils.SharedObjectUtils;
	
	import flash.net.SharedObject;
	
	
	/**
	 * Handles saving and loading settings data
	 * */
	public class PersistantDataManager {
		
		
		
		public function PersistantDataManager() {
			
		}
		
		public var settings:Settings;
		
		/**
		 * Get saved project
		 * */
		public function getSavedSettings():Boolean {
			var so:Object = SharedObjectUtils.getSharedObject("settings");
			
			if (so is SharedObject) {
				if (so.data && so.data is Settings) {
					settings = Settings(so.data);
				}
				else {
					settings = new Settings();
				}
			}
			else {
			}
			
			return true;
		}
	}
}