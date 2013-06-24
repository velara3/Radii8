
package com.flexcapacitor.model {
	
	/**
	 * Contains information about a device screen size
	 * */
	public class Device extends Size {
		
		
		public function Device(width:String="0", height:String="0", dpi:int=0)
		{
			super(width, height, dpi);
		}
		
		
		public var resolutionHeight:int;
		
		public var resolutionWidth:int;
		
		public var usableWidthPortrait:int;

		public var usableHeightPortrait:int;
		
		public var usableWidthLandscape:int;
		
		public var usableHeightLandscape:int;
		
		public var platformID:String;
		
	}
}