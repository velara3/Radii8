package {
	
	
	/**
	 * List of devices to include. 
	 * 
	 * Be sure to add a reference to the RadiateReferences.
	 * */
	public class Radii8LibraryDeviceAssets {
		
		public function Radii8LibraryDeviceAssets() {
			
		}
		
		///////////////////////////////////////////////////////
		// CORE
		///////////////////////////////////////////////////////
		
		/**
		 * var xml:XML = new XML(new Radii8LibraryDeviceAssets.devicesManifestDefaults());
		 * // get list of device items
		 * items = XML(xml).device;
		 * */
		[Embed(source="/assets/data/devices-manifest-defaults.xml", mimeType="application/octet-stream")]
		public static const devicesManifestDefaults:Class;
		
		
		///////////////////////////////////////////////////////
		// ICONS
		///////////////////////////////////////////////////////
		
		
		
		
	}
}