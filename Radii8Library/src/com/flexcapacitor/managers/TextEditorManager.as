package com.flexcapacitor.managers
{
	import com.flexcapacitor.controller.Console;
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.controls.RichTextEditorBar;
	import com.flexcapacitor.controls.RichTextEditorBarCallout;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.tools.Selection;
	import com.flexcapacitor.tools.Text;
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayList;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.managers.ISystemManager;
	import mx.managers.SystemManagerGlobals;
	import mx.styles.IStyleClient;
	
	import spark.components.ContentBackgroundAppearance;
	import spark.components.Label;
	import spark.components.RichEditableText;
	import spark.components.TextSelectionHighlighting;
	import spark.components.supportClasses.TextBase;
	import spark.events.PopUpEvent;
	import spark.events.TextOperationEvent;
	import spark.layouts.BasicLayout;
	
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.ITextImporter;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.IConfiguration;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.InlineGraphicElementStatus;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.StatusChangeEvent;

	public class TextEditorManager extends Console {
		
		public function TextEditorManager() {
			
		}
		
		public static var debug:Boolean;

		/**
		 * Component that is in edit mode. Typically a Label. 
		 * */
		public static var originalTextField:Object;
		public static var editableRichTextField:RichEditableText = new RichEditableText();
		public static var editableRichTextFieldSprite:UIComponent = new UIComponent();
		public static var editableRichTextEditorBarCallout:RichTextEditorBarCallout;
		public static var editorComponent:RichTextEditorBar;
		public static var usingCallout:Boolean;
		public static var editors:Dictionary = new Dictionary(true);
		
		/**
		 * Get the current document.
		 * */
		public static function get selectedDocument():IDocument {
			return Radiate.selectedDocument;
		}
		
		/**
		 * Handles double click on text to show text editor. 
		 * To support more components add the elements in the addElement method
		 * */
		public static function showTextEditorHandler(event:MouseEvent):void {
			var currentTarget:Object = event.target;
			var radiate:Radiate = Radiate.instance;
			var selectText:Boolean = true;
			var setFocus:Boolean = true;
			var showTextEditorInCallOut:Boolean;
			var componentDescription:ComponentDescription;
			
			componentDescription = selectedDocument.getItemDescription(currentTarget);
			showTextEditorInCallOut = Text.showTextEditorInCallOut;
			
			// todo add and remove listeners when locked and unlocked
			if (!componentDescription.locked) {
				showTextEditor(currentTarget, selectText, setFocus, showTextEditorInCallOut);
			}
		}
		
		/**
		 * Handles double click on text to show text editor. 
		 * To support more components add the elements in the addElement method
		 * */
		public static function showTextEditor(textField:Object, selectText:Boolean = false, setFocus:Boolean = true, useCallOut:Boolean = true):void {
			var textTarget:TextBase;
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
			var focusAlpha:Number;
			var rectangleBounds:Rectangle;
			var position:Point;
			var distancePoint:Point;
			var scale:Number;
			var editorBar:RichTextEditorBar;
			var offsetCalloutY:int;
			var showSpriteFillArea:Boolean = false;
			var basicFonts:Boolean = false;
			var toolLayer:IVisualElementContainer;
			
			const MIN_WIDTH:int = 22;
			
			if (debug) {
				log("Show Text Editor");
			}
			
			if (!(Radiate.selectedTool is Selection) && !(Radiate.selectedTool is com.flexcapacitor.tools.Text)) {
				return;
			}
			
			// if editor is still open we need to close it
			if (isEditFieldVisible()) {
				if (debug) {
					log("Previous editor open. Committing values.");
				}
				commitTextEditorValues();
			}
			
			focusAlpha = 0;
			offsetCalloutY = -5;
			
			textTarget = textField as TextBase;
			
			usingCallout = useCallOut;
			
			// get reference to current source label or richtext 
			originalTextField = textTarget;
			
			createTextComponent(focusAlpha);
			
			// get position of label or richtext
			// and get size and position for temporary rich text field
			if (originalTextField) {
				iDocument = selectedDocument;
				editorComponent = DocumentManager.editorComponent;
				toolLayer = DocumentManager.toolLayer;
				targetComponentDescription = DisplayObjectUtils.getTargetInComponentDisplayList(textTarget, iDocument.componentDescription);
				parentComponentDescription = targetComponentDescription.parent;
				
				isRichEditor = "textFlow" in originalTextField;
				currentEditor = editableRichTextField;
				
				propertyNames = ["x", "y", "minWidth"];
				valuesObject = {};
				
				if (originalTextField.owner.layout is BasicLayout) {
					isBasicLayout = true;
					rectangle = DisplayObjectUtils.getRectangleBounds(originalTextField, originalTextField.owner);
				}
				else {
					rectangle = DisplayObjectUtils.getRectangleBounds(textTarget, iDocument.instance);
				}
				
				//rectangleBounds = DisplayObjectUtils.getBounds(currentEditableComponent, DocumentManager.toolLayer);
				
				position = DisplayObjectUtils.getDisplayObjectPosition(originalTextField as DisplayObject, null, true);
				distancePoint = DisplayObjectUtils.getDistanceBetweenDisplayObjects(originalTextField, toolLayer);
				
				valuesObject.x = rectangle.x;
				valuesObject.y = rectangle.y;
				valuesObject.minWidth = MIN_WIDTH;
				
				if (!isNaN(textTarget.explicitWidth)) {
					propertyNames.push("width");
					valuesObject.width = rectangle.width;
				}
				else if (!isNaN(textTarget.percentWidth)) {
					// if basic layout we can get percent width
					if (isBasicLayout) {
						propertyNames.push("percentWidth");
						valuesObject.percentWidth = textTarget.percentWidth;
					}
					else {
						propertyNames.push("width");
						valuesObject.width = rectangle.width;
					}
				}
				
				hideOriginalTextField();
				
				if (useCallOut) {
					createCallOut();
					
					editorBar = editableRichTextEditorBarCallout.editorBar;
					
					editableRichTextEditorBarCallout.hideOnMouseDownOutside = true;
					editableRichTextEditorBarCallout.showEditorOnFocusIn = true;
				}
				else {
					editorBar = DocumentManager.editorComponent;
				}
				
				editorBar.focusOnTextAfterFontChange = false;
				editorBar.focusOnTextAfterFontSizeChange = false;
				
				// set fonts
				if (basicFonts && editorBar.fontDataProvider) {
					editorBar.fontDataProvider = null;
				}
				else if (!basicFonts && editorBar.fontDataProvider==null) {
					editorBar.fontDataProvider = new ArrayList(Radiate.fontsArray);
				}
				
				if (isRichEditor) {
					
					// TODO: test using TextFlowUtil
					//TextFlowUtil.importFromString();
					//TextFlowUtil.export();
					
					// TODO: test performance of below if deep copy is faster and works the same 
					textFlowString = TextConverter.export(originalTextField.textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
					textFlow = TextConverter.importToFlow(textFlowString, TextConverter.TEXT_LAYOUT_FORMAT);
					editableRichTextField.styleName = originalTextField;
					editableRichTextField.validateNow();
				}
				else {
					valuesObject.text = originalTextField.text;
					
					editableRichTextField.styleName = originalTextField;
					editableRichTextField.validateNow();
				}
				
				
				if (isRichEditor) {
					valuesObject.textFlow = textFlow;
					propertyNames.push("textFlow");
				}
				else {
					valuesObject.text = originalTextField.text;
					propertyNames.push("text");
				}
				
				// add temporary rich text field but prevent from adding to document history
				HistoryManager.doNotAddEventsToHistory = true;
				if (isBasicLayout) {
					if (isRichEditor) {
						ComponentManager.addElement(editableRichTextField, parentComponentDescription.instance, propertyNames, null, null, valuesObject);
					}
					else {
						ComponentManager.addElement(editableRichTextField, parentComponentDescription.instance, propertyNames, null, null, valuesObject);
					}
				}
				else {
					if (isRichEditor) {
						ComponentManager.addElement(editableRichTextField, iDocument.instance, propertyNames, null, null, valuesObject);
					}
					else {
						ComponentManager.addElement(editableRichTextField, iDocument.instance, propertyNames, null, null, valuesObject);
					}
				}
				HistoryManager.doNotAddEventsToHistory = false;
				
				topSystemManager = SystemManagerGlobals.topLevelSystemManagers[0];
				topSystemManager.stage.stageFocusRect = false;
				
				if (isRichEditor) {
					scale = ScaleManager.getScale();
					
					editableRichTextFieldSprite.width = rectangle.width;
					editableRichTextFieldSprite.height = rectangle.height;
					
					if (editableRichTextFieldSprite.owner!=toolLayer) {
						toolLayer.addElement(editableRichTextFieldSprite);
					}
					
					if (showSpriteFillArea) {
						editableRichTextFieldSprite.graphics.clear();
						editableRichTextFieldSprite.graphics.beginFill(Math.random()*255555,.4);
						editableRichTextFieldSprite.graphics.drawRect(0, 0, rectangle.width, rectangle.height);
						editableRichTextFieldSprite.graphics.endFill();
					}
					
					distancePoint = DisplayObjectUtils.getDisplayObjectPosition(originalTextField as DisplayObject, toolLayer, true);
					
					editableRichTextFieldSprite.x = distancePoint.x;
					editableRichTextFieldSprite.y = distancePoint.y + offsetCalloutY;
					editableRichTextFieldSprite.validateNow();
					
					if (useCallOut) {
						editableRichTextEditorBarCallout.richEditableText = editableRichTextField;
						if (editableRichTextEditorBarCallout.isOpen) {
							editableRichTextEditorBarCallout.open(editableRichTextFieldSprite);
							editableRichTextEditorBarCallout.updatePopUpPosition();							
						}
						else {
							editableRichTextEditorBarCallout.open(editableRichTextFieldSprite);
						}
						editableRichTextEditorBarCallout.addEventListener(PopUpEvent.CLOSE, richTextCallOut_closeHandler, false, 0, true);
					}
					else {
						editors[editableRichTextField] = editorBar;
						editorBar.attachRichEditableText(editableRichTextField);
						showEditor();
						
						editableRichTextField.addEventListener(FocusEvent.FOCUS_OUT, handleEditorEvents, false, 0, true);
						//editableRichTextField.addEventListener(FlexEvent.ENTER, handleEditorEvents, false, 0, true);
						//editableRichTextField.addEventListener(FlexEvent.VALUE_COMMIT, handleEditorEvents, false, 0, true);
						//editableRichTextField.addEventListener(MouseEvent.CLICK, handleEditorEvents, false, 0, true);
					}
					
					editorBar.addEventListener(RichTextEditorBar.CANCEL, richTextEditor_cancelHandler, false, 0, true);
					editorBar.addEventListener(RichTextEditorBar.APPLY, richTextEditor_applyHandler, false, 0, true);
					
					if (setFocus) {
						DeferManager.callAfter(1, editableRichTextField.setFocus);
					}
					
					if (selectText) {
						DeferManager.callAfter(1, editableRichTextField.selectAll);
					}
					
				}
				else {
					editableRichTextField.selectAll();
					editableRichTextField.setFocus();
					
					if (setFocus) {
						DeferManager.callAfter(1, editableRichTextField.setFocus);
					}
					
					if (selectText) {
						DeferManager.callAfter(1, editableRichTextField.selectAll);
					}
					
					editableRichTextField.addEventListener(FocusEvent.FOCUS_OUT, handleEditorEvents, false, 0, true);
					editableRichTextField.addEventListener(FlexEvent.ENTER, handleEditorEvents, false, 0, true);
					editableRichTextField.addEventListener(FlexEvent.VALUE_COMMIT, handleEditorEvents, false, 0, true);
					editableRichTextField.addEventListener(MouseEvent.CLICK, handleEditorEvents, false, 0, true);
				}
				
				if (!(Radiate.selectedTool is com.flexcapacitor.tools.Text)) {
					ToolManager.disableTool();
				}
				
				//ToolManager.disableTool();
			}
			
		}
		
		/**
		 * Create the call out that holds our editor component
		 **/
		public static function createCallOut():void {
			
			if (editableRichTextEditorBarCallout==null) {
				editableRichTextEditorBarCallout = new RichTextEditorBarCallout();
				editableRichTextEditorBarCallout.initialize();
				editableRichTextEditorBarCallout.createDeferredContent();
				
				editableRichTextEditorBarCallout.horizontalPosition = "middle";
				editableRichTextEditorBarCallout.verticalPosition = "before";
				editableRichTextEditorBarCallout.setStyle("contentBackgroundAppearance", ContentBackgroundAppearance.NONE);
				IStyleClient(editableRichTextEditorBarCallout).setStyle("modalTransparencyDuration", 0);
			}
		}
		
		/**
		 * Creates the text field that we use for editing text
		 **/
		public static function createTextComponent(focusAlpha:Number = 0):void {
			
			if (editableRichTextField==null) {
				editableRichTextField = new RichEditableText();
				editableRichTextField.focusRect = null;
				//editableRichTextField.imeMode
			}
			
			editableRichTextField.selectionHighlighting = TextSelectionHighlighting.WHEN_ACTIVE;
			
			editableRichTextField.setStyle("focusAlpha", focusAlpha);
		}
		
		public static function richTextCallOut_closeHandler(event:PopUpEvent):void {
			commitTextEditorValues();
		}
		
		public static function richTextEditor_cancelHandler(event:Event):void {
			event.preventDefault();
			
			if (usingCallout) {
				editableRichTextEditorBarCallout.cancel();
			}
			else {
				commitTextEditorValues(false);
			}
		}
		
		public static function richTextEditor_applyHandler(event:Event):void {
			if (usingCallout) {
				editableRichTextEditorBarCallout.close();
			}
			else {
				commitTextEditorValues();
			}
		}
		
		/**
		 * Set the value that the user typed in
		 * */
		public static function handleEditorEvents(event:Event):void {
			var newValue:String;
			var oldValue:String;
			var doSomething:Boolean;
			var currentTarget:Object;
			var editableField:Object;
			var isRichEditor:Boolean;
			var textFlow:TextFlow;
			var target:Object;
			var relatedObject:Object;
			var editor:RichTextEditorBar;
			var eventType:String = event.type;
			currentTarget = event.currentTarget;
			target = event.target;
			relatedObject = "relatedObject" in event ? Object(event).relatedObject : null;
			editor = editors[editableRichTextField];
			
			if (originalTextField is Label) {
				//editor = editableLabelTextField;
				//newValue = editableLabelTextField.text;
				editableField = editableRichTextField;
				//newValue = editableRichTextField.text;
				//oldValue = currentEditableComponent.text;
				isRichEditor = false;
			}
			else {
				editableField = editableRichTextField; //editableRichTextEditorBarCallout;
				isRichEditor = true;
			}
			
			
			// CHECK if we should do something - user clicked on the rich editable text field - ignore
			if (event is MouseEvent && currentTarget==editableField) {
				doSomething = false;
				//trace("Click event");
			}
			else if (event is FocusEvent && FocusEvent(event).relatedObject==originalTextField) {
				doSomething = false;
				//trace("related object is still edit component");
			}
			else if (event is FocusEvent && isRichEditor) {
				
				
				if (usingCallout) {
					// committing on close event from CallOut
					
					// if rich editable text loses focus and the focus is not the edit bar
					if (event.target==currentTarget && currentTarget==editableField) {
						doSomething = false;
						//trace("focus out on rich editor. ignore");
					}
					else {
						doSomething = false;
						//trace("focus out not rich editor");
					}
				}
				else {
					// not using call out
					
					// target is editable field
					// user switched applications and component lost focus
					// commit because we can't leave it in that state unless we also add activate listeners (todo)
					if (currentTarget==target && editableRichTextField==target && relatedObject==null) {
						doSomething = true;
					}
					// if rich editable text loses focus and the focus is not the edit bar
					else if (target==currentTarget && 
						currentTarget==editableField && 
						relatedObject && editor) {
						
						// if editor contains the object do nothing
						// for example, user clicked on the editor bold button 
						if (editor.containsObject(relatedObject as DisplayObject)) {
							doSomething = false;
						}
						// if related object is a pop up and the editor owns the pop up
						// for example user clicked on the color picker and that opens a pop up 
						else if ("owner" in relatedObject && 
								editor.containsObject(relatedObject.owner as DisplayObject)) {
							doSomething = false;
						}
						// if nothing related assume lost focus 
						else {
							doSomething = true;
						}
					}
					else {
						doSomething = false;
						//trace("focus out not rich editor");
					}
				}
				
			}
			else if (event is FlexEvent && event.type=="valueCommit") {
				doSomething = false; // we set richtext.textFlow to a value - happens on addElement
				//trace('value commit');
			}
			else {
				doSomething = true;
				//trace('other event: ' + event.type);
			}
			
			
			if (doSomething) {
				commitTextEditorValues();
			}
			
			event.preventDefault();
			event.stopImmediatePropagation();
			
			//editableRichTextEditorBarCallout.editorBar.scaleX = 1;
			//editableRichTextEditorBarCallout.editorBar.scaleY = 1;
		}
		
		/**
		 * Set the value that the user typed in
		 * */
		public static function commitTextEditorValues(setValues:Boolean = true):void {
			var newValue:String;
			var oldValue:String;
			var currentTarget:Object;
			var editor:Object;
			var isRichEditor:Boolean;
			var textFlow:TextFlow;
			var importer:ITextImporter;
			var config:IConfiguration;
			var radiate:Radiate = Radiate.instance;
			
			if (debug) {
				log("Committing Text Editor Values");
			}
			
			if (originalTextField==null) return;
			
			editor = editableRichTextField;
			
			if (originalTextField is Label) {
				newValue = editableRichTextField.text;
				oldValue = originalTextField.text;
				editor = editableRichTextField;
				newValue = editableRichTextField.text;
				oldValue = originalTextField.text;
				isRichEditor = false;
			}
			else {
				editor = editableRichTextField;
				isRichEditor = true;
			}
			
			if (isRichEditor) {
				// todo check TextFlowUtils 
				newValue = TextConverter.export(editor.textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
				oldValue = TextConverter.export(Object(originalTextField).textFlow, TextConverter.TEXT_LAYOUT_FORMAT, ConversionType.STRING_TYPE) as String;
				
				importer = TextConverter.getImporter(TextConverter.TEXT_FIELD_HTML_FORMAT);
				config = importer.configuration;
			}
			
			//if (currentEditableComponent && newValue!=oldValue) {
			if (originalTextField && newValue!=oldValue) {
				
				if (isRichEditor) {
					if (originalTextField.textFlow) {
						originalTextField.textFlow.removeEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, inlineGraphicStatusChange);
					}
					
					if (setValues) {
						textFlow = TextConverter.importToFlow(newValue, TextConverter.TEXT_LAYOUT_FORMAT);
						textFlow.addEventListener(StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE, inlineGraphicStatusChange, false, 0, true);
						ComponentManager.setProperty(originalTextField, "textFlow", textFlow);
					}
						
				}
				else {
					if (setValues) {
						ComponentManager.setProperty(originalTextField, "text", newValue);
					}
				}
				
			}
			
			showOriginalTextField();
			
			if (isRichEditor) {
				editor = DocumentManager.editorComponent;
				
				if (!(Radiate.selectedTool is com.flexcapacitor.tools.Text)) {
					Text.hideEditor();
				}
				
				editableRichTextEditorBarCallout.removeEventListener(PopUpEvent.CLOSE, commitTextEditorValues);
			}
			else {
				editableRichTextField.removeEventListener(FocusEvent.FOCUS_OUT, commitTextEditorValues);
				editableRichTextField.removeEventListener(FlexEvent.ENTER, commitTextEditorValues);
				editableRichTextField.removeEventListener(FlexEvent.VALUE_COMMIT, commitTextEditorValues);
				editableRichTextField.removeEventListener(MouseEvent.CLICK, commitTextEditorValues);
			}
			
			
			if (usingCallout) {
				if (editableRichTextField.owner) {
					editableRichTextEditorBarCallout.richEditableText = null;
				}
				else if (isRichEditor) {
					editableRichTextEditorBarCallout.richEditableText = null;
				}
			}
			else {
				editors[editableRichTextField] = null;
				delete editors[editableRichTextField];
			}
			
			// remove editor from stage
			HistoryManager.doNotAddEventsToHistory = true;
			if (isRichEditor) {
				//removeElement(editableRichTextEditorBarCallout);
				ComponentManager.removeElement(editableRichTextField);
			}
			else if (editableRichTextField.parent) {
				ComponentManager.removeElement(editableRichTextField);
			}
			HistoryManager.doNotAddEventsToHistory = false;
			
			
			ToolManager.enableTool();
			
			Radiate.setTarget(originalTextField);
			
			originalTextField = null;
			
			if (editableRichTextFieldSprite.owner==DocumentManager.toolLayer) {
				DocumentManager.toolLayer.removeElement(editableRichTextFieldSprite);
			}
			
		}
		
		/**
		 * Show the editor component 
		 **/
		public static function showEditor():void {
			if (editorComponent) {
				editorComponent.visible = true;
			}
		}
		
		/**
		 * Hides the editor component
		 **/
		public static function hideEditor():void {
			if (editorComponent) {
				editorComponent.visible = false;
			}
		}
		
		/**
		 * Shows the original text field that we were editing the content of
		 **/
		public static function showOriginalTextField():void
		{
			originalTextField.visible = true;
		}
		
		/**
		 * Hiding the original text field that we plan to edit the content of
		 **/
		public static function hideOriginalTextField():void
		{
			originalTextField.visible = false;
		}
		
		/**
		 * Handles when an remote image is loaded 
		 * We must invalidate RichText components so that images are visible
		 * See RichText class docs 
		 * */
		protected static function inlineGraphicStatusChange(event:StatusChangeEvent):void {
			var textFlow:TextFlow;
			var status:String = event.status;
			var graphic:DisplayObject = InlineGraphicElement(event.element).graphic;
			var component:UIComponent;
			
			// in a test READY status is not being received so checking for size pending
			if (status==InlineGraphicElementStatus.READY || status==InlineGraphicElementStatus.SIZE_PENDING) {
				component = DisplayObjectUtils.getTypeFromDisplayObject(graphic, UIComponent);
				
				if (component) {
					component.invalidateSize();
				}
			}
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
		 * Returns true if the text field we use to edit text with is visible on the stage
		 **/
		public static function isEditFieldVisible():Boolean {
			
			if (editableRichTextField && editableRichTextField.visible && editableRichTextField.stage) {
				return true;
			}
			return false;
		}
	}
}