package com.flexcapacitor.utils
{
	import flash.events.Event;
	

	public class MXMLImporterEvent extends Event 
	{
		
		public static var INITIALIZE:String = "onInitialize";
		public var idString : String;

		public function MXMLImporterEvent(type : String, indata:String, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			super( type, bubbles, cancelable );
			idString = indata;
		}
	}	

}