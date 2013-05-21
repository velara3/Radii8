package {
	
	
	/**
	 * List of classes and tools to include. 
	 * 
	 * Be sure to add a reference to the RadiateReferences.
	 * */
	public class Radii8LibraryToolAssets {
		
		public function Radii8LibraryToolAssets() {
			
		}
		
		///////////////////////////////////////////////////////
		// CORE
		///////////////////////////////////////////////////////
		
		/**
		 * var xml:XML = new XML(new Radii8LibraryToolAssets.toolManifestDefaults());
		 * // get list of tool classes
		 * items = XML(xml).tool;
		 * 
		 * 
		 * Be sure to add a reference to the RadiateReferences.
		 * */
		[Embed(source="/assets/data/tools-manifest-defaults.xml", mimeType="application/octet-stream")]
		public static const toolManifestDefaults:Class;
		
		
		///////////////////////////////////////////////////////
		// ICONS
		///////////////////////////////////////////////////////
		
		[Embed(source="assets/icons/tools/BlackArrow.gif")]
		public static const BlackArrowIcon:Class;
		
		[Embed(source="assets/icons/tools/WhiteArrow.gif")]
		public static const WhiteArrowIcon:Class;
		
		[Embed(source="assets/icons/tools/dragStripIcon.png")]
		public static const DragStripIcon:Class;
		
		
		
	}
}