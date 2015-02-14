
package com.flexcapacitor.utils {
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IDocumentExporter;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	import com.flexcapacitor.views.supportClasses.Styles;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.JPEGEncoderOptions;
	import flash.display.PNGEncoderOptions;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import mx.core.IUIComponent;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.graphics.codec.JPEGEncoder;
	import mx.graphics.codec.PNGEncoder;
	import mx.styles.IStyleClient;
	import mx.utils.Base64Encoder;
	
	import spark.components.BorderContainer;
	import spark.components.HGroup;
	import spark.components.VGroup;
	import spark.components.supportClasses.GroupBase;
	import spark.layouts.BasicLayout;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.TileLayout;
	import spark.layouts.VerticalLayout;
	import spark.utils.BitmapUtil;
	
	/**
	 * Exports a document to HTML
	 * */
	public class HTMLDocumentExporter extends DocumentExporter implements IDocumentExporter {
		
		public function HTMLDocumentExporter() {
		
		}
		
		/**
		 * Version
		 */
		public var version:String = "1.0.0";
		
		/**
		 * Sets explicit size regardless if size is explicit
		 * */
		public var setExplicitSize:Boolean = true;
		
		/**
		 * Sets styles inline
		 * */
		public var useInlineStyles:Boolean;
		
		/**
		 * Name of token in the template that is replaced by the 
		 * */
		public var contentToken:String = "<!--template_content-->";
		
		/**
		 * CSS to add to 
		 * */
		public var css:String;
		
		/**
		 * Adds border box CSS 
		 * */
		public var borderBoxCSS:String;
		
		/**
		 * Show outline 
		 * */
		public var showBordersCSS:String;
		
		/**
		 * Zoom CSS
		 * */
		public var zoomCSS:String;
		
		/**
		 * Page zoom level
		 * */
		public var scaleLevel:Number;
		
		/**
		 * CSS for SVG button
		 * */
		public var buttonCSS:String;
		
		public var buttonCSS2:String;
		
		public var stylesheets:String;
		
		public var template:String;
		
		/**
		 * Creates a snapshot of the application and sets it as the background image
		 * */
		public var showScreenshotBackground:Boolean = false;
		
		/**
		 * Alpha of the background image
		 * */
		public var backgroundImageAlpha:Number = .5;
		
		/**
		 * Used to create PNG images
		 * */
		public var pngEncoder:PNGEncoder;
		
		/**
		 * Used to create JPEG images
		 * */
		public var jpegEncoder:JPEGEncoder;
		
		/**
		 * Extension of the document when exporting to a file. 
		 * */
		public var extension:String;
		
		/**
		 * Indicates when the user has typed in the text area
		 * */
		[Bindable]
		public var isCodeModifiedByUser:Boolean;
		
		/**
		 * Show borders around HTML elements
		 * */
		[Bindable]
		public var showBorders:Boolean;
		
		/**
		 * Use SVG button class
		 * */
		[Bindable]
		public var useSVGButtonClass:Boolean = true;
		
		/**
		 * Show full HTML page source
		 * */
		[Bindable]
		public var showFullHTMLPageSource:Boolean = false;
		
		/**
		 * Convert bitmap data to graphic data
		 * */
		[Bindable]
		public var createImageDataForGraphics:Boolean = false;
		
		/**
		 * Last source code
		 * */
		[Bindable]
		public var sourceCode:String;
		
		public var includePreviewCode:Boolean;
		
		public var horizontalPositions:Array = ["x","left","right","horizontalCenter"];
		public var horizontalCenterPosition:String = "horizontalCenter";
		public var verticalPositions:Array = ["y","top","bottom","verticalCenter"];
		public var verticalCenterPosition:String = "verticalCenter";
		public var sizesPositions:Array = ["width","height"];
		
		public var addZoom:Boolean;
		public var output:String = "";
		public var cssOutput:String = "";
		public var wrapInPreview:Boolean;
		
		/**
		 * URL to transparent Gif used for spacing
		 * */
		public var transparentGifURL:String = "/spacer.gif";
		
		/**
		 * 
		 * */
		public var useWrapperDivs:Boolean;
		public var showOnlyHTML:Boolean;
		public var showOnlyCSS:Boolean;
		
		/**
		 * @inheritDoc
		 * */
		public function export(iDocument:IDocument, target:ComponentDescription = null, reference:Boolean = false):* {
			var XML1:XML;
			var application:Object = iDocument ? iDocument.instance : null;
			var targetDescription:ComponentDescription;
			var componentTree:ComponentDescription;
			var zoomOutput:String;
			var xml:XML;
			
			componentTree = iDocument.componentDescription;
			cssOutput = "";
			
			// find target in display list and get it's code
			targetDescription = DisplayObjectUtils.getTargetInComponentDisplayList(target.instance, componentTree);
			
			
			if (targetDescription) {
				
				// see the top of this document on how to generate source code
				getAppliedPropertiesFromHistory(iDocument, targetDescription);
			
				if (!reference) {
					//output = getHTMLOutputString(iDocument, iDocument.componentDescription);
					
					var includePreviewCode:Boolean = true;
					var tabDepth:String = "";
					
					if (showFullHTMLPageSource) {
						tabDepth = ""; //"\t\t\t";
					}
					
					output = getHTMLOutputString(iDocument, targetDescription, true, tabDepth, includePreviewCode);
					output += "\n";
					
					var applicationContainerID:String = "applicationContainer";
					var zoomInID:String = wrapInPreview ? application.name : applicationContainerID;
					
					// not enabled at the moment - see code inspector
					if (wrapInPreview) {
						var wrapper:String = "<div id=\"" + applicationContainerID +"\" style=\"position:absolute;";
						//output += "width:" + (component.instance.width + 40) + "px;";
						wrapper += "width:100%;";
						wrapper += "height:" + (targetDescription.instance.height + 40) + "px;";
						wrapper += "background-color:#666666;\">\n" + output + "</div>";
						output = wrapper;
					}
					
					if (stylesheets) {
						output += "\n" + stylesheets;
					}
					
					var styles:String = "";
					
					if (showOnlyCSS) {
						
						// SPOT NUMBER 1
						// you have to include css options in another spot as well below
						// SEE SPOT NUMBER 2
						// refactor
						if (!useInlineStyles) {
							styles = "\n" + cssOutput;
						}
						
						if (css) {
							styles += "\n" + css;
						}
						
						if (useSVGButtonClass) {
							styles += "\n" + buttonCSS2;
						}
						
						if (showBorders) {
							styles += "\n" + showBordersCSS;
						}
						
						if (addZoom) {
							//zoomOutput = zoomCSS.replace(/IFRAME_ID/g, "#" + application.name);
							zoomOutput = zoomCSS.replace(/IFRAME_ID/g, "#" + zoomInID);
							zoomOutput = zoomOutput.replace(/ZOOM_VALUE/g, iDocument.scale);
							styles += "\n" + zoomOutput;
						}
						
						output = styles;
					}
					else if (showOnlyHTML) {
						
						if (showFullHTMLPageSource) {
							output = template.replace(contentToken, output);
						}
					}
					else {
						// THIS IS SPOT NUMBER 2
						// You have to include CSS options in another place as well
						// see spot number 1
						if (!useInlineStyles) {
							styles += "\n" + cssOutput;
						}
						
						if (css) {
							styles += "\n" + css;
						}
						
						if (useSVGButtonClass) {
							styles += "\n" + buttonCSS2;
						}
						
						if (showBorders) {
							styles += "\n" + showBordersCSS;
						}
						
						
						if (addZoom) {
							//zoomOutput = zoomCSS.replace(/IFRAME_ID/g, "#" + application.name);
							zoomOutput = zoomCSS.replace(/IFRAME_ID/g, "#" + zoomInID);
							zoomOutput = zoomOutput.replace(/ZOOM_VALUE/g, iDocument.scale);
							styles += "\n" + zoomOutput;
						}
						
						
						
						
						// add styles in style tags and add to output
						if (styles!="") {
							output += "\n" + wrapInStyleTags(styles);
						}
						
						
						
						if (showFullHTMLPageSource) {
							output = template.replace(contentToken, output);
						}
					}
					
							
					isValid = XMLUtils.isValidXML(output);
					
					if (!isValid) {
						error = XMLUtils.validationError;
						errorMessage = XMLUtils.validationErrorMessage;
					}
					else {
						error = null;
						errorMessage = null;
					}
			
					var checkValidXML:Boolean = false;
					if (checkValidXML) {
						try {
							// don't use XML for HTML output because it converts this:
							// <div ></div>
							// to this:
							// <div />
							// and that breaks the html page
							
							// we can still try it to make sure it's valid
							// we could be saving CPU cycles here?
							var time:int = getTimer();
							
							// check if valid XML
							// we could also use XMLUtils.isValid but this is also for formatting
							xml = new XML(output);
							time = getTimer() -time;
							//trace("xml validation parsing time=" + time);
							sourceCode = output;
						}
						catch (error:Error) {
							// Error #1083: The prefix "s" for element "Group" is not bound.
							// <s:Group x="93" y="128">
							//	<s:Button x="66" y="17"/>
							//</s:Group>
							time = getTimer() -time;
							//trace("xml validation parsing time with error=" + time);
							sourceCode = output;
						}
					}
					else {
						sourceCode = output;
					}
				}
				else {// this should not be here - it should be in DocumentData
					XML1 = <document />;
					XML1.@host = iDocument.host;
					XML1.@id = iDocument.id;
					XML1.@name = iDocument.name;
					XML1.@uid = iDocument.uid;
					XML1.@uri = iDocument.uri;
					output = XML1.toXMLString();
				}
			}
			
			return output;
		}
		
	
		
		/**
		 * Gets the formatted output from a component.
		 * Yes, this is a mess. It needs refactoring.  
		 * I wanted to see if I could quickly generate valid HTML 
		 * from the component tree. 
		 * 
		 * There is partial work with CSS properties objects but those are not implemented yet. 
		 * */
		public function getHTMLOutputString(iDocument:IDocument, component:ComponentDescription, addLineBreak:Boolean = false, tabs:String = "", includePreview:Boolean = false):String {
			var componentInstance:Object = component.instance;
			if (componentInstance==null) return "";
			var property:Object = component.properties;
			var componentName:String = component.name ? component.name.toLowerCase() : "";
			var htmlName:String = componentName ? componentName : "";
			var componentChild:ComponentDescription;
			var instanceName:String = componentInstance && "name" in componentInstance ? componentInstance.name : "";
			var instanceID:String = componentInstance && "id" in componentInstance ? componentInstance.id : "";
			var contentToken:String = "[child_content]";
			var styleValue:String = "position:absolute;";
			var styles:Styles = new Styles();
			var wrapperStyles:Styles = new Styles();
			var isInHorizontalLayout:Boolean;
			var isInVerticalLayout:Boolean;
			var isInBasicLayout:Boolean;
			var isInTileLayout:Boolean;
			var childContent:String = "";
			var wrapperTag:String = "";
			var centeredHorizontally:Boolean;
			var wrapperTagStyles:String = "";
			var properties:String = "";
			var outlineStyle:String;
			var output:String = "";
			var type:String = "";
			var instance:Object;
			var numElements:int;
			var index:int;
			var value:*;
			var gap:int;
			var parentVerticalAlign:String;
			
			
			// we are setting the styles in a string now
			// the next refactor should use the object so we can output to CSS
			styles.position = Styles.ABSOLUTE;
			outlineStyle = "outline:1px solid red;"; // we should enable or disable outlines via code not markup on in the export
			
			// get layout positioning
			if (component.parent && component.parent.instance is IVisualElementContainer) {
				
				if (component.parent.instance.layout is HorizontalLayout) {
					isInHorizontalLayout = true;
					styleValue = styleValue.replace("absolute", "relative");
					//styleValue += "vertical-align:middle;";
					styles.position = Styles.RELATIVE;
					index = GroupBase(component.parent.instance).getElementIndex(component.instance as IVisualElement);
					numElements = GroupBase(component.parent.instance).numElements;
					wrapperTagStyles += hasExplicitSizeSet(component.instance as IVisualElement) ? "display:inline-block;" : "display:inline;";
					wrapperStyles.display = hasExplicitSizeSet(component.instance as IVisualElement) ? Styles.INLINE_BLOCK : Styles.INLINE;
					gap = HorizontalLayout(component.parent.instance.layout).gap - 4;
					parentVerticalAlign = component.parent.instance.verticalAlign;
					wrapperTagStyles += getParentVerticalAlign(parentVerticalAlign);
					
					if (index<numElements-1 && numElements>1) {
						//wrapperTagStyles += "padding-right:" + gap + "px;";
						wrapperTagStyles += Styles.MARGIN_RIGHT+":" + gap + "px;";
						wrapperStyles.marginRight =  gap + "px";
						
					}
					
					wrapperTag = "div";
				}
				else if (component.parent.instance.layout is TileLayout) {
					//isHorizontalLayout = true;
					isInTileLayout = true;
					styleValue = styleValue.replace("absolute", "relative");
					styles.position = Styles.RELATIVE;
					index = GroupBase(component.parent.instance).getElementIndex(component.instance as IVisualElement);
					numElements = GroupBase(component.parent.instance).numElements;
					wrapperTagStyles += hasExplicitSizeSet(component.instance as IVisualElement) ? "display:inline-block;" : "display:inline;";
					wrapperStyles.display = hasExplicitSizeSet(component.instance as IVisualElement) ? Styles.INLINE_BLOCK : Styles.INLINE;
					gap = TileLayout(component.parent.instance.layout).horizontalGap - 4;
					parentVerticalAlign = component.parent.instance.verticalAlign;
					wrapperTagStyles += getParentVerticalAlign(parentVerticalAlign);
					
					if (index<numElements-1 && numElements>1) {
						//wrapperTagStyles += "padding-right:" + gap + "px;";
						// using "margin-right" because if you set a fixed width padding was not doing anything
						wrapperTagStyles += Styles.MARGIN_RIGHT+":" + gap + "px;";
						//wrapperStyles.paddingRight =  gap + "px";
						wrapperStyles.marginRight =  gap + "px";
					}
					
					wrapperTag = "div";
				}
				
				else if (component.parent.instance.layout is VerticalLayout) {
					isInVerticalLayout = true;
					styleValue = styleValue.replace("absolute", "relative");
					styles.position = Styles.RELATIVE;
					index = GroupBase(component.parent.instance).getElementIndex(component.instance as IVisualElement);
					numElements = GroupBase(component.parent.instance).numElements;
					gap = VerticalLayout(component.parent.instance.layout).gap;
					parentVerticalAlign = component.parent.instance.verticalAlign;
					wrapperTagStyles += getParentVerticalAlign(parentVerticalAlign);
					
					
					if (index<numElements-1 && numElements>1) {
						//wrapperTagStyles += "padding-bottom:" + gap + "px;";
						wrapperTagStyles += Styles.MARGIN_BOTTOM+":" + gap + "px;";
						//wrapperStyles.paddingBottom =  gap + "px";
						wrapperStyles.marginBottom =  gap + "px";
					}
					
					wrapperTag = "div";
				}
				
				else if (component.parent.instance.layout is BasicLayout) {
					isInBasicLayout = true;
					
					
					
					//styleValue = styleValue.replace("absolute", "relative");
					//styles.position = Styles.RELATIVE;
					/*index = GroupBase(component.parent.instance).getElementIndex(component.instance as IVisualElement);
					numElements = GroupBase(component.parent.instance).numElements;
					gap = BasicLayout(component.parent.instance.layout).gap;*/
					
					/*if (index<numElements-1 && numElements>1) {
						wrapperTagStyles += "padding-bottom:" + gap + "px";
					}
					
					wrapperTag = "div";*/
				}
			}
			
			// constraints take higher authority
			var isHorizontalCenterSet:Boolean;
			var isVerticalCenterSet:Boolean;
			
			// loop through assigned properties
			for (var propertyName:String in property) {
				value = property[propertyName];
				
				if (value===undefined || value==null) {
					continue;
				}
				
				
				if (verticalPositions.indexOf(propertyName)!=-1 && !isVerticalCenterSet) {
					styleValue = getVerticalPositionHTML(component.instance as IVisualElement, styles, styleValue, isInBasicLayout);
					isVerticalCenterSet = true;
				}
				else if (horizontalPositions.indexOf(propertyName)!=-1 && !isHorizontalCenterSet) {
					styleValue = getHorizontalPositionHTML(component.instance as IVisualElement, styles, styleValue, isInBasicLayout);
					isHorizontalCenterSet = true;
				}
				
			}
			
			
			if (htmlName) {
				
				// create code for element type
				if (htmlName=="application") {
					htmlName = "div";
					
					// container div
					if (includePreview) {
						/*output = "<div style=\"position:absolute;";
						//output += "width:" + (component.instance.width + 40) + "px;";
						output += "width:100%;";
						output += "height:" + (component.instance.height + 40) + "px;";
						output += "background-color:#666666;\">";*/
						output += "<div";
						//output = getNameString(component.instance, output);
						output += properties ? " " + properties : " ";
						output = getIdentifierAttribute(component.instance, output);
						styleValue = styleValue.replace("absolute", "relative");
						styles.position = Styles.ABSOLUTE;
						styleValue += "width:" + component.instance.width+ "px;";
						styleValue += "height:" + component.instance.height+ "px;";
						styleValue += "font-family:" + component.instance.getStyle("fontFamily") + ";";
						styleValue += "font-size:" + component.instance.getStyle("fontSize") + "px;";
						styleValue += "margin:0 auto;";
						styleValue += "left:8px;top:14px;";
						styleValue += "overflow:auto;";
						styleValue += "background-color:" + DisplayObjectUtils.getColorInHex(component.instance.getStyle("backgroundColor"), true) + ";";
						//output += properties ? " " : "";
						output += setStyles(component.instance, styleValue);

						
						if (showScreenshotBackground) {
							var backgroundImageID:String = "backgroundComparisonImage";
							var imageDataFormat:String = "png";//"jpeg";
							var imageData:String = getDataURI(component.instance, imageDataFormat);
							var backgroundSnapshot:String = "\n" + tabs + "\t" + "<img ";
							backgroundSnapshot += "id=\"" + backgroundImageID +"\""; 
							backgroundSnapshot += " src=\"" + imageData + "\" ";
							
							output += backgroundSnapshot;
							output += setStyles("#"+backgroundImageID, "position:absolute;opacity:"+backgroundImageAlpha+";top:0px;left:0px;", true);
							/* background-image didn't work in FF on mac. didn't test on other browsers
							//trace(imageData);
							var imageDataStyle:String = "#" + getIdentifierOrName(target) + "  {\n";
							//imageDataStyle = "\tbackground-image: url(data:image/jpeg;base64,"+imageData+");";
							imageDataStyle += "\tbackground-repeat: no-repeat;\n";
							imageDataStyle += "\tbackground-image: url(data:image/"+imageDataFormat+";base64,"+imageData+");\n}";
							styles += "\n" + imageDataStyle;*/
						}
						
						output += contentToken;
						//output += "\n </div>\n</div>";
						output += "\n</div>";
						
					}
					else {
						//output = "<div style=\"position: absolute;width:100%;height:100%;background-color:#666666;\">";
						output = "<div";
						output += properties ? " " + properties : " ";
						output = getIdentifierAttribute(component.instance, output);
						//output = getNameString(component.instance, output);
						output += properties ? " " + properties : "";
						styleValue += "width:" + component.instance.width+ "px;";
						styleValue += "height:" + component.instance.height+ "px;";
						styleValue += "border:1px solid black;";
						styleValue += "background-color:" + DisplayObjectUtils.getColorInHex(component.instance.getStyle("backgroundColor"), true) + ";";
						styleValue += isInVerticalLayout ? getDisplayBlock() : "";
						//output += properties ? " " : "";
						output += setStyles(component.instance, styleValue);
						output += contentToken;
						output += "\n</div>";
					}
				}
				
				else if (htmlName=="group" || htmlName=="vgroup") {
					htmlName = "div";
					output = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					output += "<div " + properties;
					output = getIdentifierAttribute(component.instance, output);
					output += properties ? " " : "";
					styleValue = getSizeString(component.instance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					if (componentInstance is VGroup) {
						styleValue += "text-align:" + VGroup(componentInstance).horizontalAlign + ";";
					}
					
					//styleValue += "width:" + component.instance.width+ "px;";
					//styleValue += "height:" + component.instance.height+ "px;";
					output += setStyles(component.instance, styleValue);
					output += contentToken;
					output += "\n" + tabs + "</div>";
					output += getWrapperTag(wrapperTag, true);
				}
				
				else if (htmlName=="bordercontainer") {
					htmlName = "div";
					output = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					output += "<div " + properties;
					output = getIdentifierAttribute(componentInstance, output);
					output += properties ? " " : "";
					styleValue = getSizeString(component.instance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += getBorderString(component.instance as BorderContainer);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					//styleValue += getColorString(component.instance as BorderContainer);
					//styles += component.instance as BorderContainer);
					
					output += setStyles(component.instance, styleValue);
					output += componentInstance.numElements==0? "&#160;": contentToken;
					output += "\n" + tabs + "</div>";
					output += getWrapperTag(wrapperTag, true);
					
				}
				
				else if (htmlName=="hgroup" || htmlName=="tilegroup") {
					htmlName = "div";
					output = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					output += "<div " + properties;
					output = getIdentifierAttribute(component.instance, output);
					
					//styleValue = getSizeString(component.instance as IVisualElement, styleValue);
					if (component.name=="HGroup") {
						styleValue = getWidthString(componentInstance, styleValue, isHorizontalCenterSet, isVerticalCenterSet, false);
					}
					else {
						styleValue = getWidthString(componentInstance, styleValue, isHorizontalCenterSet, isVerticalCenterSet, false);
					}
					
					styleValue = getHeightString(componentInstance, styleValue, isHorizontalCenterSet, isVerticalCenterSet, false);
					
					//var vertical:String = component.instance.getStyle("verticalAlign");
					var verticalAlign:String = component.instance.verticalAlign;
					if (componentName.toLowerCase()=="hgroup") {
						if (verticalAlign=="middle") {
							styleValue += "line-height:" + component.instance.height + "px;";
						}
					}
					if (componentInstance is HGroup) {
						styleValue += "text-align:" + HGroup(componentInstance).horizontalAlign + ";";
					}
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					output += properties ? " " : "";
					output += setStyles(component.instance, styleValue);
					output += contentToken;
					output += "\n" + tabs + "</div>";
					output += getWrapperTag(wrapperTag, true);
				}
				else if (htmlName=="button" || htmlName=="togglebutton") {
					htmlName = "button";
					output = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					output += "<input " + properties;
					output = getIdentifierAttribute(component.instance, output);
					output += " type=\"" + htmlName.toLowerCase() + "\"" ;
					output += properties ? " " + properties : "";
					styleValue = getSizeString(component.instance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					styleValue += "font-family:" + component.instance.getStyle("fontFamily") + ";";
					styleValue += "font-size:" + component.instance.getStyle("fontSize") + "px;";
					output += " value=\"" + component.instance.label + "\"";
					output += " class=\"buttonSkin\"";
					output += setStyles(component.instance, styleValue);
					
					output += getWrapperTag(wrapperTag, true);
				}
				else if (htmlName=="checkbox") {
					if (component.instance.label!="") {
						output = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
						output += "<label ";
						output = getIdentifierAttribute(component.instance, output, "_Label");
						styleValue = getSizeString(component.instance as IVisualElement, styleValue, isHorizontalCenterSet);
						styleValue += isInVerticalLayout ? getDisplayBlock() : "";
						//styleValue += "width:" + (component.instance.width + 6)+ "px;";
						//styleValue += "height:" + component.instance.height+ "px;";
						styleValue += "font-family:" + component.instance.getStyle("fontFamily") + ";";
						styleValue += "font-size:" + component.instance.getStyle("fontSize") + "px;";
						output += setStyles("#"+getIdentifierOrName(component.instance, true, "_Label"), styleValue);
						output += "<input ";
						output = getIdentifierAttribute(component.instance, output);
						output += " type=\"" + htmlName.toLowerCase() + "\" ";
						output += "/>" ;
					}
					else {
						output = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
						output += "<input " + properties;
						output = getIdentifierAttribute(component.instance, output);
						output += " type=\"" + htmlName.toLowerCase() + "\" " + properties;
						//styleValue = getSizeString(component.instance as IVisualElement, styleValue);
						output += setStyles(component.instance, styleValue);
					}
					
					if (component.instance.label!="") {
						output += " " + component.instance.label + "</label>";
					}
					
					output += getWrapperTag(wrapperTag, true);
				}
				else if (htmlName=="radiobutton") {
					htmlName = "radio";
					if (component.instance.label!="") {
						output = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
						output += "<label ";
						output = getIdentifierAttribute(component.instance, output, "_Label");
						//styleValue += "width:" + (component.instance.width + 8)+ "px;";
						//styleValue += "height:" + component.instance.height+ "px;";
						styleValue = getSizeString(component.instance as IVisualElement, styleValue, isHorizontalCenterSet);
						styleValue += isInVerticalLayout ? getDisplayBlock() : "";
						styleValue += "font-family:" + component.instance.getStyle("fontFamily") + ";";
						styleValue += "font-size:" + component.instance.getStyle("fontSize") + "px;";
						output += setStyles("#"+getIdentifierOrName(component.instance, true, "_Label"), styleValue);
						output += "<input type=\"radio\" " ;
						output = getIdentifierAttribute(component.instance, output);
						//styleValue = getSizeString(component.instance as IVisualElement, styleValue);
						output += "/>" ;
					}
					else {
						output = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
						output += "<input type=\"" + htmlName.toLowerCase() + "\" " + properties;
						output = getIdentifierAttribute(component.instance, output);
						styleValue = getSizeString(component.instance as IVisualElement, styleValue, isHorizontalCenterSet);
						styleValue += isInVerticalLayout ? getDisplayBlock() : "";
						//styleValue = getSizeString(component.instance as IVisualElement, styleValue);
						output += setStyles(component.instance, styleValue);
					}
					
					if (component.instance.label!="") {
						output += " " + component.instance.label + "</label>";
					}
					
					output += getWrapperTag(wrapperTag, true);
				}
				else if (htmlName=="textinput" || htmlName=="combobox") {
					htmlName = "input";
					output = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					output += "<input ";
					output = getIdentifierAttribute(component.instance, output);
					if (componentInstance.prompt) {
						output += "placeholder=\"" + componentInstance.prompt + "\"";
					}
					output += " type=\"input\" "  + properties;
					//styleValue += "width:" + component.instance.width+ "px;";
					//styleValue += "height:" + component.instance.height+ "px;";
					styleValue = getSizeString(component.instance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					styleValue += "font-family:" + component.instance.getStyle("fontFamily") + ";";
					styleValue += "font-size:" + component.instance.getStyle("fontSize") + "px;";
					styleValue += "padding:0;border:1px solid " + DisplayObjectUtils.getColorInHex(component.instance.getStyle("borderColor"), true) + ";";
					
					if (htmlName=="combobox") {
						output += " list=\"listdata\"";
						//<datalist id="listData">
							  //<option value="value 1">
							  //<option value="value 2">
							  //<option value="value 3">
							//</datalist> 
					}
					output += setStyles(component.instance, styleValue);
					output += getWrapperTag(wrapperTag, true);
				}
				else if (htmlName=="dropdownlist") {
					htmlName = "select";
					output = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					output += "<select ";
					output = getIdentifierAttribute(component.instance, output);
					output += " type=\"input\" "  + properties;
					//styleValue += "width:" + component.instance.width+ "px;";
					//styleValue += "height:" + component.instance.height+ "px;";
					styleValue = getSizeString(component.instance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					styleValue += "font-family:" + component.instance.getStyle("fontFamily") + ";";
					styleValue += "font-size:" + component.instance.getStyle("fontSize") + "px;";
					styleValue += "padding:0;border:1px solid " + DisplayObjectUtils.getColorInHex(component.instance.getStyle("borderColor"), true) + ";";
					
					output += setStyles(component.instance, styleValue);
					output += "</select>";
					output += getWrapperTag(wrapperTag, true);
				}
				else if (htmlName=="linkbutton") {
					htmlName = "a";
					output = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					output += "<a "  + properties;
					output = getIdentifierAttribute(component.instance, output);
					//styleValue += "width:" + component.instance.width+ "px;";
					//styleValue += "height:" + component.instance.height+ "px;";
					styleValue = getSizeString(component.instance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					styleValue += "font-family:" + component.instance.getStyle("fontFamily") + ";";
					styleValue += "font-size:" + component.instance.getStyle("fontSize") + "px;";
					//styles += getBorderString(component.instance as IStyleClient);
					
					output += properties ? " " : "";
					output += setStyles(component.instance, styleValue);
					output += component.instance.label;
					output += "</a>";
					output += getWrapperTag(wrapperTag, true);
				}
				else if (htmlName=="label") {
					htmlName = "label";
					if (useWrapperDivs) {
						output = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					}
					else {
						output = tabs;
					}
					output += "<label "  + properties;
					output = getIdentifierAttribute(component.instance, output);
					//styleValue += "width:" + component.instance.width+ "px;";
					//styleValue += "height:" + component.instance.height+ "px;";
					//styleValue = getSizeString(component.instance as IVisualElement, styleValue, isHorizontalCenterSet, isVerticalCenterSet);
					styleValue = getWidthString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet, isVerticalCenterSet);
					styleValue = getHeightString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet, isVerticalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					//styleValue += wrapperTagStyles;
					styleValue += "color:" + DisplayObjectUtils.getColorInHex(componentInstance.getStyle("color"), true) + ";";
					styleValue += "font-weight:" + componentInstance.getStyle("fontWeight") + ";";
					styleValue += "font-family:" + componentInstance.getStyle("fontFamily") + ";";
					var fontSize:Number = component.instance.getStyle("fontSize");
					var paddingFromBrowserTextEngine:Number = .34615;
					var marginTop:int = fontSize * paddingFromBrowserTextEngine * -1;
					styleValue += "font-size:" + component.instance.getStyle("fontSize") + "px;";
					styleValue += "line-height:" + parseInt(componentInstance.getStyle("lineHeight"))/100 + ";";
					styleValue += "margin-top:" + marginTop + "px;";
					//styles += getBorderString(component.instance as IStyleClient);
					
					output += properties ? " " : "";
					// remove wrapperTagStyles since we are trying to not use wrapper tags
					//output += setStyles(component.instance, styleValue+wrapperTagStyles);
					output += setStyles(component.instance, wrapperTagStyles+styleValue);
					output += component.instance.text;
					output += "</label>";
					if (useWrapperDivs) {
						output += getWrapperTag(wrapperTag, true);
					}
				}
				else if (htmlName=="image") {
					output = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					output += "<img " + properties;
					output = getIdentifierAttribute(component.instance, output);
					//styleValue += "width:" + component.instance.width+ "px;";
					//styleValue += "height:" + component.instance.height+ "px;";
					styleValue = getSizeString(component.instance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock(component.instance) : "";
					styleValue += getVisibleDisplay(component.instance);
					output += properties ? " " : "";
					
					if (component.instance.source is BitmapData && createImageDataForGraphics) {
						output += " src=\"" + getDataURI(component.instance.source, "jpeg") + "\"";
					}
					else if (component.instance.source is String) {
						output += " src=\"" + component.instance.source + "\"";
					}
					
					output += setStyles(component.instance, styleValue);
					output += getWrapperTag(wrapperTag, true);
				}
				else if (htmlName=="spacer") {
					//move to image
					// show placeholder NOT actual component
					htmlName = "div";
					if (useWrapperDivs) {
						output = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					}
					else {
						output = tabs;
					}
					output += "<div "  + properties;
					output = getIdentifierAttribute(component.instance, output);
					styleValue = getSizeString(component.instance as IVisualElement, styleValue, isHorizontalCenterSet, isVerticalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					
					output += properties ? " " : "";
					output += setStyles(component.instance, wrapperTagStyles+styleValue);
					//output += "&#160;"
					output += "</div>";
					if (useWrapperDivs) {
						output += getWrapperTag(wrapperTag, true);
					}
				}
				else {
					// show placeholder NOT actual component
					htmlName = "label";
					if (useWrapperDivs) {
						output = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					}
					else {
						output = tabs;
					}
					output += "<label "  + properties;
					output = getIdentifierAttribute(component.instance, output);
					//styleValue += "width:" + component.instance.width+ "px;";
					//styleValue += "height:" + component.instance.height+ "px;";
					styleValue = getSizeString(component.instance as IVisualElement, styleValue, isHorizontalCenterSet, isVerticalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					//styleValue += wrapperTagStyles;
					styleValue += "color:" + DisplayObjectUtils.getColorInHex(component.instance.getStyle("color"), true) + ";";
					styleValue += "font-weight:" + component.instance.getStyle("fontWeight") + ";";
					styleValue += "font-family:" + component.instance.getStyle("fontFamily") + ";";
					styleValue += "font-size:" + component.instance.getStyle("fontSize") + "px;";
					styleValue += "line-height:" + "1;";
					//styles += getBorderString(component.instance as IStyleClient);
					
					output += properties ? " " : "";
					// remove wrapperTagStyles since we are trying to not use wrapper tags
					//output += setStyles(component.instance, styleValue+wrapperTagStyles);
					output += setStyles(component.instance, wrapperTagStyles+styleValue);
					output += getIdentifierOrName(component.instance);
					output += "</label>";
					if (useWrapperDivs) {
						output += getWrapperTag(wrapperTag, true);
					}
					/*
					output = tabs + getWrapperTag(wrapperTag, false, wrapperTagStyles);
					output += "<" + htmlName.toLowerCase()  + " " + properties;
					output = getIdentifierAttribute(component.instance, output);
					styleValue = getSizeString(component.instance as IVisualElement, styleValue, isHorizontalSet);
					output += properties ? " " : "";
					output += setStyles(component.instance, styleValue);
					output += getWrapperTag(wrapperTag, true);*/
				}
				
				
				// add children
				if (component.children && component.children.length>0) {
					//output += ">\n";
					
					for (var i:int;i<component.children.length;i++) {
						componentChild = component.children[i];
						getAppliedPropertiesFromHistory(iDocument, componentChild);
						if (i>0) {
							childContent += "\n";
						}
						childContent += getHTMLOutputString(iDocument, componentChild, false, tabs + "\t");
					}
					
					output = output.replace(contentToken, "\n" + childContent);

				}
				else {
					output = output.replace(contentToken, "\n");
				}
			}
			else {
				output = "";
			}
			
			return output;
		}
		
		/**
		 * Get a tag with less than or greater than wrapped around it. 
		 * */
		private function getWrapperTag(wrapperTag:String = "", end:Boolean = false, styles:String = ""):String {
			var output:String = "";
			
			if (wrapperTag=="") return "";
			
			if (end) {
				output = "</" + wrapperTag + ">";
				return output;
			}
			
			output += "<" + wrapperTag;
			
			if (styles) {
				output += " style=\"" + styles + "\"" ;
			}
			
			output += ">";
			
			return output;
		}
		
		/**
		 * Get width and height styles
		 * If explicit width is set then we should use inline-block 
		 * because inline does not respect width and height
		 * */
		public function getSizeString(instance:IVisualElement, styleValue:String = "", isHorizontalAlignSet:Boolean = false, isVerticalSet:Boolean = false, fitToContent:Boolean = false):String {
			var hasExplicitSize:Boolean;
			var hasBorder:Boolean;
			var border:int;
			
			if (instance is IStyleClient && IStyleClient(instance).getStyle("borderWeight")) {
				
			}
			
			if (!isNaN(instance.percentWidth)) {
				styleValue += "width:" + instance.percentWidth + "%;";
			}
			else if ("explicitWidth" in instance) {
				if (Object(instance).explicitWidth!=null && !isNaN(Object(instance).explicitWidth)
					|| setExplicitSize) {
					styleValue += "width:" + instance.width + "px;";
					hasExplicitSize = true;
				}
			}
			else {
				//styleValue += "width:" + instance.width + "px;";
			}
			
			if (!isNaN(instance.percentHeight)) {
				styleValue += "height:" + instance.percentHeight + "%;";
			}
			else if ("explicitHeight" in instance) {
				if (Object(instance).explicitHeight!=null && !isNaN(Object(instance).explicitHeight)
					|| setExplicitSize) {
					styleValue += "height:" + instance.height + "px;";
					hasExplicitSize = true;
				}
			}
			else {
				//styleValue += "height:" + instance.height + "px;";
			}
			
			
			// If explicit width is set then we should use inline-block 
			// because inline does not respect width and height
			if (!isHorizontalAlignSet && hasExplicitSize) {
				styleValue += "display:" + Styles.INLINE_BLOCK + ";";
			}
			
			return styleValue;
			
		}
		
		/**
		 * Get height styles
		 * If explicit width is set then we should use inline-block 
		 * because inline does not respect width and height
		 * */
		public function getHeightString(instance:Object, styleValue:String = "", isHorizontalCenterSet:Boolean = false, isVerticalCenterSet:Boolean = false, fitToContent:Boolean = false):String {
			var hasExplicitSize:Boolean;
			
			if (fitToContent) {
				return "";
			}
			
			// percent height causes some issues - have to figure out what the deal is
			if (!isNaN(instance.percentHeight)) {
				styleValue += "height:" + instance.percentHeight + "%;";
			}
			else if ("explicitHeight" in instance) {
				if (Object(instance).explicitHeight!=null && !isNaN(Object(instance).explicitHeight)) {
					styleValue += "height:" + instance.height + "px;";
					hasExplicitSize = true;
				}
			}
			
			
			// If explicit height is set then we should use inline-block 
			// because inline does not respect width and height
			if (!isVerticalCenterSet && hasExplicitSize) {
				styleValue += "display:" + Styles.INLINE_BLOCK + ";";
			}
			
			return styleValue;
			
		}
		
		/**
		 * Get width styles
		 * If explicit width is set then we should use inline-block 
		 * because inline does not respect width and height
		 * */
		public function getWidthString(instance:Object, styleValue:String = "", isHorizontalAlignSet:Boolean = false, isVerticalSet:Boolean = false, fitToContent:Boolean = false):String {
			var hasExplicitSize:Boolean;
			
			if (fitToContent) {
				return "";
			}
			
			if (!isNaN(instance.percentWidth)) {
				styleValue += "width:" + instance.percentWidth + "%;";
			}
			else if ("explicitWidth" in instance) {
				if (Object(instance).explicitWidth!=null && !isNaN(Object(instance).explicitWidth)) {
					styleValue += "width:" + instance.width + "px;";
					hasExplicitSize = true;
				}
			}
			
			// If explicit width is set then we should use inline-block 
			// because inline does not respect width and height
			if (!isHorizontalAlignSet && hasExplicitSize) {
				styleValue += "display:" + Styles.INLINE_BLOCK + ";";
			}
			
			return styleValue;
			
		}
		
		/**
		 * Get block display
		 * */
		public function getDisplayBlock(instance:Object = null):String {
			if (instance) {
				if (!instance.visible) {
					return "display:none;";
				}
			}
			
			return "display:block;";
		}
		
		/**
		 * Get visible display
		 * */
		public function getVisibleDisplay(instance:Object = null):String {
			if (instance) {
				if (!instance.visible) {
					return "display:none;";
				}
			}
			
			return "";
		}
		
		/**
		 * Get parent vertical align display
		 * */
		public function getParentVerticalAlign(value:String = null):String {
			return value ? "vertical-align:" + value + ";" : "";
		}
		
		/**
		 * Checks if size is explicitly set
		 * If explicit width is set then we should use inline-block 
		 * because inline does not respect width and height
		 * */
		public function hasExplicitSizeSet(instance:IVisualElement):Boolean {
			
			if ("explicitWidth" in instance && Object(instance).explicitWidth!=null) {
				return true;
			}
			else if ("explicitHeight" in instance && Object(instance).explicitHeight!=null) {
				return true;
			}
			
			return false;
		}
			
		/**
		 * Get the horizontal position string for HTML
		 * */
		public function getHorizontalPositionHTML(instance:IVisualElement, propertyModel:Styles, stylesValue:String = "", isBasicLayout:Boolean = true):String {
			
			if (!isBasicLayout) return stylesValue;
			// horizontal center trumps left and x properties
			if (instance.horizontalCenter!=null) {
				stylesValue += "display:block;margin:" + instance.horizontalCenter + " auto;left:0;right:0;";
				//stylesValue = stylesValue.replace("absolute", "relative");
				
				propertyModel.display = Styles.BLOCK;
				//propertyModel.position = Styles.RELATIVE;
				propertyModel.position = Styles.ABSOLUTE;
				propertyModel.margin = instance.horizontalCenter + " auto;left:0;right:0;";
				
				return stylesValue;
			}
			else if (instance.left!=null || instance.right!=null) {
				stylesValue += instance.left!=null ? "left:" + instance.left + "px;" : "";
				stylesValue += instance.right!=null ? "right:" + instance.right + "px;" : "";
				if (instance.left!=null) propertyModel.left = instance.left + "px";
				if (instance.right!=null) propertyModel.right = instance.right + "px";
				return stylesValue;
			}
			else {
				stylesValue += "left:" + instance.x + "px;";
				propertyModel.left = instance.x + "px;";
			}
			
			return stylesValue;
		}
		
			
		/**
		 * Get the vertical position string for HTML
		 * */
		public function getVerticalPositionHTML(instance:IVisualElement, propertyModel:Styles, stylesValue:String = "", isBasicLayout:Boolean = true):String {
			
			if (!isBasicLayout) return stylesValue;
			
			if (instance.verticalCenter!=null) {
				stylesValue += "display:block;margin:" + instance.verticalCenter + " auto;";
				stylesValue = stylesValue.replace("absolute", "relative");
				
				propertyModel.display = Styles.BLOCK;
				propertyModel.position = Styles.RELATIVE;
				propertyModel.margin = instance.verticalCenter + " auto;";
				
				return stylesValue;
			}
			else if (instance.top!=null || instance.bottom!=null) {
				stylesValue += instance.top!=null ? "top:" + instance.top + "px;" : "";
				stylesValue += instance.bottom!=null ? "bottom:" + instance.bottom + "px;" : "";
				if (instance.top!=null) propertyModel.top = instance.top + "px";
				if (instance.bottom!=null) propertyModel.bottom = instance.bottom + "px";
				return stylesValue;
			}
			else {
				stylesValue += "top:" + instance.y + "px;";
				propertyModel.top = instance.y + "px;";
			}
			
			return stylesValue;
		}
		
		/**
		 * Get border and background styles of a border container
		 * */
		public function getBorderString(element:IStyleClient):String {
			var value:String = "";
			
			if (element.getStyle("backgroundAlpha")!=0) {
				value += "background-color:" + DisplayObjectUtils.getColorInHex(element.getStyle("backgroundColor"), true) + ";";
				value += "background-alpha:" + element.getStyle("backgroundAlpha") + ";";
			}
			
			if (element.getStyle("borderVisible")) {
				value += "border-width:" + element.getStyle("borderWeight") + "px;";
				value += "border-style:solid;";
				
				if (element.getStyle("borderColor")!==undefined) {
					value += "border-color:" + DisplayObjectUtils.getColorInHex(element.getStyle("borderColor"), true) + ";";
				}
			}
			
			if (element.getStyle("color")!==undefined) {
				value += "color:" + DisplayObjectUtils.getColorInHex(element.getStyle("color"), true) + ";";
			}
			
			return value;
		}
		
		/**
		 * Set styles
		 * */
		public function setStyles(component:Object, styles:String = "", singleton:Boolean = false):String {
			var out:String = ">";
			
			if (useInlineStyles) {
				return " style=\"" + styles + "\"" + (singleton?"\>":">");
			}
			else {
				var formatted:String= "\t" + styles.replace(/;/g, ";\n\t");
				
				//styles += ";";
				//cssOutput += "#" + getIdentifierOrName(component) + "  {\n\n";
				//cssOutput += "" + styles.replace(/;/g, ";\n") + "\n\n}  ";
				
				if (component is String) {
					out = component + " {\n";
				}
				else {
					out = "#" + getIdentifierOrName(component) + "  {\n";
				}
				out += formatted;
				out += "}\n\n";
				
				out = out.replace(/\t}/g, "}");
				
				cssOutput += out;
			}
			
			return (singleton?"\>":">");
		}
		
		
		/**
		 * Wrap in style tags
		 * */
		public function wrapInStyleTags(value:String):String {
			var out:String = "<style>\n" + value + "\n</style>";
			return out;
		}
		
		/**
		 * Gets the ID of the target object
		 * 
		 * @param name if id is not available then if the name parameter is true then use name
		 * 
		 * returns id or name
		 * */
		public function getIdentifierOrName(element:Object, name:Boolean = true, appendID:String = ""):String {

			if (element && "id" in element && element.id) {
				return element.id + appendID;
			}
			else if (element && name && "name" in element && element.name) {
				return element.name + appendID;
			}
			
			return "";
		}
		
		/**
		 * Get ID from ID or else name attribute
		 * */
		public function getIdentifierAttribute(instance:Object, value:String = "", appendID:String = ""):String {
			
			if (instance && "id" in instance && instance.id) {
				value += "id=\"" + instance.id + appendID + "\"";
			}
			
			else if (instance && "name" in instance && instance.name) {
				value += "id=\"" + instance.name + appendID + "\"";
			}
			
			return value;
		}
		
		/**
		 * Get name and ID attribute
		 * */
		public function getIdentifierOrNameAttribute(instance:Object, propertyValue:String = ""):String {
			
			if (instance && "id" in instance && instance.id) {
				propertyValue += "id=\"" + instance.id + "\"";
			}
			
			if (instance && "name" in instance && instance.name) {
				propertyValue += "name=\"" + instance.name + "\"";
			}
			
			return propertyValue;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function exportXML(document:IDocument, reference:Boolean = false):XML {
			return null;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function exportJSON(document:IDocument, reference:Boolean = false):JSON {
			return null;
		}
		
		/**
		 * Get data URI from object. 
		 * 
		 * Encoding to JPG took 2000ms in some cases where PNG took 200ms.
		 * I have not extensively tested this but it seems to be 10x faster
		 * than JPG. 
		 * */
		public function getDataURI(target:Object, type:String = "png"):String {
			var output:String;
			
			if (type.toLowerCase()=="jpg") {
				type = "jpeg";
			}
			
			output = "data:image/" + type + ";base64," + getBase64ImageData(target, type);
			
			return output;
		}
		
		/**
		 * Returns base64 image string.
		 * 
		 * Encoding to JPG took 2000ms in some cases where PNG took 200ms.
		 * I have not extensively tested this but it seems to be 10x faster
		 * than JPG. 
		 * 
		 * Performance: 
		 * get snapshot. time=14
		 * encode to png. time=336 // encode to jpg. time=2000
		 * encode to base 64. time=35
		 * 
		 * Don't trust these numbers. Test it yourself. First runs are always longer than previous. 
		 * 
		 * This function gets called multiple times sometimes. We may be encoding more than we have too.
		 * But is probably a bug somewhere.  
		 * */
		public function getBase64ImageData(target:Object, type:String = "png", checkCache:Boolean = false):String {
			var component:IUIComponent = target as IUIComponent;
			var bitmapData:BitmapData;
		    var byteArray:ByteArray;
		    var base64Encoder:Base64Encoder;
		    var base64Encoder2:Base64;
			var useEncoder:Boolean;
			var rectangle:Rectangle;
			var jpegEncoderOptions:JPEGEncoderOptions;
			var pngEncoderOptions:PNGEncoderOptions;
			var quality:int = 80;
			var fastCompression:Boolean = true;
			var timeEvents:Boolean = false;
			var altBase64:Boolean = true;
			var results:String;
			
			
			if (base64BitmapCache[target] && checkCache) {
				return base64BitmapCache[target];
			}
			
			if (timeEvents) {
				var time:int = getTimer();
			}
			
			if (component) {
				bitmapData = BitmapUtil.getSnapshot(component);
			}
			else if (target is DisplayObject) {
				bitmapData = DisplayObjectUtils.getBitmapDataSnapshot2(target as DisplayObject);
			}
			else if (target is BitmapData) {
				bitmapData = target as BitmapData;
			}
			else {
				return null;
			}
			
			rectangle = new Rectangle(0, 0, bitmapData.width, bitmapData.height);
			
			if (timeEvents) {
				trace ("get snapshot. time=" + (getTimer()-time));
				time = getTimer();
			}
			
			if (type=="png") {
				
				if (useEncoder) {
					if (!pngEncoder) {
						pngEncoder = new PNGEncoder();
					}
					
					byteArray = pngEncoder.encode(bitmapData);
				}
				else {
					if (!pngEncoderOptions) {
						pngEncoderOptions = new PNGEncoderOptions(fastCompression);
					}
					
					byteArray = bitmapData.encode(rectangle, pngEncoderOptions);
				}
			}
			else if (type=="jpg" || type=="jpeg") {
				
				if (useEncoder) {
					if (!jpegEncoder) {
						jpegEncoder = new JPEGEncoder();
					}
					
					byteArray = jpegEncoder.encode(bitmapData);
				}
				else {
					if (!jpegEncoderOptions) {
						jpegEncoderOptions = new JPEGEncoderOptions(quality);
					}
					
					byteArray = bitmapData.encode(rectangle, jpegEncoderOptions);
				}
			}
			else {
				// raw bitmap image data
				byteArray = bitmapData.getPixels(new Rectangle(0, 0, bitmapData.width, bitmapData.height));
			}
			
			if (timeEvents) {
				trace ("encode to " + type + ". time=" + (getTimer()-time));
				time = getTimer();
			}
			
			if (!altBase64) {
				if (!base64Encoder) {
					base64Encoder = new Base64Encoder();
				}
				
			    base64Encoder.encodeBytes(byteArray);
			
				results = base64Encoder.toString();
			}
			else {
				results = Base64.encode(byteArray);
			}
			
		    //trace(base64.toString());
			
			if (timeEvents) {
				trace ("encode to base 64. time=" + (getTimer()-time));
			}
			
			base64BitmapCache[target] = results;
			
			return results;
		}
		
		public var base64BitmapCache:Dictionary = new Dictionary(true)
	}
}