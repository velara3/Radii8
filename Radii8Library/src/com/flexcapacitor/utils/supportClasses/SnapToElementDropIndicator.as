package com.flexcapacitor.utils.supportClasses {
	import flash.utils.getTimer;
	
	import mx.skins.ProgrammaticSkin;
	
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
		public var showFill:Boolean = true;
		public var borderColor:Number = 0x2DA7F0;
		public var fillColor:Number = 0x2DA7F0;
		public var fillAlpha:Number = .6;
		public var lineColor:Number = 0x2B333C;
		public var lineWeight:int = 1;
		
		public function setLines(x:Number, y:Number, rightEdge:Number = NaN, bottomEdge:Number = NaN):void {
			left = x;
			top = y;
			right = rightEdge;
			bottom = bottomEdge;
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
			
			if (!isNaN(left)) {
				graphics.beginFill(lineColor);
				graphics.drawRect(left, 0, lineWeight, unscaledHeight);
				graphics.endFill();
			}
			
			if (!isNaN(top)) {
				graphics.beginFill(lineColor);
				graphics.drawRect(0, top, unscaledWidth, lineWeight);
				graphics.endFill();
			}
			
			if (!isNaN(right)) {
				graphics.beginFill(lineColor);
				graphics.drawRect(right, 0, lineWeight, unscaledHeight);
				graphics.endFill();
			}
			
			if (!isNaN(bottom)) {
				graphics.beginFill(lineColor);
				graphics.drawRect(0, bottom, unscaledWidth, lineWeight);
				graphics.endFill();
			}
			
			if (showFill) {
				graphics.beginFill(fillColor, fillAlpha);
				graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
				graphics.endFill();
			}
			
		}
	}
}
