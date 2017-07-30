package com.flexcapacitor.managers
{
	import flash.net.URLVariables;
	
	import mx.events.BrowserChangeEvent;
	import mx.managers.BrowserManager;
	import mx.managers.IBrowserManager;

	public class URLManager
	{
		public function URLManager()
		{
		}
		
		
		
		private var browserManager:IBrowserManager;
		
		/**
		 * Check the URL when the page loads to see if there is a post
		 * */
		private function browserURLChange(event:BrowserChangeEvent = null):void {
			var fragment:String = browserManager.fragment;
			
			if (fragment) {
				getDocument(fragment);
			}
		}
		
		/**
		 * Get a snippet on the server
		 * */
		private function getDocument(fragment:String = ""):void {
			var form:URLVariables;
			var object:URLVariables;
			
			//loadSuccessful = false;
			//loadInProgress = true;
			
			object = new URLVariables();
			
			//object.id = postID;
			object.url = fragment;
			
			//loadService.call = "Get post";
			//renderTimeLabel.text = "Loading";
			//savingStatusGroup.visible = true;
			
			// save project
			//loadService.send("snippets", "get_snippet", null, form);				
		}
		
		private function setupBrowserManager():void {
			browserManager = BrowserManager.getInstance();
			browserManager.addEventListener(BrowserChangeEvent.APPLICATION_URL_CHANGE, applicationURLChange);
			browserManager.addEventListener(BrowserChangeEvent.BROWSER_URL_CHANGE, browserURLChange);
			browserManager.init("", "");
		}
		
		/**
		 * When you use the browserManager.setFragment() method to change the URL, you trigger an applicationURLChange event.
		 * We keep this method to check the url after user saves
		 * Otherwise use browserURLchange
		 **/
		private function applicationURLChange(event:BrowserChangeEvent):void {
			var fragment:String = browserManager.fragment;
			if (fragment) {
				//loadService.getPostById(fragment);
			}
		}
	}
}