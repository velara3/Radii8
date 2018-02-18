package com.flexcapacitor.managers
{
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.model.IDocument;
	
	import flash.display.DisplayObject;
	
	import mx.core.IVisualElement;
	
	import spark.components.Scroller;

	/**
	 * 
	 **/
	public class ScaleManager {
		
		public function ScaleManager() {
			
		}
		
		/**
		 * Stops on the scale
		 * */
		public static var scaleStops:Array = [.05,.0625,.0833,.125,.1666,.25,.333,.4,.50,.667,.8,.9,1,1.25,1.50,1.75,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
		
		/**
		 * Increases the zoom of the target application to next value 
		 * */
		public static function increaseScale(valueFrom:Number = NaN, dispatchEvent:Boolean = true):void {
			var selectedDocument:IDocument = Radiate.instance.selectedDocument;
			var newScale:Number;
			var currentScale:Number;
			
			
			if (isNaN(valueFrom)) {
				currentScale = Number(DisplayObject(selectedDocument.instance).scaleX.toFixed(4));
			}
			else {
				currentScale = valueFrom;
			}
			
			//newScale = DisplayObject(document).scaleX;
			
			for (var i:int=0;i<scaleStops.length;i++) {
				if (currentScale<scaleStops[i]) {
					newScale = scaleStops[i];
					break;
				}
			}
			
			if (i==scaleStops.length-1) {
				newScale = scaleStops[i];
			}
			
			newScale = Number(newScale.toFixed(4));
			
			setScale(newScale, dispatchEvent);
			
		}
		
		/**
		 * Decreases the zoom of the target application to next value 
		 * */
		public static function decreaseScale(valueFrom:Number = NaN, dispatchEvent:Boolean = true):void {
			var selectedDocument:IDocument = Radiate.instance.selectedDocument;
			var newScale:Number;
			var currentScale:Number;
			
			if (isNaN(valueFrom)) {
				currentScale = Number(DisplayObject(selectedDocument.instance).scaleX.toFixed(4));
			}
			else {
				currentScale = valueFrom;
			}
			
			//newScale = DisplayObject(document).scaleX;
			
			for (var i:int=scaleStops.length;i--;) {
				if (currentScale>scaleStops[i]) {
					newScale = scaleStops[i];
					break;
				}
			}
			
			if (i==0) {
				newScale = scaleStops[i];
			}
			
			newScale = Number(newScale.toFixed(4));
			
			setScale(newScale, dispatchEvent);
			
		}
		
		/**
		 * Gets the scale of the target application. 
		 * */
		public static function getScale():Number {
			var selectedDocument:IDocument = Radiate.instance.selectedDocument;
			
			if (selectedDocument && selectedDocument.instance && "scaleX" in selectedDocument.instance) {
				return Math.max(selectedDocument.instance.scaleX, selectedDocument.instance.scaleY);
			}
			
			return NaN;
		}
		
		/**
		 * Sets the zoom of the target application to value. 
		 * */
		public static function setScale(value:Number, dispatchEvent:Boolean = true):void {
			var selectedDocument:IDocument = Radiate.instance.selectedDocument;
			var maxScale:int = 20;
			var minScale:Number = .05;
			
			if (value>maxScale) {
				value = maxScale;
			}
			
			if (value<minScale) {
				value = minScale;
			}
			
			if (selectedDocument && !isNaN(value) && value>0) {
				//DisplayObject(selectedDocument.instance).scaleX = value;
				//DisplayObject(selectedDocument.instance).scaleY = value;
				selectedDocument.scale = Math.min(value, maxScale);
				
				if (dispatchEvent) {
					Radiate.instance.dispatchScaleChangeEvent(selectedDocument.instance, value, value);
				}
			}
		}
		/**
		 * Restores the scale of the target application to 100%.
		 * */
		public static function restoreDefaultScale(dispatchEvent:Boolean = true):void {
			var selectedDocument:IDocument = Radiate.instance.selectedDocument;
			if (selectedDocument) {
				setScale(1, dispatchEvent);
			}
		}
		
		/**
		 * Sets the scale to fit the available space. 
		 * */
		public static function scaleToFit(enableScaleUp:Boolean = true, dispatchEvent:Boolean = true):void {
			var selectedDocument:IDocument = Radiate.instance.selectedDocument;
			var canvasScroller:Scroller = Radiate.instance.canvasScroller;
			var width:int;
			var height:int;
			var availableWidth:int;
			var availableHeight:int;
			var widthScale:Number;
			var heightScale:Number;
			var newScale:Number;
			var documentInstance:IVisualElement;
			var vsbWidth:int;
			var hsbHeight:int;
			var padding:Number = 4;
			
			documentInstance = selectedDocument ? selectedDocument.instance as IVisualElement : null;
			
			if (documentInstance) {
				//width = DisplayObject(document).width;
				//height = DisplayObject(document).height;
				width = documentInstance.width;
				height = documentInstance.height;
				vsbWidth = canvasScroller.verticalScrollBar ? canvasScroller.verticalScrollBar.width : 50;
				hsbHeight = canvasScroller.horizontalScrollBar ? canvasScroller.horizontalScrollBar.height : 50;
				availableWidth = canvasScroller.width - vsbWidth * padding;
				availableHeight = canvasScroller.height - hsbHeight * padding;
				
				//widthScale = documentInstance.width/SkinnableContainer(documentInstance).contentGroup.contentWidth;
				//heightScale = documentInstance.height/SkinnableContainer(documentInstance).contentGroup.contentHeight;
				
				//var scrollerPaddedWidth:int = canvasScroller.width + documentPadding;
				//var scrollerPaddedHeight:int = canvasScroller.height + documentPadding;
				
				// if the visible area is less than our content then scale down
				if (height > availableHeight || width > availableWidth) {
					newScale = availableHeight/height;
					width = newScale * width;
					height = newScale * height;
				}
				else if (height < availableHeight && width < availableWidth) {
					newScale = Math.min(availableHeight/height, availableWidth/width);
					width = newScale * width;
					height = newScale * height;
					//newScale = Math.min(availableHeight/height, availableWidth/width);
					//newScale = Math.max(availableHeight/height, availableWidth/width);
				}
				
				if (newScale>1 && !enableScaleUp) {
					setScale(1, dispatchEvent);
				}
				else {
					setScale(newScale, dispatchEvent);
				}
				
				////////////////////////////////////////////////////////////////////////////////
				/*var documentRatio:Number = width / height;
				var canvasRatio:Number = availableWidth / availableHeight;
				
				var newRatio:Number = documentRatio / canvasRatio;
				newRatio = canvasRatio / documentRatio;
				newRatio = 1-documentRatio / canvasRatio;*/
				
			}
		}
	}
}