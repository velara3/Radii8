package com.flexcapacitor.managers {
	import com.flexcapacitor.controller.Radiate;
	import com.flexcapacitor.tools.Hand;
	import com.flexcapacitor.tools.ITool;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import mx.core.FTETextField;
	import mx.utils.Platform;
	
	import spark.components.Application;
	import spark.components.ComboBox;
	import spark.components.RichEditableText;
	import spark.components.supportClasses.SkinnableTextBase;
	import spark.core.IEditableText;
	
	public class KeyboardManager {
		
		public function KeyboardManager(s:SINGLEDOUBLE) {
			
		}
		
		//----------------------------------
		//  instance
		//----------------------------------
		
		public static function get instance():KeyboardManager
		{
			if (!_instance) {
				_instance = new KeyboardManager(new SINGLEDOUBLE());
			}
			return _instance;
		}
		
		public static function getInstance():KeyboardManager {
			return instance;
		}
		
		private static var _instance:KeyboardManager;
		
		public var radiate:Radiate;
		public var spaceBarDown:Boolean;
		public var application:Application;
		public var FlexHTMLLoader:Class;
		
		public function initialize(application:Application, HTMLClass:* = null):void {
			this.application = application;
			
			application.addEventListener(KeyboardEvent.KEY_UP, application_keyUpHandler, false, 0, true);
			application.addEventListener(KeyboardEvent.KEY_DOWN, application_keyDownHandler, false, 0, true);
			
			FlexHTMLLoader = HTMLClass;
		}
		
		protected function application_keyDownHandler(event:KeyboardEvent):void {
			var keyCode:int = event.keyCode;
			var componentDescription:ComponentDescription;
			var applicable:Boolean;
			var focusedObject:Object;
			var isApplication:Boolean;
			var target:Object = event.target;
			
			if (radiate==null) {
				radiate = Radiate.getInstance();
			}
			
			// prevent key repeat
			if (spaceBarDown) {
				event.preventDefault();
				event.stopImmediatePropagation()
				return;
			}
			
			if (keyCode==Keyboard.V || 
				keyCode==Keyboard.Z || 
				keyCode==Keyboard.I || 
				keyCode==Keyboard.H ||
				keyCode==Keyboard.T ||
				keyCode==Keyboard.M ||
				keyCode==Keyboard.SPACE) {
				
				if (Platform.isAir) {
					if (!event.controlKey && !event.commandKey) {
						applicable = true;
					}
				}
				else {
					if (!event.ctrlKey) {
						if ("commandKey" in event) {
							if (!event.commandKey) {
								applicable = true;
							}
						}
						else {
							applicable = true;
						}
					}
				}
			}
			
			if (!applicable) return;
			
			focusedObject = application.focusManager.getFocus();
			
			if (focusedObject is Application || event.target is Stage) {
				isApplication = true;
			}
			
			//var t:int = getTimer();
			// not sure if this is expensive... todo performance test
			// would like to take out textfield and ftetextfield check
			if (target is RichEditableText ||
				focusedObject is IEditableText ||
				focusedObject is SkinnableTextBase ||
				focusedObject is TextField ||
				focusedObject is FTETextField ||
				focusedObject is ComboBox) {
				applicable = false;
			}
			
			if (FlexHTMLLoader!=null && focusedObject is FlexHTMLLoader) {
				applicable = false;
			}
			
			//trace("time:" + (getTimer() - t)); takes 0 ms
			
			// names are in tools-manifest.xml
			if (applicable) {
				if (keyCode==Keyboard.V) {
					componentDescription = radiate.getToolByName("Selection");
					
					if (componentDescription) {
						radiate.setTool(componentDescription.instance as ITool);
					}
				}
				else if (keyCode==Keyboard.Z) {
					componentDescription = radiate.getToolByName("Zoom");
					
					if (componentDescription) {
						radiate.setTool(componentDescription.instance as ITool);
					}
				}
				else if (keyCode==Keyboard.T) {
					componentDescription = radiate.getToolByName("Text");
					
					if (componentDescription) {
						radiate.setTool(componentDescription.instance as ITool);
					}
				}
				else if (keyCode==Keyboard.I) {
					componentDescription = radiate.getToolByName("EyeDropper");
					
					if (componentDescription) {
						radiate.setTool(componentDescription.instance as ITool);
					}
				}
				else if (keyCode==Keyboard.M) {
					componentDescription = radiate.getToolByName("Marquee");
					
					if (componentDescription) {
						radiate.setTool(componentDescription.instance as ITool);
					}
				}
				else if (keyCode==Keyboard.H || keyCode==Keyboard.SPACE) {
					componentDescription = radiate.getToolByName("Hand");
					
					if (componentDescription) {
						if (keyCode==Keyboard.SPACE) {
							spaceBarDown = true;
							//trace("setting temp hand cursor");
							radiate.saveCurrentTool();
							radiate.setTool(componentDescription.instance as ITool);
							Hand(componentDescription.instance).updateMouseCursor(true);
						}
						else {
							radiate.setTool(componentDescription.instance as ITool);
						}
					}
				}
			}
		}
		
		protected function application_keyUpHandler(event:KeyboardEvent):void {
			var keyCode:int = event.keyCode;
			var componentDescription:ComponentDescription;
			var applicable:Boolean;
			var focusedObject:Object;
			var isApplication:Boolean;
			var target:Object = event.target;
			
			// prevent repeat key events in key down
			spaceBarDown = false;
			
			if (keyCode==Keyboard.SPACE) {
				applicable = true;
			}
			
			if (!applicable) return;
			
			focusedObject = application.focusManager.getFocus();
			
			
			if (target is RichEditableText ||
				focusedObject is IEditableText ||
				focusedObject is SkinnableTextBase ||
				focusedObject is TextField ||
				focusedObject is FTETextField ||
				focusedObject is ComboBox) {
				applicable = false;
			}
			
			if (FlexHTMLLoader && focusedObject is FlexHTMLLoader) {
				applicable = false;
			}
			
			// names are in tools-manifest.xml
			if (applicable) {
				if (keyCode==Keyboard.SPACE) {
					
					radiate.restoreTool();
				}
			}
			
		}
	}
}

class SINGLEDOUBLE{}