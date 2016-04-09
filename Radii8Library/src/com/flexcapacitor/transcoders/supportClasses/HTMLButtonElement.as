package com.flexcapacitor.transcoders.supportClasses
{
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import mx.core.IVisualElement;
	
	public class HTMLButtonElement extends HTMLElement {
		
		public function HTMLButtonElement() {
			super();
			elementName = "button";
			defaultElementName = "button";
		}
		
		override public function updateDescription(componentDescription:ComponentDescription):void {
			super.updateDescription(componentDescription);
			
			if (componentDescription.htmlTagName!=elementName) {
				elementName = componentDescription.htmlTagName;
			}
			
			stylesModel.updateDescription(componentDescription);
			// attributesModel.updateDescription(componentDescription);
		}
		
		override public function toString():String {
			/*
			htmlName = "button";
			layoutOutput = getWrapperTag(wrapperTag, false, wrapperTagStyles);
			layoutOutput += "<input " + properties;
			layoutOutput += " type=\"" + htmlName.toLowerCase() + "\"" ;
			layoutOutput += properties ? " " + properties : "";
			
			setSizeString(componentInstance as IVisualElement);
			
			layoutOutput += " value=\"" + componentInstance.label + "\"";
			//layoutOutput += " class=\"buttonSkin\"";
			
			layoutOutput += setStyles(componentInstance, styleValue);
			
			layoutOutput += getWrapperTag(wrapperTag, true);*/
			
			return "";
		}
		
		
		
	}
}