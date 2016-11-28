package com.flexcapacitor.tools.supportClasses
{
	import com.roguedevelopment.HandleDescription;
	import com.roguedevelopment.IHandle;
	
	import flash.events.MouseEvent;
	
	import spark.core.SpriteVisualElement;
	
	/**
	 * A handle class based on SpriteVisualElement which is suitable for adding to
	 * a Flex 4 Group based container.
	 **/
	public class VisualElementRotationHandle extends SpriteVisualElement implements IHandle {
		
		public function VisualElementRotationHandle() {
			super();
			addEventListener( MouseEvent.ROLL_OUT, onRollOut );
			addEventListener( MouseEvent.ROLL_OVER, onRollOver );
			//redraw();
		}
		
		public static var handleWidth:Number = 7;
		public static var offset:Number = 2.5;
		public static var handleLineColor:Number = 0x3dff40;
		public static var handleFillColor:Number = 0xaaaaaa;
		public static var handleFillColorOver:Number = 0xc5ffc0;
		
		private var _descriptor:HandleDescription;		
		private var _targetModel:Object;
		protected var isOver:Boolean = false;
		
		public function get handleDescriptor():HandleDescription
		{
			return _descriptor;
		}
		public function set handleDescriptor(value:HandleDescription):void
		{
			_descriptor = value;
		}
		public function get targetModel():Object
		{
			return _targetModel;
		}
		public function set targetModel(value:Object):void
		{
			_targetModel = value;
		}
		
		protected function onRollOut( event : MouseEvent ) : void
		{
			isOver = false;
			redraw();
		}
		protected function onRollOver( event:MouseEvent):void
		{
			isOver = true;
			redraw();
		}
		
		public function redraw():void {
			offset = -Math.round((handleWidth*100)/2)/100;
			graphics.clear();
			
			if (isOver) {
				graphics.lineStyle(1, handleLineColor);
				graphics.beginFill(handleFillColorOver, 1);				
			}
			else {
				graphics.lineStyle(1, 0);
				graphics.beginFill(handleFillColor, 1);
			}
			
			graphics.drawEllipse(offset, offset, handleWidth, handleWidth);
			graphics.endFill();
			
		}
	}
}