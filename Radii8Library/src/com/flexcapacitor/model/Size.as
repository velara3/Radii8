
package com.flexcapacitor.model {
	
	/**
	 * Base class for document sizes
	 * */
	public class Size {
		
		
		public function Size(width:String="0", height:String="0", ppi:int=0)
		{
			this.width = width;
			this.height = height;
			this.ppi = ppi;
		}
		
		/**
		 * 
		 * */
		public var name:String;
		
		/**
		 * Width can be percent
		 * */
		public var width:String;
		
		/**
		 * Height can be percent
		 * */
		public var height:String;
		
		/**
		 * Points per inch
		 * */
		public var ppi:int;
		
		/**
		 * Screen type
		 * */
		public var type:String;
		
	}
}