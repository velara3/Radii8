package com.flexcapacitor.managers
{
	import com.flexcapacitor.model.SaveResultsEvent;
	import com.flexcapacitor.services.IServiceEvent;
	import com.flexcapacitor.services.IWPService;
	import com.flexcapacitor.services.IWPServiceEvent;
	import com.flexcapacitor.services.WPService;
	
	import flash.net.URLVariables;
	import flash.utils.setTimeout;
	
	import mx.managers.IBrowserManager;

	public class SnippetManager
	{
		public function SnippetManager()
		{
		}
		
		
		private var host:String;
		private var viewerHost:String;
		private var editorHost:String;
		
		private var loadService:WPService;
		private var saveService:WPService;
		private var snippetsService:WPService;
		private var saveSuccessful:Boolean;
		private var saveInProgress:Boolean;
		private var loadSuccessful:Boolean;
		private var loadInProgress:Boolean;
		
		private var browserManager:IBrowserManager;
		public var lastURL:String;
		public var lastFragment:String;
		public var currentURL:String;
		public var name:String;
		
		public function initialize():void {
			
			if (snippetsService==null) {
				snippetsService = new WPService();
				snippetsService.addEventListener(WPService.RESULT, getSnippetsResultsHandler, false, 0, true);
				snippetsService.addEventListener(WPService.FAULT, getSnippetsFaultHandler, false, 0, true);
				snippetsService.host = host;
			}
		}
		
		/**
		 * Results from call to get projects
		 * */
		public function getSnippetsResultsHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			//examplesCollection.source = parseProjectsData(data);
		}
		
		/**
		 * Result example projects fault
		 * */
		public function getSnippetsFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			if (event.hasError) {
				//showErrorsImage(true, Object(event.faultEvent).text);
			}
			else {
				//showErrorsImage(false);
			}
		}
		
		/**
		 * Saves the snippet to the server
		 * */
		private function postDocument(title:String, code:String, description:String = ""):void {
			var form:URLVariables;
			
			saveSuccessful = false;
			saveInProgress = true;
			
			form = toSaveFormObject(title, code, description);
			
			if (title!=null) {
				form.title = title;
			}
			
			if (description) {
				form.content = description;
			}
			
			saveService.call = "Post call";
			//savingStatus.text = "Saving";
			//savingStatusGroup.visible = true;
			// save project
			saveService.send("snippets", "create_snippet", null, form);				
		}
		
		/**
		 * Creates an object to send to the server
		 * */
		public function toSaveFormObject(title:String, code:String, description:String = ""):URLVariables {
			var object:URLVariables = new URLVariables();
			var value:String = code;
			
			object.title = title;
			object.content = description=="" || description==null ? "An snippet" : description;
			//object.content = value;
			//object.categories = "document";
			
			//if (id) 		object.id 		= id;
			//if (status)		object.status 	= status;
			//object.type 	= "page";
			
			//object["custom[uid]"] = uid;
			//object["custom[sponge]"] = 1;
			//object["custom[sandpaper]"] = 1;
			
			object["custom[source]"] = value;
			
			return object;
		}
		
		/**
		 * Result from save result
		 * */
		public function saveResultsHandler(event:IWPServiceEvent):void {
			var saveResultsEvent:SaveResultsEvent = new SaveResultsEvent(SaveResultsEvent.SAVE_RESULTS);
			var data:Object = event.data;
			var post:Object = data ? data.post : null;
			var pathElements:Array;
			var key:String;
			var uri:String;
			var status:String;
			var id:String;
			
			saveResultsEvent.call = event.call;
			saveResultsEvent.data = event.data;
			saveResultsEvent.message = event.message;
			saveResultsEvent.text = event.text;
			
			if (post) {
				uri = post.url;
				status = post.status;
				//savingStatus.text = "Snippet saved";
				
				//pathElements = uri.split("/");
				//key = pathElements[pathElements.length-2];
				var result:Array = uri.match(/(\w+)\/?$/);
				if (result!=null) {//https://www.radii8.com/snippets/#Ewv0zaZ
					browserManager.setFragment(result[1]);
					lastFragment = result[1];
				}
				else {
					browserManager.setFragment(post.id);
					lastFragment = id;
				}
				
				lastURL = uri;
				
				saveSuccessful = true;
			}
			else {
				// you may need to be on the server, may need https, 
				// use file:// when testing locally 
				// or an error in the php 
				//savingStatus.text = "Not saved";
				saveSuccessful = false;
			}
			
			setTimeout(removeSaveLabel, 3000);
			
			saveInProgress = false;
		}
		
		public function removeSaveLabel():void {
			//savingStatusGroup.visible = false;
		}
		
		/**
		 * Result from save fault
		 * */
		public function saveFaultHandler(event:IServiceEvent):void {
			var service:IWPService = saveService;
			var errorEvent:Object = service && "errorEvent" in service ? WPService(service).errorEvent : null;
			var errorID:int;
			var errorText:String;
			var errorType:String;
			var results:String;
			
			if (errorEvent) {
				errorText = "text" in errorEvent ? errorEvent.text : "";
				errorText = "message" in errorEvent ? errorEvent.message : errorText;
				errorID = "errorID" in errorEvent ? errorEvent.errorID : 0;
				errorType = "type" in errorEvent ? errorEvent.type : "";
				results = "Error when saving snippet. You may be disconnected. Check your connection and try again";
			}
			else {
				results = "Error when trying to save document";
			}
			
			//savingStatus.text = results;
			
			setTimeout(removeSaveLabel, 5000);
			
			saveInProgress = false;
		}
		
		/**
		 * Result from load result
		 * */
		public function loadResultsHandler(event:IWPServiceEvent):void {
			var data:Object = event.data;
			var post:Object = data ? data.post : null;
			
			if (post) {
				var uri:String = post.url;
				var status:String = post.status;
				var customFields:Object = post.custom_fields;
				var source:String = browserManager ? customFields.source : null;
				//setEditorText(source);
				//renderTimeLabel.text = "Loaded";
			}
			else {
				//renderTimeLabel.text = "Not loaded";
			}
			
		}
		
		/**
		 * Result from load fault
		 * */
		public function loadFaultHandler(event:IServiceEvent):void {
			var errorEvent:Object = loadService && "errorEvent" in loadService ? WPService(loadService).errorEvent : null;
			var errorID:int;
			var errorText:String;
			var errorType:String;
			var results:String;
			
			if (errorEvent) {
				errorText = "text" in errorEvent ? errorEvent.text : "";
				errorText = "message" in errorEvent ? errorEvent.message : errorText;
				errorID = "errorID" in errorEvent ? errorEvent.errorID : 0;
				errorType = "type" in errorEvent ? errorEvent.type : "";
				results = "Error when saving document: "+ name + ". You may be disconnected. Check your connection and try again";
			}
			else {
				results = "Error when trying to save document: "+ name;
			}
			
		}
	}
}