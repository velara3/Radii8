package com.flexcapacitor.model
{
	/**
	 * Used to store a revision
	 * */
	public class DocumentRevision
	{
		public function DocumentRevision()
		{
		}
		
		public var name:String;
		public var date:String;
		public var code:String;
		
		public static function unmarshall(object:Object):DocumentRevision {
			var revision:DocumentRevision = new DocumentRevision();
			revision.name = object.name;
			revision.date = object.date;
			revision.code = object.code;
			
			return revision;
		}
	}
}