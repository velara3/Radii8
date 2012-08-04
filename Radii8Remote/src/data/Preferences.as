
package data {
	
	[Bindable]
	[RemoteClass]
	public class Preferences {
		
		public function Preferences(data:XML=null) {
			if (data) {
				unmarshall(data);
			}
		}
		
		public function unmarshall(value:XML):void {
			name = String(value.@name);
			url = String(value.@url);
		}
		
		/**
		 * 
		 */		
		public var name:String;
		
		/**
		 * Location of views, tools and shortcut items XML 
		 **/		
		public var url:String;
		
		/**
		 * Not applicable
		 * */
		public var type:Class;
		
		/**
		 * Default perspective
		 * */		
		public var defaultPerspective:Perspective;
		
		/**
		 * Selected perspective
		 * */		
		public var selectedPerspective:Perspective;
		
		/**
		 * List of perspectives
		 */		
		public var perspectives:Array = [];
	}
}