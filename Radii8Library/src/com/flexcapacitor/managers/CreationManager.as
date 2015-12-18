

package com.flexcapacitor.managers {
	import com.flexcapacitor.tools.IToolInspector;
	import com.flexcapacitor.utils.ClassUtils;
	import com.flexcapacitor.views.IInspector;
	
	import mx.collections.ArrayList;

	/**
	 * Registers parts of Radiate. 
	 * The next time you launch will show you how far it got.
	 * 
	 * Usage: 
	 * CrashManager.showMeWhatsCreatedSoFar = true;
	 * CrashManager.showMeWhatsActivatedSoFar = true;
	 * 
	 * Put inside inspector creation complete event
	 * CrashManager.createdPanelInspector(this);
	 * 
	 * Put inside tool creation complete event
	 * CrashManager.createdToolInspector(this);
	 * 
	 * Put inside inspector activate event (radiate activate)
	 * CrashManager.registerPanelInspector(this);
	 * 
	 * Put inside tool activate event
	 * CrashManager.registerToolInspector(this);
	 * */
	public class CreationManager {
		
		public function CreationManager() {
			
		}
		
		public static var title:String = "Created: ";
		
		public static var showMeWhatsCreatedSoFar:Boolean;
		public static var showMeWhatsActivatedSoFar:Boolean;
		
		public static var toolInspectors:ArrayList = new ArrayList();
		public static var viewInspectors:ArrayList = new ArrayList();
		
		public static var createdToolInspectors:ArrayList = new ArrayList();
		public static var createdPanelInspectors:ArrayList = new ArrayList();
		
		public static function registerToolInspector(inspector:IToolInspector):void {
			toolInspectors.addItem(inspector);
			
			if (showMeWhatsActivatedSoFar) {
				output(ClassUtils.getQualifiedClassName(inspector));
			}
		}
		
		public static function registerInspector(inspector:IInspector):void {
			viewInspectors.addItem(inspector);
			
			if (showMeWhatsActivatedSoFar) {
				output(ClassUtils.getQualifiedClassName(inspector));
			}
		}
		
		public static function createdToolInspector(inspector:IToolInspector):void {
			createdToolInspectors.addItem(inspector);
			
			if (showMeWhatsCreatedSoFar) {
				output(ClassUtils.getQualifiedClassName(inspector));
			}
		}
		
		public static function createdPanelInspector(inspector:IInspector):void {
			createdPanelInspectors.addItem(inspector);
			
			if (showMeWhatsCreatedSoFar) {
				output(ClassUtils.getQualifiedClassName(inspector));
			}
		}
		
		public static function output(view:String):void {
			if (showMeWhatsCreatedSoFar) {
				trace(title + view);
			}
			
		}
		
		
	}
}