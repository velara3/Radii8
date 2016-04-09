package com.flexcapacitor.transcoders.supportClasses
{
	
	public class HTMLLineBreak extends HTMLElement
	{
		public function HTMLLineBreak()
		{
			super();
		}
		
		override public function toString():String {
			return "<br >";
		}
	}
}