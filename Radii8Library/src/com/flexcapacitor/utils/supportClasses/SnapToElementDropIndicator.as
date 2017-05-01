package com.flexcapacitor.utils.supportClasses {
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	
	import mx.skins.ProgrammaticSkin;
	
	/**
	 * Shows a horizontal and vertical lines to indicate
	 * a drop location in a basic layout
	 * */
	public class SnapToElementDropIndicator extends ProgrammaticSkin {
		
		public function SnapToElementDropIndicator() {
			
		}
		
		public var horizontal:Number;
		public var vertical:Number;
		public var fillColor:Number = 0x2B333C;
		public var lineWeight:int = 1;
		
		public function setLines(x:Number, y:Number):void {
			horizontal = x;
			vertical = y;
		}
		
		/**
		 *  @private
		 */
		override protected function updateDisplayList(w:Number, h:Number):void {   
			super.updateDisplayList(w, h);
			
			graphics.clear();
			
			if (!isNaN(horizontal)) {
				graphics.beginFill(fillColor);
				graphics.drawRect(horizontal, 0, lineWeight, height);
				graphics.endFill();
			}
			
			if (!isNaN(vertical)) {
				graphics.beginFill(fillColor);
				graphics.drawRect(0, vertical, width, lineWeight);
				graphics.endFill();
			}
			
		}
	}
}
