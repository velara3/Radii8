
package com.flexcapacitor.utils.supportClasses {
	
	public interface ISelectionGroup {
		
		
		function get showResizeHandles():Boolean;
		function set showResizeHandles(value:Boolean):void;
		
		function get showSelectionFill():Boolean;
		function set showSelectionFill(value:Boolean):void;
		
		function get showSelectionFillOnDocument():Boolean;
		function set showSelectionFillOnDocument(value:Boolean):void;
		
		function get showSelectionLabel():Boolean;
		function set showSelectionLabel(value:Boolean):void;
		
		function get showSelectionLabelOnDocument():Boolean;
		function set showSelectionLabelOnDocument(value:Boolean):void;
		
		function get selectionBorderColor():uint;
		function set selectionBorderColor(value:uint):void;
		
	}
}