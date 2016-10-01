package com.flexcapacitor.utils {
	import flash.utils.Dictionary;

	public class MXMLDocumentConstants {
		
		public function MXMLDocumentConstants() {
			
		}
		
		public static var fcNamespacePrefix:String 		= "fc";
		public static var fxNamespacePrefix:String 		= "fx";
		public static var htmlNamespacePrefix:String	= "html";
		public static var mxNamespacePrefix:String 		= "mx";
		public static var sparkNamespacePrefix:String 	= "s";
		public static var svgNamespacePrefix:String 	= "svg";
		public static var xlinkNamespacePrefix:String 	= "xlink";
		public static var tlfNamespacePrefix:String 	= "flow";
		
		public static var fcNamespaceURI:String 	= "library://ns.flexcapacitor.com/flex";
		public static var fxNamespaceURI:String 	= "http://ns.adobe.com/mxml/2009";
		public static var htmlNamespaceURI:String 	= "http://www.w3.org/1999/xhtml";
		public static var mxNamespaceURI:String 	= "library://ns.adobe.com/flex";
		public static var sparkNamespaceURI:String = "library://ns.adobe.com/flex/spark";
		public static var svgNamespaceURI:String 	= "http://www.w3.org/2000/svg";
		public static var xlinkNamespaceURI:String = "http://www.w3.org/1999/xlink";
		public static var tlfNamespaceURI:String 	= "http://ns.adobe.com/textLayout/2008";
		
		public static var tlfNamespace:Namespace = new Namespace(MXMLDocumentConstants.tlfNamespacePrefix, MXMLDocumentConstants.tlfNamespaceURI);
		public static var sparkNamespace:Namespace = new Namespace(MXMLDocumentConstants.sparkNamespacePrefix, MXMLDocumentConstants.sparkNamespaceURI);
		
		public static const TEXT_FLOW:String 		= "textFlow";
		public static const FILTERS:String 			= "filters";
		public static const HTML_OVERRIDE:String 	= "htmlOverride";
		public static const HTML_ATTRIBUTES:String 	= "htmlAttributes";
		public static const HTML_BEFORE:String 		= "htmlBefore";
		public static const HTML_AFTER:String 		= "htmlAfter";
		public static const WRAP_WITH_ANCHOR:String = "wrapWithAnchor";
		public static const ANCHOR_URL:String 		= "anchorURL";
		public static const ANCHOR_TARGET:String 	= "anchorTarget";
		public static const LAYER_NAME:String 		= "name";
		public static const HTML_TAG_NAME:String 	= "htmlTagName";
		public static const HTML_STYLES:String 		= "styles";
		public static const BITMAP_DATA_ID:String 	= "bitmapDataId";
		public static const LOCKED:String 			= "locked";
		public static const CONVERT_TO_IMAGE:String = "convertToImage";
		public static const CREATE_BACKGROUND_SNAPSHOT:String = "createBackgroundSnapshot";
		
		public static var TEXT_FLOW_NS:String 			= sparkNamespaceURI + "::" + TEXT_FLOW;
		public static var FILTERS_NS:String 			= sparkNamespaceURI + "::" + FILTERS;
		public static var HTML_OVERRIDE_NS:String 		= htmlNamespaceURI + "::" + HTML_OVERRIDE;
		public static var HTML_ATTRIBUTES_NS:String 	= htmlNamespaceURI + "::" + HTML_ATTRIBUTES;
		public static var HTML_BEFORE_NS:String 		= htmlNamespaceURI + "::" + HTML_BEFORE;
		public static var HTML_AFTER_NS:String 			= htmlNamespaceURI + "::" + HTML_AFTER;
		public static var HTML_STYLES_NS:String 		= htmlNamespaceURI + "::" + HTML_STYLES;
		
		public static var WRAP_WITH_ANCHOR_NS:String 	= fcNamespaceURI + "::" + WRAP_WITH_ANCHOR;
		public static var ANCHOR_URL_NS:String 			= fcNamespaceURI + "::" + ANCHOR_URL;
		public static var ANCHOR_TARGET_NS:String 		= fcNamespaceURI + "::" + ANCHOR_TARGET;
		public static var LAYER_NAME_NS:String 			= fcNamespaceURI + "::" + LAYER_NAME;
		public static var HTML_TAG_NAME_NS:String 		= fcNamespaceURI + "::" + HTML_TAG_NAME;
		public static var BITMAP_DATA_ID_NS:String 		= fcNamespaceURI + "::" + BITMAP_DATA_ID;
		public static var LOCKED_NS:String 				= fcNamespaceURI + "::" + LOCKED;
		public static var CONVERT_TO_IMAGE_NS:String 	= fcNamespaceURI + "::" + CONVERT_TO_IMAGE;
		public static var CREATE_BACKGROUND_SNAPSHOT_NS:String = fcNamespaceURI + "::" + CREATE_BACKGROUND_SNAPSHOT;
		
		/**
		 * This is the standard XML declaration at the beginning of every XML document
		 * */
		public static var xmlDeclaration:String 	= '<?xml version="1.0" encoding="utf-8"?>';
		
		private static var _defaultNamespaceDeclarations:String;
		
		/**
		 * This contains a string of the namespaces and their prefixes used in the Application MXML tag.  
		 * This value is cached after the first run and
		 * then gets the _defaultNamespaceDeclarations value. 
		 * it is set to null when namespaces object is set so it can 
		 * regrab the new values. Not sure if you needed to know all that.
		 * */
		public static function getDefaultNamespaceDeclarations():String {
			var namespaces:Dictionary;
			var namespaceName:String;
			
			if (_defaultNamespaceDeclarations==null) {
				_defaultNamespaceDeclarations = "";
				namespaces = getNamespaces();
				
				for (namespaceName in namespaces) {
					_defaultNamespaceDeclarations += "xmlns:" + namespaceName + "=\"" + namespaces[namespaceName] + "\" ";
				}
			}
			
			return _defaultNamespaceDeclarations;
		}
		
		public static function setDefaultNamespaceDeclarations(value:String):void {
			_defaultNamespaceDeclarations = value;
		}
		
		private static var _namespaces:Dictionary;
		
		/**
		 * A dictionary containing the namespace prefixes and their URI's. 
		 * */
		public static function getNamespaces():Dictionary {
			
			if (_namespaces==null) {
				_namespaces = new Dictionary();
				_namespaces[fcNamespacePrefix] 	= fcNamespaceURI;
				_namespaces[fxNamespacePrefix] 	= fxNamespaceURI;
				_namespaces[htmlNamespacePrefix] 	= htmlNamespaceURI;
				_namespaces[mxNamespacePrefix] 	= mxNamespaceURI;
				_namespaces[sparkNamespacePrefix] = sparkNamespaceURI;
				_namespaces[svgNamespacePrefix] 	= svgNamespaceURI;
				_namespaces[xlinkNamespacePrefix] = xlinkNamespaceURI;
				_namespaces[tlfNamespacePrefix] 	= tlfNamespaceURI;
			}
			
			return _namespaces;
		}
		
		public static function setNamespaces(value:Dictionary):void {
			_defaultNamespaceDeclarations = null;
			_namespaces = value;
		}
	}
}