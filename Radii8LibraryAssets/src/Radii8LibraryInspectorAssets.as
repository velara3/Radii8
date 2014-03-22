package {

	
	/**
	 * Inspectors. Add references to RadiateReferences
	 * 
	 * To control the list of inspectors
	 * edit the /assets/data/inspectors-manifest-defaults.xml
	 * */
	public class Radii8LibraryInspectorAssets {
		
		public function Radii8LibraryInspectorAssets() {
			
		}
		
		///////////////////////////////////////////////////////
		// CORE
		///////////////////////////////////////////////////////
		
		/**
		 * var xml:XML = new XML(new Radii8LibraryInspectorAssets.inspectorsManifestDefaults());
		 * 
		 * NOTE: Add a reference to the classes here and in the XML file. 
		 * */
		[Embed(source="/assets/data/inspectors-manifest-defaults.xml", mimeType="application/octet-stream")]
		public static const inspectorsManifestDefaults:Class;
		
		
		///////////////////////////////////////////////////////
		// CONTAINERS
		///////////////////////////////////////////////////////
		
		//[Embed(source="assets/icons/containers/Accordion.png")]
		//public static const AccordionIcon:Class;
		
		//[Embed(source="assets/icons/containers/ApplicationControlBar.png")]
		//public static const ApplicationControlBarIcon:Class;
		
		//[Embed(source="assets/icons/spark/containers/BorderContainer.png")]
		//public static const BorderContainerIcon:Class;
		
		
	}
}