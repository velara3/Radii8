

package com.flexcapacitor.model {
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	
	/**
	 * Image data information
	 * */
	public class ImageData extends AttachmentData {
		
		/**
		 * Constructor
		 * */
		public function ImageData() {
			
			nodeName = "image";
		}
		
		/**
		 * 
		 * */
		public var originalURL:String;
		
		/**
		 * 
		 * */
		public var largeURL:String;
		
		/**
		 * 
		 * */
		public var mediumURL:String;
		
		/**
		 * 
		 * */
		public var smallURL:String;
		
		/**
		 * 
		 * */
		public var thumbnailURL:String;
		
		/**
		 * 
		 * */
		public var caption:String;
		
		/**
		 * Full URL to image
		 * */
		public var url:String;
		
		/**
		 * Width 
		 * */
		public var width:int;
		
		/**
		 * Height 
		 * */
		public var height:int;
		
		/**
		 * Bitmap data
		 * */
		public var bitmapData:BitmapData;
		
		/**
		 * Byte Array
		 * */
		public var byteArray:ByteArray;
		
		/**
		 * 
		 * */
		override public function unmarshall(data:Object):void {
			
			if (data is ImageData) { // only added minimal support for image data atm
				var image:ImageData = ImageData(data);
				description = image.description;
				id 			= image.id;
				mimeType	= image.mimeType;
				parentId	= image.parentId;
				name 		= image.name;
				url 		= image.url;
				width 		= data.width;
				height 		= data.height;
			}
			else if (data is Object) {
				
				caption 	= data.caption;
				description = data.description;
				id 			= data.id;
				mimeType	= data.mime_type;
				parentId	= data.parent;
				name 		= data.title;
				url 		= data.url;
				
				if (data.images) {
					mediumURL	= data.images.medium.url;
					if (data.images["small-feature"]) {
						smallURL	= data.images["small-feature"].url;
					}
					if (data.images["post-thumbnail"]) {
						//postThumbnailURL	= data.images.["post-thumbnail"].url;
					}
					thumbnailURL	= data.images.thumbnail.url;
					width 			= data.images.full.width;
					height 			= data.images.full.height;
				}
			}
		}
		
		/**
		 * 
		 * */
		override public function marshall(objectType:String = XML_TYPE, representation:Boolean = false):Object {
			var object:Object = super.marshall(objectType, representation);
				
			
			return object;
			/*
			if (objectType==STRING_TYPE || objectType==XML_TYPE ) {
				var source:String;
				var xml:XML = new XML("<" + nodeName +"/>"); // support document or project types
				
				xml.@className = className;
				xml.@dateSaved = getTimeInHistory();
				xml.@host = host;
				xml.@id = id;
				xml.@name = name;
				xml.@type = type;
				xml.@uid = uid;
				xml.@uri = uri;
				
				// add source
				if (!representation) {
					source = getSource();
					if (source) {
						xml = XMLUtils.setItemContents(xml, "source", source);
					}
				}
				
				if (objectType==STRING_TYPE) {
					return xml.toXMLString();
				}
				
				return xml;
			}*/
			
		}
	}
}