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
	import com.durej.PSDParser.PSDLayer;
	import com.durej.PSDParser.PSDParser;
	import com.flexcapacitor.components.DocumentContainer;
	import com.flexcapacitor.components.IDocumentContainer;
	import com.flexcapacitor.controls.ColorPicker;
	import com.flexcapacitor.controls.Hyperlink;
	import com.flexcapacitor.controls.RichTextEditorBar;
	import com.flexcapacitor.controls.RichTextEditorBarCallout;
	import com.flexcapacitor.effects.core.CallMethod;
	import com.flexcapacitor.effects.core.PlayerType;
	import com.flexcapacitor.effects.file.LoadFile;
	import com.flexcapacitor.effects.popup.OpenPopUp;
	import com.flexcapacitor.events.RadiateEvent;
	import com.flexcapacitor.formatters.HTMLFormatterTLF;
	import com.flexcapacitor.logging.RadiateLogTarget;
	import com.flexcapacitor.managers.CodeManager;
	import com.flexcapacitor.managers.HistoryEffect;
	import com.flexcapacitor.managers.HistoryManager;
	import com.flexcapacitor.managers.ServicesManager;
	import com.flexcapacitor.model.AttachmentData;
	import com.flexcapacitor.model.Device;
	import com.flexcapacitor.model.Document;
	import com.flexcapacitor.model.DocumentData;
	import com.flexcapacitor.model.DocumentDescription;
	import com.flexcapacitor.model.ErrorData;
	import com.flexcapacitor.model.EventMetaData;
	import com.flexcapacitor.model.ExportOptions;
	import com.flexcapacitor.model.FileInfo;
	import com.flexcapacitor.model.HTMLExportOptions;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.IDocumentData;
	import com.flexcapacitor.model.IDocumentMetaData;
	import com.flexcapacitor.model.IProject;
	import com.flexcapacitor.model.IProjectData;
	import com.flexcapacitor.model.ISavable;
	import com.flexcapacitor.model.ImageData;
	import com.flexcapacitor.model.InspectableClass;
	import com.flexcapacitor.model.InspectorData;
	import com.flexcapacitor.model.IssueData;
	import com.flexcapacitor.model.MenuItem;
	import com.flexcapacitor.model.MetaData;
	import com.flexcapacitor.model.Project;
	import com.flexcapacitor.model.SaveResultsEvent;
	import com.flexcapacitor.model.SavedData;
	import com.flexcapacitor.model.Settings;
	import com.flexcapacitor.model.SourceData;
	import com.flexcapacitor.model.StyleMetaData;
	import com.flexcapacitor.model.TranscoderDescription;
	import com.flexcapacitor.model.ValuesObject;
	import com.flexcapacitor.model.WarningData;
	import com.flexcapacitor.performance.PerformanceMeter;
	import com.flexcapacitor.services.IServiceEvent;
	import com.flexcapacitor.services.WPAttachmentService;
	import com.flexcapacitor.services.WPService;
	import com.flexcapacitor.states.AddItems;
	import com.flexcapacitor.tools.ITool;
	import com.flexcapacitor.tools.Selection;
	import com.flexcapacitor.utils.ArrayUtils;
	import com.flexcapacitor.utils.Base64;
	import com.flexcapacitor.utils.ClassUtils;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.DocumentTranscoder;
	import com.flexcapacitor.utils.FontUtils;
	import com.flexcapacitor.utils.HTMLUtils;
	import com.flexcapacitor.utils.MXMLDocumentConstants;
	import com.flexcapacitor.utils.MXMLDocumentImporter;
	import com.flexcapacitor.utils.PersistentStorage;
	import com.flexcapacitor.utils.SharedObjectUtils;
	import com.flexcapacitor.utils.TextFieldHTMLExporter2;
	import com.flexcapacitor.utils.TypeUtils;
	import com.flexcapacitor.utils.XMLUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDefinition;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	import com.flexcapacitor.views.IInspector;
	import com.flexcapacitor.views.MainView;
	import com.flexcapacitor.views.Remote;
	import com.flexcapacitor.views.windows.ImportWindow;
	import com.google.code.flexiframe.IFrame;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.globalization.DateTimeStyle;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.ui.Mouse;
	import flash.ui.MouseCursorData;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.containers.Canvas;
	import mx.containers.Grid;
	import mx.containers.GridItem;
	import mx.containers.GridRow;
	import mx.containers.TabNavigator;
	import mx.controls.Alert;
	import mx.controls.ColorPicker;
	import mx.controls.LinkButton;
	import mx.core.ClassFactory;
	import mx.core.Container;
	import mx.core.DeferredInstanceFromFunction;
	import mx.core.DragSource;
	import mx.core.IFlexModuleFactory;
	import mx.core.IInvalidating;
	import mx.core.IUIComponent;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.effects.IEffect;
	import mx.effects.Sequence;
	import mx.effects.effectClasses.PropertyChanges;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.graphics.ImageSnapshot;
	import mx.graphics.SolidColor;
	import mx.logging.AbstractTarget;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.managers.ISystemManager;
	import mx.managers.LayoutManager;
	import mx.managers.SystemManagerGlobals;
	import mx.printing.FlexPrintJob;
	import mx.printing.FlexPrintJobScaleType;
	import mx.styles.IStyleClient;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	import mx.utils.UIDUtil;
	
	import spark.collections.Sort;
	import spark.collections.SortField;
	import spark.components.Application;
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.ComboBox;
	import spark.components.ContentBackgroundAppearance;
	import spark.components.DropDownList;
	import spark.components.Grid;
	import spark.components.Image;
	import spark.components.Label;
	import spark.components.NavigatorContent;
	import spark.components.NumericStepper;
	import spark.components.RichEditableText;
	import spark.components.RichText;
	import spark.components.Scroller;
	import spark.components.SkinnableContainer;
	import spark.components.supportClasses.DropDownListBase;
	import spark.components.supportClasses.GroupBase;
	import spark.components.supportClasses.SkinnableTextBase;
	import spark.components.supportClasses.SliderBase;
	import spark.components.supportClasses.TextBase;
	import spark.components.supportClasses.ToggleButtonBase;
	import spark.core.ContentCache;
	import spark.core.IGraphicElement;
	import spark.core.IViewport;
	import spark.events.PopUpEvent;
	import spark.events.TextOperationEvent;
	import spark.formatters.DateTimeFormatter;
	import spark.layouts.BasicLayout;
	import spark.primitives.BitmapImage;
	import spark.primitives.Rect;
	import spark.primitives.supportClasses.GraphicElement;
	import spark.skins.spark.DefaultGridItemRenderer;
	import spark.utils.TextFlowUtil;
	
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.ITextImporter;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.IConfiguration;
	import flashx.textLayout.elements.TextFlow;
	
	import org.as3commons.lang.DictionaryUtils;
	import org.as3commons.lang.ObjectUtils;
	
	use namespace mx_internal;
	
	/**
	 * Dispatched on history change
	 * */
	[Event(name="historyChange", type="com.flexcapacitor.events.RadiateEvent")]
	
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
	 * 
	 * 
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
		
		public static const USER_STORE:String = "userStore";
		public static const TRANSFER_STORE:String = "transferStore";
		public static const RELEASE_DIRECTORY_STORE:String = "releaseDirectoryStore";
		
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
		
		private static var historyManager:HistoryManager;
		
		private static var serviceManager:ServicesManager;
		
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
		 * Service to delete attachments
		 * */
		public var deleteAttachmentsService:WPService;
		
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
		 * When deleting a document this is the id of the project it was part of
		 * since you need to save the project after a delete.
		 * */
		[Bindable]
		public var deleteDocumentProjectId:int;
		
		/**
		 * When deleting a document 
		 * you need to save the project after. Set this to true to save 
		 * after results are in from document delete call.
		 * */
		[Bindable]
		public var saveProjectAfterDelete:Boolean;
		
		/**
		 * Set to true when deleting an attachment
		 * */
		[Bindable]
		public var deleteAttachmentInProgress:Boolean;
		
		/**
		 * Set to true when deleting attachments
		 * */
		[Bindable]
		public var deleteAttachmentsInProgress:Boolean;
		
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
		 * Application menu
		 * */
		[Bindable]
		public var applicationMenu:Object;
		
		/**
		 * Application window menu
		 * */
		[Bindable]
		public var applicationWindowMenu:Object;
		
		/**
		 * Can user connect to the service
		 * */
		[Bindable]
		public var isUserConnected:Boolean;
		
		/**
		 * Is the user online
		 * */
		[Bindable]
		public var isUserOnline:Boolean;
		
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
		 * User name
		 * */
		[Bindable]
		public var username:String;
		
		/**
		 * Home page id
		 * */
		[Bindable]
		public var projectHomePageID:int = -1;
		
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
		 * Last save date formatted
		 * */
		[Bindable]
		public var lastSaveDateFormatted:String;
		
		/**
		 * Last save date 
		 * */
		[Bindable]
		public var lastSaveDate:Date;
		
		/**
		 * Last save date difference
		 * */
		[Bindable]
		public var lastSaveDateDifference:String;
		
		/**
		 * Last clipboard action. Either cut or copy;
		 * */
		public var lastClipboardAction:String;
		
		/**
		 * Cut data
		 * */
		public var cutData:Object;
		
		/**
		 * Copy data
		 * */
		public var copiedData:Object;
		
		/**
		 * Reference to the document of the cut or copied data
		 * */
		public var copiedDataDocument:Object;
		
		/**
		 * Reference to the source of the copied or cut data. Useful if reference to copied
		 * item is gone. In other words, user copied an item from their document
		 * and then deleted the document. They could still paste it.
		 * */
		public var copiedDataSource:String;
		
		/**
		 * The different statuses a document can have
		 * Based on WordPress posts status, "draft", "publish", etc
		 * */
		[Bindable]
		public static var documentStatuses:ArrayCollection = new ArrayCollection();
		
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
		 * Interval to check to save project. Default 2 minutes.
		 * */
		public var autoSaveInterval:int = 120000;
		
		/**
		 * Effect to auto save
		 * */
		public var autoSaveEffect:CallMethod;
		
		/**
		 * Handle auto saving 
		 * */
		public function autoSaveHandler():void {
			var numberOfAssets:int;
			var numberOfProjects:int;
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
			numberOfProjects = projects.length;
			for (i=0;i<numberOfProjects;i++) {
				iDocumentData = projects[i] as IDocumentData;
				//if (iDocumentData.isChanged && !iDocumentData.saveInProgress && iDocumentData.isOpen) {
				if (!iDocumentData.saveInProgress && iDocumentData.isOpen) {
					iDocumentData.save();
				}
			}
			
			// do not autosave now
			return;
			
			if (uploadAttachmentInProgress) {
				return;
			}
			
			// save attachments
			numberOfAssets = assets.length;
			
			for (i=0;i<numberOfAssets;i++) {
				iAttachmentData = assets[i] as ImageData;
				
				if (iAttachmentData) {
					imageData = iAttachmentData as ImageData;
					
					if (!imageData.saveInProgress && imageData.id==null) {
						//imageData.save();
						if (imageData.byteArray==null) {
							uploadAttachment(imageData.bitmapData, selectedProject.id, imageData.name, null, imageData.contentType);
						}
						else {
							uploadAttachment(imageData.byteArray, selectedProject.id, imageData.name, null, imageData.contentType);
						}
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
		
		/**
		 * Version number
		 * */
		[Bindable]
		public var versionNumber:String;
		
		/**
		 * Reference to the application
		 */
		[Bindable]
		public static var application:Application;
		
		/**
		 * Reference to the application main view
		 */
		[Bindable]
		public static var mainView:MainView;
		
		/**
		 * Reference to the application main layout
		 */
		[Bindable]
		public static var remoteView:Remote;
		
		/**
		 * Reference to the application main view importPopUp
		 */
		[Bindable]
		public static var openImportPopUp:OpenPopUp;
		
		//----------------------------------
		//
		//  Events Management
		// 
		//----------------------------------
		
		/**
		 * Dispatch example projects list received results event
		 * */
		public function dispatchGetExampleProjectsListResultsEvent(data:Object):void {
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
		public function dispatchGetProjectsListResultsEvent(data:Object):void {
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
		public function dispatchPrintCancelledEvent(data:Object, printJob:FlexPrintJob):void {
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
		public function dispatchPrintCompleteEvent(data:Object, printJob:FlexPrintJob):void {
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
		public function dispatchAttachmentsResultsEvent(successful:Boolean, attachments:Array):void {
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
		public function dispatchUploadAttachmentResultsEvent(successful:Boolean, attachments:Array, data:Object, error:Object = null):void {
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
		public function dispatchFeedbackResultsEvent(successful:Boolean, data:Object):void {
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
		public function dispatchLoginResultsEvent(successful:Boolean, data:Object):void {
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
		public function dispatchLogoutResultsEvent(successful:Boolean, data:Object):void {
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
		public function dispatchRegisterResultsEvent(successful:Boolean, data:Object):void {
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
		public function dispatchChangePasswordResultsEvent(successful:Boolean, data:Object):void {
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
		public function dispatchLostPasswordResultsEvent(successful:Boolean, data:Object):void {
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
		public function dispatchProjectDeletedEvent(successful:Boolean, data:Object):void {
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
		public function dispatchDocumentDeletedEvent(successful:Boolean, data:Object):void {
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
		public function dispatchAttachmentsDeletedEvent(successful:Boolean, data:Object):void {
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
		public function dispatchComponentDefinitionAddedEvent(data:ComponentDefinition):void {
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
		public function dispatchAssetAddedEvent(data:Object):void {
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
		public function dispatchAssetLoadedEvent(asset:Object, document:IDocument, resized:Boolean, successful:Boolean = true):void {
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
		public function dispatchAssetRemovedEvent(data:IDocumentData, successful:Boolean = true):void {
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
		public function dispatchAssetsRemovedEvent(attachments:Array, successful:Boolean = true):void {
			var assetRemovedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.ASSETS_REMOVED)) {
				assetRemovedEvent = new RadiateEvent(RadiateEvent.ASSETS_REMOVED);
				assetRemovedEvent.data = attachments;
				dispatchEvent(assetRemovedEvent);
			}
		}
		
		public static var SET_TARGET_TEST:String = "setTargetTest";
		/**
		 * Dispatch target change event
		 * */
		public function dispatchTargetChangeEvent(target:*, multipleSelection:Boolean = false):void {
			if (importingDocument) return;
			var targetChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.TARGET_CHANGE)) {
				targetChangeEvent = new RadiateEvent(RadiateEvent.TARGET_CHANGE, false, false, target);
				targetChangeEvent.selectedItem = target && target is Array ? target[0] : target;
				targetChangeEvent.targets = ArrayUtil.toArray(target);
				PerformanceMeter.start(SET_TARGET_TEST, true, false);
				dispatchEvent(targetChangeEvent);
				PerformanceMeter.stop(SET_TARGET_TEST, false);
			}
		}
		
		/**
		 * Dispatch a history change event
		 * */
		public function dispatchHistoryChangeEvent(document:IDocument, newIndex:int, oldIndex:int):void {
			var event:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.HISTORY_CHANGE)) {
				event = new RadiateEvent(RadiateEvent.HISTORY_CHANGE);
				event.newIndex = newIndex;
				event.oldIndex = oldIndex;
				event.historyEvent = HistoryManager.getHistoryEventAtIndex(document, newIndex);
				dispatchEvent(event);
			}
		}
		
		/**
		 * Dispatch scale change event
		 * */
		public function dispatchScaleChangeEvent(target:*, scaleX:Number = NaN, scaleY:Number = NaN):void {
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
		public function dispatchDocumentSizeChangeEvent(target:*):void {
			var sizeChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_SIZE_CHANGE)) {
				sizeChangeEvent = new RadiateEvent(RadiateEvent.DOCUMENT_SIZE_CHANGE, false, false, target);
				dispatchEvent(sizeChangeEvent);
			}
		}
		
		/**
		 * Dispatch preview event
		 * */
		public function dispatchPreviewEvent(sourceData:SourceData, type:String):void {
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
		public function dispatchCodeUpdatedEvent(sourceData:SourceData, type:String, openInWindow:Boolean = false):void {
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
		public function dispatchColorSelectedEvent(color:uint, invalid:Boolean = false):void {
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
		public function dispatchCanvasChangeEvent(canvas:*, canvasBackgroundParent:*, scroller:Scroller):void {
			var targetChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.CANVAS_CHANGE)) {
				targetChangeEvent = new RadiateEvent(RadiateEvent.CANVAS_CHANGE);
				dispatchEvent(targetChangeEvent);
			}
		}
		
		/**
		 * Dispatch tool change event
		 * */
		public function dispatchToolChangeEvent(value:ITool):void {
			var toolChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.TOOL_CHANGE)) {
				toolChangeEvent = new RadiateEvent(RadiateEvent.TOOL_CHANGE);
				toolChangeEvent.selectedItem = target && target is Array ? target[0] : target;
				toolChangeEvent.targets = targets;
				toolChangeEvent.tool = value;
				dispatchEvent(toolChangeEvent);
			}
		}
		
		/**
		 * Dispatch target change event with a null target. 
		 * Target change to nothing.
		 * */
		public function dispatchTargetClearEvent():void {
			var targetChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.TARGET_CHANGE)) {
				targetChangeEvent = new RadiateEvent(RadiateEvent.TARGET_CHANGE);
				dispatchEvent(targetChangeEvent);
			}
		}
		
		/**
		 * Dispatch property change event
		 * */
		public function dispatchPropertyChangeEvent(localTarget:*, changes:Array, properties:Array, styles:Array, events:Array = null):void {
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
		public function dispatchObjectSelectedEvent(target:*):void {
			var objectSelectedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.OBJECT_SELECTED)) {
				objectSelectedEvent = new RadiateEvent(RadiateEvent.OBJECT_SELECTED, false, false, target);
				dispatchEvent(objectSelectedEvent);
			}
		}
		
		/**
		 * Dispatch add items event
		 * */
		public function dispatchAddEvent(target:*, changes:Array, properties:Array, multipleSelection:Boolean = false):void {
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
		public function dispatchMoveEvent(target:*, changes:Array, properties:Array, multipleSelection:Boolean = false):void {
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
		public function dispatchRemoveItemsEvent(target:*, changes:Array, properties:*):void {
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
		public function dispatchTargetPropertyEditEvent(target:Object, changes:Array, properties:Array, styles:Array, events:Array=null):void {
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
		public function dispatchDocumentChangeEvent(document:IDocument):void {
			var documentChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_CHANGE)) {
				documentChangeEvent = new RadiateEvent(RadiateEvent.DOCUMENT_CHANGE, false, false, document);
				dispatchEvent(documentChangeEvent);
			}
		}
		
		/**
		 * Dispatch document rename event
		 * */
		public function dispatchDocumentRenameEvent(document:IDocument, name:String):void {
			var documentRenameEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_RENAME)) {
				documentRenameEvent = new RadiateEvent(RadiateEvent.DOCUMENT_RENAME, false, false, document);
				dispatchEvent(documentRenameEvent);
			}
		}
		
		/**
		 * Dispatch project rename event
		 * */
		public function dispatchProjectRenameEvent(project:IProject, name:String):void {
			var projectRenameEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_RENAME)) {
				projectRenameEvent = new RadiateEvent(RadiateEvent.PROJECT_RENAME, false, false, project);
				dispatchEvent(projectRenameEvent);
			}
		}
		
		/**
		 * Dispatch documents set
		 * */
		public function dispatchDocumentsSetEvent(documents:Array):void {
			var documentChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENTS_SET)) {
				documentChangeEvent = new RadiateEvent(RadiateEvent.DOCUMENTS_SET, false, false, documents);
				dispatchEvent(documentChangeEvent);
			}
		}
		
		/**
		 * Dispatch document opening event
		 * */
		public function dispatchDocumentOpeningEvent(document:IDocument, isPreview:Boolean = false):Boolean {
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
		public function dispatchDocumentOpenEvent(document:IDocument):void {
			var documentOpenEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_OPEN)) {
				documentOpenEvent = new RadiateEvent(RadiateEvent.DOCUMENT_OPEN, false, false);
				documentOpenEvent.selectedItem = document;
				dispatchEvent(documentOpenEvent);
			}
		}
		
		/**
		 * Dispatch document removed event
		 * */
		public function dispatchDocumentRemovedEvent(document:IDocument, successful:Boolean = true):void {
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
		public function dispatchProjectSavedEvent(project:IProject):void {
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
		public function dispatchDocumentSaveCompleteEvent(document:IDocument):void {
			var documentSaveAsCompleteEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_SAVE_COMPLETE)) {
				documentSaveAsCompleteEvent = new RadiateEvent(RadiateEvent.DOCUMENT_SAVE_COMPLETE, false, false, document);
				dispatchEvent(documentSaveAsCompleteEvent);
			}
		}
		
		/**
		 * Dispatch HTML preview uncaught exceptions
		 * */
		public function dispatchExceptionEvent(event:Event):void {
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
		public function dispatchDocumentSaveFaultEvent(document:IDocument):void {
			var documentSaveFaultEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_SAVE_FAULT)) {
				documentSaveFaultEvent = new RadiateEvent(RadiateEvent.DOCUMENT_SAVE_FAULT, false, false, document);
				dispatchEvent(documentSaveFaultEvent);
			}
		}
		
		/**
		 * Dispatch document save as cancel event
		 * */
		public function dispatchDocumentSaveAsCancelEvent(document:IDocument):void {
			var documentSaveAsCancelEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_SAVE_AS_CANCEL)) {
				documentSaveAsCancelEvent = new RadiateEvent(RadiateEvent.DOCUMENT_SAVE_AS_CANCEL, false, false, document);
				dispatchEvent(documentSaveAsCancelEvent);
			}
		}
		
		/**
		 * Dispatch console value change event
		 * */
		public function dispatchConsoleValueChangeEvent(value:String):void {
			var documentationChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.CONSOLE_VALUE_CHANGE)) {
				documentationChangeEvent = new RadiateEvent(RadiateEvent.CONSOLE_VALUE_CHANGE, false, false);
				documentationChangeEvent.data = value;
				dispatchEvent(documentationChangeEvent);
			}
		}
		
		/**
		 * Dispatch documentation change event
		 * */
		public function dispatchDocumentationChangeEvent(url:String):void {
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
		public function dispatchDocumentAddedEvent(document:IDocument):void {
			var documentAddedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_ADDED)) {
				documentAddedEvent = new RadiateEvent(RadiateEvent.DOCUMENT_ADDED, false, false, document);
				dispatchEvent(documentAddedEvent);
			}
		}
		
		/**
		 * Dispatch document reverted event
		 * */
		public function dispatchDocumentRevertedEvent(document:IDocument):void {
			var documentRevertedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.DOCUMENT_REVERTED)) {
				documentRevertedEvent = new RadiateEvent(RadiateEvent.DOCUMENT_REVERTED, false, false, document);
				dispatchEvent(documentRevertedEvent);
			}
		}
		
		/**
		 * Dispatch project closing event
		 * */
		public function dispatchProjectClosingEvent(project:IProject):void {
			var projectClosingEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_CLOSING)) {
				projectClosingEvent = new RadiateEvent(RadiateEvent.PROJECT_CLOSING, false, false, project);
				dispatchEvent(projectClosingEvent);
			}
		}
		
		/**
		 * Dispatch project closed event
		 * */
		public function dispatchProjectOpenedEvent(project:IProject):void {
			var projectOpenedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_OPENED)) {
				projectOpenedEvent = new RadiateEvent(RadiateEvent.PROJECT_OPENED, false, false, project);
				dispatchEvent(projectOpenedEvent);
			}
		}
		
		/**
		 * Dispatch project closed event
		 * */
		public function dispatchProjectClosedEvent(project:IProject):void {
			var projectClosedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_CLOSED)) {
				projectClosedEvent = new RadiateEvent(RadiateEvent.PROJECT_CLOSED, false, false, project);
				dispatchEvent(projectClosedEvent);
			}
		}
		
		/**
		 * Dispatch project removed event
		 * */
		public function dispatchProjectRemovedEvent(project:IProject):void {
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
		public function dispatchProjectChangeEvent(project:IProject, multipleSelection:Boolean = false):void {
			var projectChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_CHANGE)) {
				projectChangeEvent = new RadiateEvent(RadiateEvent.PROJECT_CHANGE, false, false, project);
				dispatchEvent(projectChangeEvent);
			}
		}
		
		/**
		 * Dispatch projects set event
		 * */
		public function dispatchProjectsSetEvent(projects:Array, multipleSelection:Boolean = false):void {
			var projectChangeEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECTS_SET)) {
				projectChangeEvent = new RadiateEvent(RadiateEvent.PROJECTS_SET, false, false, projects);
				dispatchEvent(projectChangeEvent);
			}
		}
		
		/**
		 * Dispatch project created event
		 * */
		public function dispatchProjectAddedEvent(project:IProject):void {
			var projectCreatedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_ADDED)) {
				projectCreatedEvent = new RadiateEvent(RadiateEvent.PROJECT_ADDED, false, false, project);
				dispatchEvent(projectCreatedEvent);
			}
		}
		
		/**
		 * Dispatch project created event
		 * */
		public function dispatchProjectCreatedEvent(project:IProject):void {
			var projectCreatedEvent:RadiateEvent;
			
			if (hasEventListener(RadiateEvent.PROJECT_CREATED)) {
				projectCreatedEvent = new RadiateEvent(RadiateEvent.PROJECT_CREATED, false, false, project);
				dispatchEvent(projectCreatedEvent);
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
			var componentsXML:XML 	= new XML(new Radii8LibrarySparkAssets.componentsManifestDefaults());
			var sparkXML:XML	 	= new XML(new Radii8LibraryTranscodersAssets.sparkManifest());
			var mxmlXML:XML	 		= new XML(new Radii8LibraryTranscodersAssets.mxmlManifest());
			var toolsXML:XML 		= new XML(new Radii8LibraryToolAssets.toolsManifestDefaults());
			var inspectorsXML:XML 	= new XML(new Radii8LibraryInspectorAssets.inspectorsManifestDefaults());
			var devicesXML:XML		= new XML(new Radii8LibraryDeviceAssets.devicesManifestDefaults());
			var exportersXML:XML	= new XML(new Radii8LibraryTranscodersAssets.transcodersManifestDefaults());
			//var documentsXML:XML	= new XML(new Radii8LibraryTranscodersAssets.transcodersManifestDefaults());
			
			createSettingsData();

			createSavedData();
			
			//createDocumentTypesList(documentsXML);
			
			createComponentList(componentsXML);
			//createComponentList(sparkXML);
			//createComponentList(mxmlXML);
			
			createDocumentTranscoders(exportersXML);
			
			createInspectorsList(inspectorsXML);
			
			createToolsList(toolsXML);
			
			createDevicesList(devicesXML);
			
			createFontsList();
			
			documentStatuses.source = [WPService.STATUS_NONE, WPService.STATUS_DRAFT, WPService.STATUS_PUBLISH];
		}
		
		/**
		 * Get an array of fonts. Refactor to apply to projects and documents. 
		 * */
		public static function createFontsList():void {
			fontsArray = FontUtils.getFontInformationDetails(null);
		}
		
		/**
		 * Startup 
		 * */
		public static function startup():void {
			serviceManager 			= ServicesManager.getInstance();
			historyManager 			= HistoryManager.getInstance();
			
			serviceManager.radiate 	= instance;
			HistoryManager.radiate 	= instance;
			
			application.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, instance.uncaughtErrorHandler, false, 0, true);
			
			//ExternalInterface.call("Radiate.getInstance");
			if (ExternalInterface.available) {
				ExternalInterface.call("Radiate.instance.setFlashInstance", ExternalInterface.objectID);
			}
			
			var host:String;
			var path:String;
			var screenshotPath:String;
			
			if (!firstRun) {
				host = PersistentStorage.read(Radiate.WP_HOST_NAME);
				path = PersistentStorage.read(Radiate.WP_PATH_NAME);
				screenshotPath = PersistentStorage.read(Radiate.SCREENSHOT_PATH_NAME);
			}
			
			if (host) {
				Radiate.WP_HOST = host;
			}
			else {
				WP_HOST = defaultHost;
			}
			
			if (path && !firstRun) {
				Radiate.WP_PATH = path;
			}
			else {
				WP_PATH = defaultPath;
			}
			
			if (screenshotPath) {
				Radiate.SCREENSHOT_PATH = screenshotPath;
			}
			else {
				SCREENSHOT_PATH = defaultScreenshotPath;
			}
			
			CodeManager.setTranscodersVersion(instance.versionNumber);
			CodeManager.setComponentDefinitions(componentDefinitions.source);
			
			var importer:ITextImporter = TextConverter.getImporter(TextConverter.TEXT_FIELD_HTML_FORMAT);
			var config:IConfiguration = importer.configuration;
			TextConverter.removeFormat(TextConverter.TEXT_FIELD_HTML_FORMAT);
			TextConverter.addFormat(TextConverter.TEXT_FIELD_HTML_FORMAT, flashx.textLayout.conversion.TextFieldHtmlImporter, TextFieldHTMLExporter2, null);
			importer = TextConverter.getImporter(TextConverter.TEXT_FIELD_HTML_FORMAT);
			importer.configuration = config;
			
			DisplayObjectUtils.Base64Encoder2 = Base64;
			
			XMLUtils.initialize();
			
			instance.createOpenImportPopUp();
			
			// we use this to prevent hyperlinks from opening web pages when in design mode
			// we don't know what changes this causes with other components 
			// so it was disabled for a while
			// caused some issues with hyperlinks opening so disabling 
			//UIComponentGlobals.designMode = true;
			
			//radiate.openInitialProjects();
			//LayoutManager.getInstance().usePhasedInstantiation = false;
			
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
		
		/**
		 * Create the list of document transcoders.
		 * var languages:Array = CodeManager.getLanguages();
		 * var sourceData:SourceData = CodeManager.getSourceData(target, iDocument, language, options);	
		 * */
		public static function createDocumentTranscoders(xml:XML):void {
			var hasDefinition:Boolean;
			var items:XMLList;
			var item:XML;
			var numberOfItems:uint;
			var classType:Object;
			var transcoder:TranscoderDescription;
			 
			// get list of transcoder classes 
			items = XML(xml).transcoder;
			
			numberOfItems = items.length();
			
			for (var i:int;i<numberOfItems;i++) {
				item = items[i];
				
				transcoder = new TranscoderDescription();
				transcoder.importXML(item);
				
				hasDefinition = ClassUtils.hasDefinition(transcoder.classPath);
				
				if (hasDefinition) {
					//classType = ClassUtils.getDefinition(transcoder.classPath);
					addTranscoder(transcoder);
				}
				else {
					error("Document transcoder class for " + transcoder.type + " not found: " + transcoder.classPath);
					// we need to add it to Radii8LibraryExporters
					// such as Radii8LibraryExporters
				}
			}
			
		}
		
		/**
		 * Adds a transcoder to the Code Manager and adds the current component definitions
		 * */
		public static function addTranscoder(transcoder:TranscoderDescription):void {
			
			CodeManager.registerTranscoder(transcoder);
			CodeManager.setComponentDefinitions(componentDefinitions.source);
		}
		
		/**
		 * Creates the list of components.
		 * */
		public static function createComponentList(xml:XML):void {
			var numberOfItems:uint;
			var items:XMLList;
			var item:XML;
			var className:String;
			var skinClassName:String;
			var inspectors:Array;
			var hasDefinition:Boolean;
			var classType:Object;
			var includeItem:Boolean;
			var attributes:XMLList;
			var attributesLength:int;
			var childNodes:Array = [];
			var childNodesList:XMLList;
			var childNodesLength:int;
			var defaults:Object;
			var propertyName:String;
			var descendents:XMLList;
			var name:String;
			
			
			// get list of component classes 
			items = XML(xml).component;
			
			numberOfItems = items.length();
			
			for (var i:int;i<numberOfItems;i++) {
				item = items[i];
				
				name = String(item.id);
				className = item.attribute("class");
				skinClassName = item.attribute("skinClass");
				//inspectors = item.inspector;
				
				includeItem = item.attribute("include")=="false" ? false : true;
				descendents = item.descendents.property;
				childNodes = [];
				
				
				// check that definitions exist in domain
				// skip any support classes
				if (className.indexOf("mediaClasses")==-1 && 
					className.indexOf("gridClasses")==-1 &&
					className.indexOf("windowClasses")==-1 &&
					className.indexOf("supportClasses")==-1) {
					
					hasDefinition = ClassUtils.hasDefinition(className);
					
					if (hasDefinition) {
						classType = ClassUtils.getDefinition(className);
						
						// need to check if we have the skin as well
						
						//hasDefinition = ClassUtils.hasDefinition(skinClassName);
						
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
							
							if (descendents.length()) {
								childNodesList = descendents.attributes();
								childNodesLength = childNodesList.length();
								
								for each (var node:XML in childNodesList) {
									propertyName = String(node);
									childNodes.push(propertyName);
								}
							}
							
							addComponentDefinition(item.@id, className, classType, inspectors, null, defaults, null, includeItem, childNodes, false);
						}
						else {
							error("Component skin class, '" + skinClassName + "' not found for '" + className + "'.");
						}
					}
					else {
						error("Component class not found: " + className);
						// we need to add it to Radii8LibraryAssets 
						// such as Radii8LibrarySparkAssets
					}
					
				}
				else {
					// delete support classes
					// may need to refactor why we are including them in the first place
					delete items[i];
					numberOfItems--;
				}
			}
			
			// componentDescriptions should now be populated
		}
		
		/**
		 * Creates the list of inspectors.
		 * */
		public static function createInspectorsList(xml:XML):void {
			var numberOfItems:uint;
			var inspectorsLength:uint;
			var items:XMLList;
			var className:String;
			var alternativeClassName:String;
			var alternativeClasses:XMLList;
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
			var altItem:XML;
			var inspectorItems:XMLList;
			var inspector:XML;
			var inspectableClass:InspectableClass;
			var inspectorData:InspectorData;
			
			
			// get list of inspector classes 
			items = XML(xml).item;
			
			numberOfItems = items.length();
			
			// add inspectable classes to the dictionary
			for (var i:int;i<numberOfItems;i++) {
				item = items[i];
				inspectableClass = new InspectableClass(item);
				className = inspectableClass.className;
				alternativeClasses = item..alternative;
				
				if (inspectableClassesDictionary[className]==null) {
					inspectableClassesDictionary[className] = inspectableClass;
					
					// get other classes that can use the same inspectors
					for (var k:int = 0; k < alternativeClasses.length(); k++)  {
						altItem = alternativeClasses[k];
						alternativeClassName = altItem.attribute("className");
						
						if (inspectableClassesDictionary[alternativeClassName]==null) {
							inspectableClassesDictionary[alternativeClassName] = inspectableClass;
						}
						else {
							warn("Inspectable alternative class, '" + alternativeClassName + "', was listed more than once during import.");
						}
					}
					
				}
				else {
					warn("Inspectable class, '" + className + "', was listed more than once during import.");
				}
					
			}
			
			// check that definitions exist in domain
			for each (inspectableClass in inspectableClassesDictionary) {
			
				numberOfItems = inspectableClass.inspectors.length;
				j = 0;
				
				for (var j:int;j<numberOfItems;j++) {
					inspectorData = inspectableClass.inspectors[j];
					className = inspectorData.className;
					
					if (inspectorsDictionary[className]==null) {
						
						hasDefinition = ClassUtils.hasDefinition(className);
						
						if (hasDefinition) {
							classType = ClassUtils.getDefinition(className);
						}
						else {
							error("Inspector class not found: " + className + " Add a reference to RadiateReferences");
						}
						
						// not passing in classType now since we may load it in later dynamically
						addInspectorType(inspectorData.name, className, null, inspectorData.icon, defaults);
					}
					else {
						//warn("Inspector class: " + className + ", is already in the dictionary");
					}
				}
			}
			
			// inspectorsInstancesDictionary should now be populated
		}
		
		
		/**
		 * Creates the list of tools. Read the howto.txt to see how to add 
		 * new tools. 
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
			var numberOfItems:uint;
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
			var key:String;
			
			// get list of tool classes 
			items = XML(xml).tool;
			
			numberOfItems = items.length();
			
			for (var i:int;i<numberOfItems;i++) {
				item = items[i];
				
				name = String(item.id);
				className = item.attribute("class");
				inspectorClassName = item.attribute("inspector");
				cursorItems = item..cursor;
				key = item.attribute("key");
				
				includeItem = item.attribute("include")=="false" ? false : true;
				
				if (!includeItem) continue;
				
				hasDefinition = ClassUtils.hasDefinition(className);
				
				if (hasDefinition) {
					toolClassDefinition = ClassUtils.getDefinition(className);
					
					
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
						hasDefinition = ClassUtils.hasDefinition(inspectorClassName);
						
						if (hasDefinition) {
							inspectorClassDefinition = ClassUtils.getDefinition(inspectorClassName);
							
							// Create tool inspector
							inspectorClassFactory = new ClassFactory(inspectorClassDefinition as Class);
							//classFactory.properties = defaults;
							inspectorInstance = inspectorClassFactory.newInstance();
					
						}
						else {
							var errorMessage:String = "Could not find inspector, '" + inspectorClassName + "' for tool, '" + className + "'. ";
							errorMessage += "You may need to add a reference to it in RadiateReferences.";
							error(errorMessage);
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
						
						if (cursorClass==null) {
							error("Tool cursor not found: " + cursorName);
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
					
					// add keyboard shortcut
					
					//trace("tool cursors:", cursors);
					var toolDescription:ComponentDescription = addToolType(item.@id, className, toolClassDefinition, toolInstance, inspectorClassName, null, defaults, null, cursors, key);
					//trace("tool cursors:", toolDescription.cursors);
				}
				else {
					//trace("Tool class not found: " + classDefinition);
					error("Tool class not found: " + toolClassDefinition);
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
			var numberOfItems:uint;
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
			
			numberOfItems = items.length();
			
			for (var i:int;i<numberOfItems;i++) {
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
		[Bindable]
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
		 * Assets of the current document
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
		
		public static var componentsIconPath:String = "assets/icons/components/";
		public static var componentsIconNotFoundPath:String = componentsIconPath + "/BorderContainer.png";
		
		public static var SETTINGS_DATA_NAME:String = "settingsData";
		public static var WP_HOST_NAME:String = "wpHostName";
		public static var WP_PATH_NAME:String = "wpPathName";
		public static var SAVED_DATA_NAME:String 	= "savedData";
		public static var CONTACT_FORM_URL:String = "http://www.radii8.com/support.php";
		public static var WP_HOST:String = "https://www.radii8.com";
		public static var WP_PATH:String = "/r8m/";
		public static var WP_USER_PATH:String = "";
		public static var WP_EXAMPLES_PATH:String = "/r8m/";
		public static var WP_NEWS_PATH:String = "/r8m/";
		public static var WP_LOGIN_PATH:String = "/wp-admin/";
		public static var WP_PROFILE_PATH:String = "/wp-admin/profile.php";
		public static var WP_EDIT_POST_PATH:String = "/wp-admin/post.php";
		public static var DEFAULT_DOCUMENT_WIDTH:int = 800;
		public static var DEFAULT_DOCUMENT_HEIGHT:int = 792;
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
		public static function addToolType(name:String, className:String, classType:Object, instance:ITool, 
										   inspectorClassName:String, icon:Object = null, defaultProperties:Object=null, 
										   defaultStyles:Object=null, cursors:Dictionary = null, key:String = null):ComponentDescription {
			var definition:ComponentDescription;
			var numberOfTools:uint = toolsDescriptions.length;
			var item:ComponentDescription;
			
			for (var i:uint;i<numberOfTools;i++) {
				item = toolsDescriptions.getItemAt(i) as ComponentDescription;
				
				// check if it exists already
				if (item && item.classType==classType) {
					return item;
					//return false;
				}
			}
			
			definition = new ComponentDescription();
			
			definition.name 			= name;
			definition.icon 			= icon;
			definition.className 		= className;
			definition.classType 		= classType;
			definition.defaultStyles 	= defaultStyles;
			definition.defaultProperties = defaultProperties;
			definition.instance 		= instance;
			definition.inspectorClassName = inspectorClassName;
			definition.cursors 			= cursors;
			definition.key 				= key;
			
			toolsDescriptions.addItem(definition);
			
			return definition;
		}
		
		private var _previousSelectedTool:ITool;

		public function get previousSelectedTool():ITool
		{
			return _previousSelectedTool;
		}

		public function set previousSelectedTool(value:ITool):void
		{
			_previousSelectedTool = value;
		}

		
		/**
		 * Save current tool
		 * */
		public function saveCurrentTool():void {
			previousSelectedTool = selectedTool;
		}
		
		/**
		 * Sets the selected tool to the tool passed in
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
		 * Restores the previously selected tool.
		 * 
		 * This restores the previous selected tool.
		 * */
		public function restoreTool(dispatchEvent:Boolean = true, cause:String = ""):void {
			if (previousSelectedTool && previousSelectedTool!=selectedTool) {
				setTool(previousSelectedTool, dispatchEvent, cause);
			}
		}
			
		
		/**
		 * Enables the selected tool
		 * @see disableTool()
		 * */
		public function enableTool(dispatchEvent:Boolean = true, cause:String = ""):void {
			
			if (selectedTool) {
				selectedTool.enable();
			}
			
			if (dispatchEvent) {
				//instance.dispatchToolChangeEvent(selectedTool);
			}
			
		}
		
		/**
		 * Disables the selected tool
		 * @see enableTool()
		 * */
		public function disableTool(dispatchEvent:Boolean = true, cause:String = ""):void {
			
			if (selectedTool) {
				selectedTool.disable();
			}
			
			if (dispatchEvent) {
				//instance.dispatchToolChangeEvent(selectedTool);
			}
			
		}
		
		/**
		 * Get tool description.
		 * @see getToolByType()
		 * @see getToolByName()
		 * */
		public function getToolDescription(instance:ITool):ComponentDescription {
			var numberOfTools:int = toolsDescriptions.length;
			var componentDescription:ComponentDescription;
			
			for (var i:int;i<numberOfTools;i++) {
				componentDescription = ComponentDescription(toolsDescriptions.getItemAt(i));
				
				if (componentDescription.instance==instance) {
					return componentDescription;
				}
			}
			
			return null;
		}
		
		/**
		 * Get tool by name. Pass in the class name or tool name. Match is case insensitive. 
		 * List of class names are in tools-manifest-defaults.xml or radiate.toolsDescription
		 * @see getToolByType()
		 * */
		public function getToolByName(name:String):ComponentDescription {
			var numberOfTools:int = toolsDescriptions.length;
			var componentDescription:ComponentDescription;
			var nameLowerCase:String = name? name.toLowerCase() : null;
			
			if (name==null || name=="") return null;
			
			for (var i:int;i<numberOfTools;i++) {
				componentDescription = ComponentDescription(toolsDescriptions.getItemAt(i));
				
				if (componentDescription.className.toLowerCase()==nameLowerCase ||
					componentDescription.name.toLowerCase()==nameLowerCase) {
					return componentDescription;
				}
			}
			
			return null;
		}
		
		/**
		 * Get tool by type.
		 * */
		public function getToolByType(type:Class):ComponentDescription {
			var numberOfTools:int = toolsDescriptions.length;
			var componentDescription:ComponentDescription;
			
			for (var i:int;i<numberOfTools;i++) {
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
		public function getInspectors(target:Object, fallBackOnSuperClasses:Boolean = false):Array {
			var className:String;
			var inspectors:Array;
			var inspectorDataArray:Array;
			var inspectableClass:InspectableClass;
			
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
			var maxScale:int = 10;
			var minScale:Number = .05;
			
			if (value>maxScale) {
				value = maxScale;
			}
			if (value<minScale) {
				value = minScale;
			}
			if (selectedDocument && !isNaN(value) && value>0) {
				//DisplayObject(selectedDocument.instance).scaleX = value;
				//DisplayObject(selectedDocument.instance).scaleY = value;
				selectedDocument.scale = Math.min(value, maxScale);
				
				if (dispatchEvent) {
					dispatchScaleChangeEvent(selectedDocument.instance, value, value);
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
		 * Set the scroll position of the document
		 * */
		public function setScrollPosition(x:int, y:int):void {
			if (!canvasScroller) return;
			
			var viewport:IViewport = canvasScroller.viewport;
			var vsbWidth:int = canvasScroller.verticalScrollBar ? canvasScroller.verticalScrollBar.width : 11;
			var hsbHeight:int = canvasScroller.horizontalScrollBar ? canvasScroller.horizontalScrollBar.height : 11;
			var availableWidth:int = canvasScroller.width;// - vsbWidth;
			var availableHeight:int = canvasScroller.height;// - hsbHeight;
			
			viewport.horizontalScrollPosition = Math.max(0, x);
			viewport.verticalScrollPosition = Math.max(0, y);
			
		}
		
		/**
		 * Center the application on a point
		 * */
		public function centerOnPoint(point:Point):void {
			if (!canvasScroller) return;
			var viewport:IViewport = canvasScroller.viewport;
			var availableWidth:int = canvasScroller.width;// - vsbWidth;
			var availableHeight:int = canvasScroller.height;// - hsbHeight;
			var vsbWidth:int = canvasScroller.verticalScrollBar ? canvasScroller.verticalScrollBar.width : 11;
			var hsbHeight:int = canvasScroller.horizontalScrollBar ? canvasScroller.horizontalScrollBar.height : 11;
			var documentVisualElement:IVisualElement = IVisualElement(selectedDocument.instance);
			var currentScale:Number = getScale();
			var contentWidth:int = documentVisualElement.width * currentScale;
			var contentHeight:int = documentVisualElement.height * currentScale;
			
			//var horScrollPos:int = viewportWidth/2 - contentWidth/2;
			var newX:int = availableWidth/2 - (contentWidth/2 - point.x);
			newX = availableWidth/2 - (contentWidth/2 + (contentWidth/2-point.x));
			newX = (contentWidth/2 + (contentWidth/2-(point.x*currentScale))) - availableWidth/2;
			//newX = availableWidth/2 - (contentWidth/2 - (contentWidth/2-point.x));
			//newX = (availableWidth- contentWidth)/2 - point.x;
			//newX = (availableWidth - contentWidth + vsbWidth) / 2 - point.x;
			var newY:int = (contentHeight/2 + (contentHeight/2-(point.y*currentScale))) - availableHeight/2;
			newY = canvasScroller.verticalScrollBar.value;		
			setScrollPosition(newX, newY);
			// (495 - 750) - 736
			// (-255) - 736
			// -991
			
			// 495 - (750-736)
			// 495 - (14)
			// 481
			
			// 495 - (750-736*1)
			// 495 - (14)
			// 481
			
		}
		
		/**
		 * Center the application. 
		 * 
		 * @param vertically enable vertically centering options. if verticalTop is false top and bottom may be cut off. if true, scroll to top
		 * @param verticallyTop if document is taller than avialable space keep it at the top
		 * @param horizontalLeft if document is wider than avialable space keep it to the left
		 * @param totalDocumentPadding adjustment for space at the top of the document. not sure really
		 * */
		public function centerApplication(vertically:Boolean = true, verticallyTop:Boolean = true, horizontalLeft:Boolean=true, totalDocumentPadding:int = 0):void {
			if (!canvasScroller) return;
			var viewport:IViewport = canvasScroller.viewport;
			var documentVisualElement:IVisualElement = IVisualElement(selectedDocument.instance);
			//var contentHeight:int = viewport.contentHeight * getScale();
			//var contentWidth:int = viewport.contentWidth * getScale();
			// get document size NOT scroll content size
			var contentWidth:int = documentVisualElement.width * getScale();
			var contentHeight:int = documentVisualElement.height * getScale();
			var newHorizontalPosition:int;
			var newVerticalPosition:int;
			var needsValidating:Boolean;
			//var vsbWidth:int = canvasScroller.verticalScrollBar ? canvasScroller.verticalScrollBar.width : 11;
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
				
				if (horizontalLeft) {
					newHorizontalPosition = 0;
					viewport.horizontalScrollPosition = newHorizontalPosition;
				}
				else {
					newHorizontalPosition = (contentWidth - availableWidth) / 2;
					viewport.horizontalScrollPosition = Math.max(0, newHorizontalPosition);
				}
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
		public function scaleToFit(enableScaleUp:Boolean = true, dispatchEvent:Boolean = true):void {
			var width:int;
			var height:int;
			var availableWidth:int;
			var availableHeight:int;
			var widthScale:Number;
			var heightScale:Number;
			var newScale:Number;
			var documentInstance:IVisualElement;
			var vsbWidth:int;
			var hsbHeight:int;
			
			documentInstance = selectedDocument ? selectedDocument.instance as IVisualElement : null;
			
			if (documentInstance) {
				//width = DisplayObject(document).width;
				//height = DisplayObject(document).height;
				width = documentInstance.width;
				height = documentInstance.height;
				vsbWidth = canvasScroller.verticalScrollBar ? canvasScroller.verticalScrollBar.width : 20;
				hsbHeight = canvasScroller.horizontalScrollBar ? canvasScroller.horizontalScrollBar.height : 20;
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

				if (newScale>1 && !enableScaleUp) {
					setScale(1, dispatchEvent);
				}
				else {
					setScale(newScale, dispatchEvent);
				}
				
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
		
		public static var w3URL:String = "https://www.w3.org/TR/DOM-Level-3-Events/events.html#event-DOMSubtreeModified";
		
		/**
		 * Returns the URL to the help document online based on MetaData passed to it. 
		 * 
		 * For HTML, check out W3C 
		 * */
		public static function getURLToHelp(metadata:Object, useBackupURL:Boolean = true):String {
			var path:String = "";
			var currentClass:String;
			var sameClass:Boolean;
			var prefix:String = "";
			var url:String;
			var packageName:String;
			var declaredBy:String;
			var backupURLNeeded:Boolean;
			
			if (metadata=="application") {
				metadata = "spark.components::Application";
			}
			
			if (metadata && metadata is MetaData && metadata.declaredBy) {
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
			else if (metadata is String) {
				currentClass = metadata.replace(/::|\./g, "/");
				path = currentClass + ".html";
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
		public static function addComponentDefinition(name:String, className:String, classType:Object, inspectors:Array = null, 
													  icon:Object = null, defaultProperties:Object=null, defaultStyles:Object=null, 
													  enabled:Boolean = true, childNodes:Array = null, dispatchEvents:Boolean = true):Boolean {
			var componentDefinition:ComponentDefinition;
			var numberOfDefinitions:uint = componentDefinitions.length;
			var item:ComponentDefinition;
			
			
			for (var i:uint;i<numberOfDefinitions;i++) {
				item = ComponentDefinition(componentDefinitions.getItemAt(i));
				
				// check if it exists already
				if (item && item.classType==classType) {
					return false;
				}
			}
			
			
			componentDefinition = new ComponentDefinition();
			
			componentDefinition.name = name;
			componentDefinition.icon = icon;
			componentDefinition.className = className;
			componentDefinition.classType = classType;
			componentDefinition.defaultStyles = defaultStyles;
			componentDefinition.defaultProperties = defaultProperties;
			componentDefinition.inspectors = inspectors;
			componentDefinition.enabled = enabled;
			componentDefinition.childNodes = childNodes;
			
			componentDefinitions.addItem(componentDefinition);
			
			if (dispatchEvents) {
				instance.dispatchComponentDefinitionAddedEvent(componentDefinition);
			}
			
			CodeManager.setComponentDefinitions(componentDefinitions.source);
			
			return true;
		}
		
		/**
		 * Remove the named component class
		 * */
		public static function removeComponentType(className:String):Boolean {
			var definition:ComponentDefinition;
			var numberOfDefinitions:uint = componentDefinitions.length;
			var item:ComponentDefinition;
			
			for (var i:uint;i<numberOfDefinitions;i++) {
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
			var numberOfDefinitions:uint = componentDefinitions.length;
			var item:ComponentDefinition;
			
			for (var i:uint;i<numberOfDefinitions;i++) {
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
		public static function getDynamicComponentType(componentName:Object, fullyQualified:Boolean = false):ComponentDefinition {
			var definition:ComponentDefinition;
			var numberOfDefinitions:uint = componentDefinitions.length;
			var item:ComponentDefinition;
			var className:String;
			
			if (componentName is QName) {
				className = QName(componentName).localName;
			}
			else if (componentName is String) {
				className = componentName as String;
			}
			else if (componentName is Object) {
				className = ClassUtils.getQualifiedClassName(componentName);
				
				if (className=="application" || componentName is Application) {
					className = ClassUtils.getSuperClassName(componentName, true);
				}
			}
			
			fullyQualified = className.indexOf("::")!=-1 ? true : fullyQualified;
			if (fullyQualified) {
				className = className.replace("::", ".");
			}
			
			for (var i:uint;i<numberOfDefinitions;i++) {
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
			
			
			var hasDefinition:Boolean = ClassUtils.hasDefinition(className);
			var classType:Object;
			var name:String;
			
			
			if (hasDefinition) {
				if (className.indexOf("::")!=-1) {
					name = className.split("::")[1];
				}
				else {
					name = className;
				}
				classType = ClassUtils.getDefinition(className);
				addComponentDefinition(name, className, classType, null, null);
				item = getComponentType(className, fullyQualified);
				return item;
			}
			
			return null;
		}
		
		/**
		 * Removes all components. If components were removed then returns true. 
		 * */
		public static function removeAllComponents():Boolean {
			var numberOfDefinitions:uint = componentDefinitions.length;
			
			if (numberOfDefinitions) {
				componentDefinitions.removeAll();
				return true;
			}
			
			return false;
		}
		
		/**
		 * Add multiple assets to a document or project
		 * */
		public function addAssetsToDocument(assetsToAdd:Array, documentData:DocumentData, dispatchEvents:Boolean = true):void {
			var numberOfAssets:int;
			var added:Boolean;
			
			numberOfAssets = assetsToAdd ? assetsToAdd.length : 0;
			
			for (var i:int;i<numberOfAssets;i++) {
				addAssetToDocument(assetsToAdd[i], documentData, dispatchEvents);
			}
			
		}
		
		/**
		 * Add an asset to the document assets collection
		 * Should be renamed to something like addAssetToGlobalResourcesAndAssociateWithDocument
		 * */
		public function addAssetToDocument(attachmentData:DocumentData, documentData:IDocumentData, dispatchEvent:Boolean = true):void {
			var numberOfAssets:int = assets ? assets.length : 0;
			var found:Boolean;
			var addedAttachmentData:DocumentData;
			var reparented:Boolean;
			
			for (var i:int;i<numberOfAssets;i++) {
				addedAttachmentData = assets.getItemAt(i) as DocumentData;
				
				if (attachmentData.id==addedAttachmentData.id && addedAttachmentData.id!=null) {
					found = true;
					break;
				}
			}

			
			if (documentData) {
				if (attachmentData.parentId != documentData.id) {
					attachmentData.parentId = documentData.id;
					reparented = true;
				}
			}
			
			if (!found) {
				assets.addItem(attachmentData);
			}
			
			if ((!found || reparented) && dispatchEvent) {
				dispatchAssetAddedEvent(attachmentData);
			}
		}
		
		/**
		 * Remove an asset from the documents assets collection
		 * */
		public function removeAssetFromDocument(assetData:IDocumentData, documentData:DocumentData, locations:String = null, dispatchEvents:Boolean = true):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var remote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var index:int = assets.getItemIndex(assetData);
			var removedInternally:Boolean;
			
			if (index!=-1) {
				assets.removeItemAt(index);
				removedInternally = true;
			}
			
			if (remote && assetData && assetData.id) { 
				// we need to create service
				if (deleteAttachmentService==null) {
					deleteAttachmentService = new WPService();
					deleteAttachmentService.addEventListener(WPService.RESULT, deleteDocumentResultsHandler, false, 0, true);
					deleteAttachmentService.addEventListener(WPService.FAULT, deleteDocumentFaultHandler, false, 0, true);
				}
				
				deleteAttachmentService.host = getWPURL();
				
				deleteDocumentInProgress = true;
				
				deleteAttachmentService.deleteAttachment(int(assetData.id), true);
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
			
			dispatchAssetRemovedEvent(assetData, removedInternally);
			
			return removedInternally;
		}
		
		/**
		 * Remove assets from the documents assets collection
		 * */
		public function removeAssetsFromDocument(attachments:Array, locations:String = null, dispatchEvents:Boolean = true):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var remote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var removedInternally:Boolean;
			var attachmentData:AttachmentData;
			var attachmentIDs:Array = [];
			var numberOfAttachments:int;
			var index:int;
			
			numberOfAttachments = attachments ? attachments.length : 0;
			
			for (var i:int; i < numberOfAttachments; i++) {
				attachmentData = attachments[i];
				index = assets.getItemIndex(attachmentData);
				
				if (index>-1) {
					assets.removeItemAt(index);
					removedInternally = true;
				}
			}
			
			
			if (remote && attachments && attachments.length) { 
				// we need to create service
				if (deleteAttachmentsService==null) {
					deleteAttachmentsService = new WPService();
					deleteAttachmentsService.addEventListener(WPService.RESULT, deleteAttachmentsResultsHandler, false, 0, true);
					deleteAttachmentsService.addEventListener(WPService.FAULT, deleteAttachmentsFaultHandler, false, 0, true);
				}
				
				deleteAttachmentsService.host = getWPURL();
				
				deleteAttachmentsInProgress = true;
				
				for (var j:int = 0; j < attachments.length; j++) {
					attachmentData = attachments[j];
					
					if (attachmentData.id!=null) {
						attachmentIDs.push(attachmentData.id);
					}
				}
				
				if (attachmentIDs.length) {
					deleteAttachmentsService.deleteAttachments(attachmentIDs, true);
				}
				else {
					dispatchAttachmentsDeletedEvent(true, {localDeleted:true});
				}
			}
			
			// dispatch assets removed 
			// later dispatch attachment deleted event when result comes back from server 
			dispatchAssetsRemovedEvent(attachments, removedInternally);
			
			return removedInternally;
		}
		
		/**
		 * Adds PSD to the document. <br/>
		 * Adds assets to the library and document<br/>
		 * Missing support for masks, shapes and text (text is shown as image)<br/>
		 * Takes quite a while to import. <br/>
		 * Could use performance testing.
		 * */
		public function addPSDToDocument(psdFileData:ByteArray, iDocument:IDocument, matchDocumentSizeToPSD:Boolean = true, addToAssets:Boolean = true):void {
			var componentDefinition:ComponentDefinition;
			var application:Object;
			var componentInstance:Object;
			var componentDescription:ComponentDescription;
			var path:String;
			var bitmapData:BitmapData;
			var psdParser:PSDParser;
			var numberOfLayers:int;
			var properties:Array = [];
			var propertiesObject:Object; // could be causing performance issues - try typed
			var psdLayer:PSDLayer;
			var compositeBitmapData:BitmapData;
			var compositeWidth:int;
			var compositeHeight:int;
			var addCompositeImage:Boolean;
			var imageData:ImageData;
			var blendModeKey:String;
			var blendMode:String;
			var insideFolder:Boolean;
			var isFolderVisible:Boolean;
			var layerType:String;
			var layerName:String;
			var folderName:String;
			var layerVisible:Boolean;
			var layers:Array;
			var layersAndFolders:Dictionary;
			var parentInstance:Object;
			var layerFilters:Array;
			var layerID:int;
			var parentLayerID:int;
			var currentFolders:Array = [];
			var foldersDictionary:Object = [];
			var xOffset:int;
			var yOffset:int;
			var parentGroup:Object;// could be causing performance issues - try typed
			var hasShapes:Boolean;
			var hasMasks:Boolean;
			var resized:Boolean;
			var showInfo:Boolean = false;
			var testForErrors:Boolean = false;
			var time:int;
			var setDefaultsPre:Boolean = true;
			var setDefaultsPost:Boolean = false;
			
			addCompositeImage = true;
			
			layersAndFolders = new Dictionary(true);
			
			application = iDocument && iDocument.instance ? iDocument.instance : null;
			
			if (documentThatPasteOfFilesToBeLoadedOccured==null) {
				documentThatPasteOfFilesToBeLoadedOccured = iDocument;
			}
			
			//setupPasteFileLoader();
			
			psdParser = PSDParser.getInstance();
			
			time = getTimer();
			
			if (testForErrors) {
				psdParser.parse(psdFileData);
			}
			
			try {
				if (!testForErrors) {
					psdParser.parse(psdFileData);
				}
			}
			catch (errorObject:*) {
				var errorMessage:String;
				var stack:String;
				
				if ("getStackTrace" in errorObject) {
					stack = errorObject.getStackTrace();
				}
				
				if (errorObject) {
					errorMessage = Object(errorObject).toString();
				}
				
				error("Could not import the PSD. " + errorMessage, errorObject);
				
				pasteFileLoader ? pasteFileLoader.removeReferences(true) : -1;
				dropFileLoader ? dropFileLoader.removeReferences(true) : -1;
				
				return;
			}
			
			time = getTimer() - time;
			
			//layersLevel = iDocument.instance;
			//this.addChild(layersLevel);
			
			layers = psdParser.allLayers ? psdParser.allLayers : [];
			numberOfLayers = layers ? layers.length : 0;
			
			info("Time to import: " + int(time/1000) + " seconds. Number of layers: " + numberOfLayers);
			
			compositeBitmapData = psdParser.composite_bmp;
			compositeWidth		= compositeBitmapData ? compositeBitmapData.width : 0;
			compositeHeight		= compositeBitmapData ? compositeBitmapData.height : 0;
			
			// add composite of the PSD
			if (addCompositeImage || numberOfLayers==0) {
				
				componentDefinition 		= getComponentType("Image");
				componentInstance 			= createComponentToAdd(iDocument, componentDefinition, setDefaultsPre);
				
				propertiesObject 			= {};
				propertiesObject.source 	= compositeBitmapData;
				
				propertiesObject.visible 	= numberOfLayers==0 ? true : false;
				
				properties.push("source");
				properties.push("visible");
				
				addElement(componentInstance, application, properties, null, null, propertiesObject);
				
				updateComponentAfterAdd(iDocument, componentInstance, setDefaultsPost);
				
				componentDescription = iDocument.getItemDescription(componentInstance);
				
				if (numberOfLayers!=0) {
					componentDescription.locked = true;
					componentDescription.visible = propertiesObject.visible;
					componentDescription.name = "Composite Layer";
				}
				
				if (addToAssets) {
					imageData = new ImageData();
					imageData.bitmapData = compositeBitmapData;
					imageData.name = "Composite Layer";
					imageData.layerInfo = psdLayer;
					
					addAssetToDocument(imageData, documentThatPasteOfFilesToBeLoadedOccured, false);
				}
			}
			
			if (numberOfLayers==0 && compositeBitmapData==null) {
				warn("The PSD did not contain any readable layers.");
				pasteFileLoader ? pasteFileLoader.removeReferences(true) : -1;
				dropFileLoader ? dropFileLoader.removeReferences(true) : -1;
				
				if (addToAssets && imageData) {
					dispatchAssetAddedEvent(imageData);
				}
				
				dispatchAssetLoadedEvent(imageData, documentThatPasteOfFilesToBeLoadedOccured, false, false);
				
				return;
			}
			
			
			
			// Layer groups are being parsed and they are also PSDLayer class type.
			
			// There are 4 layer types :
			// LayerType_FOLDER_OPEN, LayerType_FOLDER_CLOSED , 
			// LayerType_HIDDEN and LayerType_NORMAL.
			
			// Layer folder hidden is marker for the end of the layer group. 
			// So if you want to parse the folder structure, check where the layer type folder 
			// starts and then every layer that follows is inside of that folder, 
			// until you reach layer type hidden.
			
			// order from top to bottom from PSD
			layers.reverse();
			
			// loop through layers and get the folders 
			for (var a:int;a<numberOfLayers;a++)  {
				psdLayer					= layers[a];
				layerType 					= psdLayer.type;
				layerID 					= psdLayer.layerID;
				layerName 					= psdLayer.name;
				layersAndFolders[layerID] 	= psdLayer;
				
				// create groups 
				if (layerType==PSDLayer.LayerType_FOLDER_OPEN || 
					layerType==PSDLayer.LayerType_FOLDER_CLOSED) {
					insideFolder = true;
					isFolderVisible = psdLayer.isVisible;
					folderName = psdLayer.name;
					parentLayerID = layerID;
					
					// get last added folder id
					if (currentFolders.length) {
						psdLayer.parentLayerID = currentFolders[0];
					}
					
					
					componentDefinition 		= getComponentType("Group");
					
					componentInstance 			= createComponentToAdd(iDocument, componentDefinition, setDefaultsPre);
					
					propertiesObject 			= {};
					propertiesObject.x 			= 0;
					propertiesObject.y			= 0;
					propertiesObject.lowestX 	= [];
					propertiesObject.lowestY	= [];
					
					// properties to set
					properties = [];
					
					// properties to set
					properties.push("x");
					properties.push("y");
					
					if (psdLayer.alpha!=1) {
						propertiesObject.alpha 	= psdLayer.alpha;
						properties.push("alpha");
					}
					
					if (psdLayer.isVisible==false) {
						propertiesObject.visible = false;
						properties.push("visible");
					}
					
					if (psdLayer.blendModeKey!="norm") {
						blendMode = DisplayObjectUtils.getBlendModeByKey(psdLayer.blendModeKey);
						
						if (blendMode) {
							propertiesObject.blendMode 	= blendMode;
							properties.push("blendMode");
						}
					}
					
					parentGroup = {};
					parentGroup.properties = properties;
					parentGroup.propertiesObject = propertiesObject;
					parentGroup.instance = componentInstance;
					parentGroup.parentID = currentFolders && currentFolders.length ? currentFolders[0] : 0;

					foldersDictionary[layerID] = parentGroup;
					
					if (showInfo) {
						trace("Creating folder properties for " + layerID + " " + layerName);
					}
					
					// add group layer id ordered as depth
					currentFolders.unshift(layerID);
					
				}
				else if (layerType==PSDLayer.LayerType_HIDDEN) {
					insideFolder = false;
					isFolderVisible = false;
					folderName = null;
					layerID = currentFolders.shift();
					
					parentGroup = foldersDictionary[layerID];
					
					// set the group location to start where the contents start - later subtract the difference
					parentGroup.propertiesObject.x = Math.min.apply(null, parentGroup.propertiesObject.lowestX);
					parentGroup.propertiesObject.y = Math.min.apply(null, parentGroup.propertiesObject.lowestY);
					
				}
				else if (layerType==PSDLayer.LayerType_NORMAL) {
					
					if (currentFolders.length) {
						psdLayer.parentLayerID = currentFolders[0];
						parentGroup = foldersDictionary[currentFolders[0]];
						
						while (parentGroup) {
							parentGroup.propertiesObject.lowestX.push(psdLayer.position.x);
							parentGroup.propertiesObject.lowestY.push(psdLayer.position.y);
							parentGroup = foldersDictionary[parentGroup.parentID];
						}
					}
					else {
						psdLayer.parentLayerID = 0;
					}
				}
				
			}
			
			// order from bottom to top from PSD
			layers.reverse();
			
			
			// loop through layers and create properties object with layer destination
			for (var i:int;i<numberOfLayers;i++)  {
				psdLayer				= psdParser.allLayers[i];
				bitmapData				= psdLayer.bmp;
				
				layerType 				= psdLayer.type;
				layerVisible 			= psdLayer.isVisible;
				layerName 				= psdLayer.name;
				layerFilters			= psdLayer.filters_arr;
				layerID					= psdLayer.layerID;
				
				parentLayerID 			= psdLayer.parentLayerID;
				
				parentGroup 			= foldersDictionary[parentLayerID];
				
				if (parentGroup) {
					xOffset = 0;
					yOffset = 0;
					
					// get different in location when layers are added to groups
					while (parentGroup) {
						xOffset += parentGroup.propertiesObject.x;
						yOffset += parentGroup.propertiesObject.y;
						parentGroup = foldersDictionary[parentGroup.parentID];
					}
				}
				else {
					xOffset = 0;
					yOffset = 0;
				}
				
				if (layerType==PSDLayer.LayerType_FOLDER_OPEN || 
					layerType==PSDLayer.LayerType_FOLDER_CLOSED ||
					layerType==PSDLayer.LayerType_HIDDEN) {
					
					if (showInfo) {
						trace("Looping through layers excluding folder " + layerID + " " + layerName);
					}
					
					continue;
				}
				
				if (showInfo) {
					trace("Looping through layers adding " + layerID + " " + layerName);
				}
				
				if (layerID==0 && showInfo) {
					trace("  - shape");
					hasShapes = true;
				}
				
				// need to keep track of errors during import
				if (bitmapData==null) {
					continue;
				}
				else if (bitmapData.width==0 || bitmapData.height==0) {
					continue;
				}
				
				componentDefinition 		= getComponentType("Image");
				
				componentInstance 			= createComponentToAdd(iDocument, componentDefinition, setDefaultsPre);
				
				propertiesObject 			= {};
				propertiesObject.source 	= bitmapData;
				propertiesObject.x 			= psdLayer.position.x - xOffset;
				propertiesObject.y 			= psdLayer.position.y - yOffset;
				
				// properties to set
				properties = [];
				
				// properties to set
				properties.push("x");
				properties.push("y");
				properties.push("source");
				
				if (psdLayer.alpha!=1) {
					propertiesObject.alpha 	= psdLayer.alpha;
					properties.push("alpha");
				}
				
				if (psdLayer.isVisible==false) {
					propertiesObject.visible = false;
					properties.push("visible");
				}
				
				if (psdLayer.blendModeKey!="norm") {
					blendMode = DisplayObjectUtils.getBlendModeByKey(psdLayer.blendModeKey);
					
					if (blendMode) {
						propertiesObject.blendMode 	= blendMode;
						properties.push("blendMode");
					}
				}
				
				if (layerFilters && layerFilters.length) {
					propertiesObject.filters = layerFilters;
					properties.push("filters");
				}
				
				if (parentLayerID!=0) {
					parentGroup = foldersDictionary[parentLayerID];
					parentInstance = parentGroup.instance;
				}
				else {
					parentInstance = application;
				}
				
				// if on level 0 - no parent - add it in next loop so we keep the
				// layer order
				//if (parentLayerID==0) {
				
				parentGroup 					= {};
				parentGroup.properties 			= properties;
				parentGroup.propertiesObject 	= propertiesObject;
				parentGroup.instance 			= componentInstance;
				parentGroup.parentInstance 		= parentInstance;
				
				foldersDictionary[layerID] 		= parentGroup;
				
			}
			
			// add folders to document
			
			var customParent:Object;
			
			// loop through layers and add folders and top level layers 
			for (var b:int;b<numberOfLayers;b++)  {
				psdLayer		= layers[b];
				layerType 		= psdLayer.type;
				layerName 		= psdLayer.name;
				layerID 		= psdLayer.layerID;
				parentLayerID	= psdLayer.parentLayerID;
				parentGroup 	= foldersDictionary[layerID];
				
				if (parentGroup==null) {
					continue;
				}
				
				//trace("adding " +  psdLayer.name + " ("+ layerID+")");
				// get parent folder if one exists
				customParent = parentLayerID!=0 ? foldersDictionary[parentLayerID] : null;
				
				parentInstance = customParent ? customParent.instance : application;
				
				componentInstance = parentGroup.instance;
				
				if (showInfo) {
					trace("Adding layer " + layerName + " to group " + parentLayerID);
				}
				
				addElement(componentInstance, parentInstance, parentGroup.properties, null, null, parentGroup.propertiesObject);
				
				updateComponentAfterAdd(iDocument, componentInstance, setDefaultsPost);
				
				componentDescription = iDocument.getItemDescription(componentInstance);
				
				if (componentDescription) {
					componentDescription.locked = psdLayer.isLocked;
					componentDescription.visible = psdLayer.isVisible;
					componentDescription.name = psdLayer.name;
					componentDescription.layerInfo = psdLayer;
				}
				
				if (addToAssets && layerType==PSDLayer.LayerType_NORMAL) {
					imageData = new ImageData();
					imageData.bitmapData = psdLayer.bmp;
					imageData.name = psdLayer.name;
					imageData.layerInfo = psdLayer;
					
					addAssetToDocument(imageData, documentThatPasteOfFilesToBeLoadedOccured, false);
				}
			}
			
			// remove file references
			if (pasteFileLoader) {
				pasteFileLoader.removeReferences(true);
			}
			
			// remove file references
			if (dropFileLoader) {
				dropFileLoader.removeReferences(true);
			}
			
			const WIDTH:String = "width";
			const HEIGHT:String = "height";
			
			if (matchDocumentSizeToPSD) {
				resized = sizeDocumentToBitmapData(documentThatPasteOfFilesToBeLoadedOccured, compositeBitmapData);
			}
			
			// dispatch event 
			if (addToAssets && imageData) {
				dispatchAssetAddedEvent(imageData);
			}
			
			if (hasShapes || hasMasks) {
				info("A PSD was partially imported. It does not fully support shapes or masks. Be sure to upload the images added to the Library.");
			}
			else {
				info("A PSD was imported. Be sure to upload the images added to the Library.");
			}
			
			setTarget(iDocument.instance);
			
			imageData = getImageDataFromBitmapData(compositeBitmapData);
			
			dispatchAssetLoadedEvent(imageData, documentThatPasteOfFilesToBeLoadedOccured, resized, true);
		}
		
		/**
		 * Adds an asset to the document
		 * */
		public function addImageDataToDocument(assetData:ImageData, iDocument:IDocument, constrainImageToDocument:Boolean = true):Boolean {
			var item:ComponentDefinition;
			var application:Application;
			var componentInstance:Object;
			var path:String;
			var bitmapData:BitmapData;
			var resized:Boolean;
			
			item = getComponentType("Image");
			
			
			application = iDocument && iDocument.instance ? iDocument.instance as Application : null;
			
			if (!application) {
				warn("No document instance was available to add image into. Create a new document and add the image to it manually");
				return false;
			}
			
			// set to true so if we undo it has defaults to start with
			componentInstance = createComponentToAdd(iDocument, item, true);
			bitmapData = assetData.bitmapData;
			
			
			const WIDTH:String = "width";
			const HEIGHT:String = "height";
			
			var properties:Array = [];
			var propertiesObject:Object;
			
			if (constrainImageToDocument) {
				propertiesObject = getConstrainedImageSizeObject(iDocument, bitmapData);
			}
			
			if (propertiesObject==null) {
				propertiesObject = {};
			}
			else {
				resized = true;
				properties.push(WIDTH);
				properties.push(HEIGHT);
			}
			
			if (assetData is ImageData) {
				path = assetData.url;
				
				if (path) {
					propertiesObject.width = undefined;
					propertiesObject.height = undefined;
					propertiesObject.source = path;
					properties.push(WIDTH);
					properties.push(HEIGHT);
				}
				else if (assetData.bitmapData) {
					propertiesObject.source = assetData.bitmapData;
				}
				
				properties.push("source");
			}
			
			addElement(componentInstance, iDocument.instance, properties, null, null, propertiesObject);
			
			updateComponentAfterAdd(iDocument, componentInstance);
			
			return resized;
		}
		
		public static function getImageDataFromBitmapData(bitmapData:BitmapData):ImageData {
			var assets:ArrayCollection = instance.assets;
			var numberOfAssets:int = assets.length;
			var imageData:ImageData;
			
			for (var i:int = 0; i < numberOfAssets; i++) {
				imageData = assets.getItemAt(i) as ImageData;
				
				if (imageData && imageData.bitmapData===bitmapData) {
					return imageData;
				}
			}
			
			return null;
		}
		
		/**
		 * Get bitmap data matching ImageData.uid.
		 * */
		public static function getBitmapDataFromImageDataID(uid:String):BitmapData {
			var assets:ArrayCollection = instance.assets;
			var numberOfAssets:int = assets.length;
			var imageData:ImageData;
			
			for (var i:int = 0; i < numberOfAssets; i++) {
				imageData = assets.getItemAt(i) as ImageData;
				
				if (imageData && imageData.uid===uid) {
					return imageData.bitmapData;
				}
			}
			
			return null;
		}
		
		public static function getConstrainedImageSizeObject(iDocument:IDocument, bitmapData:Object):Object {
			var properties:Array = [];
			var propertiesObject:Object = {};
			var aspectRatio:Number = 1;
			var constraintNeeded:Boolean;
			var resized:Boolean;

			const WIDTH:String = "width";
			const HEIGHT:String = "height";
			
			if (bitmapData && bitmapData.width>0 && bitmapData.height>0) {
				aspectRatio = iDocument.instance.width/iDocument.instance.height;
				
				if (bitmapData.width>iDocument.instance.width) {
					//aspectRatio = bitmapData.width / iDocument.instance.width;
					propertiesObject = DisplayObjectUtils.getConstrainedSize(bitmapData, "width", iDocument.instance.width);
					properties = [WIDTH, HEIGHT];
					constraintNeeded = true;
					resized = true;
				}
				
				if (constraintNeeded && propertiesObject.height>iDocument.instance.height) {
					propertiesObject = DisplayObjectUtils.getConstrainedSize(bitmapData, "height", iDocument.instance.height);
					resized = true;
				}
				else if (!constraintNeeded && bitmapData.height>iDocument.instance.height) {
					// check height is not larger than document width
					// and document height is not larger than width
					//aspectRatio = bitmapData.height / iDocument.instance.height;
					propertiesObject = DisplayObjectUtils.getConstrainedSize(bitmapData, "height", iDocument.instance.height);
					properties = [WIDTH, HEIGHT];
					resized = true;
				}
				
			}
			
			if (!resized) {
				return null; 
			}
			
			return propertiesObject; 
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
		 * Selects the current document
		 * */
		public function selectDocument(value:IDocument, dispatchEvent:Boolean = true, cause:String = ""):void {
			var iDocumentContainer:IDocumentContainer;
			
			if (selectedDocument != value) {
				selectedDocument = value;
			}
			
			iDocumentContainer = documentsContainerDictionary[value] as IDocumentContainer;
			
			if (iDocumentContainer) {
				toolLayer = iDocumentContainer.toolLayer;
				canvasBorder = iDocumentContainer.canvasBorder;
				canvasBackground= iDocumentContainer.canvasBackground;
				canvasScroller = iDocumentContainer.canvasScroller;
			}
			
			HistoryManager.history = selectedDocument ? selectedDocument.history : null;
			HistoryManager.history ? HistoryManager.history.refresh() : void;
			HistoryManager.setHistoryIndex(selectedDocument, HistoryManager.getHistoryPosition(selectedDocument));
			
			if (dispatchEvent) {
				instance.dispatchDocumentChangeEvent(selectedDocument);
			}
			
		}
		
		/**
		 * Selects the documents
		 * */
		public function selectDocuments(value:*, dispatchEvent:Boolean = true, cause:String = ""):void {
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
		 * @see setTargets
		 * @see target
		 * @see targets
		 * */
		public function setTarget(value:*, dispatchEvent:Boolean = true, cause:String = "", reselect:Boolean = false):void {
			var _tempTarget:* = value && value is Array && value.length ? value[0] : value;
			
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
			
			if (dispatchEvent) {
				instance.dispatchTargetChangeEvent(target);
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
		 * @see copiedData
		 * @see lastClipboardAction
		 * @see pasteItem
		 * */
		public function cutItem(item:Object):void {
			//Clipboard.generalClipboard.setData(ClipboardFormats.HTML_FORMAT, );
			cutData = item;
			copiedData = null;
			copiedDataDocument = selectedDocument;
			lastClipboardAction = "cut";
			
			// convert to string and then import to selected target or document
			var options:ExportOptions = new ExportOptions();
			var sourceItemData:SourceData;
			options.useInlineStyles = true;
			
			if (selectedDocument.getItemDescription(item)) {
				sourceItemData = CodeManager.getSourceData(target, selectedDocument, CodeManager.MXML, options);
				
				if (sourceItemData) {
					copiedDataSource = sourceItemData.source;
				}
			}
			
		}
		
		/**
		 * Copy item
		 * @see cutData
		 * @see lastClipboardAction
		 * @see pasteItem
		 * */
		public function copyItem(item:Object, format:String = null, handler:Function = null):void {
			//Clipboard.generalClipboard.setData(ClipboardFormats.HTML_FORMAT, );
			cutData = null;
			copiedData = item;
			copiedDataDocument = selectedDocument;
			lastClipboardAction = "copy";
			
			
			var clipboard:Clipboard = Clipboard.generalClipboard;
			var serializable:Boolean = true;
			
			format = format ? format : "Object";
			handler = handler!=null ? handler : setClipboardDataHandler;
			
			if (true) {
				clipboard.clear();
			}
				
			try {
				// convert to string and then import to selected target or document
				var options:ExportOptions = new ExportOptions();
				var sourceItemData:SourceData;
				
				options.useInlineStyles = true;
				options.exportChildDescriptors = true;
				
				if (selectedDocument.getItemDescription(item)) {
					sourceItemData = CodeManager.getSourceData(target, selectedDocument, CodeManager.MXML, options);
					
					if (sourceItemData) {
						copiedDataSource = sourceItemData.source;
					}
				}
				
				
				if (item is String) {
					clipboard.setDataHandler(format, handler, serializable);
				}
				else {
					clipboard.setDataHandler(format, handler, serializable);
				}
				
			}
			catch (error:ErrorEvent) {
				
			}
		}
	
		/**
		 * Get MXML source of the document 
		 * */
		public static function getMXML(iDocument:IDocument, target:Object = null, options:ExportOptions = null):SourceData {
			var options:ExportOptions;
			var sourceItemData:SourceData;

			if (options==null) {
				options = new ExportOptions();
				options.useInlineStyles = true;
				options.exportChildDescriptors = true;
			}
			
			if (target==null) {
				target = iDocument.componentDescription.instance;
			}
			
			if (iDocument.getItemDescription(target)) {
				sourceItemData = CodeManager.getSourceData(target, iDocument, CodeManager.MXML, options);
				
				if (sourceItemData) {
					return sourceItemData;
				}
			}
			
			return null;
		}
		
		/**
		 * Get destination component or application when image files are 
		 * dropped from an external source
		 * */
		public function getDestinationForExternalFileDrop():Object {
			var destination:Object = target;
			var addToDocumentForNow:Boolean = true;
			
			// get destination of clipboard contents
			if (destination && !(destination is IVisualElementContainer)) {
				if (addToDocumentForNow) {
					destination = null;
				}
				else {
					destination = destination.owner;
				}
			}
			
			if (!destination && selectedDocument) {
				destination = selectedDocument.instance;
			}
			
			return destination;
		}
		
		/**
		 * Paste item
		 * @see cutData
		 * @see copiedData
		 * @see lastClipboardAction
		 * @see pasteItem
		 * */
		public function pasteItem(destination:Object):void {
			var clipboard:Clipboard = Clipboard.generalClipboard;
			var formats:Array = clipboard.formats;
			var component:Object;
			var descriptor:ComponentDescription;
			var newComponent:Object;
			var exportOptions:ExportOptions;
			var itemData:SourceData;
			var useCopyObjectsTechnique:Boolean = false;
			var bitmapData:BitmapData;
			var data:Object;
			
			// get destination of clipboard contents
			if (destination && !(destination is IVisualElementContainer)) {
				destination = destination.owner;
			}
			
			// prevent containers from being pasted into themselves
			if (cutData==destination || copiedData==destination) {
				if (selectedDocument.instance.contains(destination.owner)) {
					destination = destination.owner;
				}
			}
			
			if (!destination) {
				destination = selectedDocument.instance;
			}
			
			if (descriptor==null) {
				descriptor = selectedDocument.getItemDescription(component);
			}
			
			var numberOfFormats:int = formats.length;
			var format:String;
			var componentFound:Boolean;
			
			// check for bitmap data, image files, air:rtf, air:text, etc 
			// when multiple formats exist add first forrmat we suport
			for (var i:int;i<numberOfFormats;i++) {
				format = formats[i];
				
				
				if (format=="UIComponent" || format=="Object") {
					component = clipboard.getData(format);
					
					descriptor = component as ComponentDescription;
					
					if (component is Application) {
						error("Cannot copy and paste the document.");
						return;
					}
					
					if (component==null) {
						return;
					}
					
					componentFound = true;
					
					// code is outside of for loop - refactor
					break;
					
				}
				else if (format==ClipboardFormats.FILE_LIST_FORMAT || 
						format==ClipboardFormats.FILE_PROMISE_LIST_FORMAT) {
					data = clipboard.getData(format);
					
					addFileListDataToDocument(selectedDocument, data as Array, destination);
					return;
				}
				else if (format==ClipboardFormats.BITMAP_FORMAT) {
					data = clipboard.getData(ClipboardFormats.BITMAP_FORMAT);
					bitmapData = data as BitmapData;
					
					addBitmapDataToDocument(selectedDocument, bitmapData, destination);
					return;
				}
				else if (format==ClipboardFormats.TEXT_FORMAT) {
					data = clipboard.getData(ClipboardFormats.TEXT_FORMAT);
					
					addTextDataToDocument(selectedDocument, data as String, destination);
					return;
				}
				else if (format==ClipboardFormats.HTML_FORMAT) {
					data = clipboard.getData(ClipboardFormats.HTML_FORMAT);
					
					addHTMLDataToDocument(selectedDocument, data as String, destination);
					return;
				}
			}
			
			if (useCopyObjectsTechnique) {
				var item:ComponentDefinition = Radiate.getComponentType(component.className);
				newComponent = createComponentToAdd(selectedDocument, item, true);
				addElement(newComponent, destination, descriptor.propertyNames, descriptor.styleNames, descriptor.eventNames, ObjectUtils.merge(descriptor.properties, descriptor.styles));
				updateComponentAfterAdd(selectedDocument, newComponent);
				//setProperties(newComponent, descriptor.propertyNames, descriptor.properties);
				HistoryManager.doNotAddEventsToHistory = true;
				//setStyles(newComponent, descriptor.styleNames, descriptor.styles);
				HistoryManager.doNotAddEventsToHistory = false;
				setTarget(newComponent);
			}
			else if (component) {
				var useInlineStyles:Boolean = false;
				exportOptions = new ExportOptions();
				exportOptions.useInlineStyles = true;
				exportOptions.exportChildDescriptors = true;
				var description:ComponentDescription = selectedDocument.getItemDescription(component);
				
				// copy selection
				if (description) {
					itemData = CodeManager.getSourceData(component, selectedDocument, CodeManager.MXML, exportOptions);
				}
				
				// paste selection
				if (itemData && description) {
					itemData = CodeManager.setSourceData(itemData.source, destination, selectedDocument, CodeManager.MXML, null);
				}
				else if (copiedDataSource) {
					itemData = CodeManager.setSourceData(copiedDataSource, destination, selectedDocument, CodeManager.MXML, null);
				}
				
				// select first target
				if (itemData && itemData.targets && itemData.targets.length) { 
					setTarget(itemData.targets[0]);
				}
				else {
					setTarget(destination);
				}
				
				itemData = null;
			}
		}
		
		public function dropItem(event:DragEvent, createNewDocument:Boolean = false):void {
			var dragSource:DragSource;
			var hasFileListFormat:Boolean;
			var hasFilePromiseListFormat:Boolean;
			var isSelf:Boolean;
			
			dragSource = event.dragSource;
			hasFileListFormat = dragSource.hasFormat(ClipboardFormats.FILE_LIST_FORMAT);
			hasFilePromiseListFormat = dragSource.hasFormat(ClipboardFormats.FILE_PROMISE_LIST_FORMAT);
			
			var destination:Object;
			var droppedFiles:Array;
			
			if (isAcceptableDragAndDropFormat(dragSource)) {
				
				if (hasFileListFormat) {
					droppedFiles = dragSource.dataForFormat(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				}
				else if (hasFilePromiseListFormat) {
					droppedFiles = dragSource.dataForFormat(ClipboardFormats.FILE_PROMISE_LIST_FORMAT) as Array;
				}
				
				if (droppedFiles) {
					
					if (selectedDocument==null || createNewDocument) {
						createNewDocumentAndSwitchToDesignView(droppedFiles, selectedProject);
					}
					else if (selectedDocument) {
						destination = getDestinationForExternalFileDrop();
						addFileListDataToDocument(selectedDocument, droppedFiles as Array, destination);
					}
					else {
						
					}
				}
				
			}
			
			// Error: Attempt to access a dead clipboard
			//  at flash.desktop::Clipboard/checkAccess()
			//  at flash.desktop::Clipboard/getData()
			// Occurs when accessing a dragSource at a later time than the drop event
			// droppedFiles = dragSource.dataForFormat(ClipboardFormats.FILE_LIST_FORMAT) as Array;
		}
		
		/**
		 * Duplicates the selected items
		 * */
		public function duplicateItem(component:Object, destination:Object = null):Array {
			var exportOptions:ExportOptions;
			var sourceData:SourceData;
			var componentDescription:ComponentDescription;
			var newTargets:Array;
			
			exportOptions = new ExportOptions();
			exportOptions.useInlineStyles = true;
			exportOptions.exportChildDescriptors = true;
			
			if (selectedDocument) {
				if (component is ComponentDescription) {
					componentDescription = component as ComponentDescription;
				}
				else {
					componentDescription = selectedDocument.getItemDescription(component);
				}
			}
			else {
				warn("Please open a document before attempting to duplicate");
				return null;
			}
			
			// copy selection
			if (componentDescription) {
				sourceData = CodeManager.getSourceData(componentDescription, selectedDocument, CodeManager.MXML, exportOptions);
			}
			else {
				warn("Could not find item to duplicate in the selected document");
				return null;
			}
			
			// get destination
			if (destination && !(destination is IVisualElementContainer)) {
				destination = destination.owner;
			}
			
			// prevent containers from being duplicated into themselves
			if (componentDescription.instance==destination) {
				if (selectedDocument.instance.contains(destination.owner)) {
					destination = destination.owner;
				}
			}
			
			if (!destination) {
				if (componentDescription.parent) {
					destination = componentDescription.parent.instance;
				}
				
				if (!destination) {
					destination = selectedDocument.instance;
				}
			}
			
			// add duplicate
			sourceData = CodeManager.setSourceData(sourceData.source, destination, selectedDocument, CodeManager.MXML, null);
			
			// dispatch added items
			dispatchAddEvent(sourceData.targets, null, null);
			
			// select first target
			if (sourceData && sourceData.targets && sourceData.targets.length) { 
				setTarget(sourceData.targets[0], true, null, true);
			}
			else {
				setTarget(destination);
			}
			
			newTargets = sourceData.targets.slice();
			
			sourceData = null;
			
			return newTargets;
		}
		
		/**
		 * Used on select event when browsing for file
		 * */
		public function selectItem(files:Object):void {
			var destination:Object;
			var filesToAdd:Array = [];
			
			if (files is FileReferenceList) {
				filesToAdd = FileReferenceList(files).fileList;
			}
			else if (files is FileReference) {
				filesToAdd = [files];
			}
			else if (files is Array) {
				filesToAdd = (files as Array).slice();
			}
			
			if (filesToAdd && filesToAdd.length) {
				destination = getDestinationForExternalFileDrop();
				documentThatPasteOfFilesToBeLoadedOccured = selectedDocument;
				addFileListDataToDocument(selectedDocument, filesToAdd, destination);
			}
			else {
				warn("No files were selected.");
			}
				
		}
		
		/**
		 * Add file list data to a document
		 * */
		public function addFileListDataToDocument(iDocument:IDocument, fileList:Array, destination:Object = null, operation:String = "drop"):void {
			var createDocument:Boolean = false;
			
			if (fileList==null) {
				error("Not a valid file list");
				return;
			}
			
			if (fileList && fileList.length==0) {
				error("No files in the file list");
				return;
			}
			
			if (iDocument==null) {
				
				if (createDocument) {
					iDocument = createNewDocumentAndSwitchToDesignView(fileList);
				}
				else {
					error("No document is open. Create a new document first. ");
					return;
				}
			}
			
			var urlFormatData:Object;
			var path_txt:String;
			var extension:String;
			var fileSafeList:Array = [];
			var hasPSD:Boolean;
			var hasMXML:Boolean;
			
			// only accepting image files at this time
			for each (var file:FileReference in fileList) {
				extension = file.extension.toLowerCase();
				
				if (extension=="png" || 
					extension=="jpg" || 
					extension=="jpeg" || 
					extension=="gif") {
					fileSafeList.push(file);
				}
				else if (extension=="psd") {
					fileSafeList.push(file);
					hasPSD = true;
				}
				else if (extension=="mxml") {
					fileSafeList.push(file);
					hasMXML = true;
				}
				else {
					path_txt = "Not a recognised file format";  
				}
			}
			
			var fileLoader:LoadFile;
			
			const PASTE:String = "paste";
			const DROP:String = "drop";
			
			if (operation==PASTE) {
				setupPasteFileLoader();
				fileLoader = pasteFileLoader;
			}
			else if (operation==DROP) {
				setupDropFileLoader();
				fileLoader = dropFileLoader;
			}
			
			
			fileLoader.removeReferences(true);
			
			
			if (!hasPSD && !hasMXML) {
				fileLoader.loadIntoLoader = true;
			}
			else {
				fileLoader.loadIntoLoader = false;
			}
			
			if (fileSafeList.length>0) {
				
				if (fileSafeList.length>1 && hasPSD) {
					warn("You cannot load a PSD and image files at the same time. Select one or the other");
					return;
				}
				else if (fileSafeList.length>1 && hasMXML) {
					warn("You cannot load a MXML file and other files at the same time. Select one or the other");
					return;
				}
				
				if (hasPSD) {
					loadingPSD = true;
				}
				else 
				if (hasMXML) {
					loadingMXML = true;
				}
				else {
					loadingPSD = false;
				}
				
				documentThatPasteOfFilesToBeLoadedOccured = iDocument;
				
				fileLoader.filesArray = fileSafeList;
				fileLoader.play();
			}
			else {
				documentThatPasteOfFilesToBeLoadedOccured = null;
				info("No files of the acceptable type were found. Acceptable files are PNG, JPEG, GIF, PSD");
			}
		}
		
		public var pasteFileLoader:LoadFile;
		public var dropFileLoader:LoadFile;
		public var documentThatPasteOfFilesToBeLoadedOccured:IDocument;
		public var loadingMXML:Boolean;
		public var loadingPSD:Boolean;
		
		protected function setupPasteFileLoader():void {
			if (pasteFileLoader==null) {
				pasteFileLoader = new LoadFile();
				pasteFileLoader.addEventListener(LoadFile.LOADER_COMPLETE, pasteFileCompleteHandler, false, 0, true);
				pasteFileLoader.addEventListener(LoadFile.COMPLETE, pasteFileCompleteHandler, false, 0, true);
			}
		}
		
		protected function setupDropFileLoader():void {
			if (dropFileLoader==null) {
				dropFileLoader = new LoadFile();
				dropFileLoader.addEventListener(LoadFile.LOADER_COMPLETE, dropFileCompleteHandler, false, 0, true);
				dropFileLoader.addEventListener(LoadFile.COMPLETE, dropFileCompleteHandler, false, 0, true);
			}
		}
		
		/**
		 * Occurs after files pasted into the document are fully loaded 
		 * */
		protected function pasteFileCompleteHandler(event:Event):void {
			var resized:Boolean;
			var imageData:ImageData;
			
			// if we need to load the images ourselves then skip complete event
			// and wait until loader complete event
			if (dropFileLoader.loadIntoLoader && event.type!=LoadFile.LOADER_COMPLETE) {
				return;
			}
			
			if (!documentThatPasteOfFilesToBeLoadedOccured) {
				error("No document was found to paste a file into");
				return;
			}
			
			if (loadingPSD) {
				loadingPSD = false;
				info("Importing PSD");
				callAfter(250, addPSDToDocument, pasteFileLoader.data, documentThatPasteOfFilesToBeLoadedOccured);
				return;
			}
			
			if (loadingMXML) {
				loadingMXML = false;
				info("Importing MXML");
				callAfter(250, importMXMLDocument, selectedProject, documentThatPasteOfFilesToBeLoadedOccured, documentThatPasteOfFilesToBeLoadedOccured.instance, pasteFileLoader.dataAsString);
				//addPSDToDocument(pasteFileLoader.data, documentThatPasteOfFilesToBeLoadedOccured);
				return;
			}
			
			imageData = new ImageData();
			imageData.bitmapData = pasteFileLoader.bitmapData;
			imageData.byteArray = pasteFileLoader.data;
			imageData.name = pasteFileLoader.currentFileReference.name;
			imageData.contentType = pasteFileLoader.loaderContentType;
			imageData.file = pasteFileLoader.currentFileReference;
			
			addAssetToDocument(imageData, documentThatPasteOfFilesToBeLoadedOccured);
			resized = addImageDataToDocument(imageData, documentThatPasteOfFilesToBeLoadedOccured);
			
			//uploadAttachment(fileLoader.fileReference);
			if (resized) {
				info("Image was added to the library and the document and resized to fit");
			}
			else {
				info("Image was added to the library and the document");
			}
			
			setTarget(lastCreatedComponent);
			
			dispatchAssetLoadedEvent(imageData, documentThatPasteOfFilesToBeLoadedOccured, resized, true);
		}
		
		/**
		 * Occurs after files are dropped into the document are fully loaded 
		 * */
		protected function dropFileCompleteHandler(event:Event):void {
			var resized:Boolean;
			var imageData:ImageData;
			
			// if we need to load the images ourselves then skip complete event
			// and wait until loader complete event
			if (dropFileLoader.loadIntoLoader && event.type!=LoadFile.LOADER_COMPLETE) {
				return;
			}
			
			if (!documentThatPasteOfFilesToBeLoadedOccured) {
				error("No document was found to add a file into");
				return;
			}
			
			if (loadingPSD) {
				loadingPSD = false;
				info("Importing PSD");
				callAfter(250, addPSDToDocument, dropFileLoader.data, documentThatPasteOfFilesToBeLoadedOccured);
				return;
			}
			
			if (loadingMXML) {
				loadingMXML = false;
				info("Importing MXML");
				callAfter(250, importMXMLDocument, selectedProject, documentThatPasteOfFilesToBeLoadedOccured, documentThatPasteOfFilesToBeLoadedOccured.instance, dropFileLoader.dataAsString);
				//addPSDToDocument(pasteFileLoader.data, documentThatPasteOfFilesToBeLoadedOccured);
				return;
			}
			
			imageData = new ImageData();
			imageData.bitmapData = dropFileLoader.bitmapData;
			imageData.byteArray = dropFileLoader.data;
			imageData.name = dropFileLoader.currentFileReference.name;
			imageData.contentType = dropFileLoader.loaderContentType;
			imageData.file = dropFileLoader.currentFileReference;
			
			addAssetToDocument(imageData, documentThatPasteOfFilesToBeLoadedOccured);
			resized = addImageDataToDocument(imageData, documentThatPasteOfFilesToBeLoadedOccured);
			//list.selectedItem = data;
			
			//uploadAttachment(fileLoader.fileReference);
			
			if (resized) {
				info("An image was added to the library and the document and resized to fit");
			}
			else {
				info("An image was added to the library");
			}
			
			setTarget(lastCreatedComponent);
			
			dispatchAssetLoadedEvent(imageData, documentThatPasteOfFilesToBeLoadedOccured, resized, true);
		}
		
		/**
		 * Add bitmap data to a document
		 * */
		public function addBitmapDataToDocument(iDocument:IDocument, bitmapData:BitmapData, destination:Object = null):void {
			if (bitmapData==null) {
				error("Not valid bitmap data");
			}
			if (iDocument==null) {
				error("Not a valid document");
			}
			
			if (bitmapData==null || iDocument==null) {
				return;
			}
			
			var imageData:ImageData = new ImageData();
			var name:String;
			
			imageData.bitmapData = bitmapData;
			imageData.byteArray = DisplayObjectUtils.getBitmapByteArray(bitmapData);
			
			if (destination) {
				name = ClassUtils.getIdentifierNameOrClass(destination) + ".png";
			}
			else {
				name = ClassUtils.getIdentifierNameOrClass(bitmapData) + ".png";
			}
			
			imageData.name = name;
			imageData.contentType = DisplayObjectUtils.PNG_MIME_TYPE;
			imageData.file = null;
			
			addAssetToDocument(imageData, iDocument);
			
			info("An image from the clipboard was added to the library");
		}
		
		/**
		 * Add text data to a document
		 * */
		public function addTextDataToDocument(iDocument:IDocument, text:String, destination:Object = null):void {
			if (text==null || text=="") {
				error("Not valid text data");
			}
			if (iDocument==null) {
				error("Not a valid document");
			}
			
			if (text==null || iDocument==null) {
				return;
			}
			
			var definition:ComponentDefinition =  getDynamicComponentType("spark.components.Label", true);
			var component:Label = createComponentToAdd(iDocument, definition, false) as Label;
			
			// not sure why we're adding it
			addElement(component, destination, ["text"], null, null, {text:text});
			
			updateComponentAfterAdd(iDocument, component);
			
			//info("Text from the clipboard was added to the document");
		}
		
		/**
		 * Add html data to a document. The importer is awful 
		 * */
		public function addHTMLDataToDocument(iDocument:IDocument, text:String, destination:Object = null):void {
			if (text==null || text=="") {
				error("Not valid text data");
			}
			if (iDocument==null) {
				error("Not a valid document");
			}
			
			if (text==null || iDocument==null) {
				return;
			}
			
			var definition:ComponentDefinition =  getDynamicComponentType("spark.components.RichText", true);
			
			if (!definition) {
				return;
			}
			
			var componentInstance:RichText = createComponentToAdd(iDocument, definition, false) as RichText;
			var formatter:HTMLFormatterTLF = HTMLFormatterTLF.staticInstance;
			var translatedHTMLText:String;
			var textFlow:TextFlow;
			
			formatter.replaceLinebreaks = true;
			formatter.replaceMultipleBreaks = true;
			formatter.replaceEmptyBlockQoutes = true;
			translatedHTMLText = formatter.format(text);
			textFlow = TextConverter.importToFlow(translatedHTMLText, TextConverter.TEXT_FIELD_HTML_FORMAT);
			
			componentInstance.textFlow = textFlow;
			
			addElement(componentInstance, destination, ["textFlow"], null, null, {textFlow:textFlow});
			
			updateComponentAfterAdd(iDocument, componentInstance);
			
			//info("HTML from the clipboard was added to the library");
		}
		
		public static var acceptablePasteFormats:Array = ["Object", "UIComponent", "air:file list", 
														"air:url", "air:bitmap", "air:text"];
		public static var acceptableDropFormats:Array = ["UIComponent", "air:file list", "air:url", "air:bitmap"];
		
		/**
		 * Returns true if it's a type of content we can accept to be pasted in
		 * */
		public static function isAcceptablePasteFormat(formats:Array):Boolean {
			if (formats==null || formats.length==0) return false;
			
			if (ArrayUtils.containsAny(formats, acceptablePasteFormats)) {
				return true;
			}
			
			return false;
		}
		
		/**
		 * Returns true if it's a type of content we can accept to be dragged and dropped.
		 * If we are dragging a UIComponent we don't want to accept it by default because
		 * it could be us dragging a component around the design view
		 * */
		public static function isAcceptableDragAndDropFormat(dragSource:DragSource, includeUIComponents:Boolean = false):Boolean {
			if (dragSource==null) return false;
			
			if ((dragSource.hasFormat("UIComponent") && includeUIComponents) || 
				dragSource.hasFormat("air:file list") || 
				dragSource.hasFormat("air:url") || 
				dragSource.hasFormat("air:bitmap")) {
				var url:String;
				
				// if internal html preview is visible we should return false since
				// dragged images are triggering the drop panel
				if (instance.isDocumentPreviewOpen(instance.selectedDocument) && 
					dragSource.hasFormat("air:url")) {
					// http://www.radii8.com/.../image.jpg
					//url = dragSource.dataForFormat(ClipboardFormats.URL_FORMAT) as String;
					return false;
				}
				return true;
			}
			
			return false;
		}
		
		/**
		 * Issue when loading with no there is no connection
		 * */
		public function resizeFix(secondResize:Boolean = false):void {
			// i don't understand why loading a local SWF breaks the UI but resizing the application 
			// fixes
			var systemManager:ISystemManager = application.systemManager;
			var component:Object;
			if ((systemManager != null) && (systemManager.stage != null)) {
				component = systemManager.stage.nativeWindow;
			}
			else {
				return;
			}
			var width:int = component.width;
			var height:int = component.height;
			var offset:int = 1;
			
			if (secondResize) {
				component.width = width - offset;
				component.height = height - offset;
			}
			else {
				component.width = width+offset;
				component.height = height+offset;
				
				application.invalidateSize();
				application.invalidateDisplayList();
				
				component.startResize("BR");
			}
			//component.validateNow();
			//stage.nativeWindow.startResize(start);
			//application.validateNow();
		}
		
		/**
		 * Creates a new project and document and if a file is 
		 * provided then it imports the file and sizes the document to the fit. 
		 * 
		 * This is to support drag and drop of file onto application icon
		 * and open with methods. 
		 * */
		public function createNewDocumentAndSwitchToDesignView(file:Object = null, iProject:Object = null):IDocument {
			var documentName:String = "Document";
			var iDocument:IDocument;
			
			fileToBeLoaded = file;
			
			mainView.goToDesignState();
			
			if (fileToBeLoaded) {
				addEventListener(RadiateEvent.DOCUMENT_OPEN, documentOpenedHandler, false, 0, true);
			}
			
			iDocument = createBlankDemoDocument(iProject, documentName);
			
			
			if (isUserLoggedIn && iDocument) {
				saveProjectOnly(iDocument.project);
			}
			
			return iDocument
		}
		
		public var fileToBeLoaded:Object;
		
		public function documentOpenedHandler(event:RadiateEvent):void {
			var iDocument:IDocument = event.selectedItem as IDocument;
			var newFile:Object = fileToBeLoaded;
			var destination:Object;
			
			if (newFile is FileReference) {
				if (newFile.exists && newFile.isDirectory==false) {
					addEventListener(RadiateEvent.ASSET_LOADED, fileLoadedHandler, false, 0, true);
					addFileListDataToDocument(iDocument, [newFile]);
				}
			}
			else if (newFile is DragEvent) {
				dropItem(newFile as DragEvent);
			}
			else if (newFile is Array && newFile.length) {
				//destination = getDestinationForExternalFileDrop();
				addFileListDataToDocument(selectedDocument, fileToBeLoaded as Array);
			}
			
			removeEventListener(RadiateEvent.DOCUMENT_OPEN, documentOpenedHandler);
		}
		
		protected function fileLoadedHandler(event:RadiateEvent):void {
			var successful:Boolean = event.successful;
			var imageData:ImageData = event.data as ImageData;
			var iDocument:IDocument = event.selectedItem as IDocument;
			var importedImageResized:Boolean = event.resized;
			var bitmapData:BitmapData = imageData && imageData.bitmapData ? imageData.bitmapData : null;
			var fileReference:FileReference;
			
			removeEventListener(RadiateEvent.ASSET_LOADED, fileLoadedHandler);
			
			if (!successful) {
				warn("File was not imported.");
				return;
			}
			
			if (bitmapData && bitmapData.width>0 && bitmapData.height>0) {
				sizeDocumentToBitmapData(iDocument, bitmapData);
				
				if (importedImageResized && target) {
					sizeSelectionToDocument();
				}
				
				scaleToFit(false);
				centerApplication();
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
			
			// convert to string and then import to selected target or document
			//var options:ExportOptions = new ExportOptions();
			//options.useInlineStyles = true;
			
			//var sourceItemData:SourceData = CodeManager.getSourceData(target, selectedDocument, CodeManager.MXML, options);
			
			
			if (copiedData) {
				return copiedData;
			}
			else if (cutData) {
				return cutData;
			}
			
			//Clipboard.generalClipboard.setData(ClipboardFormats.HTML_FORMAT, );
		}
		
		/**
		 * Get values object from attributes and child tags on a component from XML node
		 * */
		public static function getPropertiesStylesEventsFromNode(elementInstance:Object, node:XML, item:ComponentDefinition = null):ValuesObject {
			var elementName:String = node.localName();
			var attributeName:String;
			var attributes:Array;
			var childNodeNames:Array;
			var qualifiedChildNodeNames:Array;
			var childNodeNamespaces:Array;
			var propertiesStylesEvents:Array;
			var properties:Array;
			var styles:Array;
			var events:Array;
			var attributesValueObject:Object;
			var childNodeValueObject:Object;
			var values:Object;
			var valuesObject:ValuesObject;
			var failedToImportStyles:Object = {};
			var failedToImportProperties:Object = {};
			var qualifiedAttributes:Array;
			
			attributes 				= XMLUtils.getAttributeNames(node);
			qualifiedAttributes 	= XMLUtils.getQualifiedAttributeNames(node);
			childNodeNames 			= XMLUtils.getChildNodeNames(node);
			childNodeNamespaces		= XMLUtils.getChildNodeNamesNamespace(node, true);
			qualifiedChildNodeNames	= XMLUtils.getQualifiedChildNodeNames(node);
			propertiesStylesEvents 	= attributes.concat(childNodeNames);
			properties 				= ClassUtils.getPropertiesFromArray(elementInstance, propertiesStylesEvents, true);
			styles 					= ClassUtils.getStylesFromArray(elementInstance, propertiesStylesEvents);
			events 					= ClassUtils.getEventsFromArray(elementInstance, propertiesStylesEvents);
			
			attributesValueObject 	= XMLUtils.getAttributesValueObject(node);
			attributesValueObject	= ClassUtils.getTypedStyleValueObject(elementInstance as IStyleClient, attributesValueObject, styles, failedToImportStyles);
			attributesValueObject	= ClassUtils.getTypedPropertyValueObject(elementInstance, attributesValueObject, properties, failedToImportProperties);
			
			childNodeValueObject 	= XMLUtils.getChildNodesValueObject(node, true, true, false);
			values 					= ObjectUtils.merge(attributesValueObject, childNodeValueObject);
			
			
			valuesObject 							= new ValuesObject();
			valuesObject.values 					= values;
			valuesObject.events		 				= events;
			valuesObject.styles 					= styles;
			valuesObject.properties 				= properties;
			valuesObject.attributes 				= attributes;
			valuesObject.qualifiedAttributes		= qualifiedAttributes;
			valuesObject.childNodeNames 			= childNodeNames;
			valuesObject.qualifiedChildNodeNames 	= qualifiedChildNodeNames;
			valuesObject.childNodeValues 			= childNodeValueObject;
			valuesObject.stylesErrorsObject 		= failedToImportStyles;
			valuesObject.propertiesErrorsObject 	= failedToImportProperties;
			valuesObject.propertiesStylesEvents		= properties.concat(styles).concat(events);
			valuesObject.attributesNotFound			= ArrayUtils.removeAllItems(attributes, valuesObject.propertiesStylesEvents);
			//valuesObject.nonNsAttributesNotFound	= ArrayUtils.removeAllItems(qualifiedAttributes, valuesObject.propertiesStylesEvents);
			
			/*
			var a:Object = node.namespace().prefix;     //returns prefix i.e. rdf
			var b:Object = node.namespace().uri;        //returns uri of prefix i.e. http://www.w3.org/1999/02/22-rdf-syntax-ns#
			
			var c:Object = node.inScopeNamespaces();   //returns all inscope namespace as an associative array like above
			
			//returns all nodes in an xml doc that use the namespace
			var nsElement:Namespace = new Namespace(node.namespace().prefix, node.namespace().uri);
			
			var usageCount:XMLList = node..nsElement::*;*/
			
			return valuesObject;
		}
		
		/**
		 * Get value object on a component from a properties object
		 * */
		public static function getPropertiesStylesFromObject(elementInstance:Object, dataObject:Object, item:ComponentDefinition = null):ValuesObject {
			var properties:Array;
			var styles:Array;
			var aValueObject:Object;
			var childNodeValueObject:Object;
			var valuesObject:ValuesObject;
			var values:Object = {};
			var failedToImportStyles:Object = {};
			var failedToImportProperties:Object = {};
			
			properties 				= ClassUtils.getPropertiesFromObject(elementInstance, dataObject, true);
			styles 					= ClassUtils.getStylesFromObject(elementInstance, dataObject);
			
			values					= ClassUtils.getTypedPropertyValueObject(elementInstance, dataObject, properties, failedToImportProperties);
			values					= ClassUtils.getTypedStyleValueObject(elementInstance as IStyleClient, dataObject, styles, failedToImportStyles);
			
			
			valuesObject 						= new ValuesObject();
			valuesObject.values 				= values;
			valuesObject.styles 				= styles;
			valuesObject.properties 			= properties;
			valuesObject.stylesErrorsObject 	= failedToImportStyles;
			valuesObject.propertiesErrorsObject = failedToImportProperties;
			valuesObject.propertiesStylesEvents	= properties.concat(styles);
			
			
			return valuesObject;
		}
		
		/**
		 * Removes explict size on a component object because 
		 * we are setting default width and height when creating the component.
		 * I don't know a better way to do this. Maybe use setActualSize but I 
		 * don't think the size stays if you go back and forth in history???
		 * */
		public static function removeExplictSizeOnComponent(elementInstance:Object, node:XML, item:ComponentDefinition = null, dispatchEvents:Boolean = false):void {
			var attributeName:String;
			var elementName:String = node.localName();
			
			var hasWidthAttribute:Boolean = ("@width" in node);
			var hasHeightAttribute:Boolean = ("@height" in node);
			var hasWidthDefault:Boolean = item.defaultProperties && item.defaultProperties.width;
			var hasHeightDefault:Boolean = item.defaultProperties && item.defaultProperties.height;
			
			
			// a default height was set but the user removed it so we need to remove it
			// flex doesn't support a height="auto" or height="content" type of value 
			// flex just removes the height attribute in XML altogether 
			// so if it is not in the mxml then we have to set the size to undefined 
			if (hasHeightDefault && !hasHeightAttribute) {
				//setProperty(elementInstance, "height", undefined, null, true, dispatchEvents);
				elementInstance["height"] = undefined;
			}
			
			if (hasWidthDefault && !hasWidthAttribute) {
				//setProperty(elementInstance, "width", undefined, null, true, dispatchEvents);
				elementInstance["width"] = undefined;
			}
		}
		
		/**
		 * Set attributes on a component object
		 * */
		public static function setAttributesOnComponent(elementInstance:Object, node:XML, item:ComponentDefinition = null, dispatchEvents:Boolean = false):void {
			var attributeName:String;
			var elementName:String = node.localName();
			//var domain:ApplicationDomain = ApplicationDomain.currentDomain;
			//var componentDefinition:ComponentDefinition = Radiate.getComponentType(elementName);
			//var className:String =componentDefinition ? componentDefinition.className :null;
			//var classType:Class = componentDefinition ? componentDefinition.classType as Class :null;
			//var elementInstance:Object = componentDescription.instance;
			
			var properties:Array = [];
			var styles:Array = [];
			var valueObject:Object = {};
			
			for each (var attribute:XML in node.attributes()) {
				attributeName = attribute.name().toString();
				//Radiate.info(" found attribute: " + attributeName); 
				
				
				// TODO we should check if an attribute is an property, style or event using the component definition
				// We can do it this way now since we are only working with styles and properties
				
				
				// check if property 
				if (attributeName in elementInstance) {
					
					//Radiate.info(" setting property: " + attributeName);
					//setProperty(elementInstance, attributeName, attribute.toString(), null, false, dispatchEvents);
				 	properties.push(attributeName);
					valueObject[attributeName] = attribute.toString();
				}
				
				// could be style or event
				else {
					if (elementInstance is IStyleClient) {
						//Radiate.info(" setting style: " + attributeName);
						//setStyle(elementInstance, attributeName, attribute.toString(), null, false, dispatchEvents);
						styles.push(attributeName);
						valueObject[attributeName] = attribute.toString();
					}
				}
			}
			
			if (styles.length || properties.length) {
				var propertiesStyles:Array = styles.concat(properties);
				setPropertiesStylesEvents(elementInstance, propertiesStyles, valueObject);
			}
			
			
			removeExplictSizeOnComponent(elementInstance, node, item);
		}
		
		/**
		 * Returns true if the style was cleared.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.clearStyle(myButton, "fontFamily");</pre>
		 * */
		public static function clearStyle(target:Object, style:String, description:String = null, dispatchEvents:Boolean = true):Boolean {
			
			return setStyle(target, style, undefined, description, true, dispatchEvents);
		}
		
		/**
		 * Clears the styles of the target.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.clearStyles(myButton, ["fontFamily", "fontWeight"]);</pre>
		 * */
		public static function clearStyles(target:Object, styles:Array, description:String = null, dispatchEvents:Boolean = true):Boolean {
			var object:Object = {};
			var numberOfStyles:uint = styles.length;
			
			for (var i:int;i<numberOfStyles;i++) {
				object[styles[i]] = undefined;
			}
			
			return setStyles(target, styles, object, description, true, dispatchEvents);
		}
		
		/**
		 * Returns true if the property was cleared.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.clearProperty(myButton, "width");</pre>
		 * */
		public static function clearProperty(target:Object, property:String, description:String = null, dispatchEvents:Boolean = true):Boolean {
			
			return setProperty(target, property, undefined, description, true, dispatchEvents);
		}
		
		/**
		 * Returns true if the property was cleared.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.clearProperties(myButton, ["width", "percentWidth"]);</pre>
		 * */
		public static function clearProperties(target:Object, properties:Array, description:String = null, dispatchEvents:Boolean = true):Boolean {
			var object:Object = {};
			var numberOfProperties:uint = properties.length;
			
			for (var i:int;i<numberOfProperties;i++) {
				object[properties[i]] = undefined;
			}
			
			return setProperties(target, properties, object, description, true, dispatchEvents);
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
			
			styleChanges = createPropertyChange(targets, null, style, null, value, description);
			
			
			if (!keepUndefinedValues) {
				styleChanges = stripUnchangedValues(styleChanges);
			}
			
			if (changesAvailable(styleChanges)) {
				applyChanges(targets, styleChanges, null, style, null);
				//LayoutManager.getInstance().validateNow(); // applyChanges calls this
				
				historyEvents = HistoryManager.createHistoryEventItems(targets, styleChanges, null, style, null, value);
				
				updateComponentStyles(targets, styleChanges, [style]);
				
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.addHistoryEvents(instance.selectedDocument, historyEvents, description);
				}
				
				if (dispatchEvents) {
					instance.dispatchPropertyChangeEvent(targets, styleChanges, null, ArrayUtil.toArray(style), null);
				}
				return true;
			}
			
			return false;
		}
		
		/**
		 * Checks if changes are available. 
		 * */
		public static function changesAvailable(changes:Array):Boolean {
			var numberOfChanges:int = changes.length;
			var changesAvailable:Boolean;
			var item:PropertyChanges;
			var name:String;
			
			for (var i:int;i<numberOfChanges;i++) {
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
		
		/**
		 * Apply changes to targets. You do not call this. Set properties through setProperties method. 
		 * 
		 * @param setStartValues applies the start values rather 
		 * than applying the end values
		 * 
		 * @param property string or array of strings containing the 
		 * names of the properties to set or null if setting styles
		 * 
		 * @param style string or array of strings containing the 
		 * names of the styles to set or null if setting properties
		 * 
		 * @param event string or array of strings containing the 
		 * names of the events to set
		 * */
		public static function applyChanges(targets:Array, changes:Array, property:*, style:*, event:*, setStartValues:Boolean=false, validateLayout:Boolean = true):Boolean {
			var numberOfChanges:int = changes ? changes.length : 0;
			var effect:HistoryEffect = new HistoryEffect();
			var onlyPropertyChanges:Array = [];
			var directApply:Boolean = true;
			
			for (var i:int;i<numberOfChanges;i++) {
				if (changes[i] is PropertyChanges) { 
					onlyPropertyChanges.push(changes[i]);
				}
			}
			
			effect.targets = targets;
			effect.propertyChangesArray = onlyPropertyChanges;
			
			
			effect.relevantEvents = ArrayUtil.toArray(event);
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
				if (validateLayout) {
					LayoutManager.getInstance().validateNow();
				}
			}
				
			// this works for properties but not styles
			// the style value is restored at the end 
			// update: are you sure?
			else {
				
				effect.applyEndValuesWhenDone = false;
				effect.play(targets, setStartValues);
				effect.playReversed = false;
				effect.end();
				
				if (validateLayout) {
					LayoutManager.getInstance().validateNow();
				}
			}
			
			return true;
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
			var historyEventItems:Array;
			
			propertyChanges = createPropertyChange(targets, property, null, null, value, description);
			
			
			if (!keepUndefinedValues) {
				propertyChanges = stripUnchangedValues(propertyChanges);
			}
			
			if (changesAvailable(propertyChanges)) {
				applyChanges(targets, propertyChanges, property, null, null);
				//LayoutManager.getInstance().validateNow(); // applyChanges calls this
				//addHistoryItem(propertyChanges, description);
				
				historyEventItems = HistoryManager.createHistoryEventItems(targets, propertyChanges, property, null, null, value);
				
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.addHistoryEvents(instance.selectedDocument, historyEventItems, description);
				}
				
				updateComponentProperties(targets, propertyChanges, [property]);
				
				if (dispatchEvents) {
					instance.dispatchPropertyChangeEvent(target, propertyChanges, ArrayUtil.toArray(property), null, null);
				}
				
				if (dispatchEvents) {
					if (targets.indexOf(instance.selectedDocument.instance)!=-1 && ArrayUtils.containsAny(notableApplicationProperties, [property])) {
						instance.dispatchDocumentSizeChangeEvent(target);
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
		public static function setProperties(target:Object, properties:Array, value:*, description:String = null, keepUndefinedValues:Boolean = false, dispatchEvents:Boolean = true):Boolean {
			var propertyChanges:Array;
			var historyEvents:Array;
			var targets:Array;
			
			targets = ArrayUtil.toArray(target);
			properties = ArrayUtil.toArray(properties);
			propertyChanges = createPropertyChanges(targets, properties, null, null, value, description, false);
			
			if (!keepUndefinedValues) {
				propertyChanges = stripUnchangedValues(propertyChanges);
			}
			
			if (changesAvailable(propertyChanges)) {
				applyChanges(targets, propertyChanges, properties, null, null);
				//LayoutManager.getInstance().validateNow();
				//addHistoryItem(propertyChanges);
				
				historyEvents = HistoryManager.createHistoryEventItems(targets, propertyChanges, properties, null, null, value);
				
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.addHistoryEvents(instance.selectedDocument, historyEvents, description);
				}
				
				updateComponentProperties(targets, propertyChanges, properties);
				
				if (dispatchEvents) {
					instance.dispatchPropertyChangeEvent(targets, propertyChanges, properties, null, null);
				}
				
				if (targets.indexOf(instance.selectedDocument)!=-1 && ArrayUtils.containsAny(notableApplicationProperties, properties)) {
					instance.dispatchDocumentSizeChangeEvent(targets);
				}
				
				return true;
			}
			
			return false;
		}
		
		/**
		 * Sets the style on the target object.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>setStyles([myButton,myButton2], ["fontSize","fontFamily"], {fontSize:20,fontFamily:"Arial"});</pre>
		 * <pre>setStyles(button, ["fontSize", "fontFamily"], {fontSize:10,fontFamily:"Arial"});</pre>
		 * 
		 * @see setStyle()
		 * @see setProperty()
		 * @see setProperties()
		 * */
		public static function setStyles(target:Object, styles:Array, value:*, description:String = null, keepUndefinedValues:Boolean = false, dispatchEvents:Boolean = true):Boolean {
			var stylesChanges:Array;
			var historyEvents:Array;
			var targets:Array;
			
			targets = ArrayUtil.toArray(target);
			styles = ArrayUtil.toArray(styles);
			stylesChanges = createPropertyChanges(targets, null, styles, null, value, description, false);
			
			if (!keepUndefinedValues) {
				stylesChanges = stripUnchangedValues(stylesChanges);
			}
			
			if (changesAvailable(stylesChanges)) {
				applyChanges(targets, stylesChanges, null, styles, null);
				//LayoutManager.getInstance().validateNow();
				
				historyEvents = HistoryManager.createHistoryEventItems(targets, stylesChanges, null, styles, null, value);
				
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.addHistoryEvents(instance.selectedDocument, historyEvents, description);
				}
				
				updateComponentStyles(targets, stylesChanges, styles);
				
				if (dispatchEvents) {
					instance.dispatchPropertyChangeEvent(targets, stylesChanges, null, styles, null);
				}
				
				return true;
			}
			
			return false;
		}
		
		/**
		 * Sets the properties or styles of target or targets. Returns true if the properties or styles were changed.<br/><br/>
		 * 
		 * Usage:<br/>
<pre>
setPropertiesStyles([myButton,myButton2], ["x","y","color"], {x:40,y:50,color:"0xFF0000"});
setPropertiesStyles(myButton, "x", 40);
setPropertiesStyles(button, ["x", "left"], {x:50,left:undefined});
</pre>
		 * 
		 * @see setStyle()
		 * @see setStyles()
		 * @see setProperty()
		 * @see setProperties()
		 * */
		public static function setPropertiesStylesEvents(target:Object, propertiesStylesEvents:Array, value:*, description:String = null, keepUndefinedValues:Boolean = false, dispatchEvents:Boolean = true):Boolean {
			var propertyChanges:Array;
			var historyEvents:Array;
			var targets:Array;
			var properties:Array;
			var styles:Array;
			var events:Array;
			
			targets = ArrayUtil.toArray(target);
			propertiesStylesEvents = ArrayUtil.toArray(propertiesStylesEvents);
			
			// TODO: Add support for multiple targets
			styles = ClassUtils.getStylesFromArray(target, propertiesStylesEvents);
			properties = ClassUtils.getPropertiesFromArray(target, propertiesStylesEvents, true);
			events = ClassUtils.getEventsFromArray(target, propertiesStylesEvents);
			
			propertyChanges = createPropertyChanges(targets, properties, styles, events, value, description, false);
			
			if (!keepUndefinedValues) {
				propertyChanges = stripUnchangedValues(propertyChanges);
			}
			
			if (changesAvailable(propertyChanges)) {
				applyChanges(targets, propertyChanges, properties, styles, events);
				//LayoutManager.getInstance().validateNow();
				//addHistoryItem(propertyChanges);
				
				historyEvents = HistoryManager.createHistoryEventItems(targets, propertyChanges, properties, styles, events, value);
				
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.addHistoryEvents(instance.selectedDocument, historyEvents, description);
				}
				
				updateComponentProperties(targets, propertyChanges, properties);
				updateComponentStyles(targets, propertyChanges, styles);
				updateComponentEvents(targets, propertyChanges, events);
				
				if (dispatchEvents) {
					instance.dispatchPropertyChangeEvent(targets, propertyChanges, properties, styles, events);
				}
				
				if (targets.indexOf(instance.selectedDocument)!=-1 && ArrayUtils.containsAny(notableApplicationProperties, propertiesStylesEvents)) {
					instance.dispatchDocumentSizeChangeEvent(targets);
				}
				
				return true;
			}
			
			return false;
		}
		
		/**
		 * Given a target or targets, properties and value object (name value pair)
		 * returns an array of PropertyChange objects.
		 * Value must be an object containing the properties mentioned in the properties array
		 * */
		public static function createPropertyChanges(targets:Array, properties:Array, styles:Array, events:Array, value:Object, description:String = "", storeInHistory:Boolean = true):Array {
			var tempEffect:HistoryEffect = new HistoryEffect();
			var propertyChanges:PropertyChanges;
			var changes:Array;
			var propertStyleEvent:String;
			
			tempEffect.targets = targets;
			tempEffect.relevantEvents = events;
			tempEffect.relevantProperties = properties;
			tempEffect.relevantStyles = styles;
			
			// get start values for undo
			changes = tempEffect.captureValues(null, true);
			
			// This may be hanging on to bindable objects
			// set the values to be set to the property 
			// ..later - what??? give an example
			for each (propertyChanges in changes) {
				
				// for properties 
				for each (propertStyleEvent in properties) {
					
					// value may be an object with properties or a string
					// because we accept an object containing the values with 
					// the name of the properties or styles
					if (value && propertStyleEvent in value) {
						propertyChanges.end[propertStyleEvent] = value[propertStyleEvent];
					}
					else {
						propertyChanges.end[propertStyleEvent] = value;
					}
				}
				
				// for styles
				for each (propertStyleEvent in styles) {
					
					// value may be an object with properties or a string
					// because we accept an object containing the values with 
					// the name of the properties or styles
					if (value && propertStyleEvent in value) {
						propertyChanges.end[propertStyleEvent] = value[propertStyleEvent];
					}
					else {
						propertyChanges.end[propertStyleEvent] = value;
					}
				}
				
				// for event
				for each (propertStyleEvent in events) {
					
					// value may be an object with properties or a string
					// because we accept an object containing the values with 
					// the name of the properties or styles
					if (value && propertStyleEvent in value) {
						propertyChanges.end[propertStyleEvent] = value[propertStyleEvent];
					}
					else {
						propertyChanges.end[propertStyleEvent] = value;
					}
				}
			}
			
			// we should move this out
			// add property changes array to the history dictionary
			if (storeInHistory) {
				return HistoryManager.createHistoryEventItems(targets, changes, properties, styles, events, value, description);
			}
			
			return [propertyChanges];
		}
		
		/**
		 * Given a target or targets, property name and value
		 * returns an array of PropertyChange objects.
		 * Points to createPropertyChanges()
		 * 
		 * @see createPropertyChanges()
		 * */
		public static function createPropertyChange(targets:Array, property:String, style:String, event:String, value:*, description:String = ""):Array {
			var values:Object = {};
			var changes:Array;
			
			if (property) {
				values[property] = value;
			}
			else if (style) {
				values[style] = value;
			}
			else if (event) {
				values[event] = value;
			}
			
			changes = createPropertyChanges(targets, ArrayUtil.toArray(property), ArrayUtil.toArray(style), ArrayUtil.toArray(event), values, description, false);
			
			return changes;
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
		 * Updates the properties on a component description
		 * */
		public static function updateComponentProperties(localTargets:Array, propertyChanges:Array, properties:Array, undo:Boolean = false):void {
			var componentDescription:ComponentDescription;
			var numberOfTargets:int = localTargets.length;
			var numberOfChanges:int = propertyChanges.length;
			var propertyChange:Object;
			var localTarget:Object;
			var property:String;
			var selectedDocument:IDocument = instance.selectedDocument;
			var value:*;
			var numberOfProperties:int = properties ? properties.length : 0;
			
			
			if (numberOfProperties==0) return;
			
			for (var i:int;i<numberOfTargets;i++) {
				localTarget = localTargets[i];
				componentDescription = selectedDocument.getItemDescription(localTarget);
				
				if (componentDescription) {
					
					for (var j:int=0;j<numberOfChanges;j++) {
						propertyChange = propertyChanges[j];
						
						for (var k:int = 0; k < numberOfProperties; k++) {
							property = properties[k];
							
							if (undo) {
								value = propertyChange.start[property];
							}
							else {
								value = propertyChange.end[property];
							}
							
							if (value==null || 
								value==undefined || 
								value=="") {
								//isNaN(value)) {
								delete componentDescription.properties[property];
							}
							else {
								componentDescription.properties[property] = value;
							}
						}
						
						//componentDescriptor.properties = ObjectUtils.merge(propertyChange.end, componentDescriptor.properties);
					}
				}
				
				// remove nulls and undefined values
				
			}
		}
		
		/**
		 * Updates the styles on a component description
		 * */
		public static function updateComponentStyles(localTargets:Array, propertyChanges:Array, styles:Array, undo:Boolean = false):void {
			var componentDescription:ComponentDescription;
			var numberOfTargets:int = localTargets.length;
			var numberOfChanges:int = propertyChanges.length;
			var selectedDocument:IDocument = instance.selectedDocument;
			var propertyChange:Object;
			var localTarget:Object;
			var numberOfStyles:int = styles ? styles.length : 0;
			var style:String;
			var value:*;
			
			if (numberOfStyles==0) return;
			
			for (var i:int;i<numberOfTargets;i++) {
				localTarget = localTargets[i];
				componentDescription = selectedDocument.descriptionsDictionary[localTarget];
				
				if (componentDescription) {
					
					for (var j:int=0;j<numberOfChanges;j++) {
						propertyChange = propertyChanges[j];
						
						for (var k:int = 0; k < numberOfStyles; k++) {
							style = styles[k];
							
							if (undo) {
								value = propertyChange.start[style];
							}
							else {
								value = propertyChange.end[style];
							}
							
							if (value===null || 
								value===undefined || 
								value==="") {
								// || isNaN(value)
								delete componentDescription.styles[style];
							}
							else {
								componentDescription.styles[style] = value;
							}
						}
						
						//componentDescription.styles = ObjectUtils.merge(propertyChange.end, componentDescription.styles);
					}
				}
				
				// remove nulls and undefined values
				
			}
		}
		
		/**
		 * Updates the events on a component description
		 * */
		public static function updateComponentEvents(localTargets:Array, propertyChanges:Array, events:Array, undo:Boolean = false):void {
			var componentDescription:ComponentDescription;
			var numberOfTargets:int = localTargets.length;
			var numberOfChanges:int = propertyChanges.length;
			var selectedDocument:IDocument = instance.selectedDocument;
			var propertyChange:Object;
			var localTarget:Object;
			var numberOfEvents:int = events ? events.length : 0;
			var eventName:String;
			var value:*;
			
			if (numberOfEvents==0) return;
			
			for (var i:int;i<numberOfTargets;i++) {
				localTarget = localTargets[i];
				componentDescription = selectedDocument.descriptionsDictionary[localTarget];
				
				if (componentDescription) {
					
					for (var j:int=0;j<numberOfChanges;j++) {
						propertyChange = propertyChanges[j];
						
						for (var k:int = 0; k < numberOfEvents; k++) {
							eventName = events[k];
							
							if (undo) {
								value = propertyChange.start[eventName];
							}
							else {
								value = propertyChange.end[eventName];
							}
							
							if (value==null || 
								value==undefined || 
								value=="") {
								// || isNaN(value)
								delete componentDescription.events[eventName];
							}
							else {
								componentDescription.events[eventName] = value;
							}
						}
						
						//componentDescription.styles = ObjectUtils.merge(propertyChange.end, componentDescription.styles);
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
		 * Gets the value translated into a type from the styles object. 
		 * */
		public static function getTypedValueFromProperty(target:Object, propertiesObject:Object, properties:Array):Object {
			var typedValuesObject:Object;
			var propertyType:Object;
			
			for (var property:String in properties) {
				propertyType = ClassUtils.getTypeOfProperty(target, property);
				typedValuesObject[property] = getTypedValue(propertiesObject[property], propertyType);
			}
			
			return typedValuesObject;
		}
		
		/**
		 * Gets the value translated into a type from the styles object.
		 * Might be duplicate of 
attributesValueObject	= ClassUtils.getTypedStyleValueObject(elementInstance as IStyleClient, attributesValueObject, styles); 
		 * */
		public static function getTypedValueFromStyles(target:Object, values:Object, styles:Array):Object {
			var typedValuesObject:Object = {};
			var styleType:Object;
			
			for each (var style:String in styles) {
				styleType = ClassUtils.getTypeOfStyle(target, style);
				typedValuesObject[style] = getTypedValue(values[style], styleType);
			}
			
			return typedValuesObject;
		}
		
		
		/**
		 * Move a component in the display list and sets any properties 
		 * such as positioning. Ensures properties, styles and events are 
		 * all valid.<br/><br/>
		 * 
		 * Usage:
<pre>
Radiate.moveElement(new Button(), container, ["width","color","click"], {width:50,color:red,click:"alert('click')"});
</pre>
		 * Usage:
<pre>
Radiate.moveElement(radiate.target, document.instance, ["x"], 15);
</pre>
		 * */
		public static function moveElement2(targetItems:*, 
										   destination:Object, 
										   propertiesStylesEvents:Array,
										   values:Object, 
										   description:String 	= null, 
										   position:String		= AddItems.LAST, 
										   relativeTo:Object	= null, 
										   index:int			= -1, 
										   propertyName:String	= null, 
										   isArray:Boolean		= false, 
										   isStyle:Boolean		= false, 
										   vectorClass:Class	= null,
										   keepUndefinedValues:Boolean = true):String {
			
			var items:Array;
			var item:Object;
			var styles:Array;
			var events:Array;
			var properties:Array;
			
			items = ArrayUtil.toArray(targetItems);
			
			propertiesStylesEvents = ArrayUtil.toArray(propertiesStylesEvents);
			
			for (var i:int = 0; i < items.length; i++)  {
				item = items[i];
				
				if (item) {
					styles = ClassUtils.getStylesFromArray(item, propertiesStylesEvents);
					properties = ClassUtils.getPropertiesFromArray(item, propertiesStylesEvents, true);
					events = ClassUtils.getEventsFromArray(item, propertiesStylesEvents);
				}
			}
			
			return moveElement(targetItems, destination, properties, styles, events, values, description, position, relativeTo, index, propertyName, isArray, isStyle);
			
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
		public static function moveElement(targetItems:*, 
										   destination:Object, 
										   properties:Array, 
										   styles:Array,
										   events:Array,
										   values:Object, 
										   description:String 	= null, 
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
			var historyEventItems:Array;
			var isSameOwner:Boolean;
			var isSameParent:Boolean;
			var removeBeforeAdding:Boolean;
			var currentIndex:int;
			var movingIndexWithinParent:Boolean;
			var targetItem:Object;
			var itemOwner:Object;
			var visualElementParent:Object;
			var visualElementOwner:IVisualElementContainer;
			var applicationGroup:GroupBase;
			
			targetItems = ArrayUtil.toArray(targetItems);
			
			targetItem = targetItems ? targetItems[0] : null;
			itemOwner = targetItem ? targetItem.owner : null;
			
			visualElement = targetItem as IVisualElement;
			visualElementParent = visualElement ? visualElement.parent : null;
			visualElementOwner = itemOwner as IVisualElementContainer;
			applicationGroup = destination is Application ? Application(destination).contentGroup : null;
			
			isSameParent = visualElementParent && (visualElementParent==destination || visualElementParent==applicationGroup);
			isSameOwner = visualElementOwner && visualElementOwner==destination;
			
			// set default description
			if (!description) {
				description = HistoryManager.getMoveDescription(targetItem);
			}
			
			// if it's a basic layout then don't try to add it
			// NO DO ADD IT bc we may need to swap indexes
			if (destination is IVisualElementContainer) {
				//destinationGroup = destination as GroupBase;
				
				if (destination is Container) {
					
					if (destination is Canvas) {
						// does not support multiple items?
						if (targetItem && itemOwner==destination) {
							isSameOwner = true;
						}
						
						// check if group parent and destination are the same
						if (targetItem && visualElementParent && (visualElementParent==destination || visualElementParent==applicationGroup)) {
							isSameParent = true;
						}
					}
					
				}
				else 
				if (destination.layout is BasicLayout) {
					
					// does not support multiple items?
					// check if group parent and destination are the same
					if (targetItem && itemOwner==destination) {
						//trace("can't add to the same owner in a basic layout");
						isSameOwner = true;
						
						//return SAME_OWNER;
					}
					
					// check if group parent and destination are the same
					// NOTE: if the item is an element on application this will fail
					if (targetItem && visualElementParent && (visualElementParent==destination || visualElementParent==applicationGroup)) {
						//trace("can't add to the same parent in a basic layout");
						isSameParent = true;
						//return SAME_PARENT;
					}
				}
				// if element is already child of layout container and there is only one element 
				else if (targetItems && destination is IVisualElementContainer 
						&& destination.numElements==1
						&& visualElementParent
						&& (visualElementParent==destination || visualElementParent==applicationGroup)) {
					
					isSameParent = true;
					isSameOwner = true;
					//trace("can't add to the same parent in a basic layout");
					//return SAME_PARENT;
					
				}
			}
			
			// if destination is null then we assume we are moving in same container 
			// or should null mean remove
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
					visualElement = targetItems is Array && (targetItems as Array).length>0 ? targetItems[0] as IVisualElement : targetItems as IVisualElement;
					
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
			moveItems.items = targetItems;
			moveItems.destination = destination;
			moveItems.position = position;
			moveItems.relativeTo = relativeTo;
			moveItems.propertyName = propertyName;
			moveItems.isArray = isArray;
			moveItems.isStyle = isStyle;
			moveItems.vectorClass = vectorClass;
			
			// if we want to check for property facades
			var items:Array;
			var item:Object;
			var propertiesStylesEvents:Array;
			var verifyValidProperties:Boolean;
			
			if (verifyValidProperties) {
				items = ArrayUtil.toArray(targetItems);
				
				propertiesStylesEvents = ArrayUtil.toArray(properties);
				
				for (var i:int = 0; i < items.length; i++)  {
					item = items[i];
					
					if (item) {
						styles = ClassUtils.getStylesFromArray(properties, propertiesStylesEvents);
						properties = ClassUtils.getPropertiesFromArray(item, propertiesStylesEvents, true);
						events = ClassUtils.getEventsFromArray(item, propertiesStylesEvents);
					}
				}
			}
			
			var removeConstraintsFromProperties:Boolean = true;
			var constraintStyles:Array;
			
			// remove constraints from properties array
			if (removeConstraintsFromProperties && properties && properties.length) {
				constraintStyles = ClassUtils.removeConstraintsFromArray(properties);
				
				if (constraintStyles.length) {
					if (styles==null) styles = [];
					ArrayUtils.addMissingItems(styles, constraintStyles);
				}
			}
			
			// add properties that need to be modified
			if ((properties && properties.length) || (styles && styles.length) || (events && events.length)) {
				changes = createPropertyChanges(targetItems, properties, styles, events, values, description, false);
				
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
					//info("Move: Nothing to change or add");
					return "Nothing to change or add";
				}
				
				// store changes
				// add to history
				if (!HistoryManager.doNotAddEventsToHistory) {
					historyEventItems = HistoryManager.createHistoryEventItems(targetItems, changes, properties, styles, events, values, description, RadiateEvent.MOVE_ITEM);
				}
				
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
						visualElementOwner.removeElement(visualElement);// validate now???
						visualElementOwner is IInvalidating ? IInvalidating(visualElementOwner).validateNow() : void;
					}
					
					moveItems.apply(moveItems.destination as UIComponent);
					
					if (moveItems.destination is SkinnableContainer && !SkinnableContainer(moveItems.destination).deferredContentCreated) {
						//Radiate.error("Not added because deferred content not created.");
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
					applyChanges(targetItems, [propertyChangeChange], properties, styles, events);
					LayoutManager.getInstance().validateNow();
					
					properties 	&& properties.length ? updateComponentProperties(targetItems, [propertyChangeChange], properties) :-1;
					styles 		&& styles.length ? updateComponentStyles(targetItems, [propertyChangeChange], styles) :-(1);
					events 		&& events.length ? updateComponentEvents(targetItems, [propertyChangeChange], events) :-1;
				}
				
				
				// add to history
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.addHistoryEvents(instance.selectedDocument, historyEventItems);
				}
				
				if (Radiate.importingDocument==false) {
					// check for changes before dispatching
					if (changes.indexOf(moveItems)!=-1) {
						instance.dispatchMoveEvent(targetItems, changes, properties);
					}
					
					//setTargets(items, true);
					
					if (properties) {
						instance.dispatchPropertyChangeEvent(targetItems, changes, properties, styles, events);
					}
				}
				
				return MOVED; // we assume moved if it got this far - needs more checking
			}
			catch (errorEvent:Error) {
				// this is clunky - needs to be upgraded
				error("Move error: " + errorEvent.message);
				
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.removeHistoryEvent(changes);
					HistoryManager.removeHistoryItem(instance.selectedDocument, changes);
				}
				return String(errorEvent.message);
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
										  events:Array			= null,
										  values:Object			= null, 
										  description:String 	= null, 
										  position:String		= AddItems.LAST, 
										  relativeTo:Object		= null, 
										  index:int				= -1, 
										  propertyName:String	= null, 
										  isArray:Boolean		= false, 
										  isStyle:Boolean		= false, 
										  vectorClass:Class		= null,
										  keepUndefinedValues:Boolean = true):String {
			
			
			if (!description) {
				description = HistoryManager.getAddDescription(items);
			}
			
			var results:String = moveElement(items, destination, properties, styles, events, values, 
								description, position, relativeTo, index, propertyName, 
								isArray, isStyle, vectorClass, keepUndefinedValues);
			
			var component:Object;
			
			var itemsArray:Array;
			
			itemsArray = ArrayUtil.toArray(items);
			
			for (var i:int; i < itemsArray.length; i++) {
				component = itemsArray[0];
				
				updateComponentAfterAdd(instance.selectedDocument, component);
			}
			
			return results;
		}
		
		
		/**
		 * Removes an element from the display list.<br/><br/>
		 * 
		 * Usage:<br/>
		 * <pre>Radiate.removeElement(radiate.targets);</pre>
		 * */
		public static function removeElement(items:*, description:String = null):String {
			
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
				description = HistoryManager.getRemoveDescription(item);
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
				//info("You can't remove the document");
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
				removeItems = HistoryManager.createReverseAddItems(items[0]);
				changes.unshift(removeItems);
				
				// store changes
				historyEvents = HistoryManager.createHistoryEventItems(items, changes, null, null, null, null, description, RadiateEvent.REMOVE_ITEM);
				
				// try moving
				//removeItems.apply(destination as UIComponent);
				//removeItems.apply(null);
				visualElementOwner.removeElement(visualElement);
				//removeItems.remove(destination as UIComponent);
				LayoutManager.getInstance().validateNow();
				
				
				// add to history
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.addHistoryEvents(instance.selectedDocument, historyEvents);
				}
				
				// check for changes before dispatching
				instance.dispatchRemoveItemsEvent(items, changes, null);
				// select application - could be causing errors - should select previous targets??
				setTargets(instance.selectedDocument.instance, true);
				
				return REMOVED; // we assume moved if it got this far - needs more checking
			}
			catch (errorEvent:Error) {
				// this is clunky - needs to be upgraded
				error("Remove error: " + errorEvent.message);
				if (!HistoryManager.doNotAddEventsToHistory) {
					HistoryManager.removeHistoryEvent(changes);
					HistoryManager.removeHistoryItem(instance.selectedDocument, changes);
				}
				return String(errorEvent.message);
			}
			
			return REMOVE_ERROR;
		}
		
		/**
		 * Last created component
		 * */
		public static var lastCreatedComponent:Object;
		
		/**
		 * Component that is in edit mode. Typically a Label. 
		 * */
		public static var currentEditableComponent:Object;
		public static var editableRichTextField:RichEditableText = new RichEditableText();
		public static var editableRichTextEditorBarCallout:RichTextEditorBarCallout;
		
		/**
		 * Handles double click on text to show text editor. 
		 * To support more components add the elements in the addElement method
		 * */
		public static function showTextEditor(event:MouseEvent):void {
			var target:TextBase = event.target as TextBase;
			var isRichEditor:Boolean;
			var rectangle:Rectangle;
			var propertyNames:Array;
			var valuesObject:Object;
			var isBasicLayout:Boolean;
			var topSystemManager:ISystemManager;
			var currentEditor:Object;
			var textFlowString:String;
			var textFlow:TextFlow;
			var iDocument:IDocument;
			var targetComponentDescription:ComponentDescription;
			var parentComponentDescription:ComponentDescription;
			var basicFonts:Boolean = false;
			
			const MIN_WIDTH:int = 22;
			
			if (!(instance.selectedTool is Selection)) {
				return;
			}
			
			// get reference to current source label or richtext 
			currentEditableComponent = target;
			
			// get positions of label or richtext
			// and setup properties that need to be set for temporary rich text field
			if (currentEditableComponent) {
				iDocument = instance.selectedDocument;
				targetComponentDescription = DisplayObjectUtils.getTargetInComponentDisplayList(target, iDocument.componentDescription);
				parentComponentDescription = targetComponentDescription.parent;
				//rectangle = DisplayObjectUtils.getRectangleBounds(target, iDocument.instance);
				//propertyNames = ["x", "y", "text", "minWidth"];
				//valuesObject = {};
				
				//if ((parentComponentDescription.instance is GroupBase || parentComponentDescription.instance is BorderContainer)
				//	&& parentComponentDescription.instance.layout is BasicLayout) {
				//	isBasicLayout = true;
				//	rectangle = DisplayObjectUtils.getRectangleBounds(target, parentComponentDescription.instance);
				//}
				
				isRichEditor = "textFlow" in currentEditableComponent;
				//currentEditor = isRichEditor ? editableRichTextEditorBarCallout : editableRichTextField;
				currentEditor = editableRichTextField;
				
				//rectangle = DisplayObjectUtils.getRectangleBounds(target);
				propertyNames = ["x", "y", "minWidth"];
				valuesObject = {};
				
				if (currentEditableComponent.owner.layout is BasicLayout) {
					isBasicLayout = true;
					rectangle = DisplayObjectUtils.getRectangleBounds(currentEditableComponent, currentEditableComponent.owner);
				}
				else {
					rectangle = DisplayObjectUtils.getRectangleBounds(target, iDocument.instance);
				}
				
				
				valuesObject.x = rectangle.x;
				valuesObject.y = rectangle.y;
				valuesObject.minWidth = MIN_WIDTH;
				
				if (!isNaN(target.explicitWidth)) {
					propertyNames.push("width");
					valuesObject.width = rectangle.width;
				}
				else if (!isNaN(target.percentWidth)) {
					// if basic layout we can get percent width
					if (isBasicLayout) {
						propertyNames.push("percentWidth");
						valuesObject.percentWidth = target.percentWidth;
					}
					else {
						propertyNames.push("width");
						valuesObject.width = rectangle.width;
					}
				}
				
				currentEditableComponent.visible = false;
				
				if (editableRichTextEditorBarCallout==null) {
					editableRichTextEditorBarCallout = new RichTextEditorBarCallout();
					editableRichTextEditorBarCallout.initialize();
					editableRichTextEditorBarCallout.createDeferredContent();
				}
				
				if (basicFonts && editableRichTextEditorBarCallout.editorBar.fontDataProvider) {
					editableRichTextEditorBarCallout.editorBar.fontDataProvider = null;
				}
				else if (!basicFonts && editableRichTextEditorBarCallout.editorBar.fontDataProvider ==null) {
					editableRichTextEditorBarCallout.editorBar.fontDataProvider = new ArrayList(fontsArray);
				}
				
				if (isRichEditor && editableRichTextEditorBarCallout.richEditableText != editableRichTextField) {
					//testTextArea.heightInLines = NaN;
					//editableRichTextEditorBarCallout.richEditableText = editableRichTextField;
				}
				

				if (isRichEditor) {
					editableRichTextEditorBarCallout.hideOnMouseDownOutside = true;
					editableRichTextEditorBarCallout.showEditorOnFocusIn = true;
					
					// TODO: use TextFlowUtil
					//TextFlowUtil.importFromString();
					//TextFlowUtil.export();
					
					textFlowString = TextConverter.export(currentEditableComponent.textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
					textFlow = TextConverter.importToFlow(textFlowString, TextConverter.TEXT_LAYOUT_FORMAT);
					
					editableRichTextEditorBarCallout.horizontalPosition = "middle";
					editableRichTextEditorBarCallout.verticalPosition = "before";
					editableRichTextEditorBarCallout.setStyle("contentBackgroundAppearance", ContentBackgroundAppearance.NONE);
					editableRichTextEditorBarCallout.richEditableText = editableRichTextField;
					
					
					//editableRichTextEditorBar.textFlow = textFlow;
					
					//isEditableRichTextEditorBarVisible = true;
					//editableRichTextEditorBarCallout.textFlow = textFlow;
					// not sure why the next line is commented out
					//editableRichTextEditor.styleName = currentEditableComponent;
					editableRichTextField.styleName = currentEditableComponent;
					editableRichTextField.focusRect = null;
					editableRichTextField.setStyle("focusAlpha", 0.25);
					editableRichTextField.validateNow();
				}
				else {
					//editableRichTextField.text = currentEditableComponent.text;
					valuesObject.text = currentEditableComponent.text;
					
					editableRichTextField.styleName = currentEditableComponent;
					editableRichTextField.focusRect = null;
					editableRichTextField.setStyle("focusAlpha", 0.25);
					editableRichTextField.validateNow();
				}
				
				
				if (isRichEditor) {
					//editableRichTextEditorBarCallout.includeInLayout = false;
					valuesObject.textFlow = textFlow;
					propertyNames.push("textFlow");
					/*
					testRichEditableText.clearStyle("horizontalCenter");
					testRichEditableText.clearStyle("verticalCenter");
					testRichEditableText.x = rectangle.x-2;
					testRichEditableText.y = rectangle.y-2;
					trace(testRichEditableText.x);
					trace(testRichEditableText.y);
					*/
					/*
					editableRichTextEditor.clearStyle("horizontalCenter");
					editableRichTextEditor.clearStyle("verticalCenter");
					editableRichTextEditor.x = rectangle.x-2;
					editableRichTextEditor.y = rectangle.y-2;
					*/
				}
				else {
					valuesObject.text = currentEditableComponent.text;
					propertyNames.push("text");
				}
				
				// add editor but prevent from adding to document history
				HistoryManager.doNotAddEventsToHistory = true;
				if (isBasicLayout) {
					
					if (isRichEditor) {
						
						//if (editableRichTextField.stage==null) {
						//	currentEditableComponent.owner.addElement(editableRichTextField);
						//}
						
						//addElement(editableRichTextEditorBarCallout, parentComponentDescription.instance, propertyNames, null, null, valuesObject);
						addElement(editableRichTextField, parentComponentDescription.instance, propertyNames, null, null, valuesObject);
					}
					else {
						addElement(editableRichTextField, parentComponentDescription.instance, propertyNames, null, null, valuesObject);
					}
				}
				else {
					if (isRichEditor) {
						
						//if (editableRichTextField.stage==null) {
						//	currentEditableComponent.owner.addElement(editableRichTextField);
						//}
						
						//addElement(editableRichTextEditorBarCallout, iDocument.instance, propertyNames, null, null, valuesObject);
						addElement(editableRichTextField, iDocument.instance, propertyNames, null, null, valuesObject);
					}
					else {
						addElement(editableRichTextField, iDocument.instance, propertyNames, null, null, valuesObject);
					}
				}
				HistoryManager.doNotAddEventsToHistory = false;
				
				topSystemManager = SystemManagerGlobals.topLevelSystemManagers[0];
				topSystemManager.stage.stageFocusRect = false;
				
				if (isRichEditor) {
					editableRichTextField.setFocus();
					editableRichTextEditorBarCallout.open(editableRichTextField);
					
					editableRichTextEditorBarCallout.addEventListener(PopUpEvent.CLOSE, richTextCallOut_closeHandler, false, 0, true);
					
					/*
					editableRichTextField.addEventListener(TextOperationEvent.CHANGE, richTextEditor_changeHandler, false, 0, true);
					editableRichTextField.addEventListener(FlexEvent.UPDATE_COMPLETE, richTextEditor_updateCompleteHandler, false, 0, true);
					editableRichTextField.addEventListener(MouseEvent.CLICK, handleEditorEvents, false, 0, true);
					
					editableRichTextEditorBarCallout.addEventListener(MouseEvent.CLICK, handleEditorEvents, false, 0, true);
					editableRichTextEditorBarCallout.addEventListener(FocusEvent.FOCUS_OUT, handleEditorEvents, false, 0, true);
					editableRichTextEditorBarCallout.addEventListener(FlexEvent.ENTER, handleEditorEvents, false, 0, true);
					editableRichTextEditorBarCallout.addEventListener(FlexEvent.VALUE_COMMIT, handleEditorEvents, false, 0, true);
					*/
				}
				else {
					editableRichTextField.selectAll();
					editableRichTextField.setFocus();
					
					editableRichTextField.addEventListener(FocusEvent.FOCUS_OUT, handleEditorEvents, false, 0, true);
					editableRichTextField.addEventListener(FlexEvent.ENTER, handleEditorEvents, false, 0, true);
					editableRichTextField.addEventListener(FlexEvent.VALUE_COMMIT, handleEditorEvents, false, 0, true);
					editableRichTextField.addEventListener(MouseEvent.CLICK, handleEditorEvents, false, 0, true);
				}
				
				instance.disableTool();
			}
			
			
			
			
			// OLD CODE
			/*
			return; 
			var target:TextBase = instance.target as TextBase;
			var topSystemManager:ISystemManager;
			
			if (!(instance.selectedTool is Selection)) {
				return;
			}
			
			if (target) {
				currentEditableComponent = target;
				var iDocument:IDocument = instance.selectedDocument;
				var targetComponentDescription:ComponentDescription = DisplayObjectUtils.getTargetInComponentDisplayList(target, iDocument.componentDescription);
				var parentComponentDescription:ComponentDescription = targetComponentDescription.parent;
				var rectangle:Rectangle = DisplayObjectUtils.getRectangleBounds(target, iDocument.instance);
				var propertyNames:Array = ["x", "y", "text", "minWidth"];
				var valuesObject:Object = {};
				var isBasicLayout:Boolean;
				
				if ((parentComponentDescription.instance is GroupBase || parentComponentDescription.instance is BorderContainer)
					&& parentComponentDescription.instance.layout is BasicLayout) {
					isBasicLayout = true;
					rectangle = DisplayObjectUtils.getRectangleBounds(target, parentComponentDescription.instance);
				}
				
				valuesObject.x = rectangle.x;
				valuesObject.y = rectangle.y;
				//const MIN_WIDTH:int = 22;
				valuesObject.minWidth = MIN_WIDTH;
				//properties.width = "100";
				
				if (!isNaN(target.explicitWidth)) {
					propertyNames.push("width");
					valuesObject.width = rectangle.width;
				}
				else if (!isNaN(target.percentWidth)) {
					// if basic layout we can get percent width
					if (isBasicLayout) {
						propertyNames.push("percentWidth");
						valuesObject.percentWidth = target.percentWidth;
					}
					else {
						propertyNames.push("width");
						valuesObject.width = rectangle.width;
					}
				}
				
				editableRichTextField.width = undefined;
				editableRichTextField.percentWidth = NaN;
				//properties.height = rectangle.height;
				valuesObject.text = target.text;
				currentEditableComponent.visible = false;
				editableRichTextField.styleName = currentEditableComponent;
				editableRichTextField.focusRect = null;
				editableRichTextField.setStyle("focusAlpha", 0.25);
				
				HistoryManager.doNotAddEventsToHistory = true;
				if (isBasicLayout) {
					addElement(editableRichTextField, parentComponentDescription.instance, propertyNames, null, null, valuesObject);
				}
				else {
					addElement(editableRichTextField, iDocument.instance, propertyNames, null, null, valuesObject);
				}
				HistoryManager.doNotAddEventsToHistory = false;
				
				topSystemManager = SystemManagerGlobals.topLevelSystemManagers[0];
				topSystemManager.stage.stageFocusRect = false;
				editableRichTextField.selectAll();
				editableRichTextField.setFocus();
				editableRichTextField.addEventListener(FocusEvent.FOCUS_OUT, commitTextEditorValues, false, 0, true);
				editableRichTextField.addEventListener(FlexEvent.ENTER, commitTextEditorValues, false, 0, true);
				editableRichTextField.addEventListener(FlexEvent.VALUE_COMMIT, commitTextEditorValues, false, 0, true);
				editableRichTextField.addEventListener(MouseEvent.CLICK, commitTextEditorValues, false, 0, true);
				instance.disableTool();
			}
			*/
		}
		
		public static function richTextCallOut_closeHandler(event:PopUpEvent):void {
			var data:TextFlow = event.data as TextFlow;
			
			commitTextEditorValues();
		}
		
		/**
		 * Set the value that the user typed in
		 * */
		public static function handleEditorEvents(event:Event):void {
			var newValue:String;
			var oldValue:String;
			var doSomething:Boolean;
			var currentTarget:Object;
			var editor:Object;
			var isRichEditor:Boolean;
			var textFlow:TextFlow;
			
			currentTarget = event.currentTarget;
			
			if (currentEditableComponent is Label) {
				//editor = editableLabelTextField;
				//newValue = editableLabelTextField.text;
				editor = editableRichTextField;
				//newValue = editableRichTextField.text;
				//oldValue = currentEditableComponent.text;
				isRichEditor = false;
			}
			else {
				editor = editableRichTextField; //editableRichTextEditorBarCallout;
				isRichEditor = true;
			}
			
			
			// CHECK if we should do something
			if (event is MouseEvent && currentTarget==editor) {
				doSomething = false;
				//trace("Click event");
			}
			else if (event is FocusEvent && FocusEvent(event).relatedObject==currentEditableComponent) {
				doSomething = false;
				//trace("related object is still edit component");
			}
			else if (event is FocusEvent && isRichEditor) {
				
				// if rich editable text loses focus and the focus is not the edit bar
				if (event.target==currentTarget && currentTarget==editor) {
					doSomething = false;
					//trace("focus out on rich editor. ignore");
				}
				else {
					doSomething = false;
					//trace("focus out not rich editor");
				}
			}
			else if (event is FlexEvent && event.type=="valueCommit") {
				doSomething = false;
				//trace('value commit');
			}
			else {
				doSomething = true;
				//trace('other event: ' + event.type);
			}
			
			// OLD CHECK IF DO SOMETHING
			/*
			if (event is MouseEvent && MouseEvent(event).currentTarget==editableRichTextField) {
				doSomething = false;
			}
			else if (event is FocusEvent && FocusEvent(event).relatedObject==currentEditableComponent) {
				doSomething = false;
			}
			else if (event is FlexEvent && event.type=="valueCommit") {
				doSomething = false;
			}
			else {
				doSomething = true;
			}
			*/
			
			
			if (doSomething) {
				commitTextEditorValues();
			}
			
			event.preventDefault();
			event.stopImmediatePropagation();
			
		}
		
		/**
		 * Set the value that the user typed in
		 * */
		public static function commitTextEditorValues():void {
			var newValue:String;
			var oldValue:String;
			var currentTarget:Object;
			var editor:Object;
			var isRichEditor:Boolean;
			var textFlow:TextFlow;
			var importer:ITextImporter;
			var config:IConfiguration;
			
			if (currentEditableComponent==null) return;
			
			editor = editableRichTextField;
			newValue = editableRichTextField.text;
			oldValue = currentEditableComponent.text;
			
			if (currentEditableComponent is Label) {
				editor = editableRichTextField;
				newValue = editableRichTextField.text;
				oldValue = currentEditableComponent.text;
				isRichEditor = false;
			}
			else {
				editor = editableRichTextField;
				isRichEditor = true;
			}
			
			if (isRichEditor) {
				newValue = TextConverter.export(editor.textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
				oldValue = TextConverter.export(Object(currentEditableComponent).textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
				
				importer = TextConverter.getImporter(TextConverter.TEXT_FIELD_HTML_FORMAT);
				config = importer.configuration;
			}
			
			if (currentEditableComponent && newValue!=oldValue) {
				
				if (isRichEditor) {
					textFlow = TextConverter.importToFlow(newValue, TextConverter.TEXT_LAYOUT_FORMAT);
					//currentEditableComponent.textFlow = textFlow;
					setProperty(currentEditableComponent, "textFlow", textFlow);
				}
				else {
					//currentEditableComponent.text = newValue;
					setProperty(currentEditableComponent, "text", newValue);
				}
				
			}
			
			currentEditableComponent.visible = true;
			
			if (isRichEditor) {
				editableRichTextEditorBarCallout.removeEventListener(PopUpEvent.CLOSE, commitTextEditorValues);
				/*
				editableRichTextEditorBarCallout.removeEventListener(FlexEvent.ENTER, commitTextEditorValues);
				editableRichTextEditorBarCallout.removeEventListener(FlexEvent.VALUE_COMMIT, commitTextEditorValues);
				editableRichTextEditorBarCallout.removeEventListener(MouseEvent.CLICK, commitTextEditorValues);
				
				editableRichTextField.removeEventListener(MouseEvent.CLICK, commitTextEditorValues);
				editableRichTextField.removeEventListener(TextOperationEvent.CHANGE, richTextEditor_changeHandler);
				editableRichTextField.removeEventListener(FlexEvent.UPDATE_COMPLETE, richTextEditor_updateCompleteHandler);
				*/
			}
			else {
				editableRichTextField.removeEventListener(FocusEvent.FOCUS_OUT, commitTextEditorValues);
				editableRichTextField.removeEventListener(FlexEvent.ENTER, commitTextEditorValues);
				editableRichTextField.removeEventListener(FlexEvent.VALUE_COMMIT, commitTextEditorValues);
				editableRichTextField.removeEventListener(MouseEvent.CLICK, commitTextEditorValues);
			}
			
			
			if (editableRichTextField.owner) {
				//editableRichTextField.owner.removeElement(editableRichTextField);
				editableRichTextEditorBarCallout.richEditableText = null;
			}
			else if (isRichEditor) {
				editableRichTextEditorBarCallout.richEditableText = null;
			}
			/*
			if (isRichEditor) {
				IVisualElementContainer(editableRichTextField.owner).removeElement(editableRichTextField);
			}
			
			*/
			
			// remove editor from stage
			HistoryManager.doNotAddEventsToHistory = true;
			if (isRichEditor) {
				//removeElement(editableRichTextEditorBarCallout);
				removeElement(editableRichTextField);
			}
			else if (editableRichTextField.parent) {
				removeElement(editableRichTextField);
			}
			HistoryManager.doNotAddEventsToHistory = false;
			
			
			instance.enableTool();
			
			currentEditableComponent = null;
			
			return;
			
			// OLD
			/*
			var newValue:String = editableRichTextField.text;
			var oldValue:String = currentEditableComponent.text;
			var doSomething:Boolean;
			
			
			if (event is MouseEvent && MouseEvent(event).currentTarget==editableRichTextField) {
				doSomething = false;
			}
			else if (event is FocusEvent && FocusEvent(event).relatedObject==currentEditableComponent) {
				doSomething = false;
			}
			else if (event is FlexEvent && event.type=="valueCommit") {
				doSomething = false;
			}
			else {
				doSomething = true;
			}
			
			
			if (doSomething) {
				if (currentEditableComponent && newValue!=oldValue) {
					setProperty(currentEditableComponent, "text", newValue);
					//currentEditableComponent = null;
				}
				
				currentEditableComponent.visible = true;
				editableRichTextField.removeEventListener(FocusEvent.FOCUS_OUT, commitTextEditorValues);
				editableRichTextField.removeEventListener(FlexEvent.ENTER, commitTextEditorValues);
				editableRichTextField.removeEventListener(FlexEvent.VALUE_COMMIT, commitTextEditorValues);
				editableRichTextField.removeEventListener(MouseEvent.CLICK, commitTextEditorValues);
				
				if (editableRichTextField.parent) {
					HistoryManager.doNotAddEventsToHistory = true;
					removeElement(editableRichTextField);
					HistoryManager.doNotAddEventsToHistory = false;
				}
				
				instance.enableTool();
			}
			
			event.preventDefault();
			event.stopImmediatePropagation();
			*/
		}
		
		/**
		 * Used to size the rich text editor as the user adds or removes new lines
		 * */
		public static function richTextEditor_changeHandler(event:TextOperationEvent):void {
			//trace(RichEditableText(currentEditableComponent).contentHeight);
			if (editableRichTextField is RichEditableText) {
				editableRichTextField.height = RichEditableText(editableRichTextField).contentHeight + 2;
			}
		}
		
		/**
		 * Used to size the rich text editor as the user adds or removes new lines
		 * */
		public static function richTextEditor_updateCompleteHandler(event:FlexEvent):void {
			if (editableRichTextField is RichEditableText) {
				editableRichTextField.height = RichEditableText(editableRichTextField).contentHeight + 2;
			}
		}
		
		/**
		 * Set the value that the user typed in
		 * */
		public static function commitTextEditorValuesOLD(event:Event):void {
			var newValue:String = editableRichTextField.text;
			var oldValue:String = currentEditableComponent.text;
			var doSomething:Boolean;
			
			
			if (event is MouseEvent && MouseEvent(event).currentTarget==editableRichTextField) {
				doSomething = false;
			}
			else if (event is FocusEvent && FocusEvent(event).relatedObject==currentEditableComponent) {
				doSomething = false;
			}
			else if (event is FlexEvent && event.type=="valueCommit") {
				doSomething = false;
			}
			else {
				doSomething = true;
			}
			
			
			if (doSomething) {
				if (currentEditableComponent && newValue!=oldValue) {
					setProperty(currentEditableComponent, "text", newValue);
					//currentEditableComponent = null;
				}
				
				currentEditableComponent.visible = true;
				editableRichTextField.removeEventListener(FocusEvent.FOCUS_OUT, commitTextEditorValues);
				editableRichTextField.removeEventListener(FlexEvent.ENTER, commitTextEditorValues);
				editableRichTextField.removeEventListener(FlexEvent.VALUE_COMMIT, commitTextEditorValues);
				editableRichTextField.removeEventListener(MouseEvent.CLICK, commitTextEditorValues);
				
				if (editableRichTextField.parent) {
					HistoryManager.doNotAddEventsToHistory = true;
					removeElement(editableRichTextField);
					HistoryManager.doNotAddEventsToHistory = false;
				}
				
				instance.enableTool();
			}
			
			event.preventDefault();
			event.stopImmediatePropagation();
			
		}
		
		/**
		 * Handles double click on text to show text editor. 
		 * To support more components add the elements in the addElement method
		 * */
		public static function showTextEditorOld(event:MouseEvent):void {
			var target:TextBase = instance.target as TextBase;
			var topSystemManager:ISystemManager;
			
			if (!(instance.selectedTool is Selection)) {
				return;
			}
			
			if (target) {
				currentEditableComponent = target;
				var iDocument:IDocument = instance.selectedDocument;
				var targetComponentDescription:ComponentDescription = DisplayObjectUtils.getTargetInComponentDisplayList(target, iDocument.componentDescription);
				var parentComponentDescription:ComponentDescription = targetComponentDescription.parent;
				var rectangle:Rectangle = DisplayObjectUtils.getRectangleBounds(target, iDocument.instance);
				var propertyNames:Array = ["x", "y", "text", "minWidth"];
				var valuesObject:Object = {};
				var isBasicLayout:Boolean;
				
				if ((parentComponentDescription.instance is GroupBase || parentComponentDescription.instance is BorderContainer)
					&& parentComponentDescription.instance.layout is BasicLayout) {
					isBasicLayout = true;
					rectangle = DisplayObjectUtils.getRectangleBounds(target, parentComponentDescription.instance);
				}
				
				valuesObject.x = rectangle.x;
				valuesObject.y = rectangle.y;
				const MIN_WIDTH:int = 22;
				valuesObject.minWidth = MIN_WIDTH;
				//properties.width = "100";
				
				if (!isNaN(target.explicitWidth)) {
					propertyNames.push("width");
					valuesObject.width = rectangle.width;
				}
				else if (!isNaN(target.percentWidth)) {
					// if basic layout we can get percent width
					if (isBasicLayout) {
						propertyNames.push("percentWidth");
						valuesObject.percentWidth = target.percentWidth;
					}
					else {
						propertyNames.push("width");
						valuesObject.width = rectangle.width;
					}
				}
				
				editableRichTextField.width = undefined;
				editableRichTextField.percentWidth = NaN;
				//properties.height = rectangle.height;
				valuesObject.text = target.text;
				currentEditableComponent.visible = false;
				editableRichTextField.styleName = currentEditableComponent;
				editableRichTextField.focusRect = null;
				editableRichTextField.setStyle("focusAlpha", 0.25);
				
				HistoryManager.doNotAddEventsToHistory = true;
				if (isBasicLayout) {
					addElement(editableRichTextField, parentComponentDescription.instance, propertyNames, null, null, valuesObject);
				}
				else {
					addElement(editableRichTextField, iDocument.instance, propertyNames, null, null, valuesObject);
				}
				HistoryManager.doNotAddEventsToHistory = false;
				
				topSystemManager = SystemManagerGlobals.topLevelSystemManagers[0];
				topSystemManager.stage.stageFocusRect = false;
				editableRichTextField.selectAll();
				editableRichTextField.setFocus();
				editableRichTextField.addEventListener(FocusEvent.FOCUS_OUT, commitTextEditorValues, false, 0, true);
				editableRichTextField.addEventListener(FlexEvent.ENTER, commitTextEditorValues, false, 0, true);
				editableRichTextField.addEventListener(FlexEvent.VALUE_COMMIT, commitTextEditorValues, false, 0, true);
				editableRichTextField.addEventListener(MouseEvent.CLICK, commitTextEditorValues, false, 0, true);
				instance.disableTool();
			}
		}
		
		
		/**
		 * Required for creating BorderContainers
		 * */
		protected static function deferredInstanceFromFunction():Array {
			var label:Label = new Label();
			return [label];
		}
		
		/**
		 * Sets the default properties. We may need to use setActualSize type of methods here or when added. 
		 * 
		 * For instructions on setting default properties or adding new component types
		 * look in Radii8Desktop/howto/HowTo.txt
		 * */
		public static function setDefaultProperties(componentDescription:ComponentDescription):void {
			
			var valuesObject:ValuesObject = getPropertiesStylesFromObject(componentDescription.instance, componentDescription.defaultProperties);
			
			// maybe do not add to history
			setPropertiesStylesEvents(componentDescription.instance, valuesObject.propertiesStylesEvents, valuesObject.values);
			
		}
		
		/**
		 * Updates the component with any additional settings for it to work 
		 * after it's been added to the document.
		 * 
		 * For instructions on setting default properties or adding new component types
		 * look in Radii8Desktop/howto/HowTo.txt
		 * 
		 * @see #createComponentToAdd()
		 * */
		public static function updateComponentAfterAdd(iDocument:IDocument, target:Object, setDefaults:Boolean = false, interactive:Boolean = false):void {
			var componentDescription:ComponentDescription = iDocument.getItemDescription(target);
			var componentInstance:Object = componentDescription ? componentDescription.instance : null;
			
			// set defaults
			if (componentDescription && setDefaults) {
				setDefaultProperties(componentDescription);
			}
			
			iDocument.updateComponentTree();
			
			// need to add so we can listen for click events on transparent areas of groups
			if (componentInstance is GroupBase) {
				DisplayObjectUtils.addGroupMouseSupport(componentInstance as GroupBase);
			}
			
			// we can't add elements if skinnablecontainer._deferredContentCreated is false
			if (target is BorderContainer) {
				/*var factory:DeferredInstanceFromFunction;
				factory = new DeferredInstanceFromFunction(deferredInstanceFromFunction);
				BorderContainer(component).mxmlContentFactory = factory;
				BorderContainer(component).createDeferredContent();
				BorderContainer(component).removeAllElements();*/
				
				// we could probably also do this: 
				BorderContainer(target).addElement(new Label());
				BorderContainer(target).removeAllElements();
				
				// we do this to get rid of the round joints. this skin joints default to miter
				// UPDATE - this causes an infinite loop somewhere when deleting an element
				// so let's just remove it for now
				//BorderContainer(target).setStyle("skinClass", com.flexcapacitor.skins.BorderContainerSkin);
				BorderContainer(target).setStyle("cornerRadius", 0);
			}
			
			// add fill to rect if null
			if (componentInstance is Rect && componentInstance.fill==null) {
				var fill:SolidColor = new SolidColor();
				fill.color = 0xf6f6f6;
				Rect(componentInstance).fill = fill;
			}
			
			makeInteractive(componentInstance, interactive);
			
			// prevent components from interacting with design view
			
			// we need a custom FlexSprite class to do this
			// do this after drop
			if ("eventListeners" in target && !(target is GroupBase)) {
				target.removeAllEventListeners();
			}
			
			// we need a custom FlexSprite class to do this
			// do this after drop
			/*if ("eventListeners" in component) {
			component.removeAllEventListeners();
			}*/
			
			// we can't add elements if skinnablecontainer._deferredContentCreated is false
			/*if (component is BorderContainer) {
				BorderContainer(component).creationPolicy = ContainerCreationPolicy.ALL;
				BorderContainer(component).initialize();
				BorderContainer(component).createDeferredContent();
				BorderContainer(component).initialize();
			}*/
		}
		
		/**
		 * When set to true, makes a component interactive as in a normal app. 
		 * When false makes component behave as if it was on the design view
		 * */
		public static function makeInteractive(componentInstance:Object, interactive:Boolean = false, showEditor:Boolean = true):void {
			
			// graphic elements
			// when we say interactive we mean what the user will interact with
			// do not make graphic elements interactive for user
			if (componentInstance is GraphicElement) {
				GraphicElement(componentInstance).alwaysCreateDisplayObject = !interactive;
				
				if (GraphicElement(componentInstance).displayObject) {
					Sprite(GraphicElement(componentInstance).displayObject).mouseEnabled = !interactive;
					Sprite(GraphicElement(componentInstance).displayObject).buttonMode = !interactive;
				}
			}
			
			// if text based or combo box we need to prevent 
			// interaction with cursor
			if (componentInstance is TextBase || componentInstance is SkinnableTextBase) {
				componentInstance.mouseChildren = interactive;
				
				if ("textDisplay" in componentInstance && componentInstance.textDisplay) {
					componentInstance.textDisplay.enabled = interactive;
				}
				
				
				// if show editor on double click then continue to be interactive 
				if (showEditor) {
					if (componentInstance is Label || componentInstance is RichText || componentInstance is Hyperlink) {
						componentInstance.doubleClickEnabled = true;
						
						componentInstance.addEventListener(MouseEvent.DOUBLE_CLICK, showTextEditor, false, 0, true);
					}
					
					if (componentInstance is Hyperlink) {
						componentInstance.useHandCursor = true;
					}
				}
				else {
					if (componentInstance is Label || componentInstance is RichText) {
						componentInstance.doubleClickEnabled = interactive;
						
						if (interactive) {
							componentInstance.addEventListener(MouseEvent.DOUBLE_CLICK, showTextEditor, false, 0, true);
						}
						else {
							componentInstance.removeEventListener(MouseEvent.DOUBLE_CLICK, showTextEditor);
						}
					}
					
					if (componentInstance is Hyperlink) {
						componentInstance.useHandCursor = interactive;
					}
				}
			}
			
			var sparkColorPicker:Class = ClassUtils.getDefinition("spark.components.ColorPicker") as Class;
			
			// spark or mx ColorPicker
			if ((sparkColorPicker && componentInstance is sparkColorPicker) || componentInstance is mx.controls.ColorPicker) {
				Object(componentInstance).mouseChildren = interactive;
			}
			
			// NumericStepper
			if (componentInstance is NumericStepper) {
				NumericStepper(componentInstance).mouseChildren = interactive;
			}
			
			// dropdown or combobox
			if (componentInstance is ComboBox || componentInstance is DropDownList) {
				if ("textInput" in componentInstance && componentInstance.textInput && 
					componentInstance.textInput.textDisplay) {
					ComboBox(componentInstance).textInput.textDisplay.enabled = interactive;
				}
				
				DropDownListBase(componentInstance).mouseChildren = interactive;
			}
			
			// Vertical or Horizontal Slider
			if (componentInstance is SliderBase) {
				SliderBase(componentInstance).mouseChildren = interactive;
			}
			
			
			if (componentInstance is LinkButton) {
				LinkButton(componentInstance).useHandCursor = interactive;
			}
			
			if (componentInstance is Hyperlink) {
				// prevent links from clicking use UIGlobals...designMode
				Hyperlink(componentInstance).useHandCursor = !interactive;
				Hyperlink(componentInstance).preventLaunching = interactive;
			}
			
			// checkbox or radio button or toggle button
			if (componentInstance is ToggleButtonBase) {
				
				if (!interactive) {
					IEventDispatcher(componentInstance).addEventListener(MouseEvent.CLICK, disableToggleButtonHandler, false, 0, true);
				}
				else {
					IEventDispatcher(componentInstance).removeEventListener(MouseEvent.CLICK, disableToggleButtonHandler);
				}
				
			}
			
			// test on spark grid
			if (false && componentInstance is spark.components.Grid) {
				spark.components.Grid(componentInstance).itemRenderer= new ClassFactory(DefaultGridItemRenderer);
				spark.components.Grid(componentInstance).dataProvider = new ArrayCollection(["item 1", "item 2", "item 3"]);
			}
			
			// test on mx grid
			if (false && componentInstance is mx.containers.Grid) {
				mx.containers.Grid(componentInstance)
				var grid:mx.containers.Grid = componentInstance as mx.containers.Grid;
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
			
		}
		
		/**
		 * Disables toggle button base classes
		 * */
		public static function disableToggleButtonHandler(event:Event):void {
			ToggleButtonBase(event.currentTarget).selected = !ToggleButtonBase(event.currentTarget).selected;
			event.stopImmediatePropagation();
			event.preventDefault();
		}
		
		/**
		 * Creates an instance of the component in the descriptor and sets the 
		 * default properties. We may need to use setActualSize type of methods here or when added. 
		 * 
		 * For instructions on setting default properties or adding new component types
		 * look in Radii8Desktop/howto/HowTo.txt
		 * 
		 * @see #updateComponentAfterAdd()
		 * */
		public static function createComponentToAdd(iDocument:IDocument, componentDefinition:ComponentDefinition, setDefaults:Boolean = true, instance:Object = null):Object {
			var componentDescription:ComponentDescription;
			var classFactory:ClassFactory;
			var componentInstance:Object;
			var properties:Array = [];
			
			if (instance && componentDefinition==null) {
				componentDefinition = getDynamicComponentType(instance);
			}
			
			// Create component to drag
			if (instance==null) {
				classFactory = new ClassFactory(componentDefinition.classType as Class);
			}
			
			/*if (setDefaults) {
				//classFactory.properties = item.defaultProperties;
				//componentDescription.properties = componentDefinition.defaultProperties;
				componentDescription.defaultProperties = componentDefinition.defaultProperties;
			}*/
			
			if (instance) {
				componentInstance = instance;
			}
			else {
				componentInstance = classFactory.newInstance();
			}
			
			componentDescription 			= new ComponentDescription();
			componentDescription.instance 	= componentInstance;
			componentDescription.name 		= componentDefinition.name;
			componentDescription.className 	= componentDefinition.name;
			
			// add default if we need to access defaults later
			componentDescription.defaultProperties = componentDefinition.defaultProperties;
			
			if (setDefaults) {
				
				for (var property:String in componentDefinition.defaultProperties) {
					//setProperty(component, property, [item.defaultProperties[property]]);
					properties.push(property);
				}
				
				// maybe do not add to history
				//setProperties(componentInstance, properties, item.defaultProperties);
				setDefaultProperties(componentDescription);
			}
			
			componentDescription.componentDefinition = componentDefinition;
			
			iDocument.setItemDescription(componentInstance, componentDescription);
			//iDocument.descriptionsDictionary[componentInstance] = componentDescription;
			
			lastCreatedComponent = componentInstance;
			
			return componentInstance;
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
			
			if (iProject==null) {
				error("No project to open");
				return null;
			}
			
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			
			isAlreadyOpen = isProjectOpen(iProject);
			
			/*
			if (dispatchEvents) {
				dispatchProjectChangeEvent(iProject);
			}*/
			
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
		public function projectOpenResultHandler(event:Event):void {
			var iProject:IProject = event.currentTarget as IProject;
			
			// add assets
			addAssetsToDocument(iProject.assets, iProject as DocumentData);
			
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
			if (iProject==null) {
				error("No project to close");
				return false;
			}
			
			var numOfDocuments:int = iProject.documents.length;
			//info("Close project");
			if (dispatchEvents) {
				dispatchProjectClosingEvent(iProject);
			}
			
			for (var i:int=numOfDocuments;i--;) {
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
			var remote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var numberOfDocuments:int;
			var removedProjects:Array;
			
			if (projectIndex!=-1) {
				removedProjects = projects.splice(projectIndex, 1);
				
				if (removedProjects[0]==iProject) {
					info("Project removed successfully");
					
					numberOfDocuments = iProject.documents.length;
					
					for (var i:int=numberOfDocuments;i--;) {
						removeDocument(IDocument(iProject.documents[i]), locations, dispatchEvents);
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
				
				deleteProjectService.host = getWPURL();
				
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
				serviceManager.getProjects();
				serviceManager.getAttachments();
			}
		}
		
		/**
		 * Creates a blank document and creates a new project if not supplied.
		 * 
		 * @param project if string then creates a new project. if an IProject then does not create a new project.
		 * */
		public function createBlankDemoDocument(project:Object = null, documentName:String = null, type:Class = null, open:Boolean = true, dispatchEvents:Boolean = false, select:Boolean = true):IDocument {
			var newProject:IProject;
			var newDocument:IDocument;
			
			if (project is String || project==null) {
				newProject = createProject(project as String); // create project
				addProject(newProject, false);       // add to projects array - shows up in application
			}
			else if (project is IProject) {
				newProject = project as IProject;
			}
			
			newDocument = createDocument(documentName); // create document
			addDocument(newDocument, newProject); // add to project and documents array - shows up in application
			
			openProject(newProject, DocumentData.INTERNAL_LOCATION); // should open documents - maybe we should do all previous steps in this function???
			openDocument(newDocument, DocumentData.INTERNAL_LOCATION, true, true); // add to application and parse source code if any
			
			setProject(newProject, true); // selects project 
			
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
				hasDefinition = ClassUtils.hasDefinition(String(Type));
				DocumentType = Document;
				
				if (hasDefinition) {
					DocumentType = ClassUtils.getDefinition(String(Type));
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
			var documentAdded:Boolean;
			var documentToRemove:IDocument;
			
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
				documentToRemove = getDocumentByUID(iDocument.uid);
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
			if (iDocument==null) {
				error("No document to revert");
				return false;
			}
			
			if ("revert" in iDocument) {
				Object(iDocument).revert();
				dispatchDocumentRevertedEvent(iDocument);
				return true;
			}
			
			return false;
		}
		
		/**
		 * Removes a document from the documents array
		 * */
		public function removeDocument(iDocument:IDocument, locations:String = null, dispatchEvents:Boolean = true, saveProjectAfter:Boolean = true):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var parentProject:IProject = iDocument.project;
			var documentsIndex:int = parentProject.documents.indexOf(iDocument);
			var removedDocument:IDocument;
			var remote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			
			deleteDocumentProjectId = parentProject && parentProject.id!=null ? int(parentProject.id) : -1;
			saveProjectAfterDelete = saveProjectAfter;
			
			if (documentsIndex!=-1) {
				// add remove document to project
				var removedDocuments:Array = parentProject.documents.splice(documentsIndex, 1);
				
				if (removedDocuments[0]==iDocument) {
					//info("Document removed successfully");
				}
			}
			
			closeDocument(iDocument);
			// check if document is open in tab navigator
			/*if (isDocumentOpen(iDocument)) {
				var closed:Boolean = closeDocument(iDocument);
				info("Closed " + iDocument.name);
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
					
					if (deleteDocumentProjectId!=-1 && saveProjectAfter) {
						parentProject.saveOnlyProject(locations);
					}
					
					setTarget(null);
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

			}
			
			setTarget(null);
			
			return true;
		}
		
		/**
		 * Opens the document from it's document data. If the document is already open it selects it. 
		 * 
		 * It returns the document container. 
		 * */
		public function openDocumentByData(data:IDocumentData, createIfNotFound:Boolean, showDocument:Boolean = true, dispatchEvents:Boolean = true):IDocument {
			var iDocument:IDocument = getDocumentByUID(data.uid);
			
			if (!iDocument && createIfNotFound) {
				iDocument = createDocumentFromData(data);
			}
			
			var newDocument:IDocument = openDocument(iDocument, DocumentData.INTERNAL_LOCATION, showDocument, dispatchEvents);
			
			return newDocument;
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
				error("Printing failed: Object is not of accepted type.");
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
				error("Print job was not started");
				dispatchPrintCancelledEvent(data, flexPrintJob);
				return false;
			}
			
			try {
				//info("Print width and height: " + flexPrintJob.pageWidth + "x" + flexPrintJob.pageHeight);
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
				error("Printing failed: " + e.message);
				
				// TODO this should be print error event
				dispatchPrintCancelledEvent(data, flexPrintJob);
				return false;
			} 
			
			return true;
		}
		
		/**
		 * Import MXML code
		 * */
		public function importMXMLDocument(project:IProject, iDocument:IDocument, container:IVisualElement, code:String, name:String = null, dispatchEvents:Boolean = true):SourceData {
			var result:Object;
			var newDocument:Boolean;
			var sourceData:SourceData;
			
			if (!iDocument) {
				iDocument = createDocument(name);
				newDocument = true;
				
				if (project) {
					addDocument(iDocument, project);
				}
			}
			
			
			if (!newDocument) {
				sourceData = parseSource(iDocument, code, container);
				
				return sourceData;
			}
			else {
				iDocument.originalSource = code;
				iDocument.source = code;
				// we load a blank application (swf), once it's loaded, 
				// in DocumentContainer we call Radiate.parseSource(iDocument);
				result = openDocument(iDocument, DocumentData.INTERNAL_LOCATION, true, dispatchEvents);
			}
			
			return sourceData;
		}
		
		/**
		 * Opens the document. If the document is already open it selects it. 
		 * When the document loads (it's a blank application swf) then the mxml is parsed. Check the DocumentContainer class.  
		 * 
		 * It returns the document container. 
		 * */
		public function openDocument(iDocument:IDocument, locations:String = null, showDocumentInTab:Boolean = true, dispatchEvents:Boolean = true):IDocument {
			var documentContainer:DocumentContainer;
			var navigatorContent:NavigatorContent;
			var openingEventDispatched:Boolean;
			var containerTypeInstance:Object;
			var isAlreadyOpen:Boolean;
			var container:Object;
			var documentIndex:int;
			var previewName:String;
			var index:int;
			
			if (iDocument==null || documentsTabNavigator==null) {
				error("No document to open");
				return null;
			}
			
			// NOTE: If the document is empty or all of the components are in the upper left hand corner
			// and they have no properties then my guess is that the application was never fully loaded 
			// or activated. this happens with multiple documents opening too quickly where some 
			// do not seem to activate. you see them activate when you select their tab for the first time
			// so then later if it hasn't activated, when the document is exported none of the components have
			// their properties or styles set possibly because Flex chose to defer applying them.
			// the solution is to make sure the application is fully loaded and activated
			// and also store a backup of the document MXML. 
			// that could mean waiting to open new documents until existing documents have 
			// loaded. listen for the application complete event (or create a parse and import event) 
			// ...haven't had time to do any of this yet
			// UPDATE OCT 4, 2015 - try calling activate() on the application - see Radii8Desktop.mxml menu item
			
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
					selectDocument(iDocument, dispatchEvents);
				}
				return iDocument;
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
				selectDocument(iDocument, dispatchEvents);
			}
			
			return iDocument;
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
			var html:UIComponent;
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
					selectDocument(iDocument, dispatchEvents);
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
			else if (isDesktop) {
				
				// we should add an option to use stage web instead of 
				// internal webkit browser
				
				// show HTML page
				html = HTMLUtils.createInstance();
				html.id = iDocument.name ? iDocument.name : html.name; // should we be setting id like this?
				html.percentWidth = 100;
				html.percentHeight = 100;
				html.top = -10;
				html.left = 0;
				//html.setStyle("backgroundColor", "#666666");
				
				// not sure how to get the parsing errors 
				html.addEventListener("uncaughtScriptException", uncaughtScriptExceptionHandler, false, 0, true);//HTMLUncaughtScriptExceptionEvent.uncaughtScriptException
				html.addEventListener("uncaughtException", uncaughtScriptExceptionHandler, false, 0, true);//HTMLUncaughtScriptExceptionEvent.uncaughtScriptException
				html.addEventListener("scriptException", uncaughtScriptExceptionHandler, false, 0, true);//HTMLUncaughtScriptExceptionEvent.uncaughtScriptException
				html.addEventListener("htmlError", uncaughtScriptExceptionHandler, false, 0, true);//HTMLUncaughtScriptExceptionEvent.uncaughtScriptException
				html.addEventListener("error", uncaughtScriptExceptionHandler, false, 0, true);//HTMLUncaughtScriptExceptionEvent.uncaughtScriptException
				
				navigatorContent.addElement(html);
				documentsPreviewDictionary[iDocument] = html;
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
				selectDocument(iDocument, dispatchEvents);
			}
			
			return documentsPreviewDictionary[iDocument];
		}
		
		/**
		 * Checks if a document preview is open.
		 * @see isDocumentSelected
		 * */
		public function isDocumentPreviewOpen(document:IDocument):Boolean {
			var openTabs:Array = documentsTabNavigator && documentsTabNavigator.getChildren() ? documentsTabNavigator.getChildren() : [];
			var tabCount:int = openTabs.length;
			var tab:NavigatorContent;
			var tabContent:Object;
			
			if (tabCount==0) {
				return false;
			}
			
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
		public function isDocumentOpen(iDocument:IDocument, isPreview:Boolean = false):Boolean {
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
			documentContainer = isPreview ? documentsPreviewDictionary[iDocument] : documentsContainerDictionary[iDocument];
			
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
		public function closeDocument(iDocument:IDocument, isPreview:Boolean = false, selectOtherDocument:Boolean = false):Boolean {
			if (iDocument==null || documentsTabNavigator==null) {
				error("No document to close");
				return false;
			}
			
			var openTabs:Array = documentsTabNavigator.getChildren();
			var tabCount:int = openTabs.length;
			var navigatorContent:NavigatorContent;
			var navigatorContentDocumentContainer:Object;
			var documentContainer:Object = isPreview ? documentsPreviewDictionary[iDocument] : documentsContainerDictionary[iDocument];
			var wasClosed:Boolean;
			var index:int;
			
			// third attempt
			
			
			// second attempt
			
			if (documentContainer && documentContainer.owner) {
				// ArgumentError: Error #2025: The supplied DisplayObject must be a child of the caller.
				// 	at flash.display::DisplayObjectContainer/getChildIndex()
				//var index:int = documentsTabNavigator.getChildIndex(documentContainer.owner as DisplayObject);
				var contains:Boolean = documentsTabNavigator.contains(documentContainer.owner as DisplayObject);
				
				if (contains) {
					index = documentsTabNavigator.getChildIndex(documentContainer.owner);
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
						wasClosed = true;
					}
					else {
						delete documentsPreviewDictionary[iDocument];
					}
					
					if (isPreview) {
						// TODO we must remove HTML from IFrame (inline css from previous iframes previews affects current preview)
					}
					else {
						selectDocument(null);
					}
					
					documentsTabNavigator.validateNow();
					
				}
			}
			
			var otherDocument:IDocument;
			
			if (selectOtherDocument && wasClosed && tabCount>1) {
				otherDocument = getVisibleDocument();
				openTabs = documentsTabNavigator.getChildren();
				tabCount = openTabs.length;
				
				if (otherDocument==null) {
					//index = index==0 ? 1 : index-1;
					otherDocument = documents && documents.length ? documents[0] : null;
				}
				if (otherDocument) {
					selectDocument(otherDocument);
					showDocument(otherDocument);
				}
			}
			else {
				openTabs = documentsTabNavigator.getChildren();
				tabCount = openTabs.length;
				
				if (tabCount==0) {
					setTarget(null);
				}
			}
			
			return true;
			
			// first attempt
			//info("Closing " + iDocument.name);
			for (var i:int;i<tabCount;i++) {
				navigatorContent = NavigatorContent(documentsTabNavigator.getChildAt(i));
				navigatorContentDocumentContainer = navigatorContent.numElements ? navigatorContent.getElementAt(0) : null;
				//info(" Checking tab " + tab.label);
				
				if (iDocument.name==navigatorContent.label) {
					//info(" Name Match " + iDocument.name);
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
		 * 
		 * */
		public function getDocumentTabIndex(document:Object, isPreview:Boolean = false):int {
			//TypeError: Error #1009: Cannot access a property or method of a null object reference.
			//	at com.flexcapacitor.controller::Radiate/getDocumentTabIndex()[/Users/monkeypunch/Documents/ProjectsGithub/Radii8/Radii8Library/src/com/flexcapacitor/controller/Radiate.as:5649]
			if (documentsTabNavigator==null) {
				info("Documents tab navigator is not created yet so for now you must open the document manually. Close and then open the document.");
				if (document && document is IDocument) {
					closeDocument(IDocument(document));
				}
				return -1;
			}
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
		
		public static var htmlOptions:HTMLExportOptions;
		
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
		 * Parses data into an array of usable objects 
		 * Should be in a ServicesManager class?
		 * */
		public function parseProjectsData(data:Object):Array {
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
		 * Parses the code and builds a document. 
		 * If code is null and source is set then parses source.
		 * If parent is set then imports code to the parent
		 * */
		public static function parseSource(document:IDocument, code:String = null, parent:IVisualElement = null):SourceData {
			var codeToParse:String = code ? code : document.source;
			var currentChildren:XMLList;
			var nodeName:String;
			var child:XML;
			var xml:XML;
			var root:String;
			var isValid:Boolean;
			var rootNodeName:String = "RootWrapperNode";
			var updatedCode:String;
			var mxmlDocumentImporter:MXMLDocumentImporter;
			var componentDescription:ComponentDescription;
			var sourceDataLocal:SourceData;
			var message:String;
			
			// I don't like this here - should move or dispatch events to handle import
			var transcoder:TranscoderDescription = CodeManager.getImporter(CodeManager.MXML);
			var importer:DocumentTranscoder = transcoder.importer;
			
			if (codeToParse=="" || codeToParse=="null") {
				message = "No code to parse for document, \"" + document.name + "";
				Radiate.error(message);
				return null;
			}
			
			isValid = XMLUtils.isValidXML(codeToParse);
			
			if (!isValid) {
				root = "<" + rootNodeName + " " + MXMLDocumentConstants.getDefaultNamespaceDeclarations() + ">";
				updatedCode = root + codeToParse + "</"+rootNodeName+">";
				
				isValid = XMLUtils.isValidXML(updatedCode);
				
				if (isValid) {
					codeToParse = updatedCode;
				}
			}
			
			// check for valid XML
			try {
				xml = new XML(codeToParse);
			}
			catch (error:Error) {
				message = "Could not parse code for document, \"" + document.name + "\". Fix the code before you import.";
				Radiate.error("Could not parse code for document, \"" + document.name + "\". \n" + error.message + " \nCode: \n" + codeToParse);
				
				if (openImportPopUp) {
					openImportPopUp.popUpOptions = {title:message, code:codeToParse};
					openImportPopUp.play();
				}
			}
			
			
			if (xml) {
				// loop through each item and create an instance 
				// and set the properties and styles on it
				/*currentChildren = xml.children();
				while (child in currentChildren) {
				nodeName = child.name();
				
				}*/
				//Radiate.info("Importing document: " + name);
				//var mxmlLoader:MXMLImporter = new MXMLImporter( "testWindow", new XML( inSource ), canvasHolder  );
				
				var container:IVisualElement = parent ? parent as IVisualElement : instance as IVisualElement;
				
				if (container is Application && "activate" in container) {
					Object(container).activate();
				}
				
				if (document && document.instance is Application && "activate" in document.instance) {
					Object(document.instance).activate();
				}
				
				componentDescription = document.componentDescription;
				sourceDataLocal = importer.importare(codeToParse, document, componentDescription);
				
				if (container) {
					Radiate.instance.setTarget(container);
				}
				
				if (sourceDataLocal.errors && sourceDataLocal.errors.length) {
					outputMXMLErrors("", sourceDataLocal.errors);
				}
			}
			
			
			/*_toolTipChildren = new SystemChildrenList(this,
			new QName(mx_internal, "topMostIndex"),
			new QName(mx_internal, "toolTipIndex"));*/
			//return true;
			
			return sourceDataLocal;
		}
		
		/**
		 * Open import MXML window
		 * */
		public function openImportMXMLWindow(title:String, code:String = "", showRevisions:Boolean = false):void {
			
			if (openImportPopUp==null) {
				createOpenImportPopUp();
			}
			
			if (!openImportPopUp.isOpen) {
				openImportPopUp.popUpOptions = {title:title, code:code, showRevisions:showRevisions};
				openImportPopUp.play();
			}
		}
		
		public function createOpenImportPopUp():void {
			if (openImportPopUp==null) {
				openImportPopUp = new OpenPopUp();
				openImportPopUp.popUpType = ImportWindow; 
				openImportPopUp.modalDuration = 150;
				openImportPopUp.percentWidth = 80;
				openImportPopUp.percentHeight = 76;
				openImportPopUp.useHardPercent = true;
				openImportPopUp.parent = application;
				openImportPopUp.closeOnMouseDownOutside = false;
				openImportPopUp.closeOnMouseDownInside = false;
				openImportPopUp.closeOnEscapeKey = false;
				openImportPopUp.addEventListener(OpenPopUp.CLOSE, closeImportWindowHandler);
			}
		}
		
		/**
		 * Opens a new document with MXML specified
		 * */
		public function openMXMLDocument(name:String, mxml:String):void {
			name = name.lastIndexOf(".")!=-1 ? name.substr(0, name.lastIndexOf(".")) : name;
			importMXMLDocument(selectedProject, null, null, mxml, name);
		}
		
		/**
		 * When import MXML window is closed we check for requested action 
		 * and import if necessary 
		 * */
		public function closeImportWindowHandler(event:Event):void {
			var selectedDocument:IDocument = selectedDocument;
			var popUp:ImportWindow = ImportWindow(openImportPopUp.popUp);
			var type:String = popUp.importLocation.selectedValue as String;
			var action:String = popUp.action;
			var code:String = popUp.code;
			
			if (action==ImportWindow.IMPORT) {
				if (type==ImportWindow.NEW_DOCUMENT) {
					importMXMLDocument(selectedProject, null, null, code);
				}
				else if (type==ImportWindow.CURRENT_DOCUMENT && selectedDocument) {
					importMXMLDocument(selectedProject, selectedDocument, null, code);
				}
				else if (type==ImportWindow.CURRENT_SELECTION && target is IVisualElement) {
					if (target is IVisualElement) {
						importMXMLDocument(selectedProject, selectedDocument, IVisualElement(target), code);
					}
					Alert.show("Please select a visual element");
				}
				else {
					Alert.show("Please select a document");
				}
			}
			
			popUp.action = null;
			popUp.code = null;
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
			var numberOfDocuments:int = documents.length;
			var iDocument:IDocument;
			
			for (var i:int;i<numberOfDocuments;i++) {
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
			var numberOfDocuments:int = documents.length;
			var iDocument:IDocument;
			
			for (var i:int;i<numberOfDocuments;i++) {
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
		public function getProjectByUID(id:String):IProject {
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
		public function getProjectByID(id:int):IProject {
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
			var numberOfDocuments:int;
			var projectDocument:IDocument;
			var projectLength:int = projects.length;
			var iProject:IProject;
			var projectDocuments:Array;
			var projectsList:Array = [];
			
			for (var A:int;A<length;A++) {
				iProject = IProject(projects[A]);
				projectDocuments = iProject.documents;
				numberOfDocuments = projectDocuments ? projectDocuments.length : 0;
				
				for (var B:int;B<numberOfDocuments;B++) {
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
				error("Could not get saved data. " + ObjectUtil.toString(result));
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
				error("Could not get saved settings data. " + ObjectUtil.toString(result));
			}
			
			return true;
		}
		
		/**
		 * Get saved data
		 * */
		public function getSavedData():Object {
			var result:Object = SharedObjectUtils.getSharedObject(SAVED_DATA_NAME);
			var so:SharedObject;
			
			var data:SavedData;
			
			if (result is SharedObject) {
				so = SharedObject(result);
				
				if (so.data) {
					if (SAVED_DATA_NAME in so.data) {
						data = SavedData(so.data[SAVED_DATA_NAME]);
						
						//openLocalProjects(data);
					}
				}
			}
			else {
				error("Could not get saved data. " + ObjectUtil.toString(result));
			}
			
			return result;
		}
		
		/**
		 * Create new document. 
		 * */
		public function createNewDocument(name:String = null, type:Object = null, project:IProject = null):void {
			var newDocument:IDocument;
			
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
			var numberOfDocuments:int;
				
			// get documents and add them to the documents array
			
			// TRYING TO NOT create documents until they are needed
			// but then we have issues when we want to save
			if (documentsData && documentsData.length>0) {
				numberOfDocuments = documentsData.length;
				
				for (var i:int;i<numberOfDocuments;i++) {
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
			var numberOfPotentialProjects:int;
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
					numberOfPotentialProjects = potentialProjects.length;
					
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
					selectDocument(iDocument);
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
			var numberOfOpenItems:int = openProjects.length;
			
			// open previously opened projects
			for (var i:int;i<numberOfOpenItems;i++) {
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
				error("Could not get saved data. " + ObjectUtil.toString(result));
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
				error("Could not remove saved data. " + ObjectUtil.toString(result));
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
				error("Could not remove settings data. " + ObjectUtil.toString(result));
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
				error("Could not save data. " + ObjectUtil.toString(result));
				return false;
			}
			
			return true;
		}
		
		/**
		 * Save all projects and documents locally and remotely.
		 * Eventually, we will want to create a file options class that
		 * contains information on saving locally, to file, remotely, etc
		 * NOT FINISHED
		 * */
		public function save(locations:String = null, options:Object = null):void {
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
				catch (errorEvent:Error) {
					error(errorEvent.message);
					return false;
				}
				
			}
			else {
				error("Could not save data. " + ObjectUtil.toString(result));
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
			var diff:int;
			if (!date) date = new Date();
			//if (lastSaveDate) {
			//	updateLastSavedDifference(date);
			//}
			lastSaveDateFormatted = dateFormatter.format(date);
			
			//updateLastSavedDifference(date);
			
			lastSaveDate = date;
		}
		
		public function updateLastSavedDifference(date:Date):void {
			var diff:int = (new Date().valueOf() - date.valueOf())/1000;
			
			if (diff>60) {
				lastSaveDateDifference = int(diff/60) + " min ago";
			}
			else {
				lastSaveDateDifference = "Less than a min ago";
			}
		}

		/**
		 * Save project
		 * */
		public function saveProject(project:IProject, locations:String = null, options:Object = null):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var local:Boolean = ServicesManager.getIsLocalLocation(locations);
			var remote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var locallySaved:Boolean;
			
			if (project==null) {
				error("No project to save");
				return false;
			}
			
			//if (isUserLoggedIn && isUserConnected) {
			
			if (!isUserLoggedIn) {
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
		 * Save project only. Save project saves the project and all documents
		 * while save project only saves only the project.
		 * */
		public function saveProjectOnly(project:IProject, locations:String = null, options:Object = null):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var local:Boolean = ServicesManager.getIsLocalLocation(locations);
			var remote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var locallySaved:Boolean;
			
			if (project==null) {
				error("No project to save");
				return false;
			}
			
			
			if (!isUserLoggedIn) {
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
				locallySaved = saveProjectLocally(project);
				//project.saveCompleteCallback = saveData;
			}
			
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
				error("Could not save data. " + ObjectUtil.toString(result));
				//return false;
			}
			
			return true;
		}
		
		/**
		 * Save example projects usually called after login
		 * */
		public function saveExampleProject(projectData:IProject, locations:String = null):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var saveLocally:Boolean = ServicesManager.getIsLocalLocation(locations);
			var saveRemote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			
			var numberOfDocuments:int;
			var documentData:IDocumentData;
			var url:String = getWPURL();
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
		public function saveExampleProjects(locations:String = null):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var saveLocally:Boolean = ServicesManager.getIsLocalLocation(locations);
			var saveRemote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			
			var numberOfProjects:int = projects ? projects.length : 0;
			var numberOfDocuments:int;
			var documentData:IDocumentData;
			var projectData:IProjectData;
			var url:String = getWPURL();
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
							
							if (documentData.uid=="null" || documentData.uid==null) {
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
		 * Save target as image.
		 * */
		public function saveAsImage(target:Object, options:Object = null):Boolean {
			var bitmapData:BitmapData;
			var fileName:String;
			var componentDescription:ComponentDescription;
			
			if (target==null) {
				error("No document to save");
				return false;
			}
			
			if (target is ComponentDescription) {
				componentDescription = target as ComponentDescription;
				target = componentDescription.instance;
			}
			else {
				componentDescription = selectedDocument.getItemDescription(target);
			}
			
			if (componentDescription) {
				fileName = componentDescription.name;
			}
			else {
				fileName = selectedDocument.name;
			}
			
			if (target) {
				if (target is IDocument) {
					target = DisplayObjectUtils.getAnyTypeBitmapData(IDocument(target).instance);
				}
				else {
					try {
						bitmapData = DisplayObjectUtils.getAnyTypeBitmapData(target);
					}
					catch (errorEvent:ErrorEvent) {
						error(errorEvent.text, errorEvent);
					}
				}
				
				var byteArray:ByteArray;
				
				if (bitmapData) {
					if (bitmapData.width!=0 && bitmapData.height) {
						byteArray = DisplayObjectUtils.getBitmapByteArray(bitmapData);
						saveFileAs(byteArray, fileName, "png");
						return true;
					}
					else {
						error("Selection must have a width and height greater than 0");
					}
				}
			}
			
			return false;
		}

		/**
		 * Save document. Uses constants, DocumentData.LOCAL_LOCATION, DocumentData.REMOTE_LOCATION, etc
		 * Separate them by ",". 
		 * */
		public function saveDocument(iDocument:IDocument, locations:String = null, options:Object = null):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var saveLocally:Boolean = ServicesManager.getIsLocalLocation(locations);
			var saveRemote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var saveLocallySuccessful:Boolean;
			
			//trace("- Radiate save document " + iDocument.name);
			
			if (iDocument==null) {
				error("No document to save");
				return false;
			}
			
			if (saveRemote && iDocument && iDocument is EventDispatcher) {
				EventDispatcher(iDocument).addEventListener(SaveResultsEvent.SAVE_RESULTS, documentSaveResultsHandler, false, 0, true);
				saveDocumentInProgress = true;
			}
			
			iDocument.saveFunction = saveDocumentHook;
			
			saveLocallySuccessful = iDocument.save(locations, options);
			
			// TODO add support to save after response from server 
			// because ID's may have been added from new documents
			//saveData();
			//document.saveCompleteCallback = saveData;
			//saveDocumentLocally(document);
			return saveLocallySuccessful;
		}
		
		/**
		 * This gets called on save. It allows you to modify what is saved. 
		 * */
		public function saveDocumentHook(iDocument:IDocument, data:Object):Object {
			var htmlOptions:HTMLExportOptions;
			var language:String = CodeManager.HTML;
			var output:String = "";
			var sourceData:SourceData;
			
			if (language == CodeManager.HTML) {
				htmlOptions = CodeManager.getExportOptions(language) as HTMLExportOptions;
				
				htmlOptions.template = iDocument.template;
				//htmlOptions.bordersCSS = bordersCSS;
				//htmlOptions.showBorders = showBorders;
				//htmlOptions.useBorderBox = useBoderBox;
				//htmlOptions.useInlineStyles = setStylesInline.selected;
				//htmlOptions.template = iDocument.template;
				//htmlOptions.disableTabs = true;
				//htmlOptions.useExternalStylesheet = false;
				
				//if (updateCodeLive.selected && isCodeModifiedByUser) {
					//htmlOptions.useCustomMarkup = true;
					//htmlOptions.markup = aceEditor.text;
					//htmlOptions.styles = aceCSSEditor.text;
				//}
				
				sourceData = CodeManager.getSourceData(iDocument.instance, iDocument, language, htmlOptions);
				
				data["custom[html]"] = sourceData.source;
				data["custom[styles]"] = sourceData.styles;
				data["custom[userStyles]"] = sourceData.userStyles;
				data["custom[template]"] = sourceData.template;
				data["custom[markup]"] = sourceData.markup;
				iDocument.errors = sourceData.errors;
				iDocument.warnings = sourceData.warnings;
				
			}
			
			return data;
		}
		
		/**
		 * Handles uncaught errors from an HTML preview document
		 * */
		protected function uncaughtScriptExceptionHandler(event:*):void {
			//var target:Object = event.currentTarget;
			var exceptionValue:Object = event.exceptionValue;
			
			error("Line " + exceptionValue.line + "  " + exceptionValue.name + ": " + exceptionValue.message);
		}
		
		/**
		 * Handles results from document save
		 * */
		protected function documentSaveResultsHandler(event:SaveResultsEvent):void {
			var document:IDocument = IDocument(event.currentTarget);
			saveDocumentInProgress = false;
			
			if (document is Document) {
				Document(document).removeEventListener(SaveResultsEvent.SAVE_RESULTS, documentSaveResultsHandler);
			}
			
			
			if (event.successful) {
				setLastSaveDate();
				dispatchDocumentSaveCompleteEvent(document);
			}
			else {
				dispatchDocumentSaveFaultEvent(document);
			}
		}
		
		/**
		 * Save all projects
		 * */
		public function saveAllProjects(locations:String = null, saveEvenIfClean:Boolean = true):Boolean {
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
		 * Save all documents
		 * */
		public function saveAllDocuments(locations:String = null, saveEvenIfClean:Boolean = true):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var loadLocally:Boolean = ServicesManager.getIsLocalLocation(locations);
			var loadRemote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var numberOfDocuments:int = documents.length;
			var document:IDocument;
			var anyDocumentSaved:Boolean;
			
			if (numberOfDocuments==0) {
				warn("No douments to save");
				return false;
			}
			
			for (var i:int;i<numberOfDocuments;i++) {
				document = documents[i];
				
				if (document.isChanged || saveEvenIfClean) {
					document.save(locations);
					// TODO add support to save after response from server 
					// because ID's may have been added from new documents
					//saveData();
					//document.saveCompleteCallback = saveData;
					saveDocumentLocally(document);
					anyDocumentSaved = true;
				}
			}
			
			return anyDocumentSaved;
		}
		
		/**
		 * Get assets available to upload
		 * */
		public function getAssetsAvailableToUpload():Array {
			var numberOfAssets:int;
			var attachmentData:AttachmentData;
			var assetsToUpload:Array = [];
			
			numberOfAssets = assets.length;
			
			for (var i:int=0;i<numberOfAssets;i++) {
				attachmentData = assets[i] as AttachmentData;
				
				if (attachmentData) {
					
					if (attachmentData.id==null) {
						
						if (assetsToUpload.indexOf(attachmentData)==-1) {
							assetsToUpload.push(attachmentData);
						}
					}
				}
			}
			
			return assetsToUpload;
		}
		
		/**
		 * Save all attachments. 
		 * */
		public function saveAllAttachments(iDocument:DocumentData, saveToProject:Boolean = false, locations:String = null, saveEvenIfClean:Boolean = true):Boolean {
			if (locations==null) locations = DocumentData.REMOTE_LOCATION;
			var loadLocally:Boolean = ServicesManager.getIsLocalLocation(locations);
			var loadRemote:Boolean = ServicesManager.getIsRemoteLocation(locations);
			var document:IDocument;
			var anyDocumentSaved:Boolean;
			var numberOfAttachments:int;
			var numberOfAttachmentsToUpload:int;
			var numberOfAssets:int;
			var attachmentData:AttachmentData;
			var imageData:ImageData;
			var targetPostID:String;
			var projectID:String;
			var attachmentParentID:String;
			var hasAttachments:Boolean;
			var customData:Object;
			var uploadingStillInProgress:Boolean;

			// Continues in uploadAttachmentResultsHandler
			
			if (uploadAttachmentInProgress) {
				callAfter(100, saveAllAttachments, iDocument, saveToProject, locations, saveEvenIfClean);
				return true;
			}
			
			if (saveToProject) {
				projectID = iDocument.parentId;
				targetPostID = projectID;
			}
			else {
				targetPostID = iDocument.id;
			}
			
			// save attachments
			numberOfAssets = assets.length;
			
			if (numberOfAssets==0) {
				info("No attachments to save");
				return false;
			}
			
			if (attachmentsToUpload==null) {
				attachmentsToUpload = [];
			}
			else if (attachmentsToUpload.length) {
				uploadingStillInProgress = true;
			}
			
			// get attachments that still need uploading
			
			if (!uploadingStillInProgress) {
				for (var i:int=0;i<numberOfAssets;i++) {
					attachmentData = assets[i] as AttachmentData;
					
					if (attachmentData) {
						attachmentParentID = attachmentData.parentId;
						
						if (attachmentParentID==null) {
							attachmentData.parentId = iDocument.id;
							attachmentParentID = iDocument.id;
						}
						
						// only add if matches document or project
						// you need to set the parent ID at 
						if (attachmentParentID!=targetPostID && attachmentParentID!=projectID) {
							continue;
						}
						
						if (attachmentData.id==null) {
							
							if (attachmentsToUpload.indexOf(attachmentData)==-1) {
								attachmentsToUpload.push(attachmentData);
							}
						}
					}
				}
			}
			
			numberOfAttachmentsToUpload = attachmentsToUpload.length;
			customData = {};
			
			for (var m:int = 0; m < numberOfAttachmentsToUpload; m++) {
				attachmentData = attachmentsToUpload[m];
				
				// trying to add a custom field with the uid - doesn't works
				if (attachmentData.uid) {
					customData["custom[uid]"] = attachmentData.uid;
					customData["caption"] = attachmentData.uid;
					customData["post_excerpt"] = attachmentData.uid;
					customData["post_title"] = attachmentData.name;
				}
				
				imageData = attachmentData as ImageData;
				
				if (imageData) {
					if (imageData.byteArray==null && imageData.bitmapData) {
						imageData.byteArray = DisplayObjectUtils.getBitmapByteArray(imageData.bitmapData);
						//imageData.name = ClassUtils.getIdentifierNameOrClass(initiator) + ".png";
						imageData.contentType = DisplayObjectUtils.PNG_MIME_TYPE;
						imageData.file = null;
					}
					
					if (!imageData.saveInProgress && imageData.id==null) {
						
						//imageData.save();
						hasAttachments = true;
						imageData.saveInProgress = true;
						currentAttachmentToUpload = imageData;
						
						//trace("Uploading attachment " + currentAttachmentToUpload.name + " to post " + targetPostID);
						
						uploadAttachment(imageData.byteArray, targetPostID, imageData.name, null, imageData.contentType, customData);
						break;
					}
				}
				else {
					
					hasAttachments = true;
					attachmentData.saveInProgress = true;
					currentAttachmentToUpload = attachmentData;
					
					//trace("Uploading attachment " + currentAttachmentToUpload.name + " to post " + targetPostID);
					
					uploadAttachment(attachmentData.byteArray, targetPostID, attachmentData.name, null, attachmentData.contentType, customData);
					break;
				}
			}
			
			
			//for (var i:int;i<numberOfAttachments;i++) {
				//document = documents[i];
				
				//document.upload(locations);
				// TODO add support to save after response from server 
				// because ID's may have been added from new documents
				//saveData();
				//document.saveCompleteCallback = saveData;
				//saveDocumentLocally(document);
			//	anyDocumentSaved = true;
			//}
			
			if (hasAttachments) {
				callAfter(100, saveAllAttachments, iDocument, saveToProject, locations, saveEvenIfClean);
			}
			
			return anyDocumentSaved;
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
		 * Save multiple files
		 * */
		public function saveFiles(sourceData:SourceData, directory:Object, overwrite:Boolean = false):Boolean {
			var file:Object;
			var files:Array = sourceData.files;
			var fileName:String;
			var numberOfFiles:int = files ? files.length : 0;
			var fileClassDefinition:String = "flash.filesystem.File";
			var fileStreamDefinition:String = "flash.filesystem.FileStream";
			var FileClass:Object = ClassUtils.getDefinition(fileClassDefinition);
			var FileStreamClass:Object = ClassUtils.getDefinition(fileStreamDefinition);
			var fileStream:Object;
			var writeFile:Boolean;
			var filesCreated:Boolean;
			var fileInfo:FileInfo;
			
			for (var i:int;i<numberOfFiles;i++) {
				fileInfo = files[i];
				fileInfo.created = false;
				fileName = fileInfo.fileName + "." + fileInfo.fileExtension;
				
				if (!directory.exists) {
					directory.createDirectory();
				}
				
				file = directory.resolvePath(fileName);
				
				if (file.exists && !overwrite) {
					writeFile = false;
				}
				else {
					writeFile = true;
				}
				
				if (writeFile) {
					fileStream = new FileStreamClass();
					// this might be causing an error on windows - might need to change to read / write
					fileStream.open(file, "write");// FileMode.WRITE
					fileStream.writeUTFBytes(fileInfo.contents);
					fileStream.close();
					fileInfo.created = true;
					fileInfo.filePath = file.nativePath;
					fileInfo.url = file.url;
					filesCreated = true;
				}
			}
			
			return filesCreated;
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
			addFileSaveAsListeners(fileReference);
			
			fileReference.save(data, fileName);
			
			return fileReference;
		}
		
		/**
		 * Adds file save as listeners. Rename or refactor
		 * */
		public function addFileSaveAsListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.CANCEL, cancelFileSaveAsHandler, false, 0, true);
			dispatcher.addEventListener(Event.COMPLETE, completeFileSaveAsHandler, false, 0, true);
		}
		
		/**
		 * Removes file save as listeners. Rename or refactor
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
				var numberOfDocuments:int = documentsArray.length;
				var documentData:IDocumentData;
				var found:Boolean;
				var foundIndex:int = -1;
				
				for (var i:int;i<numberOfDocuments;i++) {
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
				error("Could not get saved data. " + ObjectUtil.toString(result));
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
				error("Could not save data. " + ObjectUtil.toString(result));
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
			
			settings.enableAutoSave 	= enableAutoSave;
			
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
		 * Upload attachment data to the server
		 * */
		public function uploadAttachmentData(attachmentData:AttachmentData, id:String):void {
			if (attachmentData==null) {
				warn("No attachment to upload");
				return;
			}
			
			var imageData:ImageData = attachmentData as ImageData;
			var formattedName:String = attachmentData.name!=null ? attachmentData.name : null;
			
			if (formattedName) {
				
				if (formattedName.indexOf(" ")!=-1) {
					formattedName = formattedName.replace(/ /g, "");
				}
			}
			
			if (imageData && imageData.bitmapData && imageData.byteArray==null) {
				attachmentData.byteArray = DisplayObjectUtils.getBitmapByteArray(BitmapData(imageData.bitmapData));
				
				if (formattedName && formattedName.indexOf(".")==-1) {
					formattedName = formattedName + ".png";
				}
				
				imageData.contentType = DisplayObjectUtils.PNG_MIME_TYPE;
			}
			
			
			uploadAttachment(attachmentData.byteArray, id, formattedName, null, attachmentData.contentType, null, attachmentData);
		}
		
		/**
		 * Upload image to the server.
		 * File name cannot have spaces and must have an extension.
		 * If you pass bitmap data it is converted to a PNG
		 * */
		public function uploadAttachment(data:Object, id:String, fileName:String = null, 
										 dataField:String = null, contentType:String = null, 
										 customData:Object = null, attachmentData:AttachmentData = null):void {
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
			
			if (attachmentData) {
				currentAttachmentToUpload = attachmentData;
				currentAttachmentToUpload.saveInProgress = true;
			}
			
			uploadAttachmentService.customData = customData;
			
			uploadAttachmentInProgress = true;
			
			var formattedName:String = fileName!=null ? fileName : null;
			
			if (formattedName) {
				
				if (formattedName.indexOf(" ")!=-1) {
					formattedName = formattedName.replace(/ /g, "");
				}
				
				if (formattedName.indexOf(".")==-1) {
					
					if (contentType==DisplayObjectUtils.PNG_MIME_TYPE) {
						formattedName = formattedName + ".png";
					}
				}
			}
			
			
			if (data is FileReference) {
				uploadAttachmentService.file = data as FileReference;
				uploadAttachmentService.uploadAttachment();
			}
			else if (data) {
				
				if (data is ByteArray) {
					uploadAttachmentService.fileData = data as ByteArray;
				}
				else if (data is BitmapData) {
					uploadAttachmentService.fileData = DisplayObjectUtils.getBitmapByteArray(BitmapData(data));
					
					if (formattedName && formattedName.indexOf(".")==-1) {
						formattedName = formattedName + ".png";
					}
					
					contentType = DisplayObjectUtils.PNG_MIME_TYPE;
				}
				
				if (formattedName) {
					uploadAttachmentService.fileName = formattedName;
				}
				
				if (dataField) {
					uploadAttachmentService.dataField = dataField;
				}
				
				// default content type in service is application/octet
				if (contentType) {
					uploadAttachmentService.contentType = contentType;
				}
				
				uploadAttachmentService.uploadAttachment();
			}
			else {
				attachmentData.saveInProgress = false;
				uploadAttachmentInProgress = false;
				warn("No data or file is available for upload. Please select the file to upload.");
			}
			
		}
		
		/**
		 * Updates the user information from data object from the server
		 * */
		public function updateUserInfo(data:Object):void {
			
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
						WP_USER_PATH = userSitePath;
						WP_USER_PATH = WP_USER_PATH.replace(WP_PATH, "");
					}
					else {
						userSitePath = "";
						WP_USER_PATH = "";
					}
				}
				
				if (isUserLoggedIn==false) {
					userSitePath = "";
					WP_USER_PATH = "";
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
				WP_USER_PATH = "";
			}
		}
		
		/**
		 * Results from call to get projects
		 * */
		public function getProjectsResultsHandler(event:IServiceEvent):void {
			
			//Radiate.info("Retrieved list of projects");
			
			var data:Object = event.data;
			
			getProjectsInProgress = false;
			
			dispatchGetProjectsListResultsEvent(data);
		}
		
		/**
		 * Open list of projects. Need to eventually convert from wordpress post data object to type classes.
		 * See getAttachmentsResultsHandler() 
		 * */
		public function openProjectsFromData(projectsData:Array):void {
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
			Radiate.info("Could not get list of projects");
			
			getProjectsInProgress = false;
			
			dispatchGetProjectsListResultsEvent(data);
		}
		
		/**
		 * Result get attachments
		 * */
		public function getAttachmentsResultsHandler(event:IServiceEvent):void {
			Radiate.info("Retrieved list of attachments");
			var data:Object = event.data;
			var potentialAttachments:Array = [];
			var numberOfAttachments:int;
			var object:Object;
			var attachment:AttachmentData;
			
			if (data && data.count>0) {
				numberOfAttachments = data.count;
				
				for (var i:int;i<numberOfAttachments;i++) {
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
			
			Radiate.info("Could not get list of attachments");
			
			getAttachmentsInProgress = false;
			
			//dispatchEvent(saveResultsEvent);
			dispatchAttachmentsResultsEvent(false, []);
		}
		
		/**
		 * Result upload attachment
		 * */
		public function uploadAttachmentResultsHandler(event:IServiceEvent):void {
			//Radiate.info("Upload attachment");
			var data:Object = event.data;
			//var potentialAttachments:Array = [];
			var successful:Boolean = data && data.status && data.status=="ok" ? true : false;
			var numberOfRemoteAttachments:int;
			//var remoteAttachment:Object;
			//var remoteAttachmentData:AttachmentData;
			//var attachmentData:AttachmentData;
			var remoteAttachments:Array = data && data.post && data.post.attachments ? data.post.attachments : []; 
			var containsName:Boolean;
			var numberOfAttachmentsToUpload:int;
			var numberOfDocuments:int;
			var foundAttachment:Boolean;
			var lastAddedRemoteAttachment:Object;
			//var currentAttachment:AttachmentData;
			
			// current attachment being uploaded
			//currentAttachmentToUpload
			
			// last attachment successfully uploaded
			lastAddedRemoteAttachment = remoteAttachments && remoteAttachments.length ? remoteAttachments[remoteAttachments.length-1]: null;

			var localIDExists:Boolean = com.flexcapacitor.utils.ArrayUtils.hasItem(assets, lastAddedRemoteAttachment.id, "id");
			
			if (currentAttachmentToUpload) {
				currentAttachmentToUpload.saveInProgress = false;
			}
			
			if (lastAddedRemoteAttachment && currentAttachmentToUpload) {
				//trace("Last uploaded attachment is " + lastAddedRemoteAttachment.title + " with id of " + lastAddedRemoteAttachment.id);
				containsName = lastAddedRemoteAttachment.slug.indexOf(currentAttachmentToUpload.slugSafeName)!=-1;
			}
			
			if (!localIDExists) {
				/*
				if (String(remoteAttachment.mime_type).indexOf("image/")!=-1) {
					remoteAttachmentData = new ImageData();
					remoteAttachmentData.unmarshall(lastRemoteAttachment);
				}
				else {
					remoteAttachmentData = new AttachmentData();
					remoteAttachmentData.unmarshall(lastRemoteAttachment);
				}*/
				foundAttachment = true;
				
				if (currentAttachmentToUpload) {
					currentAttachmentToUpload.unmarshall(lastAddedRemoteAttachment);
					currentAttachmentToUpload.uploadFailed = false;
				}
				
				// loop through documents and replace bitmap data with url to source
				numberOfDocuments = documents.length;
				k = 0;
				
				for (var k:int;k<numberOfDocuments;k++) {
					var iDocument:IDocument = documents[k] as IDocument;
					
					if (iDocument) {
						DisplayObjectUtils.walkDownComponentTree(iDocument.componentDescription, replaceBitmapData, [currentAttachmentToUpload]);
					}
				}
			}
			else {
				warn("Attachment " + currentAttachmentToUpload.name + " could not be uploaded");
				currentAttachmentToUpload ? currentAttachmentToUpload.uploadFailed = true : -1;
				successful = false;
				foundAttachment = false;
			}
			
			lastAttemptedUpload = attachmentsToUpload && attachmentsToUpload.length ? attachmentsToUpload.unshift() : null;
			
			uploadAttachmentInProgress = false;
			
			if (!foundAttachment) {
				successful = false;
				dispatchUploadAttachmentResultsEvent(successful, [], data.post);
			}
			else {
				dispatchUploadAttachmentResultsEvent(successful, [currentAttachmentToUpload], data.post);
			}
			
			if (attachmentsToUpload && attachmentsToUpload.length) {
				// we should do this sequencially
			}
			
			currentAttachmentToUpload = null;
		}
		
		/**
		 * Result from upload attachment fault
		 * */
		public function uploadAttachmentFaultHandler(event:IServiceEvent):void {
			Radiate.info("Upload attachment fault");
			
			lastAttemptedUpload = attachmentsToUpload && attachmentsToUpload.length ? attachmentsToUpload.unshift() : null;
			
			uploadAttachmentInProgress = false;
			
			if (currentAttachmentToUpload) {
				currentAttachmentToUpload.saveInProgress = false;
			}
			
			if (attachmentsToUpload.length) {
				// we should do this sequencially
			}
			
			//dispatchEvent(saveResultsEvent);
			dispatchUploadAttachmentResultsEvent(false, [], event.data, event.faultEvent);
			
			currentAttachmentToUpload = null;
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
					if (instance.source is BitmapData && 
						instance.source == imageData.bitmapData && 
						imageData.bitmapData!=null) {
						Radiate.setProperty(instance, "source", imageData.url);
					}
				}
			}
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
			
			dispatchProjectDeletedEvent(successful, data);
		}
		
		/**
		 * Result from delete project fault
		 * */
		public function deleteProjectFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.info("Could not connect to the server to delete the project. ");
			
			deleteProjectInProgress = false;
			
			dispatchProjectDeletedEvent(false, data);
		}
		
		/**
		 * Delete document results handler. You should save the project after
		 * document is deleted.
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
			
			dispatchDocumentDeletedEvent(successful, data);
			
			if (successful) {
				
				if (deleteDocumentProjectId!=-1 && saveProjectAfterDelete) {
					var iProject:IProject = getProjectByID(deleteDocumentProjectId);
					
					if (iProject) {
						iProject.save();
					}
				}
				
			}
			
			saveProjectAfterDelete = false;
		}
		
		/**
		 * Result from delete project fault
		 * */
		public function deleteDocumentFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.info("Could not connect to the server to delete the document. ");
			
			deleteDocumentInProgress = false;
			
			dispatchDocumentDeletedEvent(false, data);
		}
		
		/**
		 * Delete attachments. You should save the project after
		 * document is deleted.
		 * */
		public function deleteAttachmentsResultsHandler(event:IServiceEvent):void {
			//..Radiate.info("Delete document results");
			var data:Object = event.data;
			var deletedItems:Object = data ? data.deletedItems : [];
			var successful:Boolean;
			var error:String;
			var message:String;
			
			
			if (data && data is Object && "successful" in data) {
				successful = data.successful != "false";
			}
			
			deleteAttachmentsInProgress = false;
			
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
			
			dispatchAttachmentsDeletedEvent(successful, data);
			
			if (successful) {
				
				if (deleteDocumentProjectId!=-1 && saveProjectAfterDelete) {
					var iProject:IProject = getProjectByID(deleteDocumentProjectId);
					
					if (iProject) {
						iProject.save();
					}
				}
				
			}
			
			saveProjectAfterDelete = false;
		}
		
		/**
		 * Result from delete attachments fault
		 * */
		public function deleteAttachmentsFaultHandler(event:IServiceEvent):void {
			var data:Object = event.data;
			
			Radiate.info("Could not connect to the server to delete the document. ");
			
			deleteAttachmentsInProgress = false;
			
			dispatchAttachmentsDeletedEvent(false, data);
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
			var numberOfDocuments:int = documentsArray.length;
			var documentMetaData:IDocumentMetaData;
			var found:Boolean;
			var foundIndex:int = -1;
			
			for (var i:int;i<numberOfDocuments;i++) {
				documentMetaData = IDocumentMetaData(documentsArray[i]);
				//Radiate.info("Exporting document " + iDocument.name);
				
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
		 * Get an array of projects serialized for storage. 
		 * If open is set to true then only returns open projects.
		 * If meta data is true then only returns meta data. 
		 * */
		public function saveProjectsRemotely(open:Boolean = false):Array {
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
		 * Returns true if two objects are of the same class type
		 * */
		public function isSameClassType(target:Object, target1:Object):Boolean {
			return ClassUtils.isSameClassType(target, target1);
		}
		
		/**
		 * Catch uncaught errors
		 */
		public function uncaughtErrorHandler(event:UncaughtErrorEvent):void {
			event.preventDefault();
			
			//to capture the error message
			var errorMessage:String = new String();
			var error:Object;
			
			if (event) {
				error = "error" in event ? event.error : null;
				
				if (error is Error && "message" in event.error) {
					errorMessage = Error(event.error).message;
				}
				else if (error is ErrorEvent && "text" in event.error) {
					errorMessage = ErrorEvent(event.error).text;
				}
				else if (error) {
					errorMessage = event.error.toString();
				}
				else {
					errorMessage = event.toString();
				}
				
			}
			
			
			Radiate.error(errorMessage);
			
		}
		
		/**
		 * Removes ID and location data from example projects so that the user can 
		 * save and modify them themselves
		 * */
		public function clearExampleProjectData(exampleProject:IProject):Boolean {
			if (!exampleProject) return false;
			var exampleDocuments:Array;
			var numberOfDocuments:int;
			var exampleDocument:IDocument;
			
			exampleProject.id = null;
			exampleProject.uid = null;
			exampleDocuments = exampleProject.documents;
			numberOfDocuments = exampleDocuments ? exampleDocuments.length :0;
			
			for (var i:int;i<numberOfDocuments;i++) {
				exampleDocument = exampleDocuments[i] as IDocument;
				
				if (exampleDocument) {
					exampleDocument.id = null;
					exampleDocument.uid = UIDUtil.createUID();
					exampleDocument.isExample = true;
				}
			}
			
			exampleProject.isExample = true;
			
			return true;
		}
		
		/**
		 * Update imported code so you can import it
		 * */
		public static function editImportingCode(message:String, ...Arguments):void {
			log.info("The document did not contain valid source code. Open the import window and edit the code or choose an earlier revision.");
		}
		
		/**
		 * Open document for editing in browser. 
		 * */
		public static function editDocumentInBrowser(documentData:IDocumentData):void {
			var request:URLRequest;
			var url:String;
			request = new URLRequest();
			
			if (documentData && documentData.id==null) {				
				error("The document ID is not set. You may need to save the document first.");
			}
			
			if (documentData is ImageData) {
				url = ImageData(documentData).url;
			}
			else {
				url = getWPEditPostURL(documentData);
			}
			
			if (url) {
				request.url = url;
				navigateToURL(request, "editInBrowser");
			}
			else {
				error("URL to the document was not set. You may need to save the document first.");
			}
		}
		
		/**
		 * Open document in browser. Right now you must be 
		 * logged in or the document must be published
		 * */
		public static function openInBrowser(documentData:IDocumentData, windowName:String = null):void {
			var request:URLRequest;
			var url:String;
			
			if (documentData==null) {
				warn("Please select a document.");
				return;
			}
			
			request = new URLRequest();
			
			if (windowName==null && documentData.name) {
				windowName = documentData.name;
			}
			
			if (documentData is ImageData) {
				url = ImageData(documentData).url;
			}
			else {
				url = documentData.uri;
			}
			
			if (url) {
				request.url = url;
				navigateToURL(request, windowName);
			}
			else {
				error("The URL was not set. You may need to save the document first.");
			}
		}
		
		/**
		 * Open document in browser screenshot site. 
		 * The document must be published so the external site can view it
		 * */
		public static function openInBrowserScreenshot(documentData:IDocumentData, windowName:String = null):void {
			var request:URLRequest;
			var url:String;
			
			if (documentData==null) {
				warn("Please select a document.");
				return;
			}
			
			request = new URLRequest();
			
			if (windowName==null && documentData.name) {
				windowName = documentData.name;
			}
			
			if (documentData is ImageData) {
				url = ImageData(documentData).url;
			}
			else {
				url = documentData.uri;
			}
			
			if (url) {
				request.url = SCREENSHOT_PATH + url;
				navigateToURL(request, windowName);
			}
			else {
				error("The URL was not set. You may need to publish and save the document first.");
			}
		}
		
		/**
		 * Open document in browser site scanner site. 
		 * The document must be published so the external site can view it
		 * */
		public static function openInBrowserSiteScanner(documentData:IDocumentData, windowName:String = null):void {
			var request:URLRequest;
			var url:String;
			
			if (documentData==null) {
				warn("Please select a document.");
				return;
			}
			
			request = new URLRequest();
			
			if (windowName==null && documentData.name) {
				windowName = documentData.name;
			}
			
			if (documentData is ImageData) {
				url = ImageData(documentData).url;
			}
			else {
				url = documentData.uri;
			}
			
			if (url) {
				request.url = SITE_SCANNER_PATH + encodeURI(url);
				navigateToURL(request, windowName);
			}
			else {
				error("The URL was not set. You may need to publish and save the document first.");
			}
		}
		
		/**
		 * Open document in browser. Right now you must be 
		 * logged in or the document must be published
		 * */
		public static function loginThroughBrowser():void {
			var value:Object = PersistentStorage.read(Radiate.USER_STORE);
			
			if (value!=null) {
				serviceManager.loginThroughBrowser(value.u, value.p, true);
			}
			else {
				info("No login was saved.");
				setTimeout(openUsersLoginPage, 1000);
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
			
			stackTrace = getStackTrace();
			
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
			
			className = sender ? ClassUtils.getClassName(sender) : "";
			
			if (message=="") {
				
			}
			
			if (event && "error" in event) {
				errorObject = event.error;
			}
			else if (event is Error) {
				errorObject = event;
			}
			
			if (errorObject) {
				message = "message" in errorObject ? errorObject.message : "";
				message = "text" in errorObject ? errorObject.text : message;
				type = "type" in errorObject ? errorObject.type : "";
				errorID = "errorID" in errorObject ? errorObject.errorID : "";
				name = "name" in errorObject ? errorObject.name : "";
			}
			
			stackTrace = getStackTrace();
			
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
			var className:String = sender ? ClassUtils.getClassName(sender) : "";
			
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
			var className:String = sender ? ClassUtils.getClassName(sender) : "";
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
			var className:String = sender ? ClassUtils.getClassName(sender) : "";
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
		protected static function getStackTrace(removeLines:Boolean = true):String {
			var error:Error = new Error();
			var value:String;
			var stackTrace:Array;
			
			if ("getStackTrace" in error) {
				value = error.getStackTrace();
				value = value.replace(/\t/, "");
				if (removeLines) {
					value = value.replace(/\[.*\]/g, "");
					value = value.replace(/.*?::/g, "");
				}
				stackTrace = value.split("\n");
				stackTrace.shift();
				stackTrace.shift();
				stackTrace.shift();
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
		
		public static var showMessageAnimation:Sequence;
		public static var showMessageLabel:Label;

		public static var attachmentsToUpload:Array;
		public static var currentAttachmentToUpload:AttachmentData;
		public static var lastAttemptedUpload:Object;
		
		/**
		 * Calls a function after a set amount of time. 
		 * */
		public static function callAfter(time:int, method:Function, ...Arguments):void {
			var sprite:Sprite = new Sprite();
			var startTime:int = getTimer() + time;
			
			// todo: find out if this causes memory leaks
			sprite.addEventListener(Event.ENTER_FRAME, function(e:Event):void {
				if (getTimer()>startTime) {
					sprite.removeEventListener(Event.ENTER_FRAME, arguments.callee);
					method.apply(this, Arguments);
					method = null;
				}
			});
		}
		
		/**
		 * Sizes the document to the current selected target
		 * */
		public static function sizeDocumentToSelection():void {
			var iDocument:IDocument = instance.selectedDocument;
			
			if (instance.target && iDocument) {
				var rectangle:Rectangle = getSize(instance.target);
				
				if (rectangle.width>0 && rectangle.height>0) {
					setProperties(iDocument.instance, ["width","height"], rectangle, "Size document to selection");
				}
			}
		}
		
		/**
		 * Sizes the document to the current selected target
		 * */
		public static function restoreImageToOriginalSize(target:Object):Boolean {
			var rectangle:Rectangle;
			var image:Image = target as Image;
			var bitmapImage:BitmapImage = image ? image.imageDisplay : null;
			var bitmapData:BitmapData;
			var resized:Boolean;
			
			if (image) {
				bitmapData = image.bitmapData;
			}
			else if (bitmapImage) {
				bitmapData = bitmapImage.bitmapData;
			}
			
			if (image || bitmapImage) {
				rectangle = new Rectangle(0, 0, target.sourceWidth, target.sourceHeight);
				
				if (rectangle.width>0 && 
					rectangle.height>0 &&
					target.width!=rectangle.width && 
					target.height!=rectangle.height) {
					setProperties(target, ["width","height"], rectangle, "Restore to original size");
					resized = true;
				}
			}
			
			return resized;
		}
		
		/**
		 * Sizes the document to the bitmap data target
		 * */
		public static function sizeDocumentToBitmapData(iDocument:IDocument, bitmapData:BitmapData):Boolean {
			var documentInstance:Object = iDocument.instance;
			var rectangle:Rectangle;
			var resized:Boolean;
			
			if (documentInstance) {
				rectangle = new Rectangle(0, 0, bitmapData.width, bitmapData.height);
				
				if (rectangle.width>0 && 
					rectangle.height>0 &&
					documentInstance.width!=rectangle.width && 
					documentInstance.height!=rectangle.height) {
					setProperties(documentInstance, ["width","height"], rectangle, "Size document to image");
					resized = true;
				}
			}
			
			return resized;
		}
		
		/**
		 * Sizes the current selected target to the document
		 * */
		public static function sizeSelectionToDocument(target:Object = null):Boolean {
			var iDocument:IDocument = instance.selectedDocument;
			var targetToResize:Object = target ? target : instance.target;
			var rectangle:Rectangle;
			var resized:Boolean;
			
			if (targetToResize && iDocument) {
				rectangle = getSize(iDocument.instance);
				
				if (rectangle.width>0 && rectangle.height>0 && 
					targetToResize.width!=rectangle.width && 
					targetToResize.height!=rectangle.height) {
					setProperties(targetToResize, ["width","height"], rectangle, "Size selection to document");
					resized = true;
				}
			}
			
			return resized;
		}
		
		/**
		 * Saves the selected target as an image in the library. 
		 * If successful returns ImageData. If unsuccessful returns Error
		 * */
		public static function saveToLibrary(target:Object):Object {
			var iDocument:IDocument = instance.selectedDocument;
			var snapshotTest:Boolean = true;
			var snapshot:Object;
			var data:ImageData;
			
			if (target && iDocument) {
				
				if (snapshotTest) {
					if (target is UIComponent) {
						// new 2015 method from Bitmap utils
						snapshot = DisplayObjectUtils.getSnapshotWithQuality(target as UIComponent);
					}
					else if (target is DisplayObject) {
						snapshot = DisplayObjectUtils.rasterize2(target as DisplayObject);
					}
				}
				else {
					if (target is UIComponent) {
						snapshot = DisplayObjectUtils.getUIComponentWithQuality(target as UIComponent);
					}
					else if (target is DisplayObject) {
						snapshot = DisplayObjectUtils.rasterize2(target as DisplayObject);
					}
				}
				
				if (snapshot is BitmapData) {
					data = new ImageData();
					data.bitmapData = snapshot as BitmapData;
					data.byteArray = DisplayObjectUtils.getBitmapByteArray(snapshot as BitmapData);
					data.name = ClassUtils.getIdentifierNameOrClass(target) + ".png";
					data.contentType = DisplayObjectUtils.PNG_MIME_TYPE;
					data.file = null;
					
					instance.addAssetToDocument(data, instance.selectedDocument);
					
					return data;
				}
				else {
					//Radiate.error("Could not create a snapshot of the selected item. " + snapshot); 
				}
			}
			
			return snapshot;
		}
		
		/**
		 * Gets the size of the target if it is a UIComponent or a DisplayObject.
		 * If it is neither or it does not have a size it returns null.
		 * Also sets the positionRectangle width and height. Temporary fix to bigger problem.
		 * */
		public static function getSize(target:Object, container:Object = null):Rectangle {
			var rectangle:Rectangle;
			
			if (target) {
				
				if (target is UIComponent) {
					rectangle = DisplayObjectUtils.getRectangleBounds(target as UIComponent, container);
					positionRectangle.width = rectangle.width;
					positionRectangle.height = rectangle.height;
					return rectangle;
				}
				else if (target is DisplayObject) {
					positionRectangle.width = rectangle.width;
					positionRectangle.height = rectangle.height;
					rectangle = DisplayObjectUtils.getRealBounds(target as DisplayObject);
					return rectangle;
				}
			}
			
			return null;
		}
		
		/**
		 * Reuse position rectangle. TODO reuse size rectangle
		 * */
		[Bindable]
		public static var positionRectangle:Rectangle = new Rectangle();
		
		/**
		 * Returns the x and y position of the target in a rectangle instance
		 * if it has x and y properties or null if it doesn't have those properties.
		 * */
		public static function getPosition(target:Object):Rectangle {
			//if (target is DisplayObject || target is IBitmapDrawable || target is IVisualElement) {
			if ("x" in target && "y" in target) {
				positionRectangle.x = target.x;
				positionRectangle.y = target.y;
				return positionRectangle;
			}
			else {
				positionRectangle.x = 0;
				positionRectangle.y = 0;
			}
			return null;
		}
		
		/**
		 * Open users site in a browser
		 * */
		public static function openUsersWebsite():void
		{
			var request:URLRequest;
			request = new URLRequest();
			request.url = getWPURL();
			navigateToURL(request, DEFAULT_NAVIGATION_WINDOW);
		}
		/**
		 * Open users login page or dashboard if already logged in in a browser
		 * */
		public static function openUsersLoginPage():void
		{
			var request:URLRequest;
			request = new URLRequest();
			request.url = getWPLoginURL();
			navigateToURL(request, DEFAULT_NAVIGATION_WINDOW);
		}
		
		/**
		 * Open users profile in a browser
		 * */
		public static function openUsersProfile():void
		{
			var request:URLRequest;
			request = new URLRequest();
			request.url = getWPProfileURL();
			navigateToURL(request, DEFAULT_NAVIGATION_WINDOW);
		}
		
		/**
		 * Locks or unlocks an item. You cannot lock the application at this time. 
		 * 
		 * @returns true if able to set lock on target. 
		 * */
		public static function lockComponent(target:Object, locked:Boolean = true):Boolean {
			var iDocument:IDocument = instance.selectedDocument;
			var componentDescription:ComponentDescription = iDocument ? iDocument.getItemDescription(target) : null;
			
			if (componentDescription && !(componentDescription.instance is Application)) {
				componentDescription.locked = locked;
				
				return true;
			}
			return false;
		}
		
		public var windowMenuDictionary:Dictionary = new Dictionary(true);
		/**
		 * Update the window menu item
		 * */
		public function updateWindowMenu(windowItem:MenuItem, nativeMenuItem:Object = null):void {
			var numberOfItems:int = windowItem.children ? windowItem.children.length : 0;
			var menu:Object;
			var menuItem:MenuItem;
			var numberOfDocuments:int;
			var iDocumentData:IDocumentData;
			var menuFound:Boolean;
			var applicationMenusCollection:ArrayCollection;
			var items:Array;
			var numberOfMenus:int;
			var isNativeMenu:Boolean;
			
			numberOfDocuments = documents.length;
			
			
			if (applicationMenu is Class(MenuItem.NativeMenuDefinition)) {
				var keys:Array = org.as3commons.lang.DictionaryUtils.getKeys(windowMenuDictionary);
				org.as3commons.lang.DictionaryUtils.deleteKeys(windowMenuDictionary, keys);
				items = applicationMenu.items;
				numberOfMenus = items ? items.length : 0;
				isNativeMenu = true;
				
				return;
				for (var j:int; j < numberOfDocuments; j++) {
					iDocumentData = documents[j];
					
					menuItem = new MenuItem.NativeMenuItemDefinition();
					menuItem.data = iDocumentData;
					menuItem.type = ClassUtils.getQualifiedClassName(iDocumentData);
					menuItem.label = iDocumentData.name;
					windowItem.checked = false;
					windowItem.addItem(menuItem);
				}
			}
			else {
				windowItem.removeAllChildren();
				isNativeMenu = false;
				applicationMenusCollection = applicationMenu.dataProvider;
				numberOfMenus = applicationMenusCollection ? applicationMenusCollection.length : 0;
				
				for (j; j < numberOfDocuments; j++) {
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
		
		/**
		 * Reverts the document template
		 * */
		public static function revertDocumentTemplate(iDocument:IDocument):void {
			iDocument.createTemplate();
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
		 * Gets a snapshot of document and returns bitmap data
		 * */
		public static function getDocumentSnapshot(iDocument:IDocument, scale:Number = 1):BitmapData {
			var bitmapData:BitmapData;
			
			if (iDocument && iDocument.instance) {
				bitmapData = DisplayObjectUtils.getUIComponentWithQuality(iDocument.instance as UIComponent) as BitmapData;
			}
			
			return bitmapData;
		}
		
		/**
		 * Gets a snapshot of target and returns bitmap data
		 * */
		public static function getSnapshot(object:Object, scale:Number = 1):BitmapData {
			var bitmapData:BitmapData;
			
			if (object is IUIComponent) {
				bitmapData = DisplayObjectUtils.getUIComponentBitmapData(object as IUIComponent);
			}
			else if (object is IGraphicElement) {
				bitmapData = DisplayObjectUtils.getGraphicElementBitmapData(object as IGraphicElement);
			}
			else if (object is IVisualElement) {
				bitmapData = DisplayObjectUtils.getVisualElementBitmapData(object as IVisualElement);
			}
			
			return bitmapData;
		}
		
		/**
		 * Shows the welcome home screen
		 * */
		public static function goToHomeScreen():void {
			if (mainView) {
				mainView.currentState = MainView.HOME_STATE;
			}
		}
		
		/**
		 * Opens and displays the documentation panel
		 * */
		public static function showDocumentationPanel(url:String):void {
			if (mainView) {
				mainView.currentState = MainView.DESIGN_STATE;
				
				if (remoteView) {
					remoteView.showDocumentationPanel();
					
					if (url) {
						instance.dispatchDocumentationChangeEvent(url);
					}
				}
			}
		}
		
		/**
		 * Opens and displays the API documentation panel
		 * */
		public static function showAPIPanel(url:String):void {
			if (mainView) {
				mainView.currentState = MainView.DESIGN_STATE;
				
				if (remoteView) {
					remoteView.showAPIPanel();
					
					if (url) {
						instance.dispatchDocumentationChangeEvent(url);
					}
				}
			}
		}
		
		/**
		 * Opens and displays the console panel
		 * */
		public static function showConsolePanel(value:String=""):void {
			if (mainView) {
				mainView.currentState = MainView.DESIGN_STATE;
				
				if (remoteView) {
					remoteView.showConsolePanel();
					
					if (value) {
						instance.dispatchConsoleValueChangeEvent(value);
					}
				}
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
			
			if (object is null) {
				if (instance.selectedDocument && instance.selectedDocument.instance) {
					return instance.selectedDocument.instance.moduleFactory;
				}
			}
			
			return null;
		}
	}
}

class SINGLEDOUBLE{}