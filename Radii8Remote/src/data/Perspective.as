
package data {
	
	/**
	 * Layout of views and rules. 
	 * The items contains the list of views or child perspectives.
	 * Tab stops is the location of 
	 * */
	[Bindable]
	[RemoteClass]
	public class Perspective {
		
		public static const VERTICAL:String = "vertical";
		public static const HORIZONTAL:String = "horizontal";
		
		/**
		 * @constructor
		 * */
		public function Perspective()
		{
		}
		
		/**
		 * Name of perspective
		 * */
		public var name:String;
		
		/**
		 * Enabled
		 * */
		public var enabled:Boolean = true;
		
		/**
		 * horizontal or vertical
		 * */
		public var direction:String = VERTICAL;
		
		/**
		 * Items or perspectives
		 * */
		public var items:Array;
		
		/**
		 * List of column or row positions for each item.
		 * */
		public var tabStops:Array;
		
		/**
		 * Width in percent or number
		 * */
		public var width:Object;
		
		/**
		 * Height in percent or number
		 * */
		public var height:Object;
		
	}
}