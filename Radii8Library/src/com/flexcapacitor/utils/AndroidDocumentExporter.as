

package com.flexcapacitor.utils {
	import com.flexcapacitor.model.ExportOptions;
	import com.flexcapacitor.model.IDocument;
	import com.flexcapacitor.model.SourceData;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import mx.core.IVisualElement;
	
	import spark.components.supportClasses.GroupBase;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	
	/**
	 * Exports a document to Android markup
	 * */
	public class AndroidDocumentExporter extends DocumentTranscoder {
		
		public function AndroidDocumentExporter() {
			supportsExport = true;
			language = "Android";
			exportFromHistory = true;
		}
		
		/**
		 * Last source code
		 * */
		[Bindable]
		public var sourceCode:String;
		
		public var includePreviewCode:Boolean;
		
		public var horizontalPositions:Array = ["x","left","right","horizontalCenter"];
		public var verticalPositions:Array = ["y","top","bottom","verticalCenter"];
		public var sizesPositions:Array = ["width","height"];
		
		
		/**
		 * @inheritDoc
		 * */
		override public function export(iDocument:IDocument, componentDescription:ComponentDescription = null, options:ExportOptions = null, dispatchEvents:Boolean = false):SourceData {
			var application:Object = iDocument ? iDocument.instance : null;
			var componentTree:ComponentDescription;
			var output:String = "";
			var xml:XML;
			
			componentTree = iDocument.componentDescription;
			
			
			// find target in display list and get it's code
			//targetDescription = DisplayObjectUtils.getTargetInComponentDisplayList(target, componentTree);
			
			
			if (componentDescription) {
				
				// see the top of this document on how to generate source code
				if (exportFromHistory) {
					getAppliedPropertiesFromHistory(iDocument, componentDescription);
				}
			
				//output = getAndroidOutputString(document.componentDescription);
				
				var includePreviewCode:Boolean = true;
				
				output = getAndroidOutputString(iDocument, componentDescription, true, "", includePreviewCode);
				output = output + "\n";
					
				try {
					// don't use XML for Android output because it converts this:
					// <div ></div>
					// to this:
					// <div />
					// and that breaks the Android page
					
					// we can still try it to make sure it's valid
					xml = new XML(output); // check if valid
					
					sourceCode = output;
					// passing the raw string not the xml
					//setTextareaCode(output);
				}
				catch (error:Error) {
					// Error #1083: The prefix "s" for element "Group" is not bound.
					// <s:Group x="93" y="128">
					//	<s:Button x="66" y="17"/>
					//</s:Group>
					sourceCode = output;
					//setTextareaCode(output);
				}
			}
			
			var sourceData:SourceData = new SourceData();
			
			sourceData.source = output;
			sourceData.markup = output;
			//sourceData.css = output;
			
			return sourceData;
		}
	

		/**
		 * Gets the formatted output from a component.
		 * Needs refactoring.
		 * */
		public function getAndroidOutputString(iDocument:IDocument, component:ComponentDescription, addLineBreak:Boolean = false, tabs:String = "", includePreview:Boolean = false):String {
			var property:Object = component.properties;
			var name:String = component.name.toLowerCase();
			var componentChild:ComponentDescription;
			var styles:String = "position:absolute;";
			var contentToken:String = "[child_content]";
			var isHorizontalLayout:Boolean;
			var isVerticalLayout:Boolean;
			var childContent:String = "";
			var wrapperTag:String = "";
			var wrapperTagStyles:String = "";
			var properties:String = "";
			var output:String = "";
			var type:String = "";
			var value:*;
			var index:int;
			var numElements:int;
			var gap:int;
			
			// get layout positioning
			if (component.parent && component.parent.instance is GroupBase) {
				
				if (component.parent.instance.layout is HorizontalLayout) {
					isHorizontalLayout = true;
					index = GroupBase(component.parent.instance).getElementIndex(component.instance as IVisualElement);
					numElements = GroupBase(component.parent.instance).numElements;
					wrapperTagStyles += "display:inline;";
					gap = HorizontalLayout(component.parent.instance.layout).gap - 4;
					
					if (index<numElements-1 && numElements>1) {
						wrapperTagStyles += "padding-right:" + gap + "px";
					}
					
					wrapperTag = "div";
				}
				
				else if (component.parent.instance.layout is VerticalLayout) {
					isVerticalLayout = true;
					styles = styles.replace("absolute", "relative");
					index = GroupBase(component.parent.instance).getElementIndex(component.instance as IVisualElement);
					numElements = GroupBase(component.parent.instance).numElements;
					gap = VerticalLayout(component.parent.instance.layout).gap;
					
					if (index<numElements-1 && numElements>1) {
						wrapperTagStyles += "padding-bottom:" + gap + "px";
					}
					
					wrapperTag = "div";
				}
			}
			
			
			// loop through assigned properties
			for (var propertyName:String in property) {
				value = property[propertyName];
				
				if (value===undefined || value==null) {
					continue;
				}
				
				
				// if horizontal or vertical layout do not add position
				if (propertyName=="x" || propertyName=="left") {
					
					if (!isHorizontalLayout && !isVerticalLayout) {
						styles += "left:" +  Object(property[propertyName]).toString() + "px;";
					}
				}
				else if (propertyName=="y" || propertyName=="top") {
					
					if (!isHorizontalLayout && !isVerticalLayout) {
						styles += "top:" +  Object(property[propertyName]).toString() + "px;";
					}
				}
				else {
					properties += propertyName + "=\"" + Object(property[propertyName]).toString() + "\"";
					properties += " ";
				}
			}
			
			
			if (name) {
				
				// create code for element type
				if (name=="application") {
					name = "merge";
					output += "<merge";
					output += " xmlns:android=\"http://schemas.android.com/apk/res/android\"";
					output += " xmlns:tools=\"http://schemas.android.com/tools\"";
					output += ">";
					output += contentToken;
					output += "\n</merge>";
					
					// container div
					if (includePreview) {
						
					}
					else {
					}
				}
				
				else if (name=="group") {
					name = "RelativeLayout";
					output = tabs + "<RelativeLayout";
					output += " android:layout_width=\"" + getAndroidEquivalentSize(component.instance as IVisualElement) + "\"";
					output += " android:layout_height=\"" + getAndroidEquivalentSize(component.instance as IVisualElement, false) + "\"";
					output += ">";
					output += contentToken;
					output += "\n" + tabs + "</RelativeLayout>";
				}
				
				
				else if (name=="vgroup" || name=="hgroup") {
					output = tabs + "<LinearLayout";
					
					if (name=="hgroup") {
						output += " android:orientation=\"horizontal\"";
					}
					else {
						output += " android:orientation=\"vertical\"";
					}
					name = "LinearLayout";
					
					output += " android:layout_width=\"" + getAndroidEquivalentSize(component.instance as IVisualElement) + "\"";
					output += " android:layout_height=\"" + getAndroidEquivalentSize(component.instance as IVisualElement, false) + "\"";
					output += ">";
					output += contentToken;
					output += "\n" + tabs + "</LinearLayout>";
				}
				
				else if (name=="button") {
					/*<Button android:id="@+id/sign_in_button"
	                android:layout_width="wrap_content"
	                android:layout_height="wrap_content"
	                android:layout_marginTop="16dp"
	                android:text="@string/action_sign_in_register"
	                android:paddingLeft="32dp"
	                android:paddingRight="32dp"
	                android:layout_gravity="right" />*/
					output = tabs;
					output += "<Button";
					output += " android:layout_width=\"" + getAndroidEquivalentSize(component.instance as IVisualElement) + "\"";
					output += " android:layout_height=\"" + getAndroidEquivalentSize(component.instance as IVisualElement, false) + "\"";
					
					/*if (component.parent.name=="group") {
						output += " android:layout_marginLeft=\"" + getAndroidEquivalentPosition(component) + "\"";
						output += " android:layout_marginTop=\"" + getAndroidEquivalentPosition(component, false) + "\"";
					}
					else {
						
					}*/
					
					output += " android:text=\"" + component.instance.label + "\"";
					output += "/>";
				}
				else if (name=="checkbox") {
					name = "CheckBox";
					output = tabs;
					output += "<CheckBox";
					output += " android:layout_width=\"" + getAndroidEquivalentSize(component.instance as IVisualElement) + "\"";
					output += " android:layout_height=\"" + getAndroidEquivalentSize(component.instance as IVisualElement, false) + "\"";
					output += " android:text=\"" + component.instance.label + "\"/>";
					
					//output += getWrapperTag(wrapperTag, true);
				}
				else if (name=="textinput") {
					/*				
			            <EditText
			                android:id="@+id/password"
			                android:singleLine="true"
			                android:maxLines="1"
			                android:layout_width="match_parent"
			                android:layout_height="wrap_content"
			                android:hint="@string/prompt_password"
			                android:inputType="textPassword"
			                android:imeActionLabel="@string/action_sign_in_short"
			                android:imeActionId="@+id/login"
			                android:imeOptions="actionUnspecified" />*/
					name = "EditText";
					output = tabs;
					output += "<EditText";
					output += " android:layout_width=\"" + getAndroidEquivalentSize(component.instance as IVisualElement) + "\"";
					output += " android:layout_height=\"" + getAndroidEquivalentSize(component.instance as IVisualElement, false) + "\"";
					output += " android:singleLine=\"true\"";
					output += " android:maxLines=\"1\"";
					output += " android:fontFamily=\"" + component.instance.inheritingStyles.fontFamily + "\"";
					output += " android:hint=\""+ component.instance.prompt +"\"";
					
					if (component.instance.displayAsPassword) {
						output += " android:inputType=\"textPassword\"";
					}
					else {
						output += " android:inputType=\"text\"";
					}
					
					output += "/>";
				}
				else if (name=="label") {
					/* <TextView
		            android:id="@+id/login_status_message"
		            android:textAppearance="?android:attr/textAppearanceMedium"
		            android:fontFamily="sans-serif-light"
		            android:layout_width="wrap_content"
		            android:layout_height="wrap_content"
		            android:layout_marginBottom="16dp"
		            android:text="@string/login_progress_signing_in" />*/
					name = "TextView";
					output = tabs;
					output += "<TextView";
					output += " android:layout_width=\"" + getAndroidEquivalentSize(component.instance as IVisualElement) + "\"";
					output += " android:layout_height=\"" + getAndroidEquivalentSize(component.instance as IVisualElement, false) + "\"";
					output += " android:fontFamily=\"" + component.instance.inheritingStyles.fontFamily + "\"";
					output += " android:text=\""+ component.instance.text+"\"";
					output += "/>";
				}
				else if (name=="image") {
					name = "ImageView";
					output = tabs;
					output += "<ImageView " + properties;
					output += " android:layout_width=\"" + getAndroidEquivalentSize(component.instance as IVisualElement) + "\"";
					output += " android:layout_height=\"" + getAndroidEquivalentSize(component.instance as IVisualElement, false) + "\"";
					output += " android:src=\"@drawable/" + component.instance.source + "\"";
					output += "/>";
				}
				
				else {
					output = tabs;
					output += "<!--<" + name.toLowerCase()  + " " + properties;
					output += properties ? " " : "";
					output += "style=\"" + styles + "\"/>-->";
					//output += getWrapperTag(wrapperTag, true);
				}
				
				
				// add children
				if (component.children && component.children.length>0) {
					//output += ">\n";
					
					for (var i:int;i<component.children.length;i++) {
						componentChild = component.children[i];
						
						if (exportFromHistory) {
							getAppliedPropertiesFromHistory(iDocument, componentChild);
						}
						
						if (i>0) {
							childContent += "\n";
						}
						
						childContent += getAndroidOutputString(iDocument, componentChild, false, tabs + "\t");
					}
					
					output = output.replace(contentToken, "\n" + childContent);

				}
				else {
					output = output.replace(contentToken, "\n");
				}
			}
			else {
				output = "";
			}
			
			return output;
		}
		
		/**
		 * Get Android equivalent size. 
		 * Android has fill_parent, match_parent and wrap_content.
		 * It also has numeric value, like "55dp".
		 * */
		public function getAndroidEquivalentSize(element:IVisualElement, width:Boolean = true):String {
			var isPercent:Boolean;
			var output:String;
			
			// get width
			if (width) {
				isPercent = Boolean(element.percentWidth);
				
				if (isPercent) {
					if (element.percentWidth==100) {
						output = "fill_parent";
					}
					else {
						output = String(element.width) + "dp"; // absolute value
					}
				}
				else {
					if ("explicitWidth" in element && element.width==Object(element).explicitWidth) {
						output = String(element.width) + "dp";
					}
					else {
						output = "wrap_content";
					}
				}
				
				return output;
			}
			
			// get height
			isPercent = Boolean(element.percentHeight);
			
			
			if (isPercent) {
				if (element.percentHeight==100) {
					output = "fill_parent";
				}
				else {
					output = String(element.height) + "dp"; // absolute value
				}
			}
			else {
				if ("explicitHeight" in element && element.height==Object(element).percentHeight) {
					output = String(element.height) + "dp";
				}
				else {
					output = "wrap_content";
				}
			}
			
			return output;
		}
		
		/**
		 * Get Android equivalent position
		 * */
		public function getAndroidEquivalentPosition(componentDescription:ComponentDescription, x:Boolean = true):String {
			var element:Object = componentDescription.instance;
			var isPercent:Boolean;
			var output:String;
			
			// get width
			if (x) {
				isPercent = Boolean(element.percentWidth);
				
				
				if (isPercent) {
					if (element.percentWidth==100) {
						output = "fill_parent";
					}
					else {
						output = String(element.width) + "dp"; // absolute value
					}
				}
				else {
					if ("explicitWidth" in element && element.width==Object(element).explicitWidth) {
						output = String(element.width) + "dp";
					}
					else {
						output = "wrap_content";
					}
				}
				
				return output;
			}
			
			// get height
			isPercent = Boolean(element.percentHeight);
			
			
			if (isPercent) {
				if (element.percentHeight==100) {
					output = "fill_parent";
				}
				else {
					output = String(element.height) + "dp"; // absolute value
				}
			}
			else {
				if ("explicitHeight" in element && element.height==Object(element).percentHeight) {
					output = String(element.height) + "dp";
				}
				else {
					output = "wrap_content";
				}
			}
			
			return output;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function exportXML(document:IDocument, reference:Boolean = false):XML {
			return null;
		}
		
		/**
		 * @inheritDoc
		 * */
		public function exportJSON(document:IDocument, reference:Boolean = false):JSON {
			return null;
		}
		
	}
}