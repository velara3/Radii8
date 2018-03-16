package com.flexcapacitor.managers
{
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.effects.core.CallMethod;
	import com.flexcapacitor.effects.popup.OpenPopUp;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.model.DocumentData;
	import com.flexcapacitor.model.DocumentMetaData;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IDocumentData;
	import com.flexcapacitor.model.IProject;
	import com.flexcapacitor.model.MenuItem;
	import com.flexcapacitor.tools.ITool;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	import com.flexcapacitor.utils.supportClasses.log;
	import com.flexcapacitor.views.MainView;
	import com.flexcapacitor.views.windows.LoginWindow;
	import com.flexcapacitor.views.windows.NewDocumentWindow;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.system.TouchscreenType;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	import mx.controls.Menu;
	import mx.controls.MenuBar;
	import mx.core.DragSource;
	import mx.core.IUIComponent;
	import mx.events.DragEvent;
	import mx.events.EffectEvent;
	import mx.events.MenuEvent;
	import mx.managers.DragManager;
	import mx.utils.Platform;
	
	import spark.collections.Sort;
	import spark.collections.SortField;
	import spark.components.Application;
	import spark.components.Image;
	import spark.events.IndexChangeEvent;
	
	import org.as3commons.lang.DictionaryUtils;

	/**
	 * Manages menus
	 **/
	public class MenuManager {
		
		public function MenuManager() {
			
		}
		
		public static const HOME_STATE:String = "home";
		public static const DESIGN_STATE:String = "design";
		public static const DESCRIPTION_STATE:String = "description";
		
		public static function get currentState():String {
			return mainView.currentState;
		}

		public static function set currentState(value:String):void {
			mainView.currentState = value;
		}

		/**
		 * Get the current document.
		 * */
		public static function get selectedDocument():IDocument {
			return Radiate.selectedDocument;
		}
		
		/**
		 * Application menu
		 * */
		[Bindable]
		public static var applicationMenu:Object;
		
		/**
		 * Application window menu
		 * */
		[Bindable]
		public static var applicationWindowMenu:Object;
		
		public static var windowMenuDictionary:Dictionary = new Dictionary(true);
		
		public static var fileTransferWindowClass:String = "com.flexcapacitor.views.FileTransferWindow";
		
		public static var debug:Boolean;
		
		public static var radiate:Radiate;
		public static var clipboardManager:ClipboardManager;
		public static var serviceManager:ServicesManager;
		
		public static var isWin:Boolean;
		public static var isMac:Boolean;
		public static var mainView:MainView;
		public static var mainMenuBar:MenuBar;
		
		public static var isCreatingDocument:Boolean;
		
		public static var ee:Boolean;
		public static var ripple:Object;
		public static var targetEffect:Object;
		
		public static var exampleProject:IProject;
		
		public static var browseForImage:FileReference;
		public static var checkOnlineEffect:CallMethod = new CallMethod();
		
		[Bindable]
		public static var projectsCollection:ArrayCollection = new ArrayCollection();
		[Bindable]
		public static var newsCollection:ArrayCollection = new ArrayCollection();
		[Bindable]
		public static var documentsCollection:ArrayCollection = new ArrayCollection();
		[Bindable]
		public static var examplesCollection:ArrayCollection = new ArrayCollection();
		[Bindable]
		public static var templatesCollection:ArrayCollection = new ArrayCollection();
		
		public static function startup():void {
			radiate = Radiate.instance;
			clipboardManager= ClipboardManager.getInstance();
			serviceManager = ServicesManager.getInstance();
			
			mainView = ViewManager.mainView;
			mainMenuBar = mainView.mainMenuBar;
			
			Radiate.showMessageLabel = mainView.instantMessageLabel;
			Radiate.showMessageAnimation = mainView.notificationMessenger;
			
			//PerformanceManager.addItem(Radiate.SET_TARGET_TEST, performanceLabel, "text", 500);
			
			updateCheckExamples();
			updateCheckProjects();
			updateCheckNews();
			updateCheckLoginStatus();
			
			serviceManager.getLoggedInStatus();
			serviceManager.getNewsPosts();
			serviceManager.getExampleProjects();
			
			if (ProfileManager.userID!=-1) {
				serviceManager.getProjectsByUser(ProfileManager.userID);
			}
			else {
				updateCheckProjects(0);
			}
			
			mainView.addEventListener(DragEvent.DRAG_ENTER, mainView_dragEnterHandler, false, 0, true);
			mainView.addEventListener(DragEvent.DRAG_EXIT, mainView_dragExitHandler, false, 0, true);
			mainView.addEventListener(DragEvent.DRAG_OVER, mainView_dragOverHandler, false, 0, true);
			mainView.addEventListener(DragEvent.DRAG_DROP, mainView_dragDropHandler, false, 0, true);
				
			serviceManager.addEventListener(RadiateEvent.BLOG_POSTS_RECEIVED, blogPostsReceivedHandler, false, 0, true);
			serviceManager.addEventListener(RadiateEvent.LOGGED_IN_STATUS, loggedInStatusHandler, false, 0, true);
			serviceManager.addEventListener(RadiateEvent.LOGIN_RESULTS, loggedInStatusHandler, false, 0, true);
			serviceManager.addEventListener(RadiateEvent.EXAMPLE_PROJECTS_LIST_RECEIVED, receivedExampleProjectsHandler, false, 0, true);
			serviceManager.addEventListener(RadiateEvent.PROJECTS_LIST_RECEIVED, receivedProjectsHandler, false, 0, true);
			serviceManager.addEventListener(RadiateEvent.PROJECT_SET_HOME_PAGE, clearHomePageHandler, false, 0, true);
			
			radiate.addEventListener(RadiateEvent.DOCUMENT_ADDED, documentChangeEventHandler, false, 0, true);
			radiate.addEventListener(RadiateEvent.DOCUMENT_REMOVED, documentChangeEventHandler, false, 0, true);
			radiate.addEventListener(RadiateEvent.DOCUMENT_RENAME, documentChangeEventHandler, false, 0, true);
			
			checkOnlineEffect.repeatCount = 0;
			checkOnlineEffect.method = checkOnline;
			checkOnlineEffect.repeatDelay = 60000;
			
			if (Capabilities.touchscreenType==TouchscreenType.FINGER) {
				cornerLogo_clickHandler(null);
			}
			
			if (Radiate.startInDesignView) {
				DocumentManager.createNewDocumentAndSwitchToDesignView();
				radiate.addEventListener(RadiateEvent.DOCUMENT_OPEN, documentOpenedHandler, false, 0, true);
				isCreatingDocument = true;
			}
			//PerformanceManager.start();
			//trace(ProfileManager.isUserLoggedIn);
		}
		
		/**
		 * On desktop on Mac hide the menu bar since we use the native menu bar
		 * */
		public static function showMenuBar(value:Boolean):void {
			mainMenuBar.visible = value;
			mainMenuBar.includeInLayout = value;
			mainMenuBar.visible = value;
			mainMenuBar.includeInLayout = value;
		}
		
		/**
		 * Check for news items
		 * */
		public static function news_clickHandler(event:MouseEvent):void {
			updateCheckNews(-1);
			
			serviceManager.getNewsPosts();
		}
		
		/**
		 * Check for projects
		 * */
		public static function projectsLabel_clickHandler(event:MouseEvent):void {
			updateCheckProjects(-1);
			
			serviceManager.getProjectsByUser(ProfileManager.userID);
		}
		
		/**
		 * Check for examples
		 * */
		public static function examplesLabel_clickHandler(event:MouseEvent):void
		{
			updateCheckExamples(-1);
			
			serviceManager.getExampleProjects();
		}
		
		public static function clearHomePageHandler(event:RadiateEvent):void {
			if (event.successful) {
				Radiate.info("Home page cleared");
			}
		}
		
		public static function saveSnippetMenuItem_itemClickHandler(event:MenuEvent):void
		{
			ViewManager.openExportSnippetWindow();
		}
		
		public static function contactLabel_clickHandler(event:MouseEvent):void
		{
			ViewManager.openContactWindow();
		}
		
		public static function logoutLabel_clickHandler(event:MouseEvent):void
		{
			ViewManager.openLogoutWindow(logoutPopUp_closeHandler);
		}
		
		public static function newProjectButton_clickHandler(event:Event=null):void
		{
			ViewManager.openNewProjectWindow(createNewProjectLabel_clickHandler);
		}
		
		public static function deleteDocument_itemClickHandler(event:MenuEvent):void
		{
			ViewManager.openDeleteDocumentWindow(openDeleteDocumentPopUp_closeHandler);
		}
		
		public static function deleteProjectIcon_clickHandler(event:Event=null):void
		{
			ViewManager.openDeleteProjectWindow(mainView.projectsList.selectedItem as DocumentData, getProjectsByUser);
		}
		
		public static function exportDocument_itemClickHandler(event:MenuEvent):void
		{
			ViewManager.openExportDocumentWindow();
		}
		
		public static function uploadToServer_eventStartHandler(event:Event):void {
			if (Platform.isBrowser==true) {
				event.preventDefault();
				Radiate.info("This feature is only available in the desktop version");
			}
			else {
				ViewManager.openUploadToServerWindow();
			}
		}
		
		public static function printItem_itemClickHandler(event:MenuEvent):void
		{
			ViewManager.openPrintWindow();
		}
		
		public static function lostPasswordLabel_clickHandler(event:MouseEvent):void
		{
			ViewManager.openLostLoginWindow(function(e:Event=null):void {loginPopUp_closeHandler(LoginWindow.LOST_PASSWORD)});
		}
		
		public static function loginLabel_clickHandler(event:MouseEvent):void
		{
			ViewManager.openLoginWindow(function(e:Event=null):void {loginPopUp_closeHandler(LoginWindow.LOGIN)});
		}
		
		public static function registerLabel_clickHandler(event:MouseEvent):void
		{
			ViewManager.openRegistrationWindow(function(e:Event=null):void {loginPopUp_closeHandler(LoginWindow.REGISTRATION_WITH_SITE)});
		}
		
		public static function creditsMenuItem_itemClickHandler(event:MenuEvent):void
		{
			ViewManager.openCreditsWindow();
		}
		
		public static function helpMenuItem_itemClickHandler(event:MenuEvent):void
		{
			ViewManager.openHelpWindow();
		}
		
		public static function settings_clickHandler(event:Event):void {
			ViewManager.openSettingsWindow();
		}
		
		public static function cornerLogo_clickHandler(event:MouseEvent):void {
			
			ViewManager.openSettingsWindow();
			
			// was trying to add fancy special effects to home screen
			// but disabling for now
			return;
			
			if (!ee) {
				if (!ripple) {
					ripple = ApplicationDomain.currentDomain.getDefinition(String.fromCharCode(99,111,109,46,102,108,101,120,99,97,112,97,99,105,116,111,114,46,103,114,97,112,104,105,99,115,46,82,105,112,112,108,101,114));
					
					if (ripple) {
						ripple = new ripple;
					}
				}
				//e.event = MouseEvent.CLICK;
				//e.target = backgroundLogoImage;
				ripple.event = MouseEvent.MOUSE_MOVE;
				
				if (targetEffect==null) targetEffect = mainView.backgroundLogoImage;
				//ripple.useLocalCoordinates = true;
				ripple.target = targetEffect;
				//backgroundLogoImage.source = "background01.jpg";
				//e.target = DocumentManager.canvasBackground; 
				//e.target = FlexGlobals.topLevelApplication; 
				ee = true;
			}
			else {
				ee = false;
				//removeEventListener(MouseEvent.CLICK, stageHandler);
				if (ripple) {
					ripple.destroy();
				}
			}
		}
		
		/**
		 * Switch views on logo click
		 * */
		public static function logo_clickHandler(event:MouseEvent):void {
			
			if (currentState==HOME_STATE) {
				if (ripple) ripple.destroy();
				if (ProjectManager.projects.length!=0) {
					currentState = DESIGN_STATE;
				}
			}
			else {
				currentState = HOME_STATE;
			}
			
		}
		
		/**
		 * Handle when getting result of call that checks if user is logged in
		 * */
		public static function loggedInStatusHandler(event:RadiateEvent):void {
			
			if (ProfileManager.isUserLoggedIn) {
				updateCheckLoginStatus(1);
				updateCheckProjects(-1);
				serviceManager.getProjectsByUser(ProfileManager.userID);
				mainView.userIcon.source = ProfileManager.userAvatar;
			}
			else {
				updateCheckLoginStatus(0);
				mainView.userIcon.source = ProfileManager.defaultUserAvatarPath;
			}
			
			mainView.isConnectedCheckbox.selected = ProfileManager.isUserConnected;
		}
		
		/**
		 * Handle when getting result of list of projects
		 * */
		public static function receivedProjectsHandler(event:RadiateEvent):void {
			var iProject:IProject;
			var projects:Array;
			var sortFields:Array = [];
			var dateSortField:SortField;
			var descending:Boolean = true;
			
			dateSortField = new SortField("dateSaved", descending);
			sortFields.push(dateSortField);
			
			projects = ProjectManager.parseProjectsData(event.data);
			projectsCollection.sort = new Sort(sortFields);
			projectsCollection.source = projects;
			documentsCollection.source = [];
			
			for (var i:int = 0; i < projects.length; i++) {
				iProject = projects[i];
				ProjectManager.addProject(iProject);
			}
			
			
			if (projectsCollection.length==0 && mainView.checkingForProjectsLabel) {
				updateCheckProjects(0);
				mainView.openPreviousProject.enabled = false;
			}
			else if (mainView.checkingForProjectsLabel) {
				updateCheckProjects(1);
				mainView.openPreviousProject.enabled = true;
				iProject = projectsCollection.getItemAt(0) as IProject;
				mainView.openPreviousProject.label = "Open " + iProject.name;
			}
			
		}
		
		public static function examplesList_changeHandler(event:IndexChangeEvent):void {
			var selectedItem:Object = mainView.examplesList.selectedItem;
			
			mainView.projectsList.selectedItem = null;
		}
		
		
		/**
		 * Handle when getting result of example list of projects
		 * */
		public static function receivedExampleProjectsHandler(event:RadiateEvent):void {
			var projects:Array = ProjectManager.parseProjectsData(event.data);
			examplesCollection.source = projects;
			
			if (examplesCollection.length==0 && mainView.checkingForExampleProjectsLabel) {
				updateCheckExamples(0);
			}
			else if (mainView.checkingForExampleProjectsLabel) {
				updateCheckExamples(1);
			}
			
		}
		
		
		/**
		 * Show project info and show documents in the project
		 * */
		public static function projectsList_changeHandler(event:IndexChangeEvent = null):void {
			var project:IProject = mainView.projectsList.selectedItem;
			mainView.examplesList.selectedItem = null;
			
			if (project && project is IProject) {
				mainView.projectLastSavedLabel.text = "" + project.dateSaved;
				documentsCollection.source = project.documentsMetaData;
			}
		}
		
		/**
		 * Open last project selected in project list
		 * */
		public static function openLastProject():void {
			var project:IProject = projectsCollection.length ? projectsCollection.getItemAt(0) as IProject : null;
			
			if (project && project is IProject) {
				currentState = DESIGN_STATE;
				mainView.validateNow();
				ProjectManager.addProject(project, false);
				//ProjectManager.openProject(project, DocumentData.REMOTE_LOCATION, true);
				ProjectManager.openProjectFromMetaData(project, DocumentData.REMOTE_LOCATION, true);
				Radiate.setProject(project, true);
				//projectsList.selectedIndex = -1;
			}
		}
		
		/**
		 * Handle login result
		 * */
		public static function loginPopUp_closeHandler(eventName:String):void {
			var loginWindow:LoginWindow;
			var action:String;
			
			if (LoginWindow.LOGIN==eventName) {
				loginWindow = LoginWindow(ViewManager.openLoginPopUp.popUp);
			}
			else if (LoginWindow.LOST_PASSWORD==eventName) {
				loginWindow = LoginWindow(ViewManager.openLostLoginPopUp.popUp);
			}
			else if (LoginWindow.REGISTRATION_WITH_SITE==eventName) {
				loginWindow = LoginWindow(ViewManager.openRegistrationPopUp.popUp);
			}
			
			action = loginWindow ? loginWindow.action : null;
			
			if (action==LoginWindow.CANCEL) {
				return;
			}
			
			if (ProfileManager.isUserLoggedIn) {
				updateCheckProjects(-1);
				checkForProjects();
				updateCheckLoginStatus(1);
				ProjectManager.saveExampleProjects();
			}
			else {
				serviceManager.getLoggedInStatus();
				updateCheckProjects(0);
			}
			
		}
		
		/**
		 * Check online status after logout
		 * */
		public static function logoutPopUp_closeHandler(event:Event):void {
			var loginWindow:LoginWindow = LoginWindow(ViewManager.openLogoutPopUp.popUp);
			var action:String = loginWindow ? loginWindow.action : null;
			
			if (action==LoginWindow.CANCEL || action==null) {
				return;
			}
			
			setTimeout(Radiate.info, 1000, ["Logout successful"]);
			
			updateCheckProjects(0);
			projectsCollection.removeAll();
			projectsCollection.refresh();
			checkOnline();
		}
		
		/**
		 * Check if the user is online
		 * */
		public static function checkOnline():void {
			//trace("checking online status");
			serviceManager.getLoggedInStatus();
			updateCheckLoginStatus(-1);
		}
		
		/**
		 * Work offline clicked. May not be functioning at this time? 
		 * */
		public static function workOfflineMenuItem_itemClickHandler(event:Event):void {
			if (mainView.workOfflineMenuItem.toggled) {
				checkOnlineEffect.stop();
			}
			else {
				if (!checkOnlineEffect.isPlaying) {
					checkOnlineEffect.play();
				}
			}
		}
		
		/**
		 * Create a new project
		 * */
		public static function createNewProjectLabel_clickHandler(event:Event):void {
			var openNewProject:OpenPopUp = event.currentTarget as OpenPopUp;
			var popUp:NewDocumentWindow = openNewProject.popUp as NewDocumentWindow;
			var projectName:String = popUp.projectName;
			var documentName:String = popUp.documentName;
			
			if (popUp.action==NewDocumentWindow.FINISH) {
				currentState = DESIGN_STATE;
				mainView.validateNow();
				DocumentManager.createBlankDemoDocument(projectName, documentName);
				
				if (ProfileManager.isUserLoggedIn) {
					ProjectManager.saveProject(Radiate.selectedProject);
				}
				else {
					//Radiate.info("The project will not be saved");
				}
			}
		}
		
		/**
		 * Get projects by user that is logged in. 
		 * Right now this is checking a remote WP server. We could have it point 
		 * to a local directory of projects or workspace. 
		 * */
		public static function getProjectsByUser_clickHandler(event:MouseEvent):void {
			getProjectsByUser();
		}
		
		/**
		 * Get public projects / examples. There are no public or shared examples yet. 
		 * */
		public static function getPublicProjects_clickHandler(event:MouseEvent):void {
			checkForExampleProjects();
		}
		
		/**
		 * Get projects by current user
		 * */
		public static function getProjectsByUser():void {
			checkForProjects();
		}
		
		/**
		 * Get a list of projects by user or that are shared by the public or are examples. 
		 * Shared public projects and example projects should be in their own category. 
		 * */
		public static function checkForProjects():void {
			mainView.projectsList.selectedItem = null;
			
			serviceManager.getProjectsByUser(ProfileManager.userID);
			
			if (mainView.checkingForProjectsLabel) {
				updateCheckProjects(-1);
			}
		}
		
		/**
		 * Get a list of example projects 
		 * Shared public projects and example projects should be in their own category. 
		 * */
		public static function checkForExampleProjects(byUser:Boolean = false):void {
			//projectsList.dataProvider = null;
			mainView.examplesList.selectedItem = null;
			
			serviceManager.getExampleProjects();
			
			updateCheckExamples(-1);
		}
		
		/**
		 * Check for projects 
		 * */
		public static function removeProject_itemClickHandler(event:Event):void {
			checkForProjects();
		}
		
		/**
		 * Check if connected to remote WP server and update checkbox
		 * */
		public static function isConnectedCheckbox_clickHandler(event:MouseEvent):void {
			
			mainView.isConnectedCheckbox.selected = ProfileManager.isUserConnected;
			
			
			checkOnline();
		}
		
		/**
		 * Handle if user icon is not available
		 * */
		public static function userIcon_securityErrorHandler(event:SecurityErrorEvent):void {
			if (debug) {
				log("User icon security error: ", event);
			}
		}
		
		/**
		 * Handle if user icon is not available
		 * */
		public static function userIcon_ioErrorHandler(event:IOErrorEvent):void {
			if (debug) {
				log("User icon io error: ", event);
			}
			
			// keeps looping when icon can't be found
			if (mainView.userIcon.source!=ProfileManager.defaultUserAvatarPath) {
				mainView.userIcon.source = ProfileManager.defaultUserAvatarPath;
			}
			else {
				mainView.userIcon.source = null;
			}
		}
		
		public static function fadeOutStatus_effectEndHandler(event:EffectEvent):void {
			updateCheckLoginStatus(1);
		}
		
		public static function examplesList_doubleClickHandler(event:MouseEvent):void {
			var project:IProject = mainView.examplesList.selectedItem;
			
			if (project) {
				Radiate.info("Opening example project '" + project.name + "'");
				
				DeferManager.callAfter(250, openExampleProject, project);
			}
			
		}
		
		/**
		 * Makes a duplicate of the example project
		 * Once it's loaded we need to clear the fields out and
		 * then save the project
		 * */
		public static function openExampleProject(project:IProject):void {
			
			if (project && project is IProject) {
				currentState = DESIGN_STATE;
				mainView.validateNow();
				exampleProject = project;
				ProjectManager.addProject(project, false);
				//ProjectManager.openProject(project, DocumentData.REMOTE_LOCATION, true);
				ProjectManager.openProjectFromMetaData(project, DocumentData.REMOTE_LOCATION, true);
				Radiate.addEventListener(RadiateEvent.PROJECT_OPENED, exampleProjectOpened, false, 0, true);
				Radiate.setProject(project, true);
				//projectsList.selectedIndex = -1;
			}
		}
		
		public static function exampleProjectOpened(event:Event):void {
			if (exampleProject) {
				ProjectManager.clearExampleProjectData(exampleProject);
				ProjectManager.saveExampleProject(exampleProject);
				updateCheckExamples(-1);
				serviceManager.getExampleProjects();
				updateCheckProjects(-1);
				setTimeout(serviceManager.getProjectsByUser, 6000, ProfileManager.userID);
				setTimeout(serviceManager.getProjectsByUser, 12000, ProfileManager.userID);
				exampleProject = null;
			}
		}
		
		public static function projectsList_doubleClickHandler(event:MouseEvent):void {
			var project:IProject = mainView.projectsList.selectedItem;
			
			if (project) {
				Radiate.info("Opening project '" + project.name + "'");
				
				DeferManager.callAfter(250, ProjectManager.openProjectFromMainView, project);
			}
		}
		
		
		public static function newsList_doubleClickHandler(event:MouseEvent):void {
			var request:URLRequest;
			
			if (mainView.newsList.selectedItem) {
				request = new URLRequest();
				request.url = mainView.newsList.selectedItem.url;
				navigateToURL(request, "previewInBrowser");
			}
			
		}
		
		public static function newsList_changeHandler(event:IndexChangeEvent):void
		{
			
			
		}
		
		public static function blogPostsReceivedHandler(event:RadiateEvent):void
		{
			var posts:Array = serviceManager.parsePostsData(event.data);
			newsCollection.source = posts;
			
			if (newsCollection.length==0) {
				updateCheckNews(0);
				//openPreviousProject.enabled = false;
			}
			else {
				updateCheckNews(1);
			}
		}
		
		/**
		 * Updates the label checking for examples
		 * -1 = checking
		 * 0 = no examples available
		 * 1 = examples found
		 * */
		public static function updateCheckExamples(param0:int = -1):void
		{
			
			if (param0==-1) {
				mainView.checkingForExampleProjectsLabel.text = "Checking for examples...";
				mainView.checkingForExampleProjectsLabel.includeInLayout = true;
				mainView.checkingForExampleProjectsLabel.visible = true;
			}
			else if (param0==0) {
				mainView.checkingForExampleProjectsLabel.text = "No examples available";
				mainView.checkingForExampleProjectsLabel.includeInLayout = true;
				mainView.checkingForExampleProjectsLabel.visible = true;
			}
			else if (param0==1) {
				mainView.checkingForExampleProjectsLabel.text = "";
				mainView.checkingForExampleProjectsLabel.includeInLayout = false;
				mainView.checkingForExampleProjectsLabel.visible = false;
			}
		}
		
		/**
		 * Updates the label checking for projects
		 * -1 = checking
		 * 0 = no projects available
		 * 1 = projects found
		 * */
		public static function updateCheckProjects(param0:int = -1):void
		{
			
			if (param0==-1) {
				mainView.checkingForProjectsLabel.text = "Checking for projects...";
				mainView.checkingForProjectsLabel.includeInLayout = true;
				mainView.checkingForProjectsLabel.visible = true;
			}
			else if (param0==0) {
				mainView.checkingForProjectsLabel.text = "No projects available";
				mainView.checkingForProjectsLabel.includeInLayout = true;
				mainView.checkingForProjectsLabel.visible = true;
			}
			else if (param0==1) {
				mainView.checkingForProjectsLabel.text = "";
				mainView.checkingForProjectsLabel.includeInLayout = false;
				mainView.checkingForProjectsLabel.visible = false;
			}
		}
		
		/**
		 * Updates the label checking for news
		 * -1 = checking
		 * 0 = no news available
		 * 1 = projects found
		 * */
		public static function updateCheckNews(param0:int = -1):void
		{
			
			if (param0==-1) {
				mainView.checkingForNewsLabel.text = "Checking for news...";
				mainView.checkingForNewsLabel.includeInLayout = true;
				mainView.checkingForNewsLabel.visible = true;
			}
			else if (param0==0) {
				mainView.checkingForNewsLabel.text = "No tutorials available";
				mainView.checkingForNewsLabel.includeInLayout = true;
				mainView.checkingForNewsLabel.visible = true;
			}
			else if (param0==1) {
				mainView.checkingForNewsLabel.text = "";
				mainView.checkingForNewsLabel.includeInLayout = false;
				mainView.checkingForNewsLabel.visible = false;
			}
		}
		
		/**
		 * Updates the label checking for login status
		 * -1 = checking if logged in
		 * 0 = not logged in
		 * 1 = hidden
		 * */
		public static function updateCheckLoginStatus(param0:int = -1):void {
			
			if (param0==-1) {
				mainView.statusLabel.text = "Checking to see if you're logged in... one second.";
				mainView.statusLabel.includeInLayout = true;
				mainView.statusLabel.visible = true;
			}
			else if (param0==0) {
				mainView.statusLabel.text = "You are not logged in. You must be logged in to save projects";
				mainView.statusLabel.includeInLayout = true;
				mainView.statusLabel.visible = true;
			}
			else if (param0==1) {
				mainView.statusLabel.text = "";
				mainView.statusLabel.includeInLayout = false;
				mainView.statusLabel.visible = false;
			}
		}
		
		public static function init():void { 
			isWin = Platform.isWindows; 
			isMac = Platform.isMac; 
		}
		
		/**
		 * Returns true if it's a type of content we can accept to be dragged and dropped
		 * */
		public static function acceptableFileFormat(dragSource:DragSource):Boolean {
			if (dragSource==null) return false;
			
			if (dragSource.hasFormat("air:file list") || 
				dragSource.hasFormat("air:url")) {
				return true;
			}
			
			return false;
		}
		
		public static function mainView_dragEnterHandler(event:DragEvent):void {
			if (ViewManager.isCopyImageToClipboardPanelOpen()) return;
			
			// if drag initiator is null it means it was 
			// dragged in from outside of the application
			if (event.dragInitiator==null && LibraryManager.isAcceptableDragAndDropFormat(event.dragSource)) {
				DragManager.acceptDragDrop(IUIComponent(event.currentTarget));
				mainView.dropImagesLocation.visible = true;
			}
		}
		
		public static function mainView_dragOverHandler(event:DragEvent):void {
			// todo check if html element is visible in browser to ignore accidental drag of elements
			if (ViewManager.isCopyImageToClipboardPanelOpen()) return;
			
			if (event.dragInitiator==null && LibraryManager.isAcceptableDragAndDropFormat(event.dragSource)) {
				DragManager.acceptDragDrop(IUIComponent(event.currentTarget));
				mainView.dropImagesLocation.visible = true;
			}
			
		}
		
		public static function mainView_dragDropHandler(event:DragEvent):void {
			if (ViewManager.isCopyImageToClipboardPanelOpen()) return;
			
			var dragSource:DragSource;
			var hasFileListFormat:Boolean;
			var hasFilePromiseListFormat:Boolean;
			var isSelf:Boolean;
			
			mainView.dropImagesLocation.visible = false;
			
			if (event.dragInitiator) {
				isSelf = mainView..contains(event.dragInitiator as DisplayObject);
				return;
			}
			
			// TODO: Add option to not resize by holding down the shift key 
			if (currentState==DESIGN_STATE) {
				LibraryManager.dropItem(event);
			}
			else {
				LibraryManager.dropItem(event, true);
			}
		}
		
		public static function mainView_dragExitHandler(event:DragEvent):void {
			mainView.dropImagesLocation.visible = false;
		}
		
		public static function openDeleteDocumentPopUp_closeHandler(event:Event):void {
			if (Radiate.selectedProject) {
				Radiate.selectedProject.save();
			}
		}
		
		public static function miniinspector1_changeHandler(event:MouseEvent):void {
			if (event.relatedObject as DisplayObject) {
				targetEffect = event.relatedObject;
				if (ee) {
					ripple.destroy();
					ripple.target = targetEffect;
				}
			}
		}
		
		public static function documentChangeEventHandler(event:Event):void {
			MenuManager.updateWindowMenu(mainView.windowMenu);
		}
		
		/**
		 * Handle file selected
		 **/
		public static function browseForFile_selectHandler(event:Event):void {
			
			if (browseForImage) {
				LibraryManager.loadSelectedFile(browseForImage);
			}
			
		}
		
		public static function psdLoadedHandler(event:Event):void {
			if (Radiate.selectedDocument) {
				Radiate.info("Importing PSD");
				DeferManager.callAfter(250, LibraryManager.addPSDToDocument, mainView.loadPSDFile.data, Radiate.selectedDocument);
			}
		}
		
		public static function mxmlLoadedHandler(event:Event):void {
			if (Radiate.selectedDocument) {
				DocumentManager.openMXMLDocument(mainView.loadMXMLFile.fileName, mainView.loadMXMLFile.dataAsString);
			}
		}
		
		/**
		 * Create a new document with default project for quick mockups
		 * */
		public static function newDocumentAndProjectButton_clickHandler(event:MouseEvent):void {
			
			if (!isCreatingDocument) {
				Radiate.info("Creating a new document");
				DeferManager.callAfter(250, DocumentManager.createNewDocumentAndSwitchToDesignView);
				radiate.addEventListener(RadiateEvent.DOCUMENT_OPEN, documentOpenedHandler, false, 0, true);
				isCreatingDocument = true;
			}
			
		}
		
		public static function goToDesignState(validate:Boolean = true):void {
			ViewManager.goToDesignScreen(validate);
		}
		
		public static function documentOpenedHandler(event:Event):void {
			isCreatingDocument = false;
		}
		
		public static function saveDocumentMenuItem_itemClickHandler(event:MenuEvent):void {
			ViewManager.openExportDocumentWindow();
		}
		
		/**
		 * Update the window menu item
		 * */
		public static function updateWindowMenu(windowItem:MenuItem, nativeMenuItem:Object = null):void {
			var numberOfItems:int = windowItem.children ? windowItem.children.length : 0;
			var menu:Object;
			var menuItem:MenuItem;
			var numberOfDocuments:int;
			var iDocumentData:IDocumentData;
			var menuFound:Boolean;
			var applicationMenusCollection:ListCollectionView;
			var items:Array;
			var numberOfMenus:int;
			var isNativeMenu:Boolean;
			var documents:Array = DocumentManager.documents;
			
			numberOfDocuments = documents.length;
			
			
			if (applicationMenu is Class(MenuItem.NativeMenuDefinition)) {
				var keys:Array = org.as3commons.lang.DictionaryUtils.getKeys(windowMenuDictionary);
				org.as3commons.lang.DictionaryUtils.deleteKeys(windowMenuDictionary, keys);
				items = applicationMenu.items;
				numberOfMenus = items ? items.length : 0;
				isNativeMenu = true;
				return;
			}
			else {
				windowItem.removeAllChildren();
				isNativeMenu = false;
				applicationMenusCollection = applicationMenu ? applicationMenu.dataProvider : ViewManager.mainView.mainMenuBar.dataProvider as ListCollectionView;
				numberOfMenus = applicationMenusCollection ? applicationMenusCollection.length : 0;
				
				for (var j:int; j < numberOfDocuments; j++) {
					iDocumentData = documents[j];
					
					menuItem = new MenuItem();
					menuItem.data = iDocumentData;
					menuItem.type = "radio";//ClassUtils.getQualifiedClassName(iDocumentData);
					menuItem.label = iDocumentData.name;
					
					if (iDocumentData==selectedDocument) {
						windowItem.checked = true;
					}
					else {
						windowItem.checked = false;
					}
					windowItem.addItem(menuItem);
				}
			}
			
			
			for (var i:int; i < numberOfMenus; i++) {
				if (applicationMenusCollection.getItemAt(i)==applicationWindowMenu) {
					applicationMenusCollection.removeItemAt(i);
					applicationMenusCollection.addItemAt(windowItem, i);
					//windowItem.checked = true;
					menuFound = true;
					break;
				}
			}
			
			if (menuFound) {
				windowItem.checked = true;
			}
			else {
				applicationMenusCollection.addItem(windowItem);
			}
			
			applicationMenu.dataProvider = applicationMenusCollection;
			
		}
		
		public static function openGalleryButton_clickHandler(event:MouseEvent):void {
			ViewManager.openGalleryWindow();
		}
		
		public static function cut_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			if (radiate.target) {
				clipboardManager.cutItem(radiate.target, Radiate.selectedDocument);
			}
		}
		
		public static function copy_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			if (radiate.target) {
				clipboardManager.copyItem(radiate.target, Radiate.selectedDocument);
			}				
		}
		
		public static function duplicate_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			if (radiate.target) {
				clipboardManager.duplicateItem(radiate.target, Radiate.selectedDocument);
			}				
		}
		
		public static function paste_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			if (radiate.target) {
				clipboardManager.pasteItem(radiate.target, Radiate.selectedDocument);
			}
		}
		
		public static function delete_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			if (radiate.target) {
				ComponentManager.removeElement(radiate.target);
			}
		}
		
		public static function openGallery_itemClickHandler(event:MenuEvent):void {
			ViewManager.openGalleryWindow();
		}
		
		public static function dropImagesLocation_clickHandler(event:MouseEvent):void
		{
			mainView.dropImagesLocation.visible = false;
			Radiate.info("Drag and drop did not finish apparently.");
		}
		
		public static function closeApplication_eventStartHandler(event:Event):void
		{
			if (Platform.isBrowser) {
				event.preventDefault();
				Radiate.info("The feature is only available in the desktop version");
			}
		}
		
		public static function rotateImage_itemClickHandler(event:MenuEvent):void{
			var angle:Number = 0;
			var eventTarget:Object = event.currentTarget;
			var image:Image = radiate.target as Image;
			
			if (eventTarget==mainView.rotateImage90) {
				angle = 90;
			}
			else if (eventTarget==mainView.rotateImage180) {
				angle = 180;
			}
			else if (eventTarget==mainView.rotateImage270) {
				angle = 270;
			}
			
			ImageManager.rotateImage(image, angle);
		}
		
		public static function flipImage_itemClickHandler(event:MenuEvent):void{
			var eventTarget:Object = event.currentTarget;
			var image:Image = radiate.target as Image;
			
			if (image==null) {
				Radiate.info("You must select an image");
				return;
			}
			
			if (eventTarget==mainView.flipImageHorizontally) {
				ImageManager.flipImageHorizontally(image);
			}
			else if (eventTarget==mainView.flipImageVertically) {
				ImageManager.flipImageVertically(image);
			}
			
		}
		
		public static function lockLayer_itemClickHandler(event:MenuEvent):void {
			var selectedDocument:IDocument = Radiate.selectedDocument;
			var componentDescription:ComponentDescription;
			var collection:ArrayCollection;
			
			if (selectedDocument) {
				componentDescription = selectedDocument.getItemDescription(radiate.target);
				
				if (radiate.target is Application) return;
				
				if (componentDescription) {
					componentDescription.locked = true;
				}
			}
			
		}
		
		public static function unlockLayer_itemClickHandler(event:MenuEvent):void {
			var selectedDocument:IDocument = Radiate.selectedDocument;
			var componentDescription:ComponentDescription;
			var collection:ArrayCollection;
			
			if (selectedDocument) {
				componentDescription = selectedDocument.getItemDescription(radiate.target);
				
				if (componentDescription) {
					componentDescription.locked = false;
				}
			}
			
		}
		
		public static function lockDescendantLayers_itemClickHandler(event:MenuEvent):void {
			var selectedDocument:IDocument = Radiate.selectedDocument;
			var componentDescription:ComponentDescription;
			var collection:ArrayCollection;
			
			if (selectedDocument) {
				componentDescription = selectedDocument.getItemDescription(radiate.target);
				
				if (componentDescription) {
					componentDescription.lockChildDescriptors();
				}
			}
			
		}
		
		public static function unlockDescendantLayers_itemClickHandler(event:MenuEvent):void {
			var selectedDocument:IDocument = Radiate.selectedDocument;
			var componentDescription:ComponentDescription;
			var collection:ArrayCollection;
			
			if (selectedDocument) {
				componentDescription = selectedDocument.getItemDescription(radiate.target);
				
				if (componentDescription) {
					componentDescription.lockChildDescriptors(false);
				}
			}
			
		}
		
		public static function trimImage_itemClickHandler(event:MenuEvent):void {
			var image:Image;
			image = radiate.target as Image;
			
			ImageManager.trimImage(image);
		}
		
		public static function bringForwardLayer_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			ArrangeLayers.bringForwards(radiate.target, Radiate.selectedDocument);
		}
		
		public static function sendBackwardLayer_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			ArrangeLayers.sendBackwards(radiate.target, Radiate.selectedDocument);
		}
		
		public static function bringToFront_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			ArrangeLayers.bringToFront(radiate.target, Radiate.selectedDocument);
		}
		
		public static function sendToBack_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			ArrangeLayers.sendToBack(radiate.target, Radiate.selectedDocument);
		}
		
		
		public static function checkForUpdateMenuItem_itemClickHandler(event:MenuEvent):void
		{
			radiate.checkForUpdate();
		}
		
		public static function selectSelectionTool_itemClickHandler(event:MenuEvent):void {
			var componentDescription:ComponentDescription;
			componentDescription = ToolManager.getToolByName("Selection");
			
			if (componentDescription) {
				ToolManager.setTool(componentDescription.instance as ITool);
			}
		}
		
		public static function getRevisions_itemClickHandler(event:MenuEvent):void {
			var selectedDocument:IDocument = Radiate.selectedDocument;
			
			if (selectedDocument) {
				ViewManager.openImportMXMLWindow("Import MXML", selectedDocument.originalSource, true);
			}
			else {
				Radiate.info("You need to open a document before you can show revisions");
			}
		}
		
		public static function importMXMLMenuItem_itemClickHandler(event:MenuEvent):void
		{
			ViewManager.openImportMXMLWindow("Import MXML");
		}
		
		public static function importSnippetMenuItem_itemClickHandler(event:MenuEvent):void
		{
			ViewManager.openImportMXMLWindow("Import Snippet");
		}
		
		public static function viewInBrowserScreenshot_itemClickHandler(event:MenuEvent):void
		{
			DocumentManager.openInBrowserScreenshot(Radiate.selectedDocument);
		}
		
		public static function viewInSiteScanner_itemClickHandler(event:MenuEvent):void
		{
			DocumentManager.openInBrowserSiteScanner(Radiate.selectedDocument);
		}
		
		public static function menuNewDocument_itemClickHandler(event:MenuEvent):void
		{
			DocumentManager.createNewDocument();
		}
		
		public static function importPSDMenuItem_itemClickHandler(event:MenuEvent):void {
			if (!Radiate.selectedDocument) {
				Radiate.info("Please open a document or project first");
				return;
			}
			
			mainView.browseForPSD.play();
		}
		
		
		public static function loginThroughWebsite_itemClickHandler(event:MenuEvent):void {
			if (ProfileManager.isUserLoggedIn) {
				ProfileManager.loginThroughBrowser();
			}
		}
		
		public static function openProjectButton_clickHandler(event:MouseEvent):void {
			var project:IProject = mainView.projectsList.selectedItem;
			
			if (project==null) {
				project = mainView.examplesList.selectedItem;
			}
			
			if (project) {
				
				Radiate.info("Opening project '" + project.name + "'");
				
				DeferManager.callAfter(250, ProjectManager.openProjectFromMainView, project);
				//openProject(project);
			}
			
		}
		
		public static function saveMenuItem_itemClickHandler(event:MenuEvent):void {
			//Radiate.info("Saved");
			
			if (ProfileManager.isUserLoggedIn==false) {
				Radiate.info("You must be logged in to save");
				return;
			}
			
			if (Radiate.selectedDocument) {
				DocumentManager.saveDocument(Radiate.selectedDocument);
			}
			else {
				Radiate.info("No document is open");
			}
		}
		
		public static function saveAsImageMenuItem_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			
			FileManager.saveAsImage(Radiate.selectedDocument);
		}
		
		public static function saveSelectionAsImageMenuItem_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			
			if (radiate.target) {
				FileManager.saveAsImage(radiate.target);
			}
			else {
				Radiate.info("Nothing is selected");
			}
		}
		
		public static function clearProjectHomePage_itemClickHandler(event:MenuEvent):void {
			var project:IProject = mainView.projectsList.selectedItem;
			
			if (ProfileManager.isUserLoggedIn==false) {
				Radiate.info("You must be logged in");
				return;
			}
			
			if (project==null) {
				project = mainView.examplesList.selectedItem;
			}
			
			Radiate.info("Clearing home page for '" + project.name + "'");
			
			DeferManager.callAfter(250, serviceManager.setProjectHomePage, 0);
			//serviceManager.setProjectHomePage(0);
		}
		
		
		public static function revertDocument():void {
			if (Radiate.checkForDocument()) return;
			
			var success:Boolean = DocumentManager.revertDocument(Radiate.selectedDocument);
			
			if (success) {
				Radiate.info("Document reverted");
			}
			else {
				// revertDocument will display any errors
				//Radiate.info("Document was not reverted");
			}
		}
		
		public static function instantMessengerContainer_clickHandler(event:MouseEvent):void {
			if (mainView.notificationMessenger.isPlaying) {
				mainView.notificationMessenger.end();
				mainView.notificationMessenger.stop();
				mainView.notificationMessenger.play(null, true);
			}
			else {
				//notificationMessenger.play();
				mainView.notificationMessenger.end();
			}
		}
		
		public static function sizeDocumentToOriginalImage_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			
			DocumentManager.sizeDocumentToOriginalImageSize();
		}
		
		public static function sizeDocumentToSelection_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			
			DocumentManager.sizeDocumentToSelection();
		}
		
		public static function sizeSelectionToDocument_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			
			ComponentManager.sizeSelectionToDocument();
		}
		
		public static function resizeDocumentToContent_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			
			DocumentManager.expandDocumentToContents();
		}
		
		public static function copyDocumentImageToClipboard_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			
			if (Platform.isBrowser) {
				ViewManager.showCopyImageToClipboardPanel();
			}
			else {
				DocumentManager.copyDocumentImageToClipboard(Radiate.selectedDocument);
			}
		}
		
		public static function pasteImageFromClipboardToDocument_itemClickHandler(event:MenuEvent):void {
			if (Platform.isBrowser) {
				ViewManager.openPasteImageWindow();
			}
			else {
				ClipboardManager.instance.pasteItem(Radiate.selectedDocument, Radiate.selectedDocument);
			}
		}
		
		public static function saveSnapshotToLibrary_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			
			var imageDataOrError:Object;
			
			// drag manager creates a raster snapshot when on desktop so don't use that
			imageDataOrError = LibraryManager.saveToLibrary(Radiate.selectedDocument.instance, false);
			
			if (imageDataOrError is Error) {
				Radiate.error("Could not create a snapshot of the selected item. " + imageDataOrError); 
			}
			else if (imageDataOrError) {
				
				ViewManager.showLibraryPanel(imageDataOrError as DocumentData, true);
				
				Radiate.info("Selection was saved as an image into the library.");
			}
		}
		
		public static function restoreImageToOriginalSize_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			
			var iDocument:IDocument = Radiate.selectedDocument;
			var componentDescription:ComponentDescription = iDocument ? iDocument.getItemDescription(radiate.target) : null;
			var image:Image = componentDescription ? componentDescription.instance as Image : null;
			var bitmapData:BitmapData = image ? image.bitmapData : null;
			
			if (bitmapData && bitmapData.width>0 && bitmapData.height>0) {
				ImageManager.restoreImageToOriginalSize(image);
			}
		}
		
		public static function removeExplicitPosition_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			
			ComponentManager.removeExplicitPositionFromSelection(radiate.target);
		}
		
		public static function removeExplicitSize_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			
			ComponentManager.removeExplicitSizingFromSelection(radiate.target);
		}
		
		public static function removeExplicitHeight_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			
			ComponentManager.removeExplicitHeightFromSelection(radiate.target);
		}
		
		public static function removeExplicitWidth_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			
			ComponentManager.removeExplicitWidthFromSelection(radiate.target);
		}
		
		public static function refreshView_itemClickHandler(event:MenuEvent):void {
			if (Radiate.checkForDocument()) return;
			
			DocumentManager.refreshDocument(Radiate.selectedDocument);
		}
		
		public static function copySelectionIntoLibrary_itemClickHandler(event:MenuEvent):void {
			var result:Object = LibraryManager.saveToLibrary(radiate.target);
			
			if (result is Error) {
				Radiate.error("Could not create a snapshot of the selected item. " + result); 
			}
			else if (result) {
				Radiate.info("Selection was saved as an image into the library.");
			}
		}
		
		public static function userLabel_clickHandler(event:MouseEvent):void {
			ProfileManager.openUsersLoginPage();
		}
		
		public static function userIcon_clickHandler(event:MouseEvent):void {
			if (ProfileManager.isUserLoggedIn) {
				ProfileManager.openUsersProfile();
			}
			else {
				Radiate.info("You must be logged into to view your profile website");
			}
		}
		
		public static function visitSiteLabel_clickHandler(event:MouseEvent):void{
			ProfileManager.openUsersWebsite();
		}
		
		/**
		 * Open project
		 * */
		public static function openProject_itemClickHandler(event:Event):void {
			ProjectManager.openProject(Radiate.selectedProject);
		}
		
		/**
		 * Open document
		 * */
		public static function openDocument_itemClickHandler(event:Event):void {
			mainView.browseForMXML.play();
		}
		
		/**
		 * Undo last action
		 * */
		public static function undo_itemClickHandler(event:Event):void {
			HistoryManager.undo(Radiate.selectedDocument, true);
		}
		
		/**
		 * Redo last action
		 * */
		public static function redo_itemClickHandler(event:Event):void {
			HistoryManager.redo(Radiate.selectedDocument, true);
		}
		
		/**
		 * Show project string for debugging purposes
		 * */
		public static function showProjectSource_itemClickHandler(event:Event):void {
			var iProject:IProject = Radiate.selectedProject;
			var output:String;
			
			if (iProject) {
				output = "\nSource for project, '" + iProject.name + "':\n";
				output += iProject.post ? JSON.stringify(iProject.post) + "\n" : "";
				output += iProject.toString();
				ViewManager.showConsolePanel(output);
				//Radiate.info();
			}
			else {
				Radiate.warn("No project selected");
			}
		}
		
		/**
		 * Show document string for debugging purposes
		 * */
		public static function showDocumentSource_itemClickHandler(event:Event):void {
			var iDocument:IDocument = Radiate.selectedDocument;
			var output:String;
			
			if (Radiate.checkForDocument()) return;
			
			output = "\nSource for document, '" + iDocument.name + "':\n";
			output += iDocument.post ? JSON.stringify(iDocument.post) + "\n" : "";
			output += iDocument.marshall(DocumentMetaData.STRING_TYPE, true) as String;
			
			ViewManager.showConsolePanel(output);
			
		}
		
		/**
		 * Redispatches on our custom menu items to our menu item models
		 * The models have event listeners that handle the events 
		 * The models expect mx.events.MenuEvent but in a desktop application
		 * we get FlexNativeMenuEvent. So we get an error if we don't use generic events
		 * in the model menu event handlers
		 * 
		 * In this function we are responding to 
		 * - rollover
		 * - rollout
		 * - show
		 * - hide
		 * - click
		 * 
		 * We really only need to handle click. 
		 * so someday we may only respond to that one event 
		 * */
		public static function menuItemEventHandler(event:Event, menuItem:MenuItem = null):void {
			var iDocument:IDocument;
			var item:MenuItem;
			var menu:Object;
			var menuList:Menu;
			var label:String;
			var index:int = -1;
			var flexNativeMenu:Object;
			var menuEvent:MenuEvent;
			var applicableEvent:Boolean;
			
			if (event.type == MenuEvent.MENU_SHOW) {
				menuList = MenuEvent(event).menu as Menu;
				if (menuList.variableRowHeight != true) {
					menuList.rowHeight = 22;
					//menuList.variableRowHeight = true;
				}
			}
			
			if (event) {
				if (event.type==MenuEvent.ITEM_CLICK || event.type=="select") {
					applicableEvent = true;
				}
			}
			
			if (menuItem) {
				item = menuItem;
				label = menuItem.label;
				//index = menuItem.index;
			}
			else {
				menu = "menu" in event ? Object(event).menu : null;
				label = "label" in event ? Object(event).label : null;
				index = "index" in event ? Object(event).index : -1;
				flexNativeMenu = "nativeMenuItem" in event ? Object(event).nativeMenuItem : null;
				item = "item" in event ? Object(event).item : null;
			}
			
			
			if (label && item && applicableEvent) {
				menuEvent = new MenuEvent(MenuEvent.ITEM_CLICK, event.bubbles, event.cancelable);
				menuEvent.index = index;
				menuEvent.item = item;
				menuEvent.label = label;
			}
			
			if (item && menuEvent) {
				EventDispatcher(item).dispatchEvent(menuEvent);
			}
			else if (menu && menu.dataProvider && 
				menu.dataProvider[0] is MenuItem && 
				menu.dataProvider[0].parent is MenuItem) {
				menuEvent = new MenuEvent(event.type, event.bubbles, event.cancelable);
				EventDispatcher(menu.dataProvider[0].parent).dispatchEvent(menuEvent);
			}
			
			if (item && item.data is IDocument && applicableEvent) {
				iDocument = item.data as IDocument;
				
				// we need to deselect other windows in the menu 
				if (iDocument.isOpen) {
					DocumentManager.showDocument(iDocument);
					//Radiate.selectDocument(iDocument);
				}
				
				if (!iDocument.isOpen) {
					DocumentManager.openDocumentByData(iDocument, true);
				}
				
				if (flexNativeMenu) {
					flexNativeMenu.checked = true;
					//radiate.updateWindowMenu(item, nativeMenuItem);
				}
			}
		}
		
		/**
		 * Keyboard shortcuts for menu. Not used at this time. 
		 **/
		public static function keyEquivalentModifiers(item:Object):Array { 
			var result:Array = new Array();
			var menu:Object;
			
			//var keyEquivField:String = menu.keyEquivalentField;
			var keyEquivField:String = menu.keyEquivalentField;
			var altKeyField:String;
			var controlKeyField:String;
			var shiftKeyField:String;
			
			if (item is XML) { 
				altKeyField = "@altKey";
				controlKeyField = "@controlKey";
				shiftKeyField = "@shiftKey";
			}
			else if (item is Object) { 
				altKeyField = "altKey";
				controlKeyField = "controlKey";
				shiftKeyField = "shiftKey";
			}
			
			if (item[keyEquivField] == null || item[keyEquivField].length == 0) { 
				return result;
			}
			
			if (item[altKeyField] != null && item[altKeyField] == true) 
			{
				if (isWin)
				{
					result.push(Keyboard.ALTERNATE); 
				}
			}
			
			if (item[controlKeyField] != null && item[controlKeyField] == true) 
			{
				if (isWin)
				{
					result.push(Keyboard.CONTROL);
				}
				else if (isMac) 
				{
					result.push(Keyboard.COMMAND);
				}
			}
			
			if (item[shiftKeyField] != null && item[shiftKeyField] == true) 
			{
				result.push(Keyboard.SHIFT);
			}
			
			return result;
		}
		
		public static function importImageMenuItem_itemClickHandler(event:MenuEvent):void {
			var fileFilter:FileFilter;
			var filtersString:String;
			var acceptedFileTypes:Array;
			var fileFilterDescription:String;
			var fileFilters:Array;
			
			fileFilters = [];
			fileFilterDescription = "Images";
			acceptedFileTypes = ["png", "jpg", "jpeg", "gif", "psd"];
			
			filtersString = "*." + acceptedFileTypes.join(";*.");
			
			fileFilter = new FileFilter(fileFilterDescription, filtersString);
			fileFilters.push(fileFilter);
			
			try {
				browseForImage = new FileReference();
				browseForImage.browse(fileFilters);
				browseForImage.addEventListener(Event.SELECT, browseForFile_selectHandler, false, 0, true);
			}
			catch (error:Error) {
				
			}
		}
	}
}