package com.flexcapacitor.managers
{
	import com.flexcapacitor.effects.core.CallMethod;
	import com.flexcapacitor.model.AttachmentData;
	import com.flexcapacitor.model.IDocumentData;
	import com.flexcapacitor.model.IProject;
	import com.flexcapacitor.model.ImageData;

	/**
	 * Saves at specific interval
	 **/
	public class AutoSaveManager {
		
		public function AutoSaveManager() {
			
		}
		
		private static var _enableAutoSave:Boolean;
		
		[Bindable]
		/**
		 * Auto save enabled
		 * */
		public static function get enableAutoSave():Boolean {
			return _enableAutoSave;
		}
		
		/**
		 * @private
		 */
		public static function set enableAutoSave(value:Boolean):void {
			_enableAutoSave = value;
			
			
			if (value) {
				if (!autoSaveEffect) {
					autoSaveEffect =  new CallMethod();
					autoSaveEffect.method = autoSaveHandler;
					autoSaveEffect.repeatCount = 0;
					autoSaveEffect.repeatDelay = autoSaveInterval;
				}
				if (!autoSaveEffect.isPlaying) {
					autoSaveEffect.play();
				}
			}
			else {
				autoSaveEffect.stop();
			}
		}
		
		/**
		 * Interval to check to save project. Default 2 minutes.
		 * */
		public static var autoSaveInterval:int = 120000;
		
		/**
		 * Effect to auto save
		 * */
		public static var autoSaveEffect:CallMethod;
		
		/**
		 * Handle auto saving 
		 * */
		public static function autoSaveHandler():void {
			var numberOfAssets:int;
			var numberOfProjects:int;
			var iProject:IProject;
			var iDocumentData:IDocumentData;
			var iAttachmentData:AttachmentData;
			var imageData:ImageData;
			var projects:Array = ProjectManager.projects;
			
			// save projects
			numberOfProjects = projects.length;
			
			for (var i:int;i<numberOfProjects;i++) {
				iDocumentData = projects[i] as IDocumentData;
				//if (iDocumentData.isChanged && !iDocumentData.saveInProgress && iDocumentData.isOpen) {
				if (!iDocumentData.saveInProgress && iDocumentData.isOpen) {
					iDocumentData.save();
				}
			}
		}
	}
}