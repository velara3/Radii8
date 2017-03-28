package {
	import com.flexcapacitor.controls.ColorPicker;
	import com.flexcapacitor.controls.HorizontalLine;
	import com.flexcapacitor.controls.Hyperlink;
	import com.flexcapacitor.controls.VerticalLine;
	
	import mx.containers.Canvas;
	import mx.containers.HDividedBox;
	import mx.containers.VDividedBox;
	import mx.controls.LinkButton;
	import mx.controls.Tree;
	import mx.graphics.LinearGradient;
	import mx.graphics.RadialGradient;
	import mx.graphics.RadialGradientStroke;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	import mx.skins.spark.ColorPickerSkin;
	import mx.skins.spark.LinkButtonSkin;
	
	import spark.components.BorderContainer;
	import spark.components.ButtonBar;
	import spark.components.Grid;
	import spark.components.RadioButton;
	import spark.components.RichEditableText;
	import spark.components.RichText;
	import spark.components.TabBar;
	import spark.components.TileGroup;
	import spark.components.ToggleButton;
	import spark.primitives.BitmapImage;
	import spark.primitives.Ellipse;
	import spark.primitives.Graphic;
	import spark.primitives.Line;
	import spark.primitives.Path;
	import spark.primitives.Rect;
	import spark.skins.spark.BorderContainerSkin;
	import spark.skins.spark.ButtonBarSkin;
	import spark.skins.spark.DefaultGridItemRenderer;
	import spark.skins.spark.RadioButtonSkin;
	import spark.skins.spark.TabBarSkin;
	import spark.skins.spark.ToggleButtonSkin;
	
	/**
	 * Classes, skins and icons. 
	 * 
	 * To control the list of what shows up in the component inspector  
	 * edit the /assets/data/components-manifest-defaults.xml
	 * 
	 * 
	 * Warning 1110: The constant was not initialized.
	 * public static const colorPicker:ColorPicker;
	 * Answer: 
	 * public static var colorPicker:ColorPicker;
	 * */
	public class Radii8LibrarySparkAssets {
		
		public function Radii8LibrarySparkAssets() {
			
		}
		
		///////////////////////////////////////////////////////
		// CORE
		///////////////////////////////////////////////////////
		
		/**
		 * var xml:XML = new XML(new Radii8LibrarySparkAssets.componentsManifestDefaults());
		 * // get list of component classes
		 * items = XML(xml).component;
		 * 
		 * NOTE: Add a reference to the classes here and in the XML file. 
		 * */
		[Embed(source="/assets/data/components-manifest-defaults.xml", mimeType="application/octet-stream")]
		public static const componentsManifestDefaults:Class;
		
		
		///////////////////////////////////////////////////////
		// CONTAINERS
		///////////////////////////////////////////////////////
		
		//[Embed(source="assets/icons/containers/Accordion.png")]
		//public static const AccordionIcon:Class;
		
		//[Embed(source="assets/icons/containers/ApplicationControlBar.png")]
		//public static const ApplicationControlBarIcon:Class;
		
		[Embed(source="assets/icons/spark/containers/BorderContainer.png")]
		public static const BorderContainerIcon:Class;
		
		public static var borderContainer:BorderContainer;
		public static var borderContainerSkin:BorderContainerSkin;
		
		//[Embed(source="assets/icons/containers/Box.png")]
		//public static const BoxIcon:Class;
		
		//[Embed(source="assets/icons/containers/Canvas.png")]
		//public static const CanvasIcon:Class;
		
		//[Embed(source="assets/icons/containers/ControlBar.png")]
		//public static const ControlBarIcon:Class;
		
		[Embed(source="assets/icons/spark/containers/DataGroup.png")]
		public static const DataGroupIcon:Class;
		
		//[Embed(source="assets/icons/spark/containers/DividedBox.png")]
		//public static const DividedBoxIcon:Class;
		
		[Embed(source="assets/icons/spark/containers/Form.png")]
		public static const FormIcon:Class;
		
		[Embed(source="assets/icons/spark/containers/FormHeading.png")]
		public static const FormHeadingIcon:Class;
		
		//[Embed(source="assets/icons/spark/containers/FormItem.png")]
		//public static var FormItemIcon:Class;
		
		[Embed(source="assets/icons/spark/containers/DataGroup.png")]
		public static const Grid:Class;
		public static var grid:spark.components.Grid;
		public static var defaultGridItemRenderer:spark.skins.spark.DefaultGridItemRenderer;
		//public static var gridColumn:GridColumn;
		
		[Embed(source="assets/icons/spark/containers/GridColumnHeaderGroup.png")]
		public static const GridColumnHeaderGroupIcon:Class;
		
		[Embed(source="assets/icons/spark/containers/Group.png")]
		public static const GroupIcon:Class;
		
		[Embed(source="assets/icons/spark/containers/HGroup.png")]
		public static const HGroupIcon:Class;
		
		//[Embed(source="assets/icons/spark/containers/HDividedBox.png")]
		//public static const HDividedBoxIcon:Class;
		
		[Embed(source="assets/icons/spark/containers/Panel.png")]
		public static const PanelIcon:Class;
		
		[Embed(source="assets/icons/spark/containers/SkinnableContainer.png")]
		public static const SkinnableContainerIcon:Class;
		
		[Embed(source="assets/icons/spark/containers/SkinnableDataContainer.png")]
		public static const SkinnableDataContainerIcon:Class;
		
		//[Embed(source="assets/icons/spark/containers/TabNavigator.png")]
		//public static const TabNavigatorIcon:Class;
		
		[Embed(source="assets/icons/spark/containers/TileGroup.png")]
		public static const TileGroupIcon:Class;
		public static var tileGroup:TileGroup;
		
		//[Embed(source="assets/icons/spark/containers/TitleWindow.png")]
		//public static const TitleWindowIcon:Class;
		
		//[Embed(source="assets/icons/spark/containers/TabNavigator.png")]
		//public static const TabNavigatorIcon:Class;
		
		[Embed(source="assets/icons/spark/containers/VGroup.png")]
		public static const VGroupIcon:Class;
		
		//[Embed(source="assets/icons/spark/containers/VDividedBox.png")]
		//public static const VDividedBoxIcon:Class;
		
		//[Embed(source="assets/icons/spark/containers/ViewStack.png")]
		//public static const ViewStackIcon:Class;
		
		
		///////////////////////////////////////////////////////
		// CONTROLS
		///////////////////////////////////////////////////////
		[Embed(source="assets/icons/spark/controls/Link.png")]
		public static const LinkIcon:Class;
		public static var link:Hyperlink;
		
		[Embed(source="assets/icons/spark/controls/Image.png")]
		public static const BitmapImageIcon:Class;
		public static var bitmapImage:BitmapImage;
		
		[Embed(source="assets/icons/spark/controls/ButtonBar.png")]
		public static const ButtonIcon:Class;
		
		[Embed(source="assets/icons/spark/controls/Button.png")]
		public static const ButtonBarIcon:Class;
		public static var buttonBar:ButtonBar;
		public static var buttonBarSkin:ButtonBarSkin;
		
		[Embed(source="assets/icons/spark/controls/CheckBox.png")]
		public static const CheckBoxIcon:Class;
		
		//[Embed(source="assets/icons/spark/controls/ColorPicker.png")]
		//public static const ColorPickerIcon:Class;
		
		[Embed(source="assets/icons/mx/controls/ColorPicker.png")]
		public static const ColorPickerIcon:Class;
		
		public static var colorPicker:ColorPicker;
		public static var colorPickerSkin:ColorPickerSkin;
		
		[Embed(source="assets/icons/spark/controls/ComboBox.png")]
		public static const ComboBoxIcon:Class;
		
		[Embed(source="assets/icons/spark/controls/DataGrid.png")]
		public static const DataGridIcon:Class;
		
		[Embed(source="assets/icons/spark/controls/DropDownList.png")]
		public static const DropDownListIcon:Class;
		
		//[Embed(source="assets/icons/spark/controls/DateChooser.png")]
		//public static const DateChooserIcon:Class;
		
		//[Embed(source="assets/icons/spark/controls/DateField.png")]
		//public static const DateFieldIcon:Class;
		
		//[Embed(source="assets/icons/spark/controls/HorizontalList.png")]
		//public static const HorizontalListIcon:Class;
		
		[Embed(source="assets/icons/spark/controls/HRule.png")]
		public static const HRuleIcon:Class;
		public static var horizontalLine:HorizontalLine;		
		
		[Embed(source="assets/icons/spark/controls/HScrollBar.png")]
		public static const HScrollBarIcon:Class;
		
		[Embed(source="assets/icons/spark/controls/HSlider.png")]
		public static const HSliderIcon:Class;
		
		[Embed(source="assets/icons/spark/controls/Image.png")]
		public static const ImageIcon:Class;
		
		[Embed(source="assets/icons/spark/controls/Label.png")]
		public static const LabelIcon:Class;
		
		//Embed(source="assets/icons/spark/controls/LinkBar.png")]
		//public static const LinkBarIcon:Class;
		
		[Embed(source="assets/icons/spark/controls/Hyperlink.png")]
		public static const HyperlinkIcon:Class;
		public static var hyperlink:Hyperlink;
		
		[Embed(source="assets/icons/mx/controls/LinkButton.png")]
		public static const LinkButtonIcon:Class;
		public static var linkButton:LinkButton;
		public static var linkButtonSkin:LinkButtonSkin;
		
		[Embed(source="assets/icons/spark/controls/List.png")]
		public static const ListIcon:Class;
		
		//[Embed(source="assets/icons/spark/controls/Menu.png")]
		//public static const MenuIcon:Class;
		
		//[Embed(source="assets/icons/spark/controls/MenuBar.png")]
		//public static const MenuBarIcon:Class;
		
		[Embed(source="assets/icons/spark/controls/NumericStepper.png")]
		public static const NumericStepperIcon:Class;
		
		//[Embed(source="assets/icons/spark/controls/ProgressBar.png")]
		//public static const ProgressBarIcon:Class;
		
		[Embed(source="assets/icons/spark/controls/RadioButton.png")]
		public static const RadioButtonIcon:Class;
		public static var radioButton:RadioButton;
		public static var radioButtonSkin:RadioButtonSkin;
		
		[Embed(source="assets/icons/spark/controls/RadioButtonGroup.png")]
		public static const RadioButtonGroupIcon:Class;
		
		[Embed(source="assets/icons/spark/controls/RichEditableText.png")]
		public static const RichEditableTextIcon:Class;
		public static var richEditableTextIcon:RichEditableText;
		
		[Embed(source="assets/icons/spark/controls/RichText.png")]
		public static const RichTextIcon:Class;
		public static var richText:RichText;
		
		[Embed(source="assets/icons/spark/controls/Scroller.png")]
		public static const ScrollerIcon:Class;
		
		//[Embed(source="assets/icons/spark/controls/Spacer.png")]
		//public static const SpacerIcon:Class;
		
		[Embed(source="assets/icons/spark/controls/Spinner.png")]
		public static const SpinnerIcon:Class;
		
		//[Embed(source="assets/icons/spark/controls/SWFLoader.png")]
		//public static const SWFLoaderIcon:Class;
		
		[Embed(source="assets/icons/spark/controls/TabBar.png")]
		public static const TabBarIcon:Class;
		public static var tabBar:TabBar;
		public static var tabBarSkin:TabBarSkin;
		
		//[Embed(source="assets/icons/spark/controls/Text.png")]
		//public static const TextIcon:Class;
		
		[Embed(source="assets/icons/spark/controls/TextArea.png")]
		public static const TextAreaIcon:Class;
		
		[Embed(source="assets/icons/spark/controls/TextInput.png")]
		public static const TextInputIcon:Class;
		
		//[Embed(source="assets/icons/spark/controls/TileList.png")]
		//public static const TileListIcon:Class;
		
		[Embed(source="assets/icons/spark/controls/TitleWindow.png")]
		public static const TitleWindowIcon:Class;
		
		//[Embed(source="assets/icons/spark/controls/Tree.png")]
		//public static const TreeIcon:Class;
		
		[Embed(source="assets/icons/spark/controls/ToggleButton.png")]
		public static const ToggleButtonIcon:Class;
		public static var toggleButton:ToggleButton;
		public static var toggleButtonSkin:ToggleButtonSkin;
		
		[Embed(source="assets/icons/spark/controls/VideoDisplay.png")]
		public static const VideoDisplayIcon:Class;
		
		[Embed(source="assets/icons/spark/controls/VRule.png")]
		public static const VRuleIcon:Class;
		public static var verticalLine:VerticalLine;
		
		[Embed(source="assets/icons/spark/controls/VScrollBar.png")]
		public static const VScrollBarIcon:Class;
		
		[Embed(source="assets/icons/spark/controls/VSlider.png")]
		public static const VSliderIcon:Class;
		
		/**
		 * Common MX classes
		 * */
		public static var hDividedBox:HDividedBox;
		public static var vDividedBox:VDividedBox;
		public static var canvas:Canvas;
		public static var tree:Tree;
		
		
		///////////////////////////////////////////////////////
		// GRAPHIC PRIMITIVES
		///////////////////////////////////////////////////////
		
		// 1110: The constant was not initialized.
		// - change const to var
		//public static const rect:Rect;
		
		[Embed(source="assets/icons/spark/controls/Path.png")]
		public static const PathIcon:Class;
		[Embed(source="assets/icons/spark/controls/Rect.png")]
		public static const RectIcon:Class;
		[Embed(source="assets/icons/spark/controls/Ellipse.png")]
		public static const EllipseIcon:Class;
		[Embed(source="assets/icons/spark/controls/Line.png")]
		public static const LineIcon:Class;
		
		public static var rect:Rect;
		public static var ellipse:Ellipse;
		public static var path:Path;
		public static var line:Line;
		public static var solidColorFill:SolidColor;
		public static var linearGradientFill:LinearGradient;
		public static var radialGradientFill:RadialGradient;
		public static var solidColorStroke:SolidColorStroke;
		public static var radialGradientStroke:RadialGradientStroke;
		public static var graphic:Graphic;
	}
}