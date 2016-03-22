
package com.flexcapacitor.utils {
	import com.flexcapacitor.model.ErrorData;
	import com.flexcapacitor.model.ExportOptions;
	import com.flexcapacitor.model.FileInfo;
	import com.flexcapacitor.model.HTMLExportOptions;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IDocumentExporter;
	import com.flexcapacitor.model.IssueData;
	import com.flexcapacitor.model.SourceData;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	import com.flexcapacitor.utils.supportClasses.XMLValidationInfo;
	import com.flexcapacitor.views.supportClasses.Styles;
	
	import flash.display.BitmapData;
	import flash.utils.getTimer;
	
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.styles.IStyleClient;
	import mx.utils.NameUtil;
	
	import spark.components.BorderContainer;
	import spark.components.HGroup;
	import spark.components.NumericStepper;
	import spark.components.RichText;
	import spark.components.VGroup;
	import spark.components.supportClasses.GroupBase;
	import spark.components.supportClasses.ListBase;
	import spark.layouts.BasicLayout;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.TileLayout;
	import spark.layouts.VerticalLayout;
	import spark.primitives.Line;
	import spark.primitives.supportClasses.GraphicElement;
	
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	
	import org.as3commons.lang.ObjectUtils;
	
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
		public var setExplicitSize:Boolean = true;
		
		/**
		 * Sets styles inline
		 * */
		public var useInlineStyles:Boolean;
		
		/**
		 * For label components uses a span element instead of label element
		 * */
		public var useSpanTagForLabel:Boolean = true;
		
		/**
		 * Styles added by users 
		 * */
		public var userStyles:String;
		
		/**
		 * Border box CSS
		 * cause all padding and borders to be inside width and height 
		 * http://www.paulirish.com/2012/box-sizing-border-box-ftw/
		 * */
		public var borderBoxCSS:String = "*, *:before, *:after {\n\t-moz-box-sizing:border-box;\n\t-webkit-box-sizing:border-box;\n\tbox-sizing:border-box;\n}";
		
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
		 * Places common CSS after element CSS when true.
		 * This is so in the editor you see the element css at the top
		 * */
		public var reverseInitialCSS:Boolean = true;
		
		/**
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
		 * Convert bitmap data to graphic data
		 * */
		public var createImageDataForGraphics:Boolean = false;
		
		/**
		 * Show image snapshot when html element is not found or supported
		 * */
		public var showImageWhenComponentNotFound:Boolean = true;
		
		/**
		 * Last source code
		 * */
		public var sourceCode:String;
		
		public var includePreviewCode:Boolean;
		
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
		
		/**
		 * URL to transparent Gif used for spacing
		 * */
		public var transparentGifURL:String = "/spacer.gif";
		
		/**
		 * 
		 * */
		public var useWrapperDivs:Boolean;
		
		/**
		 * 
		 * */
		public var showDocumentCode:Boolean;
		
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
		override public function export(iDocument:IDocument, targetDescription:ComponentDescription = null, localOptions:ExportOptions = null):SourceData {
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
			
			
			///////////////////////
			// SET OPTIONS
			///////////////////////
			
			if (localOptions) {
				savePresets();
				applyPresets(localOptions);
			}
			
			
			///////////////////////
			// GET SOURCE CODE
			///////////////////////
			
			if (showDocumentCode) {
				targetDescription = document.componentDescription;
			}
			
			if (targetDescription) {
				var zoomOutput:String;
				var applicationContainerID:String = "applicationContainer";
				var zoomInID:String = wrapInPreview ? document.name : applicationContainerID;
				
				// see the top of this document on how to generate source code
				
				if (exportFromHistory) {
					getAppliedPropertiesFromHistory(iDocument, targetDescription);
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
					var imageDataFormat:String = "png";//"jpeg";
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
		 * */
		public function getHTMLOutputString(iDocument:IDocument, componentDescription:ComponentDescription, addLineBreak:Boolean = false, tabs:String = "", includePreview:Boolean = false):String {
			var componentInstance:Object = componentDescription.instance;
			if (componentInstance==null) return "";
			var propertyList:Object = componentDescription.properties;
			var propertiesStylesObject:Object = ObjectUtils.merge(componentDescription.properties, componentDescription.styles);
			var componentName:String = componentDescription.className ? componentDescription.className.toLowerCase() : "";
			var localName:String = componentName ? componentName : "";
			var componentChild:ComponentDescription;
			var instanceName:String = componentInstance && "name" in componentInstance ? componentInstance.name : "";
			var instanceID:String = componentInstance && "id" in componentInstance ? componentInstance.id : "";
			var identity:String = ClassUtils.getIdentifier(componentInstance);
			var isGraphicalElement:Boolean = componentDescription.isGraphicElement;
			var contentToken:String = "[child_content]";
			var styleValue:String = "position:absolute;";
			var stylesModel:Styles = new Styles();
			var stylesOut:String = "";
			var wrapperStylesModel:Styles = new Styles();
			var isInHorizontalLayout:Boolean;
			var isInVerticalLayout:Boolean;
			var isInBasicLayout:Boolean;
			var isInTileLayout:Boolean;
			var childContent:String = "";
			var wrapperTag:String = "";
			var centeredHorizontally:Boolean;
			var wrapperTagStyles:String = "";
			var wrapperSVGStyles:String = "";
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
			var numberOfChildren:int;
			var type:String = "";
			var instance:Object;
			var numElements:int;
			var htmlName:String;
			var tracking:Number;
			var borderColor:String;
			var index:int;
			var value:*;
			var gap:int;
			var newLine:String = "\n";
			var snapshotBackground:Boolean;
			var convertElementToImage:Boolean;
			var imageDataStyle:String;
			var imageDataFormat:String = "png";
			var isHorizontalCenterSet:Boolean;
			var isVerticalCenterSet:Boolean;
			var anchor:XML;
			
			wrapWithAnchor 	= componentDescription.wrapWithAnchor;
			anchorURL 		= componentDescription.anchorURL;
			anchorTarget	= componentDescription.anchorTarget;
			
			// we are setting the styles in a string now
			// the next refactor should use the object so we can output to CSS
			stylesModel.position = Styles.ABSOLUTE;
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
				
				if (componentDescription.parent.instance.layout is HorizontalLayout) {
					isInHorizontalLayout = true;
					styleValue = styleValue.replace("absolute", "relative");
					//styleValue += "vertical-align:middle;";
					stylesModel.position = Styles.RELATIVE;
					index = GroupBase(componentDescription.parent.instance).getElementIndex(componentInstance as IVisualElement);
					numElements = GroupBase(componentDescription.parent.instance).numElements;
					wrapperTagStyles += hasExplicitSizeSet(componentInstance as IVisualElement) ? "display:inline-block;" : "display:inline;";
					wrapperStylesModel.display = hasExplicitSizeSet(componentInstance as IVisualElement) ? Styles.INLINE_BLOCK : Styles.INLINE;
					gap = HorizontalLayout(componentDescription.parent.instance.layout).gap - 4;
					parentVerticalAlign = componentDescription.parent.instance.verticalAlign;
					wrapperTagStyles += getParentVerticalAlign(parentVerticalAlign);
					
					if (index<numElements-1 && numElements>1) {
						//wrapperTagStyles += "padding-right:" + gap + "px;";
						wrapperTagStyles += Styles.MARGIN_RIGHT+":" + gap + "px;";
						wrapperStylesModel.marginRight =  gap + "px";
					}
					
					wrapperTag = "div";
				}
				else if (componentDescription.parent.instance.layout is TileLayout) {
					//isHorizontalLayout = true;
					isInTileLayout = true;
					styleValue = styleValue.replace("absolute", "relative");
					stylesModel.position = Styles.RELATIVE;
					index = GroupBase(componentDescription.parent.instance).getElementIndex(componentInstance as IVisualElement);
					numElements = GroupBase(componentDescription.parent.instance).numElements;
					wrapperTagStyles += hasExplicitSizeSet(componentInstance as IVisualElement) ? "display:inline-block;" : "display:inline;";
					wrapperStylesModel.display = hasExplicitSizeSet(componentInstance as IVisualElement) ? Styles.INLINE_BLOCK : Styles.INLINE;
					gap = TileLayout(componentDescription.parent.instance.layout).horizontalGap - 4;
					parentVerticalAlign = componentDescription.parent.instance.verticalAlign;
					wrapperTagStyles += getParentVerticalAlign(parentVerticalAlign);
					
					if (index<numElements-1 && numElements>1) {
						//wrapperTagStyles += "padding-right:" + gap + "px;";
						// using "margin-right" because if you set a fixed width padding was not doing anything
						wrapperTagStyles += Styles.MARGIN_RIGHT+":" + gap + "px;";
						//wrapperStyles.paddingRight =  gap + "px";
						wrapperStylesModel.marginRight =  gap + "px";
					}
					
					wrapperTag = "div";
				}
				
				else if (componentDescription.parent.instance.layout is VerticalLayout) {
					isInVerticalLayout = true;
					styleValue = styleValue.replace("absolute", "relative");
					stylesModel.position = Styles.RELATIVE;
					index = GroupBase(componentDescription.parent.instance).getElementIndex(componentInstance as IVisualElement);
					numElements = GroupBase(componentDescription.parent.instance).numElements;
					gap = VerticalLayout(componentDescription.parent.instance.layout).gap;
					parentVerticalAlign = componentDescription.parent.instance.verticalAlign;
					wrapperTagStyles += getParentVerticalAlign(parentVerticalAlign);
					
					
					if (index<numElements-1 && numElements>1) {
						
						if (gap!=0) {
							//wrapperTagStyles += "padding-bottom:" + gap + "px;";
							wrapperTagStyles += Styles.MARGIN_BOTTOM+":" + gap + "px;";
						}
						//wrapperStyles.paddingBottom =  gap + "px";
						wrapperStylesModel.marginBottom =  gap + "px";
					}
					
					wrapperTag = "div";
				}
				
				else if (componentDescription.parent.instance.layout is BasicLayout) {
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
			
			// constraints take higher authority
			
			// loop through assigned properties and check for layout rules 
			for (var propertyName:String in propertiesStylesObject) {
				value = null;
				
				if (propertyName in propertiesStylesObject) {
					value = propertiesStylesObject[propertyName];
				}
				
				if (value===undefined || value==null) {
					continue;
				}
				
				
				// the following needs works
				if (!isGraphicalElement) {
					if (verticalPositions.indexOf(propertyName)!=-1 && !isVerticalCenterSet) {
						styleValue = getVerticalPositionHTML(componentInstance as IVisualElement, stylesModel, styleValue, isInBasicLayout);
						//if (verticalCenterPosition.indexOf(propertyName)!=-1 && isInBasicLayout) {
							isVerticalCenterSet = true;
						//}
					}
					else if (horizontalPositions.indexOf(propertyName)!=-1 && !isHorizontalCenterSet) {
						styleValue = getHorizontalPositionHTML(componentInstance as IVisualElement, stylesModel, styleValue, isInBasicLayout);
						//if (horizontalCenterPosition.indexOf(propertyName)!=-1 && isInBasicLayout) {
							isHorizontalCenterSet = true;
						//}
					}
				}
				
			}
			
			snapshotBackground = componentDescription.createBackgroundSnapshot;
			convertElementToImage = componentDescription.convertElementToImage;
			//var imageDataFormat:String = "jpeg";
			
			
			
			// export component
			
			if (localName) {
				
				
				// putting the convert to image code at the top. it's also used below if an element is not found
				if (convertElementToImage) {
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<img " + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock(componentInstance) : "";
					styleValue += getVisibleDisplay(componentInstance);
					layoutOutput += properties ? " " : "";
					
					layoutOutput += " src=\"" + DisplayObjectUtils.getBase64ImageDataString(componentInstance, imageDataFormat) + "\"";
					
					styleValue += userInstanceStyles;
					stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
					
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += getWrapperTag(wrapperTag, true);
					
					// if exporting an image then don't export the contents 
					//exportChildDescriptors = false;
					contentToken = "";
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
						stylesModel.position = Styles.ABSOLUTE;
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
						
						if (showScreenshotBackground) {
							var backgroundImageID:String = "backgroundComparisonImage";
							var imageData:String = DisplayObjectUtils.getBase64ImageDataString(componentInstance, imageDataFormat);
							var backgroundSnapshot:String = "\n" + tabs + "\t" + "<img ";
							backgroundSnapshot += "id=\"" + backgroundImageID +"\""; 
							backgroundSnapshot += " src=\"" + imageData + "\" ";
							
							layoutOutput += backgroundSnapshot;
							layoutOutput += setStyles("#"+backgroundImageID, "position:absolute;opacity:"+backgroundImageAlpha+";top:0px;left:0px;", true);
							
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
						}
						else {
							styleValue = "";
						}
						
						styleValue += "background-color:" + DisplayObjectUtils.getColorInHex(componentInstance.getStyle("backgroundColor"), true) + ";";
						styleValue = getFontFamily(componentInstance, styleValue, true);
						styleValue = getFontWeight(componentInstance, styleValue, true);
						styleValue = getFontSize(componentInstance, styleValue, true);
						styleValue = getLineHeight(componentInstance, styleValue, false);
						
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
							imageDataFormat = "png";//"jpeg";
							imageData = DisplayObjectUtils.getBase64ImageDataString(componentInstance, imageDataFormat);
							backgroundSnapshot = "\n" + tabs + "\t" + "<img ";
							backgroundSnapshot += "id=\"" + backgroundImageID +"\""; 
							backgroundSnapshot += " src=\"" + imageData + "\" ";
							
							layoutOutput += backgroundSnapshot;
							layoutOutput += setStyles("#"+backgroundImageID, "position:absolute;opacity:"+backgroundImageAlpha+";top:0px;left:0px;", true);
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
							layoutOutput += contentToken;
							layoutOutput += "\n</div>";
						}
						else {
							setStyles("body", styleValue);
							layoutOutput += contentToken;
							layoutOutput += "";
						}
					}
				}
				
				else if (localName=="group" || localName=="vgroup") {
					htmlName = "div";
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<div " + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					layoutOutput += properties ? " " : "";
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					
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
					layoutOutput += contentToken;
					layoutOutput += "\n" + tabs + "</div>";
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				
				else if (localName=="bordercontainer") {
					htmlName = "div";
					
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<div " + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					layoutOutput += properties ? " " : "";
					
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += getBorderString(componentInstance as BorderContainer);
					styleValue += getCornerRadiusString(componentInstance as BorderContainer);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					styleValue = getFontFamily(componentInstance, styleValue);
					styleValue = getFontWeight(componentInstance, styleValue);
					styleValue = getFontSize(componentInstance, styleValue);
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
					layoutOutput += componentInstance.numElements==0? "&#160;": contentToken;
					layoutOutput += "\n" + tabs + "</div>";
					layoutOutput += getWrapperTag(wrapperTag, true);
					
				}
				
				else if (localName=="hgroup" || localName=="tilegroup") {
					htmlName = "div";
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<div " + properties;
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
					var verticalAlign:String = componentInstance.verticalAlign;
					if (localName=="hgroup") {
						
						// warning - hack below! ...and above and all over the place
						// TODO: USE TABLE CELL display type on child elements?? no
						// UPDATE now use 0 width element to size to 100% of container height
						// and other elements should center vertically - refactor
						if (verticalAlign=="middle") {
							styleValue += "line-height:" + (componentInstance.height-4) + "px;"; 
						}
						
						// trying table cell 
						if (false && verticalAlign=="middle") {
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
					layoutOutput += contentToken;
					layoutOutput += "\n" + tabs + "</div>";
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="button" || localName=="togglebutton") {
					htmlName = "button";
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<input " + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					layoutOutput += " type=\"" + htmlName.toLowerCase() + "\"" ;
					layoutOutput += properties ? " " + properties : "";
					
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					styleValue = getFontFamily(componentInstance, styleValue);
					styleValue = getFontWeight(componentInstance, styleValue);
					styleValue = getFontSize(componentInstance, styleValue);
					styleValue = getFontColor(componentInstance, styleValue);
					
					styleValue += userInstanceStyles;
					stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
					
					layoutOutput += " value=\"" + componentInstance.label + "\"";
					//layoutOutput += " class=\"buttonSkin\"";
					
					layoutOutput += setStyles(componentInstance, styleValue);
					
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="videoplayer") {
					htmlName = "video";
					
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
					
					layoutOutput += "<" +htmlName+ " ";
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					
					layoutOutput += " controls=\"true\" "  + properties;
					
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					styleValue = getFontFamily(componentInstance, styleValue);
					styleValue = getFontWeight(componentInstance, styleValue);
					styleValue = getFontSize(componentInstance, styleValue);
					styleValue = getFontColor(componentInstance, styleValue);
					//styleValue += "padding:2px;";
					
					borderColor = componentInstance.getStyle("borderColor");
					
					if (borderColor!=null) {
						styleValue += "border:1px solid " + DisplayObjectUtils.getColorInHex(uint(borderColor), true) + ";";
					}
					
					styleValue += userInstanceStyles;
					stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
					
					layoutOutput += setStyles(componentInstance, styleValue);
					
					if (componentInstance.source) {
						layoutOutput += "\n" + tabs + "\t<source src=\"" + componentInstance.source + "\">\n";
					}
					
					layoutOutput += tabs + "</" + htmlName + ">";
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="checkbox") {
					htmlName = localName;
					
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
						
						styleValue += userInstanceStyles;
						stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
						
						layoutOutput += setStyles("#"+getIdentifierOrName(componentInstance, true, "_Label"), styleValue);
						layoutOutput += "<input ";
						layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
						layoutOutput += " type=\"" + htmlName.toLowerCase() + "\" ";
						layoutOutput += "/>" ;
					}
					else {
						layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
						layoutOutput += "<input " + properties;
						layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
						layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
						layoutOutput += " type=\"" + htmlName.toLowerCase() + "\" " + properties;
						//styleValue = getSizeString(componentInstance as IVisualElement, styleValue);
						
						styleValue += userInstanceStyles;
						stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
						
						layoutOutput += setStyles(componentInstance, styleValue);
					}
					
					if (componentInstance.label!="") {
						layoutOutput += " " + componentInstance.label + "</label>";
					}
					
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="radiobutton") {
					htmlName = "radio";
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
						
						styleValue += userInstanceStyles;
						stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
						
						layoutOutput += setStyles("#"+getIdentifierOrName(componentInstance, true, "_Label"), styleValue);
						layoutOutput += "<input type=\"radio\" " ;
						layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
						layoutOutput += "/>" ;
					}
					else {
						layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
						layoutOutput += "<input type=\"" + htmlName.toLowerCase() + "\" " + properties;
						layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
						layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
						
						styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
						styleValue += isInVerticalLayout ? getDisplayBlock() : "";
						
						styleValue += userInstanceStyles;
						stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
						
						layoutOutput += setStyles(componentInstance, styleValue);
					}
					
					if (componentInstance.label!="") {
						layoutOutput += " " + componentInstance.label + "</label>";
					}
					
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="textinput" || localName=="combobox" || localName=="numericstepper"
						|| localName=="datefield" || localName=="colorpicker" 
						|| localName=="hslider" || localName=="vslider" ) {
					
					htmlName = "input";
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
					
					if (localName=="vslider") {
						styleValue += "writing-mode: bt-lr;";
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
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="dropdownlist" || localName=="list") {
					htmlName = "select";
					
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<select ";
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
					styleValue += "padding:0;border:1px solid " + DisplayObjectUtils.getColorInHex(componentInstance.getStyle("borderColor"), true) + ";";
					
					
					styleValue += userInstanceStyles;
					stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
					
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += "</select>";
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="label" || localName=="hyperlink" || localName=="textarea" || localName=="richtext") {
					
					if (localName=="label") {
						// we may want to use "p" but rendering and layout is slightly different
						if (useSpanTagForLabel) {
							htmlName = "span";
						}
						else {
							htmlName = "label";
						}
					}
					else if (localName=="textarea") {
						htmlName = "textarea";
					}
					else if (localName=="richtext") {
						htmlName = "p";
					}
					else if (localName=="hyperlink") {
						htmlName = "a";
					}
					
					if (useWrapperDivs) {
						layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
					}
					else {
						//layoutOutput = tabs;
					}
					
					layoutOutput += "<" + htmlName + " "  + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					styleValue = getWidthString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet, isVerticalCenterSet);
					styleValue = getHeightString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet, isVerticalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					
					
					styleValue = getFontFamily(componentInstance, styleValue);
					styleValue = getFontWeight(componentInstance, styleValue);
					styleValue = getFontSize(componentInstance, styleValue);
					styleValue = getLineHeight(componentInstance, styleValue);
					styleValue = getFontColor(componentInstance, styleValue);
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
					stylesOut = wrapperTagStyles + styleValue;
					layoutOutput += setStyles(componentInstance, wrapperTagStyles + styleValue);
					
					if (localName=="richtext") {
						htmlName = "p";
						
						// we need to write another TextConverter.export method that doesn't include the HTML and body tag
						
						//layoutOutput += TextConverter.export(RichText(componentInstance).textFlow, TextConverter.TEXT_FIELD_HTML_FORMAT, ConversionType.STRING_TYPE);
						var test:Object = TextConverter.export(RichText(componentInstance).textFlow, TextConverter.TEXT_FIELD_HTML_FORMAT, ConversionType.XML_TYPE);
						var content:XML = test.children()[0].children()[0].children()[0].children()[0];
						
						if (content) {
							layoutOutput += content.toXMLString();
						}
					}
					else {
						layoutOutput += componentInstance.text.replace(/\n/g, "<br/>");
					}
					
					layoutOutput += "</" + htmlName + ">";
					
					if (useWrapperDivs) {
						layoutOutput += getWrapperTag(wrapperTag, true);
					}
				}
				else if (localName=="image") {
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
					layoutOutput += "<img " + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock(componentInstance) : "";
					styleValue += getVisibleDisplay(componentInstance);
					
					layoutOutput += properties ? " " : "";
					
					if (componentInstance.source is BitmapData && createImageDataForGraphics) {
						layoutOutput += " src=\"" + DisplayObjectUtils.getBase64ImageDataString(componentInstance.source, "jpeg") + "\"";
					}
					else if (componentInstance.source is String) {
						layoutOutput += " src=\"" + componentInstance.source + "\"";
					}
					
					styleValue += userInstanceStyles;
					stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
					
					layoutOutput += setStyles(componentInstance, styleValue);
					layoutOutput += getWrapperTag(wrapperTag, true);
				}
				else if (localName=="spacer") {
					//move to image
					// show placeholder NOT actual component
					htmlName = "div";
					
					if (useWrapperDivs) {
						layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
					}
					else {
						//layoutOutput = tabs;
					}
					
					layoutOutput += "<div "  + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
					
					styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet, isVerticalCenterSet);
					styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					
					layoutOutput += properties ? " " : "";
					stylesOut = wrapperTagStyles + styleValue;
					layoutOutput += setStyles(componentInstance, wrapperTagStyles + styleValue);
					//output += "&#160;"
					layoutOutput += "</div>";
					
					if (useWrapperDivs) {
						layoutOutput += getWrapperTag(wrapperTag, true);
					}
				}
				else if (localName=="horizontalline" || localName=="verticalline") {
					//move to 
					htmlName = "line";
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
					//}
					//else {
					//	layoutOutput = tabs;
					//}
						
					if (componentInstance is GraphicElement && componentInstance.id ==null) {
						// graphic element has no name property
						componentInstance.id = NameUtil.createUniqueName(componentInstance);
					}
					
					layoutOutput += "<line "  + properties;
					layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
					
					if (localName=="horizontalline") {
						layoutOutput = getLinePosition(componentInstance, HORIZONTAL_LINE, layoutOutput);
					}
					else if (localName=="verticalline") {
						layoutOutput = getLinePosition(componentInstance, VERTICAL_LINE, layoutOutput);
					}
					else {
						layoutOutput = getLinePosition(componentInstance, LINE, layoutOutput);
					}
					
					
					layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);

					styleValue = "stroke:" + DisplayObjectUtils.getColorInRGB(componentInstance.color, componentInstance.alpha) + ";";
					styleValue += "stroke-width:" + componentInstance.strokeWeight + ";";
					
					if (true) {
						styleValue += "shape-rendering:crispEdges;";
					}
					else {
						
					}
					//styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet, isVerticalCenterSet);
					//styleValue += isInVerticalLayout ? getDisplayBlock() : "";
					
					layoutOutput += properties ? " " : "";
					//output += setStyles(componentInstance, wrapperTagStyles+styleValue);
					stylesOut = wrapperTagStyles + styleValue;
					
					layoutOutput += setStyles(componentInstance, wrapperTagStyles + styleValue);
					//output += "&#160;"
					layoutOutput += "</line>";
					
					//if (useWrapperDivs) {
						layoutOutput += getWrapperTag(wrapperTag, true);
					//}
				}
				else {
					
					// add error if we are converting to an image on purpose
					// we will create a snapshot if it's an error
					if (!convertElementToImage) {
						errorData = new ErrorData();
						errorData.description = componentDescription.name + " is not supported in HTML export at this time.";
						errorData.label = "Unsupported component";
						errors.push(errorData);
						componentNotFound = true;
					}
					
					// create code for element type or image
					if (convertElementToImage || (componentNotFound && showImageWhenComponentNotFound)) {
						//imageDataStyle = "\tbackground-image: url(data:image/jpeg;base64,"+imageData+");";
						//imageDataStyle = convertComponentToImage(componentInstance);
						//styleValue += "" + imageDataStyle;
						
						layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
						layoutOutput += "<img " + properties;
						layoutOutput = getIdentifierAttribute(componentInstance, layoutOutput);
						layoutOutput = getStyleNameAttribute(componentInstance, layoutOutput);
						styleValue = getSizeString(componentInstance as IVisualElement, styleValue, isHorizontalCenterSet);
						styleValue += isInVerticalLayout ? getDisplayBlock(componentInstance) : "";
						styleValue += getVisibleDisplay(componentInstance);
						layoutOutput += properties ? " " : "";
						
						layoutOutput += " src=\"" + DisplayObjectUtils.getBase64ImageDataString(componentInstance, imageDataFormat) + "\"";
						
						styleValue += userInstanceStyles;
						stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
						
						layoutOutput += setStyles(componentInstance, styleValue);
						layoutOutput += getWrapperTag(wrapperTag, true);
						
						// if exporting an image then don't export the contents 
						//exportChildDescriptors = false;
						contentToken = "";
					}
					else {
						// show placeholder NOT actual component
						htmlName = "label";
						
						layoutOutput += "<label "  + properties;
						
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
						
						layoutOutput += properties ? " " : "";
						// remove wrapperTagStyles since we are trying to not use wrapper tags
						//output += setStyles(componentInstance, styleValue+wrapperTagStyles);
						//output += setStyles(componentInstance, wrapperTagStyles+styleValue);
						stylesOut = wrapperTagStyles + styleValue;
						layoutOutput += setStyles(componentInstance, wrapperTagStyles + styleValue);
						layoutOutput += getIdentifierOrName(componentInstance);
						layoutOutput += "</label>";
						
						if (useWrapperDivs) {
							layoutOutput += getWrapperTag(wrapperTag, true);
						}
					}
					
				}
				
				
				// we need to put this wrapper code here rather than in the code above
				// because some code for things like the loop don't work if wrapped in div
				//if (useWrapperDivs || wrapperTag) {
				if (false) {
					layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles) + layoutOutput;
					layoutOutput = getWrapperTag(wrapperTag, true);
				}
				
				// add tabs
				if (layoutOutput!="") {
					layoutOutput = tabs + layoutOutput;
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
					
					layoutOutput = initialTabs + XMLUtils.getOpeningTag(anchor)  + "\n\t" + layoutOutput + "\n" + initialTabs + "</a>";
				}
				
				// add special wordpress loop code (rewrite later by saving markup to custom field - this will be gone) 
				if (identity && identity.toLowerCase()=="theloop") {
					layoutOutput = "\n" + initialTabs + "<!--the loop-->"  + "\n" + layoutOutput + "\n" + initialTabs + "<!--the loop-->";
				}
				
				if (localName=="application" && !addContainerDiv) {
					newLine = "";
					//tabs = "";
				}
				else {
					tabs = tabs + "\t";
				}
				
				// add children
				if (exportChildDescriptors && componentDescription.children && componentDescription.children.length>0) {
					//output += ">\n";
					
					numberOfChildren = exportChildDescriptors ? componentDescription.children.length : 0;
					
					for (var i:int;i<numberOfChildren;i++) {
						componentChild = componentDescription.children[i];
						
						if (exportFromHistory) {
							getAppliedPropertiesFromHistory(iDocument, componentChild);
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
					
					if (exportChildDescriptors) {
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
		
		public function getBackgroundImageData(componentInstance:Object, imageDataFormat:String = "png"):String {
			var color:Number = 0x0;
			var alpha:Number = .5;
			var imageData:String = DisplayObjectUtils.getBase64ImageDataString(componentInstance, imageDataFormat, null, true, color);
			var imageDataStyle:String = "";
			//imageDataStyle = "background-repeat: no-repeat;";
			//imageDataStyle += "background-image: url(" + imageData + ");";
			imageDataStyle += "background: url(" + imageData + ");";
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
		 * Gets the font color if defined inline
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
		 * Gets the font family if defined inline
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
		 * Gets the font weight if defined inline
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
		 * Gets the font size if defined inline
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
		 * Gets the line height if defined inline
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
		public function getWrapperTag(wrapperTag:String = "", end:Boolean = false, styles:String = ""):String {
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
			
			//if (instance is IStyleClient && IStyleClient(instance).getStyle("borderWeight")) {
				
			//}
			
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
				// the following line doesn't work unless the width is set
				//stylesValue += "display:block;margin:" + instance.horizontalCenter + " auto;left:0;right:0;";
				
				// using display table allows you to center a item without knowing it's width 
				stylesValue += "display:table;margin:" + instance.horizontalCenter + " auto;left:0;right:0;";
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
		 * */
		public function getVerticalPositionHTML(instance:IVisualElement, propertyModel:Styles, stylesValue:String = "", isBasicLayout:Boolean = true):String {
			
			if (!isBasicLayout) return stylesValue;
			
			if (instance.verticalCenter!=null) {
				stylesValue += "display:table;margin:" + instance.verticalCenter + " auto;";
				stylesValue += "top:50%;transform:translateY(-50%);-webkit-transform: translateY(-50%);-ms-transform: translateY(-50%);";
				stylesValue = stylesValue.replace("absolute", "relative");
				
				propertyModel.display = Styles.TABLE;
				propertyModel.position = Styles.RELATIVE;
				propertyModel.margin = instance.verticalCenter + " auto;";
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
		 * Get border and background styles of a border container
		 * */
		public function getBorderString(element:IStyleClient):String {
			var value:String = "";
			var borderWeight:Number = element.getStyle("borderWeight");
			
			if (element.getStyle("backgroundAlpha")!=0) {
				value += "background-color:" + DisplayObjectUtils.getColorInRGB(element.getStyle("backgroundColor"), element.getStyle("backgroundAlpha")) + ";";
			}
			
			if (element.getStyle("borderVisible")) {
				var borderSides:String = element.getStyle("borderSides");
				
				value += "border-style:solid;";
				
				if (borderSides!="left top right bottom") {
					var borderValues:String = "";
					
					borderValues += (borderSides.indexOf("top")!=-1) ? borderWeight + "px" : "0px";
					borderValues += (borderSides.indexOf("right")!=-1) ? borderWeight + "px" : "0px";
					borderValues += (borderSides.indexOf("bottom")!=-1) ? borderWeight + "px" : "0px";
					borderValues += (borderSides.indexOf("left")!=-1) ? borderWeight + "px" : "0px";
					
					value += "border-width:" + borderValues;
				}
				else {
					value += "border-width:" + borderWeight + "px;";
				}
				
				if (element.getStyle("borderColor")!==undefined) {
					value += "border-color:" + DisplayObjectUtils.getColorInHex(element.getStyle("borderColor"), true) + ";";
				}
				
				
			}
			
			if (StyleUtils.isStyleDeclaredInline(element, "color")) {
				value += "color:" + DisplayObjectUtils.getColorInHex(element.getStyle("color"), true) + ";";
			}
			
			return value;
		}
		
		/**
		 * Get corner radius styles of a border container
		 * */
		public function getCornerRadiusString(element:IStyleClient):String {
			var value:String = "";
			
			if (element.getStyle("cornerRadius")!==undefined) {
				value += "border-radius:" + element.getStyle("cornerRadius") + ";";
			}
			
			return value;
		}
		
		/**
		 * Set styles. REFACTOR This is doing too many things. 
		 * */
		public function setStyles(component:Object, stylesValue:String = "", singleton:Boolean = false):String {
			var out:String = ">";
			var formatted:String;
			
			if (useInlineStyles) {
				return " style=\"" + stylesValue + "\"" + (singleton?"\>":">");
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
			
			return (singleton?"\>":">");
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
			var styleName:String = styleName in instance ? instance.styleName : null;
			
			if (styleName!=null && styleName!="") {
				value += value.charAt(value.length)!=" " ? " " : "";
				value += "class=\"" + styleName + "\"";
			}
			
			return value;
		}
		
		public static const VERTICAL_LINE:String = "verticalLine";
		public static const HORIZONTAL_LINE:String = "horizontalLine";
		public static const LINE:String = "line";
		
		/**
		 * Get line position details
		 * For horizontal and vertical lines the start positions are ignored
		 * because we create a wrapper div positioning the SVG contents. 
		 * This could be incorrect but we have a low bar for this option.
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
				value += " x1=\"" + line.xFrom + "\" x2=\""+ line.xTo  + "\"";
				value += " y1=\"" + line.yFrom + "\" y2=\"" + line.yTo + "\"";
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
		 * Get url attribute
		 * */
		public function getAttribute(name:String, value:String = "", encode:Boolean = true):String {
			// need to encode to be inside attribute quotes
			value = "" + name + "=\"" + value + "\"";
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
		private var addContainerDiv:Boolean;
		
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