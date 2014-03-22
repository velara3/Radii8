package com.nbilyk.file {
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;

	public class MultipartUrlLoader extends URLLoader {

		/**
		 *  @private
		 *  Char codes for 0123456789ABCDEF
		 */
		private static const ALPHA_CHAR_CODES:Array = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70];
		
		public function MultipartUrlLoader(request:URLRequest = null) {
			super(request);
		}
		
		/**
		 * Prepares the URLRequest, constructing the multi-part data as a ByteArray, then calls load.
		 * 
		 * @param formContents FormContent objects are used to describe a file or simple variable.
		 * @param url The url to use in the request.
		 * 
		 * Dispatches:
		 *   Event.COMPLETE 
		 *   HTTPStatusEvent.HTTP_STATUS
		 *   IOErrorEvent.IO_ERROR
		 *   ProgressEvent.PROGRESS
		 *   SecurityErrorEvent.SECURITY_ERROR
		 */
		public function multipartUpload(formContents:Vector.<FormContent>, url:String):void {
			if (!formContents.length) throw new Error("formContents argument cannot be 0 length");
			var boundary:String = "----------" + createUid(); //----------Ij5KM7GI3Ef1ae0gL6ei4GI3ei4KM7
			var charSet:String = "ascii";
			
			var nL:String = "\r\n";
			var urlRequestData:ByteArray = new ByteArray();
			
			for each (var formContent:FormContent in formContents) {
				if (!formContent.name || !formContent.contents) continue;
				var formContentStr:String = "";
				formContentStr += "--" + boundary + nL;
				formContentStr += "Content-Disposition: " + formContent.contentDisposition + "; name=\"" + formContent.name + "\"; ";
				if (formContent.fileName) formContentStr += "filename=\"" + formContent.fileName + "\"; ";
				if (formContent.contentType && formContent.contents) {
					formContentStr += nL + "Content-Type: " + formContent.contentType;
				}
				formContentStr += nL + nL;
				urlRequestData.writeMultiByte(formContentStr, charSet);
				formContent.contents.position = 0;
				urlRequestData.writeBytes(formContent.contents);
				urlRequestData.writeMultiByte(nL, charSet);
			}
			urlRequestData.writeMultiByte("--" + boundary + "--", charSet);
			
			var acceptHeader:URLRequestHeader = new URLRequestHeader("Accept", "text/*");
			var urlRequest:URLRequest = new URLRequest(url);
			urlRequest.requestHeaders.push(acceptHeader);
			urlRequest.data = urlRequestData;
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.contentType = "multipart/form-data; boundary=" + boundary;
			load(urlRequest);
		}


		/**
		 * Taken from Adobe's UIDUtil.createUID.  
		 *  Generates a UID (unique identifier) based on ActionScript's
		 *  pseudo-random number generator and the current time.
		 *
		 *  <p>The UID has the form
		 *  <code>"XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"</code>
		 *  where X is a hexadecimal digit (0-9, A-F).</p>
		 *
		 *  <p>This UID will not be truly globally unique; but it is the best
		 *  we can do without player support for UID generation.</p>
		 *
		 *  @return The newly-generated UID.
		 */
		private function createUid():String {
			var uid:Array = new Array(36);
			var index:int = 0;

			var i:int;
			var j:int;

			for (i = 0; i < 8; i++) {
				uid[index++] = ALPHA_CHAR_CODES[Math.floor(Math.random() * 16)];
			}

			for (i = 0; i < 3; i++) {
				uid[index++] = 45; // charCode for "-"

				for (j = 0; j < 4; j++) {
					uid[index++] = ALPHA_CHAR_CODES[Math.floor(Math.random() * 16)];
				}
			}

			uid[index++] = 45; // charCode for "-"

			var time:Number = new Date().getTime();
			// Note: time is the number of milliseconds since 1970,
			// which is currently more than one trillion.
			// We use the low 8 hex digits of this number in the UID.
			// Just in case the system clock has been reset to
			// Jan 1-4, 1970 (in which case this number could have only
			// 1-7 hex digits), we pad on the left with 7 zeros
			// before taking the low digits.
			var timeString:String = ("0000000" + time.toString(16).toUpperCase()).substr(-8);

			for (i = 0; i < 8; i++) {
				uid[index++] = timeString.charCodeAt(i);
			}

			for (i = 0; i < 4; i++) {
				uid[index++] = ALPHA_CHAR_CODES[Math.floor(Math.random() * 16)];
			}

			return String.fromCharCode.apply(null, uid);
		}
	}
}