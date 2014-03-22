
package com.flexcapacitor.model {
	
	public interface ISavedData {
		
		function set version(value:uint):void;
		function get version():uint;
		
		function unmarshall(data:Object):void;
	}
}