
package com.flexcapacitor.transcoders.supportClasses {
	import com.flexcapacitor.utils.DisplayObjectUtils;
	import com.flexcapacitor.utils.FontUtils;
	import com.flexcapacitor.utils.StyleUtils;
	import com.flexcapacitor.utils.supportClasses.ComponentDescription;
	
	import mx.styles.IStyleClient;
	
	/**
	 * Styles for HTML elements
	 * */
	public class HTMLStyles {
		
		/**
		 * Constructor
		 * */
		public function HTMLStyles() {
			
		}
		
		/**
		 * Positions
		 * static|absolute|fixed|relative|initial|inherit;
		 * */
		public static const ABSOLUTE:String = "absolute";
		public static const FIXED:String 	= "fixed";
		public static const INHERIT:String 	= "inherit";
		public static const INITIAL:String 	= "initial";
		public static const POSITION:String = "position";
		public static const RELATIVE:String = "relative";
		
		/**
		 * Block styles
		 * */
		public static const TABLE:String = "table";
		public static const BLOCK:String = "block";
		public static const INLINE:String = "inline";
		public static const INLINE_BLOCK:String = "inline-block";
		
		/**
		 * Alignment styles
		 * */
		public static const VERTICAL_ALIGN_TOP:String = "top";
		public static const VERTICAL_ALIGN_MIDDLE:String = "middle";
		public static const VERTICAL_ALIGN_BOTTOM:String = "bottom";
		public static const HORIZONTAL_ALIGN_LEFT:String = "left";
		public static const HORIZONTAL_ALIGN_CENTER:String = "center";
		public static const HORIZONTAL_ALIGN_RIGHT:String = "right";
		
		/**
		 * Margins
		 * */
		public static const MARGIN_CENTER:String = "auto auto";
		public static const MARGIN_HORIZONTAL_CENTER:String = "0 auto";
		public static const MARGIN_VERTICAL_CENTER:String = "auto 0";
		
		public static const MARGIN_LEFT:String = "margin-left";
		public static const MARGIN_RIGHT:String = "margin-right";
		public static const MARGIN_TOP:String = "margin-top";
		public static const MARGIN_BOTTOM:String = "margin-bottom";
		
		/**
		 * Paddings
		 * */
		public static const PADDING_LEFT:String = "padding-left";
		public static const PADDING_RIGHT:String = "padding-right";
		public static const PADDING_TOP:String = "padding-top";
		public static const PADDING_BOTTOM:String = "padding-bottom";
		
		/**
		 * Transforms
		 * */
		public static const TRANSLATE_CENTER:String = "translate(-50%, -50%)";
		public static const TRANSLATE_HORIZONTAL_CENTER:String = "translateX(-50%)";
		public static const TRANSLATE_VERTICAL_CENTER:String = "translateY(-50%)";
		
		public var position:String;
		public var display:String;
		public var margin:String;
		public var padding:String;
		
		public var paddingRight:String;
		public var paddingLeft:String;
		public var paddingTop:String;
		public var paddingBottom:String;
		
		public var marginRight:String;
		public var marginLeft:String;
		public var marginTop:String;
		public var marginBottom:String;
		
		public var left:String;
		public var top:String;
		public var right:String;
		public var bottom:String;
		
		public var transform:String;
		
		public var verticalAlign:String;
		public var horizontalAlign:String;
		
		public var width:String;
		public var height:String;
		
		public var maxWidth:String;
		public var maxHeight:String;
		
		public var minWidth:String;
		public var minHeight:String;
		
		public var fontFamily:String;
		public var fontColor:String;
		public var fontWeight:String;
		public var fontSize:String;
		public var fontTypographicCase:String;
		
		/**
		 * Allow for custom user styles
		 * */
		public var user:String;
		
		public function updateDescription(componentDescription:ComponentDescription):void {
			var componentInstance:Object;
			
			componentInstance = componentDescription.instance;
			
			if (componentInstance==null) {
				return;
			}
			
			fontFamily 			= getFontFamily(componentInstance);
			fontWeight 			= getFontWeight(componentInstance);
			fontSize 			= getFontSize(componentInstance);
			fontColor 			= getFontColor(componentInstance);
			fontTypographicCase	= getFontTypographicCase(componentInstance);
			
			if (user!=null) {
				
			}
			/*
			styleValue = ObjectUtils.user;
			stylesOut = stylesHookFunction!=null ? stylesHookFunction(styleValue, componentDescription, document) : styleValue;
			*/
		}
		
		/**
		 * Gets the typographic case
		 * */
		public function getFontTypographicCase(componentInstance:Object, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			var styleValue:String;
			if (styleClient==null) return styleValue;
			
			if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "typographicCase")) {
				styleValue = componentInstance.getStyle("typographicCase");
			}
			
			return styleValue;
		}
		
		/**
		 * Gets the font color if defined inline
		 * */
		public function getFontColor(componentInstance:Object, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			var styleValue:String;
			if (styleClient==null) return styleValue;
			
			if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "color")) {
				styleValue = DisplayObjectUtils.getColorInHex(styleClient.getStyle("color"), true);
			}
			
			return styleValue;
		}
		
		/**
		 * Gets the font family if defined inline
		 * */
		public function getFontFamily(componentInstance:Object, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			var styleValue:String;
			if (styleClient==null) return styleValue;
			
			if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "fontFamily")) {
				styleValue = FontUtils.getSanitizedFontName(componentInstance);
			}
			
			return styleValue;
		}
		
		/**
		 * Gets the font weight if defined inline
		 * */
		public function getFontWeight(componentInstance:Object, getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			var styleValue:String;
			if (styleClient==null) return styleValue;
			
			if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "fontWeight")) {
				styleValue = styleClient.getStyle("fontWeight");
			}
			
			return styleValue;
		}
		
		/**
		 * Gets the font size if defined inline
		 * You can pass in format but it is still returning font size in pixels.
		 * A better solution is to check for format and return converted values.
		 * */
		public function getFontSize(componentInstance:Object, format:String = "px", getInherited:Boolean = false):String {
			var styleClient:IStyleClient = componentInstance as IStyleClient;
			var styleValue:String;
			if (styleClient==null) return styleValue;
			
			if (getInherited || StyleUtils.isStyleDeclaredInline(styleClient, "fontSize")) {
				styleValue += styleClient.getStyle("fontSize") + format;
			}
			
			return styleValue;
		}
	}
}