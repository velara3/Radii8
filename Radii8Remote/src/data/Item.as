
package data {
	
	[Bindable]
	[RemoteClass]
	/**
	 * Describes the remote module to load
	 * */
	public class Item {
		
		public function Item(data:XML=null) {
			if (data) {
				unmarshall(data);
			}
		}
		
		public function unmarshall(value:XML):void {
			name 			= String(value.@name);
			url 			= String(value.@url);
			description 	= String(value.content);
			isDefault		= Boolean(value.isDefault);
		}
		
		/**
		 * Name of module
		 * */
		public var name:String;
		
		/**
		 * Description of module
		 * */
		public var description:String;
		
		/**
		 * URL to module swf
		 * */
		public var url:String;
		
		/**
		 * Type of module. Usually this is the fully qualified class name
		 * */
		public var type:Class;
		
		/**
		 * Enabled. May not be applicable when using perspectives. IE some perspectives 
		 * may have this enabled and others may not.
		 * */
		public var enabled:Boolean;
		
		/**
		 * Indicates if item is enabled by default 
		 */		
		public var isDefault:Boolean;
	}
}