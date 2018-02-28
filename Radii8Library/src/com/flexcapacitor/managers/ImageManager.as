package com.flexcapacitor.managers
{
	import com.flexcapacitor.controller.Console;
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.ImageData;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	
	import flash.display.BitmapData;
	import flash.display.StageQuality;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import mx.core.IUIComponent;
	import mx.core.IVisualElement;
	
	import spark.components.Image;
	import spark.core.IGraphicElement;
	import spark.primitives.BitmapImage;
	
	/**
	 * Manages images and image utility methods 
	 **/
	public class ImageManager extends Console
	{
		public function ImageManager(s:SINGLEDOUBLE)
		{
			super();
		}
		
		public static var updateScreenEvent:MouseEvent;
		public static const DEG_TO_RAD:Number = 0.017453292519943294444444444444444;
		
		/**
		 * Rotates image
		 **/
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
				
				ComponentManager.setProperties(image, properties, propertiesObject, "Rotate " + angle, true);
				
				// force redraw
				updateScreenEvent = new MouseEvent(MouseEvent.MOUSE_UP);
				updateScreenEvent.updateAfterEvent();
				updateScreenEvent = null;
				
				// add image data to our library
				if (image.source is BitmapData) {
					imageData = LibraryManager.getImageDataFromBitmapData(image.source as BitmapData);
				}
				
				imageName = "Rotated image"; // should get name from component description
				
				if (imageData) {
					imageName = imageData.name;
				}
				
				LibraryManager.addBitmapDataToDocument(Radiate.selectedDocument, newBitmapData, null, imageName, false);
			}
			else {
				Radiate.info("You must select an image to apply rotation"); 
			}
		}

		/**
		 * Flips an image horizontally
		 **/
		public static function flipImageHorizontally(image:Image):void {
			flipImage(image, true);
		}
		
		/**
		 * Flips an image vertically 
		 **/
		public static function flipImageVertically(image:Image, horizontal:Boolean = false):void {
			flipImage(image, false);
		}
		
		/**
		 * Flips an image
		 **/
		public static function flipImage(image:Image, horizontal:Boolean = false):void {
			var matrix:Matrix;
			var newBitmapData:BitmapData;
			var bitmapData:BitmapData;
			var bitmapWidth:int;
			var bitmapHeight:int;
			var propertiesObject:Object;
			var properties:Array;
			var imageData:ImageData;
			var imageName:String;
			var transparent:Boolean = true;
			var smoothing:Boolean = false;
			var quality:String = StageQuality.HIGH_16X16_LINEAR;
			var bitmapColor:Number = 0;
			var direction:String;
			
			bitmapData = image && image.source ? image.source as BitmapData : null;
			
			if (image && bitmapData) {
				bitmapWidth = bitmapData.width;
				bitmapHeight = bitmapData.height;
				
				if (horizontal) {
					matrix = new Matrix(-1, 0, 0, 1, bitmapWidth, 0);
					direction = "horizontally";
				}
				else {
					matrix = new Matrix(1, 0, 0, -1, 0, bitmapHeight);
					direction = "vertically";
				}
				
				propertiesObject = {};
				properties = ["source"];
				newBitmapData = new BitmapData(bitmapWidth, bitmapHeight, transparent, bitmapColor);
				
				newBitmapData.drawWithQuality(bitmapData, matrix, null, null, null, smoothing, quality);
				
				propertiesObject.source = newBitmapData;
				
				ComponentManager.setProperties(image, properties, propertiesObject, "Flipped image " + direction, true);
				
				// force redraw
				updateScreenEvent = new MouseEvent(MouseEvent.MOUSE_UP);
				updateScreenEvent.updateAfterEvent();
				updateScreenEvent = null;
				
				// add image data to our library
				if (image.source is BitmapData) {
					imageData = LibraryManager.getImageDataFromBitmapData(image.source as BitmapData);
				}
				
				imageName = "Flipped image"; // should get name from component description
				
				if (imageData) {
					imageName = imageData.name;
				}
				
				LibraryManager.addBitmapDataToDocument(Radiate.selectedDocument, newBitmapData, null, imageName, false);
			}
			else {
				Radiate.info("You must select an image to apply rotation"); 
			}
		}
		
		/**
		 * Removes transparent pixels from edges of image
		 **/
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
				
				ComponentManager.setProperties(image, properties, propertiesObject, "Trimmed transparent edges", true);
				
				// force redraw
				updateScreenEvent = new MouseEvent(MouseEvent.MOUSE_UP);
				updateScreenEvent.updateAfterEvent();
				
				// add image data to our library
				if (image.source is BitmapData) {
					imageData = LibraryManager.getImageDataFromBitmapData(image.source as BitmapData);
				}
				
				imageName = "Trimmed image"; // should get name from component description
				
				if (imageData) {
					imageName = imageData.name;
				}
				
				LibraryManager.addBitmapDataToDocument(Radiate.selectedDocument, newBitmapData, null, imageName, false);
			}
			else {
				Radiate.info("You must select an image to trim"); 
			}
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
					ComponentManager.setProperties(target, ["width","height"], rectangle, "Restore to original size");
					resized = true;
				}
			}
			
			return resized;
		}
		
		/**
		 * Returns an object that contains the reduced width and height 
		 * if the object doesn't fit inside the document or returns null if it will fit
		 **/
		public static function getConstrainedImageSizeObject(iDocument:IDocument, bitmapData:Object):Object {
			var propertiesObject:Object = {};
			var constraintNeeded:Boolean;
			var resized:Boolean;
			
			const WIDTH:String = "width";
			const HEIGHT:String = "height";
			
			if (bitmapData && bitmapData.width>0 && bitmapData.height>0) {
				
				if (bitmapData.width>iDocument.instance.width) {
					//aspectRatio = bitmapData.width / iDocument.instance.width;
					propertiesObject = DisplayObjectUtils.getConstrainedSize(bitmapData, "width", iDocument.instance.width);
					constraintNeeded = true;
					resized = true;
				}
				
				if (constraintNeeded && propertiesObject.height>iDocument.instance.height) {
					propertiesObject = DisplayObjectUtils.getConstrainedSize(bitmapData, "height", iDocument.instance.height);
					resized = true;
				}
				else if (!constraintNeeded && bitmapData.height>iDocument.instance.height) {
					// check height is not larger than document width
					// and document height is not larger than width
					//aspectRatio = bitmapData.height / iDocument.instance.height;
					propertiesObject = DisplayObjectUtils.getConstrainedSize(bitmapData, "height", iDocument.instance.height);
					resized = true;
				}
				
			}
			
			if (!resized) {
				return null; 
			}
			
			return propertiesObject; 
		}
	}
}

class SINGLEDOUBLE{}