
package com.flexcapacitor.controller {
	import com.flexcapacitor.components.DocumentContainer;
	import com.flexcapacitor.components.IDocumentContainer;
	import com.flexcapacitor.effects.core.CallMethod;
	import com.flexcapacitor.events.HistoryEvent;
	import com.flexcapacitor.events.HistoryEventItem;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.logging.RadiateLogTarget;
	import com.flexcapacitor.model.AttachmentData;
	import com.flexcapacitor.model.Device;
	import com.flexcapacitor.model.Document;
	import com.flexcapacitor.model.DocumentData;
	import com.flexcapacitor.model.EventMetaData;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IDocumentData;
	import com.flexcapacitor.model.IDocumentMetaData;
	import com.flexcapacitor.model.IProject;
	import com.flexcapacitor.model.IProjectData;
	import com.flexcapacitor.model.ISavable;
	import com.flexcapacitor.model.ImageData;
	import com.flexcapacitor.model.InspectableClass;
	import com.flexcapacitor.model.InspectorData;
	import com.flexcapacitor.model.MetaData;
	import com.flexcapacitor.model.Project;
	import com.flexcapacitor.model.SaveResultsEvent;
	import com.flexcapacitor.model.SavedData;
	import com.flexcapacitor.model.Settings;
	import com.flexcapacitor.model.StyleMetaData;
	import com.flexcapacitor.services.IServiceEvent;
	import com.flexcapacitor.services.WPAttachmentService;
	import com.flexcapacitor.services.WPService;
	import com.flexcapacitor.services.WPServiceEvent;
	import com.flexcapacitor.tools.ITool;
	import com.flexcapacitor.utils.ClassUtils;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.SharedObjectUtils;
	import com.flexcapacitor.utils.TypeUtils;
	import com.flexcapacitor.utils.XMLUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDefinition;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	import com.flexcapacitor.views.IInspector;
	import com.google.code.flexiframe.IFrame;
	
	import flash.desktop.Clipboard;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.globalization.DateTimeStyle;
	import flash.net.FileReference;
	import flash.net.SharedObject;
	import flash.system.ApplicationDomain;
	import flash.ui.Mouse;
	import flash.ui.MouseCursorData;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Grid;
	import mx.containers.GridItem;
	import mx.containers.GridRow;
	import mx.containers.TabNavigator;
	import mx.controls.LinkButton;
	import mx.core.ClassFactory;
	import mx.core.DeferredInstanceFromFunction;
	import mx.core.IUIComponent;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.effects.effectClasses.PropertyChanges;
	import mx.graphics.ImageSnapshot;
	import mx.graphics.SolidColor;
	import mx.logging.AbstractTarget;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.managers.ILayoutManager;
	import mx.managers.LayoutManager;
	import mx.printing.FlexPrintJob;
	import mx.printing.FlexPrintJobScaleType;
	import mx.states.AddItems;
	import mx.styles.IStyleClient;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
	import spark.components.Application;
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.ComboBox;
	import spark.components.Grid;
	import spark.components.Image;
	import spark.components.Label;
	import spark.components.NavigatorContent;
	import spark.components.Scroller;
	import spark.components.SkinnableContainer;
	import spark.components.supportClasses.GroupBase;
	import spark.components.supportClasses.SkinnableTextBase;
	import spark.components.supportClasses.TextBase;
	import spark.core.ContentCache;
	import spark.core.IViewport;
	import spark.effects.SetAction;
	import spark.formatters.DateTimeFormatter;
	import spark.layouts.BasicLayout;
	import spark.primitives.BitmapImage;
	import spark.primitives.Rect;
	import spark.skins.spark.DefaultGridItemRenderer;
	
	import org.as3commons.lang.ArrayUtils;
	import org.as3commons.lang.DictionaryUtils;
	import org.as3commons.lang.ObjectUtils;
	
	use namespace mx_internal;
	
	/**
	 * Dispatched when a register results are received
	 * */
	[Event(name="registerResults", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when a print job is cancelled
	 * */
	[Event(name="printCancelled", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when an item is added to the target
	 * */
	[Event(name="addItem", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when an item is removed from the target
	 * */
	[Event(name="removeItem", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when an item is removed from the target
	 * */
	[Event(name="removeTarget", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when the target is changed
	 * */
	[Event(name="targetChange", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when the document is changed
	 * */
	[Event(name="documentChange", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when a document is opening
	 * */
	[Event(name="documentOpening", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when a document is opened
	 * */
	[Event(name="documentOpen", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when a document is renamed
	 * */
	[Event(name="documentRename", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when the project is changed
	 * */
	[Event(name="projectChange", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when the project is deleted
	 * */
	[Event(name="projectDeletedResults", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when the project is created
	 * */
	[Event(name="projectCreated", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when a property on the target is changed. 
	 * Using propertyChanged instead of propertyChange because of error with bindable
	 * tag using propertyChange:
	 * TypeError: Error #1034: Type Coercion failed: cannot convert mx.events::PropertyChangeEvent@11d2187b1 to com.flexcapacitor.events.RadiateEvent.
	 * */
	[Event(name="propertyChanged", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when a property is selected on the target
	 * */
	[Event(name="propertySelected", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when a property edit is requested
	 * */
	[Event(name="propertyEdit", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when the tool changes
	 * */
	[Event(name="toolChange", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when the scale changes
	 * */
	[Event(name="scaleChange", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when the document size or scale changes
	 * */
	[Event(name="documentSizeChange", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Not used yet. 
	 * */
	[Event(name="initialized", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Used when the tools list has been updated. 
	 * */
	[Event(name="toolsUpdated", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Used when the components list is updated. 
	 * */
	[Event(name="componentsUpdated", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Used when the document canvas is updated. 
	 * */
	[Event(name="canvasChange", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Event to request a preview if available. Used for HTML preview. 
	 * */
	[Event(name="requestPreview", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when the generated code is updated. 
	 * */
	[Event(name="codeUpdated", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when a color is selected. 
	 * */
	[Event(name="colorSelected", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatched when an object is selected 
	 * */
	[Event(name="objectSelected", type="com.flexcapacitor.radiate.events.RadiateEvent")]
	
	/**
	 * Dispatches events when the target or targets property changes or is about to change. 
	 * This class supports an Undo / Redo history. The architecture is loosely based on 
	 * the structure found in the Effects classes. 
	 * 
	 * To change a property call request property change. It will be in the history
	 * To add a component call request item add. It will be in the history
	 * 
	 * To undo call undo
	 * To redo call redo
	 * 
	 * To get the history index access history index
	 * To check if history exists call the has history
	 * To check if undo can be performed access has undo
	 * To check if redo can be performed access has redo 
	 * */
	public class Radiate extends EventDispatcher {
		
		public static const SAME_OWNER:String = "sameOwner";
		public static const SAME_PARENT:String = "sameParent";
		public static const ADDED:String = "added";
		public static const MOVED:String = "moved";
		public static const REMOVED:String = "removed";
		public static const ADD_ERROR:String = "addError";
		public static const REMOVE_ERROR:String = "removeError";
		public static const RADIATE_LOG:String = "radiate";
		public static const LOGGED_IN:String = "loggedIn";
		public static const LOGGED_OUT:String = "loggedOut";
		
		public function Radiate(s:SINGLEDOUBLE) {
			super(target as IEventDispatcher);
			
			// Create a target
			setLoggingTarget(defaultLogTarget);
			
			
			// initialize - maybe call on startup() instead
			initialize();
		}
		
		//----------------------------------
		//  instance
		//----------------------------------
		private static var _instance:Radiate;
		
		/**
		 * Attempt to support a console part 2
		 * */
		public static function get log():ILogger {
			
			if (_log) {
				return _log;
			}
			else {
				setLoggingTarget(defaultLogTarget);
				return _log;
			}
		}

		/**
		 * @private
		 */
		public static function set log(value:ILogger):void {
			_log = value;
		}

		/**
		 * Attempt to support a console part 3
		 * */
		public static function get console():Object {
			return _console;
		}

		/**
		 * @private
		 */
		public static function set console(value:Object):void {
			_console = value;
			
			if ("console" in logTarget) {
				logTarget["console"] = value;
			}
		}

		public static function get instance():Radiate
		{
			if (!_instance) {
				_instance = new Radiate(new SINGLEDOUBLE());
			}
			return _instance;
		}
		
		public static function getInstance():Radiate {
			return instance;
		}
		
		/**
		 * Create references for classes we need.
		 * */
		public static var radiateReferences:RadiateReferences;
		
		/**
		 * If true then importing document
		 * */
		public static var importingDocument:Boolean;
		
		/**
		 * Upload attachment
		 * */
		public var uploadAttachmentService:WPAttachmentService;
		
		/**
		 * Service to get list of attachments
		 * */
		public var getAttachmentsService:WPService;
		
		/**
		 * Service to get list of projects
		 * */
		public var getProjectsService:WPService;
		
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
		 * Service to login
		 * */
		public var loginService:WPService;
		
		/**
		 * Service to logout
		 * */
		public var logoutService:WPService;
		
		/**
		 * Service to register
		 * */
		public var registerService:WPService;
		
		/**
		 * Service to check if user is logged in
		 * */
		public var getLoggedInStatusService:WPService;
		
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
		 * Set to true when checking if user is logged in
		 * */
		[Bindable]
		public var getLoggedInStatusInProgress:Boolean;
		
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
		 * Is user logged in
		 * */
		[Bindable]
		public var isUserLoggedIn:Boolean;
		
		/**
		 * Default storage location for save and load. 
		 * */
		[Bindable]
		public var defaultStorageLocation:String;
		
		/**
		 * Can user connect to the service
		 * */
		[Bindable]
		public var isUserConnected:Boolean;
		
		/**
		 * Avatar of user
		 * */
		[Bindable]
		public var userAvatar:String = "assets/images/icons/gravatar.png";
		
		/**
		 * Path to default avatar of user (from Gravatar)
		 * Gravatars icons don't work locally so using path. 
		 * Default - http://0.gravatar.com/avatar/ad516503a11cd5ca435acc9bb6523536?s=96
		 * local - assets/images/icons/gravatar.png
		 * */
		[Bindable]
		public var defaultUserAvatarPath:String = "assets/images/icons/gravatar.png";
		
		/**
		 * User info
		 * */
		[Bindable]
		public var user:Object;
		
		/**
		 * User email
		 * */
		[Bindable]
		public var userEmail:String;
		
		/**
		 * User id
		 * */
		[Bindable]
		public var userID:int = -1;
		
		/**
		 * User sites
		 * */
		[Bindable]
		public var userSites:Array = [];
		
		/**
		 * User site path
		 * */
		[Bindable]
		public var userSitePath:String;
		
		/**
		 * User display name
		 * */
		[Bindable]
		public var userDisplayName:String = "guest";
		
		/**
		 * Last save date
		 * */
		[Bindable]
		public var lastSaveDate:String;
		
		/**
		 * Cut data
		 * */
		public var cutData:Object;
		
		/**
		 * Cut data
		 * */
		public var copiedData:Object;
		
		/**
		 * Auto save locations
		 * */
		[Bindable]
		public var autoSaveLocations:String;
		
		private var _enableAutoSave:Boolean;

		[Bindable]
		/**
		 * Auto save enabled
		 * */
		public function get enableAutoSave():Boolean {
			return _enableAutoSave;
		}

		/**
		 * @private
		 */
		public function set enableAutoSave(value:Boolean):void {
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
		 * Interval to check to save project
		 * */
		public var autoSaveInterval:int = 30000;
		
		/**
		 * Effect to auto save
		 * */
		public var autoSaveEffect:CallMethod;
		
		/**
		 * Handle auto saving 
		 * */
		public function autoSaveHandler():void {
			var length:int;
			var iProject:IProject;
			var iDocumentData:IDocumentData;
			var iAttachmentData:AttachmentData;
			var imageData:ImageData;
			var i:int;
			
			// save documents
			/*length = documents.length;
			for (i=0;i<length;i++) {
				iDocumentData = documents[i] as IDocumentData;
				if (iDocumentData.isChanged && !iDocumentData.saveInProgress && iDocumentData.isOpen) {
					iDocumentData.save();
				}
			}*/
			
			// save projects
			length = projects.length;
			for (i=0;i<length;i++) {
				iDocumentData = projects[i] as IDocumentData;
				//if (iDocumentData.isChanged && !iDocumentData.saveInProgress && iDocumentData.isOpen) {
				if (!iDocumentData.saveInProgress && iDocumentData.isOpen) {
					iDocumentData.save();
				}
			}
			
			// save attachments
			length = assets.length;
			for (i=0;i<length;i++) {
				iAttachmentData = assets[i] as ImageData;
				if (iAttachmentData) {
					imageData = iAttachmentData as ImageData;
					
					if (!imageData.saveInProgress && imageData.id==null) {
						//imageData.save();
						uploadAttachment(imageData.byteArray, selectedProject.id, imageData.name, null, imageData.contentType);
					}
				}
			}
		}

		/**
		 * Build number
		 * */
		[Bindable]
		public var buildNumber:String;
		
		/**
		 * Build date
		 * */
		[Bindable]
		public var buildDate:String;
		
		/**
		 * Build time
		 * */
		[Bindable]
		public var buildTime:String;
		
		//----------------------------------
		//
		//  Events Management
		// 
		//----------------------------------
		
		/**
		 * Dispatch attachments received event
		 * */
		public function dispatchGetProjectsListResultsEvent(data:Object):void {
			var projectsListResultEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROJECTS_LIST_RECEIVED);
			
			if (hasEventListener(RadiateEvent.PROJECTS_LIST_RECEIVED)) {
				projectsListResultEvent.data = data;
				dispatchEvent(projectsListResultEvent);
			}
		}
		
		/**
		 * Dispatch print cancelled event
		 * */
		public function dispatchPrintCancelledEvent(data:Object, printJob:FlexPrintJob):void {
			var printCancelledEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PRINT_CANCELLED);
			
			if (hasEventListener(RadiateEvent.PRINT_CANCELLED)) {
				printCancelledEvent.data = data;
				printCancelledEvent.selectedItem = printJob;
				dispatchEvent(printCancelledEvent);
			}
		}
		
		/**
		 * Dispatch print complete event
		 * */
		public function dispatchPrintCompleteEvent(data:Object, printJob:FlexPrintJob):void {
			var printCompleteEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PRINT_COMPLETE);
			
			if (hasEventListener(RadiateEvent.PRINT_COMPLETE)) {
				printCompleteEvent.data = data;
				printCompleteEvent.selectedItem = printJob;
				dispatchEvent(printCompleteEvent);
			}
		}
		
		/**
		 * Dispatch attachments received event
		 * */
		public function dispatchLoginStatusEvent(loggedIn:Boolean, data:Object):void {
			var loggedInStatusEvent:RadiateEvent = new RadiateEvent(RadiateEvent.LOGGED_IN_STATUS);
			
			if (hasEventListener(RadiateEvent.LOGGED_IN_STATUS)) {
				loggedInStatusEvent.status = loggedIn ? LOGGED_IN : LOGGED_OUT;
				loggedInStatusEvent.data = data;
				dispatchEvent(loggedInStatusEvent);
			}
		}
		
		/**
		 * Dispatch attachments received event
		 * */
		public function dispatchAttachmentsResultsEvent(successful:Boolean, attachments:Array):void {
			var attachmentsReceivedEvent:RadiateEvent = new RadiateEvent(RadiateEvent.ATTACHMENTS_RECEIVED, false, false, attachments);
			
			if (hasEventListener(RadiateEvent.ATTACHMENTS_RECEIVED)) {
				attachmentsReceivedEvent.successful = successful;
				attachmentsReceivedEvent.status = successful ? "ok" : "fault";
				attachmentsReceivedEvent.targets = ArrayUtil.toArray(attachments);
				dispatchEvent(attachmentsReceivedEvent);
			}
		}
		
		/**
		 * Dispatch upload attachment received event
		 * */
		public function dispatchUploadAttachmentResultsEvent(successful:Boolean, attachments:Array, data:Object):void {
			var uploadAttachmentEvent:RadiateEvent = new RadiateEvent(RadiateEvent.ATTACHMENT_UPLOADED, false, false);
			
			if (hasEventListener(RadiateEvent.ATTACHMENT_UPLOADED)) {
				uploadAttachmentEvent.successful = successful;
				uploadAttachmentEvent.status = successful ? "ok" : "fault";
				uploadAttachmentEvent.data = attachments;
				uploadAttachmentEvent.selectedItem = data;
				dispatchEvent(uploadAttachmentEvent);
			}
		}
		
		/**
		 * Dispatch login results event
		 * */
		public function dispatchLoginResultsEvent(successful:Boolean, data:Object):void {
			var loginResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.LOGIN_RESULTS);
			
			if (hasEventListener(RadiateEvent.LOGIN_RESULTS)) {
				loginResultsEvent.data = data;
				loginResultsEvent.successful = successful;
				dispatchEvent(loginResultsEvent);
			}
		}
		
		/**
		 * Dispatch logout results event
		 * */
		public function dispatchLogoutResultsEvent(successful:Boolean, data:Object):void {
			var logoutResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.LOGOUT_RESULTS);
			
			if (hasEventListener(RadiateEvent.LOGOUT_RESULTS)) {
				logoutResultsEvent.data = data;
				logoutResultsEvent.successful = successful;
				dispatchEvent(logoutResultsEvent);
			}
		}
		
		/**
		 * Dispatch register results event
		 * */
		public function dispatchRegisterResultsEvent(successful:Boolean, data:Object):void {
			var registerResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.REGISTER_RESULTS);
			
			if (hasEventListener(RadiateEvent.REGISTER_RESULTS)) {
				registerResultsEvent.data = data;
				registerResultsEvent.successful = successful;
				dispatchEvent(registerResultsEvent);
			}
		}
		
		/**
		 * Dispatch change password results event
		 * */
		public function dispatchChangePasswordResultsEvent(successful:Boolean, data:Object):void {
			var changePasswordResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.CHANGE_PASSWORD_RESULTS);
			
			if (hasEventListener(RadiateEvent.CHANGE_PASSWORD_RESULTS)) {
				changePasswordResultsEvent.data = data;
				changePasswordResultsEvent.successful = successful;
				dispatchEvent(changePasswordResultsEvent);
			}
		}
		
		/**
		 * Dispatch lost password results event
		 * */
		public function dispatchLostPasswordResultsEvent(successful:Boolean, data:Object):void {
			var lostPasswordResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.LOST_PASSWORD_RESULTS);
			
			if (hasEventListener(RadiateEvent.LOST_PASSWORD_RESULTS)) {
				lostPasswordResultsEvent.data = data;
				lostPasswordResultsEvent.successful = successful;
				dispatchEvent(lostPasswordResultsEvent);
			}
		}
		
		/**
		 * Dispatch project deleted results event
		 * */
		public function dispatchProjectDeletedEvent(successful:Boolean, data:Object):void {
			var deleteProjectResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROJECT_DELETED);
			
			if (hasEventListener(RadiateEvent.PROJECT_DELETED)) {
				deleteProjectResultsEvent.data = data;
				deleteProjectResultsEvent.successful = successful;
				deleteProjectResultsEvent.status = successful ? "ok" : "error";
				dispatchEvent(deleteProjectResultsEvent);
			}
		}
		
		/**
		 * Dispatch document deleted results event
		 * */
		public function dispatchDocumentDeletedEvent(successful:Boolean, data:Object):void {
			var deleteDocumentResultsEvent:RadiateEvent = new RadiateEvent(RadiateEvent.DOCUMENT_DELETED);
			
			if (hasEventListener(RadiateEvent.DOCUMENT_DELETED)) {
				deleteDocumentResultsEvent.data = data;
				deleteDocumentResultsEvent.successful = successful;
				deleteDocumentResultsEvent.status = successful ? "ok" : "error";
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
		
		/**
		 * Dispatch target change event
		 * */
		public function dispatchTargetChangeEvent(target:*, multipleSelection:Boolean = false):void {
			if (importingDocument) return;
			var targetChangeEvent:RadiateEvent = new RadiateEvent(RadiateEvent.TARGET_CHANGE, false, false, target, null, null, multipleSelection);
			
			if (hasEventListener(RadiateEvent.TARGET_CHANGE)) {
				targetChangeEvent.selectedItem = target && target is Array ? target[0] : target;
				targetChangeEvent.targets = ArrayUtil.toArray(target);
				dispatchEvent(targetChangeEvent);
			}
		}
		
		/**
		 * Dispatch scale change event
		 * */
		public function dispatchScaleChangeEvent(target:*, scaleX:Number = NaN, scaleY:Number = NaN):void {
			var scaleChangeEvent:RadiateEvent = new RadiateEvent(RadiateEvent.SCALE_CHANGE, false, false, target, null, null);
			
			if (hasEventListener(RadiateEvent.SCALE_CHANGE)) {
				scaleChangeEvent.scaleX = scaleX;
				scaleChangeEvent.scaleY = scaleY;
				dispatchEvent(scaleChangeEvent);
			}
		}
		
		/**
		 * Dispatch document size change event
		 * */
		public function dispatchDocumentSizeChangeEvent(target:*):void {
			var scaleChangeEvent:RadiateEvent = new RadiateEvent(RadiateEvent.DOCUMENT_SIZE_CHANGE, false, false, target, null, null);
			
			if (hasEventListener(RadiateEvent.DOCUMENT_SIZE_CHANGE)) {
				dispatchEvent(scaleChangeEvent);
			}
		}
		
		/**
		 * Dispatch preview event
		 * */
		public function dispatchPreviewEvent(code:String, type:String):void {
			var previewEvent:RadiateEvent = new RadiateEvent(RadiateEvent.REQUEST_PREVIEW);
			
			if (hasEventListener(RadiateEvent.REQUEST_PREVIEW)) {
				previewEvent.previewType = type;
				previewEvent.value = code;
				dispatchEvent(previewEvent);
			}
		}
		
		
		/**
		 * Dispatch code updated event. Type is usually "HTML". 
		 * */
		public function dispatchCodeUpdatedEvent(code:String, type:String, openInWindow:Boolean = false):void {
			var codeUpdatedEvent:RadiateEvent = new RadiateEvent(RadiateEvent.CODE_UPDATED);
			
			if (hasEventListener(RadiateEvent.CODE_UPDATED)) {
				codeUpdatedEvent.previewType = type;
				codeUpdatedEvent.value = code;
				codeUpdatedEvent.openInBrowser = openInWindow;
				dispatchEvent(codeUpdatedEvent);
			}
		}
		
		/**
		 * Dispatch color selected event
		 * */
		public function dispatchColorSelectedEvent(color:uint, invalid:Boolean = false):void {
			var colorSelectedEvent:RadiateEvent = new RadiateEvent(RadiateEvent.COLOR_SELECTED);
			
			if (hasEventListener(RadiateEvent.COLOR_SELECTED)) {
				colorSelectedEvent.color = color;
				colorSelectedEvent.invalid = invalid;
				dispatchEvent(colorSelectedEvent);
			}
		}
		
		/**
		 * Dispatch property selected event
		 * */
		public function dispatchPropertySelectedEvent(property:String, node:MetaData = null):void {
			var colorSelectedEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROPERTY_SELECTED);
			
			if (hasEventListener(RadiateEvent.PROPERTY_SELECTED)) {
				colorSelectedEvent.property = property;
				colorSelectedEvent.selectedItem = node;
				dispatchEvent(colorSelectedEvent);
			}
		}
		
		/**
		 * Dispatch color preview event
		 * */
		public function dispatchColorPreviewEvent(color:uint, invalid:Boolean = false):void {
			var colorPreviewEvent:RadiateEvent = new RadiateEvent(RadiateEvent.COLOR_PREVIEW);
			
			if (hasEventListener(RadiateEvent.COLOR_PREVIEW)) {
				colorPreviewEvent.color = color;
				colorPreviewEvent.invalid = invalid;
				dispatchEvent(colorPreviewEvent);
			}
		}
		
		/**
		 * Dispatch canvas change event
		 * */
		public function dispatchCanvasChangeEvent(canvas:*, canvasBackgroundParent:*, scroller:Scroller):void {
			var targetChangeEvent:RadiateEvent = new RadiateEvent(RadiateEvent.CANVAS_CHANGE);
			
			if (hasEventListener(RadiateEvent.CANVAS_CHANGE)) {
				dispatchEvent(targetChangeEvent);
			}
		}
		
		/**
		 * Dispatch tool change event
		 * */
		public function dispatchToolChangeEvent(value:ITool):void {
			var toolChangeEvent:RadiateEvent = new RadiateEvent(RadiateEvent.TOOL_CHANGE);
			
			if (hasEventListener(RadiateEvent.TOOL_CHANGE)) {
				toolChangeEvent.selectedItem = target && target is Array ? target[0] : target;
				toolChangeEvent.targets = targets;
				toolChangeEvent.tool = value;
				dispatchEvent(toolChangeEvent);
			}
		}
		
		/**
		 * Dispatch target change event with a null target. 
		 * */
		public function dispatchTargetClearEvent():void {
			var targetChangeEvent:RadiateEvent = new RadiateEvent(RadiateEvent.TARGET_CHANGE);
			
			if (hasEventListener(RadiateEvent.TARGET_CHANGE)) {
				dispatchEvent(targetChangeEvent);
			}
		}
		
		/**
		 * Dispatch property change event
		 * */
		public function dispatchPropertyChangeEvent(target:*, changes:Array, properties:Array, multipleSelection:Boolean = false):void {
			if (importingDocument) return;
			var propertyChangeEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROPERTY_CHANGED, false, false, target, changes, properties, multipleSelection);
			
			if (hasEventListener(RadiateEvent.PROPERTY_CHANGED)) {
				propertyChangeEvent.properties = properties;
				propertyChangeEvent.changes = changes;
				propertyChangeEvent.multipleSelection = multipleSelection;
				propertyChangeEvent.selectedItem = target && target is Array ? target[0] : target;
				propertyChangeEvent.targets = ArrayUtil.toArray(target);
				dispatchEvent(propertyChangeEvent);
			}
		}
		
		/**
		 * Dispatch object selected event
		 * */
		public function dispatchObjectSelectedEvent(target:*):void {
			var objectSelectedEvent:RadiateEvent = new RadiateEvent(RadiateEvent.OBJECT_SELECTED, false, false, target);
			
			if (hasEventListener(RadiateEvent.OBJECT_SELECTED)) {
				dispatchEvent(objectSelectedEvent);
			}
		}
		
		/**
		 * Dispatch add items event
		 * */
		public function dispatchAddEvent(target:*, changes:Array, properties:Array, multipleSelection:Boolean = false):void {
			if (importingDocument) return;
			var event:RadiateEvent = new RadiateEvent(RadiateEvent.ADD_ITEM, false, false, target, changes, properties, multipleSelection);
			var length:int = changes ? changes.length : 0;
			
			if (hasEventListener(RadiateEvent.ADD_ITEM)) {
				event.properties = properties;
				event.changes = changes;
				event.multipleSelection = multipleSelection;
				event.selectedItem = target && target is Array ? target[0] : target;
				event.targets = ArrayUtil.toArray(target);
				
				for (var i:int;i<length;i++) {
					if (changes[i] is AddItems) {
						event.addItemsInstance = changes[i];
						event.moveItemsInstance = changes[i];
					}
				}
				dispatchEvent(event);
			}
		}
		
		/**
		 * Dispatch add items event
		 * */
		public function dispatchMoveEvent(target:*, changes:Array, properties:Array, multipleSelection:Boolean = false):void {
			if (importingDocument) return;
			var event:RadiateEvent = new RadiateEvent(RadiateEvent.MOVE_ITEM, false, false, target, changes, properties, multipleSelection);
			var length:int = changes ? changes.length : 0;
			
			if (hasEventListener(RadiateEvent.MOVE_ITEM)) {
				event.properties = properties;
				event.changes = changes;
				event.multipleSelection = multipleSelection;
				event.selectedItem = target && target is Array ? target[0] : target;
				event.targets = ArrayUtil.toArray(target);
				
				for (var i:int;i<length;i++) {
					if (changes[i] is AddItems) {
						event.addItemsInstance = changes[i];
						event.moveItemsInstance = changes[i];
					}
				}
				dispatchEvent(event);
			}
		}
		
		/**
		 * Dispatch remove items event
		 * */
		public function dispatchRemoveItemsEvent(target:*, changes:Array, properties:*, multipleSelection:Boolean = false):void {
			var event:RadiateEvent = new RadiateEvent(RadiateEvent.REMOVE_ITEM, false, false, target, changes, properties, multipleSelection);
			var length:int = changes ? changes.length : 0;
			
			if (hasEventListener(RadiateEvent.REMOVE_ITEM)) {
				event.properties = properties;
				event.changes = changes;
				event.multipleSelection = multipleSelection;
				event.selectedItem = target && target is Array ? target[0] : target;
				event.targets = ArrayUtil.toArray(target);
				
				for (var i:int;i<length;i++) {
					if (changes[i] is AddItems) {
						event.addItemsInstance = changes[i];
						event.moveItemsInstance = changes[i];
					}
				}
				dispatchEvent(event);
			}
		}
		
		/**
		 * Dispatch to invoke property edit event
		 * */
		public function dispatchTargetPropertyEditEvent(target:Object, changes:Array, properties:Array, multipleSelection:Boolean = false):void {
			var propertyEditEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROPERTY_EDIT, false, false, target, changes, properties, null, multipleSelection);
			
			if (hasEventListener(RadiateEvent.PROPERTY_EDIT)) {
				dispatchEvent(propertyEditEvent);
			}
		}
		
		/**
		 * Dispatch document change event
		 * */
		public function dispatchDocumentChangeEvent(document:IDocument):void {
			var documentChangeEvent:RadiateEvent = new RadiateEvent(RadiateEvent.DOCUMENT_CHANGE, false, false, document);
			
			if (hasEventListener(RadiateEvent.DOCUMENT_CHANGE)) {
				dispatchEvent(documentChangeEvent);
			}
		}
		
		/**
		 * Dispatch document rename event
		 * */
		public function dispatchDocumentRenameEvent(document:IDocument, name:String):void {
			var documentRenameEvent:RadiateEvent = new RadiateEvent(RadiateEvent.DOCUMENT_RENAME, false, false, document);
			
			if (hasEventListener(RadiateEvent.DOCUMENT_RENAME)) {
				dispatchEvent(documentRenameEvent);
			}
		}
		
		/**
		 * Dispatch project rename event
		 * */
		public function dispatchProjectRenameEvent(project:IProject, name:String):void {
			var projectRenameEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROJECT_RENAME, false, false, project);
			
			if (hasEventListener(RadiateEvent.PROJECT_RENAME)) {
				dispatchEvent(projectRenameEvent);
			}
		}
		
		/**
		 * Dispatch documents set
		 * */
		public function dispatchDocumentsSetEvent(documents:Array):void {
			var documentChangeEvent:RadiateEvent = new RadiateEvent(RadiateEvent.DOCUMENTS_SET, false, false, documents);
			
			if (hasEventListener(RadiateEvent.DOCUMENTS_SET)) {
				dispatchEvent(documentChangeEvent);
			}
		}
		
		/**
		 * Dispatch document opening event
		 * */
		public function dispatchDocumentOpeningEvent(document:IDocument, isPreview:Boolean = false):Boolean {
			var documentOpeningEvent:RadiateEvent = new RadiateEvent(RadiateEvent.DOCUMENT_OPENING, false, true, document);
			var dispatched:Boolean;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_OPENING)) {
				dispatched = dispatchEvent(documentOpeningEvent);
			}
			
			return dispatched;
		}
		
		/**
		 * Dispatch document open event
		 * */
		public function dispatchDocumentOpenEvent(document:IDocument):void {
			var documentOpenEvent:RadiateEvent = new RadiateEvent(RadiateEvent.DOCUMENT_OPEN, false, false);
			
			if (hasEventListener(RadiateEvent.DOCUMENT_OPEN)) {
				documentOpenEvent.selectedItem = document;
				dispatchEvent(documentOpenEvent);
			}
		}
		
		/**
		 * Dispatch document removed event
		 * */
		public function dispatchDocumentRemovedEvent(document:IDocument, successful:Boolean = true):void {
			var documentRemovedEvent:RadiateEvent = new RadiateEvent(RadiateEvent.DOCUMENT_REMOVED, false, false);
			
			if (hasEventListener(RadiateEvent.DOCUMENT_REMOVED)) {
				documentRemovedEvent.successful = successful;
				documentRemovedEvent.selectedItem = document;
				dispatchEvent(documentRemovedEvent);
			}
		}
		
		/**
		 * Dispatch document save as complete event
		 * */
		public function dispatchProjectSavedEvent(project:IProject):void {
			var projectSaveEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROJECT_SAVED, false, false);
			
			if (hasEventListener(RadiateEvent.PROJECT_SAVED)) {
				
				projectSaveEvent.selectedItem = project;
				dispatchEvent(projectSaveEvent);
			}
		}
		
		/**
		 * Dispatch document save complete event
		 * */
		public function dispatchDocumentSaveCompleteEvent(document:IDocument):void {
			var documentSaveAsCompleteEvent:RadiateEvent = new RadiateEvent(RadiateEvent.DOCUMENT_SAVE_COMPLETE, false, false, document);
			
			if (hasEventListener(RadiateEvent.DOCUMENT_SAVE_COMPLETE)) {
				dispatchEvent(documentSaveAsCompleteEvent);
			}
		}
		
		/**
		 * Dispatch document not saved event
		 * */
		public function dispatchDocumentSaveFaultEvent(document:IDocument):void {
			var documentSaveFaultEvent:RadiateEvent = new RadiateEvent(RadiateEvent.DOCUMENT_SAVE_FAULT, false, false, document);
			
			if (hasEventListener(RadiateEvent.DOCUMENT_SAVE_FAULT)) {
				dispatchEvent(documentSaveFaultEvent);
			}
		}
		
		/**
		 * Dispatch document save as cancel event
		 * */
		public function dispatchDocumentSaveAsCancelEvent(document:IDocument):void {
			var documentSaveAsCancelEvent:RadiateEvent = new RadiateEvent(RadiateEvent.DOCUMENT_SAVE_AS_CANCEL, false, false, document);
			
			if (hasEventListener(RadiateEvent.DOCUMENT_SAVE_AS_CANCEL)) {
				dispatchEvent(documentSaveAsCancelEvent);
			}
		}
		
		
		/**
		 * Dispatch document add event
		 * */
		public function dispatchDocumentAddedEvent(document:IDocument):void {
			var documentAddedEvent:RadiateEvent = new RadiateEvent(RadiateEvent.DOCUMENT_ADDED, false, false, document, null, null);
			
			if (hasEventListener(RadiateEvent.DOCUMENT_ADDED)) {
				dispatchEvent(documentAddedEvent);
			}
		}
		
		/**
		 * Dispatch project closing event
		 * */
		public function dispatchProjectClosingEvent(project:IProject):void {
			var projectClosingEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROJECT_CLOSING, false, false, project, null, null);
			
			if (hasEventListener(RadiateEvent.PROJECT_CLOSING)) {
				dispatchEvent(projectClosingEvent);
			}
		}
		
		/**
		 * Dispatch project closed event
		 * */
		public function dispatchProjectOpenedEvent(project:IProject):void {
			var projectOpenedEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROJECT_OPENED, false, false, project, null, null);
			
			if (hasEventListener(RadiateEvent.PROJECT_OPENED)) {
				dispatchEvent(projectOpenedEvent);
			}
		}
		
		/**
		 * Dispatch project closed event
		 * */
		public function dispatchProjectClosedEvent(project:IProject):void {
			var projectClosedEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROJECT_CLOSED, false, false, project, null, null);
			
			if (hasEventListener(RadiateEvent.PROJECT_CLOSED)) {
				dispatchEvent(projectClosedEvent);
			}
		}
		
		/**
		 * Dispatch project removed event
		 * */
		public function dispatchProjectRemovedEvent(project:IProject):void {
			var projectRemovedEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROJECT_REMOVED, false, false, project, null, null);
			
			if (hasEventListener(RadiateEvent.PROJECT_REMOVED)) {
				dispatchEvent(projectRemovedEvent);
			}
		}
		
		/**
		 * Dispatch project change event
		 * */
		public function dispatchProjectChangeEvent(project:IProject, multipleSelection:Boolean = false):void {
			var projectChangeEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROJECT_CHANGE, false, false, project, null, null, multipleSelection);
			
			if (hasEventListener(RadiateEvent.PROJECT_CHANGE)) {
				dispatchEvent(projectChangeEvent);
			}
		}
		
		/**
		 * Dispatch projects set event
		 * */
		public function dispatchProjectsSetEvent(projects:Array, multipleSelection:Boolean = false):void {
			var projectChangeEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROJECTS_SET, false, false, projects, null, null, multipleSelection);
			
			if (hasEventListener(RadiateEvent.PROJECTS_SET)) {
				dispatchEvent(projectChangeEvent);
			}
		}
		
		/**
		 * Dispatch project created event
		 * */
		public function dispatchProjectAddedEvent(project:IProject):void {
			var projectCreatedEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROJECT_ADDED, false, false, project, null, null);
			
			if (hasEventListener(RadiateEvent.PROJECT_ADDED)) {
				dispatchEvent(projectCreatedEvent);
			}
		}
		
		/**
		 * Dispatch project created event
		 * */
		public function dispatchProjectCreatedEvent(project:IProject):void {
			var projectCreatedEvent:RadiateEvent = new RadiateEvent(RadiateEvent.PROJECT_CREATED, false, false, project, null, null);
			
			if (hasEventListener(RadiateEvent.PROJECT_CREATED)) {
				dispatchEvent(projectCreatedEvent);
			}
		}
		
		/**
		 * Dispatch a history change event
		 * */
		public function dispatchHistoryChangeEvent(newIndex:int, oldIndex:int):void {
			var event:RadiateEvent = new RadiateEvent(RadiateEvent.HISTORY_CHANGE);
			
			if (hasEventListener(RadiateEvent.HISTORY_CHANGE)) {
				event.newIndex = newIndex;
				event.oldIndex = oldIndex;
				event.historyEventItem = getHistoryItemAtIndex(newIndex);
				dispatchEvent(event);
			}
		}
		
		/**
		 * Sets the logging target
		 * */
		public static function setLoggingTarget(target:AbstractTarget = null, category:String = null, consoleObject:Object = null):void {
			
			// Log only messages for the classes in the mx.rpc.* and 
			// mx.messaging packages.
			//logTarget.filters=["mx.rpc.*","mx.messaging.*"];
			//var filters:Array = ["mx.rpc.*", "mx.messaging.*"];
			//var filters:Array = ["mx.rpc.*", "mx.messaging.*"];
			
			// Begin logging.
			if (target) {
				logTarget = target;
				//logTarget.filters = filters;
				logTarget.level = LogEventLevel.ALL;
				Log.addTarget(target);
			}
			
			// set reference to logger
			if (category) {
				log = Log.getLogger(category);
			}
			else {
				log = Log.getLogger(RADIATE_LOG);
			}
			
			if (consoleObject) {
				console = consoleObject;
			}
			
		}
		
		/**
		 * Creates the list of components and tools.
		 * */
		public static function initialize():void {
			var componentsXML:XML 	= new XML(new Radii8LibrarySparkAssets.sparkManifestDefaults());
			var toolsXML:XML 		= new XML(new Radii8LibraryToolAssets.toolsManifestDefaults());
			var inspectorsXML:XML 	= new XML(new Radii8LibraryInspectorAssets.inspectorsManifestDefaults());
			var devicesXML:XML		= new XML(new Radii8LibraryDeviceAssets.devicesManifestDefaults());
			
			createSettingsData();

			createSavedData();
			
			createComponentList(componentsXML);
			
			createInspectorsList(inspectorsXML);
			
			createToolsList(toolsXML);
			
			createDevicesList(devicesXML);
		}
		
		/**
		 * Startup 
		 * */
		public static function startup():void {
			
			//ExternalInterface.call("Radiate.getInstance");
			ExternalInterface.call("Radiate.instance.setFlashInstance", ExternalInterface.objectID);
			
			//instance.getLoggedInStatus();
		}
		
		/**
		 * Creates the list of components.
		 * */
		public static function createComponentList(xml:XML):void {
			var length:uint;
			var items:XMLList;
			var className:String;
			var skinClassName:String;
			var inspectors:Array;
			var hasDefinition:Boolean;
			var classType:Object;
			var includeItem:Boolean;
			var attributes:XMLList;
			var attributesLength:int;
			var defaults:Object;
			var propertyName:String;
			var item:XML;
			
			
			// get list of component classes 
			items = XML(xml).component;
			
			length = items.length();
			
			for (var i:int;i<length;i++) {
				item = items[i];
				
				var name:String = String(item.id);
				className = item.attribute("class");
				skinClassName = item.attribute("skinClass");
				//inspectors = item.inspector;
				
				includeItem = item.attribute("include")=="false" ? false : true;
				
				
				
				// check that definitions exist in domain
				// skip any support classes
				if (className.indexOf("mediaClasses")==-1 && 
					className.indexOf("gridClasses")==-1 &&
					className.indexOf("windowClasses")==-1 &&
					className.indexOf("supportClasses")==-1) {
					
					hasDefinition = ApplicationDomain.currentDomain.hasDefinition(className);
					
					if (hasDefinition) {
						classType = ApplicationDomain.currentDomain.getDefinition(className);
						
						// need to check if we have the skin as well
						
						//hasDefinition = ApplicationDomain.currentDomain.hasDefinition(skinClassName);
						
						if (hasDefinition) {
							
							// get default values
							if (item.defaults) {
								attributes = item.defaults.attributes();
								attributesLength = attributes.length();
								defaults = {};
								
								for each (var value:Object in attributes) {
									propertyName = String(value.name());
									
									if (propertyName=="dataProvider") {
										var array:Array = String(value).split(",");
										defaults[propertyName] = new ArrayCollection(array);
									}
									else {
										defaults[propertyName] = String(value);
									}
								}
							}
							
							addComponentType(item.@id, className, classType, inspectors, null, defaults, null, includeItem);
						}
						else {
							log.error("Component skin class, '" + skinClassName + "' not found for '" + className + "'.");
						}
					}
					else {
						log.error("Component class not found: " + className);
					}
					
				}
				else {
					// delete support classes
					// may need to refactor why we are including them in the first place
					delete items[i];
					length--;
				}
			}
			
			// componentDescriptions should now be populated
		}
		
		/**
		 * Creates the list of inspectors.
		 * */
		public static function createInspectorsList(xml:XML):void {
			var length:uint;
			var inspectorsLength:uint;
			var items:XMLList;
			var className:String;
			var skinClassName:String;
			var inspectorClassName:String;
			var hasDefinition:Boolean;
			var classType:Object;
			var includeItem:Boolean;
			var attributes:XMLList;
			var attributesLength:int;
			var defaults:Object;
			var propertyName:String;
			var item:XML;
			var inspectorItems:XMLList;
			var inspector:XML;
			var inspectableClass:InspectableClass;
			var inspectorData:InspectorData;
			
			
			// get list of inspector classes 
			items = XML(xml).item;
			
			length = items.length();
			
			// add inspectable classes to the dictionary
			for (var i:int;i<length;i++) {
				inspectableClass = new InspectableClass(items[i]);
				className = inspectableClass.className;
				
				if (inspectableClassesDictionary[className]==null) {
					inspectableClassesDictionary[className] = inspectableClass;
				}
				else {
					log.warn("Inspectable class, '" + className + "', was listed more than once during import.");
				}
					
			}
			
			// check that definitions exist in domain
			for each (inspectableClass in inspectableClassesDictionary) {
			
				length = inspectableClass.inspectors.length;
				j = 0;
				
				for (var j:int;j<length;j++) {
					inspectorData = inspectableClass.inspectors[j];
					className = inspectorData.className;
					
					if (inspectorsDictionary[className]==null) {
						
						hasDefinition = ApplicationDomain.currentDomain.hasDefinition(className);
						
						if (hasDefinition) {
							classType = ApplicationDomain.currentDomain.getDefinition(className);
						}
						else {
							log.error("Inspector class not found: " + className);
						}
						
						// not passing in classType now since we may load it in later dynamically
						addInspectorType(inspectorData.name, className, null, inspectorData.icon, defaults);
					}
					else {
						//log.warn("Inspector class: " + className + ", is already in the dictionary");
					}
				}
			}
			
			// inspectorsInstancesDictionary should now be populated
		}
		
		
		/**
		 * Creates the list of tools.
		 * */
		public static function createToolsList(xml:XML):void {
			var inspectorClassName:String;
			var hasDefinition:Boolean;
			var toolClassDefinition:Object;
			var inspectorClassDefinition:Object;
			var inspectorClassFactory:ClassFactory;
			var toolClassFactory:ClassFactory;
			var items:XMLList;
			var className:String;
			var includeItem:Boolean;
			var attributes:XMLList;
			var length:uint;
			var attributesLength:int;
			var defaults:Object;
			var propertyName:String;
			var toolInstance:ITool;
			var inspectorInstance:UIComponent;
			var name:String;
			var cursorItems:XMLList;
			var cursorItem:XML;
			var cursorName:String;
			var cursors:Dictionary;
			var cursorsCount:int;
			var cursorData:MouseCursorData;
			var cursorBitmapDatas:Vector.<BitmapData>;
			var cursorBitmap:Bitmap;
			var cursorClass:Class;
			var cursorID:String;
			var cursorX:int;
			var cursorY:int;
			var item:XML;
			
			// get list of tool classes 
			items = XML(xml).tool;
			
			length = items.length();
			
			for (var i:int;i<length;i++) {
				item = items[i];
				
				name = String(item.id);
				className = item.attribute("class");
				inspectorClassName = item.attribute("inspector");
				cursorItems = item..cursor;
				
				includeItem = item.attribute("include")=="false" ? false : true;
				
				if (!includeItem) continue;
				
				hasDefinition = ApplicationDomain.currentDomain.hasDefinition(className);
				
				if (hasDefinition) {
					toolClassDefinition = ApplicationDomain.currentDomain.getDefinition(className);
					
					
					// get default values
					if (item.defaults) {
						attributes = item.defaults.attributes();
						attributesLength = attributes.length();
						defaults = {};
						
						for each (var value:Object in attributes) {
							propertyName = String(value.name());
							
							if (propertyName=="dataProvider") {
								defaults[propertyName] = new ArrayCollection(String(value).split(","));
							}
							else {
								defaults[propertyName] = String(value);
							}
						}
					}
					
					// create tool
					toolClassFactory = new ClassFactory(toolClassDefinition as Class);
					toolClassFactory.properties = defaults;
					toolInstance = toolClassFactory.newInstance();
					
					
					// create inspector
					if (inspectorClassName!="") {
						hasDefinition = ApplicationDomain.currentDomain.hasDefinition(inspectorClassName);
						
						if (hasDefinition) {
							inspectorClassDefinition = ApplicationDomain.currentDomain.getDefinition(inspectorClassName);
							
							// Create tool inspector
							inspectorClassFactory = new ClassFactory(inspectorClassDefinition as Class);
							//classFactory.properties = defaults;
							inspectorInstance = inspectorClassFactory.newInstance();
					
						}
						else {
							var errorMessage:String = "Could not find inspector, '" + inspectorClassName + "' for tool, '" + className + "'. ";
							errorMessage += "You may need to add a reference to it in RadiateReferences.";
							log.error(errorMessage);
						}
					}
					
					
					cursorsCount = cursorItems.length();
					
					if (cursorsCount>0) {
						cursors = new Dictionary(false);
					}

					// create mouse cursors
					for (var j:int=0;j<cursorsCount;j++) {
						cursorItem = cursorItems[j];
						cursorName = cursorItem.@name.toString();
						cursorX = int(cursorItem.@x.toString());
						cursorY = int(cursorItem.@y.toString());
						cursorID = cursorName != "" ? className + "." + cursorName : className;
			
						// Create a MouseCursorData object 
						cursorData = new MouseCursorData();
						
						// Specify the hotspot 
						cursorData.hotSpot = new Point(cursorX, cursorY); 
						
						// Pass the cursor bitmap to a BitmapData Vector 
						cursorBitmapDatas = new Vector.<BitmapData>(1, true); 
						
						// Create the bitmap cursor 
						// The bitmap must be 32x32 pixels or smaller, due to an OS limitation
						//CursorClass = Radii8LibraryToolAssets.EyeDropper;
						
						if (cursorName) {
							cursorClass = toolClassDefinition[cursorName];
						}
						else {
							cursorClass = toolClassDefinition["Cursor"];
						}
						
						cursorBitmap = new cursorClass();
						
						// Pass the value to the bitmapDatas vector 
						cursorBitmapDatas[0] = cursorBitmap.bitmapData;
						
						// Assign the bitmap to the MouseCursor object 
						cursorData.data = cursorBitmapDatas;
						
						// Register the MouseCursorData to the Mouse object with an alias 
						Mouse.registerCursor(cursorID, cursorData);
						
						cursors[cursorName] = {cursorData:cursorData, id:cursorID};
					}
					
					if (cursorsCount>0) {
						mouseCursors[className] = cursors;
					}
					
					//trace("tool cursors:", cursors);
					var toolDescription:ComponentDescription = addToolType(item.@id, className, toolClassDefinition, toolInstance, inspectorClassName, null, defaults, null, cursors);
					//trace("tool cursors:", toolDescription.cursors);
				}
				else {
					//trace("Tool class not found: " + classDefinition);
					log.error("Tool class not found: " + toolClassDefinition);
				}
				
			}
			
			// toolDescriptions should now be populated
		}
		
		/**
		 * Creates the list of devices.
		 * */
		public static function createDevicesList(xml:XML):void {
			var includeItem:Boolean;
			var items:XMLList;
			var length:uint;
			var name:String;
			var item:XML;
			var device:Device;
			var type:String;
			
			const RES_WIDTH:String = "resolutionWidth";
			const RES_HEIGHT:String = "resolutionHeight";
			const USABLE_WIDTH_PORTRAIT:String = "usableWidthPortrait";
			const USABLE_HEIGHT_PORTRAIT:String = "usableHeightPortrait";
			const USABLE_WIDTH_LANDSCAPE:String = "usableWidthLandscape";
			const USABLE_HEIGHT_LANDSCAPE:String = "usableHeightLandscape";
			
			
			// get list of device classes 
			items = XML(xml).size;
			
			length = items.length();
			
			for (var i:int;i<length;i++) {
				item = items[i];
				
				name = item.attribute("name");
				type = item.attribute("type");
				
				device = new Device();
				device.name = name;
				device.type = type;
				
				if (type=="device") {
					device.ppi 					= item.attribute("ppi");
					
					device.resolutionWidth 		= item.attribute(RES_WIDTH);
					device.resolutionHeight 	= item.attribute(RES_HEIGHT);
					device.usableWidthPortrait 	= item.attribute(USABLE_WIDTH_PORTRAIT);
					device.usableHeightPortrait = item.attribute(USABLE_HEIGHT_PORTRAIT);
					device.usableWidthLandscape = item.attribute(USABLE_WIDTH_LANDSCAPE);
					device.usableHeightLandscape = item.attribute(USABLE_HEIGHT_LANDSCAPE);
				}
				else if (type=="screen") {
					device.ppi 					= item.attribute("ppi");
					device.resolutionWidth 		= item.attribute(RES_WIDTH);
					device.resolutionHeight 	= item.attribute(RES_HEIGHT);
					continue;
				}
				
				includeItem = item.attribute("include")=="false" ? false : true;
				
				deviceCollections.addItem(device);
				
			}
			
			// deviceDescriptions should now be populated
		}
		
		/**
		 * Helper method to get the ID of the mouse cursor by name.
		 * 
		 * */
		public function getMouseCursorID(tool:ITool, name:String = "Cursor"):String {
			var component:ComponentDescription = getToolDescription(tool);
			
			
			if (component.cursors && component.cursors[name]) {
				return component.cursors[name].id;
			}
			
			return null;
		}
		
		//----------------------------------
		//  target
		//----------------------------------
		
		/**
		 * Use setTarget() or setTargets() method to set the target. 
		 * */
		public function get target():Object {
			if (_targets.length > 0)
				return _targets[0];
			else
				return null;
		}
		
		/**
		 *  @private
		 */
		/*[Bindable]
		public function set target(value:Object):void {
			if (_targets.length == 1 && target==value) return;
			
			_targets.splice(0);
			
			if (value) {
				_targets[0] = value;
			}
		}*/

		
		//----------------------------------
		//  targets
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the targets property.
		 */
		private var _targets:Array = [];
		
		/**
		 * Selected targets
		 * */
		public function get targets():Array {
			return _targets;
		}
		
		/**
		 * Use setTargets() to set the targets
		 *  @private
		 * */
		/*public function set targets(value:Array):void {
			// remove listeners from previous targets
			var n:int = _targets.length;
			
			for (var i:int = n - 1; i >= 0; i--) {
				if (_targets[i] == null) {
					continue;
				}
				
				//removeHandlers(_targets[i]);
			}
			
			// Strip out null values.
			// Binding will trigger again when the null targets are created.
			n = value.length;
			
			for (i = n - 1; i >= 0; i--) {
				if (value[i] == null) {
					value.splice(i,1);
					continue;
				}
				
				//addHandlers(value[i]);
			}
			
			_targets = value;
			
		}*/
		
		//----------------------------------
		//  project
		//----------------------------------
		
		private var _selectedProject:IProject;
		
		/**
		 * Reference to the current project
		 * */
		public function get selectedProject():IProject {
			return _selectedProject;
		}
		
		/**
		 *  @private
		 */
		[Bindable(event="projectChange")]
		public function set selectedProject(value:IProject):void {
			if (value==_selectedProject) return;
			_selectedProject = value;
			
		}
		
		//----------------------------------
		//  document
		//----------------------------------
		
		private var _documentsTabNavigator:TabNavigator;

		/**
		 * Reference to the tab navigator that creates documents
		 * */
		public function get documentsTabNavigator():TabNavigator {
			return _documentsTabNavigator;
		}

		/**
		 * @private
		 */
		public function set documentsTabNavigator(value:TabNavigator):void {
			_documentsTabNavigator = value;
		}

		
		/**
		 * Reference to the tab that the document belongs to
		 * */
		public var documentsContainerDictionary:Dictionary = new Dictionary(true);
		
		/**
		 * Reference to the tab that the document preview belongs to
		 * */
		public var documentsPreviewDictionary:Dictionary = new Dictionary(true);
		
		private var _selectedDocument:IDocument;
		
		/**
		 * Get the current document.
		 * */
		public function get selectedDocument():IDocument {
			return _selectedDocument;
		}
		
		/**
		 *  @private
		 */
		[Bindable(event="documentChange")]
		public function set selectedDocument(value:IDocument):void {
			if (value==_selectedDocument) return;
			_selectedDocument = value;
		}
		
		/**
		 * Templates for creating new projects or documents
		 * */
		[Bindable]
		public var templates:Array;
		
		//----------------------------------
		//  documents
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the documents property.
		 */
		private var _documents:Array = [];
		
		/**
		 * Selected documents
		 * */
		public function get documents():Array {
			return _documents;
		}
		
		/**
		 * Selected documents
		 *  @private
		 * */
		[Bindable]
		public function set documents(value:Array):void {
			// the following comments are old possibly irrelevant...
			// remove listeners from previous documents
			var n:int = _documents.length;
			
			for (var i:int = n - 1; i >= 0; i--) {
				if (_documents[i] == null) {
					continue;
				}
				
				//removeHandlers(_documents[i]);
			}
			
			// Strip out null values.
			// Binding will trigger again when the null documents are created.
			n = value.length;
			
			for (i = n - 1; i >= 0; i--) {
				if (value[i] == null) {
					value.splice(i,1);
					continue;
				}
				
				//addHandlers(value[i]);
			}
			
			_documents = value;
			
		}
		
		
		//----------------------------------
		//  projects
		//----------------------------------
		
		
		/**
		 * Reference to the projects belongs to
		 * */
		public var projectsDictionary:Dictionary = new Dictionary(true);
		
		/**
		 *  @private
		 *  Storage for the projects property.
		 */
		private var _projects:Array = [];
		
		/**
		 * Selected projects
		 * */
		public function get projects():Array {
			return _projects;
		}
		
		/**
		 * Selected projects
		 *  @private
		 * */
		[Bindable]
		public function set projects(value:Array):void {
			_projects = value;
			
		}
		
		private var _attachments:Array = [];

		/**
		 * Attachments
		 * */
		[Bindable]
		public function get attachments():Array {
			return _attachments;
		}

		public function set attachments(value:Array):void {
			_attachments = value;
		}
		
		private var _assets:ArrayCollection = new ArrayCollection();

		/**
		 * Assets
		 * */
		[Bindable]
		public function get assets():ArrayCollection {
			return _assets;
		}

		public function set assets(value:ArrayCollection):void {
			_assets = value;
		}

		
		private var _toolLayer:IVisualElementContainer;

		/**
		 * Container that tools can draw too
		 * */
		public function get toolLayer():IVisualElementContainer {
			return _toolLayer;
		}

		/**
		 * @private
		 */
		public function set toolLayer(value:IVisualElementContainer):void {
			_toolLayer = value;
		}

		
		/**
		 * Default log target
		 * */
		public static var defaultLogTarget:AbstractTarget = new RadiateLogTarget();
		
		/**
		 * Attempt to support a console
		 * */
		public static var logTarget:AbstractTarget;
		
		private static var _log:ILogger;
		
		private static var _console:Object;
		
		public static var SETTINGS_DATA_NAME:String = "settingsData";
		public static var SAVED_DATA_NAME:String 	= "savedData";
		public static var WP_HOST:String = "http://www.radii8.com";
		public static var WP_PATH:String = "/r8m/";
		public static var WP_USER_PATH:String = "";
		public static var DEFAULT_DOCUMENT_WIDTH:int = 800;
		public static var DEFAULT_DOCUMENT_HEIGHT:int = 792;
		
		public static function getWPURL():String {
			return WP_HOST + WP_PATH + WP_USER_PATH;
		}
		
		/**
		 * Is true when preview is visible. This is manually set. 
		 * Needs refactoring. 
		 * */
		public var isPreviewVisible:Boolean;
		
		/**
		 * Settings 
		 * */
		public static var settings:Settings;
		
		/**
		 * Settings 
		 * */
		public static var savedData:SavedData;
		
		/**
		 * Collection of mouse cursors that can be added or removed to 
		 * */
		[Bindable]
		public static var mouseCursors:Dictionary = new Dictionary(true);
		
		//----------------------------------
		//
		//  Device Management
		// 
		//----------------------------------
		
		/**
		 * Collection of devices
		 * */
		[Bindable]
		public static var deviceCollections:ArrayCollection = new ArrayCollection();
		
		
		//----------------------------------
		//
		//  Tools Management
		// 
		//----------------------------------
		
		public var _selectedTool:ITool;
		
		/**
		 * Get selected tool.
		 * */
		public function get selectedTool():ITool {
			return _selectedTool;
		}
		
		/**
		 * Collection of tools that can be added or removed to 
		 * */
		[Bindable]
		public static var toolsDescriptions:ArrayCollection = new ArrayCollection();
		
		/**
		 * Add the named tool class to the list of available tools.
		 * 
		 * Not sure if we should create an instance here or earlier or later. 
		 * */
		public static function addToolType(name:String, className:String, classType:Object, instance:ITool, inspectorClassName:String, icon:Object = null, defaultProperties:Object=null, defaultStyles:Object=null, cursors:Dictionary = null):ComponentDescription {
			var definition:ComponentDescription;
			var length:uint = toolsDescriptions.length;
			var item:ComponentDescription;
			
			for (var i:uint;i<length;i++) {
				item = toolsDescriptions.getItemAt(i) as ComponentDescription;
				
				// check if it exists already
				if (item && item.classType==classType) {
					return item;
					//return false;
				}
			}
			
			definition = new ComponentDescription();
			
			definition.name = name;
			definition.icon = icon;
			definition.className = className;
			definition.classType = classType;
			definition.defaultStyles = defaultStyles;
			definition.defaultProperties = defaultProperties;
			definition.instance = instance;
			definition.inspectorClassName = inspectorClassName;
			definition.cursors = cursors;
			
			toolsDescriptions.addItem(definition);
			
			return definition;
		}
		
		/**
		 * Sets the selected tool
		 * */
		public function setTool(value:ITool, dispatchEvent:Boolean = true, cause:String = ""):void {
			
			if (selectedTool) {
				selectedTool.disable();
			}
			
			_selectedTool = value;
			
			if (selectedTool) {
				selectedTool.enable();
			}
			
			if (dispatchEvent) {
				instance.dispatchToolChangeEvent(selectedTool);
			}
			
		}
		
		/**
		 * Get tool description.
		 * */
		public function getToolDescription(instance:ITool):ComponentDescription {
			var length:int = toolsDescriptions.length;
			var componentDescription:ComponentDescription;
			
			for (var i:int;i<length;i++) {
				componentDescription = ComponentDescription(toolsDescriptions.getItemAt(i));
				
				if (componentDescription.instance==instance) {
					return componentDescription;
				}
			}
			
			return null;
		}
		
		/**
		 * Get tool by name.
		 * */
		public function getToolByName(name:String):ComponentDescription {
			var length:int = toolsDescriptions.length;
			var componentDescription:ComponentDescription;
			
			for (var i:int;i<length;i++) {
				componentDescription = ComponentDescription(toolsDescriptions.getItemAt(i));
				
				if (componentDescription.className==name) {
					return componentDescription;
				}
			}
			
			return null;
		}
		
		/**
		 * Get tool by type.
		 * */
		public function getToolByType(type:Class):ComponentDescription {
			var length:int = toolsDescriptions.length;
			var componentDescription:ComponentDescription;
			
			for (var i:int;i<length;i++) {
				componentDescription = ComponentDescription(toolsDescriptions.getItemAt(i));
				
				if (componentDescription.classType==type) {
					return componentDescription;
				}
			}
			
			return null;
		}
		
		//----------------------------------
		//
		//  Inspector Management
		// 
		//----------------------------------
		
		/**
		 * Collection of inspectors that can be added or removed to 
		 * */
		[Bindable]
		public static var inspectorsDescriptions:ArrayCollection = new ArrayCollection();
		
		/**
		 * Dictionary of classes that have inspectors
		 * */
		[Bindable]
		public static var inspectableClassesDictionary:Dictionary = new Dictionary();
		
		/**
		 * Dictionary of instances of inspectors searched by class name
		 * */
		[Bindable]
		public static var inspectorsDictionary:Dictionary = new Dictionary();
		
		/**
		 * Add the named inspector class to the list of available inspectors
		 * */
		public static function addInspectorType(name:String, className:String, classType:Object, icon:Object = null, defaults:Object=null):Boolean {
			var inspectorData:InspectorData;
			
			if (inspectorsDictionary[className]==null) {
				inspectorData = new InspectorData();
				inspectorData.name = name==null ? className : name;
				inspectorData.className = className;
				inspectorData.classType = classType;
				inspectorData.icon = icon;
				inspectorData.defaults = defaults;
				inspectorsDictionary[className] = inspectorData;
			}
			
			
			return true;
		}
		
		/**
		 * Gets inspector classes or null if the definition is not found.
		 * */
		public function getInspectableClassData(className:String):InspectableClass {
			var inspectableClass:InspectableClass = inspectableClassesDictionary[className];
			
			return inspectableClass;
		}
		
		/**
		 * Gets an instance of the inspector class or null if the definition is not found.
		 * */
		public function getInspectorInstance(className:String):IInspector {
			var inspectorData:InspectorData = inspectorsDictionary[className];
			
			if (inspectorData) {
				if (inspectorData.instance) {
					return inspectorData.instance;
				}
				
				var instance:IInspector = inspectorData.getInstance();
				
				return instance;
			
			}

			return null;
		}
		
		/**
		 * Gets an instance of the inspector class or null if the definition is not found.
		 * */
		public function getInspector(target:Object, domain:ApplicationDomain = null):IInspector {
			var className:String;
			
			if (target) {
				className = ClassUtils.getQualifiedClassName(target);
				
				var instance:IInspector = getInspectorInstance(className);
				
				return instance;
			}

			return null;
		}
		
		/**
		 * Gets array of inspector data for the given fully qualified class or object
		 * */
		public function getInspectors(target:Object):Array {
			var className:String;
			var inspectors:Array;
			var inspectorDataArray:Array;
			var inspectableClass:InspectableClass;
			var length:int;
			
			if (target==null) return [];
			
			if (target is Object) {
				className = ClassUtils.getQualifiedClassName(target);
				
				if (target is Application) {
					className = ClassUtils.getSuperClassName(target);
				}
			}
			
			if (target is String) {
				className = String(target);
			}
			
			className = className ? className.split("::").join(".") : className;
			
			inspectableClass = getInspectableClassData(className);
			
			if (inspectableClass) {
				return inspectableClass.inspectors;
			}

			return [];
		}
		
		//----------------------------------
		//
		//  Scale Management
		// 
		//----------------------------------
		
		/**
		 * Stops on the scale
		 * */
		public var scaleStops:Array = [.05,.0625,.0833,.125,.1666,.25,.333,.50,.667,1,1.25,1.50,1.75,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
		
		/**
		 * Increases the zoom of the target application to next value 
		 * */
		public function increaseScale(valueFrom:Number = NaN, dispatchEvent:Boolean = true):void {
			var newScale:Number;
			var currentScale:Number;
			
		
			if (isNaN(valueFrom)) {
				currentScale = Number(DisplayObject(selectedDocument.instance).scaleX.toFixed(4));
			}
			else {
				currentScale = valueFrom;
			}
			
			//newScale = DisplayObject(document).scaleX;
			
			for (var i:int=0;i<scaleStops.length;i++) {
				if (currentScale<scaleStops[i]) {
					newScale = scaleStops[i];
					break;
				}
			}
			
			if (i==scaleStops.length-1) {
				newScale = scaleStops[i];
			}
			
			newScale = Number(newScale.toFixed(4));
			
			setScale(newScale, dispatchEvent);
				
		}
		
		/**
		 * Decreases the zoom of the target application to next value 
		 * */
		public function decreaseScale(valueFrom:Number = NaN, dispatchEvent:Boolean = true):void {
			var newScale:Number;
			var currentScale:Number;
		
			if (isNaN(valueFrom)) {
				currentScale = Number(DisplayObject(selectedDocument.instance).scaleX.toFixed(4));
			}
			else {
				currentScale = valueFrom;
			}
			
			//newScale = DisplayObject(document).scaleX;
			
			for (var i:int=scaleStops.length;i--;) {
				if (currentScale>scaleStops[i]) {
					newScale = scaleStops[i];
					break;
				}
			}
			
			if (i==0) {
				newScale = scaleStops[i];
			}
			
			newScale = Number(newScale.toFixed(4));
			
			setScale(newScale, dispatchEvent);
				
		}
		
		/**
		 * Sets the zoom of the target application to value. 
		 * */
		public function setScale(value:Number, dispatchEvent:Boolean = true):void {
			
			if (selectedDocument && !isNaN(value) && value>0) {
				//DisplayObject(selectedDocument.instance).scaleX = value;
				//DisplayObject(selectedDocument.instance).scaleY = value;
				selectedDocument.scale = value;
				
				if (dispatchEvent) {
					dispatchScaleChangeEvent(selectedDocument, value, value);
				}
			}
		}
		
		/**
		 * Gets the scale of the target application. 
		 * */
		public function getScale():Number {
			
			if (selectedDocument && selectedDocument.instance && "scaleX" in selectedDocument.instance) {
				return Math.max(selectedDocument.instance.scaleX, selectedDocument.instance.scaleY);
			}
			
			return NaN;
		}
		
		/**
		 * Center the application
		 * */
		public function centerApplication(vertically:Boolean = true, verticallyTop:Boolean = true, totalDocumentPadding:int = 0):void {
			if (!canvasScroller) return;
			var viewport:IViewport = canvasScroller.viewport;
			var documentVisualElement:IVisualElement = IVisualElement(selectedDocument.instance);
			//var contentHeight:int = viewport.contentHeight * getScale();
			//var contentWidth:int = viewport.contentWidth * getScale();
			// get document size NOT scroll content size
			var contentHeight:int = documentVisualElement.height * getScale();
			var contentWidth:int = documentVisualElement.width * getScale();
			var newHorizontalPosition:int;
			var newVerticalPosition:int;
			var needsValidating:Boolean;
			var vsbWidth:int = canvasScroller.verticalScrollBar ? canvasScroller.verticalScrollBar.width : 11;
			var hsbHeight:int = canvasScroller.horizontalScrollBar ? canvasScroller.horizontalScrollBar.height : 11;
			var availableWidth:int = canvasScroller.width;// - vsbWidth;
			var availableHeight:int = canvasScroller.height;// - hsbHeight;
			
			if (LayoutManager.getInstance().isInvalid()) {
				needsValidating = true;
				//LayoutManager.getInstance().validateClient(canvasScroller as ILayoutManagerClient);
				//LayoutManager.getInstance().validateNow();
			}
			
			
			if (vertically) {
				// scroller height 359, content height 504, content height validated 550
				// if document is taller than available space and 
				// verticalTop is true then keep it at the top
				if (contentHeight > availableHeight && verticallyTop) {
					newVerticalPosition = canvasBackground.y - totalDocumentPadding;
					viewport.verticalScrollPosition = Math.max(0, newVerticalPosition);
				}
				else if (contentHeight > availableHeight) {
					newVerticalPosition = (contentHeight + hsbHeight - availableHeight) / 2;
					viewport.verticalScrollPosition = Math.max(0, newVerticalPosition);
				}
				else {
					// content height 384, scroller height 359, vsp 12
					newVerticalPosition = (availableHeight + hsbHeight - contentHeight) / 2;
					viewport.verticalScrollPosition = Math.max(0, newVerticalPosition);
				}
			}
			
			// if width of content is wider than canvasScroller width then center
			if (canvasScroller.width < contentWidth) {
				newHorizontalPosition = (contentWidth - availableWidth) / 2;
				viewport.horizontalScrollPosition = Math.max(0, newHorizontalPosition);
			}
			else {
				//newHorizontalPosition = (contentWidth - canvasScroller.width) / 2;
				//viewport.horizontalScrollPosition = Math.max(0, newHorizontalPosition);
			}
		}
		
		/**
		 * Restores the scale of the target application to 100%.
		 * */
		public function restoreDefaultScale(dispatchEvent:Boolean = true):void {
			if (selectedDocument) {
				setScale(1, dispatchEvent);
			}
		}
		
		/**
		 * Sets the scale to fit the available space. 
		 * */
		public function scaleToFit(dispatchEvent:Boolean = true):void {
			var width:int;
			var height:int;
			var availableWidth:int;
			var availableHeight:int;
			var widthScale:Number;
			var heightScale:Number;
			var newScale:Number;
			var documentVisualElement:IVisualElement = selectedDocument ? selectedDocument.instance as IVisualElement : null;
			
			if (documentVisualElement) {
			
				//width = DisplayObject(document).width;
				//height = DisplayObject(document).height;
				width = documentVisualElement.width;
				height = documentVisualElement.height;
				var vsbWidth:int = canvasScroller.verticalScrollBar ? canvasScroller.verticalScrollBar.width : 20;
				var hsbHeight:int = canvasScroller.horizontalScrollBar ? canvasScroller.horizontalScrollBar.height : 20;
				availableWidth = canvasScroller.width - vsbWidth*2.5;
				availableHeight = canvasScroller.height - hsbHeight*2.5;
				
				//var scrollerPaddedWidth:int = canvasScroller.width + documentPadding;
				//var scrollerPaddedHeight:int = canvasScroller.height + documentPadding;
			
                // if the visible area is less than our content then scale down
                if (height > availableHeight || width > availableWidth) {
					heightScale = availableHeight/height;
					widthScale = availableWidth/width;
					newScale = Math.min(widthScale, heightScale);
					width = newScale * width;
					height = newScale * height;
                }
				else if (height < availableHeight && width < availableWidth) {
					newScale = Math.min(availableHeight/height, availableWidth/width);
					width = newScale * width;
					height = newScale * height;
					//newScale = Math.min(availableHeight/height, availableWidth/width);
					//newScale = Math.max(availableHeight/height, availableWidth/width);
                }

				setScale(newScale, dispatchEvent);
				
				////////////////////////////////////////////////////////////////////////////////
				/*var documentRatio:Number = width / height;
				var canvasRatio:Number = availableWidth / availableHeight;
				
				var newRatio:Number = documentRatio / canvasRatio;
				newRatio = canvasRatio / documentRatio;
				newRatio = 1-documentRatio / canvasRatio;*/
					
			}
		}
		
		//----------------------------------
		//
		//  Documentation Utility
		// 
		//----------------------------------
		
		public static var docsURL:String = "http://flex.apache.org/asdoc/";
		public static var docsURL2:String = "http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/";
		
		public static function getURLToHelp(metadata:MetaData, useBackupURL:Boolean = true):String {
			var path:String = "";
			var currentClass:String;
			var sameClass:Boolean;
			var prefix:String = "";
			var url:String;
			var packageName:String;
			var declaredBy:String;
			var backupURLNeeded:Boolean;
			
			if (metadata && metadata.declaredBy) {
				declaredBy = metadata.declaredBy;
				currentClass = declaredBy.replace(/::|\./g, "/");
				
				if (declaredBy.indexOf(".")!=-1) {
					packageName = declaredBy.split(".")[0];
					if (packageName=="flash") {
						backupURLNeeded = true;
					}
				}
				
				if (metadata is StyleMetaData) {
					prefix = "style:";
				}
				else if (metadata is EventMetaData) {
					prefix = "event:";
				}
				
				
				path = currentClass + ".html#" + prefix + metadata.name;
			}
			
			if (useBackupURL && backupURLNeeded) {
				url  = docsURL2 + path;
			}
			else {
				url  = docsURL + path;
			}
			
			return url;
		}
		
		//----------------------------------
		//
		//  Component Management
		// 
		//----------------------------------
		
		/**
		 * Collection of visual elements that can be added or removed to 
		 * */
		[Bindable]
		public static var componentDefinitions:ArrayCollection = new ArrayCollection();
		
		/**
		 * Cache for component icons
		 * */
		[Bindable]
		public static var contentCache:ContentCache = new ContentCache();
		
		/**
		 * Add the named component class to the list of available components
		 * */
		public static function addComponentType(name:String, className:String, classType:Object, inspectors:Array = null, icon:Object = null, defaultProperties:Object=null, defaultStyles:Object=null, enabled:Boolean = true):Boolean {
			var definition:ComponentDefinition;
			var length:uint = componentDefinitions.length;
			var item:ComponentDefinition;
			
			
			for (var i:uint;i<length;i++) {
				item = ComponentDefinition(componentDefinitions.getItemAt(i));
				
				// check if it exists already
				if (item && item.classType==classType) {
					return false;
				}
			}
			
			
			definition = new ComponentDefinition();
			
			definition.name = name;
			definition.icon = icon;
			definition.className = className;
			definition.classType = classType;
			definition.defaultStyles = defaultStyles;
			definition.defaultProperties = defaultProperties;
			definition.inspectors = inspectors;
			definition.enabled = enabled;
			
			componentDefinitions.addItem(definition);
			
			return true;
		}
		
		/**
		 * Remove the named component class
		 * */
		public static function removeComponentType(className:String):Boolean {
			var definition:ComponentDefinition;
			var length:uint = componentDefinitions.length;
			var item:ComponentDefinition;
			
			for (var i:uint;i<length;i++) {
				item = ComponentDefinition(componentDefinitions.getItemAt(i));
				
				if (item && item.classType==className) {
					componentDefinitions.removeItemAt(i);
				}
			}
			
			return true;
		}
		
		/**
		 * Get the component by class name
		 * */
		public static function getComponentType(className:String, fullyQualified:Boolean = false):ComponentDefinition {
			var definition:ComponentDefinition;
			var length:uint = componentDefinitions.length;
			var item:ComponentDefinition;
			
			for (var i:uint;i<length;i++) {
				item = ComponentDefinition(componentDefinitions.getItemAt(i));
				
				if (fullyQualified) {
					if (item && item.className==className) {
						return item;
					}
				}
				else {
					if (item && item.name==className) {
						return item;
					}
				}
			}
			
			return null;
		}
		
		/**
		 * Get the component by class name
		 * */
		public static function getDynamicComponentType(className:String, fullyQualified:Boolean = false):ComponentDefinition {
			var definition:ComponentDefinition;
			var length:uint = componentDefinitions.length;
			var item:ComponentDefinition;
			
			for (var i:uint;i<length;i++) {
				item = ComponentDefinition(componentDefinitions.getItemAt(i));
				
				if (fullyQualified) {
					if (item && item.className==className) {
						return item;
					}
				}
				else {
					if (item && item.name==className) {
						return item;
					}
				}
			}
			
			
			var hasDefinition:Boolean = ApplicationDomain.currentDomain.hasDefinition(className);
			
			
			if (hasDefinition) {
				addComponentType(className, className, null, null);
				item = getComponentType(className, fullyQualified);
				return item;
			}
			
			return null;
		}
		
		/**
		 * Removes all components. If components were removed then returns true. 
		 * */
		public static function removeAllComponents():Boolean {
			var length:uint = componentDefinitions.length;
			
			if (length) {
				componentDefinitions.removeAll();
				return true;
			}
			
			return false;
		}
		
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
			var length:int = assets.length;
			var found:Boolean;
			var item:DocumentData;
			
			for (var i:int;i<length;i++) {
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
				
				deleteAttachmentService.host = getWPURL();
				
				deleteDocumentInProgress = true;
				
				deleteAttachmentService.deleteAttachment(int(iDocumentData.id), true);
			}
			/*else if (remote) { // document not saved yet because no ID
				
				if (dispatchEvents) {
					dispatchAssetRemovedEvent(iDocumentData, removedInternally);
					return removedInternally;
				}
			}
			else {
	
				if (dispatchEvents) {
					dispatchAssetRemovedEvent(iDocumentData, removedInternally);
					return removedInternally;
				}

			}*/
			
			dispatchAssetRemovedEvent(iDocumentData, removedInternally);
			
			return removedInternally;
		}
		
		/**
		 * The canvas border.
		 * */
		public var canvasBorder:Object;
		
		/**
		 * The canvas background.
		 * */
		public var canvasBackground:Object;
		
		/**
		 * The canvas scroller.
		 * */
		public var canvasScroller:Scroller;
		
		/**
		 * Sets the canvas and canvas parent. Not sure if going to be used. 
		 * May use canvas property on document.
		 * */
		public function setCanvas(canvasBorder:Object, canvasBackground:Object, canvasScroller:Scroller, dispatchEvent:Boolean = true, cause:String = ""):void {
			//if (this.canvasBackground==canvasBackground) return;
			
			this.canvasBorder = canvasBorder;
			this.canvasBackground = canvasBackground;
			this.canvasScroller = canvasScroller;
			
			if (dispatchEvent) {
				instance.dispatchCanvasChangeEvent(canvasBackground, canvasBorder, canvasScroller);
			}
			
		}
		
		/**
		 * Sets the document
		 * */
		public function setProject(value:IProject, dispatchEvent:Boolean = true, cause:String = ""):void {
			selectedProject = value;
			/*if (_projects.length == 1 && projects==value) return;
			
			_projects = null;// without this, the contents of the array would change across all instances
			_projects = [];
			
			if (value) {
				_projects[0] = value;
			}*/
			
			if (dispatchEvent) {
				instance.dispatchProjectChangeEvent(selectedProject);
			}
			
		}
		
		/**
		 * Selects the target
		 * */
		public function setProjects(value:*, dispatchEvent:Boolean = true, cause:String = ""):void {
			value = ArrayUtil.toArray(value);
			
			// remove listeners from previous documents
			var n:int = _projects.length;
			
			for (var i:int = n - 1; i >= 0; i--) {
				if (_projects[i] == null) {
					continue;
				}
				
				//removeHandlers(_projects[i]);
			}
			
			// Strip out null values.
			// Binding will trigger again when the null projects are created.
			n = value.length;
			
			for (i = n - 1; i >= 0; i--) {
				if (value[i] == null) {
					value.splice(i,1);
					continue;
				}
				
				//addHandlers(value[i]);
			}
			
			_projects = value;
			
			if (dispatchEvent) {
				instance.dispatchProjectsSetEvent(projects);
			}
			
		}
		
		/**
		 * Sets the current document
		 * */
		public function setDocument(value:IDocument, dispatchEvent:Boolean = true, cause:String = ""):void {
			
			if (selectedDocument != value) {
				selectedDocument = value;
			}
			
			var container:IDocumentContainer = documentsContainerDictionary[value] as IDocumentContainer;
			
			if (container) {
				toolLayer = container.toolLayer;
				canvasBorder = container.canvasBorder;
				canvasBackground= container.canvasBackground;
				canvasScroller = container.canvasScroller;
			}
			
			history = selectedDocument ? selectedDocument.history : null;
			history ? history.refresh() : void;
			historyIndex = getHistoryIndex();
			
			if (dispatchEvent) {
				instance.dispatchDocumentChangeEvent(selectedDocument);
			}
			
		}
		
		/**
		 * Selects the target
		 * */
		public function setDocuments(value:*, dispatchEvent:Boolean = true, cause:String = ""):void {
			value = ArrayUtil.toArray(value);
			
			// remove listeners from previous documents
			var n:int = _documents.length;
			
			for (var i:int = n - 1; i >= 0; i--) {
				if (_documents[i] == null) {
					continue;
				}
				
				//removeHandlers(_documents[i]);
			}
			
			// Strip out null values.
			// Binding will trigger again when the null documents are created.
			n = value.length;
			
			for (i = n - 1; i >= 0; i--) {
				if (value[i] == null) {
					value.splice(i,1);
					continue;
				}
				
				//addHandlers(value[i]);
			}
			
			_documents = value;
			
			if (dispatchEvent) {
				instance.dispatchDocumentsSetEvent(documents);
			}
			
			
		}
		
		/**
		 * Selects the target
		 * */
		public function setTarget(value:*, dispatchEvent:Boolean = true, cause:String = ""):void {
			if (_targets.length == 1 && target==value) return;
			
			_targets = null;// without this, the contents of the array would change across all instances
			_targets = [];
			
			if (value) {
				_targets[0] = value;
			}
			
			if (dispatchEvent) {
				instance.dispatchTargetChangeEvent(target);
			}
			
		}
		
		/**
		 * Selects the target
		 * */
		public function setTargets(value:*, dispatchEvent:Boolean = true, cause:String = ""):void {
			value = ArrayUtil.toArray(value);
			
			// remove listeners from previous targets
			var n:int = _targets.length;
			
			for (var i:int = n - 1; i >= 0; i--) {
				if (_targets[i] == null) {
					continue;
				}
				
				//removeHandlers(_targets[i]);
			}
			
			// Strip out null values.
			// Binding will trigger again when the null targets are created.
			n = value.length;
			
			for (i = n - 1; i >= 0; i--) {
				if (value[i] == null) {
					value.splice(i,1);
					continue;
				}
				
				//addHandlers(value[i]);
			}
			
			_targets = value;
			
			
			if (dispatchEvent) {
				instance.dispatchTargetChangeEvent(_targets, true);
			}
			
		}
		
		/**
		 * Deselects the passed in targets
		 * */
		public function desetTargets(value:*, dispatchEvent:Boolean = true, cause:String = ""):void {
			value = ArrayUtil.toArray(value);
			
			throw new Error("not done");
			
			// go through current targets and remove any that match the ones in the values
			
			// remove listeners from previous targets
			var targetsLength:int = _targets.length;
			var valuesLength:int = value ? value.length : 0;
			
			for (var i:int=0;i<targetsLength;i++) {
				for (var j:int=0;j<valuesLength;j++) {
					if (value[j]==_targets[i]) {
						_targets.splice(i,1);
						continue;
					}
				}
			}
			
			
			if (dispatchEvent) {
				instance.dispatchTargetChangeEvent(_targets, true);
			}
		}
		
		/**
		 * Deselects the target
		 * */
		public function deselectedTarget(dispatchEvent:Boolean = true, cause:String = ""):void {
			
			// go through current targets and remove any that match the ones in the values
			setTarget(null, dispatchEvent, cause);
			
		}
		
		/**
		 * Deselects the target
		 * */
		public static function clearTarget(dispatchEvent:Boolean = true, cause:String = ""):void {
			setTarget(null, dispatchEvent, cause);
		}
		
		/**
		 * Selects the target
		 * */
		public static function setTarget(value:DisplayObject, dispatchEvent:Boolean = true, cause:String = ""):void {
			instance.setTarget(value, dispatchEvent, cause);
		}
		
		/**
		 * Selects the target
		 * */
		public static function setTargets(value:Object, dispatchEvent:Boolean = true, cause:String = ""):void {
			instance.setTargets(value, dispatchEvent, cause);
		}
		
		/**
		 * Selects the document
		 * */
		public static function setDocuments(value:Object, dispatchEvent:Boolean = false, cause:String = ""):void {
			instance.setDocuments(value, dispatchEvent, cause);
		}
		
		/**
		 * Deselects the documents
		 * */
		public static function desetDocuments(dispatchEvent:Boolean = true, cause:String = ""):void {
			instance.setDocuments(null, dispatchEvent, cause);
		}
		
		/**
		 * Gets the display list of the current document
		 * */
		public static function getComponentDisplayList():ComponentDescription {
			return IDocumentContainer(instance.selectedDocument).componentDescription;
		}
		
		//----------------------------------
		//  Clipboard
		//----------------------------------
		
		/**
		 * Cut item
		 * */
		public function cutItem(item:Object):void {
			//Clipboard.generalClipboard.setData(ClipboardFormats.HTML_FORMAT, );
			cutData = item;
			copiedData = null;
		}
		
		/**
		 * Copy item
		 * */
		public function copyItem(item:Object, format:String = null, handler:Function = null):void {
			//Clipboard.generalClipboard.setData(ClipboardFormats.HTML_FORMAT, );
			cutData = null;
			copiedData = item;
			
			var clipboard:Clipboard = Clipboard.generalClipboard;
			var serializable:Boolean = true;
			
			format = format ? format : "Object";
			handler = handler!=null ? handler : setClipboardDataHandler;
			
			if (true) {
				clipboard.clear();
			}
				
			try {
				
				if (item is String) {
					clipboard.setDataHandler(format, handler, serializable);
				}
				else {
					clipboard.setDataHandler(format, handler, serializable);
				}
				
				/*
				if (action.successEffect) {
					playEffect(action.successEffect);
				}
				
				if (action.hasEventListener(CopyToClipboard.SUCCESS)) {
					dispatchActionEvent(new Event(CopyToClipboard.SUCCESS));
				}*/
			}
			catch (error:ErrorEvent) {
				
				/*
				if (action.errorEffect) {
					playEffect(action.errorEffect);
				}
				
				if (action.hasEventListener(CopyToClipboard.ERROR)) {
					dispatchActionEvent(new Event(CopyToClipboard.ERROR));
				}*/
			}
		}
		
		/**
		 * Set clipboard data handler
		 * */
		public function setClipboardDataHandler():* {
			/*Format	Return Type
			ClipboardFormats.TEXT_FORMAT	String
			ClipboardFormats.HTML_FORMAT	String
			ClipboardFormats.URL_FORMAT	String (AIR only)
			ClipboardFormats.RICH_TEXT_FORMAT	ByteArray
			ClipboardFormats.BITMAP_FORMAT	BitmapData (AIR only)
			ClipboardFormats.FILE_LIST_FORMAT	Array of File (AIR only)
			ClipboardFormats.FILE_PROMISE_LIST_FORMAT	Array of File (AIR only)
			Custom format name	Non-void*/
			
			
			
			if (copiedData) {
				return copiedData;
			}
			else if (cutData) {
				return cutData;
			}
			
			//Clipboard.generalClipboard.setData(ClipboardFormats.HTML_FORMAT, );
		}
		
		/**
		 * Copy item
		 * */
		public function pasteItem(destination:Object):void {
			//Clipboard.generalClipboard.setData(ClipboardFormats.HTML_FORMAT, );
		}
		
		/**
		 * Set attributes on a component object
		 * */
		public static function setAttributesOnComponent(elementInstance:Object, node:XML, dispatchEvents:Boolean = false):void {
			var attributeName:String;
			var elementName:String = node.localName();
			//var domain:ApplicationDomain = ApplicationDomain.currentDomain;
			//var componentDefinition:ComponentDefinition = Radiate.getComponentType(elementName);
			//var className:String =componentDefinition ? componentDefinition.className :null;
			//var classType:Class = componentDefinition ? componentDefinition.classType as Class :null;
			//var elementInstance:Object = componentDescription.instance;
			
			
			for each (var attribute:XML in node.attributes()) {
				attributeName = attribute.name().toString();
				//Radiate.log.info(" found attribute: " + attributeName); 
				
				
				// TODO we should check if an attribute is an property, style or event using the component definition
				// We can do it this way now since we are only working with styles and properties
				
				
				// check if property 
				if (attributeName in elementInstance) {
					
					//Radiate.log.info(" setting property: " + attributeName);
					setProperty(elementInstance, attributeName, attribute.toString(), null, false, dispatchEvents);
				 	
				}
				
				// could be style or event
				else {
					if (elementInstance is IStyleClient) {
						//Radiate.log.info(" setting style: " + attributeName);
						setStyle(elementInstance, attributeName, attribute.toString(), null, false, dispatchEvents);
					}
				}
			}
		}
		
		/**
		 * Returns true if the property was changed. Use setProperties for 
		 * setting multiple properties.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.setProperty(myButton, "x", 40);</pre>
		 * <pre>Radiate.setProperty([myButton,myButton2], "x", 40);</pre>
		 * */
		public static function clearStyle(target:Object, style:String, description:String = null):Boolean {
			
			return setStyle(target, style, undefined, description, true);
		}
		
		/**
		 * Returns true if the property was changed. Use setProperties for 
		 * setting multiple properties.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.setProperty(myButton, "x", 40);</pre>
		 * <pre>Radiate.setProperty([myButton,myButton2], "x", 40);</pre>
		 * */
		public static function setStyle(target:Object, style:String, value:*, description:String = null, keepUndefinedValues:Boolean = false, dispatchEvents:Boolean = true):Boolean {
			var targets:Array = ArrayUtil.toArray(target);
			var styleChanges:Array;
			var historyEvents:Array;
			
			styleChanges = createPropertyChange(targets, null, style, value, description);
			
			
			if (!keepUndefinedValues) {
				styleChanges = stripUnchangedValues(styleChanges);
			}
			
			if (changesAvailable(styleChanges)) {
				applyChanges(targets, styleChanges, null, style);
				//LayoutManager.getInstance().validateNow(); // applyChanges calls this
				
				historyEvents = createHistoryEvents(targets, styleChanges, null, style, value);
				
				updateComponentStyles(targets, styleChanges);
				
				addHistoryEvents(historyEvents, description);
				
				if (dispatchEvents) {
					instance.dispatchPropertyChangeEvent(targets, styleChanges, ArrayUtil.toArray(style));
				}
				return true;
			}
			
			return false;
		}
		
		/**
		 * Returns true if the property was changed. Use setProperties for 
		 * setting multiple properties.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.setProperty(myButton, "x", 40);</pre>
		 * <pre>Radiate.setProperty([myButton,myButton2], "x", 40);</pre>
		 * */
		public static function setProperty(target:Object, property:String, value:*, description:String = null, keepUndefinedValues:Boolean = false, dispatchEvents:Boolean = true):Boolean {
			var targets:Array = ArrayUtil.toArray(target);
			var propertyChanges:Array;
			var historyEvents:Array;
			
			propertyChanges = createPropertyChange(targets, property, null, value, description);
			
			
			if (!keepUndefinedValues) {
				propertyChanges = stripUnchangedValues(propertyChanges);
			}
			
			if (changesAvailable(propertyChanges)) {
				applyChanges(targets, propertyChanges, property, null);
				//LayoutManager.getInstance().validateNow(); // applyChanges calls this
				//addHistoryItem(propertyChanges, description);
				
				historyEvents = createHistoryEvents(targets, propertyChanges, property, null, value);
				
				addHistoryEvents(historyEvents, description);
				
				updateComponentProperties(targets, propertyChanges);
				
				if (dispatchEvents) {
					instance.dispatchPropertyChangeEvent(targets, propertyChanges, ArrayUtil.toArray(property));
				}
				
				if (dispatchEvents) {
					if (targets.indexOf(instance.selectedDocument.instance)!=-1 && ArrayUtils.containsAny(notableApplicationProperties, [property])) {
						instance.dispatchDocumentSizeChangeEvent(targets);
					}
				}
				
				return true;
			}
			
			return false;
		}
		
		/**
		 * Properties on the application to listen for for document size change event
		 * */
		public static var notableApplicationProperties:Array = ["width","height","scaleX","scaleY"];
		
		/**
		 * Returns true if the property(s) were changed.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>setProperties([myButton,myButton2], ["x","y"], {x:40,y:50});</pre>
		 * <pre>setProperties(myButton, "x", 40);</pre>
		 * <pre>setProperties(button, ["x", "left"], {x:50,left:undefined});</pre>
		 * 
		 * @see setStyle()
		 * @see setStyles()
		 * @see setProperty()
		 * */
		public static function setProperties(target:Object, properties:Array, value:*, description:String = null, keepUndefinedValues:Boolean = false):Boolean {
			var propertyChanges:Array;
			var historyEvents:Array;
			var targets:Array;
			
			targets = ArrayUtil.toArray(target);
			properties = ArrayUtil.toArray(properties);
			propertyChanges = createPropertyChanges(targets, properties, null, value, description, false);
			
			if (!keepUndefinedValues) {
				propertyChanges = stripUnchangedValues(propertyChanges);
			}
			
			if (changesAvailable(propertyChanges)) {
				applyChanges(targets, propertyChanges, properties, null);
				//LayoutManager.getInstance().validateNow();
				//addHistoryItem(propertyChanges);
				
				historyEvents = createHistoryEvents(targets, propertyChanges, properties, null, value);
				
				addHistoryEvents(historyEvents, description);
				
				updateComponentProperties(targets, propertyChanges);
				
				instance.dispatchPropertyChangeEvent(targets, propertyChanges, properties);
				
				if (targets.indexOf(instance.selectedDocument)!=-1 && ArrayUtils.containsAny(notableApplicationProperties, properties)) {
					instance.dispatchDocumentSizeChangeEvent(targets);
				}
				return true;
			}
			
			return false;
		}
		
		/**
		 * Returns true if the property(s) were changed.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>setProperties([myButton,myButton2], ["x","y"], {x:40,y:50});</pre>
		 * <pre>setProperties(myButton, "x", 40);</pre>
		 * <pre>setProperties(button, ["x", "left"], {x:50,left:undefined});</pre>
		 * 
		 * @see setStyle()
		 * @see setProperty()
		 * @see setProperties()
		 * */
		public static function setStyles(target:Object, styles:Array, value:*, description:String = null, keepUndefinedValues:Boolean = false):Boolean {
			var stylesChanges:Array;
			var historyEvents:Array;
			var targets:Array;
			
			targets = ArrayUtil.toArray(target);
			styles = ArrayUtil.toArray(styles);
			stylesChanges = createPropertyChanges(targets, styles, null, value, description, false);
			
			if (!keepUndefinedValues) {
				stylesChanges = stripUnchangedValues(stylesChanges);
			}
			
			if (changesAvailable(stylesChanges)) {
				applyChanges(targets, stylesChanges, null, styles);
				//LayoutManager.getInstance().validateNow();
				
				historyEvents = createHistoryEvents(targets, stylesChanges, null, styles, value);
				
				addHistoryEvents(historyEvents, description);
				
				updateComponentStyles(targets, stylesChanges);
				
				instance.dispatchPropertyChangeEvent(targets, stylesChanges, styles);
				return true;
			}
			
			return false;
		}
		
		/**
		 * Updates the properties on a component description
		 * */
		public static function updateComponentProperties(targets:Array, propertyChanges:Array):void {
			var descriptor:ComponentDescription;
			var targetLength:int = targets.length;
			var changesLength:int = propertyChanges.length;
			var propertyChange:Object;
			var target:Object;
			
			for (var i:int;i<targetLength;i++) {
				target = targets[i];
				descriptor = instance.selectedDocument.descriptionsDictionary[target];
				
				for (var j:int=0;j<changesLength;j++) {
					propertyChange = propertyChanges[j];
					
					if (descriptor) {
						descriptor.properties = ObjectUtils.merge(propertyChange.end, descriptor.properties);
					}
				}
				
			}
		}
		
		/**
		 * Updates the styles on a component description
		 * */
		public static function updateComponentStyles(targets:Array, propertyChanges:Array):void {
			var descriptor:ComponentDescription;
			var targetLength:int = targets.length;
			var changesLength:int = propertyChanges.length;
			var propertyChange:Object;
			var target:Object;
			
			for (var i:int;i<targetLength;i++) {
				target = targets[i];
				descriptor = instance.selectedDocument.descriptionsDictionary[target];
				
				for (var j:int=0;j<changesLength;j++) {
					propertyChange = propertyChanges[j];
					
					if (descriptor) {
						descriptor.styles = ObjectUtils.merge(propertyChange.end, descriptor.styles);
					}
				}
				
				// remove nulls and undefined values
				
			}
		}
		
		/**
		 * Gets the value translated into a type. 
		 * */
		public static function getTypedValue(value:*, valueType:*):* {
			
			return TypeUtils.getTypedValue(value, valueType);
		}
		
		
		/**
		 * Move a component in the display list and sets any properties 
		 * such as positioning<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.moveElement(new Button(), parentComponent, [], null);</pre>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.moveElement(radiate.target, null, ["x"], 15);</pre>
		 * */
		public static function moveElement(items:*, 
										   destination:Object, 
										   properties:Array, 
										   styles:Array,
										   values:Object, 
										   description:String 	= RadiateEvent.MOVE_ITEM, 
										   position:String		= AddItems.LAST, 
										   relativeTo:Object	= null, 
										   index:int			= -1, 
										   propertyName:String	= null, 
										   isArray:Boolean		= false, 
										   isStyle:Boolean		= false, 
										   vectorClass:Class	= null,
										   keepUndefinedValues:Boolean = true):String {
			
			var visualElement:IVisualElement;
			var moveItems:AddItems;
			var childIndex:int;
			var propertyChangeChange:PropertyChanges;
			var changes:Array;
			var historyEvents:Array;
			var isSameOwner:Boolean;
			var isSameParent:Boolean;
			var removeBeforeAdding:Boolean;
			var currentIndex:int;
			var movingIndexWithinParent:Boolean;
			
			items = ArrayUtil.toArray(items);
			
			var item:Object = items ? items[0] : null;
			var itemOwner:Object = item ? item.owner : null;
			
			visualElement = item as IVisualElement;
			var visualElementParent:Object = visualElement ? visualElement.parent : null;
			var visualElementOwner:IVisualElementContainer = itemOwner as IVisualElementContainer;
			var applicationGroup:GroupBase = destination is Application ? Application(destination).contentGroup : null;
			
			isSameParent = visualElementParent && (visualElementParent==destination || visualElementParent==applicationGroup);
			isSameOwner = visualElementOwner && visualElementOwner==destination;
			
			// set default description
			if (!description) {
				description = ADD_ITEM_DESCRIPTION;
			}
			
			// if it's a basic layout then don't try to add it
			// NO DO ADD IT bc we may need to swap indexes
			if (destination is IVisualElementContainer) {
				//destinationGroup = destination as GroupBase;
				
				if (destination.layout is BasicLayout) {
					
					// does not support multiple items?
					// check if group parent and destination are the same
					if (item && itemOwner==destination) {
						//trace("can't add to the same owner in a basic layout");
						isSameOwner = true;
						
						//return SAME_OWNER;
					}
					
					// check if group parent and destination are the same
					// NOTE: if the item is an element on application this will fail
					if (item && visualElementParent && (visualElementParent==destination || visualElementParent==applicationGroup)) {
						//trace("can't add to the same parent in a basic layout");
						isSameParent = true;
						//return SAME_PARENT;
					}
				}
				// if element is already child of layout container and there is only one element 
				else if (items && destination is IVisualElementContainer 
						&& destination.numElements==1
						&& visualElementParent
						&& (visualElementParent==destination || visualElementParent==applicationGroup)) {
					
					isSameParent = true;
					isSameOwner = true;
					//trace("can't add to the same parent in a basic layout");
					//return SAME_PARENT;
					
				}
			}
			
			// if destination is null then we assume we are moving
			// WRONG! null should mean remove
			else {
				//isSameParent = true;
				//isSameOwner = true;
			}
			
			
			// set default
			if (!position) {
				position = AddItems.LAST;
			}
			
			// if destination is not a basic layout Group and the index is set 
			// then find and override position and set the relative object 
			// so we can position the target in the drop location point index
			if (destination is IVisualElementContainer 
				&& !relativeTo 
				&& index!=-1
				&& destination.numElements>0) {
				
				// add as first item
				if (index==0) {
					position = AddItems.FIRST;
				}
					
					// get relative to object
				else if (index<=destination.numElements) {
					visualElement = items is Array && (items as Array).length>0 ? items[0] as IVisualElement : items as IVisualElement;
					
					// if element is already child of container account for removal of element before add
					if (visualElement && visualElement.parent == destination) {
						childIndex = destination.getElementIndex(visualElement);
						index = childIndex < index ? index-1: index;
						
						if (index<=0) {
							position = AddItems.FIRST;
						}
						else {
							relativeTo = destination.getElementAt(index-1);
							position = AddItems.AFTER;
						}
					}
						// add as last item
					else if (index>=destination.numElements) {
						
						// we need to remove first or we get an error in AddItems
						// or we can set relativeTo item and set AFTER
						if (isSameParent && destination.numElements>1) {
							removeBeforeAdding = true;
							relativeTo = destination.getElementAt(destination.numElements-1);
							position = AddItems.AFTER;
						}
						else if (isSameParent) {
							removeBeforeAdding = true;
							position = AddItems.LAST;
						}
						else {
							position = AddItems.LAST;
						}
					}
						// add after first item
					else if (index>0) {
						relativeTo = destination.getElementAt(index-1);
						position = AddItems.AFTER;
					}
				}
				
				
				// check if moving to another index within the same parent 
				if (visualElementOwner && visualElement) {
					currentIndex = visualElementOwner.getElementIndex(visualElement);
					
					if (currentIndex!=index) {
						movingIndexWithinParent = true;
					}
				}
			}
			
			
			// create a new AddItems instance and add it to the changes
			moveItems = new AddItems();
			moveItems.items = items;
			moveItems.destination = destination;
			moveItems.position = position;
			moveItems.relativeTo = relativeTo;
			moveItems.propertyName = propertyName;
			moveItems.isArray = isArray;
			moveItems.isStyle = isStyle;
			moveItems.vectorClass = vectorClass;
			
			// add properties that need to be modified
			if (properties && properties.length>0 ||
				styles && styles.length>0) {
				changes = createPropertyChanges(items, properties, styles, values, description, false);
				
				// get the property change part
				propertyChangeChange = changes[0];
			}
			else {
				changes = [];
			}
			
			// constraints use undefined values 
			// so if we use constraints do not strip out values
			if (!keepUndefinedValues) {
				changes = stripUnchangedValues(changes);
			}
			
			
			// attempt to add or move and set the properties
			try {
				
				// insert moving of items before it
				// if it's the same owner we don't want to run add items 
				// but if it's a vgroup or hgroup does this count
				if ((!isSameParent && !isSameOwner) || movingIndexWithinParent) {
					changes.unshift(moveItems); //add before other changes 
				}
				
				if (changes.length==0) {
					Radiate.log.info("Move: Nothing to change or add");
					return "Nothing to change or add";
				}
				
				// store changes
				historyEvents = createHistoryEvents(items, changes, properties, styles, values, description, RadiateEvent.MOVE_ITEM);
				
				// try moving
				if ((!isSameParent && !isSameOwner) || movingIndexWithinParent) {
					
					// this is to prevent error in AddItem when adding to the last position
					// and we get an index is out of range. 
					// 
					// for example, if an element is at index 0 and there are 3 elements 
					// then addItem will get the last index. 
					// but since the parent is the same the addElement call removes 
					// the element. the max index is reduced by one and previously 
					// determined last index is now out of range. 
					// AddItems was not meant to add an element that has already been added
					// so we remove it before hand so addItems can add it again. 
					if (removeBeforeAdding) {
						visualElementOwner.removeElement(visualElement);
					}
					
					moveItems.apply(moveItems.destination as UIComponent);
					
					if (moveItems.destination is SkinnableContainer && !SkinnableContainer(moveItems.destination).deferredContentCreated) {
						//Radiate.log.error("Not added because deferred content not created.");
						var factory:DeferredInstanceFromFunction = new DeferredInstanceFromFunction(deferredInstanceFromFunction);
						SkinnableContainer(moveItems.destination).mxmlContentFactory = factory;
						SkinnableContainer(moveItems.destination).createDeferredContent();
						SkinnableContainer(moveItems.destination).removeAllElements();
						moveItems.apply(moveItems.destination as UIComponent);
					}
					
					LayoutManager.getInstance().validateNow();
				}
				
				// try setting properties
				if (changesAvailable([propertyChangeChange])) {
					applyChanges(items, [propertyChangeChange], properties, styles);
					LayoutManager.getInstance().validateNow();
				}
				
				// add to history
				addHistoryEvents(historyEvents);
				
				// check for changes before dispatching
				if (changes.indexOf(moveItems)!=-1) {
					instance.dispatchMoveEvent(items, changes, properties);
				}
				
				setTargets(items, true);
				
				if (properties) {
					instance.dispatchPropertyChangeEvent(items, changes, properties);
				}
				
				return MOVED; // we assume moved if it got this far - needs more checking
			}
			catch (error:Error) {
				// this is clunky - needs to be upgraded
				Radiate.log.error("Move error: " + error.message);
				removeHistoryEvent(changes);
				removeHistoryItem(changes);
				return String(error.message);
			}
			
			
			return ADD_ERROR;
			
		}
			
		/**
		 * Adds a component to the display list.
		 * It should not have a parent or owner! If it does
		 * it will return an error message
		 * Returns true if the component was added
		 * 
		 * Usage:
		 * Radiate.addElement(new Button(), event.targetCandidate);
		 * */
		public static function addElement(items:*, 
										  destination:Object, 
										  properties:Array 		= null, 
										  styles:Array			= null,
										  values:Object			= null, 
										  description:String 	= RadiateEvent.ADD_ITEM, 
										  position:String		= AddItems.LAST, 
										  relativeTo:Object		= null, 
										  index:int				= -1, 
										  propertyName:String	= null, 
										  isArray:Boolean		= false, 
										  isStyle:Boolean		= false, 
										  vectorClass:Class		= null,
										  keepUndefinedValues:Boolean = true):String {
			
			var results:String = moveElement(items, destination, properties, styles, values, 
								description, position, relativeTo, index, propertyName, 
								isArray, isStyle, vectorClass, keepUndefinedValues);
			
			var component:Object = ArrayUtil.toArray(items)[0];
		
			// if text based or combo box we need to prevent 
			// interaction with cursor
			if (component is TextBase || component is SkinnableTextBase) {
				component.mouseChildren = false;
				
				if ("textDisplay" in component && component.textDisplay) {
					component.textDisplay.enabled = false;
				}
			}
			
			if (component is ComboBox) {
				if ("textInput" in component && component.textInput.textDisplay) {
					component.textInput.textDisplay.enabled = false;
				}
			}
			
			// we can't add elements if skinnablecontainer._deferredContentCreated is false
			if (component is BorderContainer) {
				/*var factory:DeferredInstanceFromFunction;
				factory = new DeferredInstanceFromFunction(deferredInstanceFromFunction);
				BorderContainer(component).mxmlContentFactory = factory;
				BorderContainer(component).createDeferredContent();
				BorderContainer(component).removeAllElements();*/
				
				// we could probably also do this: 
				BorderContainer(component).addElement(new Label());
				BorderContainer(component).removeAllElements();
				
			}
			
			// we need a custom FlexSprite class to do this
			// do this after drop
			if ("eventListeners" in component && !(component is GroupBase)) {
				component.removeAllEventListeners();
			}
			
			return results;
		}
		
		
		/**
		 * Removes an element from the display list.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.removeElement(radiate.targets);</pre>
		 * */
		public static function removeElement(items:*, description:String = RadiateEvent.REMOVE_ITEM):String {
			
			var visualElement:IVisualElement;
			var removeItems:AddItems;
			var childIndex:int;
			var propertyChangeChange:PropertyChanges;
			var changes:Array;
			var historyEvents:Array;
			var isSameOwner:Boolean;
			var isSameParent:Boolean;
			var removeBeforeAdding:Boolean;
			var currentIndex:int;
			var movingIndexWithinParent:Boolean;
			
			items = ArrayUtil.toArray(items);
			
			var item:Object = items ? items[0] : null;
			var itemOwner:Object = item ? item.owner : null;
			
			visualElement = item as IVisualElement;
			var visualElementParent:Object = visualElement ? visualElement.parent : null;
			var visualElementOwner:IVisualElementContainer = itemOwner as IVisualElementContainer;
			var applicationGroup:GroupBase = destination is Application ? Application(destination).contentGroup : null;
			
			isSameParent = visualElementParent && (visualElementParent==destination || visualElementParent==applicationGroup);
			isSameOwner = visualElementOwner && visualElementOwner==destination;
			
			// set default description
			if (!description) {
				description = REMOVE_ITEM_DESCRIPTION;
			}
			/*
			// if it's a basic layout then don't try to add it
			// NO DO ADD IT bc we may need to swap indexes
			if (destination is IVisualElementContainer) {
				//destinationGroup = destination as GroupBase;
				
				if (destination.layout is BasicLayout) {
					
					// does not support multiple items?
					// check if group parent and destination are the same
					if (item && itemOwner==destination) {
						//trace("can't add to the same owner in a basic layout");
						isSameOwner = true;
						
						//return SAME_OWNER;
					}
					
					// check if group parent and destination are the same
					// NOTE: if the item is an element on application this will fail
					if (item && visualElementParent && (visualElementParent==destination || visualElementParent==applicationGroup)) {
						//trace("can't add to the same parent in a basic layout");
						isSameParent = true;
						//return SAME_PARENT;
					}
				}
				// if element is already child of layout container and there is only one element 
				else if (items && destination is IVisualElementContainer 
						&& destination.numElements==1
						&& visualElementParent
						&& (visualElementParent==destination || visualElementParent==applicationGroup)) {
					
					isSameParent = true;
					isSameOwner = true;
					//trace("can't add to the same parent in a basic layout");
					//return SAME_PARENT;
					
				}
			}
			
			// if destination is null then we assume we are moving
			// WRONG! null should mean remove
			else {
				//isSameParent = true;
				//isSameOwner = true;
			}*/
			
			
			// set default
			/*if (!position) {
				position = AddItems.LAST;
			}*/
			
			// if destination is not a basic layout Group and the index is set 
			// then find and override position and set the relative object 
			// so we can position the target in the drop location point index
			/*if (destination is IVisualElementContainer 
				&& !relativeTo 
				&& index!=-1
				&& destination.numElements>0) {
				
				// add as first item
				if (index==0) {
					position = AddItems.FIRST;
				}
					
					// get relative to object
				else if (index<=destination.numElements) {
					visualElement = items is Array && (items as Array).length>0 ? items[0] as IVisualElement : items as IVisualElement;
					
					// if element is already child of container account for removal of element before add
					if (visualElement && visualElement.parent == destination) {
						childIndex = destination.getElementIndex(visualElement);
						index = childIndex < index ? index-1: index;
						
						if (index<=0) {
							position = AddItems.FIRST;
						}
						else {
							relativeTo = destination.getElementAt(index-1);
							position = AddItems.AFTER;
						}
					}
						// add as last item
					else if (index>=destination.numElements) {
						
						// we need to remove first or we get an error in AddItems
						// or we can set relativeTo item and set AFTER
						if (isSameParent && destination.numElements>1) {
							removeBeforeAdding = true;
							relativeTo = destination.getElementAt(destination.numElements-1);
							position = AddItems.AFTER;
						}
						else if (isSameParent) {
							removeBeforeAdding = true;
							position = AddItems.LAST;
						}
						else {
							position = AddItems.LAST;
						}
					}
						// add after first item
					else if (index>0) {
						relativeTo = destination.getElementAt(index-1);
						position = AddItems.AFTER;
					}
				}
				
				
				// check if moving to another index within the same parent 
				if (visualElementOwner && visualElement) {
					currentIndex = visualElementOwner.getElementIndex(visualElement);
					
					if (currentIndex!=index) {
						movingIndexWithinParent = true;
					}
				}
			}*/
			
			if (visualElement is Application) {
				log.info("You can't remove the design view");
				return REMOVE_ERROR;
			}
			
			var destination:Object = item.owner;
			var index:int = destination.getElementIndex(visualElement);
			var position:String;
			
			// create a new AddItems instance and add it to the changes
			//moveItems = new AddItems();
			//moveItems.items = items;
			//moveItems.destination = destination;
			//moveItems.position = position;
			//moveItems.relativeTo = relativeTo;
			//moveItems.propertyName = propertyName;
			//moveItems.isArray = isArray;
			//moveItems.isStyle = isStyle;
			//moveItems.vectorClass = vectorClass;
			
			changes = [];
			
			
			// attempt to remove
			try {
				removeItems = createReverseAddItems(items[0]);
				changes.unshift(removeItems);
				
				// store changes
				historyEvents = createHistoryEvents(items, changes, null, null, null, description, RadiateEvent.REMOVE_ITEM);
				
				// try moving
				//removeItems.apply(destination as UIComponent);
				//removeItems.apply(null);
				visualElementOwner.removeElement(visualElement);
				//removeItems.remove(destination as UIComponent);
				LayoutManager.getInstance().validateNow();
				
				
				// add to history
				addHistoryEvents(historyEvents);
				
				// check for changes before dispatching
				instance.dispatchRemoveItemsEvent(items, changes, null);
				// select application - could be causing errors - should select previous targets??
				setTargets(instance.selectedDocument.instance, true);
				
				return REMOVED; // we assume moved if it got this far - needs more checking
			}
			catch (error:Error) {
				// this is clunky - needs to be upgraded
				Radiate.log.error("Remove error: " + error.message);
				removeHistoryEvent(changes);
				removeHistoryItem(changes);
				return String(error.message);
			}
			
			return REMOVE_ERROR;
		}
		
		/**
		 * Required for creating BorderContainers
		 * */
		protected static function deferredInstanceFromFunction():Array {
			var label:Label = new Label();
			return [label];
		}
		
		/**
		 * Creates an instance of the component in the descriptor and sets the 
		 * default properties.
		 * */
		public static function createComponentForAdd(iDocument:IDocument, item:ComponentDefinition, setDefaults:Boolean = true):Object {
			var classFactory:ClassFactory;
			var component:Object;
			var componentDescription:ComponentDescription = new ComponentDescription();
			
			// Create component to drag
			classFactory = new ClassFactory(item.classType as Class);
			
			if (setDefaults) {
				classFactory.properties = item.defaultProperties;
				componentDescription.properties = item.defaultProperties;
				componentDescription.defaultProperties = item.defaultProperties;
			}
			
			component = classFactory.newInstance();
			
			for (var property:String in item.defaultProperties) {
				setProperty(component, property, [item.defaultProperties[property]]);
			}
			
			componentDescription.instance = component;
			componentDescription.name = item.name;
			
			iDocument.descriptionsDictionary[component] = componentDescription;
			
			if (component is Label) {
				
			}
			
			// working on grid
			if (component is spark.components.Grid) {
				spark.components.Grid(component).itemRenderer= new ClassFactory(DefaultGridItemRenderer);
				spark.components.Grid(component).dataProvider = new ArrayCollection(["item 1", "item 2", "item 3"]);
			}
			
			// working on mx grid
			if (component is mx.containers.Grid) {
				mx.containers.Grid(component)
				var grid:mx.containers.Grid = component as mx.containers.Grid;
				var gridRow:GridRow	= new GridRow();
				var gridItem:GridItem = new GridItem();
				var gridItem2:GridItem = new GridItem();
				
				var gridButton:Button = new Button();
				gridButton.width = 100;
				gridButton.height = 100;
				gridButton.label = "hello";
				var gridButton2:Button = new Button();
				gridButton2.width = 100;
				gridButton2.height = 100;
				gridButton2.label = "hello2";
				
				gridItem.addElement(gridButton);
				gridItem2.addElement(gridButton2);
				gridRow.addElement(gridItem);
				gridRow.addElement(gridItem2);
				grid.addElement(gridRow);
			}
			
			// add fill to rect
			if (component is Rect) {
				var fill:SolidColor = new SolidColor();
				fill.color = 0xf6f6f6;
				Rect(component).fill = fill;
			}
			
			// we need a custom FlexSprite class to do this
			// do this after drop
			/*if ("eventListeners" in component) {
				component.removeAllEventListeners();
			}*/
			
			// if text based or combo box we need to prevent 
			// interaction with cursor
			if (component is TextBase || component is SkinnableTextBase) {
				component.mouseChildren = false;
				
				if ("textDisplay" in component && component.textDisplay) {
					component.textDisplay.enabled = false;
				}
			}
			
			if (component is LinkButton) {
				LinkButton(component).useHandCursor = false;
			}
			/*
			if (component is IFlexDisplayObject) {
				//component.width = IFlexDisplayObject(component).measuredWidth;
				//component.height = IFlexDisplayObject(component).measuredHeight;
			}*/
			
			if (component is GroupBase) {
				DisplayObjectUtils.addGroupMouseSupport(component as GroupBase);
			}
			
			// we can't add elements if skinnablecontainer._deferredContentCreated is false
			/*if (component is BorderContainer) {
				BorderContainer(component).creationPolicy = ContainerCreationPolicy.ALL;
				BorderContainer(component).initialize();
				BorderContainer(component).createDeferredContent();
				BorderContainer(component).initialize();
			}*/
			
			return component;
		}
		
		/**
		 * Exports an XML string for a project
		 * */
		public function exportProject(project:IProject, format:String = "String"):String {
			var projectString:String = project.toString();
			
			return projectString;
		}
		
		/**
		 * Creates a project
		 * */
		public function createProject(name:String = null):IProject {
			var newProject:IProject = new Project();
			
			newProject.name = name ? name : "Project "  + Project.nameIndex;
			newProject.host = getWPURL();
			
			return newProject;
		}
		
		
		// Error #1047: Parameter initializer unknown or is not a compile-time constant.
		// Occassionally a 1047 error shows up. 
		// This is from using a static var in the parameter as the default 
		// and is an error in FB - run clean and it will go away
		
		/**
		 * Adds a project to the projects array. We should remove open project behavior. 
		 * */
		public function addProject(newProject:IProject, open:Boolean = false, locations:String = null, dispatchEvents:Boolean = true):IProject {
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
				dispatchProjectAddedEvent(newProject);
			}

			if (open) {
				openProject(newProject, locations, dispatchEvents);// TODO project opened or changed
			}

			return newProject;
		}
		
		/**
		 * Opens the project. Right now this does not do much. 
		 * */
		public function openProject(iProject:IProject, locations:String = null, dispatchEvents:Boolean = true):Object {
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
			iProject.open(locations);
			
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
		 * Project opened result handler
		 * */
		public function projectOpenResultHandler(event:Event):void {
			var iProject:IProject = event.currentTarget as IProject;
			
			// add assets
			addAssets(iProject.assets);
			
			if (iProject is EventDispatcher) {
				EventDispatcher(iProject).removeEventListener(Project.PROJECT_OPENED, projectOpenResultHandler);
			}
			
			dispatchProjectOpenedEvent(iProject);
		}
		
		/**
		 * Opens the project. Right now this does not do much. 
		 * */
		public function openProjectFromMetaData(iProject:IProject, locations:String = null, dispatchEvents:Boolean = true):Object {
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
		public function isProjectOpen(iProject:IProject):Boolean {
			
			return iProject.isOpen;
		}
		
		/**
		 * Closes project if open.
		 * */
		public function closeProject(iProject:IProject, dispatchEvents:Boolean = true):Boolean {
			var length:int = iProject.documents.length;
			log.info("Close project");
			if (dispatchEvents) {
				dispatchProjectClosingEvent(iProject);
			}
			
			for (var i:int=length;i--;) {
				closeDocument(IDocument(iProject.documents[i]));
				//removeDocument(IDocument(iProject.documents[i]));
			}
			
			iProject.close();
			
			if (dispatchEvents) {
				dispatchProjectClosedEvent(iProject);
			}
			
			return false;			
		}
		
		/**
		 * Removes a project from the projects array. TODO Remove from server
		 * */
		public function removeProject(iProject:IProject, locations:String = null, dispatchEvents:Boolean = true):Boolean {
			// 1047: Parameter initializer unknown or is not a compile-time constant.
			// Occassionally a 1047 error shows up. 
			// This is from using a static var in the parameter as the default 
			// and is an error in FB - run clean and it will go away
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			
			var projectIndex:int = projects.indexOf(iProject);
			var removedProject:IProject;
			var remote:Boolean = getIsRemoteLocation(locations);
			
			if (projectIndex!=-1) {
				var removedProjects:Array = projects.splice(projectIndex, 1);
				
				if (removedProjects[0]==iProject) {
					log.info("Project removed successfully");
					
					var length:int = iProject.documents.length;
					
					for (var i:int=length;i--;) {
						removeDocument(IDocument(iProject.documents[i]), locations, dispatchEvents);
					}
				}
				
			}
		
			if (remote && iProject && iProject.id) { 
				// we need to create service
				if (deleteProjectService==null) {
					var service:WPService = new WPService();
					service = new WPService();
					service.host = getWPURL();
					service.addEventListener(WPService.RESULT, deleteProjectResultsHandler, false, 0, true);
					service.addEventListener(WPService.FAULT, deleteProjectFaultHandler, false, 0, true);
					deleteProjectService = service;
				}
				
				deleteProjectInProgress = true;
				
				deleteProjectService.id = iProject.id;
				deleteProjectService.deletePost();
			}
			else if (remote) {
				if (dispatchEvents) {
					dispatchProjectRemovedEvent(iProject);
					dispatchProjectDeletedEvent(true, iProject);
				}
				return false;
			}
			
			// get first or last open document and select the project it's part of
			if (!selectedProject) {
				// to do
			}

			if (!remote && dispatchEvents) {
				dispatchProjectRemovedEvent(iProject);
			}
			

			return true;
		}
		
		/**
		 * Create project from project data
		 * */
		public function createProjectFromData(projectData:IProjectData):IProject {
			var newProject:IProject = createProject();
			newProject.unmarshall(projectData);
			
			return newProject;
		}
		
		/**
		 * Create project from project XML data
		 * */
		public function createProjectFromXML(projectData:XML):IProject {
			var newProject:IProject = createProject();
			newProject.unmarshall(projectData);
			
			return newProject;
		}
		
		/**
		 * Create document from document data
		 * */
		public function createDocumentDataFromMetaData(documentData:IDocumentMetaData, overwrite:Boolean = false):IDocumentData {
			var newDocument:IDocumentData = new DocumentData();
			newDocument.unmarshall(documentData);
			
			return newDocument;
		}
		
		/**
		 * Create document from document data
		 * */
		public function createDocumentFromData(documentData:IDocumentData, overwrite:Boolean = false):IDocument {
			var newDocument:IDocument = createDocument(documentData.name, documentData.type);
			newDocument.unmarshall(documentData);
			
			return newDocument;
		}
		
		/**
		 * Create document from document meta data
		 * */
		public function createDocumentFromMetaData(documentMetaData:IDocumentMetaData, overwrite:Boolean = false):IDocument {
			var documentData:IDocumentData = createDocumentDataFromMetaData(documentMetaData, overwrite);
			var iDocument:IDocument = createDocumentFromData(documentData, overwrite);
			
			return iDocument;
		}
		
		/**
		 * Open saved documents if they exist or open a blank document
		 * */
		public function openInitialProjects():void {
			/*
			if (savedData && (savedData.projects.length>0 || savedData.documents.length>0)) {
				restoreSavedData(savedData);
			}
			else {
				createBlankDemoDocument();
			}
			*/
			
			if (!isUserLoggedIn) {
				if (savedData && (savedData.projects.length>0 || savedData.documents.length>0)) {
					openLocalProjects(savedData);
				}
				else {
					createBlankDemoDocument();
				}
			}
			else {
				getProjects();
				getAttachments();
			}
		}
		
		/**
		 * Creates a blank project
		 * */
		public function createBlankDemoDocument(projectName:String = null, documentName:String = null, type:Class = null, open:Boolean = true, dispatchEvents:Boolean = false, select:Boolean = true):IDocument {
			var newProject:IProject;
			var newDocument:IDocument;
			
			newProject = createProject(projectName); // create project
			addProject(newProject);       // add to projects array - shows up in application
			
			newDocument = createDocument(documentName); // create document
			addDocument(newDocument, newProject); // add to project and documents array - shows up in application
			
			openProject(newProject); // should open documents - maybe we should do all previous steps in this function???
			openDocument(newDocument, DocumentData.INTERNAL_LOCATION, true, true); // add to application and parse source code if any
			
			setProject(newProject); // selects project 
			
			return newDocument;
		}
		
		/**
		 * Creates a document
		 * */
		public function createDocument(name:String = null, Type:Object = null, project:IProject = null):IDocument {
			var hasDefinition:Boolean;
			var DocumentType:Object;
			var iDocument:IDocument;
			
			if (Type is String && Type!="null" && Type!="") {
				hasDefinition = ApplicationDomain.currentDomain.hasDefinition(String(Type));
				DocumentType = Document;
				
				if (hasDefinition) {
					DocumentType = ApplicationDomain.currentDomain.getDefinition(String(Type));
					iDocument = new DocumentType();
				}
				else {
					throw new Error("Type specified, '" + String(Type) + "' to create document is not found");
				}
			}
			else if (Type is Class) {
				iDocument = new Type();
			}
			else {
				iDocument = new Document();
			}
			
			iDocument.name = name ? name : "Document";
			iDocument.host = getWPURL();
			//document.documentData = document.marshall();
			return iDocument;
		}
		
		/**
		 * Adds a document to a project if set and adds it to the documents array
		 * */
		public function addDocument(iDocument:IDocument, project:IProject = null, overwrite:Boolean = false, dispatchEvents:Boolean = true):IDocument {
			var documentAlreadyExists:Boolean;
			var length:int;
			var documentAdded:Boolean;
			
			documentAlreadyExists = doesDocumentExist(iDocument.uid);
			
			// if not added already add to documents array
			if (!documentAlreadyExists) {
				documents.push(iDocument);
				documentAdded = true;
			}
			
			if (documentAlreadyExists && overwrite) {
				// check dates
				// remove from documents
				// remove from projects
				// add to documents
				// add to projects
				var documentToRemove:IDocument = getDocumentByUID(iDocument.uid);
				removeDocument(documentToRemove, DocumentData.LOCAL_LOCATION);// this is deleting the document
				// should there be a remove (internally) and delete method?
				
				//throw new Error("Document overwrite is not implemented yet");
				documentAdded = true;
			}
			
			if (project) {
				project.addDocument(iDocument, overwrite);
			}
			
			if (documentAdded && dispatchEvents) {
				dispatchDocumentAddedEvent(iDocument);
			}
			
			return iDocument;
		}
		
		/**
		 * Reverts a document to its open state
		 * */
		public function revertDocument(iDocument:IDocument, dispatchEvents:Boolean = true):Boolean {
			
			// TODO
			return false;
		}
		
		/**
		 * Removes a document from the documents array
		 * */
		public function removeDocument(iDocument:IDocument, locations:String = null, dispatchEvents:Boolean = true):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var parentProject:IProject = iDocument.project;
			var documentsIndex:int = parentProject.documents.indexOf(iDocument);
			var removedDocument:IDocument;
			var remote:Boolean = getIsRemoteLocation(locations);
			
			if (documentsIndex!=-1) {
				// add remove document to project
				var removedDocuments:Array = parentProject.documents.splice(documentsIndex, 1);
				
				if (removedDocuments[0]==iDocument) {
					//log.info("Document removed successfully");
				}
			}
			
			closeDocument(iDocument);
			// check if document is open in tab navigator
			/*if (isDocumentOpen(iDocument)) {
				var closed:Boolean = closeDocument(iDocument);
				log.info("Closed " + iDocument.name);
			}*/
			
			if (remote && iDocument && iDocument.id) { 
				// we need to create service
				if (deleteDocumentService==null) {
					deleteDocumentService = new WPService();
					deleteDocumentService.addEventListener(WPService.RESULT, deleteDocumentResultsHandler, false, 0, true);
					deleteDocumentService.addEventListener(WPService.FAULT, deleteDocumentFaultHandler, false, 0, true);
				}
				
				deleteDocumentService.host = getWPURL();
				
				deleteDocumentInProgress = true;
				
				deleteDocumentService.id = iDocument.id
				deleteDocumentService.deletePost();
			}
			else if (remote) { // document not saved yet
				
				if (dispatchEvents) {
					dispatchDocumentRemovedEvent(iDocument);
					return true;
				}
			}
			else {
	
				if (dispatchEvents) {
					dispatchDocumentRemovedEvent(iDocument);
				}

			}
			
			// get first or last open document and select the project it's part of
			if (!this.selectedDocument) {
				// to do
			}
			
			return true;
		}
		
		/**
		 * Opens the document from it's document data. If the document is already open it selects it. 
		 * 
		 * It returns the document container. 
		 * */
		public function openDocumentByData(data:IDocumentData, showDocument:Boolean = true, dispatchEvents:Boolean = true):Object {
			var iDocument:IDocument = getDocumentByUID(data.uid);
			
			if (!iDocument) {
				iDocument = createDocumentFromData(data);
			}
			
			var result:Boolean = openDocument(iDocument, DocumentData.INTERNAL_LOCATION, showDocument, dispatchEvents);
			
			return result;
		}
		
		/**
		 * Print
		 * */
		public function print(data:Object, scaleType:String = FlexPrintJobScaleType.MATCH_WIDTH, printAsBitmap:Boolean = false):Object {
			var flexPrintJob:FlexPrintJob = new FlexPrintJob();
			var printableObject:IUIComponent;
			var scaleX:Number;
			var scaleY:Number;
			
			if (data is IDocument) {
				printableObject = IUIComponent(IDocument(data).instance)
			}
			else if (data is IUIComponent) {
				printableObject = IUIComponent(data);
			}
			else {
				Radiate.log.error("Printing failed: Object is not of accepted type.");
				return false;
			}
			
			if (data && "scaleX" in data) {
				scaleX = data.scaleX;
				scaleY = data.scaleY;
			}
			
			flexPrintJob.printAsBitmap = printAsBitmap;
			
			if (printAsBitmap && data is IBitmapDrawable) {
				var imageBitmapData:BitmapData = ImageSnapshot.captureBitmapData(IBitmapDrawable(data));
				var bitmapImage:BitmapImage = new BitmapImage();
                bitmapImage.source = new Bitmap(imageBitmapData);
				//data = bitmapImage;
			}
			
			// show OS print dialog
			// printJobStarted is false if user cancels OS print dialog
			var printJobStarted:Boolean = flexPrintJob.start();
			
			
			// if user cancels print job and we continue then the stage disappears! 
			// so we exit out (ie we don't do the try statement)
			// workaround if we set the scale it reappears 
			// so, scaleX and scaleY are set to NaN on the object when we try to print and it fails
			if (!printJobStarted) {
				log.error("Print job was not started");
				dispatchPrintCancelledEvent(data, flexPrintJob);
				return false;
			}
			
			try {
				//log.info("Print width and height: " + flexPrintJob.pageWidth + "x" + flexPrintJob.pageHeight);
				flexPrintJob.addObject(printableObject, scaleType);
				flexPrintJob.send();
				dispatchPrintCompleteEvent(data, flexPrintJob);
			}
			catch(e:Error) {
				// CHECK scale X and scale Y to see if they are null - see above
				if (data && "scaleX" in data && data.scaleX!=scaleX) {
					data.scaleX = scaleX;
					data.scaleY = scaleY;
				}
				
				// Printing failed: Error #2057: The page could not be added to the print job.
				Radiate.log.error("Printing failed: " + e.message);
				
				// TODO this should be print error event
				dispatchPrintCancelledEvent(data, flexPrintJob);
				return false;
			} 
			
			return true;
		}
		
		/**
		 * Import code. 
		 * 
		 * TODO: 
		 * - import mxml code to new document
		 * - import mxml code to existing document ovewrite current document
		 * - import document xml (wraps mxml application) 
		 * - import mxml to a container or group
		 * */
		public function importMXMLDocument(project:IProject, iDocument:IDocument, container:IVisualElement, code:String, dispatchEvents:Boolean = true):Boolean {
			var result:Object;
			var newDocument:Boolean;
			
			if (!iDocument) {
				iDocument = createDocument();
				newDocument = true;
				
				if (project) {
					addDocument(iDocument, project);
				}
			}
			
			
			if (!newDocument) {
				iDocument.parseSource(code, container);
			}
			else {
				iDocument.source = code;
				result = openDocument(iDocument, DocumentData.INTERNAL_LOCATION, true, dispatchEvents);
			}
			
			return result;
		}
		
		/**
		 * Opens the document. If the document is already open it selects it. 
		 * When the document loads (it's a blank application swf) then the mxml is parsed. Check the DocumentContainer class.  
		 * 
		 * It returns the document container. 
		 * */
		public function openDocument(iDocument:IDocument, locations:String = null, showDocumentInTab:Boolean = true, dispatchEvents:Boolean = true):Object {
			var documentContainer:DocumentContainer;
			var navigatorContent:NavigatorContent;
			var openingEventDispatched:Boolean;
			var containerTypeInstance:Object;
			var isAlreadyOpen:Boolean;
			var container:Object;
			var documentIndex:int;
			var previewName:String;
			var index:int;
			
			isAlreadyOpen = isDocumentOpen(iDocument);
			
			if (dispatchEvents) {
				openingEventDispatched = dispatchDocumentOpeningEvent(iDocument);
				
				if (!openingEventDispatched) {
					//return false;
				}
			}
			
			if (isAlreadyOpen) {
				index = getDocumentTabIndex(iDocument);
				
				if (showDocumentInTab) {
					//showDocument(iDocument, false, false); // the next call will dispatch events
					showDocument(iDocument, false, dispatchEvents); // the next call will dispatch events
					setDocument(iDocument, dispatchEvents);
				}
				return documentsContainerDictionary[iDocument];
			}
			else {
				iDocument.open(locations);
			}
			
			// TypeError: Error #1034: Type Coercion failed: cannot convert 
			// com.flexcapacitor.components::DocumentContainer@114065851 to 
			// mx.core.INavigatorContent
			navigatorContent = new NavigatorContent();
			navigatorContent.percentWidth = 100;
			navigatorContent.percentHeight = 100;
			
			navigatorContent.label = iDocument.name ? iDocument.name : "Untitled";
			
			
			if (iDocument.containerType==null) {
				documentContainer = new DocumentContainer();
				documentContainer.percentWidth = 100;
				documentContainer.percentHeight = 100;
				
				documentsContainerDictionary[iDocument] = documentContainer;
				navigatorContent.addElement(documentContainer);
				documentContainer.iDocument = IDocument(iDocument);
			}
			else {
				// custom container
				containerTypeInstance = new iDocument.containerType();
				//containerTypeInstance.id = document.name ? document.name : "";
				containerTypeInstance.percentWidth = 100;
				containerTypeInstance.percentHeight = 100;
				
				documentsContainerDictionary[iDocument] = containerTypeInstance;
				navigatorContent.addElement(containerTypeInstance as IVisualElement);
				containerTypeInstance.iDocument = IDocument(iDocument);
			}
		
			if (documentsTabNavigator) {
				//documentIndex = !isPreview ? 0 : getDocumentIndex(document) + 1;
				documentsTabNavigator.addElement(navigatorContent);
			}
			documentIndex = getDocumentTabIndex(iDocument);
			
			// show document
			if (showDocumentInTab) {
				showDocument(iDocument, false, dispatchEvents);
				setDocument(iDocument, dispatchEvents);
			}
			
			return documentsContainerDictionary[iDocument];
		}
		
		/**
		 * Opens a preview of the document. If the document is already open it selects it. 
		 * 
		 * It returns the document container. 
		 * */
		public function openDocumentPreview(iDocument:IDocument, showDocument:Boolean = false, dispatchEvents:Boolean = true):Object {
			var documentContainer:DocumentContainer;
			var navigatorContent:NavigatorContent;
			var isAlreadyOpen:Boolean;
			var index:int;
			var iframe:IFrame;
			var containerTypeInstance:Object;
			var container:Object;
			var openingEventDispatched:Boolean;
			var documentIndex:int;
			var previewName:String;
			
			isAlreadyOpen = isDocumentPreviewOpen(iDocument);
			
			if (dispatchEvents) {
				openingEventDispatched = dispatchDocumentOpeningEvent(iDocument, true);
				if (!openingEventDispatched) {
					//return false;
				}
			}
			
			if (isAlreadyOpen) {
				index = getDocumentPreviewIndex(iDocument);
				
				if (showDocument) {
					showDocumentAtIndex(index, false); // the next call will dispatch events
					setDocument(iDocument, dispatchEvents);
				}
				return documentsPreviewDictionary[iDocument];
			}
			else {
				iDocument.isPreviewOpen = true;
			}
			
			// TypeError: Error #1034: Type Coercion failed: cannot convert 
			// com.flexcapacitor.components::DocumentContainer@114065851 to 
			// mx.core.INavigatorContent
			navigatorContent = new NavigatorContent();
			navigatorContent.percentWidth = 100;
			navigatorContent.percentHeight = 100;
			
			navigatorContent.label = iDocument.name ? iDocument.name : "Untitled";
			
			previewName = iDocument.name + " HTML";
			navigatorContent.label = previewName;
			
			if (iDocument.containerType) {
				containerTypeInstance = new iDocument.containerType();
				containerTypeInstance.id = iDocument.name ? iDocument.name : iframe.name; // should we be setting id like this?
				containerTypeInstance.percentWidth = 100;
				containerTypeInstance.percentHeight = 100;
				
				navigatorContent.addElement(containerTypeInstance as IVisualElement);
				documentsPreviewDictionary[iDocument] = containerTypeInstance;
			}
			else {
				// show HTML page
				iframe = new IFrame();
				iframe.id = iDocument.name ? iDocument.name : iframe.name; // should we be setting id like this?
				iframe.percentWidth = 100;
				iframe.percentHeight = 100;
				iframe.top = 20;
				iframe.left = 20;
				iframe.setStyle("backgroundColor", "#666666");
				
				navigatorContent.addElement(iframe);
				documentsPreviewDictionary[iDocument] = iframe;
			}
			
			
			// if preview add after original document location
			documentIndex = getDocumentTabIndex(iDocument) + 1; // add after
			documentsTabNavigator.addElementAt(navigatorContent, documentIndex);
			
			// show document
			if (showDocument) {
				showDocumentAtIndex(documentIndex, dispatchEvents);
				setDocument(iDocument, dispatchEvents);
			}
			
			return documentsPreviewDictionary[iDocument];
		}
		
		/**
		 * Checks if a document preview is open.
		 * @see isDocumentSelected
		 * */
		public function isDocumentPreviewOpen(document:IDocument):Boolean {
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var tab:NavigatorContent;
			var tabContent:Object;
			var documentContainer:Object = documentsPreviewDictionary[document];
			
			for (var i:int;i<tabCount;i++) {
				tab = NavigatorContent(documentsTabNavigator.getChildAt(i));
				tabContent = tab.numElements ? tab.getElementAt(0) : null;
				
				if (tabContent && tabContent==documentContainer) {
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Checks if document is open.
		 * @see isDocumentSelected
		 * */
		public function isDocumentOpen(document:IDocument, isPreview:Boolean = false):Boolean {
			var openTabs:Array;
			var tabCount:int;
			var tab:NavigatorContent;
			var tabContent:Object;
			var documentContainer:Object;
			
			if (!documentsTabNavigator) {
				return false;
			}
			
			openTabs = documentsTabNavigator.getChildren();
			tabCount = openTabs.length;
			documentContainer = isPreview ? documentsPreviewDictionary[document] : documentsContainerDictionary[document];
			
			for (var i:int;i<tabCount;i++) {
				tab = NavigatorContent(documentsTabNavigator.getChildAt(i));
				tabContent = tab.numElements ? tab.getElementAt(0) : null;
				
				if (tabContent && tabContent==documentContainer) {
					return true;
				}
			}
			
			return false;
			
		}
		
		/**
		 * Closes the current visible document regardless if it is a preview or not. 
		 * @see isDocumentSelected
		 * */
		public function closeVisibleDocument():Boolean {
			
			var selectedDocument:IDocument = getDocumentAtIndex(documentsTabNavigator.selectedIndex);
			var isPreview:Boolean = isPreviewDocumentVisible();
			
			return closeDocument(selectedDocument, isPreview);
			
		}
		
		/**
		 * Closes document if open.
		 * @see isDocumentSelected
		 * */
		public function closeDocument(iDocument:IDocument, isPreview:Boolean = false):Boolean {
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var navigatorContent:NavigatorContent;
			var navigatorContentDocumentContainer:Object;
			var documentContainer:Object = isPreview ? documentsPreviewDictionary[iDocument] : documentsContainerDictionary[iDocument];
			
			
			// third attempt
			
			
			// second attempt
			
			if (documentContainer && documentContainer.owner) {
				// ArgumentError: Error #2025: The supplied DisplayObject must be a child of the caller.
				// 	at flash.display::DisplayObjectContainer/getChildIndex()
				//var index:int = documentsTabNavigator.getChildIndex(documentContainer.owner as DisplayObject);
				var contains:Boolean = documentsTabNavigator.contains(documentContainer.owner as DisplayObject);
				
				if (contains) {
					documentsTabNavigator.removeChild(documentContainer.owner);
					
					// close previews when the main document is closed
					if (!isPreview) {
						documentContainer = documentsPreviewDictionary[iDocument];
						
						if (documentContainer) {
							documentsTabNavigator.removeChild(documentContainer.owner);
						}
						
						iDocument.close();
						//removeDocument(iDocument);
						
						//var documentContainer:Object = isPreview ? documentsPreviewDictionary[iDocument] : documentsDictionary[iDocument];
						
						delete documentsContainerDictionary[iDocument];
						delete documentsPreviewDictionary[iDocument];
					}
					else {
						delete documentsPreviewDictionary[iDocument];
					}
					
					if (isPreview) {
						// TODO we must remove HTML from IFrame (inline css from previous iframes previews affects current preview)
					}
					
					documentsTabNavigator.validateNow();
					
				}
			}
			
			
			return true;
			// first attempt
			//log.info("Closing " + iDocument.name);
			for (var i:int;i<tabCount;i++) {
				navigatorContent = NavigatorContent(documentsTabNavigator.getChildAt(i));
				navigatorContentDocumentContainer = navigatorContent.numElements ? navigatorContent.getElementAt(0) : null;
				//log.info(" Checking tab " + tab.label);
				
				if (iDocument.name==navigatorContent.label) {
					//log.info(" Name Match " + iDocument.name);
					if (IDocumentContainer(navigatorContentDocumentContainer).iDocument==iDocument) {
						documentsTabNavigator.removeChild(navigatorContent);
						documentsTabNavigator.validateNow();
						
						return true;
					}
				}
				
				
				// oddly enough after we remove one child using the code below (note: see update)
				// the documentContainer in the documentsDictionary is no longer 
				// connected with the correct document data 
				// if we do this one at a time and remove one per second 
				// then it works but not many documents at a time (see removeProject)
				// so instead we are checking by name and then document reference 
				// in the code above this
				
				// Update: May have spoken too soon - could be problem because document 
				// was used as a variable name and it scoped to document on the UIComponent class :(
				
				if (navigatorContentDocumentContainer && navigatorContentDocumentContainer==documentContainer) {
					documentsTabNavigator.removeChild(navigatorContent);
					documentsTabNavigator.validateNow();
					return true;
				}
			}
			
			return false;
			
		}
		
		/**
		 * Checks if document is open and selected
		 * */
		public function isDocumentSelected(document:Object, isPreview:Boolean = false):Boolean {
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var tab:NavigatorContent;
			var tabContent:Object;
			var documentIndex:int = -1;
			var documentContainer:Object = isPreview ? documentsPreviewDictionary[document] : documentsContainerDictionary[document];
			
			for (var i:int;i<tabCount;i++) {
				tab = NavigatorContent(documentsTabNavigator.getChildAt(i));
				tabContent = tab.numElements ? tab.getElementAt(0) : null;
				
				if (tabContent && tabContent==documentContainer) {
					documentIndex = i;
					break;
				}
			}
			

			if (documentsTabNavigator.selectedIndex==documentIndex) {
				return true;
			}
			
			return false;
			
		}
		
		/**
		 * Get visible document in documents tab navigator
		 * */
		public function getVisibleDocument():IDocument {
			var selectedTab:NavigatorContent = documentsTabNavigator ? documentsTabNavigator.selectedChild as NavigatorContent : null;
			var tabContent:Object = selectedTab && selectedTab.numElements ? selectedTab.getElementAt(0) : null;
			
			if (tabContent is IDocumentContainer) {
				var iDocument:IDocument = IDocumentContainer(tabContent).iDocument;
				return iDocument;
			}
			
			return null;
		}
		
		/**
		 * Get the index of the document in documents tab navigator
		 * */
		public function getDocumentTabIndex(document:Object, isPreview:Boolean = false):int {
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var tab:NavigatorContent;
			var documentContainer:Object = isPreview ? documentsPreviewDictionary[document] : documentsContainerDictionary[document];
			var tabContent:Object;
			
			for (var i:int;i<tabCount;i++) {
				tab = NavigatorContent(documentsTabNavigator.getChildAt(i));
				tabContent = tab.numElements ? tab.getElementAt(0) : null;
				
				if (tabContent && tabContent==documentContainer) {
					return i;
				}
			}
			
			return -1;
		}
		
		/**
		 * Get the index of the document preview in documents tab navigator
		 * */
		public function getDocumentPreviewIndex(document:Object):int {
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var tab:NavigatorContent;
			var documentContainer:Object = documentsPreviewDictionary[document];
			var tabContent:Object;
			
			for (var i:int;i<tabCount;i++) {
				tab = NavigatorContent(documentsTabNavigator.getChildAt(i));
				tabContent = tab.numElements ? tab.getElementAt(0) : null;
				
				if (tabContent && tabContent==documentContainer) {
					return i;
				}
			}
			
			return -1;
		}
		
		/**
		 * Get the document for the given application
		 * */
		public function getDocumentForApplication(application:Application):IDocument {
			var document:IDocument;
			
			for each (document in documentsContainerDictionary) {
				if (document.instance === application) {
					return document;
					break;
				}
			}
			return null;
		}
		
		/**
		 * Gets the document container for the document preview. 
		 * For example, a document can be previewed as an HTML page. 
		 * If we want to get the document that is previewing HTML then 
		 * we need to get the container of the preview.
		 * */
		public function getDocumentPreview(document:Object):Object {
			var documentContainer:Object = documentsPreviewDictionary[document];
			return documentContainer;
		}
		
		/**
		 * Returns if the visible document is a preview
		 * */
		public function isPreviewDocumentVisible():Boolean {
			var tabContainer:NavigatorContent = documentsTabNavigator.selectedChild as NavigatorContent;
			var tabContent:Object = tabContainer && tabContainer.numElements ? tabContainer.getElementAt(0) : null;
			var isPreview:Boolean;
			
			isPreview = DictionaryUtils.containsValue(documentsPreviewDictionary, tabContent);
			
			//if (!isDocument) {
			//	isDocument = DictionaryUtils.containsValue(documentsPreviewDictionary, tabContainer);
			//}
			
			return isPreview;
		}
		
		
		/**
		 * Selects the document in the tab navigator
		 * */
		public function showDocument(iDocumentData:IDocumentData, isPreview:Boolean = false, dispatchEvent:Boolean = true):Boolean {
			var documentIndex:int = getDocumentTabIndex(iDocumentData, isPreview);
			var result:Boolean;
			
			if (documentIndex!=-1) {
				result = showDocumentAtIndex(documentIndex, dispatchEvent);
			}
			
			return result;
		}
		
		
		/**
		 * Selects the document at the specifed index
		 * */
		public function showDocumentAtIndex(index:int, dispatchEvent:Boolean = true):Boolean {
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var tab:NavigatorContent;
			var tabContent:Object;
			var document:IDocument;
			
			documentsTabNavigator.selectedIndex = index;
			
			tab = NavigatorContent(documentsTabNavigator.selectedChild);
			tabContent = tab && tab.numElements ? tab.getElementAt(0) : null;
			
			if (tabContent && tabContent is DocumentContainer && dispatchEvent) {
				document = getDocumentAtIndex(index);
				dispatchDocumentChangeEvent(DocumentContainer(tabContent).iDocument);
			}
			
			return documentsTabNavigator.selectedIndex == index;
		}
		
		/**
		 * Get the document at the index in the tab navigator
		 * */
		public function getDocumentAtIndex(index:int):IDocument {
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var tab:NavigatorContent;
			var tabContent:Object;
			var document:IDocument;
			
			if (index<0) {
				return null;
			}
			
			tab = index < openTabs.length ? openTabs[index] : null;
			tabContent = tab.numElements ? tab.getElementAt(0) : null;
	
			for (var key:* in documentsContainerDictionary) {
				if (documentsContainerDictionary[key] === tabContent) {
					return key;
				}
			}
			
	
			for (key in documentsPreviewDictionary) {
				if (documentsPreviewDictionary[key] === tabContent) {
					return key;
				}
			}
			
			return null;
			
		}
		
		/**
		 * Get document by UID
		 * */
		public function getDocumentByUID(id:String):IDocument {
			var length:int = documents.length;
			var iDocument:IDocument;
			
			for (var i:int;i<length;i++) {
				iDocument = IDocument(documents[i]);
				
				if (id==iDocument.uid) {
					return iDocument;
				}
			}
			
			return null;
		}
		
		/**
		 * Check if document exists in documents array
		 * */
		public function doesDocumentExist(id:String):Boolean {
			var length:int = documents.length;
			var iDocument:IDocument;
			
			for (var i:int;i<length;i++) {
				iDocument = IDocument(documents[i]);
				
				if (id==iDocument.uid) {
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Check if project exists in projects array. Pass in the UID not ID.
		 * */
		public function doesProjectExist(uid:String):Boolean {
			var length:int = projects.length;
			var iProject:IProject;
			
			for (var i:int;i<length;i++) {
				iProject = IProject(projects[i]);
				
				if (uid==iProject.uid) {
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * Get project by UID
		 * */
		public function getProjectByUID(id:String):IProject {
			var length:int = projects.length;
			var iProject:IProject;
			
			for (var i:int;i<length;i++) {
				iProject = IProject(projects[i]);
				
				if (id==iProject.uid) {
					return iProject;
				}
			}
			
			return null;
		}
		
		/**
		 * Get first project that owns this document
		 * */
		public function getDocumentProject(iDocument:IDocument):IProject {
			var projectsList:Array = getDocumentProjects(iDocument);
			var iProject:IProject;
			
			if (projectsList.length>0) {
				iProject = projectsList.shift();
			}
			
			return iProject;
		}
		
		/**
		 * Get a list of projects that own this document
		 * */
		public function getDocumentProjects(iDocument:IDocument):Array {
			var documentsLength:int;
			var projectDocument:IDocument;
			var projectLength:int = projects.length;
			var iProject:IProject;
			var projectDocuments:Array;
			var projectsList:Array = [];
			
			for (var A:int;A<length;A++) {
				iProject = IProject(projects[A]);
				projectDocuments = iProject.documents;
				
				for (var B:int;B<documentsLength;B++) {
					projectDocument = IDocument(projectDocuments[B]);
					
					if (projectDocuments.uid==iDocument.uid) {
						projectsList.push(iProject);
					}
				}
			}
			
			return projectsList;
		}
		
		
		/**
		 * Rename document
		 * */
		public function renameDocument(iDocument:IDocument, name:String):void {
			var tab:NavigatorContent;
			
			// todo check if name already exists
			iDocument.name = name;
			tab = getNavigatorByDocument(iDocument);
			
			if (iDocument.instance is Application) {
				setProperty(iDocument.instance, "pageTitle", name);
			}
			
			if (tab) {
				tab.label = iDocument.name;
			}
			
			dispatchDocumentRenameEvent(iDocument, name);
		}
		
		/**
		 * 
		 * */
		public function getNavigatorByDocument(iDocument:IDocument, isPreview:Boolean = false):NavigatorContent {
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var tab:NavigatorContent;
			var tabContent:Object;
			var documentContainer:Object = isPreview ? documentsPreviewDictionary[iDocument] : documentsContainerDictionary[iDocument];
			
			for (var i:int;i<tabCount;i++) {
				tab = NavigatorContent(documentsTabNavigator.getChildAt(i));
				tabContent = tab.numElements ? tab.getElementAt(0) : null;
				
				if (tabContent && tabContent==documentContainer) {
					return tab;
				}
			}
			
			return null;
		}
		
		
		//----------------------------------
		//
		//  Persistant Data Management
		// 
		//----------------------------------
		
		/**
		 * Creates the saved data
		 * */
		public static function createSavedData():Boolean {
			var result:Object = SharedObjectUtils.getSharedObject(SAVED_DATA_NAME);
			var so:SharedObject;
			
			if (result is SharedObject) {
				so = SharedObject(result);
				
				if (so.data) {
					if (SAVED_DATA_NAME in so.data && so.data[SAVED_DATA_NAME]!=null) {
						savedData = SavedData(so.data[SAVED_DATA_NAME]);
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
				log.error("Could not get saved data. " + ObjectUtil.toString(result));
			}
			
			return true;
		}
		
		
		/**
		 * Creates the settings data
		 * */
		public static function createSettingsData():Boolean {
			var result:Object = SharedObjectUtils.getSharedObject(SETTINGS_DATA_NAME);
			var so:SharedObject;
			
			if (result is SharedObject) {
				so = SharedObject(result);
				
				if (so.data) {
					if (SETTINGS_DATA_NAME in so.data && so.data[SETTINGS_DATA_NAME]!=null) {
						settings = Settings(so.data[SETTINGS_DATA_NAME]);
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
				log.error("Could not get saved settings data. " + ObjectUtil.toString(result));
			}
			
			return true;
		}
		
		/**
		 * Get saved data
		 * */
		public function getSavedData():Boolean {
			var result:Object = SharedObjectUtils.getSharedObject(SAVED_DATA_NAME);
			var so:SharedObject;
			
			var data:SavedData;
			
			if (result is SharedObject) {
				so = SharedObject(result);
				
				if (so.data) {
					if (SAVED_DATA_NAME in so.data) {
						data = SavedData(so.data[SAVED_DATA_NAME]);
						
						openLocalProjects(data);
					}
				}
			}
			else {
				log.error("Could not get saved data. " + ObjectUtil.toString(result));
			}
			
			return result;
		}
		
		/**
		 * Create new document. 
		 * */
		public function createNewDocument(name:String = null, type:Object = null, project:IProject = null):void {
			var newDocument:IDocument;
			var length:int;
			
			newDocument = createDocument(name, type);
			addDocument(newDocument, selectedProject, true, true);
			openDocument(newDocument, DocumentData.INTERNAL_LOCATION, true);
			/*
			
			if (project) {
				project.addDocument(iDocument, overwrite);
			}
			
			if (documentAdded && dispatchEvents) {
				dispatchDocumentAddedEvent(iDocument);
			}
			
			if (!selectedProject) {
				project = createProject(); // create project
				addProject(project);       // add to projects array - shows up in application
			}
			else {
				project = selectedProject;
			}
			
			newDocument = createDocument(name, type); // create document
			addDocument(newDocument, project); // add to project and documents array - shows up in application
			
			//openProject(newProject); // should open documents - maybe we should do all previous steps in this function???
			openDocument(newDocument, true, true); // add to application and parse source code if any
			
			setProject(project); // selects project 
			setDocument(newDocument);*/
		}
		
		/**
		 * Create new project. 
		 * */
		public function createNewProject(name:String = null, type:Object = null, project:IProject = null):void {
			var newProject:IProject;
			
			newProject = createProject(); // create project
			addProject(newProject);       // add to projects array - shows up in application
			
			openProject(newProject); // should open documents - maybe we should do all previous steps in this function???
			
			setProject(newProject); // selects project 
			
		}
		
		/**
		 * Create and add saved documents of array of type IDocumentData. 
		 * */
		public function createAndAddDocumentsData(documentsData:Array, add:Boolean = true):Array {
			var potentialDocuments:Array = [];
			var iDocumentMetaData:IDocumentMetaData;
			var iDocumentData:IDocumentData;
			var iDocument:IDocument;
			var length:int;
				
			// get documents and add them to the documents array
			
			// TRYING TO NOT create documents until they are needed
			// but then we have issues when we want to save
			if (documentsData && documentsData.length>0) {
				length = documentsData.length;
				
				for (var i:int;i<length;i++) {
					// TypeError: Error #1034: Type Coercion failed: cannot convert com.flexcapacitor.model::DocumentMetaData
					// to com.flexcapacitor.model.IDocumentData. check export and marshall options
					// saved as wrong data type
					iDocumentData = IDocumentData(documentsData[i]);
					
					// document doesn't exist - add it
					if (getDocumentByUID(iDocumentData.uid)==null) {
						iDocument = createDocumentFromData(iDocumentData);
						potentialDocuments.push(iDocument);
						
						if (add) {
							addDocument(iDocument);
						}
					}
					else {
						log.info("Document " + iDocumentData.name + " is already open.");
					}
				}
			}
			
			return potentialDocuments;
		}
		
		/**
		 * Create projects from array of type IProjectData
		 * */
		public function createAndAddProjectsData(projectsData:Array, add:Boolean = true):Array {
			var iProjectData:IProjectData;
			var potentialProjects:Array = [];
			var length:int;
			var iProject:IProject;
			
			// get projects and add them to the projects array
			if (projectsData && projectsData.length>0) {
				length = projectsData.length;
				
				for (var i:int;i<length;i++) {
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
						log.info("Project " + iProjectData.name + " is already open.");
					}
					
				}
			}
			
			return potentialProjects;
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
		public function openLocalProjects(data:SavedData):void {
			var projectsDataArray:Array;
			var potentialProjects:Array  = [];
			var potentialDocuments:Array = [];
			var savedDocumentsDataArray:Array;
			var potentialProjectsLength:int;
			var iProject:IProject;
			
			/*
			var iProjectData:IProjectData;
			var iDocumentData:IDocumentData;
			var iDocumentMetaData:IDocumentMetaData;
			var iDocument:IDocument;
			var iProjectDocument:IDocument;
			var iProjectDocumentsArray:Array;
			var iProjectDocumentsLength:int;
			var potentialDocumentsLength:int;
			var documentsDataArrayLength:int;*/
			
			// get list of projects and list of documents
			if (data) {
				
				// get projects and add them to the projects array
				projectsDataArray = data.projects;
				potentialProjects = createAndAddProjectsData(data.projects);
				
				// get documents and add them to the documents array
				// TRYING TO NOT create documents until they are needed
				// but then we have issues when we want to save or export
				createAndAddDocumentsData(data.documents);
				//savedDocumentsDataArray = data.documents; // should be potential documents?
				

				// go through projects and add documents to them
				if (potentialProjects.length>0) {
					potentialProjectsLength = potentialProjects.length;
					
					// loop through potentialProjectsLength objects
					for (var i:int;i<length;i++) {
						iProject = IProject(potentialProjects[i]);
						
						iProject.importDocumentInstances(documents);
					}
				}
				
				
				openPreviouslyOpenProjects();
				openPreviouslyOpenDocuments();
				showPreviouslyOpenProject();
				showPreviouslyOpenDocument();
				
			}
			else {
				// no saved data
				log.info("No saved data to restore");
			}
			
		}
		
		/**
		 * Show previously opened project
		 * */
		public function showPreviouslyOpenProject():void {
			var iProject:IProject;
			
			// Select last selected project
			if (settings.selectedProject) {
				iProject = getProjectByUID(settings.selectedProject.uid);
				
				if (iProject && iProject.isOpen) {
					log.info("Opening selected project " + iProject.name);
					setProject(iProject);
				}
			}
			else {
				if (selectedProject==null && projects && projects.length>0) {
					setProject(projects[0]);
				}
			}
		}
		
		/**
		 * Show previously opened document
		 * */
		public function showPreviouslyOpenDocument():void {
			var openDocuments:Array = settings.openDocuments;
			var iDocumentMetaData:IDocumentMetaData;
			var iDocument:IDocument;
			
			// Showing previously selected document
			if (settings.selectedDocument) {
				iDocument = getDocumentByUID(settings.selectedDocument.uid);
				
				if (iDocument && iDocument.isOpen) {
					log.info("Showing previously selected document " + iDocument.name);
					showDocument(iDocument);
					setDocument(iDocument);
				}
			}
		}
		
		/**
		 * Open previously opened documents
		 * */
		public function openPreviouslyOpenDocuments(project:IProject = null):void {
			var openDocuments:Array = settings.openDocuments;
			var iDocumentMetaData:IDocumentMetaData;
			var iDocument:IDocument;
			
			// open previously opened documents
			for (var i:int;i<openDocuments.length;i++) {
				iDocumentMetaData = IDocumentMetaData(openDocuments[i]);
				
				iDocument = getDocumentByUID(iDocumentMetaData.uid);
				
				if (iDocument) {
					
					if (project && project.documents.indexOf(iDocument)!=-1) {
						log.info("Opening project document " + iDocument.name);
						openDocument(iDocument, DocumentData.INTERNAL_LOCATION, false, true);
					}
					else if (project==null) {
						log.info("Opening document " + iDocument.name);
						openDocument(iDocument, DocumentData.INTERNAL_LOCATION, false, true);
					}
				}
				
			}
		}
		
		/**
		 * Open previously opened projects
		 * */
		public function openPreviouslyOpenProjects(locations:String = null):void {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var openProjects:Array = settings.openProjects;
			var iProject:IProject;
			var iProjectData:IProjectData;
			var openItemlength:int = openProjects.length;
			
			// open previously opened projects
			for (var i:int;i<openItemlength;i++) {
				iProjectData = IProjectData(openProjects[i]);
				iProject = getProjectByUID(iProjectData.uid);
				
				if (iProject) {
					log.info("Opening project " + iProject.name);
					openProject(iProject, locations, true);
				}
			}
		}
		
		/**
		 * Get saved settings data
		 * */
		public function getSettingsData():Boolean {
			var result:Object = SharedObjectUtils.getSharedObject(SETTINGS_DATA_NAME);
			var so:SharedObject;
			
			if (result is SharedObject) {
				so = SharedObject(result);
				
				if (so.data) {
					if (SETTINGS_DATA_NAME in so.data) {
						settings = Settings(so.data[SETTINGS_DATA_NAME]);
					}
				}
			}
			else {
				log.error("Could not get saved data. " + ObjectUtil.toString(result));
			}
			
			return result;
		}
		
		/**
		 * Removed saved data
		 * */
		public function removeSavedData():Boolean {
			var result:Object = SharedObjectUtils.getSharedObject(SAVED_DATA_NAME);
			var so:SharedObject;
			
			if (result is SharedObject) {
				so = SharedObject(result);
				
				if (so.data) {
					if (SAVED_DATA_NAME in so.data) {
						so.clear();
						log.info("Cleared saved data");
					}
				}
			}
			else {
				log.error("Could not remove saved data. " + ObjectUtil.toString(result));
			}
			
			return result;
		}
		
		/**
		 * Removed saved settings
		 * */
		public function removeSavedSettings():Boolean {
			var result:Object = SharedObjectUtils.getSharedObject(SETTINGS_DATA_NAME);
			var so:SharedObject;
			
			if (result is SharedObject) {
				so = SharedObject(result);
				
				if (so.data) {
					if (SETTINGS_DATA_NAME in so.data) {
						so.clear(); // this clears the whole thing
						log.info("Cleared settings data");
					}
				}
			}
			else {
				log.error("Could not remove settings data. " + ObjectUtil.toString(result));
			}
			
			return result;
		}
		
		
		/**
		 * Save settings data
		 * */
		public function saveSettings():Boolean {
			var result:Object = SharedObjectUtils.getSharedObject(SETTINGS_DATA_NAME);
			var so:SharedObject;
			
			if (result is SharedObject) {
				updateSettingsBeforeSave();
				so = SharedObject(result);
				so.setProperty(SETTINGS_DATA_NAME, settings);
				so.flush();
				
				//log.info("Saved Serrinfo: "+ ObjectUtil.toString(so.data));
			}
			else {
				log.error("Could not save data. " + ObjectUtil.toString(result));
				return false;
			}
			
			return true;
		}
		
		/**
		 * Save all projects and documents locally and remotely.
		 * 
		 * NOT FINISHED
		 * */
		public function save(locations:String = null, options:Object = null):void {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var local:Boolean = getIsLocalLocation(locations);
			var remote:Boolean = getIsRemoteLocation(locations);
			var localResult:Boolean;
			
			if (local) {
				local = saveProject(selectedProject, DocumentData.LOCAL_LOCATION);
			}
			
			if (remote) {
				if (remote && selectedProject is ISavable) {
					saveProjectInProgress = true
					ISavable(selectedProject).save(DocumentData.REMOTE_LOCATION, options);
					
					if (selectedProject is Project) {
						Project(selectedProject).addEventListener(SaveResultsEvent.SAVE_RESULTS, projectSaveResults, false, 0, true);
					}
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
		 * Save data
		 * */
		public function saveDataLocally():Boolean {
			var result:Object = SharedObjectUtils.getSharedObject(SAVED_DATA_NAME);
			var so:SharedObject;
			
			if (result is SharedObject) {
				updateSavedDataBeforeSave();
				so = SharedObject(result);
				so.setProperty(SAVED_DATA_NAME, savedData);
				
				try {
					so.flush();
				}
				catch (error:Error) {
					log.error(error.message);
					return false;
				}
				
			}
			else {
				log.error("Could not save data. " + ObjectUtil.toString(result));
				return false;
			}
			
			return true;
		}

		
		/**
		 * Project saved handler
		 * */
		public function projectSaveResults(event:IServiceEvent):void {
			var project:IProject = IProject(Event(event).currentTarget);
			saveProjectInProgress = false;
			
			if (project is EventDispatcher) {
				EventDispatcher(project).removeEventListener(SaveResultsEvent.SAVE_RESULTS, projectSaveResults);
			}
			
			if (event is SaveResultsEvent && SaveResultsEvent(event).successful) {
				setLastSaveDate();
			}
			
			dispatchProjectSavedEvent(IProject(Event(event).currentTarget));
		}
		
		/**
		 * Formatter for dates
		 * */
		public var dateFormatter:DateTimeFormatter = new DateTimeFormatter();
		
		/**
		 * Sets the last save date 
		 * */
		public function setLastSaveDate(date:Date = null):void {
			dateFormatter.dateStyle = DateTimeStyle.MEDIUM;
			if (!date) date = new Date();
			lastSaveDate = dateFormatter.format(date);
		}

		/**
		 * Save project
		 * */
		public function saveProject(project:IProject, locations:String = null):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			
			//if (isUserLoggedIn && isUserConnected) {
			
			saveProjectInProgress = false;
			project.save(locations);
			//}
			
			if (project is EventDispatcher) {
				EventDispatcher(project).addEventListener(SaveResultsEvent.SAVE_RESULTS, projectSaveResults, false, 0, true);
			}
			
			// TODO add support to save after response from server 
			// because ID's may have been added from new documents
			var locallySaved:Boolean = saveProjectLocally(project);
			//project.saveCompleteCallback = saveData;
			return true;
		}

		/**
		 * Save project locally
		 * */
		public function saveProjectLocally(project:IProject, saveProjectDocuments:Boolean = true):Boolean {
			var result:Object = SharedObjectUtils.getSharedObject(SAVED_DATA_NAME);
			var so:SharedObject;
			
			if (result is SharedObject) {
				// todo - implement saveProjectDocuments
				updateSaveDataForProject(project);
				
				so = SharedObject(result);
				so.setProperty(SAVED_DATA_NAME, savedData);
				so.flush();
				//log.info("Saved Data: " + ObjectUtil.toString(so.data));
			}
			else {
				log.error("Could not save data. " + ObjectUtil.toString(result));
				//return false;
			}
			
			return true;
		}

		/**
		 * Save document. Uses constants, DocumentData.LOCAL_LOCATION, DocumentData.REMOTE_LOCATION, etc
		 * Separate them by ",". 
		 * */
		public function saveDocument(iDocument:IDocument, locations:String = null, options:Object = null):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var saveLocally:Boolean = getIsLocalLocation(locations);
			var saveRemote:Boolean = getIsRemoteLocation(locations);
			var saveLocallySuccessful:Boolean;
			
			if (saveRemote && iDocument && iDocument is EventDispatcher) {
				EventDispatcher(iDocument).addEventListener(SaveResultsEvent.SAVE_RESULTS, documentSaveResultsHandler, false, 0, true);
			}
			
			saveLocallySuccessful = iDocument.save(locations, options);
			// TODO add support to save after response from server 
			// because ID's may have been added from new documents
			//saveData();
			//document.saveCompleteCallback = saveData;
			//saveDocumentLocally(document);
			return saveLocallySuccessful;
		}
		
		/**
		 * Returns true if location includes local shared object
		 * */
		public function getIsLocalLocation(value:String):Boolean {
			return value ? value.indexOf(DocumentData.LOCAL_LOCATION)!=-1 || value==DocumentData.ALL_LOCATIONS : false;
		}
		
		/**
		 * Returns true if location includes remote
		 * */
		public function getIsRemoteLocation(value:String):Boolean {
			return value ? value.indexOf(DocumentData.REMOTE_LOCATION)!=-1 || value==DocumentData.ALL_LOCATIONS : false;
		}
		
		/**
		 * Returns true if location includes file system
		 * */
		public function getIsFileLocation(value:String):Boolean {
			return value ? value.indexOf(DocumentData.FILE_LOCATION)!=-1 || value==DocumentData.ALL_LOCATIONS : false;
		}
		
		/**
		 * Returns true if location includes a database
		 * */
		public function getIsDataBaseLocation(value:String):Boolean {
			return value ? value.indexOf(DocumentData.FILE_LOCATION)!=-1 || value==DocumentData.ALL_LOCATIONS : false;
		}
		
		/**
		 * Returns true if location includes internal
		 * */
		public function getIsInternalLocation(value:String):Boolean {
			return value ? value.indexOf(DocumentData.INTERNAL_LOCATION)!=-1 || value==DocumentData.ALL_LOCATIONS : false;
		}
		
		/**
		 * Handles results from document save
		 * */
		protected function documentSaveResultsHandler(event:SaveResultsEvent):void {
			var document:IDocument = IDocument(event.currentTarget);
			
			if (document is Document) {
				Document(document).removeEventListener(SaveResultsEvent.SAVE_RESULTS, documentSaveResultsHandler);
			}
			
			setLastSaveDate();
			
			if (event.successful) {
				dispatchDocumentSaveCompleteEvent(document);
			}
			else {
				dispatchDocumentSaveFaultEvent(document);
			}
		}
		
		/**
		 * Save document
		 * */
		public function saveAllDocuments(saveLocations:String = ""):Boolean {
			var document:IDocument;
			var project:IProject;
			var length:int = documents.length;
			
			for (var i:int;i<length;i++) {
				document = documents[i];
				
				if (document.isChanged) {
					document.save(saveLocations);
					// TODO add support to save after response from server 
					// because ID's may have been added from new documents
					//saveData();
					//document.saveCompleteCallback = saveData;
					saveDocumentLocally(document);
				}
			}
			
			length = projects.length;
			for (i = 0;i<length;i++) {
				project = projects[i];
				
				if (project.isChanged) {
					project.save();
					// TODO add support to save after response from server 
					// because ID's may have been added from new documents
					//saveData();
					//document.saveCompleteCallback = saveData;
					saveProjectLocally(project);
				}
			}
			
			return true;
		}

		/**
		 * Save document as
		 * */
		public function saveDocumentAs(document:IDocument, extension:String = "html"):void {
			/*
			document.save();
			// TODO add support to save after response from server 
			// because ID's may have been added from new documents
			//saveData();
			//document.saveCompleteCallback = saveData;
			saveDocumentLocally(document);*/
			//return true;
		}

		/**
		 * Save file as
		 * */
		public function saveFileAs(data:Object, name:String = "", extension:String = "html"):FileReference {
			var fileName:String = name==null ? "" : name;
			fileName = fileName.indexOf(".")==-1 && extension ? fileName + "." + extension : fileName;
			
			// FOR SAVING A FILE (save as) WE MAY NOT NEED ALL THE LISTENERS WE ARE ADDING
			// add listeners
			var fileReference:FileReference = new FileReference();
			addFileListeners(fileReference);
			
			fileReference.save(data, fileName);
			
			return fileReference;
		}
		
		/**
		 * Adds file save as listeners
		 * */
		public function addFileListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.CANCEL, cancelFileSaveAsHandler, false, 0, true);
			dispatcher.addEventListener(Event.COMPLETE, completeFileSaveAsHandler, false, 0, true);
		}
		
		/**
		 * Removes file save as listeners
		 * */
		public function removeFileListeners(dispatcher:IEventDispatcher):void {
			dispatcher.removeEventListener(Event.CANCEL, cancelFileSaveAsHandler);
			dispatcher.removeEventListener(Event.COMPLETE, completeFileSaveAsHandler);
		}
		
		/**
		 * File save as complete
		 * */
		public function completeFileSaveAsHandler(event:Event):void {
			removeFileListeners(event.currentTarget as IEventDispatcher);
			
			dispatchDocumentSaveCompleteEvent(selectedDocument);
		}
		
		/**
		 * Cancel file save as
		 * */
		public function cancelFileSaveAsHandler(event:Event):void {
			removeFileListeners(event.currentTarget as IEventDispatcher);
			
			dispatchDocumentSaveAsCancelEvent(selectedDocument);
		}
		
		/**
		 * Get document locally
		 * */
		public function getDocumentLocally(iDocumentData:IDocumentData):IDocumentData {
			var result:Object = SharedObjectUtils.getSharedObject(SAVED_DATA_NAME);
			var so:SharedObject;
			
			if (result is SharedObject) {
				so = SharedObject(result);
				//var data:Object = savedData;
				var documentsArray:Array = so.data.savedData.documents;
				var length:int = documentsArray.length;
				var documentData:IDocumentData;
				var found:Boolean;
				var foundIndex:int = -1;
				
				for (var i:int;i<length;i++) {
					documentData = IDocumentData(documentsArray[i]);
					
					if (documentData.uid == iDocumentData.uid) {
						found = true;
						foundIndex = i;
						
						break;
					}
				}
				
				return documentData;
			}
			else {
				log.error("Could not get saved data. " + ObjectUtil.toString(result));
			}
			
			return null;
		}
		
		/**
		 * Save document locally
		 * */
		public function saveDocumentLocally(document:IDocumentData):Boolean {
			var result:Object = SharedObjectUtils.getSharedObject(SAVED_DATA_NAME);
			var so:SharedObject;
			
			if (result is SharedObject) {
				updateSaveDataForDocument(document);
				so = SharedObject(result);
				so.setProperty(SAVED_DATA_NAME, savedData);
				so.flush();
				//log.info("Saved Data: " + ObjectUtil.toString(so.data));
			}
			else {
				log.error("Could not save data. " + ObjectUtil.toString(result));
				//return false;
			}
			
			return true;
		}
		
		/**
		 * Get settings
		 * */
		public function getSettings():Boolean {
			
			return true;
		}
		
		/**
		 * Get the latest settings and copy them into the settings object
		 * */
		public function updateSettingsBeforeSave():Settings {
			// get selected document
			// get selected project
			// get open projects
			// get open documents
			// get all documents
			// get all projects
			// save workspace settings
			// save preferences settings
			
			settings.lastOpened 		= new Date().time;
			//settings.modified 		= new Date().time;
			
			settings.openDocuments 		= getOpenDocumentsSaveData(true);
			settings.openProjects 		= getOpenProjectsSaveData(true);

			settings.selectedProject 	= selectedProject ? selectedProject.toMetaData() : null;
			settings.selectedDocument 	= selectedDocument ? selectedDocument.toMetaData() : null;
			
			settings.saveCount++;
			
			return settings;
		}
		
		/**
		 * Get the latest project and document data.
		 * */
		public function updateSavedDataBeforeSave():SavedData {
			// get selected document
			// get selected project
			// get open projects
			// get open documents
			// get all documents
			// get all projects
			// save workspace settings
			// save preferences settings
			
			savedData.modified 		= new Date().time;
			//settings.modified 		= new Date().time;
			savedData.documents 	= getSaveDataForAllDocuments();
			savedData.projects 		= getSaveDataForAllProjects();
			savedData.saveCount++;
			//savedData.resources 	= getResources();
			
			return savedData;
		}
		
		/**
		 * Get projects 
		 * */
		public function getProjects(status:String = WPService.STATUS_ANY, locations:String = null, count:int = 100):void {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var loadLocally:Boolean = locations.indexOf(DocumentData.LOCAL_LOCATION)!=-1;
			var loadRemote:Boolean = locations.indexOf(DocumentData.REMOTE_LOCATION)!=-1;
			
			
			if (loadRemote) {
				// we need to create service
				if (getProjectsService==null) {
					var service:WPService = new WPService();
					service = new WPService();
					service.host = getWPURL();
					service.addEventListener(WPService.RESULT, getProjectsResultsHandler, false, 0, true);
					service.addEventListener(WPService.FAULT, getProjectsFaultHandler, false, 0, true);
					getProjectsService = service;
				}
				
				getProjectsInProgress = true;
				
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
			var loadLocally:Boolean = locations.indexOf(DocumentData.LOCAL_LOCATION)!=-1;
			var loadRemote:Boolean = locations.indexOf(DocumentData.REMOTE_LOCATION)!=-1;
			
			
			if (loadRemote) {
				// we need to create service
				if (getProjectsService==null) {
					var service:WPService = new WPService();
					service = new WPService();
					service.host = getWPURL();
					service.addEventListener(WPService.RESULT, getProjectsResultsHandler, false, 0, true);
					service.addEventListener(WPService.FAULT, getProjectsFaultHandler, false, 0, true);
					getProjectsService = service;
				}
				
				getProjectsInProgress = true;
				
				getProjectsService.getProjectsByUser(id, status, count);
				
			}
			
			if (loadLocally) {
				
			}
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
			
			loginService.host = getWPURL();
				
			loginInProgress = true;
			
			loginService.loginUser(username, password);
			
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
			
			logoutService.host = getWPURL();
			
			logoutInProgress = true;
			
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
			
			registerService.host = getWPURL();
			
			registerInProgress = true;
			
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
			
			registerService.host = getWPURL();
			
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
			
			registerService.host = getWPURL();
			
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
			
			lostPasswordService.host = getWPURL();
				
			lostPasswordInProgress = true;
			
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
			
			changePasswordService.host = getWPURL();
				
			changePasswordInProgress = true;
			
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
			
			getAttachmentsService.host = getWPURL();
			
			if (id!=0) {
				getAttachmentsService.id = String(id);
			}
			
			getAttachmentsInProgress = true;
			
			
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
			
			uploadAttachmentService.host = getWPURL();
		
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
				Radiate.log.warn("No data or file is available for upload. Please select the file to upload.");
			}
			
		}
		
		/**
		 * Get projects
		 * */
		public function getLoggedInStatus():void {
			// get selected document
			var service:WPService;
			
			// we need to create service
			if (getProjectsService==null) {
				service = new WPService();
				service.host = getWPURL();
				service.addEventListener(WPService.RESULT, getLoggedInStatusResult, false, 0, true);
				service.addEventListener(WPService.FAULT, getLoggedInStatusFault, false, 0, true);
				getLoggedInStatusService = service;
			}
			
			getLoggedInStatusInProgress = true;
			
			getLoggedInStatusService.getLoggedInUser();
		}
		
		/**
		 * Handles result to check if user is logged in 
		 * */
		protected function getLoggedInStatusResult(event:WPServiceEvent):void {
			isUserConnected = true;
			var data:Object = event.data;

			updateUserInfo(data);
			
			getLoggedInStatusInProgress = false;
			
			dispatchLoginStatusEvent(isUserLoggedIn, data);
		}
		
		/**
		 * Updates the user information from data object from the server
		 * */
		public function updateUserInfo(data:Object):void {
			
			if (data && data is Object) {
				isUserLoggedIn = data.loggedIn;
				userAvatar = data.avatar;
				userDisplayName = data.displayName ? data.displayName : "guest";
				userID = data.id;
				userEmail = data.contact;
				user = data;
				
				if ("blogs" in user) {
					//userSites = user.blogs;
					userSites = [];
					for each (var blog:Object in user.blogs) {
						userSites.push(blog);
					}
					
					if (userSites.length>0) {
						userSitePath = userSites[0].path;
						WP_USER_PATH = userSitePath;
						WP_USER_PATH = WP_USER_PATH.replace(WP_PATH, "");
					}
					else {
						userSitePath = "";
						WP_USER_PATH = "";
					}
				}
			}
		}
		
		/**
		 * Handles fault when checking if user is logged in
		 * */
		protected function getLoggedInStatusFault(event:WPServiceEvent):void {
			var data:Object = event.data;
			isUserConnected = false;
			//isUserLoggedIn = false;
			
			getLoggedInStatusInProgress = false;
			
			dispatchLoginStatusEvent(isUserLoggedIn, data);
		}
		
		/**
		 * Results from call to get projects
		 * */
		public function getProjectsResultsHandler(event:IServiceEvent):void {
			
			//Radiate.log.info("Retrieved list of projects");
			
			var data:Object = event.data;
			
			getProjectsInProgress = false;
			
			dispatchGetProjectsListResultsEvent(data);
		}
		
		/**
		 * Open list of projects. Need to eventually convert from wordpress post data object to type classes.
		 * See getAttachmentsResultsHandler() 
		 * */
		public function openProjectsFromData(projectsData:Array):void {
			var length:int;
			var post:Object;
			var project:IProject
			var xml:XML;
			var isValid:Boolean;
			var firstProject:IProject;
			var potentialProjects:Array;
			
			length = projectsData.count;
			
			for (var i:int;i<length;i++) {
				post = potentialProjects.posts[i];
				isValid = XMLUtils.isValidXML(post.content);
				
				if (isValid) {
					xml = new XML(post.content);
					project = createProjectFromXML(xml);
					addProject(project);
					potentialProjects.push(project);
				}
				else {
					log.info("Could not import project:" + post.title);
				}
			}
			
			
			//potentialProjects = addSavedProjects(data.projects);
			
			if (potentialProjects.length>0) {
				openProject(potentialProjects[0]);
				setProject(potentialProjects[0]);
			}
		}
		
		/**
		 * Result from save fault
		 * */
		public function getProjectsFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			Radiate.log.info("Could not get list of projects");
			
			getProjectsInProgress = false;
			
			dispatchGetProjectsListResultsEvent(data);
		}
		
		/**
		 * Result get attachments
		 * */
		public function getAttachmentsResultsHandler(event:IServiceEvent):void {
			Radiate.log.info("Retrieved list of attachments");
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
			
			attachments = potentialAttachments;
			
			dispatchAttachmentsResultsEvent(true, attachments);
		}
		
		/**
		 * Result from attachments fault
		 * */
		public function getAttachmentsFaultHandler(event:IServiceEvent):void {
			
			Radiate.log.info("Could not get list of attachments");
			
			getAttachmentsInProgress = false;
			
			//dispatchEvent(saveResultsEvent);
			dispatchAttachmentsResultsEvent(false, []);
		}
		
		/**
		 * Result upload attachment
		 * */
		public function uploadAttachmentResultsHandler(event:IServiceEvent):void {
			//Radiate.log.info("Upload attachment");
			var data:Object = event.data;
			var potentialAttachments:Array = [];
			var successful:Boolean = data && data.status && data.status=="ok" ? true : false;
			var length:int;
			var object:Object;
			var attachment:AttachmentData;
			var asset:AttachmentData;
			var remoteAttachments:Array = data && data.post && data.post.attachments ? data.post.attachments : []; 
			var containsName:Boolean;
			var assetsLength:int;
			
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
					assetsLength = assets.length;
					j = 0;
					
					for (var j:int;j<assetsLength;j++) {
						asset = assets.getItemAt(j) as AttachmentData;
						containsName = asset ? asset.name.indexOf(attachment.name)==0 : false;
						
						// this is not very robust but since uploading only supports one at a time 
						// it should be fine. when supporting multiple uploading, keep
						// track of items being uploaded
						if (containsName && asset.id==null) {
							asset.unmarshall(attachment);
							
							var documentLength:int = documents.length;
							k = 0;
							
							for (var k:int;k<documentLength;k++) {
								var iDocument:IDocument = documents[k] as IDocument;
								
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
			
			dispatchUploadAttachmentResultsEvent(successful, potentialAttachments, data.post);
		}
		
		/**
		 * Replaces occurances where the bitmapData in Image and BitmapImage to URL on the server
		 * */
		public function replaceBitmapData(component:ComponentDescription, imageData:ImageData):void {
			var instance:Object;
			
			if (imageData && component && component.instance) {
				instance = component.instance;
				
				if (instance is Image || instance is BitmapImage) {
					if (instance.source == imageData.bitmapData) {
						Radiate.setProperty(instance, "source", imageData.url);
					}
				}
			}
		}
		
		/**
		 * Result from upload attachment fault
		 * */
		public function uploadAttachmentFaultHandler(event:IServiceEvent):void {
			Radiate.log.info("Upload attachment fault");
			
			uploadAttachmentInProgress = false;
			
			//dispatchEvent(saveResultsEvent);
			dispatchUploadAttachmentResultsEvent(false, [], event.data);
		}
		
		/**
		 * Login results handler
		 * */
		public function loginResultsHandler(event:IServiceEvent):void {
			//Radiate.log.info("Login results");
			var data:Object = event.data;
			var loggedIn:Boolean;
			
			if (data && data is Object) {
				
				loggedIn = data.loggedIn==true;
				
				updateUserInfo(data);
			}
			
			loginInProgress = false;
			
			
			dispatchLoginResultsEvent(loggedIn, data);
		}
		
		/**
		 * Result from login fault
		 * */
		public function loginFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.log.info("Could not connect to the server to login. ");
			
			loginInProgress = false;
			
			dispatchLoginResultsEvent(false, data);
		}
		
		/**
		 * Logout results handler
		 * */
		public function logoutResultsHandler(event:IServiceEvent):void {
			Radiate.log.info("Logout results");
			var data:Object = event.data;
			var loggedOut:Boolean;
			
			if (data && data is Object) {
				
				loggedOut = data.loggedIn==false;
				
				updateUserInfo(data);
			}
			
			logoutInProgress = false;
			
			
			dispatchLogoutResultsEvent(loggedOut, data);
		}
		
		/**
		 * Result from logout fault
		 * */
		public function logoutFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.log.info("Could not connect to the server to logout. ");
			
			logoutInProgress = false;
			
			dispatchLogoutResultsEvent(false, data);
		}
		
		/**
		 * Register results handler
		 * */
		public function registerResultsHandler(event:IServiceEvent):void {
			//Radiate.log.info("Register results");
			var data:Object = event.data;
			var successful:Boolean;
			
			if (data && data is Object && "created" in data) {
				
				successful = data.created;
				
			}
			
			registerInProgress = false;
			
			
			dispatchRegisterResultsEvent(successful, data);
		}
		
		/**
		 * Result from register fault
		 * */
		public function registerFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.log.info("Could not connect to the server to register. ");
			
			registerInProgress = false;
			
			dispatchRegisterResultsEvent(false, data);
		}
		
		/**
		 * Register results handler
		 * */
		public function changePasswordResultsHandler(event:IServiceEvent):void {
			//Radiate.log.info("Change password results");
			var data:Object = event.data;
			var successful:Boolean;
			
			if (data && data is Object && "created" in data) {
				
				successful = data.created;
				
			}
			
			changePasswordInProgress = false;
			
			
			dispatchChangePasswordResultsEvent(successful, data);
		}
		
		/**
		 * Result from change password fault
		 * */
		public function changePasswordFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.log.info("Could not connect to the server. " + event.faultEvent.toString());
			
			changePasswordInProgress = false;
			
			dispatchChangePasswordResultsEvent(false, data);
		}
		
		/**
		 * Lost password results handler
		 * */
		public function lostPasswordResultsHandler(event:IServiceEvent):void {
			//Radiate.log.info("Change password results");
			var data:Object = event.data;
			var successful:Boolean;
			
			if (data && data is Object && "created" in data) {
				successful = data.created;
			}
			
			lostPasswordInProgress = false;
			
			
			dispatchLostPasswordResultsEvent(successful, data);
		}
		
		/**
		 * Result from lost password fault
		 * */
		public function lostPasswordFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.log.info("Could not connect to the server. " + event.faultEvent.toString());
			
			lostPasswordInProgress = false;
			
			dispatchLostPasswordResultsEvent(false, data);
		}
		
		/**
		 * Delete project results handler
		 * */
		public function deleteProjectResultsHandler(event:IServiceEvent):void {
			//Radiate.log.info("Delete project results");
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
			
			dispatchProjectDeletedEvent(successful, data);
		}
		
		/**
		 * Result from delete project fault
		 * */
		public function deleteProjectFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.log.info("Could not connect to the server to delete the project. ");
			
			deleteProjectInProgress = false;
			
			dispatchProjectDeletedEvent(false, data);
		}
		
		/**
		 * Delete document results handler
		 * */
		public function deleteDocumentResultsHandler(event:IServiceEvent):void {
			//..Radiate.log.info("Delete document results");
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
			
			dispatchDocumentDeletedEvent(successful, data);
		}
		
		/**
		 * Result from delete project fault
		 * */
		public function deleteDocumentFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.log.info("Could not connect to the server to delete the document. ");
			
			deleteDocumentInProgress = false;
			
			dispatchDocumentDeletedEvent(false, data);
		}

		
		/**
		 * Check if the project has changed and mark changed if it is. 
		 * */
		public function checkIfProjectHasChanged(iProject:IProject):Boolean {
			
			var isChanged:Boolean = iProject.checkProjectHasChanged();
			
			return isChanged;
		}
		
		/**
		 * Updates the saved data with the changes from the document passed in
		 * */
		public function updateSaveDataForDocument(iDocumentData:IDocumentData, metaData:Boolean = false):SavedData {
			var documentsArray:Array = savedData.documents;
			var length:int = documentsArray.length;
			var documentMetaData:IDocumentMetaData;
			var found:Boolean;
			var foundIndex:int = -1;
			
			for (var i:int;i<length;i++) {
				documentMetaData = IDocumentMetaData(documentsArray[i]);
				//Radiate.log.info("Exporting document " + iDocument.name);
				
				if (documentMetaData.uid == iDocumentData.uid) {
					found = true;
					foundIndex = i;
				}
			}
			
			if (found) {
				
				if (metaData) {
					documentsArray[foundIndex] = iDocumentData.toMetaData();
				}
				else {
					documentsArray[foundIndex] = iDocumentData.marshall();
				}
			}
			else {
				if (metaData) {
					documentsArray.push(iDocumentData.toMetaData());
				}
				else {
					documentsArray.push(iDocumentData.marshall());
				}
			}
			
			
			return savedData;
		}
		
		/**
		 * Updates the saved data with the changes from the project passed in
		 * */
		public function updateSaveDataForProject(iProject:IProject, metaData:Boolean = false):SavedData {
			var projectsArray:Array = savedData.projects;
			var length:int = projectsArray.length;
			var documentMetaData:IDocumentMetaData;
			var found:Boolean;
			var foundIndex:int = -1;
			
			for (var i:int;i<length;i++) {
				documentMetaData = IDocumentData(projectsArray[i]);
				//Radiate.log.info("Exporting document " + iDocument.name);
				
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
		 * Get a list of documents. If open is set to true then gets only open documents.
		 * */
		public function getOpenDocumentsSaveData(metaData:Boolean = false):Array {
			var documentsArray:Array = getSaveDataForAllDocuments(true, metaData);
			return documentsArray;
		}
		
		/**
		 * Get a list of documents data for storage by project. If open is set to true then only returns open documents.
		 * */
		public function getDocumentsSaveDataByProject(project:IProject, open:Boolean = false):Array {
			var documentsArray:Array = project.getSavableDocumentsData(open);
			
			return documentsArray;
		}
		
		/**
		 * Get a list of all documents data for storage. If open is set to 
		 * true then only returns open documents.
		 * */
		public function getSaveDataForAllDocuments(open:Boolean = false, metaData:Boolean = false):Array {
			var length:int = projects.length;
			var documentsArray:Array = [];
			var iProject:IProject;
			
			for (var i:int;i<length;i++) {
				iProject = projects[i];
				documentsArray = documentsArray.concat(iProject.getSavableDocumentsData(open, metaData));
			}
			
			return documentsArray;
		}
		
		
		/**
		 * Get a list of projects that are open. 
		 * If meta data is true only returns meta data. 
		 * */
		public function getOpenProjectsSaveData(metaData:Boolean = false):Array {
			var projectsArray:Array = getSaveDataForAllProjects(true, metaData);
			
			return projectsArray;
		}
		
		/**
		 * Get an array of projects serialized for storage. 
		 * If open is set to true then only returns open projects.
		 * If meta data is true then only returns meta data. 
		 * */
		public function getSaveDataForAllProjects(open:Boolean = false, metaData:Boolean = false):Array {
			var projectsArray:Array = [];
			var length:int = projects.length;
			var iProject:IProject;
			
			for (var i:int; i < length; i++) {
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
		 * Get an array of projects serialized for storage. 
		 * If open is set to true then only returns open projects.
		 * If meta data is true then only returns meta data. 
		 * */
		public function saveProjectsRemotely(open:Boolean = false):Array {
			var projectsArray:Array = [];
			var length:int = projects.length;
			var iProject:IProject;
			
			for (var i:int; i < length; i++) {
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
		
		//----------------------------------
		//
		//  History Management
		// 
		//----------------------------------
		
		// NOTE: THIS IS WRITTEN THIS WAY TO WORK WITH FLEX STATES AND TRANSITIONS
		// there is probably a better way but I am attempting to use the flex sdk's
		// own code to apply changes. we could extract that code, create commands, 
		// etc but it seemed less work and less room for error 
		
		// update oct 27: this could probably be moved to the document's own class
		// and another way to do history management is create a sequence and 
		// add actions to it (SetAction, AddItem, RemoveItem, etc)
		// that would probably enable easy to use automation and playback 
		
		public static var REMOVE_ITEM_DESCRIPTION:String = "Remove";
		public static var ADD_ITEM_DESCRIPTION:String = "Add";
		private static var BEGINNING_OF_HISTORY:String;
		
		/**
		 * Collection of items in the property change history
		 * */
		[Bindable]
		public static var history:ArrayCollection = new ArrayCollection();
		
		/**
		 * Dictionary of property change objects
		 * */
		public static var historyEventsDictionary:Dictionary = new Dictionary(true);
		
		
		/**
		 * Travel to the specified history index.
		 * Going to fast may cause some issues. Need to test thoroughly 
		 * We may need to call validateNow somewhere and set usePhasedInstantiation?
		 * */
		public static function goToHistoryIndex(index:int, dispatchEvents:Boolean = false):int {
			var document:IDocument = instance.selectedDocument;
			var newIndex:int = index;
			var oldIndex:int = historyIndex;
			var time:int = getTimer();
			var currentIndex:int;
			var difference:int;
			var layoutManager:ILayoutManager = LayoutManager.getInstance();
			var phasedInstantiation:Boolean = layoutManager.usePhasedInstantiation;
			
			layoutManager.usePhasedInstantiation = false;
			
			if (newIndex<oldIndex) {
				difference = oldIndex - newIndex;
				for (var i:int;i<difference;i++) {
					currentIndex = undo(dispatchEvents, dispatchEvents);
				}
			}
			else if (newIndex>oldIndex) {
				difference = oldIndex<0 ? newIndex+1 : newIndex - oldIndex;
				for (var j:int;j<difference;j++) {
					currentIndex = redo(dispatchEvents, dispatchEvents);
				}
			}
			
			layoutManager.usePhasedInstantiation = phasedInstantiation;
			
			history.refresh();
			historyIndex = getHistoryIndex();
			
			instance.dispatchHistoryChangeEvent(historyIndex, oldIndex);
			
			
			return currentIndex;
		}
		
		/**
		 * Undo last change. Returns the current index in the changes array. 
		 * The property change object sets the property "reversed" to 
		 * true.
		 * Going too fast causes some issues (call validateNow somewhere)?
		 * I think the issue with RangeError: Index 2 is out of range.
		 * is that the History List does not always do the first item in the 
		 * List. So we need to add a first item that does nothing, like a
		 * open history event. 
		 * */
		public static function undo(dispatchEvents:Boolean = false, dispatchForApplication:Boolean = true):int {
			var changeIndex:int = getPreviousHistoryIndex(); // index of next change to undo 
			var currentIndex:int = getHistoryIndex();
			var historyLength:int = history.length;
			var historyEvent:HistoryEventItem;
			var currentDocument:IDocument = instance.selectedDocument;
			var currentTargetDocument:Application = currentDocument.instance as Application;
			var setStartValues:Boolean = true;
			var historyItem:HistoryEvent;
			var affectsDocument:Boolean;
			var historyEvents:Array;
			var dictionary:Dictionary;
			var reverseItems:AddItems;
			var eventTargets:Array;
			var eventsLength:int;
			var targetsLength:int;
			var addItems:AddItems;
			var added:Boolean;
			var removed:Boolean;
			var action:String;
			var isInvalid:Boolean;
			
			// no changes
			if (!historyLength) {
				return -1;
			}
			
			// all changes have already been undone
			if (changeIndex<0) {
				if (dispatchEvents && instance.hasEventListener(RadiateEvent.BEGINNING_OF_UNDO_HISTORY)) {
					instance.dispatchEvent(new RadiateEvent(RadiateEvent.BEGINNING_OF_UNDO_HISTORY));
				}
				
				return -1;
			}
			
			// get current change to be redone
			historyItem = history.length ? history.getItemAt(changeIndex) as HistoryEvent : null;
			historyEvents = historyItem.historyEventItems;
			eventsLength = historyEvents.length;
			
			
			// loop through changes
			for (var i:int=eventsLength;i--;) {
				//changesLength = changes ? changes.length: 0;
				
				historyEvent = historyEvents[i];
				addItems = historyEvent.addItemsInstance;
				action = historyEvent.action;//==RadiateEvent.MOVE_ITEM && addItems ? RadiateEvent.MOVE_ITEM : RadiateEvent.PROPERTY_CHANGE;
				affectsDocument = dispatchForApplication && historyEvent.targets.indexOf(currentTargetDocument)!=-1;
				
				// undo the add
				if (action==RadiateEvent.ADD_ITEM) {
					eventTargets = historyEvent.targets;
					targetsLength = eventTargets.length;
					dictionary = historyEvent.reverseAddItemsDictionary;
					
					for (var j:int=0;j<targetsLength;j++) {
						reverseItems = dictionary[eventTargets[j]];
						addItems.remove(null);
						
						// check if it's reverse or property changes
						if (reverseItems) {
							reverseItems.apply(reverseItems.destination as UIComponent);
							
							// was it added - can be refactored
							if (reverseItems.destination==null) {
								added = true;
							}
						}
					}
					
					historyEvent.reversed = true;
					
					if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
						instance.dispatchRemoveItemsEvent(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties);
					}
				}
				
				// undo the move - (most likely an add action with x and y changes)
				if (action==RadiateEvent.MOVE_ITEM) {
					eventTargets = historyEvent.targets;
					targetsLength = eventTargets.length;
					dictionary = historyEvent.reverseAddItemsDictionary;
					
					for (j=0;j<targetsLength;j++) {
						reverseItems = dictionary[eventTargets[j]];
						
						// check if it's remove items or property changes
						if (reverseItems) {
							isInvalid = LayoutManager.getInstance().isInvalid();
							if (isInvalid) {
								LayoutManager.getInstance().validateNow();
								LayoutManager.getInstance().isInvalid() ? Radiate.log.debug("Layout Manager is still invalid at note 1.") : 0;
							}
							
							addItems.remove(null);
							isInvalid = LayoutManager.getInstance().isInvalid();
							if (isInvalid) {
								LayoutManager.getInstance().validateNow();
								LayoutManager.getInstance().isInvalid() ? Radiate.log.debug("Layout Manager is still invalid at note 2.") : 0;
							}
							reverseItems.apply(reverseItems.destination as UIComponent);
							
							if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
								instance.dispatchRemoveItemsEvent(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties);
							}
							
							// was it added - note: can be refactored
							if (reverseItems.destination==null) {
								added = true;
							}
						}
						else { // property change
							applyChanges(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties, historyEvent.styles,
								setStartValues);
							historyEvent.reversed = true;
							
							if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
								instance.dispatchPropertyChangeEvent(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties);
							}
						}
					}
					
					historyEvent.reversed = true;
				}
				// undo the remove
				else if (action==RadiateEvent.REMOVE_ITEM) {
					isInvalid = LayoutManager.getInstance().isInvalid();
					if (isInvalid) {
						LayoutManager.getInstance().validateNow();
						LayoutManager.getInstance().isInvalid() ? Radiate.log.debug("Layout Manager is still invalid at note 3") : 0;
					}
					addItems.apply(addItems.destination as UIComponent);
					historyEvent.reversed = true;
					removed = true;
					
					if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
						instance.dispatchAddEvent(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties);
					}
				}
				// undo the property changes
				else if (action==RadiateEvent.PROPERTY_CHANGED) {
				
					applyChanges(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties, historyEvent.styles,
						setStartValues);
					historyEvent.reversed = true;
					
					if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
						instance.dispatchPropertyChangeEvent(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties);
					}
				}
			}
			
			historyItem.reversed = true;
			
			// select the target
			if (selectTargetOnHistoryChange) {
				if (added) { // item was added and now unadded - select previous
					if (currentIndex>0) {
						instance.setTarget(HistoryEvent(history.getItemAt(currentIndex-1)).targets, true);
					}
					else {
						instance.setTarget(currentTargetDocument, true);
					}
				}
				else if (removed) {
					instance.setTargets(historyEvent.targets, true);
				}
				else {
					instance.setTargets(historyEvent.targets, true);
				}
			}
			
			if (eventsLength) {
				historyIndex = getHistoryIndex();
				
				if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
					instance.dispatchHistoryChangeEvent(historyIndex, currentIndex);
				}
				return changeIndex-1;
			}
			
			return historyLength;
		}
		
		/**
		 * Redo last change
		 * */
		public static function redo(dispatchEvents:Boolean = false, dispatchForApplication:Boolean = true):int {
			var currentDocument:IDocument = instance.selectedDocument;
			var historyCollection:ArrayCollection = currentDocument.history;
			var currentTargetDocument:Application = currentDocument.instance as Application; // should be typed
			var historyLength:int = historyCollection.length;
			var changeIndex:int = getNextHistoryIndex();
			var currentIndex:int = getHistoryIndex();
			var historyEvent:HistoryEventItem;
			var historyItem:HistoryEvent;
			var affectsDocument:Boolean;
			var setStartValues:Boolean;
			var historyEvents:Array;
			var addItems:AddItems;
			var isInvalid:Boolean;
			var eventsLength:int;
			var remove:Boolean;
			var action:String;
			
			
			// need to make sure everything is validated first
			// think about doing the following:
			// LayoutManager.getInstance().usePhasedInstantiation = false;
			// LayoutManager.getInstance().isInvalid() ? Radiate.log.debug("Layout Manager is still invalid. Needs a fix.") : 0;
			// also use in undo()
			
			// no changes made
			if (!historyLength) {
				return -1;
			}
			
			// cannot redo any more changes
			if (changeIndex==-1 || changeIndex>=historyLength) {
				if (instance.hasEventListener(RadiateEvent.END_OF_UNDO_HISTORY)) {
					instance.dispatchEvent(new RadiateEvent(RadiateEvent.END_OF_UNDO_HISTORY));
				}
				return historyLength-1;
			}
			
			// get current change to be redone
			historyItem = historyCollection.length ? historyCollection.getItemAt(changeIndex) as HistoryEvent : null;
			
			historyEvents = historyItem.historyEventItems;
			eventsLength = historyEvents.length;
			//changes = historyEvents;
			
			for (var j:int;j<eventsLength;j++) {
				historyEvent = HistoryEventItem(historyEvents[j]);
				//changesLength = changes ? changes.length: 0;
				
				addItems = historyEvent.addItemsInstance;
				action = historyEvent.action;
				affectsDocument = dispatchForApplication && historyEvent.targets.indexOf(currentTargetDocument)!=-1;

				
				if (action==RadiateEvent.ADD_ITEM) {
					isInvalid = LayoutManager.getInstance().isInvalid();
					if (isInvalid) {
						LayoutManager.getInstance().validateNow();
						LayoutManager.getInstance().isInvalid() ? Radiate.log.debug("Layout Manager is still invalid at note 4.") : 0;
					}
					// redo the add
					addItems.apply(addItems.destination as UIComponent);
					historyEvent.reversed = false;
					
					if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
						instance.dispatchAddEvent(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties);
					}
					
				}
				else if (action==RadiateEvent.MOVE_ITEM) {
					// redo the move
					if (addItems) {
						
						// RangeError: Index 2 is out of range. 
						// we must validate
						isInvalid = LayoutManager.getInstance().isInvalid();
						if (isInvalid) {
							LayoutManager.getInstance().validateNow();
							LayoutManager.getInstance().isInvalid() ? Radiate.log.debug("Layout Manager is still invalid at note 5") : 0;
						}
						
						addItems.apply(addItems.destination as UIComponent);
						historyEvent.reversed = false;
						
						if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
							instance.dispatchMoveEvent(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties);
						}
					}
					else {
						
						applyChanges(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties, historyEvent.styles,
							setStartValues);
						historyEvent.reversed = false;
						
						if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
							instance.dispatchPropertyChangeEvent(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties);
						}
					}
					
				}
				else if (action==RadiateEvent.REMOVE_ITEM) {
					
					isInvalid = LayoutManager.getInstance().isInvalid();
					if (isInvalid) {
						LayoutManager.getInstance().validateNow();
						LayoutManager.getInstance().isInvalid() ? Radiate.log.debug("Layout Manager is still invalid at note 6") : 0;
					}
					
					// redo the remove
					addItems.remove(addItems.destination as UIComponent);
					historyEvent.reversed = false;
					remove = true;
					if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
						instance.dispatchRemoveItemsEvent(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties);
					}
				}
				else if (action==RadiateEvent.PROPERTY_CHANGED) {
					applyChanges(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties, historyEvent.styles,
						setStartValues);
					historyEvent.reversed = false;
					
					if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
						instance.dispatchPropertyChangeEvent(historyEvent.targets, [historyEvent.propertyChanges], historyEvent.properties);
					}
				}
			}
			
			
			historyItem.reversed = false;
			
			// select target
			if (selectTargetOnHistoryChange) {
				if (remove) {
					instance.setTargets(currentTargetDocument, true);
				}
				else {
					instance.setTargets(historyEvent.targets, true);
				}
			}
			
			if (eventsLength) {
				historyIndex = getHistoryIndex();
				
				if (dispatchEvents || (dispatchForApplication && affectsDocument)) {
					instance.dispatchHistoryChangeEvent(historyIndex, currentIndex);
				}
				
				return changeIndex;
			}
			
			return historyLength;
		}
		
		/**
		 * Apply changes to targets. You do not call this. Set properties through setProperties method. 
		 * 
		 * @param setStartValues applies the start values rather 
		 * than applying the end values
		 * 
		 * @param property string or array of strings containing the 
		 * names of the properties to set or null if setting styles
		 * 
		 * @param style string or araray of strings containing the 
		 * names of the styles to set or null if setting properties
		 * */
		public static function applyChanges(targets:Array, changes:Array, property:*, style:*, setStartValues:Boolean=false):Boolean {
			var length:int = changes ? changes.length : 0;
			var effect:SetAction = new SetAction();
			var onlyPropertyChanges:Array = [];
			var directApply:Boolean = true;
			var isStyle:Boolean = style && style.length>0;
			
			for (var i:int;i<length;i++) {
				if (changes[i] is PropertyChanges) { 
					onlyPropertyChanges.push(changes[i]);
				}
			}
			
			effect.targets = targets;
			effect.propertyChangesArray = onlyPropertyChanges;
			
			if (isStyle) {
				effect.property = style;
			}
			
			effect.relevantProperties = ArrayUtil.toArray(property);
			effect.relevantStyles = ArrayUtil.toArray(style);
			
			// this works for styles and properties
			// note: the property applyActualDimensions is used to enable width and height values to stick
			if (directApply) {
				effect.applyEndValuesWhenDone = false;
				effect.applyActualDimensions = false;
				
				if (setStartValues) {
					effect.applyStartValues(onlyPropertyChanges, targets);
				}
				else {
					effect.applyEndValues(onlyPropertyChanges, targets);
				}
				
				// Revalidate after applying
				LayoutManager.getInstance().validateNow();
			}
				
				// this works for properties but not styles
				// the style value is restored at the end
			else {
				
				effect.applyEndValuesWhenDone = false;
				effect.play(targets, setStartValues);
				effect.playReversed = false;
				effect.end();
				LayoutManager.getInstance().validateNow();
			}
			
			return true;
		}
		
		/**
		 * Removes properties changes for null or same value targets
		 * @private
		 */
		public static function stripUnchangedValues(propChanges:Array):Array {
			
			// Go through and remove any before/after values that are the same.
			for (var i:int = 0; i < propChanges.length; i++) {
				if (propChanges[i].stripUnchangedValues == false)
					continue;
				
				for (var prop:Object in propChanges[i].start) {
					if ((propChanges[i].start[prop] ==
						propChanges[i].end[prop]) ||
						(typeof(propChanges[i].start[prop]) == "number" &&
							typeof(propChanges[i].end[prop])== "number" &&
							isNaN(propChanges[i].start[prop]) &&
							isNaN(propChanges[i].end[prop])))
					{
						delete propChanges[i].start[prop];
						delete propChanges[i].end[prop];
					}
				}
			}
			
			return propChanges;
		}
		
		
		
		/**
		 * Checks if changes are available. 
		 * */
		public static function changesAvailable(changes:Array):Boolean {
			var length:int = changes.length;
			var changesAvailable:Boolean;
			var item:PropertyChanges;
			var name:String;
			
			for (var i:int;i<length;i++) {
				if (!(changes[i] is PropertyChanges)) continue;
				
				item = changes[i];
				
				for (name in item.start) {
					changesAvailable = true;
					return true;
				}
				
				for (name in item.end) {
					changesAvailable = true;
					return true;
				}
			}
			
			return changesAvailable;
		}
		
		//private static var _historyIndex:int = -1;
		
		/**
		 * Selects the target on undo and redo
		 * */
		public static var selectTargetOnHistoryChange:Boolean = true;
		
		private static var _historyIndex:int = -1;

		/**
		 * Current history index. 
		 * The history index is the index of last applied change. Or
		 * to put it another way the index of the last reversed change minus 1. 
		 * If there are 10 total changes and one has been reversed then 
		 * we would be at the 9th change. The history index would 
		 * be 8 since 9-1 = 8 since the array is a zero based index. 
		 * 
		 * value -1 means no history
		 * value 0 means one item
		 * value 1 means two items
		 * value 2 means three items
		 * */
		[Bindable]
		public static function get historyIndex():int {
			
			return _historyIndex;
			//var document:IDocument = instance.selectedDocument;
			//return document ? document.historyIndex : -1;
		}

		/**
		 * @private
		 */
		public static function set historyIndex(value:int):void {
			var document:IDocument = instance.selectedDocument;
			if (document.historyIndex==value) {
				//
			}
			else {
				document.historyIndex = value;
			}
			
			_historyIndex = value;
			
			var totalItems:int = history ? 
				history.length : 0;
			var hasItems:Boolean = totalItems>0;
			
			// has forward history
			if (hasItems && historyIndex+1<totalItems) {
				canRedo = true;
			}
			else {
				canRedo = false;
			}
			
			// has previous items
			if (hasItems && historyIndex>-1) {
				canUndo = true;
			}
			else {
				canUndo = false;
			}
		}
		
		/**
		 * Indicates if undo is available
		 * */
		[Bindable]
		public static var canUndo:Boolean;
		
		/**
		 * Indicates if redo is available
		 * */
		[Bindable]
		public static var canRedo:Boolean;
		
		/**
		 * Get the index of the next item that can be undone. 
		 * If there are 10 changes and one has been reversed the 
		 * history index would be 8 since 10-1=9-1=8 since the array is 
		 * a zero based index. 
		 * */
		public static function getPreviousHistoryIndex():int {
			var document:IDocument = instance.selectedDocument;
			var length:int = document.history.length;
			var historyItem:HistoryEvent;
			var index:int;
			
			for (var i:int;i<length;i++) {
				historyItem = document.history.getItemAt(i) as HistoryEvent;
				
				if (historyItem.reversed) {
					return i-1;
				}
			}
			
			return length-1;
		}
		
		/**
		 * Get the index of the next item that can be redone in the history array. 
		 * If there are 10 changes and one has been reversed the 
		 * next history index would be 9 since 10-1=9-1=8+1=9 since the array is 
		 * a zero based index. 
		 * */
		public static function getNextHistoryIndex():int {
			var document:IDocument = instance.selectedDocument;
			var length:int = document.history.length;
			var historyItem:HistoryEvent;
			var index:int;
			
			// start at the beginning and find the next item to redo
			for (var i:int;i<length;i++) {
				historyItem = document.history.getItemAt(i) as HistoryEvent;
				
				if (historyItem.reversed) {
					return i;
				}
			}
			
			return length;
		}
		
		/**
		 * Get history index
		 * */
		public static function getHistoryIndex():int {
			var document:IDocument = instance.selectedDocument;
			var length:int = document ? document.history.length : 0;
			var historyItem:HistoryEvent;
			var index:int;
			
			// go through and find last item that is reversed
			for (var i:int;i<length;i++) {
				historyItem = document.history.getItemAt(i) as HistoryEvent;
				
				if (historyItem.reversed) {
					return i-1;
				}
			}
			
			return length-1;
		}
		
		/**
		 * Returns the history event by index
		 * */
		public function getHistoryItemAtIndex(index:int):HistoryEvent {
			var document:IDocument = instance.selectedDocument;
			var length:int = document ? document.history.length : 0;
			var historyItem:HistoryEvent;
			
			// no changes
			if (!length) {
				return null;
			}
			
			// all changes have already been undone
			if (index<0) {
				return null;
			}
			
			// get change 
			historyItem = document.history.length ? document.history.getItemAt(index) as HistoryEvent : null;
			
			return historyItem;
		}

		
		/**
		 * Given a target or targets, property name and value
		 * returns an array of PropertyChange objects.
		 * Points to createPropertyChanges()
		 * 
		 * @see createPropertyChanges()
		 * */
		public static function createPropertyChange(targets:Array, property:String, style:String, value:*, description:String = ""):Array {
			var values:Object = {};
			var changes:Array;
			
			if (property) {
				values[property] = value;
			}
			else if (style) {
				values[style] = value;
			}
			
			changes = createPropertyChanges(targets, ArrayUtil.toArray(property), ArrayUtil.toArray(style), values, description, false);
			
			return changes;
		}
		
		/**
		 * Given a target or targets, properties and value object (name value pair)
		 * returns an array of PropertyChange objects.
		 * Value must be an object containing the properties mentioned in the properties array
		 * */
		public static function createPropertyChanges(targets:Array, properties:Array, styles:Array, value:Object, description:String = "", storeInHistory:Boolean = true):Array {
			var tempEffect:SetAction = new SetAction();
			var propertyChanges:PropertyChanges;
			var changes:Array;
			var propertyOrStyle:String;
			var isStyle:Boolean = styles && styles.length>0;
			
			tempEffect.targets = targets;
			tempEffect.property = isStyle ? styles[0] : properties[0];
			tempEffect.relevantProperties = properties;
			tempEffect.relevantStyles = styles;
			
			// get start values for undo
			changes = tempEffect.captureValues(null, true);
			
			// This may be hanging on to bindable objects
			// set the values to be set to the property 
			// ..later - what??? give an example
			for each (propertyChanges in changes) {
				
				// for properties 
				for each (propertyOrStyle in properties) {
					
					// value may be an object with properties or a string
					// because we accept an object containing the values with 
					// the name of the properties or styles
					if (value && propertyOrStyle in value) {
						propertyChanges.end[propertyOrStyle] = value[propertyOrStyle];
					}
					else {
						propertyChanges.end[propertyOrStyle] = value;
					}
				}
				
				// for styles
				for each (propertyOrStyle in styles) {
					
					// value may be an object with properties or a string
					// because we accept an object containing the values with 
					// the name of the properties or styles
					if (value && propertyOrStyle in value) {
						propertyChanges.end[propertyOrStyle] = value[propertyOrStyle];
					}
					else {
						propertyChanges.end[propertyOrStyle] = value;
					}
				}
			}
			
			// we should move this out
			// add property changes array to the history dictionary
			if (storeInHistory) {
				return createHistoryEvents(targets, changes, properties, styles, value, description);
			}
			
			return [propertyChanges];
		}
		
		private static var _disableHistoryManagement:Boolean;

		/**
		 * Disables history management
		 * */
		public static function get disableHistoryManagement():Boolean {
			return _disableHistoryManagement;
		}

		/**
		 * @private
		 */
		[Bindable(event="disableHistoryManagement")]
		public static function set disableHistoryManagement(value:Boolean):void {
			if (_disableHistoryManagement == value) return;
			_disableHistoryManagement = value;
		}

		
		/**
		 * Creates a history event in the history 
		 * Changes can contain a property or style changes or add items 
		 * */
		public static function createHistoryEvents(targets:Array, changes:Array, properties:*, styles:*, value:*, description:String = null, action:String=RadiateEvent.PROPERTY_CHANGED, remove:Boolean = false):Array {
			var factory:ClassFactory = new ClassFactory(HistoryEventItem);
			var historyEvent:HistoryEventItem;
			var events:Array = [];
			var reverseAddItems:AddItems;
			var change:Object;
			var length:int;
			
			if (disableHistoryManagement) return [];
			
			// create property change objects for each
			for (var i:int;i<changes.length;i++) {
				change = changes[i];
				historyEvent 						= factory.newInstance();
				historyEvent.action 				= action;
				historyEvent.targets 				= targets;
				historyEvent.description 			= description;
				
				// check for property change or add display object
				if (change is PropertyChanges) {
					historyEvent.properties 		= ArrayUtil.toArray(properties);
					historyEvent.styles 			= ArrayUtil.toArray(styles);
					historyEvent.propertyChanges 	= PropertyChanges(change);
				}
				else if (change is AddItems && !remove) {
					historyEvent.addItemsInstance 	= AddItems(change);
					length = targets.length;
					
					// trying to add support for multiple targets - it's not all there yet
					// probably not the best place to get the previous values or is it???
					for (var j:int=0;j<length;j++) {
						historyEvent.reverseAddItemsDictionary[targets[j]] = createReverseAddItems(targets[j]);
					}
				}
				else if (change is AddItems && remove) {
					historyEvent.removeItemsInstance 	= AddItems(change);
					length = targets.length;
					
					// trying to add support for multiple targets - it's not all there yet
					// probably not the best place to get the previous values or is it???
					for (j=0;j<length;j++) {
						historyEvent.reverseRemoveItemsDictionary[targets[j]] = createReverseAddItems(targets[j]);
					}
				}
				events[i] = historyEvent;
			}
			
			return events;
			
		}
		
		/**
		 * Creates a remove item from an add item. 
		 * */
		public static function createReverseAddItems(target:Object):AddItems {
			var elementContainer:IVisualElementContainer;
			var position:String = AddItems.LAST;
			var visualElement:IVisualElement;
			var reverseAddItems:AddItems;
			var elementIndex:int = -1;
			var propertyName:String; 
			var destination:Object;
			var description:String;
			var relativeTo:Object; 
			var vectorClass:Class;
			var isStyle:Boolean; 
			var isArray:Boolean; 
			var index:int = -1; 
			
			if (!target) return null;
			
			// create add items with current values we can revert back to
			reverseAddItems = new AddItems();
			reverseAddItems.destination = target.parent;
			reverseAddItems.items = target;
			
			destination = reverseAddItems.destination;
			
			visualElement = target as IVisualElement;
			
			// set default
			if (!position) {
				position = AddItems.LAST;
			}
			
			// Check for non basic layout destination
			// if destination is not a basic layout
			// find the position and set the relative object 
			if (destination is IVisualElementContainer 
				&& destination.numElements>0) {
				elementContainer = destination as IVisualElementContainer;
				index = elementContainer.getElementIndex(visualElement);
				
				
				if (elementContainer is GroupBase 
					&& !(GroupBase(elementContainer).layout is BasicLayout)) {
					

					// add as first item
					if (index==0) {
						position = AddItems.FIRST;
					}
					
					// get relative to object
					else if (index<=elementContainer.numElements) {
						
						
						// if element is already child of container account for remove of element before add
						if (visualElement && visualElement.parent == destination) {
							elementIndex = destination.getElementIndex(visualElement);
							index = elementIndex < index ? index-1: index;
							
							if (index<=0) {
								position = AddItems.FIRST;
							}
							else {
								relativeTo = destination.getElementAt(index-1);
								position = AddItems.AFTER;
							}
						}
							// add as last item
						else if (index>=destination.numElements) {
							position = AddItems.LAST;
						}
							// add after first item
						else if (index>0) {
							relativeTo = destination.getElementAt(index-1);
							position = AddItems.AFTER;
						}
					}
				}
			}
			
			
			reverseAddItems.destination = destination;
			reverseAddItems.position = position;
			reverseAddItems.relativeTo = relativeTo;
			reverseAddItems.propertyName = propertyName;
			reverseAddItems.isArray = isArray;
			reverseAddItems.isStyle = isStyle;
			reverseAddItems.vectorClass = vectorClass;
			
			return reverseAddItems;
		}
		
		/**
		 * Stores a history event in the history events dictionary
		 * Changes can contain a property changes object or add items object
		 * */
		public static function removeHistoryEvent(changes:Array):void {
			var historyEvent:HistoryEventItem;
			var change:Object;
			
			// delete change objects
			for each (change in changes) {
				historyEventsDictionary[change] = null;
				delete historyEventsDictionary[change];
			}
			
		}
		
		/**
		 * Adds property change items to the history array
		 * */
		public static function addHistoryItem(historyEventItem:HistoryEventItem, description:String = null):void {
			addHistoryEvents(ArrayUtil.toArray(historyEventItem), description);
		}
		
		/**
		 * Adds property change items to the history array
		 * */
		public static function addHistoryEvents(historyEvents:Array, description:String = null):void {
			var document:IDocument = instance.selectedDocument;
			var historyEvent:HistoryEvent;
			var currentIndex:int = getHistoryIndex();
			var length:int = document ? document.history.length : 0;
			var historyTargets:Array;
			
			if (disableHistoryManagement) return;
			
			history.disableAutoUpdate();
			
			// trim history 
			if (currentIndex!=length-1) {
				for (var i:int = length-1;i>currentIndex;i--) {
					historyEvent = document.history.removeItemAt(i) as HistoryEvent;
					historyEvent.purge();
				}
			}
			
			historyEvent = new HistoryEvent();
			historyEvent.description = description ? HistoryEventItem(historyEvents[0]).description : description;
			historyEvent.historyEventItems = historyEvents;
			
			// we should remember to remove these references when truncating history
			for (i=0;i<historyEvents.length;i++) {
				historyTargets = HistoryEventItem(historyEvents[i]).targets;
				for (var j:int=0;j<historyTargets.length;j++) {
					if (historyEvent.targets.indexOf(historyTargets[j])==-1) {
						historyEvent.targets.push(historyTargets[j]);
					}
				}
			}
			
			document.history.addItem(historyEvent);
			document.historyIndex = getHistoryIndex();
			document.history.enableAutoUpdate();
			
			document.historyIndex = getHistoryIndex();
			
			historyIndex = getHistoryIndex();
			
			instance.dispatchHistoryChangeEvent(currentIndex+1, currentIndex);
		}
		
		/**
		 * Removes property change items in the history array
		 * */
		public static function removeHistoryItem(changes:Array):void {
			var document:IDocument = instance.selectedDocument;
			var currentIndex:int = getHistoryIndex();
			
			var itemIndex:int = document.history.getItemIndex(changes);
			
			if (itemIndex>0) {
				document.history.removeItemAt(itemIndex);
			}
			
			document.historyIndex = getHistoryIndex();
			historyIndex = getHistoryIndex();
			
			instance.dispatchHistoryChangeEvent(currentIndex-1, currentIndex);
		}
		
		/**
		 * Removes all history in the history array. 
		 * Note: We should set the changes to null. 
		 * */
		public static function removeAllHistory():void {
			var document:IDocument = instance.selectedDocument;
			var currentIndex:int = getHistoryIndex();
			document.history.removeAll();
			document.history.refresh(); // we should loop through and run purge on each HistoryItem
			instance.dispatchHistoryChangeEvent(-1, currentIndex);
		}
		
		/**
		 * Returns true if two objects are of the same class type
		 * */
		public function isSameClassType(target:Object, target1:Object):Boolean {
			return ClassUtils.isSameClassType(target, target1);
		}
	}
}

class SINGLEDOUBLE{}