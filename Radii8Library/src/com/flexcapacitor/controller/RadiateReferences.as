
package com.flexcapacitor.controller {
	import com.flexcapacitor.tools.EyeDropper;
	import com.flexcapacitor.tools.Hand;
	import com.flexcapacitor.tools.Selection;
	import com.flexcapacitor.tools.Zoom;
	import com.flexcapacitor.utils.HTMLDocumentExporter;
	import com.flexcapacitor.utils.MXMLDocumentImporter;
	import com.flexcapacitor.views.EyeDropperInspector;
	import com.flexcapacitor.views.SelectionInspector;
	import com.flexcapacitor.views.Size;
	import com.flexcapacitor.views.ZoomInspector;
	import com.flexcapacitor.views.inspectors.BasicBackgroundStyles;
	import com.flexcapacitor.views.inspectors.BorderStyles;
	import com.flexcapacitor.views.inspectors.Button;
	import com.flexcapacitor.views.inspectors.FontStyles;
	import com.flexcapacitor.views.inspectors.Gap;
	import com.flexcapacitor.views.inspectors.GroupAlign;
	import com.flexcapacitor.views.inspectors.GroupLayoutInspector;
	import com.flexcapacitor.views.inspectors.HyperLink;
	import com.flexcapacitor.views.inspectors.Identity;
	import com.flexcapacitor.views.inspectors.ImageProperties;
	import com.flexcapacitor.views.inspectors.Layout;
	import com.flexcapacitor.views.inspectors.LineProperties;
	import com.flexcapacitor.views.inspectors.StyleNameInspector;
	import com.flexcapacitor.views.inspectors.TextInspector;
	import com.flexcapacitor.views.inspectors.VideoPlayerProperties;
	
	import flash.display.JPEGEncoderOptions;
	import flash.display.PNGEncoderOptions;
	
	/**
	 * Create references so classes are included. 
	 * */
	public class RadiateReferences {
		
		
		public function RadiateReferences()
		{
			
		}
		
		///////////////////////////////////////////////////////
		// ENCODING OPTIONS - We get errors if not included
		///////////////////////////////////////////////////////
		
		public static var jpegEncoderOptions:JPEGEncoderOptions;
		public static var pngEncoderOptions:PNGEncoderOptions;
		
		///////////////////////////////////////////////////////
		// TOOLS CLASSES
		///////////////////////////////////////////////////////
		
		public static var selectionTool:com.flexcapacitor.tools.Selection;
		public static var selectionInspector:com.flexcapacitor.views.SelectionInspector;
		
		public static var zoomTool:com.flexcapacitor.tools.Zoom;
		public static var zoomInspector:com.flexcapacitor.views.ZoomInspector;
		
		public static var eyeDropperTool:com.flexcapacitor.tools.EyeDropper;
		public static var eyeDropperInspector:com.flexcapacitor.views.EyeDropperInspector;
		
		public static var handTool:com.flexcapacitor.tools.Hand;
		public static var handInspector:com.flexcapacitor.views.HandInspector;
		
		///////////////////////////////////////////////////////
		// TOOLS CLASSES
		///////////////////////////////////////////////////////
		
		public static var basicBackgroundInspector:com.flexcapacitor.views.inspectors.BasicBackgroundStyles;
		public static var borderStyles:com.flexcapacitor.views.inspectors.BorderStyles;
		public static var buttonInspector:com.flexcapacitor.views.inspectors.Button;
		public static var fontStyles:com.flexcapacitor.views.inspectors.FontStyles;
		public static var gapInspector:com.flexcapacitor.views.inspectors.Gap;
		public static var groupAlignInspector:com.flexcapacitor.views.inspectors.GroupAlign;
		public static var groupInspector:com.flexcapacitor.views.inspectors.GroupLayoutInspector;
		public static var hyperLinkInspector:com.flexcapacitor.views.inspectors.HyperLink;
		public static var identity:com.flexcapacitor.views.inspectors.Identity;
		public static var imageInspector:com.flexcapacitor.views.inspectors.ImageProperties;
		public static var layoutInspector:com.flexcapacitor.views.inspectors.Layout;
		public static var lineProperties:com.flexcapacitor.views.inspectors.LineProperties;
		public static var size:com.flexcapacitor.views.Size;
		public static var styleNameInspector:com.flexcapacitor.views.inspectors.StyleNameInspector;
		public static var textInspector:com.flexcapacitor.views.inspectors.TextInspector;
		public static var videoPlayerInspector:com.flexcapacitor.views.inspectors.VideoPlayerProperties;
		
		///////////////////////////////////////////////////////
		// TRANSCODER CLASSES
		///////////////////////////////////////////////////////
		
		public static var htmlExporter:com.flexcapacitor.utils.HTMLDocumentExporter;
		public static var mxmlExporter:com.flexcapacitor.utils.MXMLDocumentExporter;
		public static var androidExporter:com.flexcapacitor.utils.AndroidDocumentExporter;
		
		public static var mxmlImporter:com.flexcapacitor.utils.MXMLDocumentImporter;
		
	}
}