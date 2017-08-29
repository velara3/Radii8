
package com.flexcapacitor.utils {
	import com.flexcapacitor.model.ConstrainedLocations;
	import com.flexcapacitor.model.Document;
	import com.flexcapacitor.model.ErrorData;
	import com.flexcapacitor.model.ExportOptions;
	import com.flexcapacitor.model.FileInfo;
	import com.flexcapacitor.model.HTMLExportOptions;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IDocumentExporter;
	import com.flexcapacitor.model.IssueData;
	import com.flexcapacitor.model.SourceData;
	import com.flexcapacitor.transcoders.supportClasses.HTMLElement;
	import com.flexcapacitor.transcoders.supportClasses.HTMLLineBreak;
	import com.flexcapacitor.transcoders.supportClasses.HTMLMargin;
	import com.flexcapacitor.transcoders.supportClasses.HTMLStyles;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	import com.flexcapacitor.utils.supportClasses.XMLValidationInfo;
	
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.ScrollPolicy;
	import mx.core.mx_internal;
	import mx.graphics.GradientBase;
	import mx.graphics.GradientEntry;
	import mx.graphics.IFill;
	import mx.graphics.LinearGradient;
	import mx.graphics.RadialGradient;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	import mx.styles.IStyleClient;
	import mx.utils.NameUtil;
	
	import spark.components.BorderContainer;
	import spark.components.HGroup;
	import spark.components.NumericStepper;
	import spark.components.TextArea;
	import spark.components.VGroup;
	import spark.components.supportClasses.GroupBase;
	import spark.components.supportClasses.ListBase;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.layouts.BasicLayout;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.TileLayout;
	import spark.layouts.VerticalLayout;
	import spark.layouts.supportClasses.LayoutBase;
	import spark.primitives.Ellipse;
	import spark.primitives.Line;
	import spark.primitives.Path;
	import spark.primitives.Rect;
	import spark.primitives.supportClasses.FilledElement;
	import spark.primitives.supportClasses.GraphicElement;
	import spark.primitives.supportClasses.StrokedElement;
	
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	
	use namespace mx_internal;
	
	/**
	 * Exports a document to HTML<br/><br/>
	 * 
	 * Recommendations for compatibility: <br/>
	 * http://www.w3.org/TR/xhtml-media-types/#C_2
	 * 
	 * Performance considerations: 
	 * http://www.webperformancetoday.com/2012/05/29/browser-innovation-14-web-performance-rules-faster-loading-websites/
	 * 
	 * */
	public class HTMLDocumentExporter extends DocumentTranscoder implements IDocumentExporter {
		
		public function HTMLDocumentExporter() {
			supportsExport = true;
			language = "HTML";
		}
		
		/**
		 * Sets explicit size regardless if size is explicit
		 * */
		public var setExplicitSize:Boolean = false;
		
		/**
		 * Sets styles inline
		 * */
		public var useInlineStyles:Boolean;
		
		/**
		 * For label components uses a span element instead of label element
		 * */
		public var useSpanTagForLabels:Boolean = true;
		
		/**
		 * Styles added by users 
		 * */
		public var userStyles:String;
		
		/**
		 * Border box CSS
		 * cause all padding and borders to be inside width and height 
		 * http://www.paulirish.com/2012/box-sizing-border-box-ftw/
		 * */
		public var borderBoxCSS:String = "*, *:before, *:after {\n\t-moz-box-sizing:border-box;\n\t-webkit-box-sizing:border-box;\n\tbox-sizing:border-box;\n\tmargin:0;\n\tpadding:0;\n}";
		
		/**
		 * Content token
		 * */
		public var defaultContentToken:String = "[child_content]";
		
		/**
		 * Use better HTML
		 * */
		public var useBetterHTML:Boolean = true;
		
		/**
		 * Some defaults that make the html look more accurate
		 * */
		public var betterHTML:String = "html, body {\n\twidth:100%;\n\theight:100%;\n\tmargin:0;\n\tpadding:0;\n}";
		
		/**
		 * Show outline around each element
		 * */
		public var bordersCSS:String = "*,*:before,*:after {outline:1px dotted red;}";
		
		/**
		 * Zoom CSS
		 * */
		public var zoomCSS:String;
		
		/**
		 * Substitute image data for light weight gray pixel
		 * */
		public var embedPlaceholderImageData:Boolean = false;
		
		/**
		 * Image data for 1x1 gray pixel. Used as placeholder string so 
		 * image data is not using all the screen real estate in text editors
		 * */
		public var embeddedImagePlaceholderData:String = "data:" + "image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4AWP49u3bfwAJqgPikU+0iAAAAABJRU5ErkJggg==";
		
		/**
		 * Page zoom level
		 * */
		public var scaleLevel:Number;
		
		/**
		 * CSS for SVG button
		 * */
		public var buttonCSS:String;
		
		public var buttonCSS2:String = "";
		
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
		 * Extension of the document when exporting to a file. 
		 * */
		public var extension:String;
		
		/**
		 * Indicates when the user has typed in the text area
		 * */
		public var isCodeModifiedByUser:Boolean;
		
		/**
		 * Show borders around HTML elements
		 * */
		public var showBorders:Boolean;
		
		/**
		 * Use border box model
		 * */
		public var useBorderBox:Boolean = true;
		
		/**
		 * Encoding to use when using data URI
		 * */
		public var encodingType:String = DisplayObjectUtils.PNG;
		
		/**
		 * Places common CSS after element CSS when true.
		 * This is so in the editor you see the element css at the top
		 * */
		public var reverseInitialCSS:Boolean = true;
		
		/**
		 * Note: This is obsolete. Now using -0.2em to "pull up" text
		 * 
		 * Padding from browser text engine. 
		 * In browsers (some or all) the text is not absolutely placed 
		 * where you set it to be the larger the font is the farther down
		 * it is. So we adjust it but it's not that accurate. 
		 * If it is vertically aligned we shouldn't use this. TODO
		 * */
		public var paddingFromBrowserTextEngine:Number = .34615;
		
		/**
		 * Use SVG button class
		 * */
		public var useSVGButtonClass:Boolean = true;
		
		/**
		 * Show full HTML page source
		 * */
		public var showFullHTMLPageSource:Boolean = false;
		
		/**
		 * Show image snapshot when html element is not found or supported
		 * */
		public var showImageWhenComponentNotFound:Boolean = true;
		
		/**
		 * Last source code
		 * */
		public var sourceCode:String;
		
		public var includePreviewCode:Boolean;
		public var useSpacerForGap:Boolean;
		
		public var horizontalPositions:Array = ["x","left","right","horizontalCenter"];
		public var horizontalCenterPosition:String = "horizontalCenter";
		public var verticalPositions:Array = ["y","top","bottom","verticalCenter"];
		public var verticalCenterPosition:String = "verticalCenter";
		public var sizesPositions:Array = ["width","height"];
		
		public var addZoom:Boolean;
		
		public var output:String = "";
		public var markup:String = "";
		public var styles:String = "";
		
		public var wrapInPreview:Boolean;
		
		public var disableTabs:Boolean;
		public var tab:String = "\t";
		
		/**
		 * URL to transparent Gif used for spacing. Not currently used. 
		 * */
		public var transparentGifURL:String = "/spacer.gif";
		
		/**
		 * 
		 * */
		public var useWrapperDivs:Boolean;
		
		/**
		 * 
		 * */
		public var document:IDocument;
		
		/**
		 * Array of scripts. Could be string
		 * */
		public var scripts:String = "";
		
		/**
		 * @inheritDoc
		 * */
		override public function export(iDocument:IDocument, targetDescription:ComponentDescription = null, localOptions:ExportOptions = null, dispatchEvents:Boolean = false):SourceData {
			var pageOutput:String = "";
			var file:FileInfo;
			var files:Array = [];
			var errorData:IssueData;
			var warningData:IssueData;
			var tabDepth:String = "";
			var bodyContent:String;
			var headerContent:String;
			var stylesheetLinks:String;
			
			document = iDocument;
			
			errors = [];
			warnings = [];
			styles = "";
			markup = "";
			sourceCode = "";
			template = "";
			identifiers = [];
			duplicateIdentifiers = [];
			
			
			///////////////////////
			// SET OPTIONS
			///////////////////////
			
			if (localOptions) {
				savePresets(HTMLExportOptions);
				applyPresets(localOptions);
			}
			
			
			///////////////////////
			// GET SOURCE CODE
			///////////////////////
			
			if (exportFullDocument) {
				targetDescription = document.componentDescription;
			}
			
			if (targetDescription) {
				var zoomOutput:String;
				var applicationContainerID:String = "applicationContainer";
				var zoomInID:String = wrapInPreview ? document.name : applicationContainerID;
				
				// see the top of this document on how to generate source code
				
				if (exportFromHistory) {
					///getAppliedPropertiesFromHistory(iDocument, targetDescription);
				}
				
				if (!disableTabs) {
					//tabDepth = getContentTabDepth(template);
				}
				
				// if useCustomMarkup is true then markup and styles is
				// is set by the options object
				if (!useCustomMarkup) {
					markup = getHTMLOutputString(document, targetDescription, true, tabDepth);
					// styles are updated here too
				}
				else if (createFiles) {
					warningData = IssueData.getIssue("Live Editing Enabled", "Your live changes have been saved. Disable live editing to revert changes.");
					warnings.push(warningData);
				}
				
				//showScreenshotBackground = true;
				
				// background-image didn't work in FF on mac. didn't test on other browsers
				if (showScreenshotBackground) {
					var backgroundImageID:String = "backgroundComparisonImage";
					var imageDataFormat:String = encodingType;//"jpeg";
					var imageData:String = DisplayObjectUtils.getBase64ImageDataString(document.instance, imageDataFormat, null, true);
					var backgroundSnapshot:String = "\n" + tabDepth + "\t" + "<img ";
					var backgroundImageAlpha:String = ".5";
					backgroundSnapshot += "id=\"" + backgroundImageID +"\""; 
					backgroundSnapshot += " style=\"position:absolute;opacity:"+backgroundImageAlpha+";top:0px;left:0px;\"";
					backgroundSnapshot += " src=\"" + imageData + "\" >";
					
					pageOutput += backgroundSnapshot;
					
					var imageDataStyle:String;
					imageDataStyle = "body {\n";
					imageDataStyle += "\tbackground-repeat: no-repeat;\n";
					imageDataStyle += "\tbackground-image: url(" + imageData + ");\n";
					imageDataStyle += "}";
					//imageDataStyle = "\tbackground-image: url(data:image/jpeg;base64,"+imageData+");";
					
					styles += "\n" + imageDataStyle;
				}
				
				if (styles==null) {
					styles = "";
				}
				
				if (!useCustomMarkup) {
					if (useBorderBox) {
						if (reverseInitialCSS) {
							styles = styles + "\n\n" + borderBoxCSS;
						}
						else {
							styles = borderBoxCSS + "\n\n" + styles;
						}
					}
					
					if (useBetterHTML) {
						if (reverseInitialCSS) {
							styles = styles + "\n\n" + betterHTML;
						}
						else {
							styles = betterHTML + "\n\n" + styles;
						}
					}
				}
				
				if (showBorders) {
					if (reverseInitialCSS) {
						styles = styles + "\n\n" + bordersCSS;
					}
					else {
						styles = bordersCSS + "\n\n" + styles;
					}
				}
				
				if (useSVGButtonClass) {
					if (reverseInitialCSS) {
						styles = styles + "\n" + buttonCSS2;
					}
					else {
						styles += "\n" + buttonCSS2;
					}
				}
				
				if (addZoom) {
					//zoomOutput = zoomCSS.replace(/IFRAME_ID/g, "#" + application.name);
					zoomOutput = zoomCSS.replace(/IFRAME_ID/g, "#" + zoomInID);
					zoomOutput = zoomOutput.replace(/ZOOM_VALUE/g, document.scale);
					styles += "\n" + zoomOutput;
				}
				
				// add user styles
				if (userStyles) {
					styles += "\n" + userStyles;
				}
				else {
					userStyles = "";
				}
				
				if (template==null || template=="") {
					template = document.template;
				}
				
				if (template==null || template=="") {
					template = "";
					warningData = IssueData.getIssue("Missing template content", "The template was empty.");
					warnings.push(warningData);
				}
				
				// replace generator
				pageOutput = replaceGeneratorToken(template, generator);
				
				// replace title
				pageOutput = replacePageTitleToken(pageOutput, document.name);
				
				// replace scripts
				pageOutput = replaceScriptsToken(pageOutput, scripts);
				
				
				// replace styles
				if (useExternalStylesheet) {
					
					file = new FileInfo();
					file.contents = styles;
					file.fileName = document.name;
					file.fileExtension = "css";
					
					if (createFiles) {
						files.push(file);
					}
					
					// create link to stylesheet
					stylesheetLinks = getExternalStylesheetLink(file.getFullFileURI());
					
					pageOutput = replaceStylesheetsToken(pageOutput, stylesheetLinks);
					
				}
				else {
					
					if (styles!="") {
						pageOutput = replaceStylesToken(pageOutput, wrapInStyleTags(styles));
					}
				}
				
				
				// replace content
				pageOutput = replaceContentToken(pageOutput, markup);
				
				
				if (createFiles) {
					file = new FileInfo();
					file.contents = pageOutput;
					file.fileName = document.name;
					file.fileExtension = fileExtension;
					files.push(file);
				}
				
				
				///////////////////////
				// VALIDATION
				///////////////////////
				
				var validationInfo:XMLValidationInfo = XMLUtils.validateXML(pageOutput);
				
				if (validationInfo && !validationInfo.valid) {
					warningData = IssueData.getIssue("Possibly Invalid Markup", validationInfo.internalErrorMessage, validationInfo.row, validationInfo.column);
					warnings.push(warningData);
				}
				else {
					error = null;
					errorMessage = null;
				}
				
				var checkValidXML:Boolean = false;
				
				// skipping this check for now
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
						var xml:XML = new XML(pageOutput);
						time = getTimer() -time;
						//trace("xml validation parsing time=" + time);
						sourceCode = pageOutput;
					}
					catch (error:Error) {
						// Error #1083: The prefix "s" for element "Group" is not bound.
						// <s:Group x="93" y="128">
						//	<s:Button x="66" y="17"/>
						//</s:Group>
						
						warningData = IssueData.getIssue(error.name, error.message);
						warnings.push(errorData);
						
						time = getTimer() -time;
						//trace("xml validation parsing time with error=" + time);
						sourceCode = pageOutput;
					}
				}
				else {
					sourceCode = pageOutput;
				}
			}
			
			var sourceData:SourceData = new SourceData();
			
			sourceData.source = pageOutput;
			sourceData.markup = markup;
			sourceData.styles = styles;
			sourceData.template = template;
			sourceData.userStyles = userStyles;
			sourceData.files = files;
			sourceData.errors = errors;
			sourceData.warnings = warnings;

			if (localOptions) {
				restorePreviousPresets();
			}
			
			return sourceData;
		}
		
		/**
		 *  Gets the markup for a link to an external stylesheet
		 * <pre>
		 * &lt;link href="styles.css" type="text/css" />
		 * </pre>
		 * Returns a string of a link element.
		 * */
		public function getExternalStylesheetLink(filePath:String, relation:String = "stylesheet", title:String = null, type:String = "text/css", media:String = null):String {
			var xml:XML = new XML("<link/>");
			xml.@href = filePath;
			if (media) xml.@media = media;
			if (relation) xml.@rel = relation;
			if (title) xml.@rel = title;
			if (type) xml.@type = type;
			
			return xml.toXMLString();
		}
	
		/**
		 * Gets the formatted output from a component.
		 * Yes, this is hacky.
		 * I wanted to see if I could quickly generate valid HTML 
		 * from the component tree and didn't know the performance cost
		 * of using XML objects (need to test). Would like to use OOP or XML E4X
		 * but whatever it is it must support plugins, pre and post processors.
		 * It needs rewritten. Goal was to get it working
		 * find out what worked and what didn't and then refactor. 
		 * 
		 * A problem using XML is that HTML is not XML. Some XML tags will not work. 
		 * 
		 * I did start though. There is partial work with CSS properties objects 
		 * but those aren't used yet. 
		 * Basically you set the properties and styles on an object instead of inline
		 * and then call propertyObject.toString(). The method would handle
		 * formatting, tab spacings and possibly wrapper objects.
		 * Wrapper objects... that's another thing. 
		 * Different elements would extend an HTMLElement object.
		 * 
		 * Update: Started work on a second method and approach. 
		 * */
		public function getHTMLOutputString(iDocument:IDocument, componentDescription:ComponentDescription, addLineBreak:Boolean = false, tabs:String = "", includePreview:Boolean = false):String {
			var componentInstance:Object = componentDescription.instance;
			if (componentInstance==null) return "";
			var propertyList:Object = componentDescription.properties;
			///var propertiesStylesObject:Object = ObjectUtils.merge(componentDescription.properties, componentDescription.styles);
			var propertiesStylesObject:Object = ObjectUtils.merge(componentDescription.styles, componentDescription.properties);
			var componentName:String = componentDescription.className ? componentDescription.className.toLowerCase() : "";
			var localName:String = componentName ? componentName : "";
			var componentChild:ComponentDescription;
			var instanceName:String = componentInstance && "name" in componentInstance ? componentInstance.name : "";
			var instanceID:String = componentInstance && "id" in componentInstance ? componentInstance.id : "";
			var identity:String = ClassUtils.getIdentifier(componentInstance);
			var isGraphicalElement:Boolean = componentDescription.isGraphicElement;
			var contentToken:String = "[child_content]";
			var styleValue:String = "position:absolute;";
			var secondaryStyleValue:String = "";
			var stylesModel:HTMLStyles = new HTMLStyles();
			var stylesOut:String = "";
			var wrapperStylesModel:HTMLStyles = new HTMLStyles();
			var isInHorizontalLayout:Boolean;
			var isInVerticalLayout:Boolean;
			var isInBasicLayout:Boolean;
			var isInTileLayout:Boolean;
			var childContent:String = "";
			var useWrapperTag:Boolean;
			var wrapperTag:String = "";
			var centeredHorizontally:Boolean;
			var wrapperTagStyles:String = "";
			var wrapperSVGStyles:String = "";
			var wrapperSVGProperties:String = "";
			var wrapWithAnchor:Boolean;
			var anchorURL:String;
			var anchorTarget:String;
			var properties:String = "";
			var outlineStyle:String;
			var initialTabs:String = tabs;
			var parentVerticalAlign:String;
			var userInstanceStyles:String;
			var errorData:ErrorData;
			var componentNotFound:Boolean;
			var layoutOutput:String = "";
			var svgDefinitions:Array = [];
			var numberOfChildren:int;
			var type:String = "";
			var instance:Object;
			var numElements:int;
			var htmlName:String;
			var tagName:String;
			var tracking:Number;
			var borderColor:String;
			var elementIndex:int;
			var value:*;
			var gap:int;
			var newLine:String = "\n";
			var snapshotBackground:Boolean;
			var convertElementToImage:Boolean;
			var imageDataStyle:String;
			var imageDataFormat:String = encodingType;
			var isHorizontalCenterSet:Boolean;
			var isVerticalCenterSet:Boolean;
			var anchor:XML;
			var verticalAlign:String;
			var layoutBase:LayoutBase;
			var setPositioningStylesOnElement:Boolean;
			var containerVerticalAlign:String;
			var containerHorizontalAlign:String;
			var columnCount:int;
			var columnWidth:int;
			var rowCount:int;
			var rowHeight:int;
			var numberOfElements:int;
			var endOfRow:Boolean;
			var endOfColumn:Boolean;
			var htmlOverride:String;
			var htmlBefore:String;
			var htmlAfter:String;
			var htmlAttributes:String;
			var useUpdatedIndent:Boolean;
			var bounds:Rectangle;
			
			isInBasicLayout = false;
			setPositioningStylesOnElement = true;
			
			wrapWithAnchor 	= componentDescription.wrapWithAnchor;
			anchorURL 		= componentDescription.anchorURL;
			anchorTarget	= componentDescription.anchorTarget;
			
			tagName 		= componentDescription.htmlTagName;
			
			// we are setting the styles in a string now
			// the next refactor should use the object so we can output to CSS
			stylesModel.position = HTMLStyles.ABSOLUTE;
			//outlineStyle = "outline:1px solid red;"; // we should enable or disable outlines via code not markup on in the export
			
			userInstanceStyles = componentDescription.userStyles;
			
			if (userInstanceStyles==null || userInstanceStyles == "null") {
				userInstanceStyles = "";
			}
			else {
				userInstanceStyles = userInstanceStyles.replace(/\n/g, ""); // /\r?\n|\r/g
			}
			
			
			// get layout positioning
			if (componentDescription.parent && componentDescription.parent.instance is IVisualElementContainer) {
				layoutBase = componentDescription.parent.instance && "layout" in componentDescription.parent.instance ? componentDescription.parent.instance.layout as LayoutBase : null;
				
				if (layoutBase is HorizontalLayout) {
					isInHorizontalLayout = true;
					styleValue = styleValue.replace("absolute", "relative");
					//styleValue += "vertical-align:middle;";
					stylesModel.position = HTMLStyles.RELATIVE;
					elementIndex = GroupBase(componentDescription.parent.instance).getElementIndex(componentInstance as IVisualElement);
					numElements = GroupBase(componentDescription.parent.instance).numElements;
					wrapperTagStyles += hasExplicitSizeSet(componentInstance as IVisualElement) ? "display:inline-block;" : "display:inline;";
					wrapperStylesModel.display = hasExplicitSizeSet(componentInstance as IVisualElement) ? HTMLStyles.INLINE_BLOCK : HTMLStyles.INLINE;
					gap = HorizontalLayout(layoutBase).gap - 4;
					parentVerticalAlign = HorizontalLayout(layoutBase).verticalAlign;
					wrapperTagStyles += getParentVerticalAlign(parentVerticalAlign);
					
					if (elementIndex<numElements-1 && numElements>1) {
						//wrapperTagStyles += "padding-right:" + gap + "px;";
						wrapperTagStyles += HTMLStyles.MARGIN_RIGHT+":" + gap + "px;";
						wrapperStylesModel.marginRight =  gap + "px";
					}
				}
				else if (layoutBase is TileLayout) {
					var tileLayout:TileLayout = layoutBase as TileLayout;
					
					//isHorizontalLayout = true;
					isInTileLayout = true;
					styleValue = styleValue.replace("absolute", "relative");
					stylesModel.position = HTMLStyles.RELATIVE;
					elementIndex = GroupBase(componentDescription.parent.instance).getElementIndex(componentInstance as IVisualElement);
					numElements = GroupBase(componentDescription.parent.instance).numElements;
					wrapperTagStyles += hasExplicitSizeSet(componentInstance as IVisualElement) ? "display:inline-block;" : "display:inline;";
					wrapperStylesModel.display = hasExplicitSizeSet(componentInstance as IVisualElement) ? HTMLStyles.INLINE_BLOCK : HTMLStyles.INLINE;
					gap = TileLayout(layoutBase).horizontalGap - 4;
					parentVerticalAlign = TileLayout(layoutBase).verticalAlign;
					wrapperTagStyles += getParentVerticalAlign(parentVerticalAlign);
					
					if (elementIndex<numElements-1 && numElements>1) {
						//wrapperTagStyles += "padding-right:" + gap + "px;";
						// using "margin-right" because if you set a fixed width padding was not doing anything
						wrapperTagStyles += HTMLStyles.MARGIN_RIGHT+":" + gap + "px;";
						//wrapperStyles.paddingRight =  gap + "px";
						wrapperStylesModel.marginRight =  gap + "px";
					}
					
					
					columnCount					= tileLayout.columnCount;
					columnWidth 				= tileLayout.columnWidth;
					rowCount					= tileLayout.rowCount;
					rowHeight 					= tileLayout.rowHeight;
					
					
					if ((elementIndex+1) % columnCount==0) {
						endOfColumn = true;
					}
					else {
						endOfColumn = false;
					}
					
					if ((elementIndex+1) % rowCount==0) {
						endOfRow = true;
					}
					else {
						endOfRow = false;
					}
					
					wrapperTag = "div";
				}
				
				else if (layoutBase is VerticalLayout) {
					isInVerticalLayout = true;
					styleValue = styleValue.replace("absolute", "relative");
					stylesModel.position = HTMLStyles.RELATIVE;
					elementIndex = GroupBase(componentDescription.parent.instance).getElementIndex(componentInstance as IVisualElement);
					numElements = GroupBase(componentDescription.parent.instance).numElements;
					gap = VerticalLayout(layoutBase).gap - 1;
					parentVerticalAlign = VerticalLayout(layoutBase).verticalAlign;
					wrapperTagStyles += getParentVerticalAlign(parentVerticalAlign);
					
					
					if (elementIndex<numElements-1 && numElements>1) {
						
						if (gap!=0) {
							//wrapperTagStyles += "padding-bottom:" + gap + "px;";
							wrapperTagStyles += HTMLStyles.MARGIN_BOTTOM+":" + gap + "px;";
						}
						//wrapperStyles.paddingBottom =  gap + "px";
						wrapperStylesModel.marginBottom =  gap + "px";
					}
					
					wrapperTag = "div";
				}
				
				else if (layoutBase is BasicLayout) {
					isInBasicLayout = true;
					
					
					
					//styleValue = styleValue.replace("absolute", "relative");
					//styles.position = Styles.RELATIVE;
					/*index = GroupBase(component.parent.instance).getElementIndex(componentInstance as IVisualElement);
					numElements = GroupBase(component.parent.instance).numElements;
					gap = BasicLayout(component.parent.instance.layout).gap;*/
					
					/*if (index<numElements-1 && numElements>1) {
						wrapperTagStyles += "padding-bottom:" + gap + "px";
					}
					
					wrapperTag = "div";*/
				}
			}
			
			//exportChildDescriptors = componentDescription.exportChildDescriptors;
			
			if (exportChildDescriptors==false || componentDescription.exportChildDescriptors==false) {
				contentToken = "";
			}
			
				
			
				
			// the following needs works
			
			// if not a graphic element then center 
			if (!isGraphicalElement) {
				
				if (isInBasicLayout) {
					styleValue = getPositionHTML(componentInstance as IVisualElement, stylesModel, styleValue, isInBasicLayout);
				}
				
				else {
					
					if (setPositioningStylesOnElement) {
						styleValue += wrapperTagStyles;
						wrapperTag = "";
					}
					else {
						wrapperTag = "div";
					}
				}
				
				/*
				if (isVerticalCenterSet && isHorizontalCenterSet) {
					styleValue = getCenterPositionHTML(componentInstance as IVisualElement, stylesModel, styleValue, isInBasicLayout);
				}
				else if (isVerticalCenterSet) {
					styleValue = getVerticalPositionHTML(componentInstance as IVisualElement, stylesModel, styleValue, isInBasicLayout);
				}
				else if (isHorizontalCenterSet) {
					styleValue = getHorizontalPositionHTML(componentInstance as IVisualElement, stylesModel, styleValue, isInBasicLayout);
				}
				*/
			}
			else {
				
				if (isInBasicLayout && !(componentInstance is Line)) {
					styleValue = getPositionHTML(componentInstance as IVisualElement, stylesModel, styleValue, isInBasicLayout);
				}
					
				else {
					
					if (setPositioningStylesOnElement) {
						styleValue += wrapperTagStyles;
						wrapperTag = "";
					}
					else {
						wrapperTag = "div";
					}
				}
			}
			
			snapshotBackground = componentDescription.createBackgroundSnapshot;
			convertElementToImage = componentDescription.convertElementToImage;
			htmlOverride = componentDescription.htmlOverride;
			htmlBefore = componentDescription.htmlBefore;
			htmlAfter = componentDescription.htmlAfter;
			htmlAttributes = componentDescription.htmlAttributes;
			//var imageDataFormat:String = "jpeg";
			
			
			
			if (Document(iDocument).exclusions && Document(iDocument).exclusions[componentInstance]) {
				return layoutOutput;
			}
			
			// export component
			
			if (localName) {
				
				// putting the convert to image code at the top. it's also used below if an element is not found
				if (convertElementToImage || htmlOverride) {
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<img";
					//layoutOutput = StringUtils.ensureSpaceExists(layoutOutput);
					layoutOutput = StringUtils.ensureSpaceBetween(layoutOutput, properties);
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock(componentInstance) : "";
					styleValue += getVisibleDisplay(componentInstance);
					layoutOutput += properties ? " " : "";
					
					if (embedImages) {
						
						if (embedPlaceholderImageData) {
							layoutOutput += " src=\"" + embeddedImagePlaceholderData + "\"";
						}
						else {
							layoutOutput += " src=\"" + DisplayObjectUtils.getBase64ImageDataString(componentInstance, imageDataFormat) + "\"";
						}
					}
					
					styleValue += userInstanceStyles;
					stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
					
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += setUserAttributes(htmlAttributes);
					layoutOutput += closeTag(componentInstance);
					layoutOutput += getWrapperTag(wrapperTag, true);
					
					// if exporting an image then don't export the contents 
					//exportChildDescriptors = false;
					contentToken = "";
					
					if (htmlOverride) {
						layoutOutput = htmlOverride;
					}
				}
				
				else if (localName=="application") {
					htmlName = "div";
					
					// container div
					// DEPRECATED: the following code is - yoda probably
					if (includePreview) {
						/*output = "<div style=\"position:absolute;";
						//output += "width:" + (componentInstance.width + 40) + "px;";
						output += "width:100%;";
						output += "height:" + (componentInstance.height + 40) + "px;";
						output += "background-color:#666666;\">";*/
						layoutOutput += "<div";
						//output = getNameString(componentInstance, output);
						layoutOutput += properties ? " " + properties : " ";
						layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
						layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
						styleValue = styleValue.replace("absolute", "relative");
						stylesModel.position = HTMLStyles.ABSOLUTE;
						styleValue += "width:" + componentInstance.width+ "px;";
						styleValue += "height:" + componentInstance.height+ "px;";
						styleValue = getFontFamily(componentInstance, styleValue, true);
						styleValue = getFontWeight(componentInstance, styleValue, true);
						styleValue = getFontSize(componentInstance, styleValue, true);
						styleValue += "margin:0 auto;";
						styleValue += "left:8px;top:14px;";
						styleValue += "overflow:auto;";
						styleValue += "background-color:" + DisplayObjectUtils.getColorInHex(componentInstance.getStyle("backgroundColor"), true) + ";";
						
						if (snapshotBackground) {
							imageDataStyle = getBackgroundImageData(componentInstance);
							//imageDataStyle = "\tbackground-image: url(data:image/jpeg;base64,"+imageData+");";
							styleValue += "" + imageDataStyle;
						}
						
						if (convertElementToImage) {
							imageDataStyle = convertComponentToImage(componentInstance);
							//imageDataStyle = "\tbackground-image: url(data:image/jpeg;base64,"+imageData+");";
							styleValue += "" + imageDataStyle;
						}
						
						styleValue += userInstanceStyles;
						stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
						
						layoutOutput += setStyles(componentInstance, styleValue);
						layoutOutput += setUserAttributes(htmlAttributes);
						layoutOutput += closeTag(componentInstance);
						
						if (showScreenshotBackground) {
							var backgroundImageID:String = "backgroundComparisonImage";
							var imageData:String = DisplayObjectUtils.getBase64ImageDataString(componentInstance, imageDataFormat);
							var backgroundSnapshot:String = "\n" + tabs + "\t" + "<img ";
							backgroundSnapshot += "id=\"" + backgroundImageID +"\""; 
							backgroundSnapshot += " src=\"" + imageData + "\" ";
							
							layoutOutput += backgroundSnapshot;
							layoutOutput += setStyles("#"+backgroundImageID, "position:absolute;opacity:"+backgroundImageAlpha+";top:0px;left:0px;");
							layoutOutput += setUserAttributes(htmlAttributes);
							layoutOutput += closeTag(componentInstance, true);
							
							/* background-image didn't work in FF on mac. didn't test on other browsers
							//trace(imageData);
							var imageDataStyle:String = "#" + getIdentifierOrName(target) + "  {\n";
							//imageDataStyle = "\tbackground-image: url(data:image/jpeg;base64,"+imageData+");";
							imageDataStyle += "\tbackground-repeat: no-repeat;\n";
							imageDataStyle += "\tbackground-image: url(data:image/"+imageDataFormat+";base64,"+imageData+");\n}";
							styles += "\n" + imageDataStyle;*/
							// UPDATE : it didn't work because there were linebreaks in the base64 encoded string - remove all linebreaks and it works
						}
						
						
						layoutOutput += contentToken;
						//output += "\n </div>\n</div>";
						layoutOutput += "\n</div>";
						
					}
					else {
						// Deprecated: 
						if (addContainerDiv) {
							//output = "<div style=\"position: absolute;width:100%;height:100%;background-color:#666666;\">";
							layoutOutput = "<div";
							layoutOutput += properties ? " " + properties : " ";
							layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
							layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
							//output = getNameString(componentInstance, output);
							layoutOutput += properties ? " " + properties : "";
							styleValue += "width:" + componentInstance.width+ "px;";
							styleValue += "height:" + componentInstance.height+ "px;";
							styleValue += "border:1px solid black;";
							styleValue += "-moz-osx-font-smoothing: grayscale;";
						}
						else {
							styleValue = "-moz-osx-font-smoothing: grayscale;";
						}
						
						styleValue = getBackgroundColor(componentInstance, styleValue, false);
						styleValue = getFontFamily(componentInstance, styleValue, true);
						styleValue = getFontWeight(componentInstance, styleValue, true);
						styleValue = getFontSize(componentInstance, styleValue, true);
						styleValue = getFontStyle(componentInstance, styleValue);
						styleValue = getLineHeight(componentInstance, styleValue, false);
						styleValue = getFontColor(componentInstance, styleValue);
						styleValue = getAlpha(componentInstance, styleValue);
						styleValue = getTextAlign(componentInstance, styleValue);
						styleValue = getPadding(componentInstance, styleValue);
						styleValue = getTypographicCase(componentInstance, styleValue);
						styleValue = getTracking(componentInstance, styleValue);
						
						styleValue += isInVerticalLayout ? getDisplayBlock() : "";
						
						if (snapshotBackground) {
							imageDataStyle = getBackgroundImageData(componentInstance);
							//imageDataStyle = "\tbackground-image: url(data:image/jpeg;base64,"+imageData+");";
							styleValue += "" + imageDataStyle;
						}
						
						styleValue += userInstanceStyles;
						stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
						
						
						if (showScreenshotBackground) {
							backgroundImageID = "backgroundComparisonImage";
							imageDataFormat = encodingType;//"jpeg";
							imageData = DisplayObjectUtils.getBase64ImageDataString(componentInstance, imageDataFormat);
							backgroundSnapshot = "\n" + tabs + "\t" + "<img ";
							backgroundSnapshot += "id=\"" + backgroundImageID +"\""; 
							backgroundSnapshot += " src=\"" + imageData + "\" ";
							
							layoutOutput += backgroundSnapshot;
							layoutOutput += setStyles("#"+backgroundImageID, "position:absolute;opacity:"+backgroundImageAlpha+";top:0px;left:0px;");
							layoutOutput += setUserAttributes(htmlAttributes);
							layoutOutput += closeTag(componentInstance, true);
							/* background-image didn't work in FF on mac. didn't test on other browsers
							//trace(imageData);
							var imageDataStyle:String = "#" + getIdentifierOrName(target) + "  {\n";
							//imageDataStyle = "\tbackground-image: url(data:image/jpeg;base64,"+imageData+");";
							imageDataStyle += "\tbackground-repeat: no-repeat;\n";
							imageDataStyle += "\tbackground-image: url(data:image/"+imageDataFormat+";base64,"+imageData+");\n}";
							styles += "\n" + imageDataStyle;*/
						}
						
						
						if (addContainerDiv) {
							layoutOutput += setStyles(componentInstance, styleValue);
							layoutOutput += setUserAttributes(htmlAttributes);
							layoutOutput += closeTag(componentInstance);
							layoutOutput += contentToken;
							layoutOutput += "\n</div>";
						}
						else {
							layoutOutput += setUserAttributes(htmlAttributes);
							setStyles("body", styleValue);
							//layoutOutput += closeTag(componentInstance);
							layoutOutput += contentToken;
							layoutOutput += "";
						}
					}
				}
				
				else if (localName=="group" || localName=="vgroup") {
					htmlName = tagName ? tagName : "div";
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<" + htmlName + " " + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					layoutOutput += properties ? " " : "";
					
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue = getFontFamily(componentInstance, styleValue);
					styleValue = getFontWeight(componentInstance, styleValue);
					styleValue = getFontSize(componentInstance, styleValue);
					styleValue = getFontStyle(componentInstance, styleValue);
					styleValue = getFontColor(componentInstance, styleValue);
					styleValue = getAlpha(componentInstance, styleValue);
					styleValue = getBorderString(componentInstance, styleValue);
					styleValue = getTextAlign(componentInstance, styleValue);
					styleValue = getPadding(componentInstance, styleValue);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					styleValue = getScrollPolicy(componentInstance, styleValue);
					
					if (componentInstance is VGroup) {
						styleValue += "text-align:" + VGroup(componentInstance).horizontalAlign + ";";
					}
					
					if (snapshotBackground) {
						imageDataStyle = getBackgroundImageData(componentInstance);
						//imageDataStyle = "\tbackground-image: url(data:image/jpeg;base64,"+imageData+");";
						styleValue += "" + imageDataStyle;
					}
					
					styleValue += userInstanceStyles;
					stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
					
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += setUserAttributes(htmlAttributes);
					layoutOutput += closeTag(componentInstance);
					layoutOutput += contentToken;
					layoutOutput += "\n" + tabs + "</" + htmlName + ">";
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				
				else if (localName=="bordercontainer") {
					htmlName = tagName ? tagName : "div";
					
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<" + htmlName + " " + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					layoutOutput += properties ? " " : "";
					
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue = getFontFamily(componentInstance, styleValue);
					styleValue = getFontWeight(componentInstance, styleValue);
					styleValue = getFontSize(componentInstance, styleValue);
					styleValue = getFontStyle(componentInstance, styleValue);
					styleValue = getFontColor(componentInstance, styleValue);
					styleValue = getAlpha(componentInstance, styleValue);
					styleValue = getBorderString(componentInstance, styleValue, true);
					styleValue = getBackgroundColor(componentInstance, styleValue);
					styleValue = getTextAlign(componentInstance, styleValue);
					styleValue = getPadding(componentInstance, styleValue);
					
					// disabling overflow to get rid of scroll bars
					//styleValue = getScrollPolicy(componentInstance, styleValue);
					
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					//styleValue += getColorString(componentInstance as BorderContainer);
					//styles += componentInstance as BorderContainer);
					
					if (snapshotBackground) {
						imageDataStyle = getBackgroundImageData(componentInstance);
						//imageDataStyle = "\tbackground-image: url(data:image/jpeg;base64,"+imageData+");";
						styleValue += "" + imageDataStyle;
					}
					
					styleValue += userInstanceStyles;
					stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
					
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += setUserAttributes(htmlAttributes);
					layoutOutput += closeTag(componentInstance);
					layoutOutput += componentInstance.numElements==0? "&#160;": contentToken;
					layoutOutput += "\n" + tabs + "</" + htmlName + " >";
					layoutOutput += getWrapperTag(wrapperTag, true);
					
				}
				
				else if (localName=="hgroup" || localName=="tilegroup") {
					htmlName = tagName ? tagName : "div";
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<" + htmlName + " " + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					
					//styleValue = getSizeString(componentInstance as IVisualElement, styleValue);
					if (componentDescription.name=="HGroup") {
						styleValue = getWidthString(componentInstance, styleValue, isHorizontalCenterSet, isVerticalCenterSet, false);
					}
					else {
						styleValue = getWidthString(componentInstance, styleValue, isHorizontalCenterSet, isVerticalCenterSet, false);
					}
					
					styleValue = getHeightString(componentInstance, styleValue, isHorizontalCenterSet, isVerticalCenterSet, false);
					styleValue = getFontFamily(componentInstance, styleValue);
					styleValue = getFontWeight(componentInstance, styleValue);
					styleValue = getFontSize(componentInstance, styleValue);
					styleValue = getFontColor(componentInstance, styleValue);
					styleValue = getFontStyle(componentInstance, styleValue);
					styleValue = getAlpha(componentInstance, styleValue);
					styleValue = getBorderString(componentInstance, styleValue);
					styleValue = getTextAlign(componentInstance, styleValue);
					styleValue = getPadding(componentInstance, styleValue);
					styleValue = getScrollPolicy(componentInstance, styleValue);
					
					if (componentInstance is HGroup) {
						styleValue += "text-align:" + HGroup(componentInstance).horizontalAlign + ";";
						// we need whitespace for the hgroup but not inherited
						//styleValue += "white-space:" + "nowrap;";
						
						/*
						#parent {
							white-space: nowrap;
						}
						
						#parent * {
							white-space: initial;
						}
						*/
					}
					
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					
					//var vertical:String = componentInstance.getStyle("verticalAlign");
					verticalAlign = componentInstance.verticalAlign;
					
					if (localName=="hgroup" || localName=="tilegroup") {
						
						// warning - hack below! ...and above and all over the place
						// TODO: USE TABLE CELL display type on child elements?? no
						// UPDATE now use 0 width element to size to 100% of container height
						// and other elements should center vertically - refactor
						if (verticalAlign=="middle") {
							
							// this messes up some layouts
							if (!useSpanToCenterInHGroup) {
								styleValue += "line-height:" + (componentInstance.height-4) + "px;";
							}
							// update 5/2/16
							// adding a spacer element at the end with height 100% 
							
						}
						
						// trying table cell - table cell should be on elements and table on the container
						// wasn't working so didn't pursue
						if (false && verticalAlign=="middle") {
							//styleValue += "display:\"table-cell\";vertical-align:middle;"; 
							styleValue += "display:\"table-cell\";vertical-align:middle;"; 
						}
					}
					
					layoutOutput += properties ? " " : "";
					
					if (snapshotBackground) {
						imageDataStyle = getBackgroundImageData(componentInstance);
						//imageDataStyle = "\tbackground-image: url(data:image/jpeg;base64,"+imageData+");";
						styleValue += "" + imageDataStyle;
					}
					
					styleValue += userInstanceStyles;
					stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
					
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += setUserAttributes(htmlAttributes);
					layoutOutput += closeTag(componentInstance);
					layoutOutput += contentToken;
					
					if (useSpanToCenterInHGroup && verticalAlign=="middle") {
						layoutOutput += "\n" + tabs + "\t<span style='display:inline-block;height:100%;width:0;vertical-align:middle;'></span>";
					}
					
					layoutOutput += "\n" + tabs + "</" + htmlName + ">";
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="button" || localName=="togglebutton") {
					htmlName = tagName ? tagName : "input";
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<" + htmlName + " " + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					layoutOutput += " type=\"button\"" ;
					layoutOutput += properties ? " " + properties : "";
					
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					styleValue = getFontFamily(componentInstance, styleValue);
					styleValue = getFontWeight(componentInstance, styleValue);
					styleValue = getFontStyle(componentInstance, styleValue);
					styleValue = getFontSize(componentInstance, styleValue);
					styleValue = getFontColor(componentInstance, styleValue);
					styleValue = getAlpha(componentInstance, styleValue);
					styleValue = getTextAlign(componentInstance, styleValue);
					styleValue = getPadding(componentInstance, styleValue);
					styleValue = getBorderString(componentInstance, styleValue);
					
					styleValue += userInstanceStyles;
					stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
					
					layoutOutput += " value=\"" + componentInstance.label + "\"";
					//layoutOutput += " class=\"buttonSkin\"";
					
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += setUserAttributes(htmlAttributes);
					layoutOutput += closeTag(componentInstance);
					
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="videoplayer") {
					htmlName = tagName ? tagName : "video";
					
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
					
					layoutOutput += "<" +htmlName+ " ";
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					layoutOutput = getBooleanAttribute("autoPlay", componentInstance.autoPlay, layoutOutput);
					layoutOutput = getBooleanAttribute("loop", componentInstance.loop, layoutOutput);
					layoutOutput = getBooleanAttribute("muted", componentInstance.muted, layoutOutput);
					
					// the mere existence of this attribute causes controls to show up regardless of attribute value
					// layoutOutput += " controls=\"true\" "  + properties;
					
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					/*
					styleValue = getFontFamily(componentInstance, styleValue);
					styleValue = getFontWeight(componentInstance, styleValue);
					styleValue = getFontSize(componentInstance, styleValue);
					styleValue = getFontColor(componentInstance, styleValue);
					styleValue = getFontStyle(componentInstance, styleValue);
					*/
					styleValue = getAlpha(componentInstance, styleValue);
					styleValue = getPadding(componentInstance, styleValue);
					styleValue = getBorderString(componentInstance, styleValue);
					//styleValue += "padding:2px;";
					
					styleValue += userInstanceStyles;
					stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
					
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += setUserAttributes(htmlAttributes);
					layoutOutput += closeTag(componentInstance);
					
					if (componentInstance.source) {
						layoutOutput += "\n" + tabs + "\t<source src=\"" + componentInstance.source + "\">\n";
					}
					
					layoutOutput += tabs + "</" + htmlName + ">";
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="checkbox") {
					htmlName = tagName ? tagName : "input";
					
					if (componentInstance.label!="") {
						layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
						layoutOutput += "<label ";
						layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput, "_Label");
						layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
						
						//styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
						styleValue = getHeightString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
						styleValue += isInVerticalLayout ? getDisplayBlock() : "";
						styleValue = getFontFamily(componentInstance, styleValue);
						styleValue = getFontWeight(componentInstance, styleValue);
						styleValue = getFontSize(componentInstance, styleValue);
						styleValue = getFontColor(componentInstance, styleValue);
						styleValue = getFontStyle(componentInstance, styleValue);
						styleValue = getAlpha(componentInstance, styleValue);
						styleValue = getBorderString(componentInstance, styleValue);
						styleValue = getTextAlign(componentInstance, styleValue);
						styleValue = getPadding(componentInstance, styleValue);
						
						styleValue += userInstanceStyles;
						stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
						
						layoutOutput += setStyles("#"+getIdentifierOrName(componentInstance, true, "_Label"), styleValue);
						layoutOutput += setUserAttributes(htmlAttributes);
						layoutOutput += closeTag(componentInstance);
						layoutOutput += "<" + htmlName + " ";
						layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
						layoutOutput += " type=\"checkbox\" ";
						layoutOutput += "/>" ;
					}
					else {
						layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
						layoutOutput += "<" + htmlName +  " " + properties;
						layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
						layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
						layoutOutput += " type=\"checkbox\" " + properties;
						
						styleValue = getAlpha(componentInstance, styleValue);
						styleValue = getPadding(componentInstance, styleValue);
						//styleValue = getSizeString(componentInstance as IVisualElement, styleValue);
						
						styleValue += userInstanceStyles;
						stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
						
						layoutOutput += setStyles(componentInstance, styleValue);
						layoutOutput += setUserAttributes(htmlAttributes);
						layoutOutput += closeTag(componentInstance);
					}
					
					if (componentInstance.label!="") {
						layoutOutput += " " + componentInstance.label + "</label>";
					}
					
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="radiobutton") {
					//htmlName = tagName ? tagName : "radio";
					htmlName = tagName ? tagName : "input";
					
					if (componentInstance.label!="") {
						layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
						layoutOutput += "<label ";
						layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput, "_Label");
						layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
						
						styleValue = getHeightString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
						styleValue += isInVerticalLayout ? getDisplayBlock() : "";
						styleValue = getFontFamily(componentInstance, styleValue);
						styleValue = getFontWeight(componentInstance, styleValue);
						styleValue = getFontSize(componentInstance, styleValue);
						styleValue = getFontColor(componentInstance, styleValue);
						styleValue = getFontStyle(componentInstance, styleValue);
						styleValue = getAlpha(componentInstance, styleValue);
						styleValue = getTextAlign(componentInstance, styleValue);
						styleValue = getPadding(componentInstance, styleValue);
						styleValue = getBorderString(componentInstance, styleValue);
						
						styleValue += userInstanceStyles;
						stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
						
						layoutOutput += setStyles("#"+getIdentifierOrName(componentInstance, true, "_Label"), styleValue);
						layoutOutput += setUserAttributes(htmlAttributes);
						layoutOutput += closeTag(componentInstance);
						layoutOutput += "<" + htmlName + " type=\"radio\" " ;
						layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
						layoutOutput += "/>" ;
					}
					else {
						layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
						layoutOutput += "<" + htmlName + " type=\"radio\" " + properties;
						layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
						layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
						
						styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
						styleValue = getAlpha(componentInstance, styleValue);
						styleValue = getPadding(componentInstance, styleValue);
						styleValue = getBorderString(componentInstance, styleValue);
						styleValue += isInVerticalLayout ? getDisplayBlock() : "";
						
						styleValue += userInstanceStyles;
						stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
						
						layoutOutput += setStyles(componentInstance, styleValue);
						layoutOutput += setUserAttributes(htmlAttributes);
						layoutOutput += closeTag(componentInstance);
					}
					
					if (componentInstance.label!="") {
						layoutOutput += " " + componentInstance.label + "</label>";
					}
					
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="textinput" || localName=="combobox" || localName=="numericstepper"
						|| localName=="datefield" || localName=="colorpicker" 
						|| localName=="hslider" || localName=="vslider" ) {
					
					htmlName = tagName ? tagName : "input";
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
					
					layoutOutput += "<" +htmlName+ " ";
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					
					if ("prompt" in componentInstance && componentInstance.prompt) {
						layoutOutput += " placeholder=\"" + componentInstance.prompt + "\"";
					}
					
					if (localName=="textinput" && "displayAsPassword" in componentInstance && componentInstance.displayAsPassword) {
						layoutOutput += " type=\"password\" "  + properties;
					}
					else if (localName=="textinput" || localName=="combobox") {
						layoutOutput += " type=\"input\" "  + properties;
					}
					else if (localName=="numericstepper") {
						layoutOutput += " type=\"number\" "  + properties;
					}
					else if (localName=="datefield") {
						layoutOutput += " type=\"date\" "  + properties;
					}
					else if (localName=="colorpicker") {
						layoutOutput += " type=\"color\" "  + properties;
					}
					else if (localName=="hslider") {
						layoutOutput += " type=\"range\" "  + properties;
					}
					else if (localName=="vslider") {
						layoutOutput += " type=\"range\" "  + properties;
						layoutOutput += " orient=\"vertical\"";
					}
					
					
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					styleValue = getFontFamily(componentInstance, styleValue);
					styleValue = getFontWeight(componentInstance, styleValue);
					styleValue = getFontSize(componentInstance, styleValue);
					styleValue = getFontColor(componentInstance, styleValue);
					styleValue = getFontStyle(componentInstance, styleValue);
					styleValue = getAlpha(componentInstance, styleValue);
					styleValue = getBorderString(componentInstance, styleValue);
					styleValue = getTextAlign(componentInstance, styleValue);
					styleValue = getPadding(componentInstance, styleValue);
					
					if (localName=="vslider") {
						styleValue += "writing-mode:bt-lr;";
					}
					
					borderColor = componentInstance.getStyle("borderColor");
					
					if (borderColor!=null) {
						styleValue += "border:1px solid " + DisplayObjectUtils.getColorInHex(uint(borderColor), true) + ";";
					}
					
					if (localName=="combobox") {
						layoutOutput += " list=\"listdata\"";
						//<datalist id="listData">
						  //<option value="value 1">
						  //<option value="value 2">
						  //<option value="value 3">
						//</datalist> 
					}
					else if (localName=="numericstepper") {
						layoutOutput += " min=\"" + NumericStepper(componentInstance).minimum + "\"";
						layoutOutput += " max=\"" + NumericStepper(componentInstance).maximum + "\"";
						layoutOutput += " quantity=\"" + NumericStepper(componentInstance).value + "\"";
						
						if (NumericStepper(componentInstance).maxChars!=0) {
							layoutOutput += " maxlength=\"" + NumericStepper(componentInstance).maxChars + "\"";
						}
						
						if (NumericStepper(componentInstance).stepSize!=0) {
							//layoutOutput += " step=\"" + NumericStepper(componentInstance).stepSize + "\"";
						}
					}
					
					else if (localName=="colorpicker") {
						if ("selectedColor" in componentInstance) {
							layoutOutput += " value=\"" + DisplayObjectUtils.getColorInHex(uint(Object(componentInstance).selectedColor), true) + "\"";
						}
						// add zero padding for now
						styleValue += "padding:0px;";
					}
					
					
					styleValue += userInstanceStyles;
					stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
					
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += setUserAttributes(htmlAttributes);
					layoutOutput += closeTag(componentInstance);
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="dropdownlist" || localName=="list") {
					htmlName = tagName ? tagName : "select";
					
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<" + htmlName + " ";
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					layoutOutput += " type=\"input\" "  + properties;
					
					if ("allowMultipleSelection" in componentInstance && componentInstance.allowMultipleSelection) {
						layoutOutput += " multiple=\"multiple\"";
					}
					
					if (localName=="list" && ListBase(componentInstance).layout is VerticalLayout) {
						layoutOutput += " size=\"" + VerticalLayout(componentInstance.layout).rowCount + "\"";
					}
					
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					styleValue = getFontFamily(componentInstance, styleValue);
					styleValue = getFontWeight(componentInstance, styleValue);
					styleValue = getFontSize(componentInstance, styleValue);
					styleValue = getFontColor(componentInstance, styleValue);
					styleValue = getFontStyle(componentInstance, styleValue);
					styleValue = getAlpha(componentInstance, styleValue);
					styleValue = getBorderString(componentInstance, styleValue);
					styleValue = getTextAlign(componentInstance, styleValue);
					styleValue = getPadding(componentInstance, styleValue);
					
					
					styleValue += userInstanceStyles;
					stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
					
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += setUserAttributes(htmlAttributes);
					layoutOutput += closeTag(componentInstance);
					layoutOutput += "</" + htmlName + ">";
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="label" || 
						localName=="hyperlink" || 
						localName=="textarea" || 
						localName=="richtext" ||
						localName=="passthrough") {
					
					if (localName=="label") {
						// we may want to use "p" but rendering and layout is slightly different
						if (useSpanTagForLabels) {
							htmlName = "span";
						}
						else {
							htmlName = "label";
						}
					}
					else if (localName=="textarea") {
						htmlName = "textarea";
					}
					else if (localName=="richtext" || localName=="richeditabletext") {
						htmlName = "div";
					}
					else if (localName=="hyperlink") {
						htmlName = "a";
					}
					else if (localName=="passthrough") {
						htmlName = "div";
					}
					
					htmlName = tagName ? tagName : htmlName; 
					
					/*
					if (useWrapperDivs) {
						layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
					}
					else {
						//layoutOutput = tabs;
					}
					*/
					
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<" + htmlName + " "  + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					styleValue = getWidthString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet, isVerticalCenterSet);
					styleValue = getHeightString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet, isVerticalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					
					
					styleValue = getFontFamily(componentInstance, styleValue);
					styleValue = getFontWeight(componentInstance, styleValue);
					styleValue = getFontSize(componentInstance, styleValue);
					styleValue = getFontColor(componentInstance, styleValue);
					styleValue = getFontStyle(componentInstance, styleValue);
					styleValue = getLineHeight(componentInstance, styleValue);
					styleValue = getAlpha(componentInstance, styleValue);
					styleValue = getBorderString(componentInstance, styleValue);
					styleValue = getTextAlign(componentInstance, styleValue);
					styleValue = getPadding(componentInstance, styleValue);
					styleValue = getTypographicCase(componentInstance, styleValue);
					styleValue = getTracking(componentInstance, styleValue);
					
					styleValue = getMarginTopAdjustment(componentInstance, isVerticalCenterSet, styleValue);
					
					
					
					//styles += getBorderString(componentInstance as IStyleClient);
					
					layoutOutput += properties ? " " : "";
					
					if (localName=="hyperlink") {
						if (componentInstance.url) {
							layoutOutput += " " + getAttribute("href", componentInstance.url);
						}
						
						if (componentInstance.target) {
							layoutOutput += " " + getAttribute("target", componentInstance.target);
						}
					}
					
					// remove wrapperTagStyles since we are trying to not use wrapper tags
					//output += setStyles(componentInstance, styleValue+wrapperTagStyles);
					//output += setStyles(componentInstance, wrapperTagStyles + styleValue);
					
					styleValue += userInstanceStyles;
					stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
					
					//layoutOutput += setStyles(componentInstance, wrapperTagStyles + styleValue);
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += setUserAttributes(htmlAttributes);
					layoutOutput += closeTag(componentInstance);
					
					if (localName=="richtext" || localName=="richeditabletext" || localName=="textarea") {
						//htmlName = tagName ? tagName : "div";
						
						if (localName=="textarea") {
							htmlName = "textarea";
						}
						
						// we need to write another TextConverter.export method that doesn't include the HTML and body tag
						
						//layoutOutput += TextConverter.export(RichText(componentInstance).textFlow, TextConverter.TEXT_FIELD_HTML_FORMAT, ConversionType.STRING_TYPE);
						var test:Object = TextConverter.export(Object(componentInstance).textFlow, TextConverter.TEXT_FIELD_HTML_FORMAT, ConversionType.XML_TYPE);
						var content:XML;
						var items:XMLList;
						var richHTMLOutput:String = "";
						var firstItem:Boolean = true;
						var firstItemCSS:String = "margin-top:0px;";
						var existingCSS:String;
						//content = test.children()[0].children()[0].children()[0].children()[0];
						items = test.children()[0].children();
						
						if (!useInlineStyles) {
							setFirstParagraphStyles(componentInstance, firstItemCSS);
						}
						
						
						
						var originalXMLSettings:Object = XML.settings();
						
						XML.ignoreProcessingInstructions = false;
						XML.ignoreWhitespace = false;
						XML.prettyPrinting = false;
						
						for each (content in items) {
							
							if (firstItem && useInlineStyles) {
								existingCSS = String(content.@style);
								if (existingCSS==null) existingCSS = "";
								content.@style = firstItemCSS + existingCSS;
								firstItem = false;
							}
							
							richHTMLOutput += content.toXMLString() + "\n";
						}
						
						XML.setSettings(originalXMLSettings);
						
						// html text is not supported in an HTML textarea for now
						if (componentInstance is TextArea) {
							richHTMLOutput = TextArea(componentInstance).text;
						}
						
						if (richHTMLOutput) {
							richHTMLOutput = "\n" + richHTMLOutput;
							richHTMLOutput = StringUtils.indent(richHTMLOutput);
							//layoutOutput += richHTMLOutput + "\n" + tabs;
							layoutOutput += richHTMLOutput;
							useUpdatedIndent = true;
						}
					}
					else if (localName=="passthrough") {
						layoutOutput += componentInstance.text;
					}
					else {
						layoutOutput += componentInstance.text.replace(/\n/g, "<br/>");
					}
					
					layoutOutput += "</" + htmlName + ">";
					
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="image") {
					htmlName = tagName ? tagName : "img";
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<" + htmlName + " " + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue = getAlpha(componentInstance, styleValue);
					styleValue = getBorderString(componentInstance, styleValue);
					styleValue = getPadding(componentInstance, styleValue);
					styleValue += isInVerticalLayout ? getDisplayBlock(componentInstance) : "";
					styleValue += getVisibleDisplay(componentInstance);
					
					layoutOutput += properties ? " " : "";
					
					
					// showing vast amounts of base64 string in the web editor can use up all screen 
					// real estate - we can show placeholder data
					// the base url string is for a single gray pixel
					if (componentInstance.source is BitmapData) {
						
						if (embedImages) {
							
							if (embedPlaceholderImageData) {
								layoutOutput += " src=\"" + embeddedImagePlaceholderData + "\"";
							}
							else {
								layoutOutput += " src=\"" + DisplayObjectUtils.getBase64ImageDataString(componentInstance.source, imageDataFormat) + "\"";
							}
						}
					}
					else if (componentInstance.source is String) {
						layoutOutput += " src=\"" + componentInstance.source + "\"";
					}
					
					styleValue += userInstanceStyles;
					stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
					
					//layoutOutput += setStyles(componentInstance, wrapperTagStyles + styleValue);
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += setUserAttributes(htmlAttributes);
					layoutOutput += closeTag(componentInstance);
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="spacer") {
					//move to image
					// show placeholder NOT actual component
					htmlName = tagName ? tagName : "div";
					
					
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<" + htmlName + " "  + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet, isVerticalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					
					layoutOutput += properties ? " " : "";
					styleValue += userInstanceStyles;
					stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
					
					//layoutOutput += setStyles(componentInstance, wrapperTagStyles + styleValue);
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += setUserAttributes(htmlAttributes);
					layoutOutput += closeTag(componentInstance);
					//output += "&#160;"
					layoutOutput += "</" + htmlName + ">";
					
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="horizontalline" || localName=="verticalline" || localName=="line") {
					//move to 
					htmlName = tagName ? tagName : "line";
					wrapperTag = "svg";
					
					/*
					<svg height="210" width="500">
						<line x1="0" y1="0" x2="200" y2="200" style="stroke:rgb(255,0,0);stroke-width:2" />
				  	</svg>
					*/
					
					//if (useWrapperDivs) {
					wrapperSVGStyles = styleValue;
					wrapperSVGStyles += getLineWrapperSize(componentInstance);
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperSVGStyles);
					
					// graphic element has no name property
					if (componentInstance is GraphicElement && componentInstance.id ==null) {
						componentInstance.id = NameUtil.createUniqueName(componentInstance);
					}
					
					layoutOutput += newLine + tabs + tab + "<" + htmlName + " "  + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					
					if (localName=="horizontalline") {
						layoutOutput = getLinePosition(componentInstance, HORIZONTAL_LINE, layoutOutput);
						styleValue = getLineColor(componentInstance, styleValue);
						styleValue = getLineWeight(componentInstance, styleValue);
						styleValue += "shape-rendering:crispEdges;";
					}
					else if (localName=="verticalline") {
						layoutOutput = getLinePosition(componentInstance, VERTICAL_LINE, layoutOutput);
						styleValue = getLineColor(componentInstance, styleValue);
						styleValue = getLineWeight(componentInstance, styleValue);
						styleValue += "shape-rendering:crispEdges;";
					}
					else {
						layoutOutput = getLinePosition(componentInstance, LINE, layoutOutput);
						styleValue += "shape-rendering:auto;";
						styleValue = getStroke(componentInstance as Line, styleValue);
					}
					
					
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);

					styleValue = getAlpha(componentInstance, styleValue);
					styleValue = getBorderString(componentInstance, styleValue);
					styleValue = getTextAlign(componentInstance, styleValue);
					styleValue = getPadding(componentInstance, styleValue);
					
					//styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet, isVerticalCenterSet);
					//styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					
					layoutOutput += properties ? " " : "";
					//output += setStyles(componentInstance, wrapperTagStyles+styleValue);
					//stylesOut = wrapperTagStyles + styleValue;
					
					styleValue += userInstanceStyles;
					stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
					
					//layoutOutput += setStyles(componentInstance, wrapperTagStyles + styleValue);
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += setUserAttributes(htmlAttributes);
					layoutOutput += closeTag(componentInstance);
					//output += "&#160;"
					layoutOutput += "</" + htmlName + ">";
					
					layoutOutput += newLine + tabs + getWrapperTag(wrapperTag, true);
				}
				else if (componentInstance is GraphicElement) {
					// for graphic elements look at the button.svg code
					// it uses percents and LTBR constraints
					// this might be better than the way described
					// on most of the SVG sites
					// and provide for a better more dynamic Flex way
					// for skinning and constraint based layout
					// first step, obviously, is to get it working
					// second step, make it performant and clean
					// third step is make it delightful
					if (localName=="path") {
						htmlName = tagName ? tagName : "path";
					}
					else if (localName=="rect") {
						htmlName = tagName ? tagName : "rect";
					}
					else if (localName=="ellipse") {
						htmlName = tagName ? tagName : "ellipse";
					}
					
					wrapperTag = "svg";
					styleValue = "";
					
					/*
					<svg height="210" width="500">
						<line x1="0" y1="0" x2="200" y2="200" style="stroke:rgb(255,0,0);stroke-width:2" />
					</svg>
					*/
					
					if (localName=="path") {
						wrapperSVGProperties += getSVGViewBox(componentInstance, layoutBase);
					}
					
					wrapperSVGStyles = isInBasicLayout ? "position:absolute;" : "";
					wrapperSVGStyles += getSVGSize(componentInstance, layoutBase);
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperSVGStyles, wrapperSVGProperties);

					// graphic element has no name property
					if (componentInstance is GraphicElement && componentInstance.id==null) {
						componentInstance.id = NameUtil.createUniqueName(componentInstance);
					}
					
					layoutOutput += newLine + tabs + "<" + htmlName + " " + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					
					if (localName=="path") {
						layoutOutput = getAttributeLayout("d", Path(componentInstance).data, layoutOutput, false);
						styleValue = getGraphicElementPositionString(componentInstance as GraphicElement, styleValue);
						styleValue = getGraphicElementSizeString(componentInstance as GraphicElement, styleValue);
					}
					else if (localName=="rect") {
						layoutOutput = getGraphicElementPositionAttributes(componentInstance as GraphicElement, layoutOutput);
						layoutOutput = getGraphicElementSizeAttributes(componentInstance as GraphicElement, layoutOutput);
						layoutOutput = getRectCornerRadius(Rect(componentInstance), layoutOutput);
					}
					else if (localName=="ellipse") {
						layoutOutput = getEllipsePositionString(componentInstance as Ellipse, layoutOutput);
					}
					
					styleValue = getFill(componentInstance as FilledElement, styleValue, svgDefinitions);
					styleValue = getStroke(componentInstance as StrokedElement, styleValue, svgDefinitions);
					
					styleValue += userInstanceStyles;
					stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
					
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += setUserAttributes(htmlAttributes);
					layoutOutput += closeTag(componentInstance);
					layoutOutput += newLine + tabs + tab + "</" + htmlName + ">";
					
					if (svgDefinitions.length) {
						layoutOutput += newLine + StringUtils.indent(svgDefinitions.join("\n"), tabs+tab);
					}
					
					layoutOutput += newLine + tabs + getWrapperTag(wrapperTag, true);
				}
				else if (localName=="graphic") {
					
					htmlName = "svg";
					
					wrapperTag = "svg";
					styleValue = "";
					
					/*
					<svg height="210" width="500">
					<line x1="0" y1="0" x2="200" y2="200" style="stroke:rgb(255,0,0);stroke-width:2" />
					</svg>
					*/
					
					layoutOutput = "<" + htmlName + " " + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput, "", true);
					
					if (localName=="graphic") {
						layoutOutput = getSVGViewBox(componentInstance, layoutBase, layoutOutput);
					}
					
					//styleValue = isInBasicLayout ? "position:absolute;" : "";
					styleValue = isInBasicLayout ? "position:absolute;" : "";
					styleValue += getSVGSize(componentInstance, layoutBase);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					
					styleValue += userInstanceStyles;
					stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
					
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += setUserAttributes(htmlAttributes);
					layoutOutput += closeTag(componentInstance);
					
					layoutOutput += componentInstance.numElements==0? "&#160;": contentToken;
					
					layoutOutput += newLine + tabs + "</" + htmlName + ">";
				}
				else {
					
					// add error if we are converting to an image on purpose
					// we will create a snapshot if it's an error
					if (!convertElementToImage) {
						errorData = new ErrorData();
						errorData.description = componentDescription.className + " is not supported in HTML export at this time.";
						errorData.label = "Unsupported component";
						errors.push(errorData);
						componentNotFound = true;
					}
					
					// create code for element type or image
					if (convertElementToImage || (componentNotFound && showImageWhenComponentNotFound)) {
						//imageDataStyle = "\tbackground-image: url(data:image/jpeg;base64,"+imageData+");";
						//imageDataStyle = convertComponentToImage(componentInstance);
						//styleValue += "" + imageDataStyle;
						htmlName = tagName ? tagName : "img";
						
						layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
						layoutOutput += "<" + htmlName + " " + properties;
						layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput, "", true);
						layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
						styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
						styleValue += isInVerticalLayout ? getDisplayBlock(componentInstance) : "";
						styleValue += getVisibleDisplay(componentInstance);
						layoutOutput += properties ? " " : "";
						
						layoutOutput += " src=\"" + DisplayObjectUtils.getBase64ImageDataString(componentInstance, imageDataFormat) + "\"";
						
						styleValue += userInstanceStyles;
						stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
						
						layoutOutput += setStyles(componentInstance, styleValue);
						layoutOutput += setUserAttributes(htmlAttributes);
						layoutOutput += closeTag(componentInstance);
						layoutOutput += getWrapperTag(wrapperTag, true);
						
						// if exporting an image then don't export the contents 
						//exportChildDescriptors = false;
						contentToken = "";
					}
					else {
						// show placeholder NOT actual component
						htmlName = tagName ? tagName : "label";
						
						layoutOutput += "<" + htmlName + " "  + properties;
						
						if (componentInstance is GraphicElement && componentInstance.id==null) {
							// graphic element has no name property
							componentInstance.id = NameUtil.createUniqueName(componentInstance);
						}
						
						layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
						layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
						
						styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet, isVerticalCenterSet);
						styleValue += isInVerticalLayout ? getDisplayBlock() : "";
						styleValue = getFontColor(componentInstance, styleValue);
						
						styleValue = getFontFamily(componentInstance, styleValue);
						styleValue = getFontWeight(componentInstance, styleValue);
						styleValue = getFontSize(componentInstance, styleValue);
						styleValue = getLineHeight(componentInstance, styleValue, true);
						styleValue = getPadding(componentInstance, styleValue);
						
						layoutOutput += properties ? " " : "";
						// remove wrapperTagStyles since we are trying to not use wrapper tags
						//output += setStyles(componentInstance, styleValue+wrapperTagStyles);
						//output += setStyles(componentInstance, wrapperTagStyles+styleValue);
						//stylesOut = wrapperTagStyles + styleValue;
						stylesOut = styleValue;
						//layoutOutput += setStyles(componentInstance, wrapperTagStyles + styleValue);
						layoutOutput += getIdentifierOrName(componentInstance);
						layoutOutput += setStyles(componentInstance, styleValue);
						layoutOutput += setUserAttributes(htmlAttributes);
						layoutOutput += closeTag(componentInstance);
						layoutOutput += "</" + htmlName + ">";
						
						layoutOutput += getWrapperTag(wrapperTag, true);
					}
					
				}
				
				
				// we need to put this wrapper code here rather than in the code above
				// because some code for things like the loop don't work if wrapped in div
				//if (useWrapperDivs || wrapperTag) {
				if (false) {
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles) + layoutOutput;
					layoutOutput = getWrapperTag(wrapperTag, true);
				}
				
				// for tile group
				if (endOfColumn) {
					layoutOutput += "<br />";
				}

				if (htmlBefore) {
					layoutOutput = htmlBefore + layoutOutput;
				}
				
				if (htmlAfter) {
					layoutOutput = layoutOutput + htmlAfter;
				}
				
				// add tabs
				if (layoutOutput!="") {
					if (useUpdatedIndent) {
						layoutOutput = StringUtils.indent(layoutOutput, tabs);
					}
					else {
						layoutOutput = tabs + layoutOutput;
					}
				}
				
				// add anchor - rewrite this using pre or post processor
				if (wrapWithAnchor) {
					anchor = <a/>;
					
					if (anchorURL) {
						anchor.@href = anchorURL;
					}
					
					if (anchorTarget) {
						anchor.@target = anchorTarget;
					}
					
					layoutOutput = initialTabs + XMLUtils.getOpeningTag(anchor)  + "\n" + StringUtils.indent(layoutOutput) + "\n" + initialTabs + "</a>";
				}
				
				// add special wordpress loop code (rewrite later by saving markup to custom field - this will be gone) 
				if (identity && identity.toLowerCase()=="theloop") {
					layoutOutput = "\n" + initialTabs + "<!--the loop-->"  + "\n" + layoutOutput + "\n" + initialTabs + "<!--the loop-->";
				}
				
				
				if (identity) {
					
					if (identifiers.indexOf(identity)!=-1) {
						duplicateIdentifiers.push(identity);
						
						errorData = ErrorData.getIssue("Duplicate Identifier", "There is more than one component using the id '" + identity + "'");
						errors.push(errorData);
					}
					else {
						identifiers.push(identity);
					}
				}
				
				if (localName=="application" && !addContainerDiv) {
					newLine = "";
					//tabs = "";
				}
				else {
					tabs = tabs + "\t";
				}
				
				// add children
				if (exportChildDescriptors && 
					componentDescription.children && 
					componentDescription.children.length>0 && 
					!convertElementToImage) {
					//output += ">\n";
					
					numberOfChildren = exportChildDescriptors ? componentDescription.children.length : 0;
					
					for (var i:int;i<numberOfChildren;i++) {
						componentChild = componentDescription.children[i];
						
						if (exportFromHistory) {
							///getAppliedPropertiesFromHistory(iDocument, componentChild);
						}
						
						if (i>0) {
							childContent += "\n";
						}
						
						childContent += getHTMLOutputString(iDocument, componentChild, false, tabs);
					}
					
					componentDescription.markupData = layoutOutput;
					componentDescription.stylesData = stylesOut;
					
					layoutOutput = layoutOutput.replace(contentToken, newLine + childContent);
					
					componentDescription.processedMarkupData = layoutOutput;
					componentDescription.processedStylesData = stylesOut;

				}
				else {
					componentDescription.markupData = layoutOutput;
					componentDescription.stylesData = stylesOut;
					
					if (exportChildDescriptors && contentToken!="") {
						layoutOutput = layoutOutput.replace(contentToken, newLine);
					}
					
					componentDescription.processedMarkupData = layoutOutput;
					componentDescription.processedStylesData = stylesOut;
				}
			}
			else {
				layoutOutput = "";
			}
			
			//exportChildDescriptors = true;
			
			return layoutOutput;
		}
		
		/**
		 * UPDATE: This is the start of a refactor
		 * Previous comments below: 
		 * ----
		 * Gets the formatted output from a component.
		 * Yes, this is hacky. It needs rewritten.  
		 * I wanted to see if I could quickly generate valid HTML 
		 * from the component tree and didn't know the performance cost
		 * of using XML objects (need to test). Would like to use OOP or XML E4X
		 * but whatever it is it must support plugins, pre and post processors.
		 * 
		 * A problem using XML is that HTML is not XML. Some XML tags will not work. 
		 * 
		 * I did start though. There is partial work with CSS properties objects 
		 * but those aren't used yet. 
		 * Basically you set the properties and styles on an object instead of inline
		 * and then call propertyObject.toString(). The method would handle
		 * formatting, tab spacings and possibly wrapper objects.
		 * Wrapper objects... that's another thing. 
		 * Different elements would extend an HTMLElement object.
		 * ----
		 * */
		public function getHTMLOutputStringNEW(iDocument:IDocument, componentDescription:ComponentDescription, addLineBreak:Boolean = false, tabs:String = "", includePreview:Boolean = false):String {
			/* 
			var componentName:String = componentDescription.className ? componentDescription.className.toLowerCase() : "";
			var localName:String = componentName ? componentName : "";
			var componentChild:ComponentDescription;
			var instanceName:String = componentInstance && "name" in componentInstance ? componentInstance.name : "";
			var instanceID:String = componentInstance && "id" in componentInstance ? componentInstance.id : "";
			var identity:String = ClassUtils.getIdentifier(componentInstance);
			var isGraphicalElement:Boolean = componentDescription.isGraphicElement;
			var styleValue:String = "position:absolute;";
			var stylesOut:String = "";
			var wrapperStylesModel:HTMLStyles = new HTMLStyles();
			var childContent:String = "";
			var wrapperTag:String = "";
			var centeredHorizontally:Boolean;
			var wrapperTagStyles:String = "";
			var wrapperSVGStyles:String = "";
			var properties:String = "";
			var outlineStyle:String;
			var initialTabs:String = tabs;
			var componentNotFound:Boolean;
			var layoutOutput:String = "";
			var numberOfChildren:int;
			var type:String = "";
			var instance:Object;
			var htmlName:String;
			var tracking:Number;
			var borderColor:String;
			var index:int;
			var value:*;
			var newLine:String = "\n";
			var imageDataStyle:String;
			var imageDataFormat:String = "png";
			var isHorizontalCenterSet:Boolean;
			var isVerticalCenterSet:Boolean;
			var anchor:XML;
			var constrainedLocation:String = ConstrainedLocations.TOP_LEFT;
			*/
			var htmlElement:HTMLElement;
			var wrapWithAnchor:Boolean;
			var anchorURL:String;
			var anchorTarget:String;
			
			var stylesModel:HTMLStyles;
			var userInstanceStyles:String;
			var propertyList:Object;
			var propertiesStylesObject:Object;
			var targetElementLocation:String;
			
			var layoutBase:LayoutBase;
			var basicLayout:BasicLayout;
			var horizontalLayout:HorizontalLayout;
			var verticalLayout:VerticalLayout;
			var tileLayout:TileLayout;
			var visualElementContainer:IVisualElementContainer;
			var displayObjectContainer:DisplayObjectContainer;
			var groupBaseContainer:GroupBase;
			
			var containerVerticalAlign:String;
			var containerHorizontalAlign:String;
			var columnCount:int;
			var columnWidth:int;
			var rowCount:int;
			var rowHeight:int;
			
			var numberOfElements:int;
			var elementIndex:int;
			var endOfRow:Boolean;
			var endOfColumn:Boolean;
			
			var horizontalGap:int;
			var verticalGap:int;
			
			var isInHorizontalLayout:Boolean;
			var isInVerticalLayout:Boolean;
			var isInBasicLayout:Boolean;
			var isInTileLayout:Boolean;
			
			var componentInstance:Object;
			var errorData:ErrorData;
			
			var exportChildContent:Boolean;
			var value:Object;
			
			var addSnapshotToBackground:Boolean;
			var convertElementToImage:Boolean;
			
			var tagName:String;
			var elementType:HTMLElement;
			
			/////////////////////////////////////////////
			// start
			/////////////////////////////////////////////
			componentInstance = componentDescription.instance;
			
			// should add warning that element is missing
			if (componentInstance==null) {
				errorData = new ErrorData();
				errorData.description = componentDescription.name + " is not supported in HTML export at this time.";
				errorData.label = "Unsupported component";
				errors.push(errorData);
				return "";
			}
			
			if (componentDescription.htmlTagName) {
				tagName = componentDescription.htmlTagName;
			}
			else {
				
			}
			
			propertyList 			= componentDescription.properties;
			propertiesStylesObject 	= ObjectUtils.merge(componentDescription.properties, componentDescription.styles);
			
			
			wrapWithAnchor 	= componentDescription.wrapWithAnchor;
			anchorURL 		= componentDescription.anchorURL;
			anchorTarget	= componentDescription.anchorTarget;
			
			userInstanceStyles = componentDescription.userStyles;
			
			// if not null replace 
			if (userInstanceStyles==null || userInstanceStyles == "null") {
				userInstanceStyles = "";
			}
			else {
				userInstanceStyles = userInstanceStyles.replace(/\n/g, ""); // /\r?\n|\r/g
			}
			
			stylesModel				= new HTMLStyles();
			stylesModel.position 	= HTMLStyles.ABSOLUTE;
			stylesModel.user 		= userInstanceStyles;
			
			
			if (componentDescription.htmlClassType) {
				htmlElement 			= new componentDescription.htmlClassType();
			}
			else {
				htmlElement 			= new HTMLElement();
			}
			
			if (componentDescription.parent) {
				visualElementContainer 	= componentDescription.parent.instance as IVisualElementContainer;
				displayObjectContainer 	= componentDescription.parent.instance as DisplayObjectContainer;
				groupBaseContainer 		= componentDescription.parent.instance as GroupBase;
			}
			
			// get layout positioning
			if (groupBaseContainer) {
				layoutBase 			= groupBaseContainer.layout;
				numberOfElements	= groupBaseContainer.numElements;
				elementIndex 		= groupBaseContainer.getElementIndex(componentInstance as IVisualElement);
				
				
				if (layoutBase is BasicLayout) {
					isInBasicLayout 		= true;
					stylesModel.position 	= HTMLStyles.ABSOLUTE;
					stylesModel.display 	= HTMLStyles.BLOCK;
				}
				else if (layoutBase is HorizontalLayout) {
					isInHorizontalLayout 		= true;
					horizontalLayout 			= layoutBase as HorizontalLayout;
					stylesModel.position 		= HTMLStyles.RELATIVE;
					stylesModel.display 		= hasExplicitSizeSet(componentInstance as IVisualElement) ? HTMLStyles.INLINE_BLOCK : HTMLStyles.INLINE;
					horizontalGap 				= horizontalLayout.gap;
					containerVerticalAlign 		= horizontalLayout.verticalAlign;
					containerHorizontalAlign 	= horizontalLayout.horizontalAlign;
					stylesModel.verticalAlign 	= containerVerticalAlign;
					stylesModel.horizontalAlign = containerHorizontalAlign;
					
					// if not last element 
					// add margin to the right of the element to simulate a gap
					if (elementIndex<numberOfElements-1 && numberOfElements>1) {
						
						if (useSpacerForGap) {
							// todo: add support for gap spacers 
						}
						else {
							stylesModel.marginRight = horizontalGap + "px";
						}
					}
					
				}
				else if (layoutBase is VerticalLayout) {
					isInVerticalLayout 			= true;
					verticalLayout 				= layoutBase as VerticalLayout;
					stylesModel.position 		= HTMLStyles.RELATIVE;
					stylesModel.display 		= hasExplicitSizeSet(componentInstance as IVisualElement) ? HTMLStyles.INLINE_BLOCK : HTMLStyles.INLINE;
					verticalGap 				= verticalLayout.gap;
					containerVerticalAlign 		= verticalLayout.verticalAlign;
					containerHorizontalAlign 	= verticalLayout.horizontalAlign;
					stylesModel.verticalAlign 	= containerVerticalAlign;
					stylesModel.horizontalAlign = containerHorizontalAlign;
					
					// if not last element 
					// add margin to the bottom of the element to simulate a gap
					if (elementIndex<numberOfElements-1 && numberOfElements>1) {
						
						if (useSpacerForGap) {
							// todo: add support for gap spacers 
						}
						else {
							stylesModel.marginBottom = verticalGap + "px";
						}
					}
					
				}
				else if (layoutBase is TileLayout) {
					isInTileLayout 				= true;
					tileLayout 					= layoutBase as TileLayout;
					horizontalGap 				= tileLayout.horizontalGap;
					verticalGap 				= tileLayout.verticalGap;
					containerVerticalAlign 		= tileLayout.verticalAlign;
					containerHorizontalAlign 	= tileLayout.horizontalAlign;
					columnCount					= tileLayout.columnCount;
					columnWidth 				= tileLayout.columnWidth;
					rowCount					= tileLayout.rowCount;
					rowHeight 					= tileLayout.rowHeight;
					
					stylesModel.verticalAlign 	= containerVerticalAlign;
					stylesModel.horizontalAlign = containerHorizontalAlign;
					stylesModel.position 		= HTMLStyles.RELATIVE;
					stylesModel.display 		= hasExplicitSizeSet(componentInstance as IVisualElement) ? HTMLStyles.INLINE_BLOCK : HTMLStyles.INLINE;
					
					if ((elementIndex+1) % columnCount==0) {
						endOfColumn = true;
					}
					else {
						endOfColumn = false;
					}
					
					if ((elementIndex+1) % rowCount==0) {
						endOfRow = true;
					}
					else {
						endOfRow = false;
					}
					
					// if end of column add a new row  
					if (endOfColumn) {
						htmlElement.rightAdjacentElements.push(new HTMLLineBreak());
					}
					
					// if not last element 
					// add margin to the right of the element to simulate a gap
					if (!endOfColumn) {
						
						if (useSpacerForGap) {
							htmlElement.rightAdjacentElements.push(new HTMLMargin(String(horizontalGap)));
						}
						else {
							stylesModel.marginRight = horizontalGap + "px";
						}
					}
					
					// if not last element 
					// add margin to the bottom of the element to simulate a gap
					if (elementIndex<numberOfElements-1 && numberOfElements>1) {
						
						if (useSpacerForGap) {
							// todo: add support for gap spacers 
						}
						else {
							stylesModel.marginBottom = verticalGap + "px";
						}
					}
				}
			}
			
			//exportChildDescriptors = componentDescription.exportChildDescriptors;
			
			if (exportChildDescriptors==false || componentDescription.exportChildDescriptors==false) {
				//contentToken = "";
				exportChildContent = false;
			}
			else {
				exportChildContent = true;
			}
			
			if (isInBasicLayout) {
				// constraints take higher authority
				// check for layout rules 
				
				///////////////////
				// TOP
				///////////////////
				
				// TOP and LEFT
				if (propertiesStylesObject[ConstrainedLocations.TOP]!=null && 
					propertiesStylesObject[ConstrainedLocations.LEFT]!=null) {
					targetElementLocation = ConstrainedLocations.TOP_LEFT;
				}
					
					// TOP and CENTER
				else if (propertiesStylesObject[ConstrainedLocations.TOP]!=null && 
					propertiesStylesObject[ConstrainedLocations.HORIZONTAL_CENTER]!=null) {
					targetElementLocation = ConstrainedLocations.TOP_CENTER;
				}
					
					// TOP and RIGHT
				else if (propertiesStylesObject[ConstrainedLocations.TOP]!=null && 
					propertiesStylesObject[ConstrainedLocations.RIGHT]!=null) {
					targetElementLocation = ConstrainedLocations.TOP_RIGHT;
				}
					
					///////////////////
					// MIDDLE
					///////////////////
					
					// MIDDLE and LEFT
				else if (propertiesStylesObject[ConstrainedLocations.VERTICAL_CENTER]!=null && 
					propertiesStylesObject[ConstrainedLocations.LEFT]!=null) {
					targetElementLocation = ConstrainedLocations.MIDDLE_LEFT;
				}
					
					// HORIZONTAL CENTER and VERTICAL CENTER
				else if (propertiesStylesObject[ConstrainedLocations.HORIZONTAL_CENTER]!=null && 
					propertiesStylesObject[ConstrainedLocations.VERTICAL_CENTER]!=null) {
					targetElementLocation = ConstrainedLocations.MIDDLE_CENTER;
				}
					
					// MIDDLE and RIGHT
				else if (propertiesStylesObject[ConstrainedLocations.VERTICAL_CENTER]!=null && 
					propertiesStylesObject[ConstrainedLocations.RIGHT]!=null) {
					targetElementLocation = ConstrainedLocations.MIDDLE_RIGHT;
				}
					
					////////////////////
					// BOTTOM
					///////////////////
					
					// BOTTOM and LEFT
				else if (propertiesStylesObject[ConstrainedLocations.BOTTOM]!=null && 
					propertiesStylesObject[ConstrainedLocations.LEFT]!=null) {
					targetElementLocation = ConstrainedLocations.BOTTOM_LEFT;
				}
					
					// BOTTOM and CENTER
				else if (propertiesStylesObject[ConstrainedLocations.BOTTOM]!=null && 
					propertiesStylesObject[ConstrainedLocations.HORIZONTAL_CENTER]!=null) {
					targetElementLocation = ConstrainedLocations.BOTTOM_CENTER;
				}
					
					// BOTTOM and RIGHT
				else if (propertiesStylesObject[ConstrainedLocations.BOTTOM]!=null && 
					propertiesStylesObject[ConstrainedLocations.RIGHT]!=null) {
					targetElementLocation = ConstrainedLocations.BOTTOM_RIGHT;
				}
			}
			
			addSnapshotToBackground = componentDescription.createBackgroundSnapshot;
			convertElementToImage = componentDescription.convertElementToImage;
			
			htmlElement.updateDescription(componentDescription);
			//htmlElement.updateStyles(componentDescription);
			
			/*
			if (!putStylesInline) {
			stylesValues = htmlElement.stylesToString();
			or 
			stylesArray.push(htmlElement.stylesArray);
			}
			*/
			return htmlElement.toString();
		}
		
		public function getBackgroundImageData(componentInstance:Object, imageDataFormat:String = "png", color:Number = NaN, alpha:Number = 0.5, linebreaks:Boolean = false):String {
			var imageData:String;
			var imageDataStyle:String;
			
			imageData = DisplayObjectUtils.getBase64ImageDataString(componentInstance, imageDataFormat, null, true, color, alpha, linebreaks);
			imageDataStyle = "";
			imageDataStyle += "background: no-repeat url(" + imageData + ");";
			
			return imageDataStyle;
		}
		
		public function convertComponentToImage(componentInstance:Object, imageDataFormat:String = "png"):String {
			//var backgroundImageID:String = "backgroundComparisonImage";
			var imageData:String = DisplayObjectUtils.getBase64ImageDataString(componentInstance, imageDataFormat);
			var imageSnapshot:String = "<img ";
			imageSnapshot += " src=\"" + imageData + "\" >";
			return imageSnapshot;
		}
		
		/**
		 * A hook to modify the styles before it is output
		 * */
		public var stylesHookFunction:Function;
		
		/**
		 * A hook to modify the markup before it is output
		 * */
		public var markupHookFunction:Function;
		
		/**
		 * Adds a negative top margin of .2em to adjust for browsers. Flash text is flush to the top while html text is not. 
		 * http://stackoverflow.com/questions/34983672/is-there-a-way-to-make-text-characters-flush-to-the-top-of-their-bounding-box-in/35060979#35060979
		 * */
		public function addTopMarginFix(componentInstance:Object, styleValue:String, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			if (styleClient==null) return styleValue;
			
			styleValue += "margin-top: -0.2em;"
			
			return styleValue;
		}
		
		/**
		 * Gets the tracking left or right
		 * */
		public function getTracking(componentInstance:Object, styleValue:String, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			if (styleClient==null) return styleValue;
			var tracking:Number = 0;
			
			// probably need to check if inline or inherited. see other methods
			if (styleClient.getStyle("trackingLeft")!=0) {
				tracking = Number(styleClient.getStyle("trackingLeft"));
			}
			
			if (styleClient.getStyle("trackingRight")!=0) {
				tracking += Number(styleClient.getStyle("trackingRight"));
			}
			
			if (getInherited || tracking!=0) {
				styleValue += "letter-spacing:" + tracking + "px;";
			}
			
			return styleValue;
		}
		
		/**
		 * Gets the scroll policy
		 * */
		public function getScrollPolicy(componentInstance:Object, styleValue:String, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			if (styleClient==null) return styleValue;
			
			var verticalScrollPolicy:String;
			var horizontalScrollPolicy:String;
			var clipAndEnableScrolling:Boolean;
			var hasScrollPolicy:Boolean;
			var isSet:Boolean;
			
			// for GroupBase
			if ("clipAndEnableScrolling" in componentInstance) {
				clipAndEnableScrolling = componentInstance.clipAndEnableScrolling;
				
				if (clipAndEnableScrolling) {
					styleValue += "overflow:" + "auto;"; // or scroll
				}
				else {
					styleValue += "overflow:" + "visible;" // or hidden
				}
			}
			else if (StyleUtils.hasStyle(styleClient, VERTICAL_SCROLL_POLICY) || 
				StyleUtils.hasStyle(styleClient, HORIZONTAL_SCROLL_POLICY)) {
				
				// NOT FINISHED
				// for ListBase
				if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "verticalScrollPolicy")) {
					verticalScrollPolicy = styleClient.getStyle("verticalScrollPolicy");
					horizontalScrollPolicy = styleClient.getStyle("horizontalScrollPolicy");
					
					if (verticalScrollPolicy && (verticalScrollPolicy !== ScrollPolicy.AUTO)) {
						isSet = true;
					}
					
					if (horizontalScrollPolicy && (horizontalScrollPolicy !== ScrollPolicy.AUTO)) {
						isSet = true;
					}
					
				}
				// not finished
				styleValue += "overflow:" + "auto;"; // or scroll
			}
			else if (styleClient is BorderContainer || styleClient is SkinnableComponent) {
				styleValue += "overflow:" + "auto;"; // or scroll
			}
			//if (!isSet) {
				//styleValue += "overflow:" + "auto;"
			//}
			
			return styleValue;
		}
		
		/**
		 * Gets the typographic case
		 * */
		public function getTypographicCase(componentInstance:Object, styleValue:String, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			if (styleClient==null) return styleValue;
			
			// might need to check if typographic case is default and reset to actual html default value
			// if (getInherited || componentInstance.getStyle("typographicCase")!="default") {
			
			if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "typographicCase")) {
				styleValue += "text-transform:" + componentInstance.getStyle("typographicCase") + ";";
			}
			
			return styleValue;
		}
		
		/**
		 * Gets the font color
		 * */
		public function getFontColor(componentInstance:Object, styleValue:String, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			if (styleClient==null) return styleValue;
			
			if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "color")) {
				styleValue += "color:" + DisplayObjectUtils.getColorInHex(styleClient.getStyle("color"), true) + ";"
			}
			
			return styleValue;
		}
		
		/**
		 * Get border and background styles of a border container. Not finished
		 * */
		public function getBorderString(componentInstance:Object, styleValue:String, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			if (styleClient==null) return styleValue;
			
			var borderWeight:Number;
			var borderVisible:Boolean;
			var borderSides:String;
			var borderValues:String;
			
			if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "borderWeight")) {
				borderWeight = styleClient.getStyle("borderWeight");
			}
			
			/*
			if (styleClient.getStyle("backgroundAlpha")!=0) {
				styleValue += "background-color:" + DisplayObjectUtils.getColorInRGB(styleClient.getStyle("backgroundColor"), styleClient.getStyle("backgroundAlpha")) + ";";
			}*/
			
			if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "borderVisible")) {
				
				if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "borderSides")) {
					borderSides = styleClient.getStyle("borderSides");
				}
				else {
					borderSides = "";
				}
				
				if (borderSides!="left top right bottom") {
					borderValues = "";
					
					borderValues += (borderSides.indexOf("top")!=-1) ? borderWeight + "px" : "0px";
					borderValues += (borderSides.indexOf("right")!=-1) ? borderWeight + "px" : "0px";
					borderValues += (borderSides.indexOf("bottom")!=-1) ? borderWeight + "px" : "0px";
					borderValues += (borderSides.indexOf("left")!=-1) ? borderWeight + "px" : "0px";
					
					styleValue += "border-width:" + borderValues;
				}
				else {
					styleValue += "border-width:" + borderWeight + "px;";
				}
				
				if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "borderColor")) {
					styleValue += "border-color:" + DisplayObjectUtils.getColorInHex(styleClient.getStyle("borderColor"), true) + ";";
				}
				
				borderVisible = styleClient.getStyle("borderVisible") as Boolean;
				
				if (StyleUtils.hasStyle(styleClient, "borderVisible")==true && borderVisible==false) {
					styleValue += "border-style:" + "none" + ";";
				}
				else {
					styleValue += "border-style:solid;";
				}
				
				if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "cornerRadius")) {
					styleValue += "border-radius:" + styleClient.getStyle("cornerRadius") + "px;";
				}
			}
			
			return styleValue;
		}
		
		/**
		 * Gets the text align
		 * */
		public function getTextAlign(componentInstance:Object, styleValue:String, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			if (styleClient==null) return styleValue;
			
			if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "textAlign")) {
				styleValue += "text-align:" + styleClient.getStyle("textAlign") + ";";
			}
			
			return styleValue;
		}
		
		/**
		 * Gets background color
		 * */
		public function getBackgroundColor(componentInstance:Object, styleValue:String, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			if (styleClient==null) return styleValue;
			
			if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "backgroundColor")) {
				
				if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "backgroundAlpha")) {
					styleValue += "background-color:" + DisplayObjectUtils.getColorInRGB(componentInstance.getStyle("backgroundColor"), componentInstance.getStyle("backgroundAlpha")) + ";";
				}
				else {
					styleValue += "background-color:" + DisplayObjectUtils.getColorInHex(componentInstance.getStyle("backgroundColor"), true) + ";";
				}
			}
			
			return styleValue;
		}
		
		/**
		 * Gets the font family
		 * */
		public function getFontFamily(componentInstance:Object, styleValue:String, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			if (styleClient==null) return styleValue;
			
			if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "fontFamily")) {
				styleValue += "font-family:" + FontUtils.getSanitizedFontName(componentInstance) + ";"
			}
			
			return styleValue;
		}
		
		/**
		 * Gets the font weight
		 * */
		public function getFontStyle(componentInstance:Object, styleValue:String, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			if (styleClient==null) return styleValue;
			
			if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "fontStyle")) {
				styleValue += "font-style:" + styleClient.getStyle("fontStyle") + ";"
			}
			
			return styleValue;
		}
		
		/**
		 * Gets the border color
		 * */
		public function getBorderColor(componentInstance:Object, styleValue:String, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			if (styleClient==null) return styleValue;
			
			if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "borderColor")) {
				styleValue += "border-color:" + styleClient.getStyle("borderColor") + ";"
			}
			
			return styleValue;
		}
		
		/**
		 * Gets the font weight
		 * */
		public function getFontWeight(componentInstance:Object, styleValue:String, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			if (styleClient==null) return styleValue;
			
			if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "fontWeight")) {
				styleValue += "font-weight:" + styleClient.getStyle("fontWeight") + ";"
			}
			
			return styleValue;
		}
		
		/**
		 * Gets the font size
		 * */
		public function getFontSize(componentInstance:Object, styleValue:String, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			if (styleClient==null) return styleValue;
			
			if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "fontSize")) {
				styleValue += "font-size:" + styleClient.getStyle("fontSize") + "px;"
			}
			
			return styleValue;
		}
		
		/**
		 * Gets the line height
		 * */
		public function getLineHeight(componentInstance:Object, styleValue:String, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			if (styleClient==null) return styleValue;
			
			if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "lineHeight")) {
				styleValue += "line-height:" + parseInt(styleClient.getStyle("lineHeight"))/100 + ";"
			}
			
			return styleValue;
		}
		
		/**
		 * Gets the padding
		 * */
		public function getPadding(componentInstance:Object, styleValue:String, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			if (styleClient==null) return styleValue;
			
			if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "padding")) {
				styleValue += "padding:" + parseInt(styleClient.getStyle("padding")) + "px;"
			}
			if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "paddingBottom")) {
				styleValue += "padding-bottom:" + parseInt(styleClient.getStyle("paddingBottom")) + "px;"
			}
			
			if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "paddingTop")) {
				styleValue += "padding-top:" + parseInt(styleClient.getStyle("paddingTop")) + "px;"
			}
			
			if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "paddingLeft")) {
				styleValue += "padding-left:" + parseInt(styleClient.getStyle("paddingLeft")) + "px;"
			}
			
			if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "paddingRight")) {
				styleValue += "padding-right:" + parseInt(styleClient.getStyle("paddingRight")) + "px;"
			}
			
			return styleValue;
		}
		
		/**
		 * Gets the alpha
		 * */
		public function getAlpha(componentInstance:Object, styleValue:String):String {
			if ("alpha" in componentInstance && componentInstance.alpha!=1) {
				styleValue += "opacity:" + componentInstance.alpha + ";"
			}
			
			return styleValue;
		}
		
		/**
		 * Gets the stroke weight
		 * */
		public function getLineWeight(componentInstance:Object, styleValue:String):String {
			if ("strokeWeight" in componentInstance && componentInstance.strokeWeight!=1) {
				styleValue += "stroke-width:" + componentInstance.strokeWeight+ ";"
			}
			
			return styleValue;
		}
		
		/**
		 * Gets the line color
		 * */
		public function getLineColor(componentInstance:Object, styleValue:String):String {
			if ("color" in componentInstance && componentInstance.color!=0) {
				styleValue += "stroke:" + DisplayObjectUtils.getColorInRGB(componentInstance.color, componentInstance.alpha) + ";";
			}
			
			return styleValue;
		}
		
		/**
		 * Gets the stroke
		 * 
		 * https://svgwg.org/specs/strokes/
		 * */
		public function getStroke(componentInstance:StrokedElement, styleValue:String, svgDefinitions:Array = null):String {
			var solidColorStroke:SolidColorStroke;
			
			solidColorStroke = componentInstance.stroke as SolidColorStroke;
			
			if (solidColorStroke) {
				styleValue += "stroke:" + DisplayObjectUtils.getColorInRGB(solidColorStroke.color, solidColorStroke.alpha) + ";";
				styleValue += "stroke-width:" + solidColorStroke.weight + "px;";
				styleValue += "stroke-linejoin:" + solidColorStroke.joints + ";";
					
				if (solidColorStroke.caps==CapsStyle.NONE) {
					styleValue += "stroke-linecap:" + "butt" + ";";
				}
				else {
					styleValue += "stroke-linecap:" + solidColorStroke.caps + ";";
				}
				
				styleValue += "stroke-miterlimit:" + solidColorStroke.miterLimit + ";";
				styleValue += "stroke-align:" + "center" + ";";
				
			}
			
			
			return styleValue;
		}
		
		/**
		 * Gets the fill
		 * 
		 * https://www.w3.org/TR/SVG/pservers.html#StopElement
		 * */
		public function getFill(componentInstance:FilledElement, styleValue:String, definition:Array = null):String {
			var gradientBase:GradientBase;
			var linear:LinearGradient;
			var radial:RadialGradient;
			var solid:SolidColor;
			var fill:IFill;
			var gradientXML:XML;
			var entryXML:XML;
			var entry:GradientEntry;
			var entries:Array;
			var numberOfEntries:int;
			var id:String;
			
			fill = componentInstance.fill as IFill;
			
			if (fill) {
				
				if (fill is GradientBase) {
					linear = fill as LinearGradient;
					radial = fill as RadialGradient;
					gradientBase = fill as GradientBase;

					if (linear) {
						gradientXML = new XML("<linearGradient/>");
					}
					else if (radial) {
						gradientXML = new XML("<radialGradient/>");
					}
					
					id = NameUtil.createUniqueName(gradientBase);
					gradientXML.@id = id;
					gradientXML.@spreadMethod = gradientBase.spreadMethod;
					gradientXML.@gradientTransform = "rotate(" + gradientBase.rotation + ")";
					entries = gradientBase.entries;
					numberOfEntries = entries ? entries.length : 0;
					
					for (var i:int; i < numberOfEntries; i++) {
						entry = entries[i];
						entryXML = new XML("<stop/>");
						entryXML.@offset = entry.ratio;
						entryXML["@stop-color"] = DisplayObjectUtils.getColorInHexWithHash(entry.color);
						entryXML["@stop-opacity"] = entry.alpha;
						gradientXML.appendChild(entryXML);
					}
					
					styleValue += "fill:url(#" + id + ");";
					
					if (componentInstance is Path) {
						styleValue += "fill-rule:" + Path(componentInstance).winding.toLowerCase() + ";";
					}
					
					if (definition) {
						definition.push(gradientXML.toXMLString());
					}
				}
				else if (fill is SolidColor) {
					solid = fill as SolidColor;
					//styleValue += "fill:" + DisplayObjectUtils.getColorInRGB(solid.color, solid.alpha) + ";";
					styleValue += "fill:" + DisplayObjectUtils.getColorInHexWithHash(solid.color) + ";";
					styleValue += "fill-opacity:" + solid.alpha + ";";
				}
				
			}
			else if (componentInstance is GraphicElement) {
				styleValue += "fill:" + "transparent" + ";";
			}
			
			
			return styleValue;
		}
		
		/**
		 * Centering vertically
		 * */
		public function centerVertically():void {
			/*
			.container {
				position: absolute;
				display: table;
				width: 100%;
				height: 100%;
			}
			.containerElement{
				display: table-cell;
				vertical-align: middle;
			}
			*/
		}
		
		/**
		 * Adds a negative top margin of .2em to adjust for browsers. Flash text is flush to the top while html text is not. 
		 * http://stackoverflow.com/questions/34983672/is-there-a-way-to-make-text-characters-flush-to-the-top-of-their-bounding-box-in/35060979#35060979
		 * 
		 * See note on #paddingFromBrowserTextEngine.
		 * If in vertically centered box the browser seems to align it correctly. 
		 * Otherwise large fonts are pushed down 
		 * @see #paddingFromBrowserTextEngine
		 * */
		public function getMarginTopAdjustment(componentInstance:Object, isVerticalCenterSet:Boolean, styleValue:String):String {
			// note updated the code from using line-height:.8; to using margin-top:-0.2em;
			
			if (!isVerticalCenterSet) {
				styleValue += "margin-top:-0.2em;"
			}
			
			return styleValue;
		}		
		
		/**
		 * Get a tag with less than or greater than wrapped around it. 
		 * 
<pre>
getWrapperTag(""); // returns ""
getWrapperTag("div"); // returns &lt;div>
getWrapperTag("div", true); // returns &lt;/div>
getWrapperTag("div", false, "color:blue"); // returns &lt;div styles="color:blue;">
</pre>
		 * */
		public function getWrapperTag(wrapperTag:String = "", end:Boolean = false, styles:String = "", attributes:String = ""):String {
			var output:String = "";
			
			if (wrapperTag=="") return "";
			
			if (end) {
				output = "</" + wrapperTag + ">";
				return output;
			}
			
			output += "<" + wrapperTag;
			
			if (attributes) {
				output += " " + attributes;
			}
			
			if (styles) {
				output += " style=\"" + styles + "\"" ;
			}
			
			output += ">";
			
			return output;
		}
		
		/**
		 * Get x and y of GraphicElement
		 * */
		public function getGraphicElementPositionString(componentInstance:GraphicElement, styleValue:String = ""):String {
			
			styleValue += "x:" + componentInstance.x + "px;";
			styleValue += "y:" + componentInstance.y + "px;";
			
			return styleValue;
		}
		
		/**
		 * Get x and y of Ellipse
		 * */
		public function getEllipsePositionString(componentInstance:GraphicElement, layout:String = ""):String {
			var rx:Number = componentInstance.width / 2;
			var ry:Number = componentInstance.height / 2;
			var cx:Number = componentInstance.x + rx;
			var cy:Number = componentInstance.y + ry;
			
			layout = getAttributeLayout("cx", String(cx), layout);
			layout = getAttributeLayout("cy", String(cy), layout);
			layout = getAttributeLayout("rx", String(rx), layout);
			layout = getAttributeLayout("ry", String(ry), layout);
			
			return layout;
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
				styleValue += "display:" + HTMLStyles.INLINE_BLOCK + ";";
			}
			
			return styleValue;
			
		}
		
		/**
		 * Get width and height of Rect
		 * */
		public function getGraphicElementSizeString(instance:IVisualElement, styleValue:String = "", sizeRequired:Boolean = true):String {
			var hasExplicitSize:Boolean;
			var hasBorder:Boolean;
			var border:int;
			
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
			else if (sizeRequired) {
				styleValue += "width:" + instance.width + "px;";
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
			else if (sizeRequired) {
				styleValue += "height:" + instance.height + "px;";
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
			
			// minimum height
			if ("explicitMinHeight" in instance) {
				if (Object(instance).explicitMinHeight!=null && !isNaN(Object(instance).explicitMinHeight)) {
					styleValue += "min-height:" + instance.explicitMinHeight + "px;";
				}
			}
			
			// maximum height
			if ("explicitMaxHeight" in instance) {
				if (Object(instance).explicitMaxHeight!=null && !isNaN(Object(instance).explicitMaxHeight)) {
					styleValue += "max-height:" + instance.explicitMaxHeight + "px;";
				}
			}
			
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
				styleValue += "display:" + HTMLStyles.INLINE_BLOCK + ";";
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
			
			// minimum width
			if ("explicitMinWidth" in instance) {
				if (Object(instance).explicitMinWidth!=null && !isNaN(Object(instance).explicitMinWidth)) {
					styleValue += "min-width:" + instance.explicitMinWidth + "px;";
				}
			}
			
			// maximum width
			if ("explicitMaxWidth" in instance) {
				if (Object(instance).explicitMaxWidth!=null && !isNaN(Object(instance).explicitMaxWidth)) {
					styleValue += "max-width:" + instance.explicitMaxWidth + "px;";
				}
			}
			
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
				styleValue += "display:" + HTMLStyles.INLINE_BLOCK + ";";
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
		 * Clear elements left and right
		 * */
		public function getRowClear(instance:Object = null):String {
			return "clear:both;";
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
		
		public var useTransformCentering:Boolean = true;
		
		/**
		 * Get the horizontal position string for HTML
		 * */
		public function getHorizontalPositionHTML(instance:IVisualElement, propertyModel:HTMLStyles, stylesValue:String = "", isBasicLayout:Boolean = true):String {
			
			if (!isBasicLayout) return stylesValue;
			// horizontal center trumps left and x properties
			if (instance.horizontalCenter!=null) {
				// the following line doesn't work unless the width is set
				//stylesValue += "display:block;margin:" + instance.horizontalCenter + " auto;left:0;right:0;";
				
				if (useTransformCentering) {
					stylesValue += "display:table;"
					stylesValue += "left:50%;transform:translateX(-50%);-webkit-transform:translateX(-50%);-ms-transform:translateX(-50%);";
					propertyModel.display = HTMLStyles.TABLE;
					propertyModel.position = HTMLStyles.ABSOLUTE;
					propertyModel.transform = "transform:translateX(-50%)";
					
				}
				else {
					// using display table allows you to center a item without knowing it's width 
					stylesValue += "display:table;margin:" + instance.horizontalCenter + " auto;left:0;right:0;";
					//stylesValue = stylesValue.replace("absolute", "relative");
					
					propertyModel.display = HTMLStyles.BLOCK;
					//propertyModel.position = Styles.RELATIVE;
					propertyModel.position = HTMLStyles.ABSOLUTE;
					propertyModel.margin = instance.horizontalCenter + " auto;left:0;right:0;";
				}
				
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
		 * Get the vertical position string for HTML element in basic layout
		 * 
		 * Parent element needs preserve 3d to prevent blurry pixels
		 * -webkit-transform-style: preserve-3d;
		 * -moz-transform-style: preserve-3d;
		 * transform-style: preserve-3d;
		 * 
		 * see http://zerosixthree.se/vertical-align-anything-with-just-3-lines-of-css/
		 * 
		 * notes: 
		 * - parent may require height to be set
		 * - text may be blurry. use preserve-3d on parent or maybe on body:
		 *   -webkit-transform-style: preserve-3d;
		 *   -moz-transform-style: preserve-3d;
		 *   transform-style: preserve-3d;
		 * - element may need to be block element and absolute positioned
		 * - page may need height and width set to 100% (html5)
		 * 
		 * vertically align in hgroup using table and table cell
		 * https://jsfiddle.net/b74o1utw/6/
		 * 
		 * UPDATE: there are problems vertically aligning with table and table cell
		 * https://jsfiddle.net/b74o1utw/6/
		 * */
		public function getVerticalPositionHTML(instance:IVisualElement, propertyModel:HTMLStyles, stylesValue:String = "", isBasicLayout:Boolean = true):String {
			
			if (!isBasicLayout) return stylesValue;
			
			if (instance.verticalCenter!=null) {
				stylesValue += "display:table;margin:" + instance.verticalCenter + " auto;";
				stylesValue += "top:50%;transform:translateY(-50%);-webkit-transform:translateY(-50%);-ms-transform:translateY(-50%);";
				stylesValue = stylesValue.replace("absolute", "relative");
				
				propertyModel.display = HTMLStyles.TABLE;
				propertyModel.position = HTMLStyles.RELATIVE;
				propertyModel.margin = instance.verticalCenter + "px auto;";
				propertyModel.top = "50%;";
				propertyModel.transform = "translateY(-50%)";
				// how to do webkit and ms 
				//propertyModel.translateWebKit = "translateY(-50%)";
				//propertyModel.translateMS = "translateY(-50%)";
				
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
		 * Get the position string for HTML element in basic layout
		 * 
		 * Parent element needs preserve 3d to prevent blurry pixels
		 * -webkit-transform-style: preserve-3d;
		 * -moz-transform-style: preserve-3d;
		 * transform-style: preserve-3d;
		 * 
		 * see http://zerosixthree.se/vertical-align-anything-with-just-3-lines-of-css/
		 * 
		 * notes: 
		 * - parent may require height to be set
		 * - text may be blurry. use preserve-3d on parent or maybe on body:
		 *   -webkit-transform-style: preserve-3d;
		 *   -moz-transform-style: preserve-3d;
		 *   transform-style: preserve-3d;
		 * - element may need to be block element and absolute positioned
		 * - page may need height and width set to 100% (html5)
		 * 
		 * vertically align in hgroup using table and table cell
		 * https://jsfiddle.net/b74o1utw/6/
		 * 
		 * UPDATE: there are problems vertically aligning with table and table cell
		 * https://jsfiddle.net/b74o1utw/6/
		 * 
		 * Update: now using transform:translate();
		 * */
		public function getPositionHTML(instance:IVisualElement, propertyModel:HTMLStyles, stylesValue:String = "", isBasicLayout:Boolean = true):String {
			if (!isBasicLayout) return stylesValue;
			
			stylesValue = stylesValue.replace(/position:absolute;/g,"");
			stylesValue += "position:absolute;";
			
			var isVerticalCenterSet:Boolean;
			var isHorizontalCenterSet:Boolean;
			
			// constraints take higher authority
			var verticalCenter:Object = instance[verticalCenterPosition];
			var horizontalCenter:Object = instance[horizontalCenterPosition];
			
			if (verticalCenter!=null) {
				isVerticalCenterSet = true;
			}
			
			if (horizontalCenter!=null ) {
				isHorizontalCenterSet = true;
			}
			
			if (isVerticalCenterSet && isHorizontalCenterSet) {
				
				if (useTransformCentering) {
					stylesValue += "display:table;top:50%;left:50%;";
					stylesValue += "transform:translate(-50%,-50%);-webkit-transform:translate(-50%,-50%);-ms-transform:translate(-50%,-50%);";
					
					propertyModel.position = HTMLStyles.ABSOLUTE;
					propertyModel.display = HTMLStyles.TABLE;
					propertyModel.top = "50%;";
					propertyModel.left = "50%;";
					propertyModel.transform = "translate(-50%,-50%)";
				}
			}
			else {
				
				// vertical
				if (isVerticalCenterSet) {
					
					if (useTransformCentering) {
						stylesValue += "display:table;top:50%;";
						stylesValue += "transform:translateY(-50%);-webkit-transform:translateY(-50%);-ms-transform:translateY(-50%);";
						
						propertyModel.display = HTMLStyles.TABLE;
						propertyModel.position = HTMLStyles.ABSOLUTE;
						propertyModel.top = "50%;";
						propertyModel.transform = "translateY(-50%)";
					}
				}
				else if (instance.top!=null || instance.bottom!=null) {
					stylesValue += instance.top!=null ? "top:" + instance.top + "px;" : "";
					stylesValue += instance.bottom!=null ? "bottom:" + instance.bottom + "px;" : "";
					
					if (instance.top!=null) propertyModel.top = instance.top + "px";
					if (instance.bottom!=null) propertyModel.bottom = instance.bottom + "px";
					propertyModel.position = HTMLStyles.ABSOLUTE;
				}
				else {
					stylesValue += "top:" + instance.y + "px;";
					propertyModel.top = instance.y + "px;";
				}
				
				// horizontal
				if (isHorizontalCenterSet) {
					
					if (useTransformCentering) {
						stylesValue += "display:table;"
						stylesValue += "left:50%;transform:translateX(-50%);-webkit-transform:translateX(-50%);-ms-transform:translateX(-50%);";
						
						propertyModel.position = HTMLStyles.ABSOLUTE;
						propertyModel.display = HTMLStyles.TABLE;
						propertyModel.transform = "transform:translateX(-50%)";
					}
				}
				else if (instance.left!=null || instance.right!=null) {
					stylesValue += instance.left!=null ? "left:" + instance.left + "px;" : "";
					stylesValue += instance.right!=null ? "right:" + instance.right + "px;" : "";
					
					if (instance.left!=null) propertyModel.left = instance.left + "px";
					if (instance.right!=null) propertyModel.right = instance.right + "px";
					
					propertyModel.position = HTMLStyles.ABSOLUTE;
					
				}
				else {
					stylesValue += "left:" + instance.x + "px;";
					
					propertyModel.left = instance.x + "px;";
				}
				
			}
			
			return stylesValue;
		}
		
			
		/**
		 * Get the center position string for HTML element in basic layout
		 * 
		 * Parent element needs preserve 3d to prevent blurry pixels
		 * -webkit-transform-style: preserve-3d;
		 * -moz-transform-style: preserve-3d;
		 * transform-style: preserve-3d;
		 * 
		 * see http://zerosixthree.se/vertical-align-anything-with-just-3-lines-of-css/
		 * 
		 * notes: 
		 * - parent may require height to be set
		 * - text may be blurry. use preserve-3d on parent or maybe on body:
		 *   -webkit-transform-style: preserve-3d;
		 *   -moz-transform-style: preserve-3d;
		 *   transform-style: preserve-3d;
		 * - element may need to be block element and absolute positioned
		 * - page may need height and width set to 100% (html5)
		 * 
		 * vertically align in hgroup using table and table cell
		 * https://jsfiddle.net/b74o1utw/6/
		 * 
		 * UPDATE: there are problems vertically aligning with table and table cell
		 * https://jsfiddle.net/b74o1utw/6/
		 * 
		 * Update: now using transform:translate();
		 * */
		public function getCenterPositionHTML(instance:IVisualElement, propertyModel:HTMLStyles, stylesValue:String = "", isBasicLayout:Boolean = true):String {
			
			if (!isBasicLayout) return stylesValue;
			
			if (instance.verticalCenter!=null) {
				
				if (useTransformCentering) {
					stylesValue += "display:table;top:50%;left:50%;";
					stylesValue += "transform:translate(-50%,-50%);-webkit-transform:translate(-50%,-50%);-ms-transform:translate(-50%,-50%);";
					//stylesValue = stylesValue.replace("absolute", "relative");
					
					propertyModel.display = HTMLStyles.TABLE;
					propertyModel.position = HTMLStyles.ABSOLUTE;
					//propertyModel.margin = instance.verticalCenter + "px auto;";
					propertyModel.top = "50%;";
					propertyModel.left = "50%;";
					propertyModel.transform = "translate(-50%,-50%)";
				}
				else {
					stylesValue += "display:table;margin:" + instance.verticalCenter + " auto;";
					stylesValue += "top:50%;transform:translateY(-50%);-webkit-transform:translateY(-50%);-ms-transform:translateY(-50%);";
					stylesValue = stylesValue.replace("absolute", "relative");
					
					propertyModel.display = HTMLStyles.TABLE;
					propertyModel.position = HTMLStyles.RELATIVE;
					propertyModel.margin = instance.verticalCenter + "px auto;";
					propertyModel.top = "50%;";
					propertyModel.transform = "translateY(-50%)";
					// how to do webkit and ms 
					//propertyModel.translateWebKit = "translateY(-50%)";
					//propertyModel.translateMS = "translateY(-50%)";
				}
				
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
		 * Set styles. REFACTOR This is doing too many things. 
		 * */
		public function setStyles(component:Object, stylesValue:String = ""):String {
			var out:String = ">";
			var formatted:String;
			
			if (useInlineStyles) {
				return " style=\"" + stylesValue + "\"";
			}
			else {
				//formatted= "\t" + stylesValue.replace(/;/g, ";\n\t");
				
				// if we use oop we wouldn't need to do this
				formatted = "\t" + stylesValue.replace(/\b(data:image\/[^\/;]*;)|;/g, function (_:String, matchingGroup:String, ...args):String {
					return matchingGroup ? matchingGroup : ";\n\t";
				});
				
				
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
				
				if (styles==null) styles = "";
				styles += out;
			}
			
			return "";
		}
		
		
		
		/**
		 * Set first paragraph style hack
		 * */
		public function setFirstParagraphStyles(component:Object, stylesValue:String = ""):String {
			var out:String = "";
			var formatted:String;
			
			if (useInlineStyles) {
				//return " style=\"" + stylesValue + "\"";
			}
			else {
				formatted= "\t" + stylesValue.replace(/;/g, ";\n\t");
				
				out = "#" + getIdentifierOrName(component) + " > :first-child {\n";
				
				
				out += formatted;
				out += "}\n\n";
				
				out = out.replace(/\t}/g, "}");
				
				if (styles==null) styles = "";
				styles += out;
			}
			
			return "";
		}
		
		/**
		 * Close tag with greater than sign or slash plus greater than sign
		 * */
		public function closeTag(component:Object, singleton:Boolean = false):String {
			
			return singleton ? "\>" : ">";
		}
		
		/**
		 * Set user attributes.  
		 * */
		public function setUserAttributes(attributesValue:String = ""):String {
			if (attributesValue) {
				attributesValue = " " + attributesValue.replace(osNeutralLinebreaks, " ");
			}
			else {
				attributesValue = "";
			}
			
			return attributesValue;
		}
		
		/**
		 * Adds an tag. If you singleton is true then the tag returned is "/>" 
		 * if singleton is false then the tag returned is ">". 
		 * */
		public function endTag(component:Object, singleton:Boolean = false):String {
			var out:String = ">";
			
			return singleton ? "\>" : ">";
		}
		
		/**
		 * Wrap in style tags
		 * */
		public function wrapInStyleTags(value:String):String {
			if (value==null || value=="") return "";
			var out:String = "<style type=\"text/css\">\n" + value + "\n</style>";
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
		 * Get style name or class attribute
		 * */
		public function getStyleNameAttribute(instance:Object, value:String = "", appendID:String = ""):String {
			var styleName:String = "styleName" in instance ? instance.styleName : null;
			
			if (styleName!=null && styleName!="") {
				value += value.charAt(value.length)!=" " ? " " : "";
				value += "class=\"" + styleName + "\"";
			}
			
			return value;
		}
		
		public static const VERTICAL_SCROLL_POLICY:String = "verticalScrollPolicy";
		public static const HORIZONTAL_SCROLL_POLICY:String = "horizontalScrollPolicy";
		public static const VERTICAL_LINE:String = "verticalLine";
		public static const HORIZONTAL_LINE:String = "horizontalLine";
		public static const LINE:String = "line";
		
		/**
		 * Get line position details
		 * For horizontal and vertical lines the start positions are ignored
		 * because we create a wrapper div positioning the SVG content
		 * */
		public function getLinePosition(instance:Object, type:String, value:String = ""):String {
			var line:Line = instance as Line;
			
			if (line==null) {
				return value;
			}
			
			if (type==HORIZONTAL_LINE) {
				
				// start at 0
				value += " x1=\"" + instance.x + "\"";
				
				// stretch to width 
				if (!isNaN(line.percentWidth)) {
					value += " x2=\"" + line.percentWidth + "%\"";
				}
				else {
					value += " x2=\"" + (line.width + instance.x) + "\"";
				}
				
				value += " y1=\""+ instance.y + "\" y2=\"" + instance.y +  "\"";
			}
			else if (type==VERTICAL_LINE) {
				// start at 0
				value += " y1=\"" + instance.y +  "\"";
				
				// stretch to height 
				if (!isNaN(line.percentHeight)) {
					value += " y2=\"" + line.percentHeight + "%\"";
				}
				else {
					value += " y2=\"" + (line.height + instance.y) + "\"";
				}
				
				value += " x1=\"" + instance.x + "\" x2=\"" + instance.x + "\"";
				
			}
			else {
				//value += " x1=\"" + line.xFrom + "\" x2=\""+ line.xTo  + "\"";
				//value += " y1=\"" + line.yFrom + "\" y2=\"" + line.yTo + "\"";
				
				value += " x1=\"" + line.xFrom + "\"";
				
				// stretch to width 
				if (!isNaN(line.percentWidth)) {
					value += " x2=\"" + line.percentWidth + "%\"";
				}
				else {
					value += " x2=\"" + line.xTo + "\"";
				}
				
				value += " y1=\"" + line.yFrom + "\"";
				
				if (!isNaN(line.percentHeight)) {
					value += " y2=\"" + line.percentHeight + "%\"";
				}
				else {
					value += " y2=\"" + line.yTo + "\"";
				}
				
			}
			
			return value;
		}
		
		/**
		 * Get line wrapper position details
		 * This could be incorrect. 
		 * */
		public function getLineWrapperSize(instance:Object):String {
			var line:Line = instance as Line;
			var value:String = "";
			var sizeValue:Number;
			
			if (line==null) {
				return "";
			}
			
			value += "width:100%;";
			value += "height:100%;";
			return value;
			
			if (!isNaN(instance.percentWidth)) {
				value += "width:" + instance.percentWidth + "%;";
			}
			else if ("explicitWidth" in instance) {
				sizeValue = Object(instance).explicitWidth as Number;
				
				if (!isNaN(sizeValue)) {
					// if the width is zero then the element won't be visible so don't set it?
					if (sizeValue>0) {
						value += "width:" + instance.width + "px;";
					}
				}
			}
			
			if (!isNaN(instance.percentHeight)) {
				value += "height:" + instance.percentHeight + "%;";
			}
			else if ("explicitHeight" in instance) {
				sizeValue = Object(instance).explicitHeight as Number;
				
				if (!isNaN(sizeValue)) {
					// if the height is zero then the element won't be visible so don't set it?
					if (sizeValue>0) {
						value += "height:" + instance.height + "px;";
					}
				}
			}
			
			return value;
		}
		
		/**
		 * Get the minimum SVG view box 
		 * */
		public function getSVGViewBox(componentInstance:Object, layoutBase:LayoutBase, value:String = ""):String {
			var bounds:Rectangle;
			
			bounds = layoutBase.getChildElementBounds(componentInstance as IVisualElement);
			
			value = StringUtils.ensureSpaceExists(value);
			
			value += "viewBox=\"" + -bounds.x + " " + -bounds.y;
			value += " " + bounds.right + " " + bounds.bottom + "\"";
			
			return value;
		}
		
		/**
		 * Get the minimum SVG size 
		 * */
		public function getSVGSize(componentInstance:Object, layoutBase:LayoutBase):String {
			var value:String = "";
			var bounds:Rectangle;
			
			bounds = layoutBase.getChildElementBounds(componentInstance as IVisualElement);
			
			if (!isNaN(componentInstance.percentWidth)) {
				value += "width:" + componentInstance.percentWidth + "%;";
			}
			else {
			
				// if the width is zero then the element won't be visible so don't set it?
				if (bounds.right>0) {
					value += "width:" + bounds.right + "px;";
				}
			}
			
			if (!isNaN(componentInstance.percentHeight)) {
				value += "height:" + componentInstance.percentHeight + "%;";
			}
			else {
				
				// if the height is zero then the element won't be visible so don't set it?
				if (bounds.bottom>0) {
					value += "height:" + bounds.bottom + "px;";
				}
			}
			
			return value;
		}
		
		/**
		 * Get ID from ID or else name attribute
		 * */
		public function getIdentifierAttribute(instance:Object, value:String = "", appendID:String = "", createUniqueName:Boolean = false):String {
			value = StringUtils.ensureSpaceExists(value);
			
			if (instance && "id" in instance && instance.id) {
				value += "id=\"" + instance.id + appendID + "\"";
			}
				
			else if (instance && "name" in instance && instance.name) {
				value += "id=\"" + instance.name + appendID + "\"";
			}
			
			if (instance is GraphicElement && instance.id ==null) {
				// graphic element has no name property
				instance.id = NameUtil.createUniqueName(instance);
			}
			
			return value;
		}
		
		/**
		 * Get specific attribute
		 * */
		public function getAttribute(name:String, value:String, encode:Boolean = true, spaceBefore:Boolean = true):String {
			// need to encode to be inside attribute quotes
			value = name + "=\"" + value + "\"";
			spaceBefore ? value = " " + value : void;
			
			return value;
		}
		
		
		/**
		 * Get rect corner radius
		 * */
		public function getRectCornerRadius(componentInstance:Rect, layout:String = "", spaceBefore:Boolean = true):String {
			layout = StringUtils.ensureSpaceExists(layout);
			
			// we set the attributes explicitly because if they are not (in Mac Safari)
			// setting them in styles does not have any effect
			layout += "rx" + "=\"" + componentInstance.radiusX + "\"";
			layout += " ry" + "=\"" + componentInstance.radiusY + "\"";
			
			return layout;
		}
		
		/**
		 * Get Graphic Element size attributes
		 * */
		public function getGraphicElementSizeAttributes(componentInstance:Object, layout:String = ""):String {
			layout = StringUtils.ensureSpaceExists(layout);
			
			if (!isNaN(componentInstance.percentWidth)) {
				layout += "width" + "=\"" + componentInstance.percentWidth + "%\"";
			}
			else {
				layout += "width" + "=\"" + componentInstance.width + "\"";
			}
			
			layout = StringUtils.ensureSpaceExists(layout);
			
			if (!isNaN(componentInstance.percentHeight)) {
				layout += "height" + "=\"" + componentInstance.percentHeight + "%\"";
			}
			else {
				layout += "height" + "=\"" + componentInstance.height + "\"";
			}
			
			return layout;
		}
		
		/**
		 * Get graphic element position attributes
		 * */
		public function getGraphicElementPositionAttributes(componentInstance:GraphicElement, layout:String = ""):String {
			layout = StringUtils.ensureSpaceExists(layout);
			
			layout += "x" + "=\"" + componentInstance.x + "\"";
			
			layout = StringUtils.ensureSpaceExists(layout);
			
			layout += "y" + "=\"" + componentInstance.y + "\"";
			
			return layout;
		}
		
		/**
		 * Adds an attribute to the string
		 * 
		 * @name name of attribute
		 * @value value of attribute
		 * @layout string to add attribute to 
		 * @encode encodes the value with encodecomponent
		 * @spaceBefore adds a space before the appended attribute
		 * */
		public function getAttributeLayout(name:String, value:String, layout:String = "", encode:Boolean = true, spaceBefore:Boolean = true):String {
			// need to encode to be inside attribute quotes
			spaceBefore ? layout += " ":0;
			layout += name + "=\"" + value + "\"";
			
			return layout;
		}
		
		/**
		 * Get boolean attribute. If value is false it doesn't add the attribute
		 * */
		public function getBooleanAttribute(name:String, enabled:Boolean, layout:String, spaceBefore:Boolean = true):String {
			
			if (enabled) {
				spaceBefore ? layout += " ":0;
				layout += "" + name + "=\"" + enabled + "\"";
			}
			
			return layout;
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
		 * Instead of this class generating the markup the markup is passed in 
		 * through the options parameter
		 * @see #export()
		 * */
		public var useCustomMarkup:Boolean;
		
		/**
		 * Any styles not set inline are placed in an external stylesheet
		 * */
		public var useExternalStylesheet:Boolean;
		
		/**
		 * Styles set inline are placed before markup
		 * */
		public var inlineStylesBeforeMarkup:Boolean = true;
		
		/**
		 * Default file extension. Default is html. 
		 * This can be changed by setting the export options.
		 * */
		public var fileExtension:String = "html";
		
		/**
		 * Adds a container around the markup
		 * */
		public var addContainerDiv:Boolean;
		
		/**
		 * Uses an html element at the end of a list of items in a horizontal
		 * layout that is then sized to 100% to center all the other items vertically 
		 * The other option is to use line-height:12px or whatever the height of the 
		 * tallest element is but that has issues. 
		 * */
		public var useSpanToCenterInHGroup:Boolean = true;
		
		/**
		 * @inheritDoc
		 * */
		override public function getExportOptions(getCurrentValues:Boolean = true):ExportOptions {
			if (exportOptions==null) {
				exportOptions = new HTMLExportOptions();
			}
			
			super.getExportOptions(getCurrentValues);
			
			return exportOptions;
		}
	}
}