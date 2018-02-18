

package com.flexcapacitor.model {
	import flash.display.BitmapData;
	
	
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
		 * Layer info from import
		 * */
		public var layerInfo:Object;
		
		/**
		 * On import should resize to fit document if image is larger than document
		 **/
		public var resizeToFitDocument:Boolean;
		
		/**
		 * On import should resize document to fit the image original size
		 **/
		public var resizeDocumentToFit:Boolean;
		
		/**
		 * 
		 * */
		override public function unmarshall(data:Object):void {
			var imageData:ImageData;
			var images:Object;
			
			if (data is ImageData) { // only added minimal support for image data atm
				imageData 	= ImageData(data);
				description = imageData.description;
				id 			= imageData.id;
				mimeType	= imageData.mimeType;
				parentId	= imageData.parentId;
				name 		= imageData.name;
				//name 		= data.title; ?? 
				url 		= imageData.url;
				slug 		= imageData.slug;
				width 		= imageData.width;
				height 		= imageData.height;
				
				mediumURL	= imageData.mediumURL;
				smallURL	= imageData.smallURL;
				thumbnailURL= imageData.thumbnailURL;
				width 		= imageData.width;
				height 		= imageData.height;
			}
			else if (data is Object) {
				
				caption 	= data.caption;
				description = data.description;
				id 			= data.id;
				mimeType	= data.mime_type;
				parentId	= data.parent;
				name 		= data.title;
				slug 		= data.slug;
				url 		= data.url;
				
				images = data.images;
				
				// an image can not have values if something goes wrong. gif was not returning images.
				if (images) {
					if (images.medium) {
						mediumURL	= images.medium.url;
					}
					
					if (images["small-feature"]) {
						smallURL	= images["small-feature"].url;
					}
					
					if (images["post-thumbnail"]) {
						//postThumbnailURL	= data.images.["post-thumbnail"].url;
					}
					
					if (images.thumbnail) {
						thumbnailURL	= images.thumbnail.url;
					}
					
					if (images.full) {
						width 			= images.full.width;
						height 			= images.full.height;
					}
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