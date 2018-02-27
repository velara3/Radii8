package com.flexcapacitor.managers
{
	import flash.globalization.DateTimeStyle;
	
	import spark.formatters.DateTimeFormatter;

	public class DateManager
	{
		public function DateManager()
		{
		}
		
		/**
		 * Last save date formatted
		 * */
		[Bindable]
		public static var lastSaveDateFormatted:String;
		
		/**
		 * Last save date 
		 * */
		[Bindable]
		public static var lastSaveDate:Date;
		
		/**
		 * Last save date difference
		 * */
		[Bindable]
		public static var lastSaveDateDifference:String;
		
		/**
		 * Formatter for dates
		 * */
		public static var dateFormatter:DateTimeFormatter = new DateTimeFormatter();
		
		/**
		 * Sets the last save date 
		 * */
		public static function setLastSaveDate(date:Date = null):void {
			dateFormatter.dateStyle = DateTimeStyle.MEDIUM;
			var diff:int;
			if (!date) date = new Date();
			
			lastSaveDateFormatted = dateFormatter.format(date);
			
			lastSaveDate = date;
		}
		
		public static function updateLastSavedDifference(date:Date):void {
			var diff:int = (new Date().valueOf() - date.valueOf())/1000;
			
			if (diff>60) {
				lastSaveDateDifference = int(diff/60) + " min ago";
			}
			else {
				lastSaveDateDifference = "Less than a min ago";
			}
		}
	}
}