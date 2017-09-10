package com.flexcapacitor.managers {
	import com.flexcapacitor.model.SaveResultsEvent;
	import com.flexcapacitor.services.ServiceEvent;
	import com.flexcapacitor.services.WPService;
	
	import flash.events.EventDispatcher;
	import flash.net.URLVariables;
	
	import mx.managers.IBrowserManager;
	
	[Event("saveResults", type="com.flexcapacitor.services.ServiceEvent")]
	[Event("retrievedResults", type="com.flexcapacitor.services.ServiceEvent")]

	public class SnippetManager extends EventDispatcher {
		
		public function SnippetManager(s:SINGLEDOUBLE) {
		
		}
		
		public static var SAVE_RESULTS:String = "saveResults";
		public static var RETRIEVED_RESULTS:String = "retrievedResults";
		
		private var host:String;
		private var viewerHost:String;
		private var editorHost:String;
		
		private var saveSnippetsService:WPService;
		private var getSnippetsService:WPService;
		private var saveSuccessful:Boolean;
		private var saveInProgress:Boolean;
		private var loadSuccessful:Boolean;
		private var loadInProgress:Boolean;
		
		private var browserManager:IBrowserManager;
		public var lastURL:String;
		public var lastFragment:String;
		public var currentURL:String;
		public var name:String;
		public var checkSize:Boolean;
		
		public function initialize(location:String = null):void {
			
			if (location) {
				host = location;
			}
			
			if (getSnippetsService==null) {
				getSnippetsService = new WPService();
				getSnippetsService.addEventListener(WPService.RESULT, getSnippetsResultsHandler, false, 0, true);
				getSnippetsService.addEventListener(WPService.FAULT, getSnippetsFaultHandler, false, 0, true);
				getSnippetsService.host = host;
				getSnippetsService.usePermalinks = true;
			}
			
			if (saveSnippetsService==null) {
				saveSnippetsService = new WPService();
				saveSnippetsService.addEventListener(WPService.RESULT, saveSnippetsResultsHandler, false, 0, true);
				saveSnippetsService.addEventListener(WPService.FAULT, saveSnippetsFaultHandler, false, 0, true);
				saveSnippetsService.host = host;
				saveSnippetsService.usePermalinks = true;
			}
		}
		
		/**
		 * Get the snippet by id
		 **/
		public function getSnippetByID(id:String):void {
			var variables:URLVariables;
			
			loadSuccessful = false;
			loadInProgress = true;
			
			variables = new URLVariables();
			
			variables.id = id;
			
			getSnippetsService.call = "Get Snippet";
			getSnippetsService.send("snippets", "get_snippet", null, variables);
		}
		
		/**
		 * Get the snippet by fragment
		 **/
		public function getSnippetByFragment(fragment:String):void {
			var variables:URLVariables;
			
			loadSuccessful = false;
			loadInProgress = true;
			
			variables = new URLVariables();
			
			variables.fragment = fragment;
			
			getSnippetsService.call = "Get Snippet";
			getSnippetsService.send("snippets", "get_snippet", null, variables);
		}
		
		/**
		 * Saves the snippet to the server
		 * */
		public function saveSnippet(title:String, code:String, description:String = "", thumbnail:String = ""):void {
			var form:URLVariables;
			var size:int;
			
			saveSuccessful = false;
			saveInProgress = true;
			
			size = title.length + code.length + description.length + thumbnail.length;
			
			// on https the post size limit is sometimes much lower
			// 413 Request Entity Too Large
			if (checkSize) {
				trace(size);
			}
			
			form = createFormObject(title, code, description, thumbnail);
			
			saveSnippetsService.call = "Post call";
			saveSnippetsService.send("snippets", "create_snippet", null, form);				
		}
		
		/**
		 * Creates an object to send to the server
		 * */
		protected function createFormObject(title:String, code:String, description:String = "", thumbnail:String = null):URLVariables {
			var variables:URLVariables = new URLVariables();
			var value:String = code;
			
			variables.title = title;
			variables.content = description=="" || description==null ? "A snippet" : description;
			
			variables["custom[source]"] = value;
			
			if (thumbnail) {
				variables["custom[thumbnail]"] = thumbnail;
			}
			
			return variables;
		}
		
		
		/***************************************************
		 * Event Handlers
		 ****************************************************/
		
		/**
		 * Result from save result
		 * */
		public function saveSnippetsResultsHandler(event:ServiceEvent):void {
			var saveResultsEvent:SaveResultsEvent;
			var data:Object;
			var post:Object;
			var uri:String;
			var status:String;
			var result:Array;
			var id:String;
			var serviceEvent:ServiceEvent;
			
			data = event.data;
			post = data ? data.post : null;
			
			//saveResultsEvent = new SaveResultsEvent(SaveResultsEvent.SAVE_RESULTS);
			//saveResultsEvent.call = event.call;
			//saveResultsEvent.data = event.data;
			//saveResultsEvent.message = event.message;
			//saveResultsEvent.text = event.text;
			
			if (post) {
				uri = post.url;
				status = post.status;
				//uri = post.url;
				//savingStatus.text = "Snippet saved";
				
				//pathElements = uri.split("/");
				//key = pathElements[pathElements.length-2];
				result = uri.match(/(\w+)\/?$/);
				
				//https://www.radii8.com/snippets/#Ewv0zaZ23nA
				if (result!=null) {
					
					//browserManager.setFragment(result[1]);
					lastFragment = result[1];
				}
				else {
					
					//browserManager.setFragment(post.id);
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
			
			saveInProgress = false;
			
			if (hasEventListener(SAVE_RESULTS)) {
				serviceEvent = new ServiceEvent(SAVE_RESULTS);
				
				if (event.hasError) {
					serviceEvent.faultEvent = event;
				}
				else {
					serviceEvent.resultEvent = event;
				}
				
				dispatchEvent(serviceEvent);
			}
		}
		
		/**
		 * Result from save fault
		 * */
		public function saveSnippetsFaultHandler(event:ServiceEvent):void {
			var errorEvent:Object;
			var errorText:String;
			var errorType:String;
			var results:String;
			var errorID:int;
			var serviceEvent:ServiceEvent;
			
			errorEvent = saveSnippetsService && "errorEvent" in saveSnippetsService ? WPService(saveSnippetsService).errorEvent : null;
			
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
			
			
			saveInProgress = false;
			
			if (hasEventListener(SAVE_RESULTS)) {
				serviceEvent = new ServiceEvent(SAVE_RESULTS);
				
				if (event.hasError) {
					serviceEvent.hasError = true;
					serviceEvent.faultEvent = event;
					serviceEvent.errorMessage = errorText;
				}
				else {
					serviceEvent.resultEvent = event;
				}
				
				dispatchEvent(serviceEvent);
			}
		}
		
		/**
		 * Result from load result
		 * */
		public function getSnippetsResultsHandler(event:ServiceEvent):void {
			var data:Object;
			var post:Object;
			var uri:String;
			var status:String;
			var customFields:Object;
			var source:String;
			var thumbnail:String;
			var serviceEvent:ServiceEvent;
			
			data = event.data;
			post = data ? data.post : null;
			
			if (post) {
				uri = post.url;
				status = post.status;
				customFields = post.custom_fields;
				source = customFields.source;
				thumbnail = customFields.thumbnail;
			}
			else if ("error" in data && data.error) {
				source = data.error; // Snippet not found.
			}
			
			
			if (hasEventListener(RETRIEVED_RESULTS)) {
				serviceEvent = new ServiceEvent(RETRIEVED_RESULTS);
				
				if (event.hasError) {
					serviceEvent.faultEvent = event;
				}
				else {
					serviceEvent.resultEvent = event;
				}
				
				if (serviceEvent.data==null) {
					serviceEvent.data = data;
				}
				
				if (event.hasError) {
					serviceEvent.hasError = event.hasError;
				}
				
				dispatchEvent(serviceEvent);
			}
		}
		
		/**
		 * Result from load fault
		 * */
		public function getSnippetsFaultHandler(event:ServiceEvent):void {
			var errorEvent:Object;
			var errorID:int;
			var errorText:String;
			var errorType:String;
			var results:String;
			var serviceEvent:ServiceEvent;
			
			errorEvent = saveSnippetsService && "errorEvent" in saveSnippetsService ? WPService(saveSnippetsService).errorEvent : null;
			
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
			
			if (hasEventListener(RETRIEVED_RESULTS)) {
				serviceEvent = new ServiceEvent(RETRIEVED_RESULTS);
				
				if (event.hasError) {
					serviceEvent.faultEvent = event;
				}
				else {
					serviceEvent.resultEvent = event;
				}
				
				dispatchEvent(serviceEvent);
			}
		}
		
		//----------------------------------
		//  instance
		//----------------------------------
		
		public static function get instance():SnippetManager
		{
			if (!_instance) {
				_instance = new SnippetManager(new SINGLEDOUBLE());
			}
			return _instance;
		}
		
		public static function getInstance():SnippetManager {
			return instance;
		}
		
		private static var _instance:SnippetManager;
	}
}

class SINGLEDOUBLE{}