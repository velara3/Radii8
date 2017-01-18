package {
	
	
	/**
	 * List of transcoders to include. 
	 * 
	 * Be sure to add a class reference to the RadiateReferences.
	 * */
	public class Radii8LibraryTranscodersAssets {
		
		public function Radii8LibraryTranscodersAssets() {
			
		}
		
		///////////////////////////////////////////////////////
		// CORE
		///////////////////////////////////////////////////////
		
		/**
		 * var xml:XML = new XML(new Radii8LibraryTranscoderAssets.transcodersManifestDefaults());
		 * // get list of transcoders items
		 * items = XML(xml).transcoder;
		 * */
		[Embed(source="/assets/data/transcoders-manifest-defaults.xml", mimeType="application/octet-stream")]
		public static const transcodersManifestDefaults:Class;
		
		/**
		 * var xml:XML = new XML(new Radii8LibraryTranscoderAssets.sparkManifest());
		 * */
		[Embed(source="/assets/data/spark-manifest.xml", mimeType="application/octet-stream")]
		public static const sparkManifest:Class;
		
		/**
		 * var xml:XML = new XML(new Radii8LibraryTranscoderAssets.sparkManifest());
		 * */
		[Embed(source="/assets/data/mxml-manifest.xml", mimeType="application/octet-stream")]
		public static const mxmlManifest:Class;
		
		/**
		 * Basic HTML document
		 * */
		[Embed(source="/assets/templates/html/template.html", mimeType="application/octet-stream")]
		public static const basicHTMLDocument:Class;
		
		/**
		 * Reusable Basic HTML document
		 * */
		[Embed(source="/assets/templates/html/template_reusable.html", mimeType="application/octet-stream")]
		public static const basicHTMLDocumentReusable:Class;
		
		
	}
}