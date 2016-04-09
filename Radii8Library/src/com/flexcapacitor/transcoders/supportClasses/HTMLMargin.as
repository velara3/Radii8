package com.flexcapacitor.transcoders.supportClasses
{
	public class HTMLMargin
	{
		public function HTMLMargin(value:String, position:String = null, type:String = "")
		{
			if (value) {
				if (position==ALL || position==null) {
					right = top = bottom = left = value;
				}
			}
			
			if (type!=null || type!="") {
				this.type = type;
			}
		}
		
		public static const PIXELS:String = "px";
		public static const EM:String = "em";
		
		public static const ALL:String = "all";
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		public static const BOTTOM:String = "bottom";
		public static const TOP:String = "top";
		
		public var right:String;
		public var left:String;
		public var top:String;
		public var bottom:String;
		
		public var all:String;
		
		public var type:String;
	}
}