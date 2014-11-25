
package com.flexcapacitor.tools {
	
	
	/**
	 * Location of images at runtime is 
	 * radii8/src/assets/images/tools
	 * 
	 * otherwise images are embedded in Radii8LibraryAssets/Radii8LibraryToolAssets.as
	 * The path is defined in Tools.mxml (should be in Radiate.as)
	 */
	public interface ITool {
		
		/**
		 * Enables the selected tool. 
		 * */
		function enable():void 
		
		/**
		 * Disables the selected tool. 
		 * */
		function disable():void 
			
		/**
		 * Embedded icon
		 * */
		function get icon():Class
	}
	
}