
package 
{
	import flash.display.Graphics;
	import flash.display.GraphicsPathCommand;
	import flash.events.MouseEvent;
	
	import spark.core.SpriteVisualElement;
	
	/**
	 * The Ruler class displays a ruler made of lines
	 * for each division and each subdivision.
	 * 
	 * The number of divisions and subdivisions can be set,
	 * the lines are drawn based on the strokeWeight and
	 * color property.
	 * 
	 * TODO: clean up code, optimize, test.
	 * 
	 * @author andy andreas hulstkamp
	 * @modified judah frangipane
	 */
	public class Ruler extends SpriteVisualElement
	{
		
		public static var HORIZONTAL:String = "horizontal";
		
		public static var VERTICAL:String = "vertical";

		/**
		 * Total amount of lines drawn including subdivisions
		 * You do not set this
		 * */
		public var lineCount:int;
		
		/**
		 * Commands to draw the lines 
		 */
		private var _commands:Vector.<int> = new Vector.<int>();
		
		/**
		 * Data to draw the lines 
		 */
		private var _data:Vector.<Number> = new Vector.<Number>();
		
		/**
		 * Index for drawing commands 
		 */
		private var _commandIndex:int = 0;
		
		/**
		 * Index for data commands 
		 */
		private var _dataIndex:int = 0;
		
		/**
		 * Number of divisions 
		 */
		private var _divisions:int = 23;
		
		/**
		 * Number of subdivisions 
		 */
		private var _subdivisions:int = 4;
		
		/**
		 * Ratio of line height, subdivisions to division 
		 */
		private var _subdivisionToDivisionLineHeightRatio:Number = .5;
		
		/**
		 * Distance between lines (not subdivisions)
		 */
		private var _divisionTickDistance:Number = 50;
		
		/**
		 * Weight of stroke 
		 */
		private var _strokeWeight:int = 1;
		
		/**
		 * Color of stroke 
		 */
		private var _color:uint = 0x808080;
		
		/**
		 * Color of background 
		 */
		public var backgroundColor:uint = 0xffffff;
		
		/**
		 * The direction of the ruler. Vertical or horizontal
		 * */
		private var _direction:String = Ruler.HORIZONTAL;
		
		/**
		 * The background color alpha
		 * */
		private var backgroundAlpha:Number = 1;

		/**
		 * The division of the last location clicked
		 * */
		public var localDivision:int = -1;
		
		
		//------------------------------------------------------------------
		//
		// Constructor
		//
		//------------------------------------------------------------------

		
		public function Ruler() {
			super();
			
			addEventListener(MouseEvent.CLICK, mouseClickHandler);
		}
		

		protected function mouseClickHandler(event:MouseEvent):void {
			if (direction==HORIZONTAL) {
				localDivision = event.localX / width * divisions + 1;
			}
			else if (direction==VERTICAL) {
				localDivision = event.localY / height * divisions + 1;
			}
			
			//dispatchEvent(event.clone());
		}
		
		//------------------------------------------------------------------
		//
		// Properties
		//
		//------------------------------------------------------------------
		
		[Inspectable(enumeration="horizontal,vertical")]
		public function get direction():String { return _direction; }
		
		/**
		 * Direction of the ruler
		 * */
		public function set direction(value:String):void
		{
			if (_direction == value) return;
			_direction = value;
			invalidateParentSizeAndDisplayList();
		}
		
		/**
		 * Distance between each line
		 * */
		public function get divisionLineDistance():Number
		{
			return _divisionTickDistance;
		}
		
		/**
		 * @private
		 */
		public function set divisionLineDistance(value:Number):void
		{
			if (_divisionTickDistance==value) return;
			_divisionTickDistance = value;
			invalidateParentSizeAndDisplayList();
		}
		
		/**
		 * Number of divisions 
		 */
		public function get divisions():int
		{
			return _divisions;
		}
		
		/**
		 * @private
		 */
		public function set divisions(value:int):void
		{
			_divisions = Math.max(1, value);
			invalidateParentSizeAndDisplayList();
		}
		
		/**
		 * Number of subdivision 
		 */
		public function get subdivisions():int
		{
			return _subdivisions;
		}
		
		public function set subdivisions(value:int):void
		{
			if (_subdivisions==Math.max(1, value)) return;
			_subdivisions = Math.max(1, value);
			invalidateParentSizeAndDisplayList();
		}
		
		/**
		 * Stroke color 
		 */
		public function get color():uint
		{
			return _color;
		}
		
		/**
		 * @private
		 */
		public function set color(value:uint):void
		{
			_color = value;
		}
		
		/**
		 * Stroke weights 
		 */
		public function get strokeWeight():int
		{
			return _strokeWeight;
		}
		
		/**
		 * @private
		 */
		public function set strokeWeight(value:int):void
		{
			if (_strokeWeight==value) return;
			_strokeWeight = value;
			invalidateParentSizeAndDisplayList();
		}
		
		/**
		 * Ratio of line height, subdivision to division 
		 */
		public function get subdivisionToDivisionLineRatio():Number
		{
			return _subdivisionToDivisionLineHeightRatio;
		}
		
		/**
		 * @private
		 */
		public function set subdivisionToDivisionLineRatio(value:Number):void
		{
			if (_subdivisionToDivisionLineHeightRatio==value) return;
			_subdivisionToDivisionLineHeightRatio = value;
			invalidateParentSizeAndDisplayList();
		}
		
		//------------------------------------------------------------------
		//
		// Drawing
		//
		//------------------------------------------------------------------
		
		/**
		 * Called during the validation pass by the Flex LayoutManager via
		 * the layout object.
		 * @param width
		 * @param height
		 * @param postLayoutTransform
		 * 
		 */
		override public function setLayoutBoundsSize(width:Number, height:Number, postLayoutTransform:Boolean=true):void 
		{
			super.setLayoutBoundsSize(width, height, postLayoutTransform);
			
			// update division count
			divisions = (direction==HORIZONTAL) ? width/divisionLineDistance : height/divisionLineDistance;
			
			// calculate how many total lines need to be drawn
			var measuredLineCount:int = (direction==HORIZONTAL) ? width / (divisionLineDistance / subdivisions) : height/(divisionLineDistance/subdivisions);
			
			// check if we are already showing that amount of lines
			if (measuredLineCount==lineCount) return;
			
			// set lines to new line count
			lineCount = measuredLineCount;
			
			//call our drawing function
			draw(width, height);
		}
		
		
		/**
		 * Draw the ruler 
		 * 
		 * TODO: logic to actually reuse commands and data if nothing has changed
		 * @param w width of ruler
		 * @param h height of ruler
		 * 
		 * */
		protected function draw(w:Number, h:Number):void {
			
			if (direction===Ruler.HORIZONTAL) {
				drawHorizontal(w, h);
			}
			else if (direction===Ruler.VERTICAL) {
				drawVertical(w, h);
			}
		}
		
		/**
		 * Draw the ruler 
		 * 
		 * TODO: logic to actually reuse commands and data if nothing has changed
		 * @param w width of ruler
		 * @param h height of ruler
		 * 
		 */
		protected function drawHorizontal(w:Number, h:Number):void {
			var g:Graphics = this.graphics;
			
			// reset indexes for drawing commands
			_commandIndex = 0;
			_dataIndex = 0;
			
			w = isNaN(w) ? this.width : w;
			h = (isNaN(h) ? this.height : h) - 1;
			
			// DivisionTickDistance
			//var divisionTickDistance:Number = w/(divisions);
			//divisionTickDistance;
			
			//divisions = w/divisionTickDistance;
			
			//height of subdivision line
			var subdivisionTicklineHeight:int = h * subdivisionToDivisionLineRatio;
			
			//subdivision line distance
			var subdivisionTickLineDistance:Number = divisionLineDistance/subdivisions;
			
			//x incrementing
			var tx:Number = 0;
			
			//current height of line to draw
			var lineHeight:int = h;
			
			var counter:int = 0;
			
			//var lines:int = (divisions) * subdivisions;
			//var lines:int = w / (divisionDistance / subdivisions);
			
			//the bottom line
			_commands[_commandIndex++] = GraphicsPathCommand.MOVE_TO;
			_data[_dataIndex++] = 0;
			_data[_dataIndex++] = h;
			
			_commands[_commandIndex++] = GraphicsPathCommand.LINE_TO;
			_data[_dataIndex++] = w;
			_data[_dataIndex++] = h;
			
			//prepare drawing commands for lines
			while (counter <= lineCount) {
				
				if (counter % subdivisions == 0) {
					lineHeight = 0;
				} else {
					lineHeight = subdivisionTicklineHeight;
				}
				
				//Tick
				_commands[_commandIndex++] = GraphicsPathCommand.MOVE_TO;
				_data[_dataIndex++] = tx;
				_data[_dataIndex++] = h;
				
				_commands[_commandIndex++] = GraphicsPathCommand.LINE_TO;
				_data[_dataIndex++] = tx;
				_data[_dataIndex++] = lineHeight;
				
				tx += subdivisionTickLineDistance;
				counter++;
			}
			
			//since we are reusing command and data vectors over multiple passses clear out unnecessary data from former pass
			if (_commandIndex != _commands.length - 1)
			{
				_commands.splice(_commandIndex, _commands.length - _commandIndex);
				_data.splice(_dataIndex, _data.length - _dataIndex);
			}
			
			//redraw
			g.clear();
			
			//draw background 
			//_gradientMatrix.createGradientBox(w, h, Math.PI/2);
			//g.beginGradientFill(GradientType.LINEAR, [backgroundColor, backgroundColor], [1, 1], [0, 255], _gradientMatrix);
			g.beginFill(backgroundColor, backgroundAlpha);
			g.drawRect(0, 0, w, h);
			g.endFill();
			//trace("HORIZONTAL "+ _commands.join(" "));
			
			//draw lines
			g.lineStyle(strokeWeight, color);
			g.drawPath(_commands, _data);
		}
		
		/**
		 * Draw the ruler 
		 * 
		 * TODO: logic to actually reuse commands and data if nothing has changed
		 * @param w width of ruler
		 * @param h height of ruler
		 * 
		 */
		protected function drawVertical(w:Number, h:Number):void 
		{
			var g:Graphics = this.graphics;
			
			//reset indexes for drawing commands
			_commandIndex = 0;
			_dataIndex = 0;
			
			w = (isNaN(w) ? this.width : w)  - 1;
			h = (isNaN(h) ? this.height : h);
			
			//DivisionTickDistance
			// var divisionTickDistance:Number = h/(divisions);
			divisionLineDistance;
			
			divisions = h/divisionLineDistance;
			
			// width of subdivision line
			var subdivisionLineWidth:int = w * subdivisionToDivisionLineRatio;
			
			// subdivision line distance
			var subdivisionLineDistance:Number = divisionLineDistance/subdivisions;
			
			//y inc
			var ty:Number = 0;
			
			//current width of line to draw
			var lineWidth:int = w;
			
			var counter:int;
			
			//var lines:int = (divisions) * subdivisions;
			//var lineCount:int = h / (divisionLineDistance / subdivisions);
			
			//the right edge line
			_commands[_commandIndex++] = GraphicsPathCommand.MOVE_TO;
			_data[_dataIndex++] = w;
			_data[_dataIndex++] = 0;
			
			_commands[_commandIndex++] = GraphicsPathCommand.LINE_TO;
			_data[_dataIndex++] = w;
			_data[_dataIndex++] = h;
			
			//prepare drawing commands for lines
			while (counter <= lineCount) {
				
				if (counter % subdivisions == 0) {
					lineWidth = 0;
				} else {
					lineWidth = subdivisionLineWidth;
				}
				
				//Tick
				_commands[_commandIndex++] = GraphicsPathCommand.MOVE_TO;
				_data[_dataIndex++] = w;
				_data[_dataIndex++] = ty;
				
				_commands[_commandIndex++] = GraphicsPathCommand.LINE_TO;
				_data[_dataIndex++] = lineWidth;
				_data[_dataIndex++] = ty;
				
				ty += subdivisionLineDistance;
				counter++;
			}
			
			//since we are reusing command and data vectors over multiple passses clear out unnecessary data from former pass
			if (_commandIndex != _commands.length - 1)
			{
				_commands.splice(_commandIndex, _commands.length - _commandIndex);
				_data.splice(_dataIndex, _data.length - _dataIndex);
			}
			
			//redraw
			g.clear();
			
			//draw background 
			//_gradientMatrix.createGradientBox(w, h, Math.PI/2);
			//g.beginGradientFill(GradientType.LINEAR, [backgroundColor, backgroundColor], [1, 1], [0, 255], _gradientMatrix);
			g.beginFill(backgroundColor, 1);
			g.drawRect(0, 0, w, h);
			g.endFill();
			
			//draw lines
			g.lineStyle(strokeWeight, color);
			g.drawPath(_commands, _data);
		}
	}
}

