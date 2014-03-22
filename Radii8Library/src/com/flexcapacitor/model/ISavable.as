
package com.flexcapacitor.model {
	
	/**
	 * Defines methods needed for saving a project or document or asset. 
	 * */
	public interface ISavable {

		/**
		 * Method that saves the data locally or to the server. 
		 * */
		function save(locations:String = "", options:Object = null):Boolean;
	}
}