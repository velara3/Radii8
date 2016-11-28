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
		 * Define icons in tools-manifest-defaults.xml
		 * */
		
		[Embed(source="assets/icons/tools/BlackArrow.png")]
		public static const BlackArrow:Class;
		
		[Embed(source="assets/icons/tools/DragStripIcon.png")]
		public static const DragStrip:Class;
		
		[Embed(source="assets/icons/tools/EyeDropper.png")]
		public static const EyeDropper:Class;
		
		[Embed(source="assets/icons/tools/EyeDropperCursor.png")]
		public static const EyeDropperCursor:Class;
		
		[Embed(source="assets/icons/tools/PointingHand.png")]
		public static const PointerHand:Class;
		
		[Embed(source="assets/icons/tools/HandPointer.png")]
		public static const Button:Class;
		
		[Embed(source="assets/icons/tools/Button32.png")]
		public static const Button32:Class;
		
		[Embed(source="assets/icons/tools/Hand.png")]
		public static const Hand:Class;
		
		[Embed(source="assets/icons/tools/HandGrab.png")]
		public static const HandGrab:Class;
		
		[Embed(source="assets/icons/tools/Launch.png")]
		public static const Launch:Class;
		
		[Embed(source="assets/icons/tools/Selection.png")]
		public static const Selection:Class;
		
		[Embed(source="assets/icons/tools/Text.png")]
		public static const Text:Class;
		
		[Embed(source="assets/icons/tools/WhiteArrow.png")]
		public static const WhiteArrow:Class;
		
		[Embed(source="assets/icons/tools/Zoom.png")]
		public static const Zoom:Class;
		
		[Embed(source="assets/icons/tools/ZoomIn.png")]
		public static const ZoomIn:Class;
		
		[Embed(source="assets/icons/tools/ZoomOut.png")]
		public static const ZoomOut:Class;
		
		
	}
}