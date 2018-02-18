package com.flexcapacitor.controller
{
	import com.flexcapacitor.managers.ClipboardManager;
	import com.flexcapacitor.managers.ScaleManager;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.ImageData;
	import com.flexcapacitor.utils.ClassUtils;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.StageQuality;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.IUIComponent;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.managers.LayoutManager;
	
	import spark.components.Image;
	import spark.components.Scroller;
	import spark.core.IGraphicElement;
	import spark.core.IViewport;
	import spark.primitives.BitmapImage;
	import spark.primitives.supportClasses.GraphicElement;

	/**
	 * Commands and utility methods. 
	 * Refactoring effort to lower build time and times when code complete fails in FB
	 **/
	public class RadiateUtilities extends Console {
		
		public function RadiateUtilities() {
			
		}
		
		/**
		 * Set the scroll position of the document
		 * */
		public static function setScrollPosition(x:int, y:int):void {
			var selectedDocument:IDocument = Radiate.instance.selectedDocument;
			var canvasScroller:Scroller = Radiate.instance.canvasScroller;
			
			if (!canvasScroller) return;
			
			var viewport:IViewport = canvasScroller.viewport;
			var vsbWidth:int = canvasScroller.verticalScrollBar ? canvasScroller.verticalScrollBar.width : 11;
			var hsbHeight:int = canvasScroller.horizontalScrollBar ? canvasScroller.horizontalScrollBar.height : 11;
			var availableWidth:int = canvasScroller.width;// - vsbWidth;
			var availableHeight:int = canvasScroller.height;// - hsbHeight;
			
			viewport.horizontalScrollPosition = Math.max(0, x);
			viewport.verticalScrollPosition = Math.max(0, y);
			
		}
		
		/**
		 * Center the application on a point
		 * */
		public static function centerOnPoint(point:Point):void {
			var selectedDocument:IDocument = Radiate.instance.selectedDocument;
			var canvasScroller:Scroller = Radiate.instance.canvasScroller;
			
			if (!canvasScroller) return;
			var viewport:IViewport = canvasScroller.viewport;
			var availableWidth:int = canvasScroller.width;// - vsbWidth;
			var availableHeight:int = canvasScroller.height;// - hsbHeight;
			var vsbWidth:int = canvasScroller.verticalScrollBar ? canvasScroller.verticalScrollBar.width : 11;
			var hsbHeight:int = canvasScroller.horizontalScrollBar ? canvasScroller.horizontalScrollBar.height : 11;
			var documentVisualElement:IVisualElement = IVisualElement(selectedDocument.instance);
			var currentScale:Number = ScaleManager.getScale();
			var contentWidth:int = documentVisualElement.width * currentScale;
			var contentHeight:int = documentVisualElement.height * currentScale;
			
			//var horScrollPos:int = viewportWidth/2 - contentWidth/2;
			var newX:int = availableWidth/2 - (contentWidth/2 - point.x);
			newX = availableWidth/2 - (contentWidth/2 + (contentWidth/2-point.x));
			newX = (contentWidth/2 + (contentWidth/2-(point.x*currentScale))) - availableWidth/2;
			//newX = availableWidth/2 - (contentWidth/2 - (contentWidth/2-point.x));
			//newX = (availableWidth- contentWidth)/2 - point.x;
			//newX = (availableWidth - contentWidth + vsbWidth) / 2 - point.x;
			var newY:int = (contentHeight/2 + (contentHeight/2-(point.y*currentScale))) - availableHeight/2;
			newY = canvasScroller.verticalScrollBar.value;		
			setScrollPosition(newX, newY);
			// (495 - 750) - 736
			// (-255) - 736
			// -991
			
			// 495 - (750-736)
			// 495 - (14)
			// 481
			
			// 495 - (750-736*1)
			// 495 - (14)
			// 481
			
		}
		
		/**
		 * Center the application. 
		 * 
		 * @param vertically enable vertically centering options. if verticalTop is false top and bottom may be cut off. if true, scroll to top
		 * @param verticallyTop if document is taller than avialable space keep it at the top
		 * @param horizontalLeft if document is wider than avialable space keep it to the left
		 * @param totalDocumentPadding adjustment for space at the top of the document. not sure really
		 * */
		public static function centerApplication(vertically:Boolean = true, verticallyTop:Boolean = true, horizontalLeft:Boolean=true, totalDocumentPadding:int = 0):void {
			var selectedDocument:IDocument = Radiate.instance.selectedDocument;
			var canvasScroller:Scroller = Radiate.instance.canvasScroller;
			var canvasBackground:Object = Radiate.instance.canvasBackground;
			
			if (!canvasScroller) return;
			var viewport:IViewport = canvasScroller.viewport;
			var documentVisualElement:IVisualElement = IVisualElement(selectedDocument.instance);
			//var contentHeight:int = viewport.contentHeight * getScale();
			//var contentWidth:int = viewport.contentWidth * getScale();
			// get document size NOT scroll content size
			var contentWidth:int = documentVisualElement.width * ScaleManager.getScale();
			var contentHeight:int = documentVisualElement.height * ScaleManager.getScale();
			var newHorizontalPosition:int;
			var newVerticalPosition:int;
			var needsValidating:Boolean;
			//var vsbWidth:int = canvasScroller.verticalScrollBar ? canvasScroller.verticalScrollBar.width : 11;
			var hsbHeight:int = canvasScroller.horizontalScrollBar ? canvasScroller.horizontalScrollBar.height : 11;
			var availableWidth:int = canvasScroller.width;// - vsbWidth;
			var availableHeight:int = canvasScroller.height;// - hsbHeight;
			
			if (LayoutManager.getInstance().isInvalid()) {
				needsValidating = true;
				//LayoutManager.getInstance().validateClient(canvasScroller as ILayoutManagerClient);
				//LayoutManager.getInstance().validateNow();
			}
			
			
			if (vertically) {
				// scroller height 359, content height 504, content height validated 550
				// if document is taller than available space and 
				// verticalTop is true then keep it at the top
				if (contentHeight > availableHeight && verticallyTop) {
					newVerticalPosition = canvasBackground.y - totalDocumentPadding;
					viewport.verticalScrollPosition = Math.max(0, newVerticalPosition);
				}
				else if (contentHeight > availableHeight) {
					newVerticalPosition = (contentHeight + hsbHeight - availableHeight) / 2;
					viewport.verticalScrollPosition = Math.max(0, newVerticalPosition);
				}
				else {
					// content height 384, scroller height 359, vsp 12
					newVerticalPosition = (availableHeight + hsbHeight - contentHeight) / 2;
					viewport.verticalScrollPosition = Math.max(0, newVerticalPosition);
				}
			}
			
			// if width of content is wider than canvasScroller width then center
			if (canvasScroller.width < contentWidth) {
				
				if (horizontalLeft) {
					newHorizontalPosition = 0;
					viewport.horizontalScrollPosition = newHorizontalPosition;
				}
				else {
					newHorizontalPosition = (contentWidth - availableWidth) / 2;
					viewport.horizontalScrollPosition = Math.max(0, newHorizontalPosition);
				}
			}
			else {
				//newHorizontalPosition = (contentWidth - canvasScroller.width) / 2;
				//viewport.horizontalScrollPosition = Math.max(0, newHorizontalPosition);
			}
		}
		
		/**
		 * Gets a snapshot of document and returns bitmap data
		 * */
		public static function getDocumentSnapshot(iDocument:IDocument, scale:Number = 1, quality:String = StageQuality.BEST):BitmapData {
			var bitmapData:BitmapData;
			
			if (iDocument && iDocument.instance) {
				bitmapData = DisplayObjectUtils.getUIComponentWithQuality(iDocument.instance as UIComponent, quality) as BitmapData;
			}
			
			return bitmapData;
		}
		
		/**
		 * Gets a snapshot of target and returns bitmap data
		 * This method is clipping the content sometimes.  
		 * */
		public static function getSnapshot(object:Object, scale:Number = 1, quality:String = StageQuality.BEST, smoothing:Boolean = true, clip:Boolean = true):BitmapData {
			var bitmapData:BitmapData;
			
			if (object is IUIComponent) {
				bitmapData = DisplayObjectUtils.getUIComponentBitmapData(object as IUIComponent, quality, smoothing);
			}
			else if (object is IGraphicElement) {
				bitmapData = DisplayObjectUtils.getGraphicElementBitmapData(object as IGraphicElement);
			}
			else if (object is IVisualElement) {
				bitmapData = DisplayObjectUtils.getVisualElementBitmapData(object as IVisualElement);
			}
			
			return bitmapData;
		}
		
		/**
		 * Gets a snapshot of target and returns base 64 image data
		 * */
		public static function getThumbnailBaseData(object:Object, width:int=100, height:int=100):String {
			var documentBitmapData:BitmapData;
			var base64ImageData:String;
			
			if (object is IDocument) {
				object = IDocument(object).instance;
			}
			
			if (object is IUIComponent || object is IGraphicElement || object is IVisualElement) {
				//documentBitmapData = DisplayObjectUtils.getUIComponentWithQuality(instance as UIComponent, StageQuality.LOW) as BitmapData;
				documentBitmapData = getSnapshot(object) as BitmapData;
				documentBitmapData = DisplayObjectUtils.resizeBitmapData(documentBitmapData, width, height, "letterbox");
				base64ImageData = DisplayObjectUtils.getBase64ImageDataString(documentBitmapData, DisplayObjectUtils.PNG, null, true);
			}
			
			return base64ImageData;
		}
		
		/**
		 * Get base 64 string value from bitmap data
		 * */
		public static function getBase64FromBitmapData(bitmapData:BitmapData, addHeader:Boolean = true):String {
			var base64ImageData:String;
			base64ImageData = DisplayObjectUtils.getBase64ImageDataString(bitmapData, DisplayObjectUtils.PNG);
			
			return base64ImageData;
		}
		
		
		/**
		 * Sizes the document to the current selected target
		 * */
		public static function sizeDocumentToSelection():void {
			var iDocument:IDocument = Radiate.instance.selectedDocument;
			
			if (Radiate.instance.target && iDocument) {
				var rectangle:Rectangle = Radiate.getSize(Radiate.instance.target);
				
				if (rectangle.width>0 && rectangle.height>0) {
					Radiate.setProperties(iDocument.instance, ["width","height"], rectangle, "Size document to selection");
				}
			}
		}
		
		/**
		 * Removes x, y, top, bottom, and so on so that component is positioned to container
		 * */
		public static function removeExplicitPositionFromSelection(target:Object):Boolean {
			var iDocument:IDocument = Radiate.instance.selectedDocument;
			var sized:Boolean;
			
			if (target) {
				// I think there is an array of positions somewhere
				sized = Radiate.clearProperties(target, ["x","y", "left", "right", "top", "bottom", "verticalCenter", "horizontalCenter", "baseline"], null, "Remove positioning");
			}
			
			return sized;
		}
		
		/**
		 * Removes width and height so that component is sized to content
		 * */
		public static function removeExplicitSizingFromSelection(target:Object):Boolean {
			var iDocument:IDocument = Radiate.instance.selectedDocument;
			var sized:Boolean;
			
			if (target) {
				sized = Radiate.clearProperties(target, ["width","percentWidth", "height", "percentHeight"], null, "Removed explicit size");
			}
			
			return sized;
		}
		
		/**
		 * Removes explicit width 
		 * */
		public static function removeExplicitWidthFromSelection(target:Object):Boolean {
			var iDocument:IDocument = Radiate.instance.selectedDocument;
			var sized:Boolean;
			
			if (target) {
				sized = Radiate.clearProperties(target, ["width","percentWidth"], null, "Removed width");
			}
			
			return sized;
		}
		
		/**
		 * Removes explicit height
		 * */
		public static function removeExplicitHeightFromSelection(target:Object):Boolean {
			var iDocument:IDocument = Radiate.instance.selectedDocument;
			var sized:Boolean;
			
			if (target) {
				sized = Radiate.clearProperties(target, ["height", "percentHeight"], null, "Removed height");
			}
			
			return sized;
		}
		
		/**
		 * Sizes the image to it's original size
		 * */
		public static function restoreImageToOriginalSize(target:Object):Boolean {
			var rectangle:Rectangle;
			var image:Image = target as Image;
			var bitmapImage:BitmapImage = image ? image.imageDisplay : null;
			var bitmapData:BitmapData;
			var resized:Boolean;
			
			if (image) {
				bitmapData = image.bitmapData;
			}
			else if (bitmapImage) {
				bitmapData = bitmapImage.bitmapData;
			}
			
			if (image || bitmapImage) {
				rectangle = new Rectangle(0, 0, target.sourceWidth, target.sourceHeight);
				
				if (rectangle.width>0 && 
					rectangle.height>0 &&
					target.width!=rectangle.width && 
					target.height!=rectangle.height) {
					Radiate.setProperties(target, ["width","height"], rectangle, "Restore to original size");
					resized = true;
				}
			}
			
			return resized;
		}
		
		/**
		 * Sizes the document to the bitmap data target
		 * */
		public static function sizeDocumentToBitmapData(iDocument:IDocument, bitmapData:BitmapData):Boolean {
			var documentInstance:Object = iDocument.instance;
			var rectangle:Rectangle;
			var resized:Boolean;
			
			if (documentInstance) {
				rectangle = new Rectangle(0, 0, bitmapData.width, bitmapData.height);
				
				if (rectangle.width>0 && rectangle.height>0) {
					Radiate.setProperties(documentInstance, ["width","height"], rectangle, "Size document to image");
					resized = true;
				}
			}
			
			return resized;
		}
		
		
		/**
		 * Sizes the current selected target to the document
		 * */
		public static function sizeSelectionToDocument(target:Object = null):Boolean {
			var radiate:Radiate = Radiate.instance;
			var iDocument:IDocument = radiate.selectedDocument;
			var targetToResize:Object = target ? target : radiate.target;
			var rectangle:Rectangle;
			var resized:Boolean;
			
			if (targetToResize && iDocument) {
				rectangle = Radiate.getSize(iDocument.instance);
				
				if (rectangle.width>0 && rectangle.height>0 && 
					targetToResize.width!=rectangle.width && 
					targetToResize.height!=rectangle.height) {
					Radiate.setProperties(targetToResize, ["width","height"], rectangle, "Size selection to document");
					resized = true;
				}
			}
			
			return resized;
		}
		
		/**
		 * Resizes the current document to show all of it's content
		 * */
		public static function expandDocumentToContents():Boolean {
			var radiate:Radiate = Radiate.instance;
			var iDocument:IDocument = radiate.selectedDocument;
			var targetObject:Object = iDocument.instance;
			var documentRectangle:Rectangle;
			var contentRectangle:Rectangle;
			var resized:Boolean;
			var width:Number;
			var height:Number;
			
			contentRectangle = new Rectangle();
			documentRectangle = new Rectangle();
			
			width = targetObject.contentGroup.contentWidth;
			height = targetObject.contentGroup.contentHeight;
			
			contentRectangle.width = width;
			contentRectangle.height = height;
			
			documentRectangle.width = targetObject.width;
			documentRectangle.height = targetObject.height;
			
			if (contentRectangle.width>documentRectangle.width || contentRectangle.height>documentRectangle.height) {
				contentRectangle.width = Math.max(contentRectangle.width, documentRectangle.width);
				contentRectangle.height = Math.max(contentRectangle.height, documentRectangle.height);
				Radiate.setProperties(targetObject, ["width","height"], contentRectangle, "Expand document");
				resized = true;
			}
			
			return resized;
		}
		
		/**
		 * Saves the selected target as an image in the library. 
		 * If successful returns ImageData. If unsuccessful returns Error
		 * Quality is set to BEST by default. There are higher quality settings but there are 
		 * numerous bugs when enabled. Embedded or system fonts are 75% of there normal size and gradients fills are only a few colors.
		 * */
		public static function saveToLibrary(target:Object, clip:Boolean = false, scale:Number = 1, quality:String = StageQuality.BEST):Object {
			var radiate:Radiate = Radiate.instance;
			var iDocument:IDocument = radiate.selectedDocument;
			var snapshot:Object;
			var data:ImageData;
			var previousScaleX:Number;
			var previousScaleY:Number;
			
			if (target && iDocument) {
				previousScaleX = target.scaleX;
				previousScaleY = target.scaleY;
				
				target.scaleX = scale;
				target.scaleY = scale;
				
				if (!clip) {
					
					if (target is UIComponent) {
						// new 2015 method from Bitmap utils
						snapshot = DisplayObjectUtils.getSnapshotWithQuality(target as UIComponent, quality);
					}
					else if (target is DisplayObject) {
						snapshot = DisplayObjectUtils.rasterize2(target as DisplayObject);
					}
					else if (target is GraphicElement) {
						snapshot = DisplayObjectUtils.getGraphicElementBitmapData(target as GraphicElement);
					}
				}
				else {
					if (target is UIComponent) {
						snapshot = DisplayObjectUtils.getUIComponentWithQuality(target as UIComponent);
					}
					else if (target is DisplayObject) {
						snapshot = DisplayObjectUtils.rasterize2(target as DisplayObject);
					}
					else if (target is GraphicElement) {
						snapshot = DisplayObjectUtils.getGraphicElementBitmapData(target as GraphicElement);
					}
				}
				
				target.scaleX = previousScaleX;
				target.scaleY = previousScaleY;
				
				if (snapshot is BitmapData) {
					
					// need to trim the transparent areas 
					snapshot = DisplayObjectUtils.trimTransparentBitmapData(snapshot as BitmapData);
					
					data = new ImageData();
					data.bitmapData = snapshot as BitmapData;
					data.byteArray = DisplayObjectUtils.getByteArrayFromBitmapData(snapshot as BitmapData);
					data.name = ClassUtils.getIdentifierNameOrClass(target) + ".png";
					data.contentType = DisplayObjectUtils.PNG_MIME_TYPE;
					data.file = null;
					
					radiate.addAssetToDocument(data, radiate.selectedDocument);
					
					return data;
				}
				else {
					//Radiate.error("Could not create a snapshot of the selected item. " + snapshot); 
				}
			}
			
			return snapshot;
		}
		
		public static function copyDocumentImageToClipboard(iDocument:IDocument):void {
			var bitmapData:BitmapData = getDocumentSnapshot(iDocument);
			ClipboardManager.instance.copyBitmapDataToClipboard(bitmapData);
		}
		
		
		public static var updateScreenEvent:MouseEvent;
		public static const DEG_TO_RAD:Number = 0.017453292519943294444444444444444;
		
		public static function rotateImage(image:Image, angle:Number = 0):void {
			var radiate:Radiate = Radiate.instance;
			var matrix:Matrix;
			var newBitmapData:BitmapData;
			var degree:int;
			var bitmapData:BitmapData;
			var bitmapWidth:int;
			var bitmapHeight:int;
			var propertiesObject:Object;
			var properties:Array;
			var imageData:ImageData;
			var imageName:String;
			var transparent:Boolean = true;
			var smoothing:Boolean = true;
			var quality:String = StageQuality.HIGH_16X16_LINEAR;
			var bitmapColor:Number = 0;
			
			bitmapData = image && image.source ? image.source as BitmapData : null;
			
			if (image && bitmapData) {
				bitmapHeight = bitmapData.height;
				bitmapWidth = bitmapData.width;
				
				matrix = new Matrix();
				matrix.rotate(angle * DEG_TO_RAD);
				
				propertiesObject = {};
				properties = ["source"];
				
				if (angle==90) {
					newBitmapData = new BitmapData(bitmapHeight, bitmapWidth, transparent, bitmapColor);
					matrix.translate(bitmapHeight, 0);
					
					if (!isNaN(image.explicitWidth)) {
						properties.push("height");
						propertiesObject.height = image.explicitWidth;
					}
					if (!isNaN(image.explicitHeight)) {
						properties.push("width");
						propertiesObject.width = image.explicitHeight;
					}
				}
				else if (angle==-90 || angle==270) {
					newBitmapData = new BitmapData(bitmapHeight, bitmapWidth, transparent, bitmapColor);
					matrix.translate(0, bitmapWidth);
					
					if (!isNaN(image.explicitWidth)) {
						properties.push("height");
						propertiesObject.height = image.explicitWidth;
					}
					if (!isNaN(image.explicitHeight)) {
						properties.push("width");
						propertiesObject.width = image.explicitHeight;
					}
				}
				else if (angle==180) {
					newBitmapData = new BitmapData(bitmapWidth, bitmapHeight, transparent, bitmapColor);
					matrix.translate(bitmapWidth, bitmapHeight);
				}
				else {
					newBitmapData = new BitmapData(bitmapWidth*2, bitmapHeight*2, transparent, bitmapColor);
					//matrix.translate(bitmapWidth, bitmapHeight);
				}
				
				//newBitmapData.draw(bitmapData, matrix, null, null, null, smoothing);
				newBitmapData.drawWithQuality(bitmapData, matrix, null, null, null, smoothing, quality);
				
				propertiesObject.source = newBitmapData;
				
				Radiate.setProperties(image, properties, propertiesObject, "Rotate " + angle, true);
				
				// force redraw
				updateScreenEvent = new MouseEvent(MouseEvent.MOUSE_UP);
				updateScreenEvent.updateAfterEvent();
				updateScreenEvent = null;
				
				// add image data to our library
				if (image.source is BitmapData) {
					imageData = Radiate.getImageDataFromBitmapData(image.source as BitmapData);
				}
				
				imageName = "Rotated image"; // should get name from component description
				
				if (imageData) {
					imageName = imageData.name;
				}
				
				radiate.addBitmapDataToDocument(radiate.selectedDocument, newBitmapData, null, imageName, false);
			}
			else {
				Radiate.info("You must select an image to apply rotation"); 
			}
		}
		
		public static function trimImage(image:Image):void {
			var radiate:Radiate = Radiate.instance;
			var newBitmapData:BitmapData;
			var image:Image;
			var bitmapData:BitmapData;
			var bitmapWidth:int;
			var bitmapHeight:int;
			var propertiesObject:Object;
			var properties:Array;
			var imageData:ImageData;
			var imageName:String;
			
			bitmapData = image && image.source ? image.source as BitmapData : null;
			
			if (image && bitmapData) {
				bitmapHeight = bitmapData.height;
				bitmapWidth = bitmapData.width;
				
				newBitmapData = DisplayObjectUtils.trimTransparentBitmapData(bitmapData);
				
				if (newBitmapData==null) {
					info("Nothing was trimmed");
					return;
				}
				
				if (newBitmapData.width==bitmapData.width && newBitmapData.height==bitmapData.height) {
					info("Nothing was trimmed");
					return;
				}
				
				propertiesObject = {};
				properties = ["source"];
				propertiesObject.source = newBitmapData;
				
				Radiate.setProperties(image, properties, propertiesObject, "Trimmed transparent edges", true);
				
				// force redraw
				updateScreenEvent = new MouseEvent(MouseEvent.MOUSE_UP);
				updateScreenEvent.updateAfterEvent();
				
				// add image data to our library
				if (image.source is BitmapData) {
					imageData = Radiate.getImageDataFromBitmapData(image.source as BitmapData);
				}
				
				imageName = "Trimmed image"; // should get name from component description
				
				if (imageData) {
					imageName = imageData.name;
				}
				
				radiate.addBitmapDataToDocument(radiate.selectedDocument, newBitmapData, null, imageName, false);
			}
			else {
				Radiate.info("You must select an image to trim"); 
			}
		}
	}
}