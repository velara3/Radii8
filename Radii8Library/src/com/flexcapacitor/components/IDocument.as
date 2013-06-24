
package com.flexcapacitor.components {
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	
	
	public interface IDocument {

		/**
		 * The root component description for this document.
		 * */
		function get componentDescription():ComponentDescription;
		
		/**
		 * @private
		 * */
		function set componentDescription(value:ComponentDescription):void 
	}
}