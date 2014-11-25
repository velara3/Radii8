package {
	
	
	/**
	 * List of classes and tools to include. 
	 * 
	 * Be sure to add a reference to this class in the RadiateReferences.
	 * */
	public class Radii8LibraryToolAssets {
		
		public function Radii8LibraryToolAssets() {
			
		}
		
		///////////////////////////////////////////////////////
		// CORE
		///////////////////////////////////////////////////////
		
		/**
		 * var xml:XML = new XML(new Radii8LibraryToolAssets.toolsManifestDefaults());
		 * // get list of tool classes
		 * items = XML(xml).tool;
		 * 
		 * 
		 * Be sure to add a reference to the RadiateReferences.
		 * */
		[Embed(source="/assets/data/tools-manifest-defaults.xml", mimeType="application/octet-stream")]
		public static const toolsManifestDefaults:Class;
		
		
		
		
		///////////////////////////////////////////////////////
		// ICONS
		///////////////////////////////////////////////////////
		
		/**
		 * 
		 * 
		 * ICONS ARE IN 
		 * 
		 * Radii8Library/src/assets/tools NOT HERE
		 * 
		 * Define icons in tools-manifest-defaults.xml
		 * 
		 * */
		
		
		
		[Embed(source="assets/icons/tools/BlackArrow.png")]
		public static const BlackArrowIcon:Class;
		
		[Embed(source="assets/icons/tools/WhiteArrow.png")]
		public static const WhiteArrowIcon:Class;
		
		[Embed(source="assets/icons/tools/DragStripIcon.png")]
		public static const DragStripIcon:Class;
		
		[Embed(source="assets/icons/tools/EyeDropper.png")]
		public static const EyeDropper:Class;
		
		
		
	}
}