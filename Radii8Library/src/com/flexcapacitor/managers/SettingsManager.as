package com.flexcapacitor.managers {
	
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.model.IDocumentData;
	import com.flexcapacitor.model.IProject;
	import com.flexcapacitor.model.SavedData;
	import com.flexcapacitor.model.Settings;
	import com.flexcapacitor.tools.Selection;
	import com.flexcapacitor.tools.Text;
	import com.flexcapacitor.utils.SharedObjectUtils;
	
	import flash.net.SharedObject;
	
	import mx.utils.ObjectUtil;

	/**
	 * Manages storing and restoring settings
	 **/
	public class SettingsManager {
		
		public function SettingsManager() {
			
		}
		
		public static var SETTINGS_DATA_NAME:String = "settingsData";
		public static var SAVED_DATA_NAME:String 	= "savedData";
		
		/**
		 * Settings 
		 * */
		public static var settings:Settings;
		
		/**
		 * Settings 
		 * */
		public static var savedData:SavedData;
		
		/**
		 * Creates the settings data
		 * */
		public static function createSettingsData():Boolean {
			var result:Object = SharedObjectUtils.getSharedObject(SETTINGS_DATA_NAME);
			var sharedObject:SharedObject;
			
			if (result is SharedObject) {
				sharedObject = SharedObject(result);
				
				if (sharedObject.data) {
					if (SETTINGS_DATA_NAME in sharedObject.data && sharedObject.data[SETTINGS_DATA_NAME]!=null) {
						settings = Settings(sharedObject.data[SETTINGS_DATA_NAME]);
					}
						// does not contain settings property
					else {
						settings = new Settings();
					}
				}
					// data is null
				else {
					settings = new Settings();
				}
			}
			else {
				Radiate.error("Could not get saved settings data. " + ObjectUtil.toString(result));
			}
			
			return true;
		}
		
		/**
		 * Creates the saved data
		 * */
		public static function createSavedData():Boolean {
			var result:Object = SharedObjectUtils.getSharedObject(SAVED_DATA_NAME);
			var sharedObject:SharedObject;
			
			if (result is SharedObject) {
				sharedObject = SharedObject(result);
				
				if (sharedObject.data) {
					if (SAVED_DATA_NAME in sharedObject.data && sharedObject.data[SAVED_DATA_NAME]!=null) {
						savedData = SavedData(sharedObject.data[SAVED_DATA_NAME]);
						//log.info("createSavedData:"+ObjectUtil.toString(savedData));
					}
						// does not contain property
					else {
						savedData = new SavedData();
					}
				}
					// data is null
				else {
					savedData = new SavedData();
				}
			}
			else {
				Radiate.error("Could not get saved data. " + ObjectUtil.toString(result));
			}
			
			return true;
		}
		
		/**
		 * Get saved data
		 * */
		public static function getSavedData():Object {
			var result:Object = SharedObjectUtils.getSharedObject(SAVED_DATA_NAME);
			var sharedObject:SharedObject;
			
			var data:SavedData;
			
			if (result is SharedObject) {
				sharedObject = SharedObject(result);
				
				if (sharedObject.data) {
					if (SAVED_DATA_NAME in sharedObject.data) {
						data = SavedData(sharedObject.data[SAVED_DATA_NAME]);
						
						//openLocalProjects(data);
					}
				}
			}
			else {
				Radiate.error("Could not get saved data. " + ObjectUtil.toString(result));
			}
			
			return result;
		}
		
		
		/**
		 * Get saved settings data
		 * */
		public static function getSettingsData():Boolean {
			var result:Object = SharedObjectUtils.getSharedObject(SETTINGS_DATA_NAME);
			var sharedOoject:SharedObject;
			
			if (result is SharedObject) {
				sharedOoject = SharedObject(result);
				
				if (sharedOoject.data) {
					if (SETTINGS_DATA_NAME in sharedOoject.data) {
						settings = Settings(sharedOoject.data[SETTINGS_DATA_NAME]);
					}
				}
			}
			else {
				Radiate.error("Could not get saved data. " + ObjectUtil.toString(result));
			}
			
			return result;
		}
		
		/**
		 * Removed saved data
		 * */
		public static function removeSavedData():Boolean {
			var result:Object = SharedObjectUtils.getSharedObject(SAVED_DATA_NAME);
			var sharedObject:SharedObject;
			
			if (result is SharedObject) {
				sharedObject = SharedObject(result);
				
				if (sharedObject.data) {
					if (SAVED_DATA_NAME in sharedObject.data) {
						sharedObject.clear();
						Radiate.log.info("Cleared saved data");
					}
				}
			}
			else {
				Radiate.error("Could not remove saved data. " + ObjectUtil.toString(result));
			}
			
			return result;
		}
		
		/**
		 * Removed saved settings
		 * */
		public static function removeSavedSettings():Boolean {
			var result:Object = SharedObjectUtils.getSharedObject(SETTINGS_DATA_NAME);
			var sharedObject:SharedObject;
			
			if (result is SharedObject) {
				sharedObject = SharedObject(result);
				
				if (sharedObject.data) {
					if (SETTINGS_DATA_NAME in sharedObject.data) {
						sharedObject.clear(); // this clears the whole thing
						Radiate.log.info("Cleared settings data");
					}
				}
			}
			else {
				Radiate.error("Could not remove settings data. " + ObjectUtil.toString(result));
			}
			
			return result;
		}
		
		
		/**
		 * Save settings data
		 * */
		public static function saveSettings():Boolean {
			var result:Object = SharedObjectUtils.getSharedObject(SETTINGS_DATA_NAME);
			var sharedObject:SharedObject;
			
			if (result is SharedObject) {
				updateSettingsBeforeSave();
				sharedObject = SharedObject(result);
				sharedObject.setProperty(SETTINGS_DATA_NAME, settings);
				sharedObject.flush();
				
				//log.info("Saved Serrinfo: "+ ObjectUtil.toString(so.data));
			}
			else {
				Radiate.error("Could not save data. " + ObjectUtil.toString(result));
				return false;
			}
			
			return true;
		}
		
		/**
		 * Get setting
		 * */
		public static function getSetting(name:String):Object {
			var result:Object = SharedObjectUtils.getSharedObject(SETTINGS_DATA_NAME);
			var sharedObject:SharedObject;
			
			if (result is SharedObject) {
				sharedObject = SharedObject(result);
				
				if (sharedObject.data) {
					if (SETTINGS_DATA_NAME in sharedObject.data) {
						settings = Settings(sharedObject.data[SETTINGS_DATA_NAME]);
						if (name in settings) {
							return settings[name];
						}
					}
				}
				
				//log.info("Saved Serrinfo: "+ ObjectUtil.toString(so.data));
			}
			else {
				Radiate.error("Could not get setting \"" + name + "\"");
			}
			
			return null;
		}
		
		/**
		 * Save setting. Name must already exist on Settings class
		 * */
		public static function saveSetting(name:String, value:Object):void {
			
			if (settings==null) {
				getSettingsData();
			}
			
			if (name in settings) {
				settings[name] = value;
				saveSettings();
			}
			else {
				Radiate.error("Could not save setting \"" + name + "\"");
			}
		}
		
		/**
		 * Apply the settings
		 * TODO refactor
		 * */
		public static function applySettings():Settings {
			var radiate:Radiate = Radiate.instance;
			
			if (settings==null) {
				getSettingsData();
			}
			
			AutoSaveManager.enableAutoSave = settings.enableAutoSave;
			
			//enableWordWrap = settings.enableWordWrap;
			//embedImages = settings.embedImages;
			Radiate.startInDesignView = settings.startInDesignView;
			Selection.instance.showSelectionLabel = settings.showSelectionLabel;
			Selection.instance.snapToNearbyElements = settings.snapToNearbyElements;
			
			Text.showTextEditorInCallOut = settings.useCallOutForEditing;
			
			return settings;
		}
		
		/**
		 * Get the latest settings and copy them into the settings object
		 * */
		public static function updateSettingsBeforeSave():Settings {
			// get selected document
			// get selected project
			// get open projects
			// get open documents
			// get all documents
			// get all projects
			// save workspace settings
			// save preferences settings
			
			settings.lastOpened 	= new Date().time;
			//settings.modified 		= new Date().time;
			
			//settings.openDocuments 		= getOpenDocumentsSaveData(true);
			//settings.openProjects 		= getOpenProjectsSaveData(true);
			
			//settings.selectedProject 	= instance.selectedProject ? instance.selectedProject.toMetaData() : null;
			//settings.selectedDocument 	= instance.selectedDocument ? instance.selectedDocument.toMetaData() : null;
			
			settings.enableAutoSave = AutoSaveManager.enableAutoSave;
			
			settings.saveCount++;
			
			return settings;
		}
		
		/**
		 * Get the latest project and document data.
		 * */
		public static function updateSavedDataBeforeSave():SavedData {
			// get selected document
			// get selected project
			// get open projects
			// get open documents
			// get all documents
			// get all projects
			// save workspace settings
			// save preferences settings
			
			
			savedData.modified 		= new Date().time;
			//settings.modified 	= new Date().time;
			savedData.documents 	= getSaveDataForAllDocuments();
			savedData.projects 		= getSaveDataForAllProjects();
			savedData.saveCount++;
			//savedData.resources 	= getResources();
			
			return savedData;
		}
		
		/**
		 * Save data
		 * */
		public static function saveDataLocally():Boolean {
			var result:Object = SharedObjectUtils.getSharedObject(SAVED_DATA_NAME);
			var so:SharedObject;
			
			if (result is SharedObject) {
				updateSavedDataBeforeSave();
				so = SharedObject(result);
				so.setProperty(SAVED_DATA_NAME, savedData);
				
				try {
					so.flush();
				}
				catch (errorEvent:Error) {
					Radiate.error(errorEvent.message);
					return false;
				}
				
			}
			else {
				Radiate.error("Could not save data. " + ObjectUtil.toString(result));
				return false;
			}
			
			return true;
		}
		
		/**
		 * Save document locally
		 * */
		public static function saveDocumentLocally(document:IDocumentData):Boolean {
			var radiate:Radiate = Radiate.instance;
			var result:Object = SharedObjectUtils.getSharedObject(SAVED_DATA_NAME);
			var so:SharedObject;
			
			if (result is SharedObject) {
				DocumentManager.updateSaveDataForDocument(document);
				so = SharedObject(result);
				so.setProperty(SAVED_DATA_NAME, savedData);
				so.flush();
				//log.info("Saved Data: " + ObjectUtil.toString(so.data));
			}
			else {
				Radiate.error("Could not save data. " + ObjectUtil.toString(result));
				//return false;
			}
			
			return true;
		}
		
		
		/**
		 * Get a list of all documents data for storage. If open is set to 
		 * true then only returns open documents.
		 * */
		public static function getSaveDataForAllDocuments(open:Boolean = false, metaData:Boolean = false):Array {
			var projects:Array = ProjectManager.projects;
			var numberOfProjects:int = projects.length;
			var documentsArray:Array = [];
			var iProject:IProject;
			
			for (var i:int;i<numberOfProjects;i++) {
				iProject = projects[i];
				documentsArray = documentsArray.concat(iProject.getSavableDocumentsData(open, metaData));
			}
			
			return documentsArray;
		}
		
		/**
		 * Get an array of projects serialized for storage. 
		 * If open is set to true then only returns open projects.
		 * If meta data is true then only returns meta data. 
		 * */
		public static function getSaveDataForAllProjects(open:Boolean = false, metaData:Boolean = false):Array {
			var projectsArray:Array = [];
			var projects:Array = ProjectManager.projects;
			var numberOfProjects:int = projects.length;
			var iProject:IProject;
			
			for (var i:int; i < numberOfProjects; i++) {
				iProject = IProject(projects[i]);
				
				if (open) {
					if (iProject.isOpen) {
						if (metaData) {
							projectsArray.push(iProject.toMetaData());
						}
						else {
							projectsArray.push(iProject.marshall());
						}
					}
				}
				else {
					if (metaData) {
						projectsArray.push(iProject.toMetaData());
					}
					else {
						projectsArray.push(iProject.marshall());
					}
				}
			}
			
			return projectsArray;
		}
		
		/**
		 * Save project locally
		 * */
		public static function saveProjectLocally(project:IProject, saveProjectDocuments:Boolean = true):Boolean {
			var result:Object = SharedObjectUtils.getSharedObject(SAVED_DATA_NAME);
			var so:SharedObject;
			
			if (result is SharedObject) {
				// todo - implement saveProjectDocuments
				ProjectManager.updateSaveDataForProject(project);
				
				so = SharedObject(result);
				so.setProperty(SAVED_DATA_NAME, savedData);
				so.flush();
				//log.info("Saved Data: " + ObjectUtil.toString(so.data));
			}
			else {
				Radiate.error("Could not save data. " + ObjectUtil.toString(result));
			}
			
			return true;
		}
	}
}