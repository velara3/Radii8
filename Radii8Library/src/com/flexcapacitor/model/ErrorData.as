package com.flexcapacitor.model {
	
	/**
	 * Contains information on errors during compilation
	 * */
	public class ErrorData extends IssueData {
		
		public function ErrorData() {
			
		}
		
		public var errorID:String;
		public var message:String;
		public var name:String;
		
	}
}