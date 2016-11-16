
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
	import com.flexcapacitor.views.inspectors.ButtonProperties;
	import com.flexcapacitor.views.inspectors.ColorPickerProperties;
	import com.flexcapacitor.views.inspectors.FontStyles;
	import com.flexcapacitor.views.inspectors.Gap;
	import com.flexcapacitor.views.inspectors.GroupAlign;
	import com.flexcapacitor.views.inspectors.GroupLayoutInspector;
	import com.flexcapacitor.views.inspectors.HyperlinkInspector;
	import com.flexcapacitor.views.inspectors.Identity;
	import com.flexcapacitor.views.inspectors.ImageProperties;
	import com.flexcapacitor.views.inspectors.Layout;
	import com.flexcapacitor.views.inspectors.LineProperties;
	import com.flexcapacitor.views.inspectors.PathProperties;
	import com.flexcapacitor.views.inspectors.RadioButtonProperties;
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
		public static var buttonInspector:com.flexcapacitor.views.inspectors.ButtonProperties;
		public static var checkboxInspector:com.flexcapacitor.views.inspectors.CheckBoxProperties;
		public static var colorPickerInspector:com.flexcapacitor.views.inspectors.ColorPickerProperties;
		public static var comboboxInspector:com.flexcapacitor.views.inspectors.ComboBoxProperties;
		public static var dropDownListInspector:com.flexcapacitor.views.inspectors.DropDownListProperties;
		public static var fontStyles:com.flexcapacitor.views.inspectors.FontStyles;
		public static var gapInspector:com.flexcapacitor.views.inspectors.Gap;
		public static var groupAlignInspector:com.flexcapacitor.views.inspectors.GroupAlign;
		public static var groupInspector:com.flexcapacitor.views.inspectors.GroupLayoutInspector;
		public static var hyperLinkInspector:com.flexcapacitor.views.inspectors.HyperlinkInspector;
		public static var identity:com.flexcapacitor.views.inspectors.Identity;
		public static var imageInspector:com.flexcapacitor.views.inspectors.ImageProperties;
		public static var layoutInspector:com.flexcapacitor.views.inspectors.Layout;
		public static var lineProperties:com.flexcapacitor.views.inspectors.LineProperties;
		public static var listProperties:com.flexcapacitor.views.inspectors.ListProperties;
		public static var radioButtonInspector:com.flexcapacitor.views.inspectors.RadioButtonProperties;
		public static var sizeInspector:com.flexcapacitor.views.Size;
		public static var sliderInspector:com.flexcapacitor.views.inspectors.SliderProperties;
		public static var stepperInspector:com.flexcapacitor.views.inspectors.StepperProperties;
		public static var styleNameInspector:com.flexcapacitor.views.inspectors.StyleNameInspector;
		public static var textInputInspector:com.flexcapacitor.views.inspectors.TextInspector;
		public static var textAreaInspector:com.flexcapacitor.views.inspectors.TextAreaInspector;
		public static var tileGroupInspector:com.flexcapacitor.views.inspectors.TileGroupProperties;
		public static var videoPlayerInspector:com.flexcapacitor.views.inspectors.VideoPlayerProperties;
		public static var pathInspector:com.flexcapacitor.views.inspectors.PathProperties;
		
		///////////////////////////////////////////////////////
		// TRANSCODER CLASSES
		///////////////////////////////////////////////////////
		
		public static var htmlExporter:com.flexcapacitor.utils.HTMLDocumentExporter;
		public static var mxmlExporter:com.flexcapacitor.utils.MXMLDocumentExporter;
		public static var androidExporter:com.flexcapacitor.utils.AndroidDocumentExporter;
		
		public static var mxmlImporter:com.flexcapacitor.utils.MXMLDocumentImporter;
		
	}
}