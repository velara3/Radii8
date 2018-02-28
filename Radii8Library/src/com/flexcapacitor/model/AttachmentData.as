
package com.flexcapacitor.model {
	import com.flexcapacitor.utils.DisplayObjectUtils;
	
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	
	/**
	 * Used for image attachments in WordPress
	 * */
	public class AttachmentData extends DocumentData {
		
		/**
		 * Constructor
		 * */
		public function AttachmentData(target:IEventDispatcher=null) {
			super(target);
		}
		
		/**
		 * Byte Array
		 * */
		public var byteArray:ByteArray;
		
		/**
		 * Mime type
		 * */
		public var mimeType:String;
		
		/**
		 * Base 64 encoding for data uri
		 * */
		public var base64Encoding:String;
		
		/**
		 * On import should resize to fit document if image is larger than document
		 **/
		public var resizeToFitDocument:Boolean;
		
		/**
		 * On import should resize document to fit the image original size
		 **/
		public var resizeDocumentToFit:Boolean;
		
		/**
		 * Caption for image
		 * */
		public var caption:String;
		
		/**
		 * Full URL to image
		 * */
		public var url:String;
		
		/**
		 * Used for deferred data
		 **/
		public var data:Object;
		
		/**
		 * Is set to true when upload failed
		 * */
		[Bindable]
		public var uploadFailed:Boolean;
		
		/**
		 * Reason upload failed
		 * */
		public var uploadFailedReason:String;
		
		private var _slugSafeName:String;

		public function get slugSafeName():String {
			_slugSafeName = name;
			
			if (_slugSafeName && _slugSafeName.indexOf(" ")!=-1) {
				_slugSafeName = _slugSafeName.replace(/ /g, "");
			}
			
			if (_slugSafeName) {
				_slugSafeName = _slugSafeName.toLowerCase();
			}
			
			if (_slugSafeName.indexOf(".")!=-1) {
				_slugSafeName = _slugSafeName.substring(0, _slugSafeName.indexOf("."));
			}
			
			return _slugSafeName;
		}

		public function set slugSafeName(value:String):void {
			
			_slugSafeName = value;
		}

		
		private var _fileSafeName:String;

		public function get fileSafeName():String {
			_fileSafeName = name;
			
			if (_fileSafeName && _fileSafeName.indexOf(" ")!=-1) {
				_fileSafeName = _fileSafeName.replace(/ /g, "");
			}
			
			if (_fileSafeName && _fileSafeName.indexOf(".")==-1) {
				
				if (contentType==DisplayObjectUtils.PNG_MIME_TYPE) {
					_fileSafeName = _fileSafeName + ".png";
				}
				
				else if (contentType==DisplayObjectUtils.JPEG_MIME_TYPE) {
					_fileSafeName = _fileSafeName + ".jpeg";
				}
				
				else if (contentType==DisplayObjectUtils.GIF_MIME_TYPE) {
					_fileSafeName = _fileSafeName + ".gif";
				}
				
				else if (contentType==DisplayObjectUtils.FLASH_MIME_TYPE) {
					_fileSafeName = _fileSafeName + ".swf";
				}
			}
			
			return _fileSafeName;
		}

		public function set fileSafeName(value:String):void {
			_fileSafeName = value;
		}

	}
}