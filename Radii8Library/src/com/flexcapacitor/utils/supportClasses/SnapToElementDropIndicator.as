package com.flexcapacitor.utils.supportClasses {
	import mx.skins.ProgrammaticSkin;
	
	import spark.components.Application;
	
	/**
	 * Shows a horizontal and vertical lines to indicate
	 * a drop location in a basic layout
	 * */
	public class SnapToElementDropIndicator extends ProgrammaticSkin {
		
		public function SnapToElementDropIndicator() {
			
		}
		
		public var left:Number;
		public var top:Number;
		public var right:Number;
		public var bottom:Number;
		public var verticalCenter:Number;
		public var horizontalCenter:Number;
		
		public var showFill:Boolean = true;
		public var borderColor:Number = 0x2DA7F0;
		public var fillColor:Number = 0x2DA7F0;
		public var fillAlpha:Number = .5;
		public var lineColor:Number = 0x2B333C;
		public var lineWeight:Number = 1;
		public var lineAlpha:Number = 1;
		public var linePixelHinting:Boolean = true;
		public var lineScaleMode:String = "none";
		public var lineCaps:String = "none";
		public var drawAsRect:Boolean = false;
		public var hairlineWhenLine:Boolean = true;
		public var target:Object;
		
		public function setLines(x:Number, y:Number, rightEdge:Number = NaN, bottomEdge:Number = NaN, horizontal:Number = NaN, vertical:Number = NaN):void {
			left = x;
			top = y;
			right = rightEdge;
			bottom = bottomEdge;
			horizontalCenter = horizontal;
			verticalCenter = vertical;
		}
		
		
		/**
		 *  The measured height of this object.
		 *
		 *  @return The measured height of the object, in pixels.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		override public function get measuredHeight():Number
		{
			return parent ? parent.height : 0;
		}
		
		/**
		 *  The measured width of this object.
		 *
		 *  @return The measured width of the object, in pixels.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		override public function get measuredWidth():Number
		{
			return parent ? parent.width : 0;
		}
		
		/**
		 *  @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {   
			
			if (parent) {
				if (measuredWidth!=unscaledWidth || measuredHeight!=unscaledHeight) {
					//trace("1 updating lines: " + getTimer());
					unscaledWidth = measuredWidth;
					unscaledHeight = measuredHeight;
					setActualSize(measuredWidth, measuredHeight);
					return; // come back after size is updated
				}
			}
			
			//trace("2 updating lines: " + getTimer());
			graphics.clear();
			
			if (showFill) {
				graphics.beginFill(fillColor, fillAlpha);
				graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
				graphics.endFill();
			}
			
			if (!isNaN(left)) {
				drawLine(left, 0, lineWeight, unscaledHeight);
			}
			
			if (!isNaN(top)) {
				drawLine(0, top, unscaledWidth, lineWeight);
			}
			
			if (!isNaN(right)) {
				if (target is Application) {
					drawLine(right-1, 0, lineWeight, unscaledHeight);
				}
				else {
					drawLine(right, 0, lineWeight, unscaledHeight);
				}
			}
			
			if (!isNaN(bottom)) {
				if (target is Application) {
					drawLine(0, bottom - 1, unscaledWidth, lineWeight);
				}
				else {
					drawLine(0, bottom, unscaledWidth, lineWeight);
				}
			}
			
			if (!isNaN(horizontalCenter)) {
				drawLine(horizontalCenter, 0, lineWeight, unscaledHeight);
			}
			
			if (!isNaN(verticalCenter)) {
				drawLine(0, verticalCenter, unscaledWidth, lineWeight);
			}
			
		}
		
		public function drawLine(x:int, y:int, width:int, height:int):void {
			
			if (drawAsRect) {
				graphics.beginFill(lineColor);
				graphics.drawRect(x, y, width, height);
				graphics.endFill();
			}
			else {
				graphics.moveTo(x, y);
				//graphics.lineStyle(lineWeight, lineColor, alpha, pixelHinting, scaleMode, caps, joints);
				
				if (hairlineWhenLine) {
					graphics.lineStyle(0, lineColor, lineAlpha, linePixelHinting, lineScaleMode, lineCaps);
				}
				else {
					graphics.lineStyle(lineWeight, lineColor);
				}
				
				graphics.lineTo(width+x, height+y);
				//graphics.lin
			}
		}
	}
}
