
package com.flexcapacitor.views {
	
	/**
	 * Interface for dynamic inspectors
	 * */
	public interface IInspector {
		
		
		function activate(target:Object = null):void;
		
		function deactivate():void;
	}
}