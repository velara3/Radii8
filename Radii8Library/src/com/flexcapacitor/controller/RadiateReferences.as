
package com.flexcapacitor.controller {
	import com.flexcapacitor.filters.BlackAndWhiteFilter;
	import com.flexcapacitor.filters.BorderStrokeFilter;
	import com.flexcapacitor.filters.TextShadowFilter;
	import com.flexcapacitor.tools.EyeDropper;
	import com.flexcapacitor.tools.Hand;
	import com.flexcapacitor.tools.Line;
	import com.flexcapacitor.tools.Marquee;
	import com.flexcapacitor.tools.Selection;
	import com.flexcapacitor.tools.Text;
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
	import com.flexcapacitor.views.inspectors.DropShadowFilterInspector;
	import com.flexcapacitor.views.inspectors.FillStyles;
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
	import com.flexcapacitor.views.panels.FiltersInspector;
	
	import flash.display.JPEGEncoderOptions;
	import flash.display.PNGEncoderOptions;
	
	import spark.filters.BevelFilter;
	import spark.filters.BlurFilter;
	import spark.filters.ColorMatrixFilter;
	import spark.filters.ConvolutionFilter;
	import spark.filters.DisplacementMapFilter;
	import spark.filters.DropShadowFilter;
	import spark.filters.GlowFilter;
	import spark.filters.GradientBevelFilter;
	import spark.filters.GradientFilter;
	import spark.filters.GradientGlowFilter;
	import spark.filters.ShaderFilter;
	
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
		
		public static var textTool:com.flexcapacitor.tools.Text;
		
		public static var marqueeTool:com.flexcapacitor.tools.Marquee;
		public static var marqueeInspector:com.flexcapacitor.views.MarqueeInspector;
		
		public static var lineTool:com.flexcapacitor.tools.Line;
		public static var lineInspector:com.flexcapacitor.views.LineInspector;
		
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
		public static var fillInspector:com.flexcapacitor.views.inspectors.FillStyles;
		public static var strokeInspector:com.flexcapacitor.views.inspectors.StrokeStyles;
		
		// FILTERS
		public static var filterInspector:com.flexcapacitor.views.panels.FiltersInspector;
		public static var filterCallout:com.flexcapacitor.views.panels.FiltersCallout;
		
		public static var bevelFilterInspector:com.flexcapacitor.views.inspectors.BevelFilterInspector;
		public static var borderStrokeFilterInspector:com.flexcapacitor.views.inspectors.BorderStrokeFilterInspector;
		public static var blackAndWhiteFilterInspector:com.flexcapacitor.views.inspectors.BlackAndWhiteFilterInspector;
		public static var blurFilterInspector:com.flexcapacitor.views.inspectors.BlurFilterInspector;
		public static var colorMatrixFilterInspector:com.flexcapacitor.views.inspectors.ColorMatrixFilterInspector;
		public static var convolutionFilterInspector:com.flexcapacitor.views.inspectors.ConvolutionFilterInspector;
		public static var displacementFilterInspector:com.flexcapacitor.views.inspectors.DisplacementMapFilterInspector;
		public static var dropShadowFilterInspector:com.flexcapacitor.views.inspectors.DropShadowFilterInspector;
		public static var glowFilterInspector:com.flexcapacitor.views.inspectors.GlowFilterInspector;
		public static var baseDimensionsFilterInspector:com.flexcapacitor.views.inspectors.BaseDimensionFilterInspector;
		
		public static var bevelFilter:BevelFilter;
		public static var blurFilter:BlurFilter;
		public static var colorMatrixFilter:ColorMatrixFilter;
		public static var convolutionFilter:ConvolutionFilter;
		public static var displacementFilter:DisplacementMapFilter;
		public static var dropShadowFilter:DropShadowFilter;
		public static var glowFilter:GlowFilter;
		public static var gradientBevelFilter:GradientBevelFilter;
		public static var gradientFilter:GradientFilter;
		public static var gradientGlowFilter:GradientGlowFilter;
		public static var shaderFilter:ShaderFilter;
		public static var blackAndWhiteFilter:BlackAndWhiteFilter;
		public static var borderStrokeFilter:BorderStrokeFilter;
		public static var textShadowFilter:TextShadowFilter;
		
		///////////////////////////////////////////////////////
		// TRANSCODER CLASSES
		///////////////////////////////////////////////////////
		
		public static var htmlExporter:com.flexcapacitor.utils.HTMLDocumentExporter;
		public static var mxmlExporter:com.flexcapacitor.utils.MXMLDocumentExporter;
		public static var androidExporter:com.flexcapacitor.utils.AndroidDocumentExporter;
		
		public static var mxmlImporter:com.flexcapacitor.utils.MXMLDocumentImporter;
		
	}
}