package com.flexcapacitor.managers
{
	import com.flexcapacitor.controller.Console;
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.controller.RadiateUtilities;
	import com.flexcapacitor.model.DocumentData;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IDocumentData;
	import com.flexcapacitor.model.IDocumentMetaData;
	import com.flexcapacitor.model.IProject;
	import com.flexcapacitor.model.IProjectData;
	import com.flexcapacitor.model.ISavable;
	import com.flexcapacitor.model.Project;
	import com.flexcapacitor.model.SaveResultsEvent;
	import com.flexcapacitor.model.SavedData;
	import com.flexcapacitor.model.Settings;
	import com.flexcapacitor.services.IServiceEvent;
	import com.flexcapacitor.services.WPService;
	import com.flexcapacitor.utils.XMLUtils;
	import com.flexcapacitor.views.MainView;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.Dictionary;
	
	import mx.utils.UIDUtil;
	
	import spark.collections.Sort;
	import spark.collections.SortField;

	/**
	 * Manages projects
	 **/
	public class ProjectManager extends Console {
		
		public function ProjectManager(s:SINGLEDOUBLE) {
			
		}
		
		/**
		 * Service to get list of projects
		 * */
		public static var getProjectsService:WPService;
		
		/**
		 * Service to delete project
		 * */
		public static var deleteProjectService:WPService;
		
		/**
		 * Set to true when project is being saved to the server
		 * */
		[Bindable]
		public static var saveProjectInProgress:Boolean;
		
		/**
		 * Set to true when deleting a project
		 * */
		[Bindable]
		public static var deleteProjectInProgress:Boolean;
		
		/**
		 * Set to true when getting list of projects
		 * */
		[Bindable]
		public static var getProjectsInProgress:Boolean;
		
		/**
		 * Reference to the projects belongs to
		 * */
		public static var projectsDictionary:Dictionary = new Dictionary(true);
		
		/**
		 *  @private
		 *  Storage for the projects property.
		 */
		private static var _projects:Array = [];
		
		/**
		 * Selected projects
		 * */
		public static function get projects():Array {
			return _projects;
		}
		
		/**
		 * Selected projects
		 *  @private
		 * */
		[Bindable]
		public static function set projects(value:Array):void {
			_projects = value;
			
		}
		
		/**
		 * Get the current document.
		 * */
		public static function get selectedDocument():IDocument {
			return Radiate.selectedDocument;
		}
		
		/**
		 * Get the current project.
		 * */
		public static function get selectedProject():IProject {
			return Radiate.selectedProject;
		}
		
		/**
		 * Check if the project has changed and mark changed if it is. 
		 * */
		public static function checkIfProjectHasChanged(iProject:IProject):Boolean {
			
			var isChanged:Boolean = iProject.checkProjectHasChanged();
			
			return isChanged;
		}
		
		/**
		 * Get a list of projects that are open. 
		 * If meta data is true only returns meta data. 
		 * */
		public static function getOpenProjectsSaveData(metaData:Boolean = false):Array {
			var projectsArray:Array = SettingsManager.getSaveDataForAllProjects(true, metaData);
			
			return projectsArray;
		}
		
		/**
		 * Get an array of projects serialized for storage. 
		 * If open is set to true then only returns open projects.
		 * If meta data is true then only returns meta data. 
		 * */
		public static function saveProjectsRemotely(open:Boolean = false):Array {
			var projectsArray:Array = [];
			var numberOfProjects:int = projects.length;
			var iProject:IProject;
			
			for (var i:int; i < numberOfProjects; i++) {
				iProject = IProject(projects[i]);
				
				if (open) {
					if (iProject.isOpen) {
						iProject.save();
					}
				}
				else {
					iProject.save();
				}
			}
			
			
			return projectsArray;
		}
		
		/**
		 * Updates the saved data with the changes from the project passed in
		 * */
		public static function updateSaveDataForProject(iProject:IProject, metaData:Boolean = false):SavedData {
			var savedData:SavedData = SettingsManager.savedData;
			var projectsArray:Array = savedData.projects;
			var numberOfProjects:int = projectsArray.length;
			var documentMetaData:IDocumentMetaData;
			var found:Boolean;
			var foundIndex:int = -1;
			
			for (var i:int;i<numberOfProjects;i++) {
				documentMetaData = IDocumentData(projectsArray[i]);
				//Radiate.info("Exporting document " + iDocument.name);
				
				if (documentMetaData.uid == iProject.uid) {
					found = true;
					foundIndex = i;
				}
			}
			
			if (found) {
				
				if (metaData) {
					projectsArray[foundIndex] = iProject.toMetaData();
				}
				else {
					projectsArray[foundIndex] = iProject.marshall();
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
			
			
			return savedData;
		}
		
		/**
		 * Save all projects and documents locally and remotely.
		 * Eventually, we will want to create a file options class that
		 * contains information on saving locally, to file, remotely, etc
		 * NOT FINISHED
		 * */
		public static function save(locations:String = null, options:Object = null):void {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var local:Boolean = ServicesManager.getIsLocalLocation(locations);
			var remote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var localResult:Boolean;
			
			if (local) {
				local = saveProject(selectedProject, DocumentData.LOCAL_LOCATION);
			}
			
			if (remote) {
				if (remote && selectedProject is ISavable) {
					saveProjectInProgress = true
					
					if (selectedProject is Project) {
						Project(selectedProject).addEventListener(SaveResultsEvent.SAVE_RESULTS, projectSaveResults, false, 0, true);
					}
					
					ISavable(selectedProject).save(DocumentData.REMOTE_LOCATION, options);
				}
			}
			
			if (local) {
				// saved local successful
				if (localResult) {
					
				}
				else {
					// unsuccessful
				}
			}
			
			
			if (remote) {
				if (remote) {
					
				}
				else {
					
				}
			}
			
		}
		
		/**
		 * Save all projects
		 * */
		public static function saveAllProjects(locations:String = null, saveEvenIfClean:Boolean = true):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var loadLocally:Boolean = ServicesManager.getIsLocalLocation(locations);
			var loadRemote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var numberOfProjects:int = projects ? projects.length : 0;
			var project:IProject;
			var anyProjectSaved:Boolean;
			
			if (numberOfProjects==0) {
				warn("No projects to save");
				return false;
			}
			
			for (var i:int;i<numberOfProjects;i++) {
				project = projects[i];
				
				if (project.isChanged || saveEvenIfClean) {
					project.save(locations);
				}
				else {
					project.save(locations);
				}
				
				anyProjectSaved = true;
			}
			
			return anyProjectSaved;
		}
		
		/**
		 * Save example projects usually called after login
		 * */
		public static function saveExampleProject(projectData:IProject, locations:String = null):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var saveLocally:Boolean = ServicesManager.getIsLocalLocation(locations);
			var saveRemote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			
			var numberOfDocuments:int;
			var documentData:IDocumentData;
			var url:String = Radiate.getWPURL();
			var exampleDocuments:Array;
			
			projectData.host = url;
			
			if (projectData.uid=="null" || projectData.uid=="" || projectData.uid==null) {
				projectData.uid = projectData.createUID();
				projectData.name += " Copy";
			}
			
			exampleDocuments = IProjectData(projectData).documents;
			numberOfDocuments = exampleDocuments ? exampleDocuments.length : 0;
			j=0;
			
			for (var j:int; j < numberOfDocuments; j++) {
				documentData = IDocumentData(exampleDocuments[j]);
				
				if (documentData) {
					documentData.host = url;
					
					if (documentData.uid=="null" || documentData.uid=="" || documentData.uid==null) {
						documentData.uid = documentData.createUID();
						documentData.name += " Copy";
					}
				}
			}
			
			projectData.save(locations);
			
			return true;
		}
		
		/**
		 * Save example projects usually called after login
		 * */
		public static function saveExampleProjects(locations:String = null):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var saveLocally:Boolean = ServicesManager.getIsLocalLocation(locations);
			var saveRemote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			
			var numberOfProjects:int = projects ? projects.length : 0;
			var numberOfDocuments:int;
			var documentData:IDocumentData;
			var projectData:IProjectData;
			var url:String = Radiate.getWPURL();
			var documents:Array;
			
			for (var i:int; i < numberOfProjects; i++) {
				projectData = IProjectData(projects[i]);
				
				if (IProject(projectData).isExample) {
					projectData.host = url;
					
					if (projectData.uid=="null" || projectData.uid==null) {
						projectData.uid = projectData.createUID();
						projectData.name += " Copy";
					}
					
					documents = IProjectData(projectData).documents;
					numberOfDocuments = documents ? documents.length : 0;
					j=0;
					
					for (var j:int; j < numberOfDocuments; j++) {
						documentData = IDocumentData(documents[j]);
						
						if (documentData) {
							documentData.host = url;
							
							if (documentData.uid=="null" || documentData.uid==null || documentData.uid=="") {
								documentData.uid = documentData.createUID();
								documentData.name += " Copy";
							}
						}
					}
					
					projectData.save();
				}
			}
			
			return true;
		}
		
		/**
		 * Removes ID and location data from example projects so that the user can 
		 * save and modify them themselves
		 * */
		public static function clearExampleProjectData(exampleProject:IProject):Boolean {
			if (!exampleProject) return false;
			var exampleDocuments:Array;
			var numberOfDocuments:int;
			var exampleDocument:IDocument;
			
			DocumentManager.removeUniqueDocumentData(exampleProject);
			exampleDocuments = exampleProject.documents;
			numberOfDocuments = exampleDocuments ? exampleDocuments.length :0;
			
			for (var i:int;i<numberOfDocuments;i++) {
				exampleDocument = exampleDocuments[i] as IDocument;
				
				if (exampleDocument) {
					DocumentManager.removeUniqueDocumentData(exampleDocument);
					exampleDocument.uid = UIDUtil.createUID();
					exampleDocument.isExample = true;
				}
			}
			
			exampleProject.isExample = true;
			
			return true;
		}
		
		/**
		 * Save project
		 * */
		public static function saveProject(project:IProject, locations:String = null, options:Object = null):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var local:Boolean = ServicesManager.getIsLocalLocation(locations);
			var remote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var locallySaved:Boolean;
			
			if (project==null) {
				error("No project to save");
				return false;
			}
			
			//if (isUserLoggedIn && isUserConnected) {
			
			if (!ProfileManager.isUserLoggedIn) {
				error("You must be logged in to save a project.");
				return false;
			}
			
			
			if (project is EventDispatcher && remote) {
				EventDispatcher(project).addEventListener(SaveResultsEvent.SAVE_RESULTS, projectSaveResults, false, 0, true);
				//EventDispatcher(project).addEventListener(Project.PROJECT_SAVED, projectSaveResults, false, 0, true);
			}
			
			if (!local) {
				saveProjectInProgress = true;
			}
			
			project.save(locations, options);
			
			if (local) {
				// TODO add support to save after response from server 
				// because ID's may have been added from new documents
				// UPDATE not saving locally bc it is not managed yet (no delete)
				//locallySaved = saveProjectLocally(project);
				//project.saveCompleteCallback = saveData;
			}
			
			return true;
		}
		
		/**
		 * Project saved handler
		 * */
		public static function projectSaveResults(event:IServiceEvent):void {
			var project:IProject = IProject(Event(event).currentTarget);
			
			saveProjectInProgress = false;
			
			if (project is EventDispatcher) {
				EventDispatcher(project).removeEventListener(SaveResultsEvent.SAVE_RESULTS, projectSaveResults);
			}
			
			if (event is SaveResultsEvent && SaveResultsEvent(event).successful) {
				DateManager.setLastSaveDate();
			}
			
			Radiate.dispatchProjectSavedEvent(IProject(Event(event).currentTarget));
		}
		
		/**
		 * Save project only. Save project saves the project and all documents
		 * while save project only saves only the project.
		 * */
		public static function saveProjectOnly(project:IProject, locations:String = null, options:Object = null):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var local:Boolean = ServicesManager.getIsLocalLocation(locations);
			var remote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var locallySaved:Boolean;
			
			if (project==null) {
				error("No project to save");
				return false;
			}
			
			
			if (!ProfileManager.isUserLoggedIn) {
				error("You must be logged in to save a project.");
				return false;
			}
			
			
			if (project is EventDispatcher && remote) {
				EventDispatcher(project).addEventListener(SaveResultsEvent.SAVE_RESULTS, projectSaveResults, false, 0, true);
			}
			
			saveProjectInProgress = false;
			project.saveOnlyProject(locations, options);
			
			if (local) { 
				// TODO add support to save after response from server 
				// because ID's may have been added from new documents
				locallySaved = SettingsManager.saveProjectLocally(project);
				//project.saveCompleteCallback = saveData;
			}
			
			return true;
		}
		
		
		/**
		 * Open previously opened projects
		 * */
		public static function openPreviouslyOpenProjects(locations:String = null):void {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var settings:Settings = SettingsManager.settings;
			var openProjects:Array = settings.openProjects;
			var iProject:IProject;
			var iProjectData:IProjectData;
			var numberOfOpenItems:int = openProjects.length;
			
			// open previously opened projects
			for (var i:int;i<numberOfOpenItems;i++) {
				iProjectData = IProjectData(openProjects[i]);
				iProject = getProjectByUID(iProjectData.uid);
				
				if (iProject) {
					info("Opening project " + iProject.name);
					openProject(iProject, locations, true);
				}
			}
		}
		
		/**
		 * Show previously opened project
		 * */
		public static function showPreviouslyOpenProject():void {
			var settings:Settings = SettingsManager.settings;
			var iProject:IProject;
			
			// Select last selected project
			if (settings.selectedProject) {
				iProject = getProjectByUID(settings.selectedProject.uid);
				
				if (iProject && iProject.isOpen) {
					info("Opening selected project " + iProject.name);
					Radiate.setProject(iProject);
				}
			}
			else {
				if (selectedProject==null && projects && projects.length>0) {
					Radiate.setProject(projects[0]);
				}
			}
		}
		/**
		 * Delete project results handler
		 * */
		public static function deleteProjectResultsHandler(event:IServiceEvent):void {
			//Radiate.info("Delete project results");
			var data:Object = event.data;
			var status:Boolean;
			var successful:Boolean;
			var error:String;
			var message:String;
			
			if (data && data is Object) {
				//status = data.status==true;
			}
			
			deleteProjectInProgress = false;
			
			if (data && data is Object && "status" in data) {
				
				successful = data.status!="error";
			}
			
			//Include 'id' or 'slug' var in your request.
			if (event.faultEvent is IOErrorEvent) {
				message = "Are you connected to the internet? ";
				
				if (event.faultEvent is IOErrorEvent) {
					message = IOErrorEvent(event.faultEvent).text;
				}
				else if (event.faultEvent is SecurityErrorEvent) {
					
					if (SecurityErrorEvent(event.faultEvent).errorID==2048) {
						
					}
					
					message += SecurityErrorEvent(event.faultEvent).text;
				}
			}
			
			
			//dispatchProjectRemovedEvent(null);
			
			Radiate.dispatchProjectDeletedEvent(successful, data);
		}
		
		/**
		 * Result from delete project fault
		 * */
		public static function deleteProjectFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.info("Could not connect to the server to delete the project. ");
			
			deleteProjectInProgress = false;
			
			Radiate.dispatchProjectDeletedEvent(false, data);
		}
		
		/**
		 * Results from call to get projects
		 * */
		public static function getProjectsResultsHandler(event:IServiceEvent):void {
			
			//Radiate.info("Retrieved list of projects");
			
			var data:Object = event.data;
			
			getProjectsInProgress = false;
			
			Radiate.dispatchGetProjectsListResultsEvent(data);
		}
		
		/**
		 * Open list of projects. Need to eventually convert from wordpress post data object to type classes.
		 * See getAttachmentsResultsHandler() 
		 * */
		public static function openProjectsFromData(projectsData:Array):void {
			var numberOfProjects:int;
			var post:Object;
			var project:IProject
			var xml:XML;
			var isValid:Boolean;
			var firstProject:IProject;
			var potentialProjects:Array;
			
			numberOfProjects = projectsData.count;
			
			for (var i:int;i<numberOfProjects;i++) {
				post = potentialProjects.posts[i];
				isValid = XMLUtils.isValidXML(post.content);
				
				if (isValid) {
					xml = new XML(post.content);
					project = createProjectFromXML(xml);
					addProject(project);
					potentialProjects.push(project);
				}
				else {
					info("Could not import project:" + post.title);
				}
			}
			
			
			//potentialProjects = addSavedProjects(data.projects);
			
			if (potentialProjects.length>0) {
				openProject(potentialProjects[0]);
				Radiate.setProject(potentialProjects[0]);
			}
		}
		
		/**
		 * Result from save fault
		 * */
		public static function getProjectsFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			Radiate.info("Could not get list of projects");
			
			getProjectsInProgress = false;
			
			Radiate.dispatchGetProjectsListResultsEvent(data);
		}
		
		/**
		 * Create new project. 
		 * */
		public static function createNewProject(name:String = null, type:Object = null, project:IProject = null):void {
			var newProject:IProject;
			
			newProject = createProject(); // create project
			addProject(newProject);       // add to projects array - shows up in application
			
			openProject(newProject); // should open documents - maybe we should do all previous steps in this function???
			
			Radiate.setProject(newProject); // selects project 
			
		}
		
		/**
		 * Create projects from array of type IProjectData
		 * */
		public static function createAndAddProjectsData(projectsData:Array, add:Boolean = true):Array {
			var iProjectData:IProjectData;
			var potentialProjects:Array = [];
			var numberOfProjects:int;
			var iProject:IProject;
			
			// get projects and add them to the projects array
			if (projectsData && projectsData.length>0) {
				numberOfProjects = projectsData.length;
				
				for (var i:int;i<numberOfProjects;i++) {
					iProjectData = IProjectData(projectsData[i]);
					
					// project doesn't exist - add it
					if (getProjectByUID(iProjectData.uid)==null) {
						iProject = createProjectFromData(iProjectData);
						potentialProjects.push(iProject);
						
						if (add) {
							addProject(iProject);
						}
					}
					else {
						info("Project " + iProjectData.name + " is already open.");
					}
					
				}
			}
			
			return potentialProjects;
		}
		
		/**
		 * Check if project exists in projects array. Pass in the UID not ID.
		 * */
		public static function doesProjectExist(uid:String):Boolean {
			var numberOfProjects:int = projects.length;
			var iProject:IProject;
			
			for (var i:int;i<numberOfProjects;i++) {
				iProject = IProject(projects[i]);
				
				if (iProject.uid==uid) {
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Get project by UID
		 * */
		public static function getProjectByUID(id:String):IProject {
			var numberOfProjects:int = projects.length;
			var iProject:IProject;
			
			for (var i:int;i<numberOfProjects;i++) {
				iProject = IProject(projects[i]);
				
				if (id==iProject.uid) {
					return iProject;
				}
			}
			
			return null;
		}
		
		/**
		 * Get project by ID
		 * */
		public static function getProjectByID(id:int):IProject {
			var numberOfProjects:int = projects.length;
			var iProject:IProject;
			
			for (var i:int;i<numberOfProjects;i++) {
				iProject = IProject(projects[i]);
				
				if (iProject.id!=null && id==int(iProject.id)) {
					return iProject;
				}
			}
			
			return null;
		}
		
		/**
		 * Restores projects and documents from local store
		 * Add all saved projects to projects array
		 * Add all saved documents to documents array
		 * Add documents to projects
		 * Open previously open projects
		 * Open previously open documents
		 * Select previously selected project
		 * Select previously selected document
		 * */
		public static function openLocalProjects(data:SavedData):void {
			var projectsDataArray:Array;
			var potentialProjects:Array  = [];
			var potentialDocuments:Array = [];
			var savedDocumentsDataArray:Array;
			var numberOfPotentialProjects:int;
			var iProject:IProject;
			
			// get list of projects and list of documents
			if (data) {
				
				// get projects and add them to the projects array
				projectsDataArray = data.projects;
				potentialProjects = createAndAddProjectsData(data.projects);
				
				// get documents and add them to the documents array
				// TRYING TO NOT create documents until they are needed
				// but then we have issues when we want to save or export
				DocumentManager.createAndAddDocumentsData(data.documents);
				//savedDocumentsDataArray = data.documents; // should be potential documents?
				
				
				// go through projects and add documents to them
				if (potentialProjects.length>0) {
					numberOfPotentialProjects = potentialProjects.length;
					
					// loop through potentialProjectsLength objects
					for (var i:int;i<length;i++) {
						iProject = IProject(potentialProjects[i]);
						
						iProject.importDocumentInstances(DocumentManager.documents);
					}
				}
				
				
				openPreviouslyOpenProjects();
				DocumentManager.openPreviouslyOpenDocuments();
				showPreviouslyOpenProject();
				DocumentManager.showPreviouslyOpenDocument();
				
			}
			else {
				// no saved data
				info("No saved data to restore");
			}
			
		}
		
		/**
		 * Parses data into an array of usable objects 
		 * Should be in a ServicesManager class?
		 * */
		public static function parseProjectsData(data:Object):Array {
			var dataLength:int;
			var post:Object;
			var project:IProject
			var xml:XML;
			var isValid:Boolean;
			var firstProject:IProject;
			var potentialProjects:Array = [];
			var source:String;
			
			dataLength = data && data is Object ? data.count : 0;
			
			for (var i:int;i<dataLength;i++) {
				post = data.posts[i];
				//isValid = XMLUtils.isValidXML(post.content);
				source = post.custom_fields.source;
				isValid = XMLUtils.isValidXML(source);
				
				if (isValid) {
					xml = new XML(source);
					// should have an unmarshall from data method
					project = createProjectFromXML(xml);
					
					// maybe we should keep an array of the projects we just loaded
					// then we can unmarshall them rather than creating them from xml
					if (post.attachments) {
						project.parseAttachments(post.attachments);
					}
					
					// if id is not set in the XML set it manually
					// we need id for  delete
					if (project.id==null || project.id=="") {
						project.id = post.id;
					}
					
					// let's enforce url 
					project.uri = post.url;
					if (project.uri==null || project.uri=="") {
						project.uri = post.url;
					}
					//addProject(project);
					potentialProjects.push(project);
				}
				else {
					Radiate.info("Could not import project:" + post.title);
				}
			}
			
			var sort:Sort = new Sort();
			var sortField:SortField = new SortField("dateSaved");
			sort.fields = [sortField];
			
			return potentialProjects;
		}
		
		/**
		 * Open saved documents if they exist or open a blank document
		 * */
		public static function openInitialProjects():void {
			/*
			if (savedData && (savedData.projects.length>0 || savedData.documents.length>0)) {
			restoreSavedData(savedData);
			}
			else {
			createBlankDemoDocument();
			}
			*/
			var savedData:SavedData = SettingsManager.savedData;
			
			if (!ProfileManager.isUserLoggedIn) {
				if (savedData && (savedData.projects.length>0 || savedData.documents.length>0)) {
					openLocalProjects(savedData);
				}
				else {
					DocumentManager.createBlankDemoDocument();
				}
			}
			else {
				ServicesManager.instance.getProjects();
				ServicesManager.instance.getAttachments();
			}
		}
		
		/**
		 * Exports an XML string for a project
		 * */
		public static function exportProject(project:IProject, format:String = "String"):String {
			var projectString:String = project.toString();
			
			return projectString;
		}
		
		/**
		 * Creates a project
		 * */
		public static function createProject(name:String = null):IProject {
			var newProject:IProject = new Project();
			
			newProject.name = name ? name : "Project "  + Project.nameIndex;
			newProject.host = Radiate.getWPURL();
			
			return newProject;
		}
		
		
		// Error #1047: Parameter initializer unknown or is not a compile-time constant.
		// Occassionally a 1047 error shows up. 
		// This is from using a static var in the parameter as the default 
		// and is an error in FB - run clean and it will go away
		
		/**
		 * Adds a project to the projects array. We should remove open project behavior. 
		 * */
		public static function addProject(newProject:IProject, open:Boolean = false, locations:String = null, dispatchEvents:Boolean = true):IProject {
			var found:Boolean = doesProjectExist(newProject.uid);
			
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			
			if (!found) {
				projects.push(newProject);
			}
			else {
				return newProject;
			}
			
			// if no projects exist select the first one
			/*if (!selectedProject) {
			setProject(newProject, dispatchEvents);
			}*/
			
			if (dispatchEvents) {
				Radiate.dispatchProjectAddedEvent(newProject);
			}
			
			if (open) {
				openProject(newProject, locations, dispatchEvents);// TODO project opened or changed
			}
			
			return newProject;
		}
		
		/**
		 * Opens project from main view
		 * */
		public static function openProjectFromMainView(project:IProject):void {
			
			if (project && project is IProject && !project.isOpen) {
				ViewManager.mainView.currentState = MenuManager.DESIGN_STATE;
				ViewManager.mainView.validateNow();
				addProject(project, false);
				openProjectFromMetaData(project, DocumentData.REMOTE_LOCATION, true);
				Radiate.setProject(project, true);
			}
			else if (project && project is IProject && project.isOpen) {
				ViewManager.mainView.currentState = MenuManager.DESIGN_STATE;
				ViewManager.mainView.validateNow();
				Radiate.setProject(project, true);
			}
		}
		
		/**
		 * Opens the project. Right now this does not do much. 
		 * */
		public static function openProject(iProject:IProject, locations:String = null, dispatchEvents:Boolean = true):Object {
			var isAlreadyOpen:Boolean;
			
			if (iProject==null) {
				error("No project to open");
				return null;
			}
			
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			
			isAlreadyOpen = isProjectOpen(iProject);
			
			if (iProject as EventDispatcher) {
				EventDispatcher(iProject).addEventListener(Project.PROJECT_OPENED, projectOpenResultHandler, false, 0, true);
			}
			
			if (isAlreadyOpen) {
				//setProject(iProject, dispatchEvents);
				return true;
			}
			else {
				// TODO open project documents
				iProject.open(locations);
				iProject.isOpen = true;
			}
			
			
			// show project
			//setProject(iProject, dispatchEvents);
			
			return true;
		}
		
		/**
		 * Project opened result handler
		 * */
		public static function projectOpenResultHandler(event:Event):void {
			var iProject:IProject = event.currentTarget as IProject;
			
			// add assets
			LibraryManager.addAssetsToDocument(iProject.assets, iProject as DocumentData);
			
			if (iProject is EventDispatcher) {
				EventDispatcher(iProject).removeEventListener(Project.PROJECT_OPENED, projectOpenResultHandler);
			}
			
			Radiate.dispatchProjectOpenedEvent(iProject);
		}
		
		/**
		 * Opens the project. Right now this does not do much. 
		 * */
		public static function openProjectFromMetaData(iProject:IProject, locations:String = null, dispatchEvents:Boolean = true):Object {
			var isAlreadyOpen:Boolean;
			
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			
			isAlreadyOpen = isProjectOpen(iProject);
			
			/*
			if (dispatchEvents) {
			dispatchProjectChangeEvent(iProject);
			}*/
			
			if (iProject as EventDispatcher) {
				EventDispatcher(iProject).addEventListener(Project.PROJECT_OPENED, projectOpenResultHandler, false, 0, true);
			}
			
			// TODO open project documents
			iProject.openFromMetaData(locations);
			
			if (isAlreadyOpen) {
				//setProject(iProject, dispatchEvents);
				return true;
			}
			else {
				iProject.isOpen = true;
			}
			
			
			// show project
			//setProject(iProject, dispatchEvents);
			
			return true;
		}
		
		/**
		 * Checks if project is open.
		 * */
		public static function isProjectOpen(iProject:IProject):Boolean {
			
			return iProject.isOpen;
		}
		
		/**
		 * Closes project if open.
		 * */
		public static function closeProject(iProject:IProject, dispatchEvents:Boolean = true):Boolean {
			if (iProject==null) {
				error("No project to close");
				return false;
			}
			
			var numOfDocuments:int = iProject.documents.length;
			//info("Close project");
			if (dispatchEvents) {
				Radiate.dispatchProjectClosingEvent(iProject);
			}
			
			for (var i:int=numOfDocuments;i--;) {
				DocumentManager.closeDocument(IDocument(iProject.documents[i]));
				//removeDocument(IDocument(iProject.documents[i]));
			}
			
			iProject.close();
			
			if (dispatchEvents) {
				Radiate.dispatchProjectClosedEvent(iProject);
			}
			
			return false;			
		}
		
		/**
		 * Removes a project from the projects array. TODO Remove from server
		 * */
		public static function removeProject(iProject:IProject, locations:String = null, dispatchEvents:Boolean = true):Boolean {
			// 1047: Parameter initializer unknown or is not a compile-time constant.
			// Occassionally a 1047 error shows up. 
			// This is from using a static var in the parameter as the default 
			// and is an error in FB - run clean and it will go away
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			
			var projectIndex:int = projects.indexOf(iProject);
			var removedProject:IProject;
			var remote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var numberOfDocuments:int;
			var removedProjects:Array;
			
			if (projectIndex!=-1) {
				removedProjects = projects.splice(projectIndex, 1);
				
				if (removedProjects[0]==iProject) {
					info("Project removed successfully");
					
					numberOfDocuments = iProject.documents.length;
					
					for (var i:int=numberOfDocuments;i--;) {
						DocumentManager.removeDocument(IDocument(iProject.documents[i]), locations, dispatchEvents);
					}
				}
				
			}
			
			if (remote && iProject && iProject.id) { 
				// we need to create service
				if (deleteProjectService==null) {
					deleteProjectService = new WPService();
					deleteProjectService.addEventListener(WPService.RESULT, deleteProjectResultsHandler, false, 0, true);
					deleteProjectService.addEventListener(WPService.FAULT, deleteProjectFaultHandler, false, 0, true);
				}
				
				deleteProjectService.host = Radiate.getWPURL();
				
				deleteProjectInProgress = true;
				
				deleteProjectService.id = iProject.id;
				deleteProjectService.deletePost();
			}
			else if (remote) {
				if (dispatchEvents) {
					Radiate.dispatchProjectRemovedEvent(iProject);
					Radiate.dispatchProjectDeletedEvent(true, iProject);
				}
				return false;
			}
			
			// get first or last open document and select the project it's part of
			if (!selectedProject) {
				// to do
			}
			
			if (!remote && dispatchEvents) {
				Radiate.dispatchProjectRemovedEvent(iProject);
			}
			
			return true;
		}
		
		/**
		 * Create project from project data
		 * */
		public static function createProjectFromData(projectData:IProjectData):IProject {
			var newProject:IProject = createProject();
			newProject.unmarshall(projectData);
			
			return newProject;
		}
		
		/**
		 * Create project from project XML data
		 * */
		public static function createProjectFromXML(projectData:XML):IProject {
			var newProject:IProject = createProject();
			newProject.unmarshall(projectData);
			
			return newProject;
		}
		
		//----------------------------------
		//  instance
		//----------------------------------
		
		public static function get instance():ProjectManager
		{
			if (!_instance) {
				_instance = new ProjectManager(new SINGLEDOUBLE());
			}
			return _instance;
		}
		
		public static function getInstance():ProjectManager {
			return instance;
		}
		
		private static var _instance:ProjectManager;
	}
}

class SINGLEDOUBLE{}