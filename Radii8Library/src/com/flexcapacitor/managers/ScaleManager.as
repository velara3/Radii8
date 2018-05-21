package com.flexcapacitor.managers
{
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.model.IDocument;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import mx.core.IVisualElement;
	
	import spark.components.Scroller;
	import spark.effects.Animate;
	import spark.effects.Scale;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;

	/**
	 * Scale document
	 **/
	public class ScaleManager {
		
		public function ScaleManager() {
			
		}
		
		public static var MAX_SCALE:int = 32;
		public static var MIN_SCALE:Number = .01;
		
		public static var scaleAnimation:Animate;
		public static var scaleAnimationDuration:int = 250;
		public static var scaleAnimationStartDelay:int = 0;
		
		/**
		 * Stops on the scale
		 * */
		public static var scaleStops:Array = [MIN_SCALE,.015,.02,.025,.033,.05,.0625,.0833,.125,.1666,.25,.333,.4,.50,.667,
			.8,.9,1,1.25,1.50,1.75,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,19,20,21,22,23,24,25,26,27,28,29,30,31,MAX_SCALE];
		
		/**
		 * Increases the scale of the document by the specified amount 
		 * and centers on a point if provided
		 * */
		public static function increaseScaleBy(percentAmount:int = 10, point:Point = null, dispatchEvent:Boolean = true):void {
			var newScale:Number;
			var currentScale:Number;
			var newPoint:Point;
			var scaleByAmount:Number = Math.abs(percentAmount)/100;
			
			currentScale = getScale();
			
			if (currentScale<=1) {
				newScale = currentScale+currentScale*scaleByAmount;
			}
			else {
				newScale = currentScale+scaleByAmount;
			}
			
			setScale(newScale);
			
			if (point) {
				newPoint = new Point();
				newPoint.x = point.x * newScale;
				newPoint.y = point.y * newScale;
			}
			
			if (newPoint!=null) {
				DocumentManager.centerViewOnPoint(DocumentManager.canvasScroller, newPoint);
			}
		}
		
		/**
		 * Decreases the scale of the document by the specified amount 
		 * and centers on a point if provided 
		 * */
		public static function decreaseScaleBy(percentAmount:int = 10, point:Point = null, dispatchEvent:Boolean = true):void {
			var selectedDocument:IDocument = Radiate.selectedDocument;
			var newScale:Number;
			var currentScale:Number = getScale();
			var newPoint:Point;
			var scaleByAmount:Number = Math.abs(percentAmount)/100;
			
			if (currentScale<=1) {
				newScale = currentScale-currentScale*scaleByAmount;
			}
			else {
				newScale = currentScale-scaleByAmount;
			}
			
			setScale(newScale);
			
			if (point) {
				newPoint = new Point();
				newPoint.x = point.x * newScale;
				newPoint.y = point.y * newScale;
			}
			
			if (newPoint!=null) {
				DocumentManager.centerViewOnPoint(DocumentManager.canvasScroller, newPoint);
			}
		}	
		
		/**
		 * Increases the zoom of the target application to next value 
		 * */
		public static function increaseScale(valueFrom:Number = NaN, dispatchEvent:Boolean = true):void {
			var selectedDocument:IDocument = Radiate.selectedDocument;
			var newScale:Number;
			var currentScale:Number;
			
			
			if (isNaN(valueFrom)) {
				currentScale = Number(DisplayObject(selectedDocument.instance).scaleX.toFixed(4));
			}
			else {
				currentScale = valueFrom;
			}
			
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
			var selectedDocument:IDocument = Radiate.selectedDocument;
			var newScale:Number;
			var currentScale:Number;
			
			if (isNaN(valueFrom)) {
				currentScale = Number(DisplayObject(selectedDocument.instance).scaleX.toFixed(4));
			}
			else {
				currentScale = valueFrom;
			}
			
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
			var selectedDocument:IDocument = Radiate.selectedDocument;
			
			if (selectedDocument && selectedDocument.instance && "scaleX" in selectedDocument.instance) {
				return Math.max(selectedDocument.instance.scaleX, selectedDocument.instance.scaleY);
			}
			
			return NaN;
		}
		
		/**
		 * Sets the zoom of the target application to value. 
		 * */
		public static function setScale(value:Number, dispatchEvent:Boolean = true):void {
			var selectedDocument:IDocument = Radiate.selectedDocument;
			var maxScale:int = MAX_SCALE;
			var minScale:Number = MIN_SCALE;
			
			if (value>maxScale) {
				value = maxScale;
			}
			
			if (value<minScale) {
				value = minScale;
			}
			
			if (selectedDocument && !isNaN(value) && value>0) {
				selectedDocument.scale = Math.min(value, maxScale);
				
				if (dispatchEvent) {
					Radiate.dispatchScaleChangeEvent(selectedDocument.instance, value, value);
				}
			}
		}
		
		/**
		 * Animate to a specified scale value
		 **/
		public static function animateScalePointIntoView(newScale:Point, oldScale:Point = null, target:Object = null):void {
			var scaleMotionPaths:Vector.<MotionPath>;
			var scaleXPath:SimpleMotionPath;
			var scaleYPath:SimpleMotionPath;
			
			if (target==null) return;
			
			scaleAnimation = new Animate();
			scaleAnimation.duration = scaleAnimationDuration;
			scaleAnimation.startDelay = scaleAnimationStartDelay;
			
			if (newScale) {
				scaleXPath = new SimpleMotionPath("scaleX", oldScale.x, newScale.x);
				scaleYPath = new SimpleMotionPath("scaleY", oldScale.y, newScale.y);
			}
			else {
				scaleXPath = new SimpleMotionPath("scaleX", null, newScale.x);
				scaleYPath = new SimpleMotionPath("scaleY", null, newScale.y);
			}
			
			//scrollBarAnimation.addEventListener(EffectEvent.EFFECT_END, hideScrollBarAnimation_effectEndHandler);
			scaleMotionPaths = Vector.<MotionPath>([scaleXPath, scaleYPath]);
			scaleAnimation.motionPaths = scaleMotionPaths;
			scaleAnimation.play([target]);
		}
		
		/**
		 * Restores the scale of the target application to 100%.
		 * */
		public static function restoreDefaultScale(dispatchEvent:Boolean = true):void {
			var selectedDocument:IDocument = Radiate.selectedDocument;
			if (selectedDocument) {
				setScale(1, dispatchEvent);
			}
		}
		
		/**
		 * Sets the scale to fit the available space. 
		 * */
		public static function scaleToFit(enableScaleUp:Boolean = true, dispatchEvent:Boolean = true):void {
			var selectedDocument:IDocument = Radiate.selectedDocument;
			var canvasScroller:Scroller = DocumentManager.canvasScroller;
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
				width = documentInstance.width;
				height = documentInstance.height;
				vsbWidth = canvasScroller.verticalScrollBar ? canvasScroller.verticalScrollBar.width : 50;
				hsbHeight = canvasScroller.horizontalScrollBar ? canvasScroller.horizontalScrollBar.height : 50;
				availableWidth = canvasScroller.width - vsbWidth * padding;
				availableHeight = canvasScroller.height - hsbHeight * padding;
				
				// scale down
				if (height > availableHeight || width > availableWidth) {
					newScale = Math.min(availableHeight/height, availableWidth/width);
					width = newScale * width;
					height = newScale * height;
				}
				// scale up
				else if (height < availableHeight && width < availableWidth) {
					newScale = Math.min(availableHeight/height, availableWidth/width);
					width = newScale * width;
					height = newScale * height;
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