package com.flexcapacitor.model {
	
	public class ConstrainedLocations {
		
		public function ConstrainedLocations() {
			
		}
		
		public static const VERTICAL_CENTER:String 		= "verticalCenter";
		public static const HORIZONTAL_CENTER:String 	= "horizontalCenter";
		public static const TOP:String 					= "top";
		public static const LEFT:String 				= "left";
		public static const RIGHT:String 				= "right";
		public static const BOTTOM:String 				= "bottom";
		public static const BASELINE:String 			= "baseline";
		
		public static const TOP_LEFT:String 			= "topLeft";
		public static const TOP_CENTER:String 			= "topCenter";
		public static const TOP_RIGHT:String 			= "topRight";
		public static const MIDDLE_LEFT:String 			= "middleLeft";
		public static const MIDDLE_CENTER:String 		= "middleCenter";
		public static const MIDDLE_RIGHT:String 		= "middleRight";
		public static const BOTTOM_LEFT:String 			= "bottomLeft";
		public static const BOTTOM_CENTER:String 		= "bottomCenter";
		public static const BOTTOM_RIGHT:String 		= "bottomRight";
		
		public static const CONSTRAINTS:Array 			= [TOP, LEFT, RIGHT, BOTTOM, BASELINE, VERTICAL_CENTER, HORIZONTAL_CENTER];
		public static const CONSTRAINTS_NO_BASELINE:Array = [TOP, LEFT, RIGHT, BOTTOM, VERTICAL_CENTER, HORIZONTAL_CENTER];
	}
}