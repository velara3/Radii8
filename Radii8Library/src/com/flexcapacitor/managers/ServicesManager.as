
package com.flexcapacitor.managers {
	
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.model.AttachmentData;
	import com.flexcapacitor.model.DocumentData;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IDocumentData;
	import com.flexcapacitor.model.IProject;
	import com.flexcapacitor.model.ImageData;
	import com.flexcapacitor.model.Project;
	import com.flexcapacitor.services.IServiceEvent;
	import com.flexcapacitor.services.WPAttachmentService;
	import com.flexcapacitor.services.WPService;
	import com.flexcapacitor.services.WPServiceEvent;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	
	import spark.collections.Sort;
	import spark.collections.SortField;
	import spark.components.Image;
	import spark.primitives.BitmapImage;

	
	/**
	 * Dispatched when register results are received
	 * */
	[Event(name="registerResults", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched on get project home page event
	 * */
	[Event(name="projectGetHomePage", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched on set project home page event
	 * */
	[Event(name="projectSetHomePage", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when blog posts are received
	 * */
	[Event(name="blogPostsReceived", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Track changes
	 * */
	public class ServicesManager extends EventDispatcher {
		
		
		public function ServicesManager(s:SINGLEDOUBLE) {
			
		}
		
		public static const LOGGED_IN:String = "loggedIn";
		public static const LOGGED_OUT:String = "loggedOut";
		
		
		//----------------------------------
		//  instance
		//----------------------------------
		
		public static function get instance():ServicesManager
		{
			if (!_instance) {
				_instance = new ServicesManager(new SINGLEDOUBLE());
			}
			return _instance;
		}
		
		public static function getInstance():ServicesManager {
			return instance;
		}
		
		private static var _instance:ServicesManager;
		
		/**
		 * Reference to radiate
		 * */
		[Bindable]
		public var radiate:Radiate;
		
		/**
		 * Service to check if user is logged in
		 * */
		public var getLoggedInStatusService:WPService;
		
		/**
		 * Set to true when checking if user is logged in
		 * */
		[Bindable]
		public var getLoggedInStatusInProgress:Boolean;
		
		/**
		 * Upload attachment
		 * */
		public var uploadAttachmentService:WPAttachmentService;
		
		/**
		 * Service to get list of example projects
		 * */
		public var getExampleProjectsService:WPService;
		
		/**
		 * Set to true when getting list of example projects
		 * */
		[Bindable]
		public var getExampleProjectsInProgress:Boolean;
		
		/**
		 * Service to get list of attachments
		 * */
		public var getAttachmentsService:WPService;
		
		/**
		 * Service to get list of projects
		 * */
		public var getProjectsService:WPService;
		
		/**
		 * Service to get list of blog posts
		 * */
		public var getBlogPostsService:WPService;
		
		/**
		 * Service to delete attachment
		 * */
		public var deleteAttachmentService:WPService;
		
		/**
		 * Service to delete document
		 * */
		public var deleteDocumentService:WPService;
		
		/**
		 * Service to delete project
		 * */
		public var deleteProjectService:WPService;
		
		/**
		 * Service to request reset the password
		 * */
		public var lostPasswordService:WPService;
		
		/**
		 * Service to change the password
		 * */
		public var changePasswordService:WPService;
		
		/**
		 * Send feedback
		 * */
		public var sendFeedbackService:URLLoader;
		
		/**
		 * Service to login
		 * */
		public var loginService:WPService;
		
		/**
		 * Service to login through browser
		 * */
		public var loginThroughBrowserService:WPService;
		
		/**
		 * Service to logout
		 * */
		public var logoutService:WPService;
		
		/**
		 * Service to register
		 * */
		public var registerService:WPService;
		
		/**
		 * Get project home page
		 * */
		public var getProjectHomePageService:WPService;
		
		/**
		 * Set project home page
		 * */
		public var setProjectHomePageService:WPService;
		
		/**
		 * Set to true when set project home page is being sent to the server
		 * */
		[Bindable]
		public var setProjectHomePageInProgress:Boolean;
		
		/**
		 * Set to true when get project home page is in progress
		 * */
		[Bindable]
		public var getProjectHomePageInProgress:Boolean;
		
		/**
		 * Set to true when feedback is being sent to the server
		 * */
		[Bindable]
		public var sendFeedbackInProgress:Boolean;
		
		/**
		 * Set to true when a document is being saved to the server
		 * */
		[Bindable]
		public var saveDocumentInProgress:Boolean;
		
		/**
		 * Set to true when project is being saved to the server
		 * */
		[Bindable]
		public var saveProjectInProgress:Boolean;
		
		/**
		 * Set to true when lost password call is made
		 * */
		[Bindable]
		public var lostPasswordInProgress:Boolean;
		
		/**
		 * Set to true when changing password
		 * */
		[Bindable]
		public var changePasswordInProgress:Boolean;
		
		/**
		 * Set to true when registering
		 * */
		[Bindable]
		public var registerInProgress:Boolean;
		
		/**
		 * Set to true when logging in
		 * */
		[Bindable]
		public var loginInProgress:Boolean;
		
		/**
		 * Set to true when logging out
		 * */
		[Bindable]
		public var logoutInProgress:Boolean;
		
		/**
		 * Set to true when deleting a project
		 * */
		[Bindable]
		public var deleteProjectInProgress:Boolean;
		
		/**
		 * Set to true when deleting a document
		 * */
		[Bindable]
		public var deleteDocumentInProgress:Boolean;
		
		/**
		 * Set to true when deleting an attachment
		 * */
		[Bindable]
		public var deleteAttachmentInProgress:Boolean;
		
		/**
		 * Set to true when getting list of attachments
		 * */
		[Bindable]
		public var getAttachmentsInProgress:Boolean;
		
		/**
		 * Set to true when uploading an attachment
		 * */
		[Bindable]
		public var uploadAttachmentInProgress:Boolean;
		
		/**
		 * Set to true when getting list of projects
		 * */
		[Bindable]
		public var getProjectsInProgress:Boolean;
		
		/**
		 * Set to true when getting list of blog posts
		 * */
		[Bindable]
		public var getBlogPostsInProgress:Boolean;
		
		/**
		 * Default storage location for save and load. 
		 * */
		[Bindable]
		public var defaultStorageLocation:String;
		
		/**
		 * Get project home page
		 * @see #setProjectHomePage()
		 * */
		public function getProjectHomePage():void {
			
			// we need to create service
			if (getProjectHomePageService==null) {
				getProjectHomePageService = new WPService();
				getProjectHomePageService.addEventListener(WPService.RESULT, getProjectHomePageResult, false, 0, true);
				getProjectHomePageService.addEventListener(WPService.FAULT, getProjectHomePageFault, false, 0, true);
			}
			
			getProjectHomePageService.host = Radiate.getWPURL();
			
			getProjectHomePageInProgress = true;
			
			getProjectHomePageService.getProjectHomePage();
		}
		
		/**
		 * Handles get project home page result 
		 * */
		protected function getProjectHomePageResult(event:WPServiceEvent):void {
			
			getProjectHomePageInProgress = false;
			
			dispatchGetHomePageEvent(event.data, event);
		}
		
		/**
		 * Handles get project home page fault
		 * */
		protected function getProjectHomePageFault(event:WPServiceEvent):void {
			var data:Object = event.data;
			
			getProjectHomePageInProgress = false;
			
			dispatchGetHomePageEvent(data, event);
		}
		
		/**
		 * Clears the project home page. 
		 * This is a wrapper function.
		 * You can also call setProjectHomePage(0);
		 * Listen to the same events as setProjectHomePage.
		 * 
		 * @see #getProjectHomePage()
		 * @see #setProjectHomePage()
		 * */
		public function clearProjectHomePage():void {
			setProjectHomePage(0);
		}
		
		
		/**
		 * Set project home page. You can unset project home page
		 * by setting the id to 0
		 * 
		 * @param id id of post to set it to
		 * @see #getProjectHomePage()
		 * @see #clearProjectHomePage()
		 * */
		public function setProjectHomePage(id:int):void {
			
			// we need to create service
			if (setProjectHomePageService==null) {
				setProjectHomePageService = new WPService();
				setProjectHomePageService.addEventListener(WPService.RESULT, setProjectHomePageResult, false, 0, true);
				setProjectHomePageService.addEventListener(WPService.FAULT, setProjectHomePageFault, false, 0, true);
			}
			
			setProjectHomePageInProgress = true;
			
			setProjectHomePageService.host = Radiate.getWPURL();
			
			setProjectHomePageService.setProjectHomePage(id);
		}
		
		/**
		 * Handles set project home page result 
		 * */
		protected function setProjectHomePageResult(event:WPServiceEvent):void {
			var data:Object = event.data;
			
			setProjectHomePageInProgress = false;
			
			dispatchSetHomePageEvent(data, event);
		}
		
		/**
		 * Handle set project home page fault
		 * */
		protected function setProjectHomePageFault(event:WPServiceEvent):void {
			var data:Object = event.data;
			
			setProjectHomePageInProgress = false;
			
			dispatchSetHomePageEvent(data, event);
		}
		
		/**
		 * Get logged in status
		 * */
		public function getLoggedInStatus():void {
			// get selected document
			
			// we need to create service
			if (getLoggedInStatusService==null) {
				getLoggedInStatusService = new WPService();
				getLoggedInStatusService.addEventListener(WPService.RESULT, getLoggedInStatusResult, false, 0, true);
				getLoggedInStatusService.addEventListener(WPService.FAULT, getLoggedInStatusFault, false, 0, true);
			}
			
			getLoggedInStatusService.host = Radiate.getWPURL();
			
			getLoggedInStatusInProgress = true;
			
			getLoggedInStatusService.getLoggedInUser();
		}
		
		/**
		 * Handles result to check if user is logged in 
		 * */
		protected function getLoggedInStatusResult(event:WPServiceEvent):void {
			var data:Object = event.data;
			
			if (event.hasError) {
				ProfileManager.isUserConnected = false;
			}
			else {
				ProfileManager.isUserConnected = true;
			}
			
			ProfileManager.updateUserInfo(data);
			
			getLoggedInStatusInProgress = false;
			
			dispatchLoginStatusEvent(ProfileManager.isUserLoggedIn, data, event);
		}
		
		/**
		 * Handles fault when checking if user is logged in
		 * */
		protected function getLoggedInStatusFault(event:WPServiceEvent):void {
			var data:Object = event.data;
			ProfileManager.isUserConnected = false;
			//isUserLoggedIn = false;
			
			getLoggedInStatusInProgress = false;
			
			dispatchLoginStatusEvent(ProfileManager.isUserLoggedIn, data, event);
		}
		
		/**
		 * Get example projects
		 * */
		public function getExampleProjects(status:String = WPService.STATUS_ANY, locations:String = null, count:int = 100):void {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			if (status==null) status = WPService.STATUS_ANY;
			var loadLocally:Boolean = getIsLocalLocation(locations);
			var loadRemote:Boolean = getIsRemoteLocation(locations);
			
			
			if (loadRemote) {
				// we need to create service
				if (getExampleProjectsService==null) {
					getExampleProjectsService = new WPService();
					getExampleProjectsService.addEventListener(WPService.RESULT, getExampleProjectsResultsHandler, false, 0, true);
					getExampleProjectsService.addEventListener(WPService.FAULT, getExampleProjectsFaultHandler, false, 0, true);
				}
				
				getExampleProjectsInProgress = true;
				
				getExampleProjectsService.host = Radiate.getExamplesWPURL();
				
				getExampleProjectsService.getProjects(WPService.STATUS_PUBLISH, count);
				
			}
			
			if (loadLocally) {
				
			}
		}
		
		/**
		 * Get news projects
		 * */
		public function getNewsPosts(category:String = "Tutorial", status:String = WPService.STATUS_ANY, locations:String = null, count:int = 100):void {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var loadLocally:Boolean = getIsLocalLocation(locations);
			var loadRemote:Boolean = getIsRemoteLocation(locations);
			
			
			if (loadRemote) {
				// we need to create service
				if (getBlogPostsService==null) {
					getBlogPostsService = new WPService();
					getBlogPostsService.addEventListener(WPService.RESULT, getBlogPostsResultsHandler, false, 0, true);
					getBlogPostsService.addEventListener(WPService.FAULT, getBlogPostsFaultHandler, false, 0, true);
				}
				
				getBlogPostsInProgress = true;
				
				getBlogPostsService.host = Radiate.getNewsWPURL();
				
				getBlogPostsService.getPostsByCategory(category, count);
			}
			
			if (loadLocally) {
				
			}
		}
		
		/**
		 * Get blog posts by category
		 * */
		public function getBlogPostsByCategory(category:String, status:String = WPService.STATUS_ANY, locations:String = null, count:int = 100):void {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var loadLocally:Boolean = getIsLocalLocation(locations);
			var loadRemote:Boolean = getIsRemoteLocation(locations);
			
			
			if (loadRemote) {
				// we need to create service
				if (getBlogPostsService==null) {
					getBlogPostsService = new WPService();
					getBlogPostsService.addEventListener(WPService.RESULT, getBlogPostsResultsHandler, false, 0, true);
					getBlogPostsService.addEventListener(WPService.FAULT, getBlogPostsFaultHandler, false, 0, true);
				}
				
				getBlogPostsInProgress = true;
				
				getBlogPostsService.host = Radiate.getWPURL();
				
				getBlogPostsService.getPostsByCategory(category, count);
			}
			
			if (loadLocally) {
				
			}
		}
		
		/**
		 * Get projects 
		 * */
		public function getProjects(status:String = WPService.STATUS_ANY, locations:String = null, count:int = 100):void {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var loadLocally:Boolean = getIsLocalLocation(locations);
			var loadRemote:Boolean = getIsRemoteLocation(locations);
			
			
			if (loadRemote) {
				// we need to create service
				if (getProjectsService==null) {
					getProjectsService = new WPService();
					getProjectsService = new WPService();
					getProjectsService.addEventListener(WPService.RESULT, getProjectsResultsHandler, false, 0, true);
					getProjectsService.addEventListener(WPService.FAULT, getProjectsFaultHandler, false, 0, true);
				}
				
				getProjectsInProgress = true;
				
				getProjectsService.host = Radiate.getWPURL();
				
				getProjectsService.getProjects(status, count);
			}
			
			if (loadLocally) {
				
			}
		}
		
		/**
		 * Get projects by user ID
		 * */
		public function getProjectsByUser(id:int, status:String = WPService.STATUS_ANY, locations:String = null, count:int = 100):void {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			if (status==null) status = WPService.STATUS_ANY;
			var loadLocally:Boolean = getIsLocalLocation(locations);
			var loadRemote:Boolean = getIsRemoteLocation(locations);
			
			
			if (loadRemote) {
				// we need to create service
				if (getProjectsService==null) {
					getProjectsService = new WPService();
					getProjectsService.addEventListener(WPService.RESULT, getProjectsResultsHandler, false, 0, true);
					getProjectsService.addEventListener(WPService.FAULT, getProjectsFaultHandler, false, 0, true);
				}
				
				getProjectsInProgress = true;
				
				getProjectsService.host = Radiate.getWPURL();
				
				getProjectsService.getProjectsByUser(id, status, count);
				
			}
			
			if (loadLocally) {
				
			}
		}
		
		/**
		 * Send feedback
		 * */
		public function sendFeedback(message:Object):void {
			
			// we need to create service
			if (sendFeedbackService==null) {
				sendFeedbackService = new URLLoader();
				sendFeedbackService.dataFormat = URLLoaderDataFormat.TEXT;
				sendFeedbackService.addEventListener(Event.COMPLETE, sendFeedbackHandler, false, 0, true);
				sendFeedbackService.addEventListener(SecurityErrorEvent.SECURITY_ERROR, sendFeedbackHandler, false, 0, true);
				sendFeedbackService.addEventListener(IOErrorEvent.IO_ERROR, sendFeedbackHandler, false, 0, true);
			}
			
			var request:URLRequest = new URLRequest(Radiate.CONTACT_FORM_URL);
			request.data = message;
			request.method = URLRequestMethod.POST;
			
			sendFeedbackInProgress = true;
			
			sendFeedbackService.load(request);
			
		}
		
		
		/**
		 * Login user 
		 * */
		public function login(username:String, password:String):void {
			
			// we need to create service
			if (loginService==null) {
				loginService = new WPService();
				loginService.addEventListener(WPService.RESULT, loginResultsHandler, false, 0, true);
				loginService.addEventListener(WPService.FAULT, loginFaultHandler, false, 0, true);
			}
			
			loginInProgress = true;
				
			loginService.host = Radiate.getWPURL();
			
			loginService.loginUser(username, password);
			
		}
		
		
		
		/**
		 * Login user through browser. Doesn't work. 
		 * */
		public function loginThroughBrowser(username:String, password:String, remember:Boolean = false, window:String = null):void {
			var useNavigate:Boolean = true;
			
			// we need to create service
			if (loginThroughBrowserService==null) {
				loginThroughBrowserService = new WPService();
			}
			
			if (useNavigate) {
				var url:String = Radiate.getWPURL() + "?json=" + loginThroughBrowserService.loginUserURL;
				var variables:URLVariables = new URLVariables();
				variables.log = encodeURIComponent(username);
				variables.pwd = encodeURIComponent(password);
				variables.rememberme = remember;
				
				var request:URLRequest = new URLRequest(url);
				request.contentType = "application/x-www-form-urlencoded";
				request.data = variables;
				request.method = URLRequestMethod.POST;
				
				navigateToURL(request, window);
				return;
			}
			
			
			loginThroughBrowserService.useNavigateToURL = true;
			loginThroughBrowserService.windowName = window;
			
			//var rhArray:Array = new Array(new URLRequestHeader("Content-Type", "text/html"));
			// request.requestHeaders
			// request.contentType = "application/x-www-form-urlencoded";
			
			loginThroughBrowserService.host = Radiate.getWPURL();
			
			loginThroughBrowserService.loginUser(username, password);
			
		}
		
		/**
		 * Logout user 
		 * */
		public function logout():void {
			
			// we need to create service
			if (logoutService==null) {
				logoutService = new WPService();
				logoutService.addEventListener(WPService.RESULT, logoutResultsHandler, false, 0, true);
				logoutService.addEventListener(WPService.FAULT, logoutFaultHandler, false, 0, true);
			}
			
			logoutInProgress = true;
			
			logoutService.host = Radiate.getWPURL();
			
			logoutService.logoutUser();
			
		}
		
		/**
		 * Register user 
		 * */
		public function register(username:String, email:String):void {
			
			// we need to create service
			if (registerService==null) {
				registerService = new WPService();
				registerService.addEventListener(WPService.RESULT, registerResultsHandler, false, 0, true);
				registerService.addEventListener(WPService.FAULT, registerFaultHandler, false, 0, true);
			}
			
			registerInProgress = true;
			
			registerService.host = Radiate.getWPURL();
			
			registerService.registerUser(username, email);
			
		}
		
		/**
		 * Register site 
		 * */
		public function registerSite(blogName:String = "", blogTitle:String = "", isPublic:Boolean = false):void {
			
			// we need to create service
			if (registerService==null) {
				registerService = new WPService();
				registerService.addEventListener(WPService.RESULT, registerResultsHandler, false, 0, true);
				registerService.addEventListener(WPService.FAULT, registerFaultHandler, false, 0, true);
			}
			
			registerService.host = Radiate.getWPURL();
			
			registerInProgress = true;
			
			registerService.registerSite(blogName, blogTitle, isPublic);
			
		}
		
		/**
		 * Register user and site 
		 * */
		public function registerUserAndSite(username:String, email:String, siteName:String = "", blogTitle:String = "", isPublic:Boolean = false, requireSiteName:Boolean = false):void {
			
			// we need to create service
			if (registerService==null) {
				registerService = new WPService();
				registerService.addEventListener(WPService.RESULT, registerResultsHandler, false, 0, true);
				registerService.addEventListener(WPService.FAULT, registerFaultHandler, false, 0, true);
			}
			
			registerService.host = Radiate.getWPURL();
			
			registerInProgress = true;
			
			if (!requireSiteName) {
				if (siteName=="") {
					siteName = username;
				}
				
				if (blogTitle=="") {
					blogTitle = "A Radiate site";
				}
			}
			
			registerService.registerUserAndSite(username, email, siteName, blogTitle, isPublic);
			
		}
		
		/**
		 * Request lost password. Sends an email with instructions. 
		 * @param username or email address
		 * */
		public function lostPassword(usernameOrEmail:String):void {
			
			// we need to create service
			if (lostPasswordService==null) {
				lostPasswordService = new WPService();
				lostPasswordService.addEventListener(WPService.RESULT, lostPasswordResultsHandler, false, 0, true);
				lostPasswordService.addEventListener(WPService.FAULT, lostPasswordFaultHandler, false, 0, true);
			}
			
			lostPasswordInProgress = true;
				
			lostPasswordService.host = Radiate.getWPURL();
			
			lostPasswordService.lostPassword(usernameOrEmail);
			
		}
		
		/**
		 * Reset or change password
		 * */
		public function changePassword(key:String, username:String, password:String, password2:String):void {
			
			// we need to create service
			if (changePasswordService==null) {
				changePasswordService = new WPService();
				changePasswordService.addEventListener(WPService.RESULT, changePasswordResultsHandler, false, 0, true);
				changePasswordService.addEventListener(WPService.FAULT, changePasswordFaultHandler, false, 0, true);
			}
			
			changePasswordInProgress = true;
				
			changePasswordService.host = Radiate.getWPURL();
			
			changePasswordService.resetPassword(key, username, password, password2);
			
		}
		
		/**
		 * Get images from the server
		 * */
		public function getAttachments(id:int = 0):void {
			// get selected document
			
			// we need to create service
			if (getAttachmentsService==null) {
				getAttachmentsService = new WPService();
				getAttachmentsService.addEventListener(WPService.RESULT, getAttachmentsResultsHandler, false, 0, true);
				getAttachmentsService.addEventListener(WPService.FAULT, getAttachmentsFaultHandler, false, 0, true);
			}
			
			getAttachmentsInProgress = true;
			
			if (id!=0) {
				getAttachmentsService.id = String(id);
			}
			
			getAttachmentsService.host = Radiate.getWPURL();
			
			
			getAttachmentsService.getAttachments(id);
		}
		
		/**
		 * Upload image to the server
		 * */
		public function uploadAttachment(data:Object, id:String, fileName:String = null, dataField:String = null, contentType:String = null):void {
			// get selected document
			
			// we need to create service
			if (uploadAttachmentService==null) {
				uploadAttachmentService = new WPAttachmentService();
				uploadAttachmentService.addEventListener(WPService.RESULT, uploadAttachmentResultsHandler, false, 0, true);
				uploadAttachmentService.addEventListener(WPService.FAULT, uploadAttachmentFaultHandler, false, 0, true);
				//uploadAttachmentService = service;
			}
			
			uploadAttachmentService.host = Radiate.getWPURL();
		
			if (id!=null) {
				uploadAttachmentService.id = id;
			}
			
			uploadAttachmentInProgress = true;
			
			if (data is FileReference) {
				uploadAttachmentService.file = data as FileReference;
				uploadAttachmentService.uploadAttachment();
			}
			else if (data) {
				uploadAttachmentService.fileData = data as ByteArray;
				
				if (fileName) {
					uploadAttachmentService.fileName = fileName;
				}
				
				if (dataField) {
					uploadAttachmentService.dataField = dataField;
				}
				
				if (contentType) {
					uploadAttachmentService.contentType = contentType;
				}
				
				uploadAttachmentService.uploadAttachment();
			}
			else {
				Radiate.warn("No data or file is available for upload. Please select the file to upload.");
			}
			
		}
		
		
		/*********************************************************/
		
		
		/**
		 * Add an asset
		 * */
		public function addAssets(data:Array, dispatchEvents:Boolean = true):void {
			var length:int;
			var added:Boolean;
			
			if (data) {
				length = data.length;
				
				for (var i:int;i<length;i++) {
					addAsset(data[i], dispatchEvents);
				}
				
			}
			
		}
		
		/**
		 * Add an asset
		 * */
		public function addAsset(data:DocumentData, dispatchEvent:Boolean = true):void {
			var assets:ArrayCollection = LibraryManager.assets;
			var numberOfAssets:int = assets.length;
			var found:Boolean;
			var item:DocumentData;
			
			for (var i:int;i<numberOfAssets;i++) {
				item = assets.getItemAt(i) as DocumentData;
				
				if (item.id==data.id && item.id!=null) {
					found = true;
					break;
				}
			}
			
			if (!found) {
				assets.addItem(data);
			}
			
			if (!found && dispatchEvent) {
				dispatchAssetAddedEvent(data);
			}
		}
		
		/**
		 * Remove an asset
		 * */
		public function removeAsset(iDocumentData:IDocumentData, locations:String = null, dispatchEvents:Boolean = true):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var remote:Boolean = getIsRemoteLocation(locations);
			var assets:ArrayCollection = LibraryManager.assets;
			var index:int = assets.getItemIndex(iDocumentData);
			var removedInternally:Boolean;
			
			if (index!=-1) {
				assets.removeItemAt(index);
				removedInternally = true;
			}
			
			if (remote && iDocumentData && iDocumentData.id) { 
				// we need to create service
				if (deleteAttachmentService==null) {
					deleteAttachmentService = new WPService();
					deleteAttachmentService.addEventListener(WPService.RESULT, deleteDocumentResultsHandler, false, 0, true);
					deleteAttachmentService.addEventListener(WPService.FAULT, deleteDocumentFaultHandler, false, 0, true);
				}
				
				deleteAttachmentService.host = Radiate.getWPURL();
				
				deleteDocumentInProgress = true;
				
				deleteAttachmentService.deleteAttachment(int(iDocumentData.id), true);
			}
			
			dispatchAssetRemovedEvent(iDocumentData, removedInternally);
			
			return removedInternally;
		}
		
		//----------------------------------
		//
		//  EVENT HANDLERS
		// 
		//----------------------------------
		
		
		/**
		 * Project opened result handler
		 * */
		public function projectOpenResultHandler(event:Event):void {
			var iProject:IProject = event.currentTarget as IProject;
			
			// add assets
			addAssets(iProject.assets);
			
			if (iProject is EventDispatcher) {
				EventDispatcher(iProject).removeEventListener(Project.PROJECT_OPENED, projectOpenResultHandler);
			}
			
			Radiate.dispatchProjectOpenedEvent(iProject);
		}
		
		/**
		 * Results from call to get projects
		 * */
		public function getProjectsResultsHandler(event:IServiceEvent):void {
			
			//Radiate.info("Retrieved list of projects");
			
			var data:Object = event.data;
			
			getProjectsInProgress = false;
			
			dispatchGetProjectsListResultsEvent(data, event);
		}
		
		/**
		 * Results from call to get blog posts
		 * */
		public function getBlogPostsResultsHandler(event:IServiceEvent):void {
			
			//Radiate.info("Retrieved list of projects");
			
			var data:Object = event.data;
			
			if (event.hasError) {
				
			}
			
			getBlogPostsInProgress = false;
			
			dispatchGetBlogPostsResultsEvent(data, event);
		}
		
		/**
		 * Results from call to get projects
		 * */
		public function getExampleProjectsResultsHandler(event:IServiceEvent):void {
			
			//Radiate.info("Retrieved list of projects");
			
			var data:Object = event.data;
			
			getExampleProjectsInProgress = false;
			
			dispatchGetExampleProjectsListResultsEvent(data, event);
		}
		
		/**
		 * Result example projects fault
		 * */
		public function getExampleProjectsFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			//Radiate.info("Could not get list of example projects");
			
			getExampleProjectsInProgress = false;
			
			dispatchGetExampleProjectsListResultsEvent(data, event);
		}
		
		/**
		 * Result from get projects fault
		 * */
		public function getProjectsFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			//Radiate.info("Could not get list of projects");
			
			getProjectsInProgress = false;
			
			dispatchGetProjectsListResultsEvent(data, event);
		}
		
		/**
		 * Result from get blog posts fault
		 * */
		public function getBlogPostsFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			//Radiate.info("Could not get list of blog posts. Check to make sure you are online. ");
			
			getBlogPostsInProgress = false;
			
			dispatchGetBlogPostsResultsEvent(data, event);
		}
		
		/**
		 * Result get attachments
		 * */
		public function getAttachmentsResultsHandler(event:IServiceEvent):void {
			//Radiate.info("Retrieved list of attachments");
			var data:Object = event.data;
			var potentialAttachments:Array = [];
			var length:int;
			var object:Object;
			var attachment:AttachmentData;
			
			if (data && data.count>0) {
				length = data.count;
				
				for (var i:int;i<length;i++) {
					object = data.attachments[i];
					
					if (String(object.mime_type).indexOf("image/")!=-1) {
						attachment = new ImageData();
						attachment.unmarshall(object);
					}
					else {
						attachment = new AttachmentData();
						attachment.unmarshall(object);
					}
					
					potentialAttachments.push(attachment);
				}
			}
			
			getAttachmentsInProgress = false;
			
			LibraryManager.attachments = potentialAttachments;
			
			dispatchAttachmentsResultsEvent(true, LibraryManager.attachments, event);
		}
		
		/**
		 * Result from attachments fault
		 * */
		public function getAttachmentsFaultHandler(event:IServiceEvent):void {
			//Radiate.info("Could not get list of attachments. Check to make sure you are online.");
			
			getAttachmentsInProgress = false;
			
			//dispatchEvent(saveResultsEvent);
			dispatchAttachmentsResultsEvent(false, null, event);
		}
		
		/**
		 * Result upload attachment
		 * */
		public function uploadAttachmentResultsHandler(event:IServiceEvent):void {
			//Radiate.info("Upload attachment");
			var data:Object = event.data;
			var potentialAttachments:Array = [];
			var successful:Boolean;
			var length:int;
			var object:Object;
			var attachment:AttachmentData;
			var asset:AttachmentData;
			var remoteAttachments:Array;
			var containsName:Boolean;
			var numberOfAssets:int;
			var assetsCollection:ArrayCollection;
			
			successful = data && data.status && data.status=="ok" ? true : false;
			remoteAttachments = data && data.post && data.post.attachments ? data.post.attachments : []; 
			
			if (remoteAttachments.length>0) {
				length = remoteAttachments.length;
				
				for (var i:int;i<length;i++) {
					object = remoteAttachments[i];
					
					if (String(object.mime_type).indexOf("image/")!=-1) {
						attachment = new ImageData();
						attachment.unmarshall(object);
					}
					else {
						attachment = new AttachmentData();
						attachment.unmarshall(object);
					}
					
					potentialAttachments.push(attachment);
					
					//attachments = potentialAttachments;
					assetsCollection = LibraryManager.assets;
					numberOfAssets = assetsCollection.length;
					
					j = 0;
					
					for (var j:int;j<numberOfAssets;j++) {
						asset = assetsCollection.getItemAt(j) as AttachmentData;
						containsName = asset ? asset.name.indexOf(attachment.name)==0 : false;
						
						// this is not very robust but since uploading only supports one at a time 
						// it should be fine. when supporting multiple uploading, keep
						// track of items being uploaded
						if (containsName && asset.id==null) {
							asset.unmarshall(attachment);
							
							var numberOfDocuments:int = DocumentManager.documents.length;
							k = 0;
							
							for (var k:int;k<numberOfDocuments;k++) {
								var iDocument:IDocument = DocumentManager.documents[k] as IDocument;
								
								if (iDocument) {
									DisplayObjectUtils.walkDownComponentTree(iDocument.componentDescription, replaceBitmapData, [asset]);
								}
							}
							
							break;
						}
					}
				}
			}
			
			
			uploadAttachmentInProgress = false;
			
			dispatchUploadAttachmentResultsEvent(successful, potentialAttachments, data.post, event);
		}
		
		/**
		 * Replaces occurances where the bitmapData in Image and BitmapImage have
		 * been uploaded to the server and we now want to point the image to a URL
		 * rather than bitmap data
		 * */
		public function replaceBitmapData(component:ComponentDescription, imageData:ImageData):void {
			var instance:Object;
			
			if (imageData && component && component.instance) {
				instance = component.instance;
				
				if (instance is Image || instance is BitmapImage) {
					if (instance.source == imageData.bitmapData) {
						ComponentManager.setProperty(instance, "source", imageData.url);
					}
				}
			}
		}
		
		/**
		 * Result from upload attachment fault
		 * */
		public function uploadAttachmentFaultHandler(event:IServiceEvent):void {
			Radiate.info("Upload attachment fault");
			
			uploadAttachmentInProgress = false;
			
			//dispatchEvent(saveResultsEvent);
			dispatchUploadAttachmentResultsEvent(false, null, event.data, event);
		}
		
		/**
		 * Feedback form results handler
		 * */
		public function sendFeedbackHandler(event:Object):void {
			//Radiate.info("Feedback results");
			var type:String = event.type;
			var data:Object;
			var successful:Boolean;
			var success:String = "Mail sent";
			var loader:URLLoader;
			
			if (type==Event.COMPLETE) {
				loader = event.currentTarget as URLLoader;
				data = loader.data;
				
				if (data && String(data).toLowerCase().indexOf("Mail sent")!=-1) {
					successful = data.success==true;
				}
			}
			
			sendFeedbackInProgress = false;
			
			
			dispatchFeedbackResultsEvent(successful, data, event);
		}
		
		/**
		 * Login results handler
		 * */
		public function loginResultsHandler(event:IServiceEvent):void {
			//Radiate.info("Login results");
			var data:Object = event.data;
			var loggedIn:Boolean;
			
			if (data && data is Object) {
				
				loggedIn = data.loggedIn==true;
				
				ProfileManager.updateUserInfo(data);
			}
			
			loginInProgress = false;
			
			
			dispatchLoginResultsEvent(loggedIn, data, event);
		}
		
		/**
		 * Result from login fault
		 * */
		public function loginFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.info("Could not connect to the server to login. Check to make sure you are online.");
			
			loginInProgress = false;
			
			dispatchLoginResultsEvent(false, data, event);
		}
		
		/**
		 * Logout results handler
		 * */
		public function logoutResultsHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			var loggedOut:Boolean;
			
			if (data && data is Object) {
				
				loggedOut = data.loggedIn==false;
				
				ProfileManager.updateUserInfo(data);
			}
			
			logoutInProgress = false;
			
			
			dispatchLogoutResultsEvent(loggedOut, data, event);
		}
		
		/**
		 * Result from logout fault
		 * */
		public function logoutFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.info("Could not connect to the server to logout. Check to make sure you are online.");
			
			logoutInProgress = false;
			
			dispatchLogoutResultsEvent(false, data, event);
		}
		
		/**
		 * Register results handler
		 * */
		public function registerResultsHandler(event:IServiceEvent):void {
			//Radiate.info("Register results");
			var data:Object = event.data;
			var successful:Boolean;
			
			if (data && data is Object && "created" in data) {
				
				successful = data.created;
				
			}
			
			registerInProgress = false;
			
			
			dispatchRegisterResultsEvent(successful, data, event);
		}
		
		/**
		 * Result from register fault
		 * */
		public function registerFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.info("Could not connect to the server to register. Check to make sure you are online.");
			
			registerInProgress = false;
			
			dispatchRegisterResultsEvent(false, data, event);
		}
		
		/**
		 * Register results handler
		 * */
		public function changePasswordResultsHandler(event:IServiceEvent):void {
			//Radiate.info("Change password results");
			var data:Object = event.data;
			var successful:Boolean;
			
			if (data && data is Object && "created" in data) {
				
				successful = data.created;
				
			}
			
			changePasswordInProgress = false;
			
			
			dispatchChangePasswordResultsEvent(successful, data, event);
		}
		
		/**
		 * Result from change password fault
		 * */
		public function changePasswordFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.info("Could not connect to the server. Check to make sure you are online. " + event.faultEvent.toString());
			
			changePasswordInProgress = false;
			
			dispatchChangePasswordResultsEvent(false, data, event);
		}
		
		/**
		 * Lost password results handler
		 * */
		public function lostPasswordResultsHandler(event:IServiceEvent):void {
			//Radiate.info("Change password results");
			var data:Object = event.data;
			var successful:Boolean;
			
			if (data && data is Object && "created" in data) {
				successful = data.created;
			}
			
			lostPasswordInProgress = false;
			
			
			dispatchLostPasswordResultsEvent(successful, data, event);
		}
		
		/**
		 * Result from lost password fault
		 * */
		public function lostPasswordFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.info("Could not connect to the server. Check to make sure you are online. " + event.faultEvent.toString());
			
			lostPasswordInProgress = false;
			
			dispatchLostPasswordResultsEvent(false, data, event);
		}
		
		/**
		 * Delete project results handler
		 * */
		public function deleteProjectResultsHandler(event:IServiceEvent):void {
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
			
			dispatchProjectDeletedEvent(successful, data, event);
		}
		
		/**
		 * Result from delete project fault
		 * */
		public function deleteProjectFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.info("Could not connect to the server to delete the project. Check to make sure you are online.");
			
			deleteProjectInProgress = false;
			
			dispatchProjectDeletedEvent(false, data, event);
		}
		
		/**
		 * Delete document results handler
		 * */
		public function deleteDocumentResultsHandler(event:IServiceEvent):void {
			//..Radiate.info("Delete document results");
			var data:Object = event.data;
			//var status:Boolean;
			var successful:Boolean;
			var error:String;
			var message:String;
			
			
			if (data && data is Object && "status" in data) {
				successful = data.status!="error";
			}
			
			deleteDocumentInProgress = false;
			deleteAttachmentInProgress = false;
			
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
			
			//status = message;
			
			//dispatchDocumentRemovedEvent(null);
			
			dispatchDocumentDeletedEvent(successful, data, event);
		}
		
		/**
		 * Result from delete project fault
		 * */
		public function deleteDocumentFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.info("Could not connect to the server to delete the document. Check to make sure you are online.");
			
			deleteDocumentInProgress = false;
			
			dispatchDocumentDeletedEvent(false, data, event);
		}

		
		//----------------------------------
		//
		//  DISPATCHING EVENTS
		// 
		//----------------------------------
		
		
		/**
		 * Dispatch example projects list received results event
		 * */
		public function dispatchGetExampleProjectsListResultsEvent(data:Object, event:IServiceEvent):void {
			var projectsListResultEvent:RadiateEvent = new RadiateEvent(RadiateEvent.EXAMPLE_PROJECTS_LIST_RECEIVED);
			
			if (hasEventListener(RadiateEvent.EXAMPLE_PROJECTS_LIST_RECEIVED)) {
				projectsListResultEvent.data = data;
				projectsListResultEvent.successful = event.successful;
				projectsListResultEvent.serviceEvent = event;
				dispatchEvent(projectsListResultEvent);
			}
		}
		
		/**
		 * Dispatch projects list received results event
		 * */
		public function dispatchGetProjectsListResultsEvent(data:Object, event:IServiceEvent):void {
			var projectsListResultEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROJECTS_LIST_RECEIVED);
			
			if (hasEventListener(RadiateEvent.PROJECTS_LIST_RECEIVED)) {
				projectsListResultEvent.data = data;
				projectsListResultEvent.successful = event.successful;
				projectsListResultEvent.serviceEvent = event;
				dispatchEvent(projectsListResultEvent);
			}
		}
		
		/**
		 * Dispatch blog posts received results event
		 * */
		public function dispatchGetBlogPostsResultsEvent(data:Object, event:IServiceEvent):void {
			var blogPostsResultEvent:RadiateEvent = new RadiateEvent(RadiateEvent.BLOG_POSTS_RECEIVED);
			
			if (hasEventListener(RadiateEvent.BLOG_POSTS_RECEIVED)) {
				blogPostsResultEvent.data = data;
				blogPostsResultEvent.successful = event.successful;
				blogPostsResultEvent.serviceEvent = event;
				dispatchEvent(blogPostsResultEvent);
			}
		}
		
		/**
		 * Parses data into an array of usable objects 
		 * Should be in a ServicesManager class?
		 * */
		public function parsePostsData(data:Object):Array {
			var numberOfPosts:int;
			var post:Object;
			var xml:XML;
			var isValid:Boolean;
			var source:String;
			var posts:Array = [];
			
			numberOfPosts = data && data is Object && !(data is String) ? data.count : 0;
			
			for (var i:int;i<numberOfPosts;i++) {
				post = data.posts[i];
				posts.push(post);
			}
			
			var sort:Sort = new Sort();
			var sortField:SortField = new SortField("dateSaved");
			sort.fields = [sortField];
			
			return posts;
		}
		
		/**
		 * Dispatch attachments received event
		 * */
		public function dispatchLoginStatusEvent(loggedIn:Boolean, data:Object, event:IServiceEvent):void {
			var loggedInStatusEvent:RadiateEvent = new RadiateEvent(RadiateEvent.LOGGED_IN_STATUS);
			
			if (hasEventListener(RadiateEvent.LOGGED_IN_STATUS)) {
				loggedInStatusEvent.status = loggedIn ? LOGGED_IN : LOGGED_OUT;
				loggedInStatusEvent.data = data;
				loggedInStatusEvent.serviceEvent = event;
				dispatchEvent(loggedInStatusEvent);
			}
		}
		
		/**
		 * Dispatch get home page received event
		 * */
		public function dispatchGetHomePageEvent(data:Object, event:IServiceEvent):void {
			var getHomePageEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROJECT_GET_HOME_PAGE);
			
			if (hasEventListener(RadiateEvent.PROJECT_GET_HOME_PAGE)) {
				getHomePageEvent.data = data;
				getHomePageEvent.serviceEvent = event;
				dispatchEvent(getHomePageEvent);
			}
		}
		
		/**
		 * Dispatch set home page received event
		 * */
		public function dispatchSetHomePageEvent(data:Object, event:IServiceEvent):void {
			var setHomePageEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROJECT_SET_HOME_PAGE);
			
			if (hasEventListener(RadiateEvent.PROJECT_SET_HOME_PAGE)) {
				setHomePageEvent.data = data;
				setHomePageEvent.serviceEvent = event;
				dispatchEvent(setHomePageEvent);
			}
		}
		
		/**
		 * Dispatch attachments received event
		 * */
		public function dispatchAttachmentsResultsEvent(successful:Boolean, attachments:Array, event:IServiceEvent):void {
			var attachmentsReceivedEvent:RadiateEvent = new RadiateEvent(RadiateEvent.ATTACHMENTS_RECEIVED, false, false, attachments);
			
			if (hasEventListener(RadiateEvent.ATTACHMENTS_RECEIVED)) {
				attachmentsReceivedEvent.successful = successful;
				attachmentsReceivedEvent.status = successful ? "ok" : "fault";
				attachmentsReceivedEvent.targets = attachments ? attachments : [];
				attachmentsReceivedEvent.serviceEvent = event;
				dispatchEvent(attachmentsReceivedEvent);
			}
		}
		
		/**
		 * Dispatch upload attachment received event
		 * */
		public function dispatchUploadAttachmentResultsEvent(successful:Boolean, attachments:Array, data:Object, event:IServiceEvent):void {
			var uploadAttachmentEvent:RadiateEvent = new RadiateEvent(RadiateEvent.ATTACHMENT_UPLOADED, false, false);
			
			if (hasEventListener(RadiateEvent.ATTACHMENT_UPLOADED)) {
				uploadAttachmentEvent.successful = successful;
				uploadAttachmentEvent.status = successful ? "ok" : "fault";
				uploadAttachmentEvent.data = attachments ? attachments : [];
				uploadAttachmentEvent.selectedItem = data;
				uploadAttachmentEvent.serviceEvent = event;
				dispatchEvent(uploadAttachmentEvent);
			}
		}
		
		/**
		 * Dispatch feedback results event
		 * */
		public function dispatchFeedbackResultsEvent(successful:Boolean, data:Object, event:Object):void {
			var feedbackResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.FEEDBACK_RESULT);
			
			if (hasEventListener(RadiateEvent.FEEDBACK_RESULT)) {
				feedbackResultsEvent.data = data;
				feedbackResultsEvent.successful = successful;
				feedbackResultsEvent.serviceEvent = event as IServiceEvent;
				dispatchEvent(feedbackResultsEvent);
			}
		}
		
		/**
		 * Dispatch login results event
		 * */
		public function dispatchLoginResultsEvent(successful:Boolean, data:Object, event:IServiceEvent):void {
			var loginResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.LOGIN_RESULTS);
			
			if (hasEventListener(RadiateEvent.LOGIN_RESULTS)) {
				loginResultsEvent.data = data;
				loginResultsEvent.successful = successful;
				loginResultsEvent.serviceEvent = event;
				dispatchEvent(loginResultsEvent);
			}
		}
		
		/**
		 * Dispatch logout results event
		 * */
		public function dispatchLogoutResultsEvent(successful:Boolean, data:Object, event:IServiceEvent):void {
			var logoutResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.LOGOUT_RESULTS);
			
			if (hasEventListener(RadiateEvent.LOGOUT_RESULTS)) {
				logoutResultsEvent.data = data;
				logoutResultsEvent.successful = successful;
				logoutResultsEvent.serviceEvent = event;
				dispatchEvent(logoutResultsEvent);
			}
		}
		
		/**
		 * Dispatch register results event
		 * */
		public function dispatchRegisterResultsEvent(successful:Boolean, data:Object, event:IServiceEvent):void {
			var registerResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.REGISTER_RESULTS);
			
			if (hasEventListener(RadiateEvent.REGISTER_RESULTS)) {
				registerResultsEvent.data = data;
				registerResultsEvent.successful = successful;
				registerResultsEvent.serviceEvent = event;
				dispatchEvent(registerResultsEvent);
			}
		}
		
		/**
		 * Dispatch change password results event
		 * */
		public function dispatchChangePasswordResultsEvent(successful:Boolean, data:Object, event:IServiceEvent):void {
			var changePasswordResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.CHANGE_PASSWORD_RESULTS);
			
			if (hasEventListener(RadiateEvent.CHANGE_PASSWORD_RESULTS)) {
				changePasswordResultsEvent.data = data;
				changePasswordResultsEvent.successful = successful;
				changePasswordResultsEvent.serviceEvent = event;
				dispatchEvent(changePasswordResultsEvent);
			}
		}
		
		/**
		 * Dispatch lost password results event
		 * */
		public function dispatchLostPasswordResultsEvent(successful:Boolean, data:Object, event:IServiceEvent):void {
			var lostPasswordResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.LOST_PASSWORD_RESULTS);
			
			if (hasEventListener(RadiateEvent.LOST_PASSWORD_RESULTS)) {
				lostPasswordResultsEvent.data = data;
				lostPasswordResultsEvent.successful = successful;
				lostPasswordResultsEvent.serviceEvent = event;
				dispatchEvent(lostPasswordResultsEvent);
			}
		}
		
		/**
		 * Dispatch project deleted results event
		 * */
		public function dispatchProjectDeletedEvent(successful:Boolean, data:Object, event:IServiceEvent):void {
			var deleteProjectResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROJECT_DELETED);
			
			if (hasEventListener(RadiateEvent.PROJECT_DELETED)) {
				deleteProjectResultsEvent.data = data;
				deleteProjectResultsEvent.successful = successful;
				deleteProjectResultsEvent.status = successful ? "ok" : "error";
				deleteProjectResultsEvent.serviceEvent = event;
				dispatchEvent(deleteProjectResultsEvent);
			}
		}
		
		/**
		 * Dispatch document deleted results event
		 * */
		public function dispatchDocumentDeletedEvent(successful:Boolean, data:Object, event:IServiceEvent):void {
			var deleteDocumentResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.DOCUMENT_DELETED);
			
			if (hasEventListener(RadiateEvent.DOCUMENT_DELETED)) {
				deleteDocumentResultsEvent.data = data;
				deleteDocumentResultsEvent.successful = successful;
				deleteDocumentResultsEvent.status = successful ? "ok" : "error";
				deleteDocumentResultsEvent.serviceEvent = event;
				dispatchEvent(deleteDocumentResultsEvent);
			}
		}
		
		/**
		 * Dispatch asset added event
		 * */
		public function dispatchAssetAddedEvent(data:Object):void {
			var assetAddedEvent:RadiateEvent = new RadiateEvent(RadiateEvent.ASSET_ADDED);
			
			if (hasEventListener(RadiateEvent.ASSET_ADDED)) {
				assetAddedEvent.data = data;
				dispatchEvent(assetAddedEvent);
			}
		}
		
		/**
		 * Dispatch asset removed event
		 * */
		public function dispatchAssetRemovedEvent(data:IDocumentData, successful:Boolean = true):void {
			var assetRemovedEvent:RadiateEvent = new RadiateEvent(RadiateEvent.ASSET_REMOVED);
			
			if (hasEventListener(RadiateEvent.ASSET_REMOVED)) {
				assetRemovedEvent.data = data;
				dispatchEvent(assetRemovedEvent);
			}
		}
		
		/**********************************
		 * 
		 * 
		 *********************************/
		
		
		
		/**
		 * Returns true if location includes local shared object
		 * */
		public static function getIsLocalLocation(value:String):Boolean {
			return value ? value.indexOf(DocumentData.LOCAL_LOCATION)!=-1 || value==DocumentData.ALL_LOCATIONS : false;
		}
		
		/**
		 * Returns true if location includes remote
		 * */
		public static function getIsRemoteLocation(value:String):Boolean {
			return value ? value.indexOf(DocumentData.REMOTE_LOCATION)!=-1 || value==DocumentData.ALL_LOCATIONS : false;
		}
		
		/**
		 * Returns true if location includes file system
		 * */
		public static function getIsFileLocation(value:String):Boolean {
			return value ? value.indexOf(DocumentData.FILE_LOCATION)!=-1 || value==DocumentData.ALL_LOCATIONS : false;
		}
		
		/**
		 * Returns true if location includes a database
		 * */
		public static function getIsDataBaseLocation(value:String):Boolean {
			return value ? value.indexOf(DocumentData.DATABASE_LOCATION)!=-1 || value==DocumentData.ALL_LOCATIONS : false;
		}
		
		/**
		 * Returns true if location includes internal
		 * */
		public static function getIsInternalLocation(value:String):Boolean {
			return value ? value.indexOf(DocumentData.INTERNAL_LOCATION)!=-1 || value==DocumentData.ALL_LOCATIONS : false;
		}
	}
}

class SINGLEDOUBLE{}