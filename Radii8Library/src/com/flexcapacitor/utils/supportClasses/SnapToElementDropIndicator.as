package com.flexcapacitor.utils.supportClasses {
	import flash.display.LineScaleMode;
	
	import mx.skins.ProgrammaticSkin;
	
	/**
	 * Shows horizontal and vertical lines to indicate
	 * a drop location edge in a basic layout
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
		public var centerColor:Number = 0xFF0000;
		public var lineColor:Number = 0x2B333C;
		public var lineWeight:Number = 1;
		public var lineAlpha:Number = 1;
		public var linePixelHinting:Boolean = false;
		public var lineScaleMode:String = LineScaleMode.NORMAL;
		public var lineCaps:String = "none";
		public var drawAsRect:Boolean = false;
		public var hairlineWhenLine:Boolean = true;
		public var target:Object;
		public var drawHorizontalCenter:Boolean = true;
		public var drawVerticalCenter:Boolean = true;
		public var isApplication:Boolean;
		public var centerLineHeight:int = 6;
		public var centerLineWidth:int = 6;
		
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
				drawVerticalLine(left, 0, unscaledHeight, lineColor, lineWeight);
			}
			
			if (!isNaN(top)) {
				drawHorizontalLine(0, top, unscaledWidth, lineColor, lineWeight);
			}
			
			if (!isNaN(right)) {
				if (isApplication) {
					drawVerticalLine(right-1, 0, unscaledHeight, lineColor, lineWeight);
				}
				else {
					drawVerticalLine(right, 0, unscaledHeight, lineColor, lineWeight);
				}
			}
			
			if (!isNaN(bottom)) {
				if (isApplication) {
					drawHorizontalLine(0, bottom - 1, unscaledWidth, lineColor, lineWeight);
				}
				else {
					drawHorizontalLine(0, bottom, unscaledWidth, lineColor, lineWeight);
				}
			}
			
			if (!isNaN(horizontalCenter)) {
				drawVerticalLine(horizontalCenter, 0, unscaledHeight, lineColor, lineWeight);
			}
			
			if (!isNaN(verticalCenter)) {
				drawHorizontalLine(0, verticalCenter, unscaledWidth, lineColor, lineWeight);
			}
			
			var weight:int = 4;
			var centerX:Number;
			var odd:Boolean;
			var width:int;
			var height:int;
			var centerY:Number;
			
			if (drawHorizontalCenter) {
				odd = unscaledWidth/2%2!=0;
				width = odd ? 3 : 2;
				height = 0;
				centerX = Math.floor(unscaledWidth/2);
				centerX = odd ? centerX-1 : centerX-1;
				
				// top edge center
				drawHorizontalLine(centerX, 0, width, centerColor, weight);
				// bottom edge center
				drawHorizontalLine(centerX, measuredHeight-2, width, centerColor, weight);
			}
			
			if (drawVerticalCenter) {
				odd = unscaledHeight/2%2!=0;
				width = 0;
				height = odd ? 3 : 2;
				centerY = Math.floor(unscaledHeight/2);
				centerY = odd ? centerY-1 : centerY-1;
				
				// left edge middle
				drawVerticalLine(0, centerY, height, centerColor, weight);
				// right edge middle
				drawVerticalLine(measuredWidth-2, centerY, height, centerColor, weight);
			}
			
		}
		
		public function drawLine(x:Number, y:Number, width:int, height:int):void {
			
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
		
		public function drawLine2(x:int, y:int, width:int, height:int, color:Number, weight:int):void {
			graphics.moveTo(x, y);
			
			graphics.lineStyle(weight, color, 1, linePixelHinting, LineScaleMode.NORMAL, lineCaps);
			
			graphics.lineTo(width+x, height+y);
		}
		
		public function drawHorizontalLine(x:Number, y:Number, width:Number, color:Number, weight:Number):void {
			graphics.moveTo(x, y);
			
			graphics.lineStyle(weight, color, 1, linePixelHinting, LineScaleMode.NORMAL, lineCaps);
			
			graphics.lineTo(width+x, y);
		}
		
		public function drawVerticalLine(x:Number, y:Number, height:Number, color:Number, weight:Number):void {
			graphics.moveTo(x, y);
			
			graphics.lineStyle(weight, color, 1, linePixelHinting, LineScaleMode.NORMAL, lineCaps);
			
			graphics.lineTo(x, height+y);
		}
		
		public function drawRect(x:int, y:int, width:int, height:int, color:Number, weight:int):void {
			graphics.beginFill(color);
			graphics.drawRect(x, y, width, height);
			graphics.endFill();
		}
	}
}
