/**
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

package com.flexcapacitor.controller {
	import com.flexcapacitor.components.IDocumentContainer;
	import com.flexcapacitor.effects.core.PlayerType;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.logging.RadiateLogTarget;
	import com.flexcapacitor.managers.ClassesManager;
	import com.flexcapacitor.managers.ClipboardManager;
	import com.flexcapacitor.managers.CodeManager;
	import com.flexcapacitor.managers.ComponentManager;
	import com.flexcapacitor.managers.CreationManager;
	import com.flexcapacitor.managers.DeviceManager;
	import com.flexcapacitor.managers.DocumentManager;
	import com.flexcapacitor.managers.FontManager;
	import com.flexcapacitor.managers.HistoryManager;
	import com.flexcapacitor.managers.ImportManager;
	import com.flexcapacitor.managers.InspectorManager;
	import com.flexcapacitor.managers.KeyboardManager;
	import com.flexcapacitor.managers.MenuManager;
	import com.flexcapacitor.managers.ProfileManager;
	import com.flexcapacitor.managers.ProjectManager;
	import com.flexcapacitor.managers.ServicesManager;
	import com.flexcapacitor.managers.SettingsManager;
	import com.flexcapacitor.managers.SnippetManager;
	import com.flexcapacitor.managers.TextEditorManager;
	import com.flexcapacitor.managers.ToolManager;
	import com.flexcapacitor.managers.TranscodersManager;
	import com.flexcapacitor.managers.ViewManager;
	import com.flexcapacitor.model.DocumentData;
	import com.flexcapacitor.model.DocumentDescription;
	import com.flexcapacitor.model.ErrorData;
	import com.flexcapacitor.model.HTMLExportOptions;
	import com.flexcapacitor.model.HistoryEventData;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IDocumentData;
	import com.flexcapacitor.model.IProject;
	import com.flexcapacitor.model.IssueData;
	import com.flexcapacitor.model.MetaData;
	import com.flexcapacitor.model.SourceData;
	import com.flexcapacitor.model.WarningData;
	import com.flexcapacitor.performance.PerformanceMeter;
	import com.flexcapacitor.states.AddItems;
	import com.flexcapacitor.tools.ITool;
	import com.flexcapacitor.tools.Selection;
	import com.flexcapacitor.tools.Text;
	import com.flexcapacitor.utils.ArrayUtils;
	import com.flexcapacitor.utils.Base64;
	import com.flexcapacitor.utils.ClassLoader;
	import com.flexcapacitor.utils.ClassUtils;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.DragManagerUtil;
	import com.flexcapacitor.utils.LayoutDebugHelper;
	import com.flexcapacitor.utils.PersistentStorage;
	import com.flexcapacitor.utils.PopUpOverlayManager;
	import com.flexcapacitor.utils.SVGUtils;
	import com.flexcapacitor.utils.XMLUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDefinition;
	import com.flexcapacitor.views.MainView;
	import com.flexcapacitor.views.windows.PasteImageFromClipboardWindow;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.UncaughtErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.FileReference;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.core.IFlexModuleFactory;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.effects.IEffect;
	import mx.effects.Sequence;
	import mx.logging.AbstractTarget;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.printing.FlexPrintJob;
	import mx.styles.IStyleClient;
	import mx.utils.ArrayUtil;
	
	import spark.components.Application;
	import spark.components.Label;
	import spark.components.Scroller;
	import spark.core.ContentCache;
	import spark.primitives.supportClasses.GraphicElement;
	
	use namespace mx_internal;
	
	/**
	 * Dispatched on history change
	 * */
	[Event(name="historyChange", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched on beginning of undo history
	 * */
	[Event(name=RadiateEvent.BEGINNING_OF_UNDO_HISTORY, type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched on end of undo history
	 * */
	[Event(name=RadiateEvent.END_OF_UNDO_HISTORY, type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when namespaces have loaded
	 * */
	[Event(name=RadiateEvent.NAMESPACES_LOADED, type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when register results are received
	 * */
	[Event(name="registerResults", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when a print job is cancelled
	 * */
	[Event(name="printCancelled", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when an item is added to the target
	 * */
	[Event(name="addItem", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when an item is removed from the target
	 * */
	[Event(name="removeItem", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when an item is removed from the target
	 * */
	[Event(name="removeTarget", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when the target is changed
	 * */
	[Event(name="targetChange", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when the documentation url is changed
	 * */
	[Event(name="documentationChange", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when the document is changed
	 * */
	[Event(name="documentChange", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when a document is opening
	 * */
	[Event(name="documentOpening", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when a document is opened
	 * */
	[Event(name="documentOpen", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when a document is closed
	 * */
	[Event(name=RadiateEvent.DOCUMENT_CLOSE, type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when a console value is changed
	 * */
	[Event(name="consoleValueChange", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when a document is renamed
	 * */
	[Event(name="documentRename", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when the project is changed
	 * */
	[Event(name="projectChange", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when the project is deleted
	 * */
	[Event(name="projectDeletedResults", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when the project is created
	 * */
	[Event(name="projectCreated", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when a property on the target is changed. 
	 * Using propertyChanged instead of propertyChange because of error with bindable
	 * tag using propertyChange:
	 * TypeError: Error #1034: Type Coercion failed: cannot convert mx.events::PropertyChangeEvent@11d2187b1 to com.flexcapacitor.events.RadiateEvent.
	 * */
	[Event(name="propertyChanged", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when a property is selected on the target
	 * */
	[Event(name="propertySelected", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when a property edit is requested
	 * */
	[Event(name="propertyEdit", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when the tool changes
	 * */
	[Event(name="toolChange", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when the scale changes
	 * */
	[Event(name="scaleChange", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when the document size or scale changes
	 * */
	[Event(name="documentSizeChange", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when the document preview uncaught event occurs
	 * */
	[Event(name="uncaughtExceptionEvent", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Not used yet. 
	 * */
	[Event(name="initialized", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Used when the tools list has been updated. 
	 * */
	[Event(name="toolsUpdated", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Used when the components list is updated. 
	 * */
	[Event(name="componentsUpdated", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Used when the document canvas is updated. 
	 * */
	[Event(name="canvasChange", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Event to request a preview if available. Used for HTML preview. 
	 * */
	[Event(name="requestPreview", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when the generated code is updated. 
	 * */
	[Event(name="codeUpdated", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when a color is selected. 
	 * */
	[Event(name="colorSelected", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when an object is selected 
	 * */
	[Event(name="objectSelected", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Dispatched when an external asset such as an image is loaded 
	 * */
	[Event(name="assetLoaded", type="com.flexcapacitor.events.RadiateEvent")]
	
	/**
	 * Main class and API that handles the interactions between the view and the models. <br/><br/>
	 * 
	 * Dispatches events and exposes methods to manipulate the documents.<br/><br/>
	 *  
	 * It contains a list of components, tools, devices, inspectors (panels), assets and 
	 * in the future we should add skins, effects and so on. 
	 * These items are created from an XML file at startup so we can configure what is available
	 * to our user or project. We do this so we can also load in a remote SWF to add 
	 * additional components, sounds, images, skins, inspectors, fonts, etc<br/><br/>
	 * 
	 * Currently we are saving and loading to a remote location or to a local shared object. 
	 * To save to a local file system we will need to modify these functions. <br/><br/>
	 * 
	 * This class supports an Undo / Redo history. The architecture is loosely based on 
	 * the structure found in the Effects classes. We may want to be a proxy to the documents
	 * and call undo and redo on them since we would like to support more than one 
	 * type of document. <br/><br/>
	 * 
	 * This class can be broken up into multiple classes since it is also handling 
	 * saving and loading and services. <br/><br/>
	 * 
	 * To set a property or style call setProperty or setStyle. <br/>
	 * To add a component call addElement. <br/>
	 * To log a message to the console call Radiate.info() or error().<br/><br/>
	 * 
	 * To undo call undo<br/>
	 * To redo call redo<br/><br/>
	 * 
	 * To get the history index access history index<br/>
	 * To check if history exists call the has history<br/>
	 * To check if undo can be performed access has undo<br/>
	 * To check if redo can be performed access has redo <br/><br/>
	 * */
	public class Radiate extends EventDispatcher {
		
		public function Radiate(s:SINGLEDOUBLE) {
			super(target as IEventDispatcher);
			
			// initialize - maybe call on startup() instead
			if (!initialized) {
				initialize();
			}
		}
		
		public static const SAME_OWNER:String = "sameOwner";
		public static const SAME_PARENT:String = "sameParent";
		public static const RADIATE_LOG:String = "radiate";
		
		public static const USER_STORE:String = "userStore";
		public static const TRANSFER_STORE:String = "transferStore";
		public static const RELEASE_DIRECTORY_STORE:String = "releaseDirectoryStore";
		
		public static var SET_TARGET_TEST:String = "setTargetTest";
		

		private static var initialized:Boolean;
		
		/**
		 * Attempt to support a console
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
		
		private static var historyManager:HistoryManager;
		private static var popUpOverlayManager:PopUpOverlayManager;
		private static var serviceManager:ServicesManager;
		private static var clipboardManager:ClipboardManager;
		private static var snippetManager:SnippetManager;
		private static var keyboardManager:KeyboardManager;
		private static var profileManager:ProfileManager;
		
		[Bindable]
		public static var fontsArray:Array;
		
		/**
		 * Create references for classes we need.
		 * */
		public static var radiateReferences:RadiateReferences;
		
		/**
		 * Is running on desktop
		 * */
		public static function get isDesktop():Boolean
		{
			return Capabilities.playerType == PlayerType.DESKTOP;
		}
		
		/**
		 * If true then importing document
		 * */
		public static var importingDocument:Boolean;
		
		/**
		 * Editor source data
		 * */
		public var editorSource:SourceData;
		
		/**
		 * Export file location if one is selected
		 * */
		public var exportFileLocation:FileReference;
		
		/**
		 * Default storage location for save and load. 
		 * */
		[Bindable]
		public var defaultStorageLocation:String;
		
		/**
		 * Auto save locations
		 * */
		[Bindable]
		public var autoSaveLocations:String;
		
		/**
		 * Open the design view at startup
		 * */
		public static var startInDesignView:Boolean;
		
		/**
		 * HTML Class
		 * */
		public static var htmlClass:Object;
		public static var desktopHTMLClassName:String = "mx.controls.HTML";
		
		public static var showMessageAnimation:Sequence;
		public static var showMessageLabel:Label;
		

		/**
		 * Build number
		 * */
		[Bindable]
		public static var buildNumber:String;
		
		/**
		 * Build date
		 * */
		[Bindable]
		public static var buildDate:String;
		
		/**
		 * Build time
		 * */
		[Bindable]
		public static var buildTime:String;
		
		/**
		 * Version number
		 * */
		[Bindable]
		public static var versionNumber:String;
		
		//----------------------------------
		//
		//  Logging Management
		// 
		//----------------------------------
		
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
			var componentsXML:XML 	= new XML(new Radii8LibrarySparkAssets.componentsManifestDefaults());
			var sparkXML:XML	 	= new XML(new Radii8LibraryTranscodersAssets.sparkManifest());
			var mxmlXML:XML	 		= new XML(new Radii8LibraryTranscodersAssets.mxmlManifest());
			var toolsXML:XML 		= new XML(new Radii8LibraryToolAssets.toolsManifestDefaults());
			var inspectorsXML:XML 	= new XML(new Radii8LibraryInspectorAssets.inspectorsManifestDefaults());
			var devicesXML:XML		= new XML(new Radii8LibraryDeviceAssets.devicesManifestDefaults());
			var exportersXML:XML	= new XML(new Radii8LibraryTranscodersAssets.transcodersManifestDefaults());
			
			setLoggingTarget(defaultLogTarget);
			
			SettingsManager.createSettingsData();

			SettingsManager.createSavedData();
			
			//createDocumentTypesList(documentsXML);
			
			ComponentManager.createComponentList(componentsXML);
			//createComponentList(sparkXML);
			//createComponentList(mxmlXML);
			
			TranscodersManager.createDocumentTranscoders(exportersXML);
			
			InspectorManager.createInspectorsList(inspectorsXML);
			
			ToolManager.createToolsList(toolsXML);
			
			DeviceManager.createDevicesList(devicesXML);
			
			FontManager.createFontsList();
			
			initialized = true;
		}
		
		/**
		 * Startup 
		 * */
		public static function startup(applicationReference:Application, 
									   mainViewReference:MainView, 
									   host:String = null, 
									   path:String = null):void {
			
			
			var screenshotPath:String;
			
			SettingsManager.applySettings();
			
			ViewManager.application = applicationReference;
			ViewManager.mainView 	= mainViewReference;
			
			// add support to enable this and send error reports
			CreationManager.showMeWhatsActivatedSoFar = false;
			CreationManager.showMeWhatsCreatedSoFar = false;
			
			serviceManager 			= ServicesManager.getInstance();
			historyManager 			= HistoryManager.getInstance();
 			popUpOverlayManager 	= PopUpOverlayManager.getInstance();
			keyboardManager			= KeyboardManager.getInstance();
			clipboardManager		= ClipboardManager.getInstance();
			snippetManager			= SnippetManager.getInstance();
			profileManager			= ProfileManager.getInstance();
			
			htmlClass = ClassUtils.getDefinition("mx.core.FlexHTMLLoader");
			
			keyboardManager.initialize(applicationReference, htmlClass);
			
			serviceManager.radiate 	= instance;
			HistoryManager.radiate 	= instance;
			clipboardManager.radiate= instance;
			
			// set debugging options here
			HistoryManager.debug 	= false;
			DragManagerUtil.debug 	= false;
			Text.debug 				= false;
			Selection.debug			= false;
			LayoutDebugHelper.debug	= false;
			MenuManager.debug 		= false;
			ClassLoader.debug 		= false;
			TextEditorManager.debug = false;
			
			PasteImageFromClipboardWindow.debug = false;
			
			// testing for why layout is invalid when disconnected from network - no longer needed
			//var layoutManager:ILayoutManager;
			//UIComponentGlobals.catchCallLaterExceptions = true;
			//layoutManager = UIComponentGlobals.layoutManager;
			//layoutManager.usePhasedInstantiation;
			
			ViewManager.application.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, instance.uncaughtErrorHandler, false, 0, true);
			//application.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, instance.uncaughtErrorHandler2, false, 0, true);
			
			//ExternalInterface.call("Radiate.getInstance");
			if (ExternalInterface.available) {
				ExternalInterface.call("Radiate.getInstance().setFlashInstance", ExternalInterface.objectID);
			}
			
			if (!firstRun && PersistentStorage.isSupported) {
				host = PersistentStorage.read(WP_HOST_NAME);
				path = PersistentStorage.read(WP_PATH_NAME);
				screenshotPath = PersistentStorage.read(SCREENSHOT_PATH_NAME);
			}
			
			if (host) {
				WP_HOST = host;
			}
			else {
				WP_HOST = defaultHost;
			}
			
			if (path && !firstRun) {
				WP_PATH = path;
			}
			else {
				WP_PATH = defaultPath;
			}
			
			if (screenshotPath) {
				SCREENSHOT_PATH = screenshotPath;
			}
			else {
				SCREENSHOT_PATH = defaultScreenshotPath;
			}
			
			snippetManager.initialize(WP_SNIPPET_HOST);
			
			// todo check how many we use
			contentCache.maxCacheEntries = 300;
			
			CodeManager.setTranscodersVersion(Radiate.versionNumber);
			CodeManager.setComponentDefinitions(ComponentManager.componentDefinitions.source);
			
			ImportManager.setUpdatedHTMLImporterAndExporter();
			
			DisplayObjectUtils.Base64Encoder2 = Base64;
			
			XMLUtils.initialize();
			SVGUtils.initialize();
			
			ViewManager.createOpenImportPopUp();
			
			MenuManager.startup();
			
			TextEditorManager.createCallOut();
			
			// we use this to prevent hyperlinks from opening web pages when in design mode
			// we don't know what changes this causes with other components 
			// so it was disabled for a while
			// caused some issues with hyperlinks opening so disabling 
			//UIComponentGlobals.designMode = true;
			
			//radiate.openInitialProjects();
			//LayoutManager.getInstance().usePhasedInstantiation = false;
			
			ClassesManager.registerClasses();
			
		}
		
		protected function uncaughtErrorHandler2(event:UncaughtErrorEvent):void
		{
			//trace("Uncaught error: " + event);
			if ("text" in event && event.text!="") {
				error(event.text, event);
			}
			else if ("error" in event && event.error && "message" in event.error) {
				error(event.error.message, event);
			}
		}
		
		/**
		 * Reference to mechanism used to update the application
		 * */
		public var updater:IEffect;
		
		/**
		 * Checks for update on the desktop version 
		 * */
		public function checkForUpdate():void {
			if (updater) {
				updater.play();
			}
		}
		
		/**
		 * Create the list of document view types.
		 * */
		public static function createDocumentTypesList(xml:XML):void {
			var hasDefinition:Boolean;
			var items:XMLList;
			var item:XML;
			var numberOfItems:uint;
			var classType:Object;
			 
			// get list of transcoder classes 
			items = XML(xml).transcoder;
			
			numberOfItems = items.length();
			
			for (var i:int;i<numberOfItems;i++) {
				item = items[i];
				
				var documentDescription:DocumentDescription = new DocumentDescription();
				documentDescription.importXML(item);
				
				hasDefinition = ClassUtils.hasDefinition(documentDescription.classPath);
				
				if (hasDefinition) {
					//classType = ClassUtils.getDefinition(transcoder.classPath);
					
					//CodeManager.registerTranscoder(documentDescription);
				}
				else {
					error("Document transcoder class for " + documentDescription.name + " not found: " + documentDescription.classPath);
					// we need to add it to Radii8LibraryExporters
					// such as Radii8LibraryExporters
				}
			}
			
		}
		
		//----------------------------------
		//  target
		//----------------------------------
		
		/**
		 * Use setTarget() or setTargets() method to set the target. 
		 * */
		public function get target():Object {
			if (_targets.length > 0) {
				return _targets[0];
			}
			else {
				return null;
			}
		}
		
		/**
		 * Use setTarget() or setTargets() method to set the target. 
		 * */
		public static function get target():Object {
			return instance.target;
		}
		
		/**
		 * When the target is set we sometimes want to work with a property on that target.
		 * If that property is an array we must also set the property index
		 * 
		 * @see target
		 * @see setTarget
		 * @see setTargetProperties
		 * @see propertyIndex
		 * */
		public var property:String;
		
		/**
		 * When the target is set we sometimes want to work with a property on that target.
		 * If that property is an array we must also set the property index
		 * 
		 * @see target
		 * @see setTarget
		 * @see setTargetProperties
		 * @see propertyIndex
		 * */
		public var propertyIndex:int;
		
		/**
		 * When working with an object related to the target
		 * */
		public var subTarget:Object;
		
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
		
		//----------------------------------
		//  project
		//----------------------------------
		
		private static var _selectedProject:IProject;
		
		/**
		 * Reference to the current project
		 * */
		public static function get selectedProject():IProject {
			return _selectedProject;
		}
		
		/**
		 *  @private
		 */
		[Bindable(event="projectChange")]
		public static function set selectedProject(value:IProject):void {
			if (value==_selectedProject) return;
			_selectedProject = value;
			
		}
		
		//----------------------------------
		//  document
		//----------------------------------
		
		private static var _selectedDocument:IDocument;
		
		/**
		 * Get the current document.
		 * */
		public static function get selectedDocument():IDocument {
			return _selectedDocument;
		}
		
		/**
		 *  @private
		 */
		[Bindable]
		public static function set selectedDocument(value:IDocument):void {
			if (value==_selectedDocument) return;
			_selectedDocument = value;
		}
		
		/**
		 * Returns true if there is no document open and shows a message if no document open
		 **/
		public static function checkForDocument():Boolean {
			if (selectedDocument==null) {
				info("No document open");
				return true;
			}
			
			return false;
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
		
		public static var componentsIconPath:String = "assets/icons/components/";
		public static var componentsIconNotFoundPath:String = componentsIconPath + "/BorderContainer.png";
		
		public static var WP_HOST_NAME:String = "wpHostName";
		public static var WP_PATH_NAME:String = "wpPathName";
		public static var CONTACT_FORM_URL:String = "http://www.radii8.com/support.php";
		public static var WP_HOST:String = "https://www.radii8.com";
		public static var WP_PATH:String = "/r8m/";
		public static var WP_USER_PATH:String = "";
		public static var WP_EXAMPLES_PATH:String = "/r8m/";
		public static var WP_NEWS_PATH:String = "/r8m/";
		public static var WP_LOGIN_PATH:String = "/wp-admin/";
		public static var WP_PROFILE_PATH:String = "/wp-admin/profile.php";
		public static var WP_EDIT_POST_PATH:String = "/wp-admin/post.php";
		public static var WP_SNIPPET_HOST:String = "https://www.radii8.com/snippets/";
		public static var WP_SNIPPET_EDITOR:String = "https://www.radii8.com/mxml/";
		public static var WP_SNIPPET_VIEWER:String = "https://www.radii8.com/viewer/";
		public static var APPLICATION_PATH:String = "/online/";
		public static var EDITOR_PATH:String = "/mxml/";
		public static var VIEWER_PATH:String = "/viewer/";
		public static var DEFAULT_NAVIGATION_WINDOW:String = "userNavigation";
		public static var SCREENSHOT_PATH:String = "https://dev.windows.com/en-us/microsoft-edge/tools/screenshots/?url=";
		public static var SCREENSHOT_PATH_NAME:String = "screenshotPathName";
		public static var SITE_SCANNER_PATH:String = "https://dev.windows.com/en-us/microsoft-edge/tools/staticscan/?url=";
		public static var SITE_SCANNER_PATH_NAME:String = "siteScannerPathName";
		
		public static var defaultHost:String = "https://www.radii8.com";
		public static var defaultPath:String = "/r8m/";
		public static var defaultScreenshotPath:String = "https://dev.windows.com/en-us/microsoft-edge/tools/screenshots/?url=";
		public static var defaultSiteScannerPath:String = "https://dev.windows.com/en-us/microsoft-edge/tools/staticscan/?url=";
		public static var firstRun:Boolean;
		
		/**
		 * Gets the URL to the examples site
		 * */
		public static function getExamplesWPURL():String {
			return WP_HOST + WP_EXAMPLES_PATH;
		}
		
		/**
		 * Gets the URL to the examples site
		 * */
		public static function getNewsWPURL():String {
			return WP_HOST + WP_NEWS_PATH;
		}
		
		/**
		 * Get's the root path to the single or multiuser wordpress site
		 * Wp_host + WP_Path
		 * */
		public static function getWPHostURL():String {
			return WP_HOST + WP_PATH;
		}
		
		/**
		 * Get's the path to the single or multiuser wordpress site
		 * Wp_host + WP_Path + WP_USER_Path. 
		 * When a user logs into a multiuser site the first time
		 * they can and usually do log into wp_host + wp_path.
		 * After they log in, future calls are made to 
		 * wp_host + wp_path + wp_user_path. 
		 * */
		public static function getWPURL():String {
			return WP_HOST + WP_PATH + WP_USER_PATH;
		}
		
		/**
		 * Get's the URL to the login page for users to login manually
		 * */
		public static function getWPLoginURL():String {
			return WP_HOST + WP_PATH + WP_USER_PATH + WP_LOGIN_PATH;
		}
		
		/**
		 * Get's the URL to the profile page for the user
		 * */
		public static function getWPProfileURL():String {
			return WP_HOST + WP_PATH + WP_USER_PATH + WP_PROFILE_PATH;
		}
		
		/**
		 * Get's the URL to edit the current post
		 * */
		public static function getWPEditPostURL(documentData:IDocumentData):String {
			//http://www.radii8.com/r8m/wp-admin/post.php?post=5227&action=edit
			return WP_HOST + WP_PATH + WP_USER_PATH + WP_EDIT_POST_PATH + "?post=" + documentData.id + "&action=edit";
		}
		
		/**
		 * Gets the URL to open this snippet
		 * */
		public static function getSnippetApplicationURL(snippedID:String):String {
			return WP_HOST + APPLICATION_PATH + "#" + snippedID;
		}
		
		/**
		 * Gets the URL to edit this snippet in the text editor
		 * */
		public static function getSnippetEditorURL(snippedID:String):String {
			return WP_HOST + EDITOR_PATH + "#" + snippedID;
		}
		
		/**
		 * Gets the URL to view this snippet
		 * */
		public static function getSnippetViewerURL(snippedID:String):String {
			return WP_HOST + VIEWER_PATH + "#" + snippedID;
		}
		
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
		
		public static var _selectedTool:ITool;
		
		/**
		 * Get selected tool.
		 * */
		public static function get selectedTool():ITool {
			return _selectedTool;
		}
		
		/**
		 * Set selected tool.
		 * */
		public static function set selectedTool(value:ITool):void {
			_selectedTool = value;
		}
		
		/**
		 * Collection of tools that can be added or removed to 
		 * */
		[Bindable]
		public static var toolsDescriptions:ArrayCollection = new ArrayCollection();
		
		private static var _previousSelectedTool:ITool;

		public static function get previousSelectedTool():ITool {
			return _previousSelectedTool;
		}

		public static function set previousSelectedTool(value:ITool):void {
			_previousSelectedTool = value;
		}
		
		/**
		 * Cache for icons used throught the application
		 * */
		[Bindable]
		public static var contentCache:ContentCache = new ContentCache();
		
		
		/**
		 * Sets the document
		 * */
		public static function setProject(value:IProject, dispatchEvent:Boolean = true, cause:String = ""):void {
			selectedProject = value;
			/*if (_projects.length == 1 && projects==value) return;
			
			_projects = null;// without this, the contents of the array would change across all instances
			_projects = [];
			
			if (value) {
				_projects[0] = value;
			}*/
			
			if (dispatchEvent) {
				dispatchProjectChangeEvent(selectedProject);
			}
			
		}
		
		/**
		 * Selects the projects
		 * */
		public function setProjects(value:*, dispatchEvent:Boolean = true, cause:String = ""):void {
			/*
			value = ArrayUtil.toArray(value);
			
			// remove listeners from previous documents
			var n:int = _projects.length;
			
			for (var i:int = n - 1; i >= 0; i--) {
				if (_projects[i] == null) {
					continue;
				}
			}
			
			// Strip out null values.
			// Binding will trigger again when the null projects are created.
			n = value.length;
			
			for (i = n - 1; i >= 0; i--) {
				if (value[i] == null) {
					value.splice(i,1);
					continue;
				}
			}
			
			_projects = value;
			*/
			
			if (dispatchEvent) {
				dispatchProjectsSetEvent(ProjectManager.projects);
			}
			
		}
		
		/**
		 * Selects the current document
		 * */
		public static function selectDocument(value:IDocument, dispatchEvent:Boolean = true, cause:String = ""):void {
			var iDocumentContainer:IDocumentContainer;
			
			if (selectedDocument != value) {
				selectedDocument = value;
			}
			
			iDocumentContainer = DocumentManager.getDocumentContainer(value);
			
			if (iDocumentContainer) {
				DocumentManager.toolLayer = iDocumentContainer.toolLayer;
				DocumentManager.canvasBorder = iDocumentContainer.canvasBorder;
				DocumentManager.canvasBackground= iDocumentContainer.canvasBackground;
				DocumentManager.canvasScroller = iDocumentContainer.canvasScroller;
				DocumentManager.editorComponent = iDocumentContainer.editorComponent;
			}
			
			HistoryManager.history = selectedDocument ? selectedDocument.history : null;
			HistoryManager.history ? HistoryManager.history.refresh() : void;
			HistoryManager.updateUndoRedoBindings(selectedDocument, HistoryManager.getHistoryPosition(selectedDocument));
			
			if (dispatchEvent) {
				dispatchDocumentChangeEvent(selectedDocument);
			}
			
		}
		
		/**
		 * Selects the documents
		 * */
		public function selectDocuments(value:*, dispatchEvent:Boolean = true, cause:String = ""):void {
			/*
			value = ArrayUtil.toArray(value);
			
			// remove listeners from previous documents
			var n:int = _documents.length;
			
			for (var i:int = n - 1; i >= 0; i--) {
				if (_documents[i] == null) {
					continue;
				}
			}
			
			// Strip out null values.
			// Binding will trigger again when the null documents are created.
			n = value.length;
			
			for (i = n - 1; i >= 0; i--) {
				if (value[i] == null) {
					value.splice(i,1);
					continue;
				}
				
			}
			
			_documents = value;*/
			
			if (dispatchEvent) {
				dispatchDocumentsSetEvent(value);
			}
			
			
		}
		
		/**
		 * Selects the target
		 * @see setTargets
		 * @see target
		 * @see targets
		 * */
		public function setTarget(value:*, dispatchEvent:Boolean = true, cause:String = "", reselect:Boolean = false):void {
			var _tempTarget:* = value && value is Array && value.length ? value[0] : value;
			var documentData:Class = DocumentData;
			if (target is IDocument) {
				//enterDebugger();
			}
			
			if (_targets.length == 1 && target==_tempTarget && reselect==false) {
				//return;
			}
			
			_targets = null;// without this, the contents of the array would change across all instances
			_targets = [];
			
			if (value is Array) {
				//_targets = (value as Array).slice();
				_targets[0] = _tempTarget;
			}
			else {
				_targets[0] = value;
			}
			
			subTarget = null;
			property = null;
			propertyIndex = -1;
			
			if (dispatchEvent) {
				dispatchTargetChangeEvent(target);
			}
			
		}
		
		/**
		 * Selects the target
		 * @see setTargets
		 * @see target
		 * @see targets
		 * */
		public function setSubTarget(target:*, subTarget:*, dispatchEvent:Boolean = true, cause:String = "", reselect:Boolean = false):void {
			var _tempTarget:* = target && target is Array && target.length ? target[0] : target;
			
			if (_targets.length == 1 && target==_tempTarget && reselect==false) {
				//return;
			}
			
			_targets = null;// without this, the contents of the array would change across all instances
			_targets = [];
			
			if (target is Array) {
				//_targets = (value as Array).slice();
				_targets[0] = _tempTarget;
			}
			else {
				_targets[0] = target;
			}
			
			this.subTarget = subTarget;
			property = null;
			propertyIndex = -1;
			
			if (dispatchEvent) {
				dispatchTargetChangeEvent(target, false, null, -1, subTarget);
			}
			
		}
		
		/**
		 * Selects the target
		 * @see setTargets
		 * @see target
		 * @see targets
		 * */
		public function setTargetProperties(target:*, propertyName:*, propertyIndex:int = -1, dispatchEvent:Boolean = true, cause:String = "", reselect:Boolean = false):void {
			var _tempTarget:* = target && target is Array && target.length ? target[0] : target;
			
			if (_targets.length == 1 && target==_tempTarget && reselect==false) {
				//return;
			}
			
			_targets = null;// without this, the contents of the array would change across all instances
			_targets = [];
			
			if (target is Array) {
				//_targets = (value as Array).slice();
				_targets[0] = _tempTarget;
			}
			else {
				_targets[0] = target;
			}
			
			property = propertyName;
			propertyIndex = propertyName;
			
			if (dispatchEvent) {
				dispatchTargetChangeEvent(target, false, propertyName, propertyIndex);
			}
			
		}
		
		/**
		 * Selects the target
		 * 
		 * @see setTarget
		 * @see target
		 * @see targets
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
			
			subTarget = null;
			property = null;
			propertyIndex = -1;
			
			if (dispatchEvent) {
				dispatchTargetChangeEvent(_targets, true);
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
				dispatchTargetChangeEvent(_targets, true);
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
		 * Selects the last created component
		 * */
		public static function setLastCreatedComponent(dispatchEvent:Boolean = true, cause:String = "", reselect:Boolean = false):void {
			instance.setTarget(ComponentManager.lastCreatedComponent, dispatchEvent, cause, reselect);
		}
		
		/**
		 * Selects the target
		 * */
		public static function setTarget(value:Object, dispatchEvent:Boolean = true, cause:String = "", reselect:Boolean = false):void {
			instance.setTarget(value, dispatchEvent, cause, reselect);
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
			instance.selectDocuments(value, dispatchEvent, cause);
		}
		
		/**
		 * Deselects the documents
		 * */
		public static function desetDocuments(dispatchEvent:Boolean = true, cause:String = ""):void {
			instance.selectDocuments(null, dispatchEvent, cause);
		}
		
		/**
		 * Prevent log messages
		 * */
		public static var preventDefaultMessages:Boolean;
		
		public static var htmlOptions:HTMLExportOptions;
		
		//----------------------------------
		//
		//  Events Management
		// 
		//----------------------------------
		
		/**
		 * Dispatch example projects list received results event
		 * */
		public static function dispatchGetExampleProjectsListResultsEvent(data:Object):void {
			var projectsListResultEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.EXAMPLE_PROJECTS_LIST_RECEIVED)) {
				projectsListResultEvent = new RadiateEvent(RadiateEvent.EXAMPLE_PROJECTS_LIST_RECEIVED);
				projectsListResultEvent.data = data;
				dispatchEvent(projectsListResultEvent);
			}
		}
		
		/**
		 * Dispatch projects list received results event
		 * */
		public static function dispatchGetProjectsListResultsEvent(data:Object):void {
			var projectsListResultEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECTS_LIST_RECEIVED)) {
				projectsListResultEvent = new RadiateEvent(RadiateEvent.PROJECTS_LIST_RECEIVED);
				projectsListResultEvent.data = data;
				dispatchEvent(projectsListResultEvent);
			}
		}
		
		/**
		 * Dispatch print cancelled event
		 * */
		public static function dispatchPrintCancelledEvent(data:Object, printJob:FlexPrintJob):void {
			var printCancelledEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PRINT_CANCELLED)) {
				printCancelledEvent = new RadiateEvent(RadiateEvent.PRINT_CANCELLED);
				printCancelledEvent.data = data;
				printCancelledEvent.selectedItem = printJob;
				dispatchEvent(printCancelledEvent);
			}
		}
		
		/**
		 * Dispatch print complete event
		 * */
		public static function dispatchPrintCompleteEvent(data:Object, printJob:FlexPrintJob):void {
			var printCompleteEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PRINT_COMPLETE)) {
				printCompleteEvent = new RadiateEvent(RadiateEvent.PRINT_COMPLETE);
				printCompleteEvent.data = data;
				printCompleteEvent.selectedItem = printJob;
				dispatchEvent(printCompleteEvent);
			}
		}
		
		/**
		 * Dispatch attachments received event
		 * */
		public static function dispatchAttachmentsResultsEvent(successful:Boolean, attachments:Array):void {
			var attachmentsReceivedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.ATTACHMENTS_RECEIVED)) {
				attachmentsReceivedEvent = new RadiateEvent(RadiateEvent.ATTACHMENTS_RECEIVED, false, false, attachments);
				attachmentsReceivedEvent.successful = successful;
				attachmentsReceivedEvent.status = successful ? "ok" : "fault";
				attachmentsReceivedEvent.targets = ArrayUtil.toArray(attachments);
				dispatchEvent(attachmentsReceivedEvent);
			}
		}
		
		/**
		 * Dispatch upload attachment received event
		 * */
		public static function dispatchUploadAttachmentResultsEvent(successful:Boolean, attachments:Array, data:Object, error:Object = null):void {
			var uploadAttachmentEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.ATTACHMENT_UPLOADED)) {
				uploadAttachmentEvent = new RadiateEvent(RadiateEvent.ATTACHMENT_UPLOADED, false, false);
				uploadAttachmentEvent.successful = successful;
				uploadAttachmentEvent.status = successful ? "ok" : "fault";
				uploadAttachmentEvent.data = attachments;
				uploadAttachmentEvent.selectedItem = data;
				uploadAttachmentEvent.error = error;
				dispatchEvent(uploadAttachmentEvent);
			}
		}
		
		/**
		 * Dispatch feedback results event
		 * */
		public static function dispatchFeedbackResultsEvent(successful:Boolean, data:Object):void {
			var feedbackResultsEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.FEEDBACK_RESULT)) {
				feedbackResultsEvent = new RadiateEvent(RadiateEvent.FEEDBACK_RESULT);
				feedbackResultsEvent.data = data;
				feedbackResultsEvent.successful = successful;
				dispatchEvent(feedbackResultsEvent);
			}
		}
		
		/**
		 * Dispatch login results event
		 * */
		public static function dispatchLoginResultsEvent(successful:Boolean, data:Object):void {
			var loginResultsEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.LOGIN_RESULTS)) {
				loginResultsEvent = new RadiateEvent(RadiateEvent.LOGIN_RESULTS);
				loginResultsEvent.data = data;
				loginResultsEvent.successful = successful;
				dispatchEvent(loginResultsEvent);
			}
		}
		
		/**
		 * Dispatch logout results event
		 * */
		public static function dispatchLogoutResultsEvent(successful:Boolean, data:Object):void {
			var logoutResultsEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.LOGOUT_RESULTS)) {
				logoutResultsEvent = new RadiateEvent(RadiateEvent.LOGOUT_RESULTS);
				logoutResultsEvent.data = data;
				logoutResultsEvent.successful = successful;
				dispatchEvent(logoutResultsEvent);
			}
		}
		
		/**
		 * Dispatch register results event
		 * */
		public static function dispatchRegisterResultsEvent(successful:Boolean, data:Object):void {
			var registerResultsEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.REGISTER_RESULTS)) {
				registerResultsEvent = new RadiateEvent(RadiateEvent.REGISTER_RESULTS);
				registerResultsEvent.data = data;
				registerResultsEvent.successful = successful;
				dispatchEvent(registerResultsEvent);
			}
		}
		
		/**
		 * Dispatch change password results event
		 * */
		public static function dispatchChangePasswordResultsEvent(successful:Boolean, data:Object):void {
			var changePasswordResultsEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.CHANGE_PASSWORD_RESULTS)) {
				changePasswordResultsEvent = new RadiateEvent(RadiateEvent.CHANGE_PASSWORD_RESULTS);
				changePasswordResultsEvent.data = data;
				changePasswordResultsEvent.successful = successful;
				dispatchEvent(changePasswordResultsEvent);
			}
		}
		
		/**
		 * Dispatch lost password results event
		 * */
		public static function dispatchLostPasswordResultsEvent(successful:Boolean, data:Object):void {
			var lostPasswordResultsEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.LOST_PASSWORD_RESULTS)) {
				lostPasswordResultsEvent = new RadiateEvent(RadiateEvent.LOST_PASSWORD_RESULTS);
				lostPasswordResultsEvent.data = data;
				lostPasswordResultsEvent.successful = successful;
				dispatchEvent(lostPasswordResultsEvent);
			}
		}
		
		/**
		 * Dispatch project deleted results event
		 * */
		public static function dispatchProjectDeletedEvent(successful:Boolean, data:Object):void {
			var deleteProjectResultsEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_DELETED)) {
				deleteProjectResultsEvent = new RadiateEvent(RadiateEvent.PROJECT_DELETED);
				deleteProjectResultsEvent.data = data;
				deleteProjectResultsEvent.successful = successful;
				deleteProjectResultsEvent.status = successful ? "ok" : "error";
				dispatchEvent(deleteProjectResultsEvent);
			}
		}
		
		/**
		 * Dispatch document deleted results event
		 * */
		public static function dispatchDocumentDeletedEvent(successful:Boolean, data:Object):void {
			var deleteDocumentResultsEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_DELETED)) {
				deleteDocumentResultsEvent = new RadiateEvent(RadiateEvent.DOCUMENT_DELETED);
				deleteDocumentResultsEvent.data = data;
				deleteDocumentResultsEvent.successful = successful;
				deleteDocumentResultsEvent.status = successful ? "ok" : "error";
				dispatchEvent(deleteDocumentResultsEvent);
			}
		}
		
		/**
		 * Dispatch attachments deleted results event
		 * */
		public static function dispatchAttachmentsDeletedEvent(successful:Boolean, data:Object):void {
			var deleteDocumentResultsEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.ATTACHMENTS_DELETED)) {
				deleteDocumentResultsEvent = new RadiateEvent(RadiateEvent.ATTACHMENTS_DELETED);
				deleteDocumentResultsEvent.data = data;
				deleteDocumentResultsEvent.successful = successful;
				deleteDocumentResultsEvent.status = successful ? "ok" : "error";
				dispatchEvent(deleteDocumentResultsEvent);
			}
		}
		
		/**
		 * Dispatch component definition added 
		 * */
		public static function dispatchComponentDefinitionAddedEvent(data:ComponentDefinition):void {
			var assetAddedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.COMPONENT_DEFINITION_ADDED)) {
				assetAddedEvent = new RadiateEvent(RadiateEvent.COMPONENT_DEFINITION_ADDED);
				assetAddedEvent.data = data;
				dispatchEvent(assetAddedEvent);
			}
		}
		
		/**
		 * Dispatch asset added event
		 * */
		public static function dispatchAssetAddedEvent(data:Object):void {
			var assetAddedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.ASSET_ADDED)) {
				assetAddedEvent = new RadiateEvent(RadiateEvent.ASSET_ADDED);
				assetAddedEvent.data = data;
				dispatchEvent(assetAddedEvent);
			}
		}
		
		/**
		 * Dispatch asset loaded event
		 * */
		public static function dispatchAssetLoadedEvent(asset:Object, document:IDocument, resized:Boolean, successful:Boolean = true):void {
			var assetLoadedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.ASSET_LOADED)) {
				assetLoadedEvent = new RadiateEvent(RadiateEvent.ASSET_LOADED);
				assetLoadedEvent.data = asset;
				assetLoadedEvent.selectedItem = document;
				assetLoadedEvent.resized = resized;
				assetLoadedEvent.successful = successful;
				dispatchEvent(assetLoadedEvent);
			}
		}
		
		/**
		 * Dispatch asset removed event
		 * */
		public static function dispatchAssetRemovedEvent(data:IDocumentData, successful:Boolean = true):void {
			var assetRemovedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.ASSET_REMOVED)) {
				assetRemovedEvent = new RadiateEvent(RadiateEvent.ASSET_REMOVED);
				assetRemovedEvent.data = data;
				dispatchEvent(assetRemovedEvent);
			}
		}
		
		/**
		 * Dispatch assets removed event
		 * */
		public static function dispatchAssetsRemovedEvent(attachments:Array, successful:Boolean = true):void {
			var assetRemovedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.ASSETS_REMOVED)) {
				assetRemovedEvent = new RadiateEvent(RadiateEvent.ASSETS_REMOVED);
				assetRemovedEvent.data = attachments;
				dispatchEvent(assetRemovedEvent);
			}
		}
		
		/**
		 * Dispatch target change event
		 * */
		public static function dispatchTargetChangeEvent(target:*, multipleSelection:Boolean = false, propertyName:String = null, propertyIndex:int = -1, subTarget:Object = null):void {
			if (importingDocument) return;
			var targetChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.TARGET_CHANGE)) {
				targetChangeEvent = new RadiateEvent(RadiateEvent.TARGET_CHANGE, false, false, target);
				targetChangeEvent.selectedItem = target && target is Array ? target[0] : target;
				targetChangeEvent.subSelectedItem = subTarget;
				targetChangeEvent.targets = ArrayUtil.toArray(target);
				targetChangeEvent.property = propertyName;
				targetChangeEvent.propertyIndex = propertyIndex;
				PerformanceMeter.start(SET_TARGET_TEST, true, false);
				dispatchEvent(targetChangeEvent);
				PerformanceMeter.stop(SET_TARGET_TEST, false);
			}
		}
		
		/**
		 * Dispatch namespaces loaded event
		 * */
		public static function dispatchNamespacesLoadedEvent(successful:Boolean = true):void {
			var assetLoadedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.NAMESPACES_LOADED)) {
				assetLoadedEvent = new RadiateEvent(RadiateEvent.NAMESPACES_LOADED);
				assetLoadedEvent.successful = successful;
				dispatchEvent(assetLoadedEvent);
			}
		}
		
		/**
		 * Dispatch a history change event
		 * */
		public static function dispatchHistoryChangeEvent(document:IDocument, newIndex:int, oldIndex:int, historyEvent:HistoryEventData = null):void {
			var event:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.HISTORY_CHANGE)) {
				event = new RadiateEvent(RadiateEvent.HISTORY_CHANGE);
				event.newIndex = newIndex;
				event.oldIndex = oldIndex;
				event.historyEvent = historyEvent ? historyEvent : null;
				event.targets = historyEvent ? historyEvent.targets : [];
				dispatchEvent(event);
			}
		}
		
		/**
		 * Dispatch a history change event
		 * */
		public static function dispatchDocumentRebuiltEvent(document:IDocument):void {
			var event:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_REBUILT)) {
				event = new RadiateEvent(RadiateEvent.DOCUMENT_REBUILT);
				//event.target = document;
				dispatchEvent(event);
			}
		}
		
		/**
		 * Dispatch scale change event
		 * */
		public static function dispatchScaleChangeEvent(target:*, scaleX:Number = NaN, scaleY:Number = NaN):void {
			var scaleChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.SCALE_CHANGE)) {
				scaleChangeEvent = new RadiateEvent(RadiateEvent.SCALE_CHANGE, false, false, target);
				scaleChangeEvent.scaleX = scaleX;
				scaleChangeEvent.scaleY = scaleY;
				dispatchEvent(scaleChangeEvent);
			}
		}
		
		/**
		 * Dispatch document size change event
		 * */
		public static function dispatchDocumentSizeChangeEvent(target:*):void {
			var sizeChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_SIZE_CHANGE)) {
				sizeChangeEvent = new RadiateEvent(RadiateEvent.DOCUMENT_SIZE_CHANGE, false, false, target);
				dispatchEvent(sizeChangeEvent);
			}
		}
		
		/**
		 * Dispatch document updated event
		 * */
		public static function dispatchDocumentUpdatedEvent(target:*):void {
			var documentUpdatedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_UPDATED)) {
				documentUpdatedEvent = new RadiateEvent(RadiateEvent.DOCUMENT_UPDATED, false, false, target);
				dispatchEvent(documentUpdatedEvent);
			}
		}
		
		/**
		 * Dispatch preview event
		 * */
		public static function dispatchPreviewEvent(sourceData:SourceData, type:String):void {
			var previewEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.REQUEST_PREVIEW)) {
				previewEvent = new RadiateEvent(RadiateEvent.REQUEST_PREVIEW);
				previewEvent.previewType = type;
				previewEvent.value = sourceData;
				dispatchEvent(previewEvent);
			}
		}
		
		
		/**
		 * Dispatch code updated event. Type is usually "HTML". 
		 * */
		public static function dispatchCodeUpdatedEvent(sourceData:SourceData, type:String, openInWindow:Boolean = false):void {
			var codeUpdatedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.CODE_UPDATED)) {
				codeUpdatedEvent = new RadiateEvent(RadiateEvent.CODE_UPDATED);
				codeUpdatedEvent.previewType = type;
				codeUpdatedEvent.value = sourceData;
				codeUpdatedEvent.openInBrowser = openInWindow;
				dispatchEvent(codeUpdatedEvent);
			}
		}
		
		/**
		 * Dispatch color selected event
		 * */
		public static function dispatchColorSelectedEvent(color:uint, invalid:Boolean = false):void {
			var colorSelectedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.COLOR_SELECTED)) {
				colorSelectedEvent = new RadiateEvent(RadiateEvent.COLOR_SELECTED);
				colorSelectedEvent.color = color;
				colorSelectedEvent.invalid = invalid;
				dispatchEvent(colorSelectedEvent);
			}
		}
		
		/**
		 * Dispatch property selected event
		 * */
		public static function dispatchPropertySelectedEvent(property:String, node:MetaData = null):void {
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
		public static function dispatchColorPreviewEvent(color:uint, invalid:Boolean = false):void {
			var colorPreviewEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.COLOR_PREVIEW)) {
				colorPreviewEvent = new RadiateEvent(RadiateEvent.COLOR_PREVIEW);
				colorPreviewEvent.color = color;
				colorPreviewEvent.invalid = invalid;
				dispatchEvent(colorPreviewEvent);
			}
		}
		
		/**
		 * Dispatch canvas change event
		 * */
		public static function dispatchCanvasChangeEvent(canvas:*, canvasBackgroundParent:*, scroller:Scroller):void {
			var targetChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.CANVAS_CHANGE)) {
				targetChangeEvent = new RadiateEvent(RadiateEvent.CANVAS_CHANGE);
				dispatchEvent(targetChangeEvent);
			}
		}
		
		/**
		 * Dispatch tool change event
		 * */
		public static function dispatchToolChangeEvent(value:ITool):void {
			var toolChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.TOOL_CHANGE)) {
				toolChangeEvent = new RadiateEvent(RadiateEvent.TOOL_CHANGE);
				toolChangeEvent.selectedItem = instance.target;
				toolChangeEvent.targets = instance.targets;
				toolChangeEvent.tool = value;
				dispatchEvent(toolChangeEvent);
			}
		}
		
		/**
		 * Dispatch target change event with a null target. 
		 * Target change to nothing.
		 * */
		public static function dispatchTargetClearEvent():void {
			var targetChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.TARGET_CHANGE)) {
				targetChangeEvent = new RadiateEvent(RadiateEvent.TARGET_CHANGE);
				dispatchEvent(targetChangeEvent);
			}
		}
		
		/**
		 * Dispatch property change event
		 * */
		public static function dispatchPropertyChangeEvent(localTarget:*, changes:Array, properties:Array, styles:Array, events:Array = null):void {
			if (importingDocument) return;
			var propertyChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROPERTY_CHANGED)) {
				propertyChangeEvent = new RadiateEvent(RadiateEvent.PROPERTY_CHANGED, false, false, localTarget);
				propertyChangeEvent.property = properties && properties.length ? properties[0] : null;
				propertyChangeEvent.properties = properties;
				propertyChangeEvent.styles = styles;
				propertyChangeEvent.events = events;
				propertyChangeEvent.propertiesAndStyles = com.flexcapacitor.utils.ArrayUtils.join(properties, styles);
				propertyChangeEvent.propertiesStylesEvents = com.flexcapacitor.utils.ArrayUtils.join(properties, styles, events);
				propertyChangeEvent.changes = changes;
				propertyChangeEvent.selectedItem = localTarget && localTarget is Array ? localTarget[0] : localTarget;
				propertyChangeEvent.targets = ArrayUtil.toArray(localTarget);
				dispatchEvent(propertyChangeEvent);
			}
		}
		
		/**
		 * Dispatch object selected event
		 * */
		public static function dispatchObjectSelectedEvent(target:*):void {
			var objectSelectedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.OBJECT_SELECTED)) {
				objectSelectedEvent = new RadiateEvent(RadiateEvent.OBJECT_SELECTED, false, false, target);
				dispatchEvent(objectSelectedEvent);
			}
		}
		
		/**
		 * Dispatch add items event
		 * */
		public static function dispatchAddEvent(target:*, changes:Array, properties:Array, multipleSelection:Boolean = false):void {
			if (importingDocument) return;
			var event:RadiateEvent;
			var numberOfChanges:int = changes ? changes.length : 0;
			
			if (hasEventListener(RadiateEvent.ADD_ITEM)) {
				event = new RadiateEvent(RadiateEvent.ADD_ITEM, false, false, target);
				event.properties = properties;
				event.changes = changes;
				event.multipleSelection = multipleSelection;
				event.selectedItem = target && target is Array ? target[0] : target;
				event.targets = ArrayUtil.toArray(target);
				
				for (var i:int;i<numberOfChanges;i++) {
					if (changes[i] is AddItems) {
						event.addItemsInstance = changes[i];
						event.moveItemsInstance = changes[i];
					}
				}
				
				dispatchEvent(event);
			}
		}
		
		/**
		 * Dispatch move items event
		 * */
		public static function dispatchMoveEvent(target:*, changes:Array, properties:Array, multipleSelection:Boolean = false):void {
			if (importingDocument) return;
			var moveEvent:RadiateEvent;
			var numOfChanges:int;
			
			if (hasEventListener(RadiateEvent.MOVE_ITEM)) {
				moveEvent = new RadiateEvent(RadiateEvent.MOVE_ITEM, false, false, target);
				moveEvent.properties = properties;
				moveEvent.changes = changes;
				moveEvent.multipleSelection = multipleSelection;
				moveEvent.selectedItem = target && target is Array ? target[0] : target;
				moveEvent.targets = ArrayUtil.toArray(target);
				numOfChanges = changes ? changes.length : 0;
				
				for (var i:int;i<numOfChanges;i++) {
					if (changes[i] is AddItems) {
						moveEvent.addItemsInstance = changes[i];
						moveEvent.moveItemsInstance = changes[i];
					}
				}
				
				dispatchEvent(moveEvent);
			}
		}
		
		/**
		 * Dispatch remove items event
		 * */
		public static function dispatchRemoveItemsEvent(target:*, changes:Array, properties:*):void {
			var removeEvent:RadiateEvent = new RadiateEvent(RadiateEvent.REMOVE_ITEM, false, false, target);
			var numOfChanges:int;
			
			if (hasEventListener(RadiateEvent.REMOVE_ITEM)) {
				removeEvent.changes = changes;
				removeEvent.properties = properties;
				removeEvent.selectedItem = target && target is Array ? target[0] : target;
				removeEvent.targets = ArrayUtil.toArray(target);
				
				numOfChanges = changes ? changes.length : 0;
				
				for (var i:int;i<numOfChanges;i++) {
					if (changes[i] is AddItems) {
						removeEvent.addItemsInstance = changes[i];
						removeEvent.moveItemsInstance = changes[i];
					}
				}
				
				dispatchEvent(removeEvent);
			}
		}
		
		/**
		 * Dispatch to invoke property edit event
		 * */
		public static function dispatchTargetPropertyEditEvent(target:Object, changes:Array, properties:Array, styles:Array, events:Array=null):void {
			var propertyEditEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROPERTY_EDIT)) {
				propertyEditEvent = new RadiateEvent(RadiateEvent.PROPERTY_EDIT, false, false, target);
				propertyEditEvent.changes = changes;
				propertyEditEvent.properties = properties;
				dispatchEvent(propertyEditEvent);
			}
		}
		
		/**
		 * Dispatch document change event
		 * */
		public static function dispatchDocumentChangeEvent(document:IDocument):void {
			var documentChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_CHANGE)) {
				documentChangeEvent = new RadiateEvent(RadiateEvent.DOCUMENT_CHANGE, false, false, document);
				dispatchEvent(documentChangeEvent);
			}
		}
		
		/**
		 * Dispatch document rename event
		 * */
		public static function dispatchDocumentRenameEvent(document:IDocument, name:String):void {
			var documentRenameEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_RENAME)) {
				documentRenameEvent = new RadiateEvent(RadiateEvent.DOCUMENT_RENAME, false, false, document);
				dispatchEvent(documentRenameEvent);
			}
		}
		
		/**
		 * Dispatch project rename event
		 * */
		public static function dispatchProjectRenameEvent(project:IProject, name:String):void {
			var projectRenameEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_RENAME)) {
				projectRenameEvent = new RadiateEvent(RadiateEvent.PROJECT_RENAME, false, false, project);
				dispatchEvent(projectRenameEvent);
			}
		}
		
		/**
		 * Dispatch documents set
		 * */
		public static function dispatchDocumentsSetEvent(documents:Array):void {
			var documentChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENTS_SET)) {
				documentChangeEvent = new RadiateEvent(RadiateEvent.DOCUMENTS_SET, false, false, documents);
				dispatchEvent(documentChangeEvent);
			}
		}
		
		/**
		 * Dispatch document opening event
		 * */
		public static function dispatchDocumentOpeningEvent(document:IDocument, isPreview:Boolean = false):Boolean {
			var documentOpeningEvent:RadiateEvent;
			var dispatched:Boolean;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_OPENING)) {
				documentOpeningEvent = new RadiateEvent(RadiateEvent.DOCUMENT_OPENING, false, true, document);
				dispatched = dispatchEvent(documentOpeningEvent);
			}
			
			return dispatched;
		}
		
		/**
		 * Dispatch document open event
		 * */
		public static function dispatchDocumentOpenEvent(document:IDocument):void {
			var documentOpenEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_OPEN)) {
				documentOpenEvent = new RadiateEvent(RadiateEvent.DOCUMENT_OPEN, false, false);
				documentOpenEvent.selectedItem = document;
				dispatchEvent(documentOpenEvent);
			}
		}
		
		/**
		 * Dispatch document closed event
		 * */
		public static function dispatchDocumentCloseEvent(document:IDocument, documentClosed:Boolean = true, previewClosed:Boolean = false):void {
			var documentOpenEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_CLOSE)) {
				documentOpenEvent = new RadiateEvent(RadiateEvent.DOCUMENT_CLOSE, false, false);
				documentOpenEvent.selectedItem = document;
				documentOpenEvent.previewClosed = previewClosed;
				documentOpenEvent.documentClosed = documentClosed;
				dispatchEvent(documentOpenEvent);
			}
		}
		
		/**
		 * Dispatch document removed event
		 * */
		public static function dispatchDocumentRemovedEvent(document:IDocument, successful:Boolean = true):void {
			var documentRemovedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_REMOVED)) {
				documentRemovedEvent = new RadiateEvent(RadiateEvent.DOCUMENT_REMOVED, false, false);
				documentRemovedEvent.successful = successful;
				documentRemovedEvent.selectedItem = document;
				dispatchEvent(documentRemovedEvent);
			}
		}
		
		/**
		 * Dispatch project saved event
		 * */
		public static function dispatchProjectSavedEvent(project:IProject):void {
			var projectSaveEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_SAVED)) {
				projectSaveEvent = new RadiateEvent(RadiateEvent.PROJECT_SAVED, false, false);
				projectSaveEvent.selectedItem = project;
				dispatchEvent(projectSaveEvent);
			}
		}
		
		/**
		 * Dispatch document save complete event
		 * */
		public static function dispatchDocumentSaveCompleteEvent(document:IDocument):void {
			var documentSaveAsCompleteEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_SAVE_COMPLETE)) {
				documentSaveAsCompleteEvent = new RadiateEvent(RadiateEvent.DOCUMENT_SAVE_COMPLETE, false, false, document);
				dispatchEvent(documentSaveAsCompleteEvent);
			}
		}
		
		/**
		 * Dispatch HTML preview uncaught exceptions
		 * */
		public static function dispatchExceptionEvent(event:Event):void {
			var uncaughtExceptionEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.UNCAUGHT_EXCEPTION_EVENT)) {
				uncaughtExceptionEvent = new RadiateEvent(RadiateEvent.UNCAUGHT_EXCEPTION_EVENT, false, false);
				uncaughtExceptionEvent.data = event;
				dispatchEvent(uncaughtExceptionEvent);
			}
		}
		
		/**
		 * Dispatch document not saved event
		 * */
		public static function dispatchDocumentSaveFaultEvent(document:IDocument):void {
			var documentSaveFaultEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_SAVE_FAULT)) {
				documentSaveFaultEvent = new RadiateEvent(RadiateEvent.DOCUMENT_SAVE_FAULT, false, false, document);
				dispatchEvent(documentSaveFaultEvent);
			}
		}
		
		/**
		 * Dispatch document save as cancel event
		 * */
		public static function dispatchDocumentSaveAsCancelEvent(document:IDocument):void {
			var documentSaveAsCancelEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_SAVE_AS_CANCEL)) {
				documentSaveAsCancelEvent = new RadiateEvent(RadiateEvent.DOCUMENT_SAVE_AS_CANCEL, false, false, document);
				dispatchEvent(documentSaveAsCancelEvent);
			}
		}
		
		/**
		 * Dispatch console value change event
		 * */
		public static function dispatchConsoleValueChangeEvent(value:String):void {
			var consoleValueChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.CONSOLE_VALUE_CHANGE)) {
				consoleValueChangeEvent = new RadiateEvent(RadiateEvent.CONSOLE_VALUE_CHANGE, false, false);
				consoleValueChangeEvent.data = value;
				dispatchEvent(consoleValueChangeEvent);
			}
		}
		
		/**
		 * Dispatch documentation change event
		 * */
		public static function dispatchDocumentationChangeEvent(url:String):void {
			var documentationChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENTATION_CHANGE)) {
				documentationChangeEvent = new RadiateEvent(RadiateEvent.DOCUMENTATION_CHANGE, false, false);
				documentationChangeEvent.data = url;
				dispatchEvent(documentationChangeEvent);
			}
		}
		
		/**
		 * Dispatch document add event
		 * */
		public static function dispatchDocumentAddedEvent(document:IDocument):void {
			var documentAddedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_ADDED)) {
				documentAddedEvent = new RadiateEvent(RadiateEvent.DOCUMENT_ADDED, false, false, document);
				dispatchEvent(documentAddedEvent);
			}
		}
		
		/**
		 * Dispatch document reverted event
		 * */
		public static function dispatchDocumentRevertedEvent(document:IDocument):void {
			var documentRevertedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_REVERTED)) {
				documentRevertedEvent = new RadiateEvent(RadiateEvent.DOCUMENT_REVERTED, false, false, document);
				dispatchEvent(documentRevertedEvent);
			}
		}
		
		/**
		 * Dispatch project closing event
		 * */
		public static function dispatchProjectClosingEvent(project:IProject):void {
			var projectClosingEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_CLOSING)) {
				projectClosingEvent = new RadiateEvent(RadiateEvent.PROJECT_CLOSING, false, false, project);
				dispatchEvent(projectClosingEvent);
			}
		}
		
		/**
		 * Dispatch project closed event
		 * */
		public static function dispatchProjectOpenedEvent(project:IProject):void {
			var projectOpenedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_OPENED)) {
				projectOpenedEvent = new RadiateEvent(RadiateEvent.PROJECT_OPENED, false, false, project);
				dispatchEvent(projectOpenedEvent);
			}
		}
		
		/**
		 * Dispatch project closed event
		 * */
		public static function dispatchProjectClosedEvent(project:IProject):void {
			var projectClosedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_CLOSED)) {
				projectClosedEvent = new RadiateEvent(RadiateEvent.PROJECT_CLOSED, false, false, project);
				dispatchEvent(projectClosedEvent);
			}
		}
		
		/**
		 * Dispatch project removed event
		 * */
		public static function dispatchProjectRemovedEvent(project:IProject):void {
			var projectRemovedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_REMOVED)) {
				projectRemovedEvent = new RadiateEvent(RadiateEvent.PROJECT_REMOVED, false, false, project);
				projectRemovedEvent.data = project;
				dispatchEvent(projectRemovedEvent);
			}
		}
		
		/**
		 * Dispatch project change event
		 * */
		public static function dispatchProjectChangeEvent(project:IProject, multipleSelection:Boolean = false):void {
			var projectChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_CHANGE)) {
				projectChangeEvent = new RadiateEvent(RadiateEvent.PROJECT_CHANGE, false, false, project);
				dispatchEvent(projectChangeEvent);
			}
		}
		
		/**
		 * Dispatch projects set event
		 * */
		public static function dispatchProjectsSetEvent(projects:Array, multipleSelection:Boolean = false):void {
			var projectChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECTS_SET)) {
				projectChangeEvent = new RadiateEvent(RadiateEvent.PROJECTS_SET, false, false, projects);
				dispatchEvent(projectChangeEvent);
			}
		}
		
		/**
		 * Dispatch project created event
		 * */
		public static function dispatchProjectAddedEvent(project:IProject):void {
			var projectCreatedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_ADDED)) {
				projectCreatedEvent = new RadiateEvent(RadiateEvent.PROJECT_ADDED, false, false, project);
				dispatchEvent(projectCreatedEvent);
			}
		}
		
		/**
		 * Dispatch project created event
		 * */
		public static function dispatchProjectCreatedEvent(project:IProject):void {
			var projectCreatedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_CREATED)) {
				projectCreatedEvent = new RadiateEvent(RadiateEvent.PROJECT_CREATED, false, false, project);
				dispatchEvent(projectCreatedEvent);
			}
		}
		
		/**
		 * Static method for addEventListener.
		 * We do this so that we can use static methods without 
		 * writing out Class.instance.addEventListener() elsewhere
		 * */
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, 
												priority:int = 0, useWeakReferences:Boolean = false):void {
			instance.addEventListener(type, listener, useCapture, priority, useWeakReferences);
		}
		
		/**
		 * Static method for removeEventListener.
		 * We do this so that we can use static methods without 
		 * writing out Class.instance.removeEventListener() elsewhere
		 * */
		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			instance.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * Static method for hasEventListener.
		 * We do this so that we can use static methods without writing out Class.instance.hasEventListener()
		 * */
		public static function hasEventListener(type:String):Boolean {
			return instance.hasEventListener(type);
		}
		
		/**
		 * Static method for dispatchEvent
		 * We do this so that we can use static methods without writing out Class.instance.dispatchEvent()
		 * */
		public static function dispatchEvent(event:Event):Boolean {
			return instance.dispatchEvent(event);
		}
		
		private static var lastErrorObject:Object;
		
		/**
		 * Catch uncaught errors
		 */
		public function uncaughtErrorHandler(event:UncaughtErrorEvent):void {
			event.preventDefault();
			
			//to capture the error message
			var errorMessage:String = new String();
			var errorObject:Object;
			var stack:String = getStackTrace(event.error);
			
			if (event) {
				errorObject = "error" in event ? event.error : null;
				
				if (errorObject is Error && "message" in errorObject) {
					errorMessage = Error(errorObject).message;
				}
				else if (errorObject is ErrorEvent && "text" in errorObject) {
					errorMessage = ErrorEvent(errorObject).text;
				}
				else if (errorObject) {
					errorMessage = errorObject.toString();
				}
				else {
					errorMessage = event.toString();
				}
				
			}
			
			if (event!=lastErrorObject) {
				lastErrorObject = event;
				Radiate.error(errorMessage, event);
			}
		}
		
		/**
		 * Traces an fatal message
		 * */
		public static function fatal(message:String, event:* = null, sender:Object = null, ...Arguments):void {
			var issueData:IssueData;
			var errorObject:Object;
			var type:String;
			var errorID:String;
			var errorData:ErrorData;
			var name:String;
			var className:String;
			var stackTrace:String;
			
			className = sender ? ClassUtils.getClassName(sender) : "";
			
			
			if (event && "error" in event) {
				errorObject = event.error;
				message = "message" in errorObject ? errorObject.message : "";
				message = "text" in errorObject ? errorObject.text : message;
				type = "type" in errorObject ? errorObject.type : "";
				errorID = "errorID" in errorObject ? errorObject.errorID : "";
				name = "name" in errorObject ? errorObject.name : "";
			}
			
			stackTrace = getStackTrace(event);
			
			if (enableDiagnosticLogs) {
				errorData = addLogData(message, LogEventLevel.ERROR, className, Arguments) as ErrorData;
				
				if (errorData) {
					if (message=="" || message==null) {
						errorData.description = message;
					}
					errorData.type = type;
					errorData.errorID = errorID;
					errorData.message = message;
					errorData.name = name;
				}
			}
			
			log.error(message, Arguments);
			
			
			playMessage(message, LogEventLevel.FATAL);
		}
		
		/**
		 * Traces the MXML import errors
		 * */
		public static function outputMXMLErrors(title:String, errors:Array):void {
			var errorData:ErrorData;
			var message:String;
			
			title = title!=null && title!="" ? title : "MXML Import Errors";
			
			message = title;
			message += "\n";
			
			for (var i:int = 0; i < errors.length; i++) {
				errorData = errors[i] as ErrorData;
				
				if (errorData) {
					message += " " + errorData.label + "\n " + errorData.description + "\n\n";
				}
				
			}
			
			log.error(message);
			
			playMessage(title + " - Check console for more details", LogEventLevel.WARN);
		}
		
		/**
		 * Traces an error message.
		 * 
		 * Getting three error messages. 
		 * One from Radii8Desktop, one from here Radiate.as, and one from DocumentContainer
		 * */
		public static function error(message:String, event:Object = null, sender:String = null, ...Arguments):void {
			var errorData:ErrorData;
			var issueData:IssueData;
			var errorObject:Object;
			var errorID:String;
			var type:String;
			var name:String;
			var className:String;
			var stackTrace:String;
			
			if (preventDefaultMessages) return;
			
			className = sender ? ClassUtils.getClassName(sender) : "";
			
			if (message=="") {
				
			}
			
			if (event && "error" in event) {
				errorObject = event.error;
			}
			else if (event is Error) {
				errorObject = event;
			}
			
			lastErrorObject = event;
			
			if (errorObject) {
				message = "message" in errorObject ? errorObject.message : "";
				message = "text" in errorObject ? errorObject.text : message;
				type = "type" in errorObject ? errorObject.type : "";
				errorID = "errorID" in errorObject ? errorObject.errorID : "";
				name = "name" in errorObject ? errorObject.name : "";
			}
			
			stackTrace = getStackTrace(event);
			
			if (enableDiagnosticLogs) {
				issueData = addLogData(message, LogEventLevel.ERROR, className, Arguments);
				//errorData = addLogData(message, LogEventLevel.ERROR, className, Arguments);
				
				if (issueData is ErrorData) {
					errorData = ErrorData(issueData);
					
					if (message=="" || message==null) {
						ErrorData(errorData).description = message;
					}
					errorData.type = type;
					errorData.errorID = errorID;
					errorData.message = message;
					errorData.name = name;
					errorData.stackTrace = stackTrace;
				}
			}
			
			log.error(message, Arguments);
			
			playMessage(message, LogEventLevel.ERROR);
		}
		
		/**
		 * Traces an warning message
		 * */
		public static function warn(message:String, sender:Object = null, ...Arguments):void {
			var className:String;
			
			if (preventDefaultMessages) return;
			
			className = sender ? ClassUtils.getClassName(sender) : "";
			
			if (className=="") {
				//var object:Object = warn.arguments.caller;
			}
			
			log.warn(message, Arguments);
			
			if (enableDiagnosticLogs) {
				addLogData(message, LogEventLevel.WARN, className, Arguments);
			}
			
			playMessage(message, LogEventLevel.WARN);
		}
		
		/**
		 * Traces an info message
		 * */
		public static function info(message:String, sender:Object = null, ...Arguments):void {
			var className:String;
			
			if (preventDefaultMessages) return;
			
			className = sender ? ClassUtils.getClassName(sender) : "";
			
			log.info(message, Arguments);
			
			if (enableDiagnosticLogs) {
				addLogData(message, LogEventLevel.INFO, className, Arguments);
			}
			
			playMessage(message, LogEventLevel.INFO);
		}
		
		/**
		 * Traces an debug message
		 * */
		public static function debug(message:String, sender:Object = null, ...Arguments):void {
			var className:String;
			
			if (preventDefaultMessages) return;
			
			className = sender ? ClassUtils.getClassName(sender) : "";

			log.debug(message, Arguments);
			
			if (enableDiagnosticLogs) {
				addLogData(message, LogEventLevel.DEBUG, className, Arguments);
			}
			
			playMessage(message, LogEventLevel.DEBUG);
		}
		
		/**
		 * Adds a new log item for diagnostics and to let user go back and read messages
		 * */
		public static function addLogData(message:String, level:int = 4, className:String = null, arguments:Array = null):IssueData {
			var issue:IssueData;
			
			if (level == LogEventLevel.ERROR || level == LogEventLevel.FATAL) {
				issue = new ErrorData();
			}
			else if (level == LogEventLevel.WARN) {
				issue = new WarningData();
			}
			else if (level == LogEventLevel.DEBUG || level==LogEventLevel.INFO || level==LogEventLevel.ALL) {
				issue = new IssueData();
			}
			else {
				issue = new IssueData();
			}
			
			issue.description = message;
			issue.level = level;
			issue.className = className;
			logsCollection.addItem(issue);
			
			
			return issue;
		}
		
		/**
		 * Get the stack trace from an error. Stack traces are available from 11.5 on
		 * or possibly earlier if you set -compiler.verbose-stacktraces=true
		 * */
		protected static function getStackTrace(error:Object, removeLines:Boolean = true):String {
			var value:String;
			var stackTrace:Array;
			
			if (error==null) {
				error = new Error();
			}
			else if ("error" in error) {
				error = error.error;
			}
			
			if ("getStackTrace" in error) {
				value = error.getStackTrace();
				value = value.replace(/\t/, "");
				if (removeLines) {
					value = value.replace(/\[.*(:\d+)\]/, "$1");
					value = value.replace(/\[.*\]/g, "");
					value = value.replace(/.*?::/g, "");
				}
				stackTrace = value.split("\n");
				//stackTrace.shift();
				//stackTrace.shift();
				//stackTrace.shift();
				return stackTrace.join("\n");
			}
			
			return null;
		}
		
		/**
		 * Keep track of error messages
		 * */
		public static var logsCollection:ArrayCollection = new ArrayCollection();
		public static var logErrorBackgroundColor:uint;
		public static var logErrorColor:uint;
		public static var enableDiagnosticLogs:Boolean = true;
		
		/**
		 * Plays an animation for different log messages. 
		 * Uses the log event levels for different message types,
		 * LogEventLevel.FATAL, LogEventLevel.ERROR, etc
		 * We do not show debug messages. Check the logsCollection or ConsoleLogInspector.
		 * */
		public static function playMessage(message:String, level:int=0):void {
			if (showMessageAnimation==null) return; // UI not created yet
			
			var borderContainer:IStyleClient = showMessageAnimation.target as IStyleClient;
			
			if (level==LogEventLevel.FATAL) {
				borderContainer.setStyle("backgroundColor", "red");
				borderContainer.setStyle("color", "white");
			}
			if (level==LogEventLevel.ERROR) {
				borderContainer.setStyle("backgroundColor", "red");
				borderContainer.setStyle("color", "white");
			}
			else if (level==LogEventLevel.WARN) {
				borderContainer.setStyle("backgroundColor", "yellow");
				borderContainer.setStyle("color", "black");
			}
			else if (level==LogEventLevel.INFO) {
				borderContainer.setStyle("backgroundColor", "blue");
				borderContainer.setStyle("color", "white");
			}
			
			showMessageLabel.text = message;
			
			if (showMessageAnimation.isPlaying) {
				showMessageAnimation.end();
			}
			
			showMessageAnimation.play();
		}
		
		/**
		 * Method to write straight to the console. Does not log events since
		 * it is the logger helping to view previous logs. 
		 * */
		public static function logToConsole(message:String):void
		{
			log.info(message);
		}
		
		/**
		 * Updates the selection if the selection tool is selected
		 * */
		public static function updateSelection(target:Object = null):void {
			if (DocumentManager.toolLayer && Radiate.selectedTool is Selection) {
				Selection(Radiate.selectedTool).updateSelection(target);
			}
		}
		
		/**
		 * Gets the module factory for the specified object or 
		 * selected document if object is null.
		 * */
		public static function getModuleFactory(object:Object):IFlexModuleFactory {
			
			if (object is UIComponent) {
				return UIComponent(object).moduleFactory;
			}
			
			if (object==null || object is GraphicElement) {
				if (selectedDocument && selectedDocument.instance) {
					return selectedDocument.instance.moduleFactory;
				}
			}
			
			return null;
		}
		
		//----------------------------------
		//  instance
		//----------------------------------
		private static var _instance:Radiate;
		
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
	}
}

class SINGLEDOUBLE{}