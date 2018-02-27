package com.flexcapacitor.managers
{
	import com.flexcapacitor.services.WPServiceEvent;
	import com.flexcapacitor.utils.PersistentStorage;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.setTimeout;
	import com.flexcapacitor.controller.Console;
	import com.flexcapacitor.controller.Radiate;

	/**
	 * Profile manaager
	 **/
	public class ProfileManager extends Console {
		
		public function ProfileManager(s:SINGLEDOUBLE) {
			super();
		}
		
		/**
		 * Is user logged in
		 * */
		[Bindable]
		public static var isUserLoggedIn:Boolean;
		
		/**
		 * Can user connect to the service
		 * */
		[Bindable]
		public static var isUserConnected:Boolean;
		
		/**
		 * Is the user online
		 * */
		[Bindable]
		public static var isUserOnline:Boolean;
		
		/**
		 * Avatar of user
		 * */
		[Bindable]
		public static var userAvatar:String = "assets/images/icons/gravatar.png";
		
		/**
		 * Path to default avatar of user (from Gravatar)
		 * Gravatars icons don't work locally so using path. 
		 * Default - http://0.gravatar.com/avatar/ad516503a11cd5ca435acc9bb6523536?s=96
		 * local - assets/images/icons/gravatar.png
		 * */
		[Bindable]
		public static var defaultUserAvatarPath:String = "assets/images/icons/gravatar.png";
		
		/**
		 * User info
		 * */
		[Bindable]
		public static var user:Object;
		
		/**
		 * User email
		 * */
		[Bindable]
		public static var userEmail:String;
		
		/**
		 * User id
		 * */
		[Bindable]
		public static var userID:int = -1;
		
		/**
		 * User name
		 * */
		[Bindable]
		public static var username:String;
		
		/**
		 * Home page id
		 * */
		[Bindable]
		public static var projectHomePageID:int = -1;
		
		/**
		 * User sites
		 * */
		[Bindable]
		public static var userSites:Array = [];
		
		/**
		 * User site path
		 * */
		[Bindable]
		public static var userSitePath:String;
		
		/**
		 * User display name
		 * */
		[Bindable]
		public static var userDisplayName:String = "guest";
		
		/**
		 * Opens a login page for the user to login
		 * */
		public static function loginThroughBrowser():void {
			var value:Object = PersistentStorage.read(Radiate.USER_STORE);
			
			if (value!=null) {
				ServicesManager.instance.loginThroughBrowser(value.u, value.p, true);
			}
			else {
				info("No login was saved.");
				setTimeout(openUsersLoginPage, 1000);
			}
		}
		
		/**
		 * Open users site in a browser
		 * */
		public static function openUsersWebsite():void {
			var request:URLRequest;
			request = new URLRequest();
			request.url = Radiate.getWPURL();
			navigateToURL(request, Radiate.DEFAULT_NAVIGATION_WINDOW);
		}
		/**
		 * Open users login page or dashboard if already logged in in a browser
		 * */
		public static function openUsersLoginPage():void {
			var request:URLRequest;
			request = new URLRequest();
			request.url = Radiate.getWPLoginURL();
			navigateToURL(request, Radiate.DEFAULT_NAVIGATION_WINDOW);
		}
		
		/**
		 * Open users profile in a browser
		 * */
		public static function openUsersProfile():void {
			var request:URLRequest;
			request = new URLRequest();
			request.url = Radiate.getWPProfileURL();
			navigateToURL(request, Radiate.DEFAULT_NAVIGATION_WINDOW);
		}
		
		/**
		 * Updates the user information from data object from the server
		 * */
		public static function updateUserInfo(data:Object):void {
			
			if (data && data is Object && "loggedIn" in data) {
				isUserLoggedIn = data.loggedIn;
				userAvatar = data.avatar;
				userDisplayName = data.displayName ? data.displayName : "guest";
				username = data.username;
				userID = data.id;
				userEmail = data.contact;
				user = data;
				
				if (!isNaN(data.homePage)) {
					projectHomePageID = data.homePage;
				}
				else {
					projectHomePageID = -1;
				}
				
				userSites = [];
				
				if ("blogs" in user) {
					//userSites = user.blogs;
					for each (var blog:Object in user.blogs) {
						userSites.push(blog);
					}
					
					if (userSites.length>0) {
						userSitePath = userSites[0].path;
						Radiate.WP_USER_PATH = userSitePath;
						Radiate.WP_USER_PATH = Radiate.WP_USER_PATH.replace(Radiate.WP_PATH, "");
					}
					else {
						userSitePath = "";
						Radiate.WP_USER_PATH = "";
					}
				}
				
				if (isUserLoggedIn==false) {
					userSitePath = "";
					Radiate.WP_USER_PATH = "";
				}
			}
			else {
				isUserLoggedIn = false;
				userAvatar = "";
				userDisplayName = "guest";
				userID = 0;
				userEmail = "";
				user = null;
				projectHomePageID = -1;
				userSites = [];
				userSitePath = "";
				Radiate.WP_USER_PATH = "";
			}
		}
		
		protected function loginStatusChange(event:WPServiceEvent):void {
			var data:Object = event.data;
			
			if (event.hasError) {
				isUserConnected = false;
			}
			else {
				isUserConnected = true;
			}
			
			updateUserInfo(data);
		}
		
		//----------------------------------
		//  instance
		//----------------------------------
		
		public static function get instance():ProfileManager {
			if (!_instance) {
				_instance = new ProfileManager(new SINGLEDOUBLE());
			}
			return _instance;
		}
		
		public static function getInstance():ProfileManager {
			return instance;
		}
		
		private static var _instance:ProfileManager;
	}
}

class SINGLEDOUBLE{}