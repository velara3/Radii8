
package com.flexcapacitor.model {
	
	public interface ISettings {
	
		function set version(value:uint):void;
		function get version():uint;
		
		function unmarshall(data:Object):void;
	}
}