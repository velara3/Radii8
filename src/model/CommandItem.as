
package model {
	
	/**
	 * Contains information about a command
	 * */
	public class CommandItem {
		
		/**
		 * Constructor
		 * */
		public function CommandItem() {
			
		}
		
		/**
		 * Name of command
		 * */
		public var name:String;
		
		/**
		 * Command with markup instructions
		 * */
		public var code:String;
		
		/**
		 * Generated command script
		 * */
		public var content:String;
		
		/**
		 * ID
		 * */
		public var id:int;
		
		/**
		 * Is the item data is changed
		 * */
		[Transient]
		[Bindable]
		public var isChanged:Boolean;
		
		/**
		 * Decode data object into CommandItem
		 * */
		public function unmarshall(data:Object):void {
			
			name = data.name;
			code = data.code;
			content = data.content;
			id = data.id;
			
		}
	}
}