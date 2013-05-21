
package com.flexcapacitor.controller {
	import com.flexcapacitor.tools.Selection;
	import com.flexcapacitor.tools.Zoom;
	import com.flexcapacitor.views.SelectionInspector;
	import com.flexcapacitor.views.ZoomInspector;
	
	/**
	 * Create references so classes are included. 
	 * */
	public class RadiateReferences {
		
		public function RadiateReferences()
		{
			
		}
		
		
		///////////////////////////////////////////////////////
		// CLASSES
		///////////////////////////////////////////////////////
		
		public static var selectionTool:com.flexcapacitor.tools.Selection;
		public static var selectionInspector:com.flexcapacitor.views.SelectionInspector;
		
		public static var zoomTool:com.flexcapacitor.tools.Zoom;
		public static var zoomInspector:com.flexcapacitor.views.ZoomInspector;
		
	}
}